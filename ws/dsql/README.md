# Into the distributed and postgres++ sql universe

[Back to Workshop Home][home]

[![Open in Gitpod][logo-gitpod]][gp-dsql]

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

    <details>
      <summary>
        Sample Output
      </summary>

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
    </details>

2. See table schema

    ```sql
    \d+ sample;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>



3. Insert some data

    ```sql
    insert into sample
    values (1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '{"a": 1}');
    ```

     <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      yugabyte=# insert into  sample
      yugabyte-# values (1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '{"a": 1}');
      INSERT 0 1
      ```

    </details>


4. Retrieve inserted data in sample table

    ```sql
    select * from sample where k = 1;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      yugabyte=# select * from sample where k = 1;
      k | v |  t  |  f  |     d      |         ts          |          tsz           |                  u                   |    j
      ---+---+-----+-----+------------+---------------------+------------------------+--------------------------------------+----------
      1 | 1 | one | 1.1 | 2020-01-01 | 2020-01-01 01:01:01 | 2020-01-01 01:01:01+00 | a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11 | {"a": 1}
      (1 row)

      ```

    </details>



1. create an index on sample table, on column v

    ```sql
    create index idx_sample_v on sample(v);
    ```


    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      yugabyte=# create index idx_sample_v on sample(v);
      CREATE INDEX
      ```
    </details>


1. See updated schem for sample table


    ```sql
    \d+ sample;
    ```

     <details>
      <summary>
        Sample Output
      </summary>

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

    </details>



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

     <details>
      <summary>
        Sample Output
      </summary>

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

    </details>


1. See schema for table `sample_01`

    ```sql
    \d+ sample_01
    ```

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>


1. Create index with custom split

    ```sql
    create index on sample_01(v) split into 4 tablets;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      yugabyte=# create index on sample_01(v) split into 4 tablets;
      CREATE INDEX
      ```

    </details>


1. Check the schema for table `sample_01`

    ```sql
    \d+ sample_01;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>



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

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>


1. See schema for table `sample_02`

    ```sql
    \d+ sample_02;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>



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

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>


1. See schema for table `sample_03`

    ```sql
    \d+ sample_03;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>




### Xperience the power of YCQL

Run the following from `ycqlsh` shell

1. Create a keyspace

    ```sql
    create keyspace demo;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh> create keyspace demo;
      ycqlsh>
      ```

    </details>



1. Switch to newly created keyspace

    ```sql
    use demo;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

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

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>


1. See schema for table

    ```sql

    desc sample;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

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

    </details>


1. Insert data into table

    ```sql
    insert into sample(k, v, t, f, d, ts, tsz, u, j)
    values(1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11, '{"a": 1}');
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> insert into sample(k, v, t, f, d, ts, tsz, u, j)
              ... values(1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11, '{"a": 1}');
      ycqlsh:demo>
      ```

    </details>


1. Retrieve data

    ```sql
    select k, v, t, f, d, ts, tsz, u, j
    from sample;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> select k, v, t, f, d, ts, tsz, u, j
              ... from sample;

      k | v | t   | f   | d          | ts                              | tsz                             | u                                    | j
      ---+---+-----+-----+------------+---------------------------------+---------------------------------+--------------------------------------+---------
      1 | 1 | one | 1.1 | 2020-01-01 | 2019-12-31 17:01:01.000000+0000 | 2019-12-31 17:01:01.000000+0000 | a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11 | {"a":1}

      (1 rows)
      ycqlsh:demo>
      ```

    </details>



1. Try to createa an index (this will fail)

    ```sql
    create index on sample(v);
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> create index on sample(v);
      InvalidRequest: Error from server: code=2200 [Invalid query] message="Invalid Table Definition. Transactions cannot be enabled in an index of a table without transactions enabled.
      create index on sample(v);
      ^^^^^^
      (ql error -302)"
      ```

    </details>



    Above error shows that indexes require a transactional table

1. Lets create a table with transacitons

    ```sql
    create table sample_01(
        k int,
        v int,
        t text,
        f float,
        d date,
        ts timestamp,
        tsz timestamp,
        u uuid,
        j jsonb,
        primary key(k, v)
    )
    with transactions = { 'enabled' : true };
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> create table sample_01(
              ...     k int,
              ...     v int,
              ...     t text,
              ...     f float,
              ...     d date,
              ...     ts timestamp,
              ...     tsz timestamp,
              ...     u uuid,
              ...     j jsonb,
              ...     primary key(k, v)
              ... )
              ... with transactions = { 'enabled' : true };
      ycqlsh:demo>
      ```

    </details>


1. Lets create an index on this table

    ```sql
    create index on sample_01(v);
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> create index on sample_01(v);
      ycqlsh:demo>
      ```

    </details>


1. Describe that table

    ```sql
    desc sample_01;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> desc sample_01;

      CREATE TABLE demo.sample_01 (
          k int,
          v int,
          t text,
          f float,
          d date,
          ts timestamp,
          tsz timestamp,
          u uuid,
          j jsonb,
          PRIMARY KEY (k, v)
      ) WITH CLUSTERING ORDER BY (v ASC)
          AND default_time_to_live = 0
          AND transactions = {'enabled': 'true'};
      CREATE INDEX sample_01_v_idx ON demo.sample_01 (v, k)
          WITH transactions = {'enabled': 'true'};

      ycqlsh:demo>
      ```

    </details>


1. Create a table with customer tablet split

    ```sql
    create table sample_02(
        k int,
        v int,
        t text,
        f float,
        d date,
        ts timestamp,
        b boolean,
        tsz timestamp,
        u uuid,
        j jsonb,
        primary key(k, v)
    )
    with transactions = { 'enabled' : true }
    and
    tablets = 4;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> create table sample_02(
              ...     k int,
              ...     v int,
              ...     t text,
              ...     f float,
              ...     d date,
              ...     ts timestamp,
              ...     b boolean,
              ...     tsz timestamp,
              ...     u uuid,
              ...     j jsonb,
              ...     primary key(k, v)
              ... )
              ... with transactions = { 'enabled' : true }
              ... and
              ... tablets = 4;
      ycqlsh:demo>
      ```

    </details>


1. Create an index on this table

    ```sql
    create index on sample_02(v)
    with transactions = { 'enabled' : true }
    and
    tablets = 4;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> create index on sample_02(v)
              ... with transactions = { 'enabled' : true }
              ... and
              ... tablets = 4;
      ycqlsh:demo>
      ```

    </details>

1. Describe table to see the index information

    ```sql
    desc sample_02;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      ycqlsh:demo> desc sample_02;

      CREATE TABLE demo.sample_02 (
          k int,
          v int,
          t text,
          f float,
          d date,
          ts timestamp,
          b boolean,
          tsz timestamp,
          u uuid,
          j jsonb,
          PRIMARY KEY (k, v)
      ) WITH CLUSTERING ORDER BY (v ASC)
          AND default_time_to_live = 0
          AND tablets = 4
          AND transactions = {'enabled': 'true'};
      CREATE INDEX sample_02_v_idx ON demo.sample_02 (v, k)
          WITH tablets = 4
          AND transactions = {'enabled': 'true'};
      ```

    </details>

[Back to Workshop Home][home]

[home]: ../../README.md
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
[gp-dsql]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws/dsql
