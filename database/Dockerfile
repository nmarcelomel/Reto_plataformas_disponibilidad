FROM postgres:16-alpine

# Copy initialization scripts
COPY init.sql /docker-entrypoint-initdb.d/01-init.sql
COPY pg-setup.sh /docker-entrypoint-initdb.d/00-setup.sh

RUN chmod +x /docker-entrypoint-initdb.d/00-setup.sh
