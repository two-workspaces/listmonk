# Official listmonk image plus psql, so the first boot can point listmonk's
# root URL at the Railway domain (it lives in the database, not in env).
FROM listmonk/listmonk:v6.2.0
RUN apk add --no-cache postgresql-client
COPY railway-start.sh /usr/local/bin/railway-start.sh
CMD ["/usr/local/bin/railway-start.sh"]
