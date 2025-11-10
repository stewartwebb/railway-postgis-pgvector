FROM postgres:17-bookworm

# Set environment variables for initial cluster
ENV POSTGRES_DB=railway \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres

# Install prerequisites and configure PGDG repo with modern keyring method
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg; \
    install -d -m 0755 /usr/share/keyrings; \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(. /etc/os-release && echo $VERSION_CODENAME)-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
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
