###############################################################
# app/main.py – Minimal FastAPI application
# Serves: GET /health  →  200 JSON
#         GET /version →  200 JSON
#         GET /        →  200 HTML landing page
###############################################################
from fastapi import FastAPI
from fastapi.responses import HTMLResponse, JSONResponse
import platform, os, datetime

app = FastAPI(title="DevOps Assessment App", version="1.0.0")

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "local")

START_TIME = datetime.datetime.utcnow()

def uptime_seconds() -> float:
    delta = datetime.datetime.utcnow() - START_TIME
    return round(delta.total_seconds(), 2)

@app.get("/health", tags=["ops"])
async def health():
    """Liveness / readiness probe – always returns 200."""
    return JSONResponse(
        status_code=200,
        content={
            "status": "ok",
            "uptime_seconds": uptime_seconds(),
            "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
        },
    )

@app.get("/version", tags=["ops"])
async def version():
    """Returns version and build metadata."""
    return JSONResponse(
        status_code=200,
        content={
            "version": APP_VERSION,
            "environment": ENVIRONMENT,
            "python": platform.python_version(),
            "host": platform.node(),
            "os": platform.system(),
            "deployed_at": START_TIME.isoformat() + "Z",
        },
    )

@app.get("/", response_class=HTMLResponse, include_in_schema=False)
async def root():
    """Simple HTML landing page."""
    return f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>DevOps Assessment App</title>
      <style>
        *{{margin:0;padding:0;box-sizing:border-box}}
        body{{font-family:system-ui,sans-serif;background:linear-gradient(135deg,#0f0c29,#302b63,#24243e);
          min-height:100vh;display:flex;align-items:center;justify-content:center;color:#fff}}
        .card{{background:rgba(255,255,255,.08);backdrop-filter:blur(12px);border:1px solid rgba(255,255,255,.15);
          border-radius:20px;padding:3rem 4rem;text-align:center;box-shadow:0 25px 50px rgba(0,0,0,.4)}}
        .badge{{display:inline-block;background:linear-gradient(90deg,#00c6ff,#0072ff);border-radius:999px;
          padding:6px 18px;font-size:.75rem;font-weight:700;letter-spacing:2px;text-transform:uppercase;margin-bottom:1.5rem}}
        h1{{font-size:2.5rem;font-weight:800;margin-bottom:.5rem}}
        p{{color:rgba(255,255,255,.65);margin-bottom:.3rem}}
        .links{{margin-top:2rem;display:flex;gap:1rem;justify-content:center}}
        .links a{{background:rgba(255,255,255,.12);border:1px solid rgba(255,255,255,.2);color:#fff;
          text-decoration:none;padding:10px 22px;border-radius:10px;font-weight:600;transition:background .2s}}
        .links a:hover{{background:rgba(255,255,255,.22)}}
      </style>
    </head>
    <body>
      <div class="card">
        <div class="badge">Containerised</div>
        <h1>DevOps Assessment</h1>
        <p>Environment: <strong>{ENVIRONMENT}</strong></p>
        <p>Version: <strong>v{APP_VERSION}</strong></p>
        <p>Host: <strong>{platform.node()}</strong></p>
        <p>Uptime: <strong>{uptime_seconds()}s</strong></p>
        <div class="links">
          <a href="/health">Health</a>
          <a href="/version">Version</a>
          <a href="/docs">API Docs</a>
        </div>
      </div>
    </body>
    </html>
    """
