from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from fastapi import Depends
from ..models.table_type import TableType
from ..db.postgres import get_db

class GetAllTableTypes:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_all(self) -> list[TableType]:
        result = await self.db.execute(select(TableType))
        table_types = result.scalars().all()
        return table_types
        

def get_all_table_types(db: AsyncSession = Depends(get_db)):
    return GetAllTableTypes(db)