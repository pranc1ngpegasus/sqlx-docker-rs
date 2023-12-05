FROM clux/muslrust:stable AS chef
RUN cargo install cargo-chef
RUN cargo install sqlx-cli
WORKDIR /usr/src/app

FROM chef as planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
ENV SQLX_OFFLINE true
ENV DATABASE_URL postgres://postgres:postgres@localhost:5432/postgres
COPY --from=planner /usr/src/app/recipe.json recipe.json
RUN cargo chef cook --release --target x86_64-unknown-linux-musl --recipe-path recipe.json
COPY . .
RUN cargo sqlx prepare --workspace
RUN cargo build --release --target x86_64-unknown-linux-musl && mv target/x86_64-unknown-linux-musl/release/sqlx-docker-rs /tmp/sqlx-docker-rs

FROM gcr.io/distroless/cc as runner

COPY --from=builder /tmp/sqlx-docker-rs /usr/local/bin/sqlx-docker-rs

ENTRYPOINT ["/usr/local/bin/sqlx-docker-rs"]
