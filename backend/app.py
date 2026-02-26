from typing import Annotated
from pydantic import BaseModel
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi.middleware.cors import CORSMiddleware
import dotenv
import os
import database

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://tanken.nvvliet.nl", "https://tanken.nvvliet.nl"], # In production, replace "*" with your actual domain
    allow_credentials=True,
    allow_methods=["*"], # This allows POST, OPTIONS, GET, etc.
    allow_headers=["*"], # This allows your Authorization header
)
dotenv.load_dotenv()

security = HTTPBearer()

TOKEN = os.getenv("APIKEY")

class Item(BaseModel):
    km: float
    liters: float

class Afrekenen(BaseModel):
    km: float

@app.post("/tanken")
def tanken(item: Item,
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)]
):
    if credentials.credentials != TOKEN:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    else:
        con, cur = database.check_and_makedb() 
        database.insert_data(con=con,cur=cur, km=item.km, liters=item.liters)
        con.close()
        return f"Updated: {item}"

@app.post("/afrekening")
def afrekening(afrekenen: Afrekenen,
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)]
):
    if credentials.credentials != TOKEN:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    else:
        con, cur = database.check_and_makedb() 
        avg_km, avg_liters = database.get_averages(con, cur)
        avg_consumption = avg_liters/avg_km

        est_liters = avg_consumption * afrekenen.km
        return est_liters