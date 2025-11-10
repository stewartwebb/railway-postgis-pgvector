FROM postgres:17-bookworm

# Set environment variables for initial cluster
ENV POSTGRES_DB=railway \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres

# Install PostGIS and pgvector from PGDG repository (already configured in base image)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        postgresql-17-postgis-3 \
        postgresql-17-postgis-3-scripts \
        postgresql-17-pgvector; \
    rm -rf /var/lib/apt/lists/*

# Copy init script to enable extensions at first init
COPY init-extensions.sql /docker-entrypoint-initdb.d/init-extensions.sql

EXPOSE 5432
CMD ["postgres"]
