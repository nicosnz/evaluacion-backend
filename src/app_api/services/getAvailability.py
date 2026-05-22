from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from fastapi import Depends
from datetime import date, time, datetime
from redis.asyncio import Redis
from zoneinfo import ZoneInfo
import json 
import logging
from models.table_type import TableType
from models.reservation import Reservation
from models.reservation_guest import ReservationGuest
from db.postgres import get_db
from pydantic import BaseModel
from datetime import datetime
from db.cache import get_redis

class AvailabilitySlot(BaseModel):
    time: datetime
    table_type: str        
    table_type_name: str
    seats: int             
    available_seats: int   
    price_per_seat: float

logger = logging.getLogger(__name__)

CACHE_TTL = 60
    
class GetAvailability:
    def __init__(self, db: AsyncSession,redis:Redis):
        self.db = db
        self.redis=redis
        
    def _cache_key(self, date: date, time: time | None, party: int, table_type: str | None, tz: str) -> str:
        return f"availability:{date}:{time}:{party}:{table_type or 'any'}:{tz}"

    async def _get_from_cache(self, key: str) -> list[AvailabilitySlot] | None:
        try:
            cached = await self.redis.get(key)
            if cached:
                data = json.loads(cached)
                return [AvailabilitySlot(**item) for item in data]
        except Exception as e:
            logger.warning(f"Redis get availability fallo: {e}")
        return None
    async def _set_cache(self, key: str, data: list[AvailabilitySlot]) -> None:
            try:
                serialized = json.dumps([item.model_dump(mode="json") for item in data])
                await self.redis.setex(key, CACHE_TTL, serialized)
            except Exception as e:
                logger.warning(f"Redis set availability fallo: {e}")
    async def get_availability(
        self,
        date: date,
        time: time | None,
        party: int,
        table_type: str | None,
        tz: str
    ) -> list[AvailabilitySlot]:
        key = self._cache_key(date,time,party,table_type,tz)
        
        cached = await self._get_from_cache(key)
        if cached is not None:
            return cached
        
        result = await self._get_from_db(date, time, party, table_type, tz)

        await self._set_cache(key, result)

        return result
    
    async def _get_from_db(
        self,
        date: date,
        time: time | None,
        party: int,
        table_type: str | None,
        tz: str
    ) -> list[AvailabilitySlot]:        
        
        try:
            client_tz = ZoneInfo(tz)
        except Exception:
            client_tz = ZoneInfo("UTC")

        if time:
            local_dt = datetime.combine(date, time).replace(tzinfo=client_tz)
            reservation_time_utc = local_dt.astimezone(ZoneInfo("UTC")).replace(tzinfo=None)
            time_filter = Reservation.reservation_time == reservation_time_utc
        else:
            start = datetime.combine(date, datetime.min.time())
            end = datetime.combine(date, datetime.max.time())
            time_filter = Reservation.reservation_time.between(start, end)

        guests_per_reservation = (
            select(
                Reservation.table_type_id,
                func.count(ReservationGuest.id).label("guest_count")
            )
            .join(ReservationGuest, ReservationGuest.reservation_id == Reservation.id)
            .where(
                time_filter,
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

        if table_type and table_type.lower() not in ("", "any"):
            stmt = stmt.where(TableType.type == table_type)

        result = await self.db.execute(stmt)
        rows = result.all()

        reference_time = local_dt.replace(tzinfo=None) if time else datetime.combine(date, datetime.min.time())

        return [
            AvailabilitySlot(
                time=reference_time,
                table_type=tt.type,
                table_type_name=tt.name,
                seats=tt.capacity,
                available_seats=tt.capacity - reserved,
                price_per_seat=tt.price
            )
            for tt, reserved in rows
            if tt.capacity - reserved >= party
        ]

def get_availability_service(db: AsyncSession = Depends(get_db),redis:Redis = Depends(get_redis)):
    return GetAvailability(db,redis)