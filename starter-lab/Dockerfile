FROM public.ecr.aws/docker/library/python:3.12-slim AS builder
WORKDIR /install
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM public.ecr.aws/docker/library/python:3.12-slim
RUN useradd -m appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app/app.py .
USER appuser
EXPOSE 8080
CMD ["python", "app.py"]
