from fastapi import FastAPI
from .models import *
from .api.v1 import table_types
from .api.v1 import reservations
from .api.v1 import menu
app = FastAPI()

app.include_router(table_types.router,prefix="/api/v1/tables",tags=["table type"])
app.include_router(reservations.router,prefix="/api/v1/reservations",tags=["reservations"])
app.include_router(menu.router,prefix="/api/v1/menu",tags=["menu"])
@app.get("/api/v1/healthz")
async def healthz():
    return {"status": "ok"}