# Ultra-minimal multi-stage build
FROM python:3.9-alpine AS builder

# Install build dependencies
RUN apk add --no-cache gcc musl-dev mariadb-dev pkgconfig

WORKDIR /app
COPY requirements.txt .

# Install to local directory
RUN pip install --user --no-cache-dir mysqlclient \
    && pip install --user --no-cache-dir -r requirements.txt

# Ultra-minimal production stage
FROM python:3.9-alpine

# Install only essential runtime library
RUN apk add --no-cache mariadb-connector-c \
    && rm -rf /var/cache/apk/*

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local

# Add local packages to path
ENV PATH=/root/.local/bin:$PATH

WORKDIR /app
COPY . .

CMD ["python", "app.py"]
