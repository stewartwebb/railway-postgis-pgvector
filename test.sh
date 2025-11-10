#!/bin/bash
set -e

echo "=================================="
echo "PostgreSQL + PostGIS + pgvector Test Suite"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
test_pass() {
    echo -e "${GREEN}✓ $1${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}✗ $1${NC}"
    ((TESTS_FAILED++))
}

# Database connection parameters
PGHOST="${PGHOST:-localhost}"
PGPORT="${PGPORT:-5432}"
PGUSER="${PGUSER:-postgres}"
PGPASSWORD="${PGPASSWORD:-postgres}"
PGDATABASE="${PGDATABASE:-railway}"

export PGPASSWORD

echo ""
echo "Connection Parameters:"
echo "  Host: $PGHOST"
echo "  Port: $PGPORT"
echo "  User: $PGUSER"
echo "  Database: $PGDATABASE"
echo ""

# Test 1: PostgreSQL Connection
echo "Test 1: PostgreSQL Connection"
if psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT 1;" > /dev/null 2>&1; then
    test_pass "PostgreSQL connection successful"
else
    test_fail "PostgreSQL connection failed"
fi

# Test 2: PostgreSQL Version
echo ""
echo "Test 2: PostgreSQL Version"
VERSION=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -c "SELECT version();" | grep -oP "PostgreSQL \d+" || echo "")
if [[ "$VERSION" == *"PostgreSQL 17"* ]]; then
    test_pass "PostgreSQL 17 detected: $VERSION"
else
    test_fail "PostgreSQL 17 not detected. Found: $VERSION"
fi

# Test 3: PostGIS Extension
echo ""
echo "Test 3: PostGIS Extension"
POSTGIS_INSTALLED=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -c "SELECT COUNT(*) FROM pg_extension WHERE extname = 'postgis';" | xargs)
if [ "$POSTGIS_INSTALLED" -eq 1 ]; then
    POSTGIS_VERSION=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -c "SELECT PostGIS_version();" | xargs)
    test_pass "PostGIS extension installed: $POSTGIS_VERSION"
else
    test_fail "PostGIS extension not installed"
fi

# Test 4: PostGIS Functionality
echo ""
echo "Test 4: PostGIS Functionality"
if psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT ST_AsText(ST_MakePoint(0, 0));" > /dev/null 2>&1; then
    test_pass "PostGIS spatial functions working"
else
    test_fail "PostGIS spatial functions not working"
fi

# Test 5: pgvector Extension
echo ""
echo "Test 5: pgvector Extension"
PGVECTOR_INSTALLED=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -c "SELECT COUNT(*) FROM pg_extension WHERE extname = 'vector';" | xargs)
if [ "$PGVECTOR_INSTALLED" -eq 1 ]; then
    PGVECTOR_VERSION=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -t -c "SELECT extversion FROM pg_extension WHERE extname = 'vector';" | xargs)
    test_pass "pgvector extension installed: version $PGVECTOR_VERSION"
else
    test_fail "pgvector extension not installed"
fi

# Test 6: pgvector Functionality
echo ""
echo "Test 6: pgvector Functionality"
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" << EOF > /dev/null 2>&1
CREATE TABLE IF NOT EXISTS test_vectors (id serial PRIMARY KEY, embedding vector(3));
INSERT INTO test_vectors (embedding) VALUES ('[1,2,3]'), ('[4,5,6]');
SELECT embedding FROM test_vectors LIMIT 1;
DROP TABLE test_vectors;
EOF

if [ $? -eq 0 ]; then
    test_pass "pgvector operations working"
else
    test_fail "pgvector operations not working"
fi

# Test 7: Combined PostGIS and pgvector
echo ""
echo "Test 7: Combined PostGIS and pgvector Usage"
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" << EOF > /dev/null 2>&1
CREATE TABLE IF NOT EXISTS test_geo_vectors (
    id serial PRIMARY KEY,
    location geometry(Point, 4326),
    embedding vector(3)
);
INSERT INTO test_geo_vectors (location, embedding) 
VALUES (ST_SetSRID(ST_MakePoint(-73.935242, 40.730610), 4326), '[1,2,3]');
SELECT id FROM test_geo_vectors WHERE ST_DWithin(location, ST_SetSRID(ST_MakePoint(-73.935242, 40.730610), 4326), 100);
DROP TABLE test_geo_vectors;
EOF

if [ $? -eq 0 ]; then
    test_pass "Combined PostGIS and pgvector operations working"
else
    test_fail "Combined PostGIS and pgvector operations not working"
fi

# Summary
echo ""
echo "=================================="
echo "Test Summary"
echo "=================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "=================================="

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
