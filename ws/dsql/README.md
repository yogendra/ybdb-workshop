# Into the distributed and postgres++ sql universe

[Back to Workshop Home](../../README.md)

### Xperience the power of YSQL

Run the following from `ysqlsh` shell

1. Create a table
    ```sql
    create table sample(
        k int primary key,
        v int, t text,
        f float,
        d date,
        ts timestamp,
        tsz timestamptz,
        u uuid,
        j jsonb
    );
    ```

    Sample output
    ```sql
    yugabyte=# create table sample(
    yugabyte(#     k int primary key,
    yugabyte(#     v int, t text,
    yugabyte(#     f float,
    yugabyte(#     d date,
    yugabyte(#     ts timestamp,
    yugabyte(#     tsz timestamptz,
    yugabyte(#     u uuid,
    yugabyte(#     j jsonb
    yugabyte(# );
    CREATE TABLE
    ```
1. See table schema

    ```sql
    \d+ sample;
    ```

    Sample output
    ```sql
    yugabyte=# \d+ sample;
                                                Table "public.sample"
    Column |            Type             | Collation | Nullable | Default | Storage  | Stats target | Description
    --------+-----------------------------+-----------+----------+---------+----------+--------------+-------------
    k      | integer                     |           | not null |         | plain    |              |
    v      | integer                     |           |          |         | plain    |              |
    t      | text                        |           |          |         | extended |              |
    f      | double precision            |           |          |         | plain    |              |
    d      | date                        |           |          |         | plain    |              |
    ts     | timestamp without time zone |           |          |         | plain    |              |
    tsz    | timestamp with time zone    |           |          |         | plain    |              |
    u      | uuid                        |           |          |         | plain    |              |
    j      | jsonb                       |           |          |         | extended |              |
    Indexes:
        "sample_pkey" PRIMARY KEY, lsm (k HASH)
    ```

1. Insert some data

    ```sql
    insert into sample
    values (1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '{"a": 1}');
    ```

    Sample Output:

    ```sql
    yugabyte=# insert into  sample
    yugabyte-# values (1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '{"a": 1}');
    INSERT 0 1
    ```

1. Retrieve inserted data in sample table

    ```sql
    select * from sample where k = 1;
    ```

    Sample Output

    ```sql
    yugabyte=# select * from sample where k = 1;
    k | v |  t  |  f  |     d      |         ts          |          tsz           |                  u                   |    j
    ---+---+-----+-----+------------+---------------------+------------------------+--------------------------------------+----------
    1 | 1 | one | 1.1 | 2020-01-01 | 2020-01-01 01:01:01 | 2020-01-01 01:01:01+00 | a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11 | {"a": 1}
    (1 row)

    ```


1. create an index on sample table, on column v

    ```sql
    create index idx_sample_v on sample(v);
    ```

    Sample Output


    ```sql
    yugabyte=# create index idx_sample_v on sample(v);
    CREATE INDEX
    ```

1. See updated schem for sample table


    ```sql
    \d+ sample;
    ```

    Sample Output

    ```sql
    yugabyte=# \d+ sample;
                                                Table "public.sample"
    Column |            Type             | Collation | Nullable | Default | Storage  | Stats target | Description
    --------+-----------------------------+-----------+----------+---------+----------+--------------+-------------
    k      | integer                     |           | not null |         | plain    |              |
    v      | integer                     |           |          |         | plain    |              |
    t      | text                        |           |          |         | extended |              |
    f      | double precision            |           |          |         | plain    |              |
    d      | date                        |           |          |         | plain    |              |
    ts     | timestamp without time zone |           |          |         | plain    |              |
    tsz    | timestamp with time zone    |           |          |         | plain    |              |
    u      | uuid                        |           |          |         | plain    |              |
    j      | jsonb                       |           |          |         | extended |              |
    Indexes:
        "sample_pkey" PRIMARY KEY, lsm (k HASH)
        "idx_sample_v" lsm (v HASH)

    ```

1. Create new table with custom tablet split

    ```sql
    create table sample_01(
        k int primary key,
        v int,
        t text,
        f float,
        d date,
        ts timestamp,
        tsz timestamptz,
        u uuid,
        j jsonb
    ) split into 4 tablets;
    ```

    Sample Output

    ```sql
    yugabyte=# create table sample_01(
    yugabyte(#     k int primary key,
    yugabyte(#     v int,
    yugabyte(#     t text,
    yugabyte(#     f float,
    yugabyte(#     d date,
    yugabyte(#     ts timestamp,
    yugabyte(#     tsz timestamptz,
    yugabyte(#     u uuid,
    yugabyte(#     j jsonb
    yugabyte(# ) split into 4 tablets;
    CREATE TABLE
    ```

