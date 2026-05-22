from pydantic import BaseModel
import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import Depends
from datetime import date
from ..models.menu import Menu
from ..models.menu_item import MenuItem
from ..db.postgres import get_db

class MenuItemResponse(BaseModel):
    id: uuid.UUID
    course: int
    name: str
    description: str
    price: float
    allergens: list[str]

    class Config:
        from_attributes = True


class GetMenu:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_date(self, date: date) -> list[MenuItemResponse]:
        # Buscar menu activo en esa fecha
        menu_stmt = select(Menu).where(
            Menu.active_from <= date,
            Menu.active_to >= date
        )
        menu_result = await self.db.execute(menu_stmt)
        menu = menu_result.scalars().first()

        if not menu:
            return []

        # Buscar items del menu ordenados por curso
        items_stmt = select(MenuItem).where(
            MenuItem.menu_id == menu.id
        ).order_by(MenuItem.course_number)

        items_result = await self.db.execute(items_stmt)
        items = items_result.scalars().all()

        return [
            MenuItemResponse(
                id=item.id,
                course=item.course_number,
                name=item.name,
                description=item.description,
                price=item.price,
                allergens=[a.strip() for a in item.ingredients.split(",") if a.strip()]
            )
            for item in items
        ]

def get_menu_service(db: AsyncSession = Depends(get_db)):
    return GetMenu(db)