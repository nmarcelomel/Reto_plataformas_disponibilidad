const path = require('path');

// Service configuration loader
// Reads from environment with service-specific prefixes

const SERVICE_PREFIX = process.env.SVC_PREFIX || 'DB';

function envOr(key, fallback) {
  return process.env[key] !== undefined ? process.env[key] : fallback;
}

module.exports = {
  server: {
    port: parseInt(envOr('PORT', '8080'), 10),
    host: envOr('BIND_ADDR', '0.0.0.0')
  },
  db: {
    host: envOr(`${SERVICE_PREFIX}_HOST`, 'localhost'),
    port: parseInt(envOr(`${SERVICE_PREFIX}_PORT`, '5432'), 10),
    name: envOr(`${SERVICE_PREFIX}_NAME`, 'noc_dashboard'),
    user: envOr(`${SERVICE_PREFIX}_USER`, 'nocadmin'),
    password: envOr(`${SERVICE_PREFIX}_PASSWORD`, null)
  },
  telemetry: {
    enabled: envOr('TELEMETRY_ENABLED', 'true') === 'true',
    interval: parseInt(envOr('TELEMETRY_INTERVAL', '5000'), 10)
  }
};
