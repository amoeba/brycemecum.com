---
layout: post
title: "Using ADBC with $5 Planetscale"
tags: ["arrow", "adbc", "postgresql", "database", "planetscale", "python"]
---

![](/assets/{{page.slug}}/adbc-planetscale.png)

[Planetscale](https://planetscale.com) recently [announced](https://bsky.app/profile/planetscale.com/post/3m5mjtfj3gs2r) their new $5 Postgres instance (PS-5) and I wanted to give it a test.

Since I'm working on [ADBC](https://arrow.apache.org/adbc), my first question was whether Planetscale $5 Postgres would work with the [ADBC PostgreSQL driver](https://arrow.apache.org/adbc/current/driver/postgresql.html).

Here's what I did:

After creating a new $5 instance, I clicked Connect and created a role with the following permissions:

- `pg_read_all_data` (Read data from all tables, views, and sequences.)
- `pg_write_all_data` (Write data to all tables, views, and sequences.)
- `postgres` (Create, modify, and drop databases, users, roles, tables, schemas, and all other objects.)

Note: That last role (postgres) will be key since I want to test ingesting data into my instance.

When the Connect wizard asked me how I was connecting, I selected Python. At this point, the instructions show how to use the `psycopg2-binary` and they provide this code:

```python
import psycopg2
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

conn = psycopg2.connect(
  host=os.getenv("DATABASE_HOST"),
  port=os.getenv("DATABASE_PORT"),
  user=os.getenv("DATABASE_USERNAME"),
  password=os.getenv("DATABASE_PASSWORD"),
  dbname=os.getenv("DATABASE"),
)

cur = conn.cursor()
cur.execute("SELECT version();")
print(cur.fetchone())

cur.close()
conn.close()
```

Because ADBC drivers use the same underlying protocols as the database their targetting,

1. We can swap `psycopg2-binary` out for the ADBC PostgreSQL driver and it should just work
2. We can use mostly the same code and exactly the same SQL

I installed the ADBC PostgreSQL driver using [dbc](https://docs.columnar.tech/dbc), a new command line tool we're building to make working with ADBC drivers easier. It's also available [on PyPI](https://pypi.org/project/adbc-driver-postgresql). I also did this in a venv to keep it contained (using [uv](https://astral.sh/uv)):

```console
$ uv venv
$ source .venv/bin/activate
$ dbc install postgresql
[✓] searching
[✓] downloading
[✓] installing
[✓] verifying signature

Installed postgresql 1.8.0 to /Users/bryce/planetscale-adbc/.venv/etc/adbc/drivers
```

This installed the driver into my new virtual environment as you can see above.

I then installed a few more packages for my test:

```console
$ uv pip install adbc-driver-manager pyarrow
```
In their wizard, Planetscale gave me a set of environment variables for the connection so I stored those in a `.env` file and loaded them in my shell so they were available to Python below. For this I use [direnv](https://direnv.net).

To do my test, I connected:

```python
import os
from adbc_driver_manager import dbapi

URI=f"postgresql://{os.getenv('DATABASE_USERNAME')}:{os.getenv('DATABASE_PASSWORD')}@{os.getenv('DATABASE_HOST')}:{os.getenv('DATABASE_PORT')}/{os.getenv('DATABASE')}"

con = dbapi.connect(driver="postgresql", uri=URI)
cur = con.cursor()
cur.execute("SELECT version();").fetchone()
# => ('PostgreSQL 17.5 (Debian 17.5-1.pgdg120+1) on aarch64-unknown-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit',)
```

Ingested a [Parquet](https://parquet.apache.org) file ([Palmer Penguins](https://allisonhorst.github.io/palmerpenguins/), of course):

```python
import pyarrow.parquet as pq

tbl = pq.read_table("./penguins.parquet")
cur.adbc_ingest("penguins", tbl, mode="create")
# => 344
```

And then read it back:

```python
tbl = cur.execute("select * from penguins").fetch_arrow_table()
tbl.num_rows
# => 344
tbl
```

Which prints:

```text
pyarrow.Table
species: string
island: string
bill_len: double
bill_dep: double
flipper_len: int64
body_mass: int64
sex: string
year: int64
----
species: [["Adelie","Adelie","Adelie","Adelie","Adelie",...,"Chinstrap","Chinstrap","Chinstrap","Chinstrap","Chinstrap"]]
island: [["Torgersen","Torgersen","Torgersen","Torgersen","Torgersen",...,"Dream","Dream","Dream","Dream","Dream"]]
bill_len: [[39.1,39.5,40.3,null,36.7,...,55.8,43.5,49.6,50.8,50.2]]
bill_dep: [[18.7,17.4,18,null,19.3,...,19.8,18.1,18.2,19,18.7]]
flipper_len: [[181,186,195,null,193,...,207,202,193,210,198]]
body_mass: [[3750,3800,3250,null,3450,...,4000,3400,3775,4100,3775]]
sex: [["male","female","female","NA","female",...,"male","female","male","male","female"]]
year: [[2007,2007,2007,2007,2007,...,2009,2009,2009,2009,2009]]
```

I'd say that was a successful test.

Now, connecting to a $5 PostgreSQL instance may not be the most realistic demonstration of how to use ADBC but I hope the above shows the value of interfaces. Notably, here are the things I didn't have to do:

1. Learn a new Python database API (both psycogp2 and ADBC speak [PEP 249](https://peps.python.org/pep-0249/))
2. Figure out how to get my Parquet data converted into whatever format PostgreSQL needs

And now, also because of interfaces, here's what I can now easily do:

1. Work with it directly with [PyArrow](https://arrow.apache.org/docs/python)
2. Work with this data in [DuckDB](https://duckdb.org) without copying
3. Work with this data in [Polars](https://pola.rs) without copying

And the list can go on because ADBC speaks [Arrow](https://arrow.apache.org) and increasing amounts of the data engineering stack are speaking Arrow.
