use sqlx::postgres::PgPoolOptions;

const DATABASE_URL: &str = "postgres://postgres:password@localhost:5432/postgres";

#[derive(Debug)]
struct Result {
    pub foo: i64,
}

#[tokio::main]
async fn main() {
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(DATABASE_URL)
        .await
        .expect("failed to connect to database");

    let results = sqlx::query!(r#"SELECT 1::bigint as "foo!""#)
        .fetch_all(&pool)
        .await
        .map(|rows| {
            rows.iter()
                .map(|row| Result { foo: row.foo })
                .collect::<Vec<_>>()
        })
        .expect("failed to fetch results");

    println!("results: {:?}", results);
}
