from sqlmodel import SQLModel,Field
from datetime import datetime

class TimeStampModel(SQLModel):
    created_at:datetime
    updated_at:datetime
    
    