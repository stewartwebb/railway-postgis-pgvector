# Build and Test Guide

This document provides detailed instructions for building and testing the PostgreSQL + PostGIS + pgvector Docker image.

## Prerequisites

- Docker installed and running
- Docker Compose (optional, for easier local development)
- PostgreSQL client tools (for testing)

## Building the Image

### Local Build

```bash
docker build -t railway-postgis-pgvector:local .
```

### Build with Docker Compose

```bash
docker-compose build
```

## Testing

### Option 1: Using the Test Script

Start the container:
```bash
docker-compose up -d
```

Run the test suite:
```bash
./test.sh
```

Clean up:
```bash
docker-compose down -v
```

### Option 2: Manual Testing

Start a container:
```bash
docker run -d --name test-postgres \
  -e POSTGRES_PASSWORD=testpass \
  -e POSTGRES_DB=testdb \
  -p 5432:5432 \
  railway-postgis-pgvector:local
```

Wait for PostgreSQL to be ready:
```bash
docker exec test-postgres pg_isready -U postgres
```

Test PostgreSQL version:
```bash
docker exec test-postgres psql -U postgres -d testdb -c "SELECT version();"
```

Test PostGIS:
```bash
docker exec test-postgres psql -U postgres -d testdb -c "SELECT PostGIS_version();"
```

Test pgvector:
```bash
docker exec test-postgres psql -U postgres -d testdb -c "SELECT extversion FROM pg_extension WHERE extname = 'vector';"
```

Test spatial queries:
```bash
docker exec test-postgres psql -U postgres -d testdb -c "SELECT ST_AsText(ST_MakePoint(0, 0));"
```

Test vector operations:
```bash
docker exec test-postgres psql -U postgres -d testdb << 'EOF'
CREATE TABLE test_vectors (id serial PRIMARY KEY, embedding vector(3));
INSERT INTO test_vectors (embedding) VALUES ('[1,2,3]'), ('[4,5,6]');
SELECT * FROM test_vectors ORDER BY embedding <-> '[1,2,3]' LIMIT 1;
DROP TABLE test_vectors;
EOF
```

Clean up:
```bash
docker stop test-postgres
docker rm test-postgres
```

## Troubleshooting

### Network Issues During Build

If you encounter network connectivity issues (e.g., "Temporary failure resolving 'apt.postgresql.org'"):

1. **Check your network connection**: Ensure you have internet access
2. **Try again**: Network issues can be transient
3. **Use a VPN**: Some networks may block certain repositories
4. **Build with cache**: Use `docker build --no-cache` to force a fresh build

### Container Won't Start

Check logs:
```bash
docker logs test-postgres
```

Common issues:
- Port 5432 already in use: Stop other PostgreSQL instances or use a different port
- Insufficient permissions: Ensure Docker has proper permissions

### Extensions Not Loading

Verify extensions are installed:
```bash
docker exec test-postgres psql -U postgres -d testdb -c "SELECT * FROM pg_available_extensions WHERE name IN ('postgis', 'vector');"
```

If extensions are missing, the build may have failed. Rebuild the image.

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/build.yml`) automatically:

1. Builds the image on every push
2. Runs the test suite
3. Pushes to Docker Hub (if configured)
4. Runs weekly to check for updates

### Required Secrets

To enable Docker Hub publishing, configure these secrets in your GitHub repository:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password or access token

## Performance Testing

For performance testing with realistic workloads:

```bash
# Start container with custom memory limits
docker run -d --name perf-postgres \
  -e POSTGRES_PASSWORD=testpass \
  -p 5432:5432 \
  -m 2g \
  --memory-swap 2g \
  railway-postgis-pgvector:local

# Run pgbench
docker exec perf-postgres pgbench -i -s 50 postgres
docker exec perf-postgres pgbench -c 10 -j 2 -t 1000 postgres
```

## Version Updates

To update component versions:

1. Edit `Dockerfile` and update version environment variables:
   ```dockerfile
   ENV POSTGIS_VERSION=3.5 \
       PGVECTOR_VERSION=0.8.0
   ```

2. Rebuild and test:
   ```bash
   docker build -t railway-postgis-pgvector:test .
   docker run -d --name test-update railway-postgis-pgvector:test
   ./test.sh
   ```

3. Commit changes if tests pass

## Support

For issues:
- Check Docker logs: `docker logs <container-name>`
- Review PostgreSQL logs inside the container: `docker exec <container-name> cat /var/log/postgresql/postgresql-18-main.log`
- Open an issue on GitHub with logs and error messages
