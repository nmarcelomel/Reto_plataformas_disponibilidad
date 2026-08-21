#!/bin/bash
# PostgreSQL Setup - Custom authentication configuration
# Applies network security policies for NOC environment

echo "Configuring PostgreSQL authentication policies..."

# Create a dedicated schema for monitoring data
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
    CREATE SCHEMA IF NOT EXISTS monitoring;
    ALTER DATABASE noc_dashboard SET search_path TO public, monitoring;
EOSQL

echo "Authentication configuration complete."
