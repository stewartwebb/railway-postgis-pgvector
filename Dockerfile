FROM postgres:18

# Set environment variables
ENV POSTGRES_DB=railway \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres \
    POSTGIS_VERSION=3.4 \
    PGVECTOR_VERSION=0.7.4

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-18-postgis-3 \
    postgresql-18-postgis-3-scripts \
    build-essential \
    git \
    postgresql-server-dev-18 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install pgvector from source
RUN cd /tmp && \
    git clone --branch v${PGVECTOR_VERSION} https://github.com/pgvector/pgvector.git && \
    cd pgvector && \
    make clean && \
    make OPTFLAGS="" && \
    make install && \
    cd / && \
    rm -rf /tmp/pgvector

# Create init script to enable extensions
RUN mkdir -p /docker-entrypoint-initdb.d
COPY init-extensions.sql /docker-entrypoint-initdb.d/

# Expose PostgreSQL port
EXPOSE 5432

# Use the default postgres entrypoint
CMD ["postgres"]
