FROM python:3.10

# Установка необходимых пакетов для OpenTelemetry
RUN pip install --upgrade pip && \
    pip install opentelemetry-distro==0.33b0 \
                opentelemetry-instrumentation-fastapi==0.33b0 \
                opentelemetry-exporter-otlp-proto-grpc==1.12.0

# Выбор папки, в которой будет вестись работа
WORKDIR /code

# Копирование файлов
COPY ./requirements.txt /code/
RUN pip install --no-cache-dir -r /code/requirements.txt

COPY ./app /code/app
COPY ./migration /code/migration
COPY ./alembic.ini /code/alembic.ini

# Экспорт переменной окружения для указания порта Jaeger
ENV JAEGER_AGENT_HOST=jaeger
ENV JAEGER_AGENT_PORT=6831
# Экспорт порта для Jaeger
EXPOSE 80

# Команда для старта приложения с трассировкой
CMD ["sh", "-c", "alembic upgrade head && opentelemetry-instrument --service_name design.api uvicorn app.main:app --host 0.0.0.0 --port 80"]
