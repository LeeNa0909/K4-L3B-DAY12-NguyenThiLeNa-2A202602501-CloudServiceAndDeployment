FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim AS runtime

WORKDIR /app

COPY --from=builder /install /usr/local
COPY app ./app
COPY utils ./utils

RUN addgroup --system app && adduser --system --ingroup app app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["python", "-c", "import os, urllib.request; port=os.getenv('PORT', '8000'); urllib.request.urlopen(f'http://127.0.0.1:{port}/health')"]

CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
