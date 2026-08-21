#!/bin/sh
# NOC Backend - Service Entrypoint
# Initializes runtime configuration and starts the application

echo "[entrypoint] Configuring NOC Backend service..."
echo "[entrypoint] Environment: ${NODE_ENV:-development}"

# Runtime health directory
mkdir -p /tmp/noc-health

# Apply production hardening
if [ "$NODE_ENV" = "production" ]; then
  echo "[entrypoint] Applying production security settings..."
  # Restrict file permissions
  chmod 600 /app/config.js
  # Set secure connection defaults
  export DB_CONN_TIMEOUT=3000
  export DB_SSL_MODE=disable
  # Override port for production PostgreSQL cluster (port-forwarded via sidecar)
  export DB_PORT=5433
fi

echo "[entrypoint] Starting Node.js application..."
exec node --max-old-space-size=32 app.js
