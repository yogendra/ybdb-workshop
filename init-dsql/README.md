## Into the distributed and postgres++ sql universe

Run the following from `ysqlsh` shell

### Xperience the power of YSQL

```
create table sample(k int primary key, v int, t text, f float, d date, ts timestamp, tsz timestamptz, u uuid, j jsonb);

\d+ sample;

insert into sample values(1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '{"a": 1}');

create index on sample(v);

\d+ sample;

create table sample_01(k int primary key, v int, t text, f float, d date, ts timestamp, tsz timestamptz, u uuid, j jsonb) split into 4 tablets;

create index on sample_01(v) split into 4 tablets;

\d+ sample_01;

create table sample_02(k int, v int, t text, f float, d date, ts timestamp, b bool, tsz timestamptz, u uuid, j jsonb, primary key(k, v asc));

\d+ sample_02;

create table sample_03(k int, v int, t text, f float, d date, ts timestamp, b bool, tsz timestamptz, u uuid, j jsonb, primary key((k, v) HASH, t desc));

\d+ sample_03;
```

### Xperience the power of YCQL

Run the following from `ycqlsh` shell

```
create keyspace demo;

use demo;

create table sample(k int primary key, v int, t text, f float, d date, ts timestamp, tsz timestamp, u uuid, j jsonb);

desc sample;

insert into sample(k, v, t, f, d, ts, tsz, u, j) values(1, 1, 'one', 1.1, '2020-01-01', '2020-01-01 01:01:01', '2020-01-01 01:01:01', a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11, '{"a": 1}');

# will fail
create index on sample(v);

create table sample_01(k int, v int, t text, f float, d date, ts timestamp, tsz timestamp, u uuid, j jsonb, primary key(k, v)) with transactions = { 'enabled' : true };

create index on sample_01(v);

desc sample_01;

create table sample_02(k int, v int, t text, f float, d date, ts timestamp, b boolean, tsz timestamp, u uuid, j jsonb, primary key(k, v)) with transactions = { 'enabled' : true } and tablets = 4;

create index on sample_02(v) with transactions = { 'enabled' : true } and tablets = 4;

desc sample_02;
```