1. See schema for table `sample_01`

    ```sql
    \d+ sample_01
    ```

    Sample Output

    ```sql
    yugabyte=# \d+ sample_01
                                            Table "public.sample_01"
    Column |            Type             | Collation | Nullable | Default | Storage  | Stats target | Description
    --------+-----------------------------+-----------+----------+---------+----------+--------------+-------------
    k      | integer                     |           | not null |         | plain    |              |
    v      | integer                     |           |          |         | plain    |              |
    t      | text                        |           |          |         | extended |              |
    f      | double precision            |           |          |         | plain    |              |
    d      | date                        |           |          |         | plain    |              |
    ts     | timestamp without time zone |           |          |         | plain    |              |
    tsz    | timestamp with time zone    |           |          |         | plain    |              |
    u      | uuid                        |           |          |         | plain    |              |
    j      | jsonb                       |           |          |         | extended |              |
    Indexes:
        "sample_01_pkey" PRIMARY KEY, lsm (k HASH)
    ```
1. Create index with custom split

    ```sql
    create index on sample_01(v) split into 4 tablets;
    ```

    Sample Output

    ```sql
    yugabyte=# create index on sample_01(v) split into 4 tablets;
    CREATE INDEX
    ```

1. Check the schema for table `sample_01`

    ```sql
    \d+ sample_01;
    ```

    Sample Output

    ```sql
    yugabyte=# \d+ sample_01;
                                            Table "public.sample_01"
    Column |            Type             | Collation | Nullable | Default | Storage  | Stats target | Description
    --------+-----------------------------+-----------+----------+---------+----------+--------------+-------------
    k      | integer                     |           | not null |         | plain    |              |
    v      | integer                     |           |          |         | plain    |              |
    t      | text                        |           |          |         | extended |              |
    f      | double precision            |           |          |         | plain    |              |
    d      | date                        |           |          |         | plain    |              |
    ts     | timestamp without time zone |           |          |         | plain    |              |
    tsz    | timestamp with time zone    |           |          |         | plain    |              |
    u      | uuid                        |           |          |         | plain    |              |
    j      | jsonb                       |           |          |         | extended |              |
    Indexes:
        "sample_01_pkey" PRIMARY KEY, lsm (k HASH)
        "sample_01_v_idx" lsm (v HASH)

    ```

1. Create a table with complex primary key

    ```sql
    create table sample_02(
        k int,
        v int,
        t text,
        f float,
        d date,
        ts timestamp,
        b bool,
        tsz timestamptz,
        u uuid,
        j jsonb,
        primary key(k, v asc)
    );
    ```

    Sample Output

    ```sql
    yugabyte=# create table sample_02(
    yugabyte(#     k int,
    yugabyte(#     v int,
    yugabyte(#     t text,
    yugabyte(#     f float,
    yugabyte(#     d date,
    yugabyte(#     ts timestamp,
    yugabyte(#     b bool,
    yugabyte(#     tsz timestamptz,
    yugabyte(#     u uuid,
    yugabyte(#     j jsonb,
    yugabyte(#     primary key(k, v asc)
    yugabyte(# );
    CREATE TABLE
    ```

1. See schema for table `sample_02`

    ```sql
    \d+ sample_02;
    ```

    Sample Output

    ```sql
    yugabyte=# \d+ sample_02;
                                            Table "public.sample_02"
    Column |            Type             | Collation | Nullable | Default | Storage  | Stats target | Description
    --------+-----------------------------+-----------+----------+---------+----------+--------------+-------------
    k      | integer                     |           | not null |         | plain    |              |
    v      | integer                     |           | not null |         | plain    |              |
    t      | text                        |           |          |         | extended |              |
    f      | double precision            |           |          |         | plain    |              |
    d      | date                        |           |          |         | plain    |              |
    ts     | timestamp without time zone |           |          |         | plain    |              |
    b      | boolean                     |           |          |         | plain    |              |
    tsz    | timestamp with time zone    |           |          |         | plain    |              |
    u      | uuid                        |           |          |         | plain    |              |
    j      | jsonb                       |           |          |         | extended |              |
    Indexes:
        "sample_02_pkey" PRIMARY KEY, lsm (k HASH, v ASC)

    ```

1. Create a table with primary key and clustering/sharding key

    ```sql
    create table sample_03(
        k int,
        v int,
        t text,
        f float,
        d date,
        ts timestamp,
        b bool,
        tsz timestamptz,
        u uuid,
        j jsonb,
        primary key((k, v) HASH, t desc)
    );
    ```

    Sample Output

    ```sql
    yugabyte=# create table sample_03(
    yugabyte(#     k int,
    yugabyte(#     v int,
    yugabyte(#     t text,
    yugabyte(#     f float,
    yugabyte(#     d date,
    yugabyte(#     ts timestamp,
    yugabyte(#     b bool,
    yugabyte(#     tsz timestamptz,
    yugabyte(#     u uuid,
    yugabyte(#     j jsonb,
    yugabyte(#     primary key((k, v) HASH, t desc)
    yugabyte(# );
    CREATE TABLE
    ```
