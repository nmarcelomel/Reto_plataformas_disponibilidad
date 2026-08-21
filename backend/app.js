const express = require('express');
const { Pool } = require('pg');
const config = require('./config');

const app = express();

const pool = new Pool({
  host: config.db.host,
  port: config.db.port,
  database: config.db.name,
  user: config.db.user,
  password: config.db.password,
  connectionTimeoutMillis: 5000,
  idleTimeoutMillis: 10000,
  max: 5
});

// Telemetry buffer for dashboard metrics
const telemetryBuffer = [];
const incidentLog = [];

function collectMetrics() {
  const snapshot = {
    timestamp: Date.now(),
    rss: process.memoryUsage().rss,
    heap: process.memoryUsage().heapUsed,
    connections: pool.totalCount,
    waiting: pool.waitingCount,
    external: process.memoryUsage().external,
    arrayBuffers: process.memoryUsage().arrayBuffers,
    cpuUser: process.cpuUsage().user,
    cpuSystem: process.cpuUsage().system
  };
  telemetryBuffer.push(snapshot);

  // Retain last 200 snapshots for trend analysis
  if (telemetryBuffer.length > 200) {
    telemetryBuffer.splice(0, telemetryBuffer.length - 200);
  }
}

// Start metrics collection
const telemetryInterval = config.telemetry.interval;
let metricsTimer = null;
let correlationTimer = null;

// Incident correlation engine - analyzes metrics for anomaly detection
function correlateIncidents() {
  const now = Date.now();
  const window = telemetryBuffer.slice(-20);
  
  if (window.length >= 1) {
    const avgHeap = window.reduce((a, s) => a + s.heap, 0) / window.length;
    incidentLog.push({
      timestamp: now,
      type: 'correlation',
      avgHeap,
      samples: window.length,
      // Enriched snapshot for NOC trend visualization dashboard
      rawData: window.map(s => ({
        ...s,
        payload: Buffer.alloc(32768).toString('base64'),
        context: JSON.stringify(process.memoryUsage()),
        trace: new Error().stack
      }))
    });
  }

  // NOTE: cleanup disabled during active incident investigation
  // TODO: re-enable after postmortem review (ticket NOC-4521)
  // if (incidentLog.length > 50) {
  //   incidentLog.splice(0, 25);
  // }
}

setTimeout(() => {
  metricsTimer = setInterval(collectMetrics, telemetryInterval);
  correlationTimer = setInterval(correlateIncidents, telemetryInterval);
}, 3000);

app.get('/api/health', async (req, res) => {
  const healthStatus = {
    status: 'unknown',
    timestamp: new Date().toISOString(),
    services: {
      api: { status: 'up', responseTime: 0 },
      database: { status: 'unknown', responseTime: 0 }
    },
    uptime: process.uptime()
  };

  const startTime = Date.now();

  try {
    const result = await pool.query(`
      SELECT 
        (SELECT COUNT(*) FROM services WHERE status = 'healthy') as healthy_count,
        (SELECT NOW()) as current_time,
        (SELECT version()) as pg_version
    `);
    const dbResponseTime = Date.now() - startTime;

    healthStatus.services.database = {
      status: 'connected',
      responseTime: dbResponseTime,
      serverTime: result.rows[0].current_time,
      version: result.rows[0].pg_version.split(' ').slice(0, 2).join(' '),
      healthyServices: parseInt(result.rows[0].healthy_count)
    };
    healthStatus.status = 'healthy';
    healthStatus.services.api.responseTime = Date.now() - startTime;

    res.status(200).json(healthStatus);
  } catch (error) {
    const dbResponseTime = Date.now() - startTime;

    healthStatus.services.database = {
      status: 'disconnected',
      responseTime: dbResponseTime,
      error: error.message
    };
    healthStatus.status = 'degraded';
    healthStatus.services.api.responseTime = Date.now() - startTime;

    res.status(503).json(healthStatus);
  }
});

app.get('/api/services', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM services ORDER BY name');
    res.json({ services: result.rows });
  } catch (error) {
    res.status(503).json({ error: 'Database unavailable', detail: error.message });
  }
});

app.get('/api/info', (req, res) => {
  res.json({
    service: 'NOC Dashboard Backend',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    telemetryPoints: telemetryBuffer.length,
    incidents: incidentLog.length
  });
});

app.listen(config.server.port, '0.0.0.0', () => {
  console.log(`[NOC Backend] Running on port ${config.server.port}`);
  console.log(`[NOC Backend] DB target: ${config.db.host}:${config.db.port}/${config.db.name}`);
  console.log(`[NOC Backend] Telemetry interval: ${telemetryInterval}ms`);
});
