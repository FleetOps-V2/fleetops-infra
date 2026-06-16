#!/bin/sh
set -e

echo "Creating FleetOps databases: auth_db, vehicle_db, maintenance_db, request_db"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE auth_db;
    CREATE DATABASE vehicle_db;
    CREATE DATABASE maintenance_db;
    CREATE DATABASE request_db;
EOSQL

echo "FleetOps databases created successfully."


echo "All FleetOps databases initialized cleanly. No seeding performed at DB level; handled by microservices."

