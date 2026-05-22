# services/getAvailability.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from fastapi import Depends
from datetime import date, time, datetime
from zoneinfo import ZoneInfo
from ..models.table_type import TableType
from ..models.reservation import Reservation
from ..models.reservation_guest import ReservationGuest
from ..db.postgres import get_db
from pydantic import BaseModel
from datetime import datetime

class AvailabilitySlot(BaseModel):
    time: datetime
    table_type: str        
    table_type_name: str
    seats: int             
    available_seats: int   
    price_per_seat: float
    
    
class GetAvailability:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_availability(
        self,
        date: date,
        time: time,
        party: int,
        table_type: str | None,
        tz: str
    ) -> list[AvailabilitySlot]:

        try:
            client_tz = ZoneInfo(tz)
        except Exception:
            client_tz = ZoneInfo("UTC")

        local_dt = datetime.combine(date, time).replace(tzinfo=client_tz)
        reservation_time_utc = local_dt.astimezone(ZoneInfo("UTC")).replace(tzinfo=None)

        guests_per_reservation = (
            select(
                Reservation.table_type_id,
                func.count(ReservationGuest.id).label("guest_count")
            )
            .join(ReservationGuest, ReservationGuest.reservation_id == Reservation.id)
            .where(
                Reservation.reservation_time == reservation_time_utc,
                Reservation.status.in_(["confirmed", "pending"])
            )
            .group_by(Reservation.table_type_id)
            .subquery()
        )

        stmt = select(
            TableType,
            func.coalesce(guests_per_reservation.c.guest_count, 0).label("reserved_seats")
        ).outerjoin(
            guests_per_reservation,
            TableType.id == guests_per_reservation.c.table_type_id
        ).where(
            TableType.capacity >= party
        )

        if table_type:
            stmt = stmt.where(TableType.type == table_type)

        result = await self.db.execute(stmt)
        rows = result.all()

        return [
            AvailabilitySlot(
                time=local_dt.replace(tzinfo=None),
                table_type=tt.type,
                table_type_name=tt.name,
                seats=tt.capacity,
                available_seats=tt.capacity - reserved,
                price_per_seat=tt.price
            )
            for tt, reserved in rows
            if tt.capacity - reserved >= party  
        ]

def get_availability_service(db: AsyncSession = Depends(get_db)):
    return GetAvailability(db)