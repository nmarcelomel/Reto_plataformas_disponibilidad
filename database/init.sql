-- NOC Dashboard - Database Initialization
-- Creates the monitoring tables for service health tracking

-- Service registry table
CREATE TABLE IF NOT EXISTS monitoring.services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'unknown',
    last_check TIMESTAMP DEFAULT NOW(),
    response_time_ms INTEGER DEFAULT 0,
    metadata JSONB DEFAULT '{}'
);

-- Insert baseline services
INSERT INTO monitoring.services (name, status, response_time_ms) VALUES
    ('api-gateway', 'healthy', 45),
    ('auth-service', 'healthy', 120),
    ('payment-processor', 'healthy', 200),
    ('notification-engine', 'healthy', 80),
    ('data-pipeline', 'healthy', 350),
    ('cache-layer', 'healthy', 15),
    ('search-index', 'healthy', 180),
    ('file-storage', 'healthy', 95),
    ('message-queue', 'healthy', 30),
    ('monitoring-agent', 'healthy', 60);

-- Health check log (accumulates over time)
CREATE TABLE IF NOT EXISTS monitoring.health_log (
    id SERIAL PRIMARY KEY,
    service_id INTEGER REFERENCES monitoring.services(id),
    checked_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(20) NOT NULL,
    response_time_ms INTEGER,
    error_message TEXT
);

-- Generate some historical data
INSERT INTO monitoring.health_log (service_id, checked_at, status, response_time_ms)
SELECT 
    s.id,
    NOW() - (interval '1 minute' * generate_series(1, 100)),
    'healthy',
    (random() * 200 + 20)::integer
FROM monitoring.services s;
