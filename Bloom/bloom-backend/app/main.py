from fastapi import FastAPI
from app.routes.generate import router as generate_router

app = FastAPI(title="Bloom Backend")

app.include_router(generate_router)


@app.get("/")
async def root():
    return {
        "success": True,
        "message": "Bloom backend is running"
    }


@app.get("/health")
async def health():
    return {
        "success": True,
        "status": "ok"
    }
