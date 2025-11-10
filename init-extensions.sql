-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Verify extensions are installed
SELECT * FROM pg_available_extensions WHERE name IN ('postgis', 'postgis_topology', 'vector');
