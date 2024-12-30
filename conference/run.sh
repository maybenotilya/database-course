make up


docker exec postgres_container psql -U postgres -f /scripts/fill.sql && \
sleep 1.5 && \
docker exec postgres_container psql -U postgres -f /scripts/queries.sql


docker exec postgres_container psql -U postgres -f /scripts/fill.sql && \
sleep 1.5 && \
docker exec postgres_container psql -U postgres -f /scripts/updates.sql