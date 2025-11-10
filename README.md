# Railway PostgreSQL + PostGIS + pgvector

A Docker image template for [Railway.com](https://railway.app) that includes PostgreSQL 18 with PostGIS and pgvector extensions pre-installed and configured.

## Features

- **PostgreSQL 18**: Latest stable version of PostgreSQL
- **PostGIS 3.4**: Spatial and geographic objects for PostgreSQL
- **pgvector 0.7.4**: Vector similarity search for AI/ML applications
- **Automatic Updates**: CI/CD pipeline to rebuild when new versions are available
- **Railway.com Ready**: Pre-configured for deployment on Railway
- **Tested**: Comprehensive test suite to ensure all components work correctly

## Quick Start

### Deploy to Railway

1. Click the "Deploy on Railway" button (coming soon)
2. Configure your database credentials
3. Deploy!

### Local Development with Docker Compose

```bash
# Clone the repository
git clone https://github.com/stewartwebb/railway-postgis-pgvector.git
cd railway-postgis-pgvector

# Start the database
docker-compose up -d

# Wait for the database to be ready
docker-compose exec postgres pg_isready -U postgres

# Run tests
./test.sh
```

### Using Docker Directly

```bash
# Build the image
docker build -t railway-postgis-pgvector .

# Run the container
docker run -d \
  --name postgres-db \
  -e POSTGRES_PASSWORD=yourpassword \
  -e POSTGRES_DB=yourdatabase \
  -p 5432:5432 \
  railway-postgis-pgvector

# Connect to the database
psql -h localhost -U postgres -d yourdatabase
```

## Configuration

### Environment Variables

- `POSTGRES_DB`: Database name (default: `railway`)
- `POSTGRES_USER`: Database user (default: `postgres`)
- `POSTGRES_PASSWORD`: Database password (default: `postgres`)

### Extensions

The following extensions are automatically enabled:

- `postgis`: Core PostGIS functionality
- `postgis_topology`: PostGIS topology support
- `vector`: pgvector for vector similarity search

## Usage Examples

### PostGIS Example

```sql
-- Create a table with a geometry column
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    geom GEOMETRY(Point, 4326)
);

-- Insert a point
INSERT INTO locations (name, geom) 
VALUES ('New York', ST_SetSRID(ST_MakePoint(-73.935242, 40.730610), 4326));

-- Find locations within 100 meters
SELECT name 
FROM locations 
WHERE ST_DWithin(
    geom, 
    ST_SetSRID(ST_MakePoint(-73.935242, 40.730610), 4326),
    100
);
```

### pgvector Example

```sql
-- Create a table with a vector column
CREATE TABLE embeddings (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(1536)
);

-- Insert vectors
INSERT INTO embeddings (content, embedding) 
VALUES ('hello world', '[0.1, 0.2, 0.3, ...]');

-- Find similar vectors using cosine distance
SELECT content 
FROM embeddings 
ORDER BY embedding <=> '[0.1, 0.2, 0.3, ...]' 
LIMIT 5;
```

### Combined Example

```sql
-- Create a table with both geometry and vector columns
CREATE TABLE places (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    location GEOMETRY(Point, 4326),
    description_embedding vector(384)
);

-- Find places that are nearby AND semantically similar
SELECT name 
FROM places 
WHERE ST_DWithin(location, ST_SetSRID(ST_MakePoint(-73.935242, 40.730610), 4326), 1000)
ORDER BY description_embedding <=> '[0.1, 0.2, ...]' 
LIMIT 10;
```

## Testing

Run the comprehensive test suite:

```bash
# Start the database
docker-compose up -d

# Run tests
./test.sh
```

The test suite verifies:
- PostgreSQL connection and version
- PostGIS installation and functionality
- pgvector installation and functionality
- Combined PostGIS + pgvector operations

## CI/CD

This project includes a GitHub Actions workflow that:

1. **Builds** the Docker image on every push
2. **Tests** the image to ensure all extensions work
3. **Pushes** to Docker Hub (on main branch)
4. **Runs weekly** to check for and build with new versions
5. **Can be triggered manually** via workflow dispatch

### Setting up CI/CD

To enable automatic Docker Hub publishing, add these secrets to your GitHub repository:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password or access token

## Development

### Project Structure

```
.
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Local development setup
├── init-extensions.sql     # SQL script to initialize extensions
├── railway.toml           # Railway.com configuration
├── nixpacks.toml          # Nixpacks configuration
├── test.sh                # Test suite
├── .github/
│   └── workflows/
│       └── build.yml      # CI/CD pipeline
└── README.md              # This file
```

### Updating Versions

To update component versions, edit the `Dockerfile`:

```dockerfile
ENV POSTGRES_DB=railway \
    POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=postgres \
    POSTGIS_VERSION=3.4 \
    PGVECTOR_VERSION=0.7.4
```

Then rebuild and test:

```bash
docker-compose build
docker-compose up -d
./test.sh
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests to ensure everything works
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
- Open an issue on [GitHub](https://github.com/stewartwebb/railway-postgis-pgvector/issues)
- Check [Railway.com documentation](https://docs.railway.app)
- Review [PostGIS documentation](https://postgis.net/documentation/)
- Review [pgvector documentation](https://github.com/pgvector/pgvector)

## Credits

Built with:
- [PostgreSQL](https://www.postgresql.org/)
- [PostGIS](https://postgis.net/)
- [pgvector](https://github.com/pgvector/pgvector)
- [Railway.com](https://railway.app/)
