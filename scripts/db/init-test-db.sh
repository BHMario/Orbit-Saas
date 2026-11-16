#!/bin/bash
# ==============================
# Create a separate test database for integration tests.
# This script runs automatically on first container start
# via the /docker-entrypoint-initdb.d/ mechanism.
# ==============================

set -e

echo "Creating test database: orbit_test"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE orbit_test
        OWNER $POSTGRES_USER
        ENCODING 'UTF8'
        LC_COLLATE 'en_US.utf8'
        LC_CTYPE 'en_US.utf8';
EOSQL

echo "Test database orbit_test created successfully."
