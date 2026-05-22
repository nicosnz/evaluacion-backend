from fastapi import APIRouter,Depends
from pydantic import BaseModel
from services.getAllTableTypes import GetAllTableTypes,get_all_table_types
router = APIRouter()
import uuid

class TableTypeResponse(BaseModel):
    id: uuid.UUID
    name: str
    seats: int
    description: str

    class Config:
        from_attributes = True
   


@router.get("/types", response_model=list[TableTypeResponse])
async def get_all(
    service: GetAllTableTypes = Depends(get_all_table_types)
):
    tables = await service.get_all()
    return [
            TableTypeResponse(
                id=tt.id,
                name=tt.name,
                seats=tt.capacity,  
                description=tt.description
            )
            for tt in tables
        ]