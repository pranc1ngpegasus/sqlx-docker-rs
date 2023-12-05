FROM gcr.io/distroless/cc

COPY tmp/sqlx-docker-rs /usr/local/bin/sqlx-docker-rs

ENTRYPOINT ["/usr/local/bin/sqlx-docker-rs"]
