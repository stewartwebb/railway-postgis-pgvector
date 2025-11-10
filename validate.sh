#!/bin/bash
# Validation script to check project structure and configuration

echo "========================================"
echo "Project Structure Validation"
echo "========================================"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $1 is missing"
        FAILED=$((FAILED + 1))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $1 is missing"
        FAILED=$((FAILED + 1))
    fi
}
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $1 is missing"
        FAILED=$((FAILED + 1))
    fi
}

echo ""
echo "Checking required files..."
check_file "Dockerfile"
check_file "railway.toml"
check_file "railway.json"
check_file "nixpacks.toml"
check_file "docker-compose.yml"
check_file "init-extensions.sql"
check_file "test.sh"
check_file "README.md"
check_file "LICENSE"
check_file ".gitignore"

echo ""
echo "Checking documentation..."
check_file "BUILD_AND_TEST.md"
check_file "CONTRIBUTING.md"

echo ""
echo "Checking CI/CD..."
check_dir ".github/workflows"
check_file ".github/workflows/build.yml"
check_file ".github/workflows/check-updates.yml"

echo ""
echo "Checking Dockerfile content..."
if grep -q "FROM postgres:17" Dockerfile; then
    echo -e "${GREEN}✓${NC} Uses PostgreSQL 17"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} Does not use PostgreSQL 17"
    FAILED=$((FAILED + 1))
fi


echo ""
echo "Checking test script..."
if [ -x "test.sh" ]; then
    echo -e "${GREEN}✓${NC} test.sh is executable"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} test.sh is not executable"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "Checking init-extensions.sql..."
if grep -q "CREATE EXTENSION.*postgis" init-extensions.sql; then
    echo -e "${GREEN}✓${NC} PostGIS extension initialization found"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} PostGIS extension initialization missing"
    FAILED=$((FAILED + 1))
fi

if grep -q "CREATE EXTENSION.*vector" init-extensions.sql; then
    echo -e "${GREEN}✓${NC} pgvector extension initialization found"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} pgvector extension initialization missing"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "========================================"
echo "Summary"
echo "========================================"
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo "========================================"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}Some validations failed!${NC}"
    exit 1
fi
