#!/bin/sh
# Install on an empty database, migrate on upgrades, then serve.
set -e
export PGHOST="$LISTMONK_db__host" PGPORT="${LISTMONK_db__port:-5432}" PGUSER="$LISTMONK_db__user" \
  PGPASSWORD="$LISTMONK_db__password" PGDATABASE="$LISTMONK_db__database"

until pg_isready -q -t 2; do echo "[railway] waiting for Postgres at $PGHOST"; sleep 2; done

./listmonk --install --idempotent --yes --config ''
./listmonk --upgrade --yes --config ''

# listmonk builds unsubscribe, tracking and archive links from app.root_url,
# which installs as http://localhost:9000. Replace only that default, so a
# URL set later in Settings survives redeploys.
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  # psql only interpolates :'url' on stdin, not with -c.
  n=$(echo "UPDATE settings SET value = :'url'::jsonb WHERE key = 'app.root_url'
    AND value = '\"http://localhost:9000\"'::jsonb RETURNING 1;" |
    psql -tAq -v ON_ERROR_STOP=1 -v url="\"https://$RAILWAY_PUBLIC_DOMAIN\"")
  [ -n "$n" ] && echo "[railway] root URL set to https://$RAILWAY_PUBLIC_DOMAIN"
fi

exec ./listmonk --config ''