1. See schema for table `sample_03`

    ```sql
    \d+ sample_03;
    ```

    Sample Output

    ```sql
    yugabyte=# \d+ sample_03;
                                            Table "public.sample_03"
    Column |            Type             | Collation | Nullable | Default | Storage  | Stats target | Description
    --------+-----------------------------+-----------+----------+---------+----------+--------------+-------------
    k      | integer                     |           | not null |         | plain    |              |
    v      | integer                     |           | not null |         | plain    |              |
    t      | text                        |           | not null |         | extended |              |
    f      | double precision            |           |          |         | plain    |              |
    d      | date                        |           |          |         | plain    |              |
    ts     | timestamp without time zone |           |          |         | plain    |              |
    b      | boolean                     |           |          |         | plain    |              |
    tsz    | timestamp with time zone    |           |          |         | plain    |              |
    u      | uuid                        |           |          |         | plain    |              |
    j      | jsonb                       |           |          |         | extended |              |
    Indexes:
        "sample_03_pkey" PRIMARY KEY, lsm ((k, v) HASH, t DESC)

    ```

### Xperience the power of YCQL

Run the following from `ycqlsh` shell

1. Create a keyspace

    ```sql
    create keyspace demo;
    ```

    Sample Output

    ```sql
    ycqlsh> create keyspace demo;
    ycqlsh>
    ```

1. Switch to newly created keyspace

    ```sql
    use demo;
    ```

    Sample Output

    ```sql
    ycqlsh> use demo;
    ycqlsh:demo>
    ```

1. Create a table

    ```sql
    create table sample(
        k int primary key,
        v int,
        t text,
        f float,
        d date,
        ts timestamp,
        tsz timestamp,
        u uuid,
        j jsonb
    );
    ```

    Sample Output

    ```sql
    ycqlsh:demo> create table sample(
            ...     k int primary key,
            ...     v int,
            ...     t text,
            ...     f float,
            ...     d date,
            ...     ts timestamp,
            ...     tsz timestamp,
            ...     u uuid,
            ...     j jsonb
            ... );
    ycqlsh:demo>
    ```

1. See schema for table

    ```sql

    desc sample;
    ```

    Sample Output

    ```sql
    ycqlsh:demo> desc sample;

    CREATE TABLE demo.sample (
        k int PRIMARY KEY,
        v int,
        t text,
        f float,
        d date,
        ts timestamp,
        tsz timestamp,
        u uuid,
        j jsonb
    ) WITH default_time_to_live = 0
        AND transactions = {'enabled': 'false'};

    ycqlsh:demo>
    ```

1. Insert data into table

    ```sql
    insert into sample(k, v, t, f, d, ts, tsz, u, j)
    values(1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11, '{"a": 1}');
    ```
    Sample Output

    ```sql
    ycqlsh:demo> insert into sample(k, v, t, f, d, ts, tsz, u, j)
            ... values(1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11, '{"a": 1}');
    ycqlsh:demo>
    ```

1. Retrieve data

    ```sql
    select k, v, t, f, d, ts, tsz, u, j
    from sample;
    ```

    Sample Output

    ```sql
    ycqlsh:demo> select k, v, t, f, d, ts, tsz, u, j
            ... from sample;

    k | v | t   | f   | d          | ts                              | tsz                             | u                                    | j
    ---+---+-----+-----+------------+---------------------------------+---------------------------------+--------------------------------------+---------
    1 | 1 | one | 1.1 | 2020-01-01 | 2019-12-31 17:01:01.000000+0000 | 2019-12-31 17:01:01.000000+0000 | a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11 | {"a":1}

    (1 rows)
    ycqlsh:demo>
    ```


# will fail
create index on sample(v);

create table sample_01(k int, v int, t text, f float, d date, ts timestamp, tsz timestamp, u uuid, j jsonb, primary key(k, v)) with transactions = { 'enabled' : true };

create index on sample_01(v);

desc sample_01;

create table sample_02(k int, v int, t text, f float, d date, ts timestamp, b boolean, tsz timestamp, u uuid, j jsonb, primary key(k, v)) with transactions = { 'enabled' : true } and tablets = 4;

create index on sample_02(v) with transactions = { 'enabled' : true } and tablets = 4;

desc sample_02;
```
[Back to Workshop Home](../../README.md)
