## Query tuning tips and tricks

[Back to Workshop Home][home]

[![Open in Gitpod][logo-gitpod]][gp-qt]

### explain plan

```
\set ea 'explain(analyze, dist, verbose, costs, buffers, timing, summary)'
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# \set ea 'explain(analyze, dist, verbose, costs, buffers, timing, summary)'
  yugabyte=#
  ```

</details>

### count(aggregate) pushdown

``` sql
:ea select count(1) from track;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# :ea select count(1) from track;
                                                    QUERY PLAN
  -----------------------------------------------------------------------------------------------------------------
  Finalize Aggregate  (cost=102.50..102.51 rows=1 width=8) (actual time=1.413..1.413 rows=1 loops=1)
    Output: count(1)
    ->  Seq Scan on public.track  (cost=0.00..100.00 rows=1000 width=0) (actual time=1.405..1.406 rows=3 loops=1)
          Storage Table Read Requests: 1
          Storage Table Read Execution Time: 1.094 ms
          Partial Aggregate: true
  Planning Time: 27.760 ms
  Execution Time: 2.140 ms
  Storage Read Requests: 1
  Storage Read Execution Time: 1.094 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 44
  Catalog Read Execution Time: 25.815 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 26.909 ms
  Peak Memory Usage: 64 kB
  (17 rows)

  yugabyte=#
  ```

</details>

### distinct pushdown

```sql
:ea select distinct albumid from track where albumid>0;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# :ea select distinct albumid from track where albumid>0;
                                                                      QUERY PLAN
  --------------------------------------------------------------------------------------------------------------------------------------------------
  Distinct Index Only Scan using ifk_trackalbumid on public.track  (cost=0.00..23.80 rows=200 width=4) (actual time=1.068..1.123 rows=347 loops=1)
    Output: albumid
    Distinct Prefix: 1
    Remote Filter: (track.albumid > 0)
    Heap Fetches: 0
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.997 ms
  Planning Time: 3.641 ms
  Execution Time: 1.247 ms
  Storage Read Requests: 1
  Storage Read Execution Time: 0.997 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 32
  Catalog Read Execution Time: 19.664 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 20.661 ms
  Peak Memory Usage: 24 kB
  (18 rows)

  yugabyte=#
  ```

</details>

### expression pushdown

```sql
:ea select * from track where upper(name) like 'THE TROOPER';
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# :ea select * from track where upper(name) like 'THE TROOPER';
                                                  QUERY PLAN
  -------------------------------------------------------------------------------------------------------------
  Seq Scan on public.track  (cost=0.00..105.00 rows=1000 width=916) (actual time=1.728..1.733 rows=5 loops=1)
    Output: trackid, name, albumid, mediatypeid, genreid, composer, milliseconds, bytes, unitprice
    Remote Filter: (upper((track.name)::text) ~~ 'THE TROOPER'::text)
    Storage Table Read Requests: 1
    Storage Table Read Execution Time: 1.548 ms
  Planning Time: 0.691 ms
  Execution Time: 1.775 ms
  Storage Read Requests: 1
  Storage Read Execution Time: 1.548 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 12
  Catalog Read Execution Time: 7.864 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 9.412 ms
  Peak Memory Usage: 24 kB
  (16 rows)

  yugabyte=#
  ```

</details>

### hash index

```sql
:ea select * from track where albumid = 0;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# :ea select * from track where albumid = 0;
                                                              QUERY PLAN
  ----------------------------------------------------------------------------------------------------------------------------------
  Index Scan using ifk_trackalbumid on public.track  (cost=0.00..5.22 rows=10 width=916) (actual time=0.717..0.717 rows=0 loops=1)
    Output: trackid, name, albumid, mediatypeid, genreid, composer, milliseconds, bytes, unitprice
    Index Cond: (track.albumid = 0)
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.604 ms
  Planning Time: 0.127 ms
  Execution Time: 0.760 ms
  Storage Read Requests: 1
  Storage Read Execution Time: 0.604 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 3
  Catalog Read Execution Time: 2.252 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 2.856 ms
  Peak Memory Usage: 24 kB
  (16 rows)

  yugabyte=#
  ```

</details>

### range index

```
:ea select * from track where albumid > 0;

create index track_albumid on track(albumid asc);

:ea select * from track where albumid > 0;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# :ea select * from track where albumid > 0;
                                                    QUERY PLAN
  ----------------------------------------------------------------------------------------------------------------
  Seq Scan on public.track  (cost=0.00..102.50 rows=1000 width=916) (actual time=2.141..4.169 rows=3503 loops=1)
    Output: trackid, name, albumid, mediatypeid, genreid, composer, milliseconds, bytes, unitprice
    Remote Filter: (track.albumid > 0)
    Storage Table Read Requests: 2
    Storage Table Read Execution Time: 1.929 ms
  Planning Time: 0.055 ms
  Execution Time: 5.152 ms
  Storage Read Requests: 2
  Storage Read Execution Time: 1.929 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 0
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 1.929 ms
  Peak Memory Usage: 24 kB
  (15 rows)

  yugabyte=#
  yugabyte=# create index track_albumid on track(albumid asc);
  CREATE INDEX
  yugabyte=#
  yugabyte=# :ea select * from track where albumid > 0;
                                                              QUERY PLAN
  -----------------------------------------------------------------------------------------------------------------------------------
  Index Scan using track_albumid on public.track  (cost=0.00..5.22 rows=10 width=916) (actual time=4.652..13.272 rows=3503 loops=1)
    Output: trackid, name, albumid, mediatypeid, genreid, composer, milliseconds, bytes, unitprice
    Index Cond: (track.albumid > 0)
    Storage Table Read Requests: 4
    Storage Table Read Execution Time: 7.552 ms
    Storage Index Read Requests: 4
    Storage Index Read Execution Time: 1.161 ms
  Planning Time: 4.711 ms
  Execution Time: 14.273 ms
  Storage Read Requests: 8
  Storage Read Execution Time: 8.713 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 7
  Catalog Read Execution Time: 7.942 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 16.655 ms
  Peak Memory Usage: 32 kB
  (18 rows)

  yugabyte=#
  ```

</details>

### covering index

```sql
:ea select * from track where albumid=1;

:ea select trackid, composer from track where albumid=1;

create index track_albumid_1 on track(albumid) include(trackid, composer);

:ea select trackid, composer from track where albumid=1;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# :ea select * from track where albumid=1;
                                                            QUERY PLAN
  --------------------------------------------------------------------------------------------------------------------------------
  Index Scan using track_albumid on public.track  (cost=0.00..5.22 rows=10 width=916) (actual time=1.829..1.840 rows=10 loops=1)
    Output: trackid, name, albumid, mediatypeid, genreid, composer, milliseconds, bytes, unitprice
    Index Cond: (track.albumid = 1)
    Storage Table Read Requests: 1
    Storage Table Read Execution Time: 0.788 ms
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.812 ms
  Planning Time: 0.105 ms
  Execution Time: 1.905 ms
  Storage Read Requests: 2
  Storage Read Execution Time: 1.600 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 0
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 1.600 ms
  Peak Memory Usage: 24 kB
  (17 rows)

  yugabyte=#
  yugabyte=# :ea select trackid, composer from track where albumid=1;
                                                            QUERY PLAN
  --------------------------------------------------------------------------------------------------------------------------------
  Index Scan using track_albumid on public.track  (cost=0.00..5.22 rows=10 width=462) (actual time=1.467..1.473 rows=10 loops=1)
    Output: trackid, composer
    Index Cond: (track.albumid = 1)
    Storage Table Read Requests: 1
    Storage Table Read Execution Time: 0.794 ms
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.575 ms
  Planning Time: 0.113 ms
  Execution Time: 1.509 ms
  Storage Read Requests: 2
  Storage Read Execution Time: 1.369 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 2
  Catalog Read Execution Time: 1.520 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 2.889 ms
  Peak Memory Usage: 24 kB
  (18 rows)

  yugabyte=#
  yugabyte=# create index track_albumid_1 on track(albumid) include(trackid, composer);
  CREATE INDEX
  yugabyte=# :ea select trackid, composer from track where albumid=1;
                                                                QUERY PLAN
  ---------------------------------------------------------------------------------------------------------------------------------------
  Index Only Scan using track_albumid_1 on public.track  (cost=0.00..5.12 rows=10 width=462) (actual time=1.687..1.694 rows=10 loops=1)
    Output: trackid, composer
    Index Cond: (track.albumid = 1)
    Heap Fetches: 0
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.647 ms
  Planning Time: 4.774 ms
  Execution Time: 1.763 ms
  Storage Read Requests: 1
  Storage Read Execution Time: 0.647 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 7
  Catalog Read Execution Time: 7.990 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 8.637 ms
  Peak Memory Usage: 24 kB
  (17 rows)

  yugabyte=#
  ```

</details>

### partial index

```
create index employee_city on employee(city) where city not in ('Lethbridge', 'Edmonton');

:ea select * from employee where city='Lethbridge';

:ea select * from employee where city='Calgary';
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# create index employee_city on employee(city) where city not in ('Lethbridge', 'Edmonton');
  CREATE INDEX
  yugabyte=#
  yugabyte=# :ea select * from employee where city='Lethbridge';
                                                                    QUERY PLAN
  ------------------------------------------------------------------------------------------------------------------------------------------------
  Seq Scan on public.employee  (cost=0.00..102.50 rows=1000 width=978) (actual time=1.850..1.852 rows=2 loops=1)
    Output: employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email
    Remote Filter: ((employee.city)::text = 'Lethbridge'::text)
    Storage Table Read Requests: 1
    Storage Table Read Execution Time: 0.727 ms
  Planning Time: 10.218 ms
  Execution Time: 1.901 ms
  Storage Read Requests: 1
  Storage Read Execution Time: 0.727 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 33
  Catalog Read Execution Time: 23.290 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 24.017 ms
  Peak Memory Usage: 24 kB
  (16 rows)

  yugabyte=#
  yugabyte=# :ea select * from employee where city='Calgary';
                                                                    QUERY PLAN
  ------------------------------------------------------------------------------------------------------------------------------------------------
  Index Scan using employee_city on public.employee  (cost=0.00..4.98 rows=10 width=978) (actual time=2.409..2.419 rows=5 loops=1)
    Output: employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email
    Index Cond: ((employee.city)::text = 'Calgary'::text)
    Storage Table Read Requests: 1
    Storage Table Read Execution Time: 1.648 ms
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.528 ms
  Planning Time: 1.433 ms
  Execution Time: 2.504 ms
  Storage Read Requests: 2
  Storage Read Execution Time: 2.176 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 0
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 2.176 ms
  Peak Memory Usage: 24 kB
  (17 rows)

  yugabyte=#
  ```

</details>

### index forward and backward scan

```sql
create index customer_repid on customer(supportrepid asc);

:ea select * from customer order by supportrepid;

:ea select * from customer order by supportrepid desc;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# create index customer_repid on customer(supportrepid asc);

  CREATE INDEX
  yugabyte=#
  yugabyte=# :ea select * from customer order by supportrepid;
                                                                QUERY PLAN
  -----------------------------------------------------------------------------------------------------------------------------------------
  Index Scan using customer_repid on public.customer  (cost=0.00..124.00 rows=1000 width=1102) (actual time=2.427..2.472 rows=59 loops=1)
    Output: customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid
    Storage Table Read Requests: 1
    Storage Table Read Execution Time: 0.713 ms
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.584 ms
  Planning Time: 7.908 ms
  Execution Time: 2.567 ms
  Storage Read Requests: 2
  Storage Read Execution Time: 1.297 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 13
  Catalog Read Execution Time: 8.814 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 10.111 ms
  Peak Memory Usage: 24 kB
  (17 rows)

  yugabyte=#
  yugabyte=# :ea select * from customer order by supportrepid desc;
                                                                      QUERY PLAN
  --------------------------------------------------------------------------------------------------------------------------------------------------
  Index Scan Backward using customer_repid on public.customer  (cost=0.00..135.00 rows=1000 width=1102) (actual time=1.835..1.874 rows=59 loops=1)
    Output: customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid
    Storage Table Read Requests: 1
    Storage Table Read Execution Time: 0.815 ms
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.918 ms
  Planning Time: 1.856 ms
  Execution Time: 1.925 ms
  Storage Read Requests: 2
  Storage Read Execution Time: 1.733 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 1
  Catalog Read Execution Time: 1.679 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 3.412 ms
  Peak Memory Usage: 24 kB
  (17 rows)

  yugabyte=#
  ```

</details>

### hints

```sql
:ea
/*+Leading ( ( ( a t ) ar ) ) */
SELECT t.TrackId,
  t.Name AS track_name,
  a.Title AS album_title,
  ar.Name AS artist_name
FROM Track t
  INNER JOIN Album a ON t.AlbumId = a.AlbumId
  INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE t.TrackId = 5;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# :ea
  yugabyte-# /*+Leading ( ( ( a t ) ar ) ) */
  yugabyte-# SELECT t.TrackId,
  yugabyte-#   t.Name AS track_name,
  yugabyte-#   a.Title AS album_title,
  yugabyte-#   ar.Name AS artist_name
  yugabyte-# FROM Track t
  yugabyte-#   INNER JOIN Album a ON t.AlbumId = a.AlbumId
  yugabyte-#   INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
  yugabyte-# WHERE t.TrackId = 5;
                                                                  QUERY PLAN
  ---------------------------------------------------------------------------------------------------------------------------------------------
  Nested Loop  (cost=4.12..112.43 rows=1 width=1018) (actual time=3.314..3.319 rows=1 loops=1)
    Output: t.trackid, t.name, a.title, ar.name
    Inner Unique: true
    ->  Hash Join  (cost=4.12..112.31 rows=1 width=764) (actual time=2.668..2.673 rows=1 loops=1)
          Output: t.trackid, t.name, a.title, a.artistid
          Inner Unique: true
          Hash Cond: (a.albumid = t.albumid)
          ->  Seq Scan on public.album a  (cost=0.00..100.00 rows=1000 width=346) (actual time=0.546..1.137 rows=347 loops=1)
                Output: a.title, a.albumid, a.artistid
                Storage Table Read Requests: 3
                Storage Table Read Execution Time: 0.963 ms
          ->  Hash  (cost=4.11..4.11 rows=1 width=426) (actual time=1.378..1.379 rows=1 loops=1)
                Output: t.trackid, t.name, t.albumid
                Buckets: 1024  Batches: 1  Memory Usage: 9kB
                ->  Index Scan using pk_track on public.track t  (cost=0.00..4.11 rows=1 width=426) (actual time=1.358..1.360 rows=1 loops=1)
                      Output: t.trackid, t.name, t.albumid
                      Index Cond: (t.trackid = 5)
                      Storage Table Read Requests: 1
                      Storage Table Read Execution Time: 1.264 ms
    ->  Index Scan using pk_artist on public.artist ar  (cost=0.00..0.11 rows=1 width=262) (actual time=0.642..0.642 rows=1 loops=1)
          Output: ar.name, ar.artistid
          Index Cond: (ar.artistid = a.artistid)
          Storage Table Read Requests: 1
          Storage Table Read Execution Time: 0.580 ms
  Planning Time: 23.394 ms
  Execution Time: 3.464 ms
  Storage Read Requests: 5
  Storage Read Execution Time: 2.806 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 42
  Catalog Read Execution Time: 29.343 ms
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 32.149 ms
  Peak Memory Usage: 257 kB
  (35 rows)

  yugabyte=#
  ```

</details>

```sql
:ea
/*+Leading ( ( ar ( a t ) ) ) */
SELECT t.TrackId,
  t.Name AS track_name,
  a.Title AS album_title,
  ar.Name AS artist_name
FROM Track t
  INNER JOIN Album a ON t.AlbumId = a.AlbumId
  INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE t.TrackId = 5;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# :ea
  yugabyte-# /*+Leading ( ( ar ( a t ) ) ) */
  yugabyte-# SELECT t.TrackId,
  yugabyte-#   t.Name AS track_name,
  yugabyte-#   a.Title AS album_title,
  yugabyte-#   ar.Name AS artist_name
  yugabyte-# FROM Track t
  yugabyte-#   INNER JOIN Album a ON t.AlbumId = a.AlbumId
  yugabyte-#   INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
  yugabyte-# WHERE t.TrackId = 5;
                                                                      QUERY PLAN
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  Hash Join  (cost=112.33..216.09 rows=1 width=1018) (actual time=3.167..3.211 rows=1 loops=1)
    Output: t.trackid, t.name, a.title, ar.name
    Hash Cond: (ar.artistid = a.artistid)
    ->  Seq Scan on public.artist ar  (cost=0.00..100.00 rows=1000 width=262) (actual time=0.774..1.358 rows=275 loops=1)
          Output: ar.name, ar.artistid
          Storage Table Read Requests: 3
          Storage Table Read Execution Time: 1.169 ms
    ->  Hash  (cost=112.31..112.31 rows=1 width=764) (actual time=1.735..1.735 rows=1 loops=1)
          Output: t.trackid, t.name, a.title, a.artistid
          Buckets: 1024  Batches: 1  Memory Usage: 9kB
          ->  Hash Join  (cost=4.12..112.31 rows=1 width=764) (actual time=1.713..1.717 rows=1 loops=1)
                Output: t.trackid, t.name, a.title, a.artistid
                Inner Unique: true
                Hash Cond: (a.albumid = t.albumid)
                ->  Seq Scan on public.album a  (cost=0.00..100.00 rows=1000 width=346) (actual time=0.435..1.033 rows=347 loops=1)
                      Output: a.title, a.albumid, a.artistid
                      Storage Table Read Requests: 3
                      Storage Table Read Execution Time: 0.876 ms
                ->  Hash  (cost=4.11..4.11 rows=1 width=426) (actual time=0.571..0.571 rows=1 loops=1)
                      Output: t.trackid, t.name, t.albumid
                      Buckets: 1024  Batches: 1  Memory Usage: 9kB
                      ->  Index Scan using pk_track on public.track t  (cost=0.00..4.11 rows=1 width=426) (actual time=0.552..0.554 rows=1 loops=1)
                            Output: t.trackid, t.name, t.albumid
                            Index Cond: (t.trackid = 5)
                            Storage Table Read Requests: 1
                            Storage Table Read Execution Time: 0.498 ms
  Planning Time: 0.331 ms
  Execution Time: 3.325 ms
  Storage Read Requests: 7
  Storage Read Execution Time: 2.543 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 0
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 2.543 ms
  Peak Memory Usage: 278 kB
  (36 rows)

  yugabyte=#
  ```

</details>

### batch nested loop

```sql
set yb_bnl_batch_size=512;

:ea
SELECT p.PlaylistId,
  p.Name AS playlist_name,
  t.Name AS track_name,
  ar.Name AS artist_name
FROM Playlist p
  INNER JOIN PlaylistTrack pt ON p.PlaylistId = pt.PlaylistId
  INNER JOIN Track t ON pt.TrackId = t.TrackId
  INNER JOIN Album a ON t.AlbumId = a.AlbumId
  INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE p.PlaylistId = 3;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# set yb_bnl_batch_size=512;
  SET
  yugabyte=#
  yugabyte=# :ea
  yugabyte-# SELECT p.PlaylistId,
  yugabyte-#   p.Name AS playlist_name,
  yugabyte-#   t.Name AS track_name,
  yugabyte-#   ar.Name AS artist_name
  yugabyte-# FROM Playlist p
  yugabyte-#   INNER JOIN PlaylistTrack pt ON p.PlaylistId = pt.PlaylistId
  yugabyte-#   INNER JOIN Track t ON pt.TrackId = t.TrackId
  yugabyte-#   INNER JOIN Album a ON t.AlbumId = a.AlbumId
  yugabyte-#   INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
  yugabyte-# WHERE p.PlaylistId = 3;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        QUERY PLAN
  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  YB Batched Nested Loop Join  (cost=0.00..25.98 rows=100 width=938) (actual time=5.537..5.596 rows=213 loops=1)
    Output: p.playlistid, p.name, t.name, ar.name
    Inner Unique: true
    Join Filter: (a.artistid = ar.artistid)
    ->  YB Batched Nested Loop Join  (cost=0.00..24.54 rows=100 width=684) (actual time=4.592..4.660 rows=213 loops=1)
          Output: p.playlistid, p.name, t.name, a.artistid
          Inner Unique: true
          Join Filter: (t.albumid = a.albumid)
          ->  YB Batched Nested Loop Join  (cost=0.00..23.10 rows=100 width=684) (actual time=3.248..3.596 rows=213 loops=1)
                Output: p.playlistid, p.name, t.name, t.albumid
                Inner Unique: true
                Join Filter: (pt.trackid = t.trackid)
                ->  Nested Loop  (cost=0.00..20.36 rows=100 width=266) (actual time=1.601..1.736 rows=213 loops=1)
                      Output: p.playlistid, p.name, pt.trackid
                      ->  Index Scan using pk_playlist on public.playlist p  (cost=0.00..4.11 rows=1 width=262) (actual time=0.910..0.911 rows=1 loops=1)
                            Output: p.playlistid, p.name
                            Index Cond: (p.playlistid = 3)
                            Storage Table Read Requests: 1
                            Storage Table Read Execution Time: 0.804 ms
                      ->  Index Scan using pk_playlisttrack on public.playlisttrack pt  (cost=0.00..15.25 rows=100 width=8) (actual time=0.687..0.746 rows=213 loops=1)
                            Output: pt.playlistid, pt.trackid
                            Index Cond: (pt.playlistid = 3)
                            Storage Table Read Requests: 1
                            Storage Table Read Execution Time: 0.638 ms
                ->  Index Scan using pk_track on public.track t  (cost=0.00..4.11 rows=1 width=426) (actual time=1.326..1.453 rows=213 loops=1)
                      Output: t.name, t.trackid, t.albumid
                      Index Cond: (t.trackid = ANY (ARRAY[pt.trackid, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $100, $101, $102, $103, $104, $105, $106, $107, $108, $109, $110, $111, $112, $113, $114, $115, $116, $117, $118, $119, $120, $121, $122, $123, $124, $125, $126, $127, $128, $129, $130, $131, $132, $133, $134, $135, $136, $137, $138, $139, $140, $141, $142, $143, $144, $145, $146, $147, $148, $149, $150, $151, $152, $153, $154, $155, $156, $157, $158, $159, $160, $161, $162, $163, $164, $165, $166, $167, $168, $169, $170, $171, $172, $173, $174, $175, $176, $177, $178, $179, $180, $181, $182, $183, $184, $185, $186, $187, $188, $189, $190, $191, $192, $193, $194, $195, $196, $197, $198, $199, $200, $201, $202, $203, $204, $205, $206, $207, $208, $209, $210, $211, $212, $213, $214, $215, $216, $217, $218, $219, $220, $221, $222, $223, $224, $225, $226, $227, $228, $229, $230, $231, $232, $233, $234, $235, $236, $237, $238, $239, $240, $241, $242, $243, $244, $245, $246, $247, $248, $249, $250, $251, $252, $253, $254, $255, $256, $257, $258, $259, $260, $261, $262, $263, $264, $265, $266, $267, $268, $269, $270, $271, $272, $273, $274, $275, $276, $277, $278, $279, $280, $281, $282, $283, $284, $285, $286, $287, $288, $289, $290, $291, $292, $293, $294, $295, $296, $297, $298, $299, $300, $301, $302, $303, $304, $305, $306, $307, $308, $309, $310, $311, $312, $313, $314, $315, $316, $317, $318, $319, $320, $321, $322, $323, $324, $325, $326, $327, $328, $329, $330, $331, $332, $333, $334, $335, $336, $337, $338, $339, $340, $341, $342, $343, $344, $345, $346, $347, $348, $349, $350, $351, $352, $353, $354, $355, $356, $357, $358, $359, $360, $361, $362, $363, $364, $365, $366, $367, $368, $369, $370, $371, $372, $373, $374, $375, $376, $377, $378, $379, $380, $381, $382, $383, $384, $385, $386, $387, $388, $389, $390, $391, $392, $393, $394, $395, $396, $397, $398, $399, $400, $401, $402, $403, $404, $405, $406, $407, $408, $409, $410, $411, $412, $413, $414, $415, $416, $417, $418, $419, $420, $421, $422, $423, $424, $425, $426, $427, $428, $429, $430, $431, $432, $433, $434, $435, $436, $437, $438, $439, $440, $441, $442, $443, $444, $445, $446, $447, $448, $449, $450, $451, $452, $453, $454, $455, $456, $457, $458, $459, $460, $461, $462, $463, $464, $465, $466, $467, $468, $469, $470, $471, $472, $473, $474, $475, $476, $477, $478, $479, $480, $481, $482, $483, $484, $485, $486, $487, $488, $489, $490, $491, $492, $493, $494, $495, $496, $497, $498, $499, $500, $501, $502, $503, $504, $505, $506, $507, $508, $509, $510, $511]))
                      Storage Table Read Requests: 1
                      Storage Table Read Execution Time: 1.121 ms
          ->  Index Scan using pk_album on public.album a  (cost=0.00..2.16 rows=1 width=8) (actual time=0.750..0.756 rows=12 loops=1)
                Output: a.albumid, a.artistid
                Index Cond: (a.albumid = ANY (ARRAY[t.albumid, $513, $514, $515, $516, $517, $518, $519, $520, $521, $522, $523, $524, $525, $526, $527, $528, $529, $530, $531, $532, $533, $534, $535, $536, $537, $538, $539, $540, $541, $542, $543, $544, $545, $546, $547, $548, $549, $550, $551, $552, $553, $554, $555, $556, $557, $558, $559, $560, $561, $562, $563, $564, $565, $566, $567, $568, $569, $570, $571, $572, $573, $574, $575, $576, $577, $578, $579, $580, $581, $582, $583, $584, $585, $586, $587, $588, $589, $590, $591, $592, $593, $594, $595, $596, $597, $598, $599, $600, $601, $602, $603, $604, $605, $606, $607, $608, $609, $610, $611, $612, $613, $614, $615, $616, $617, $618, $619, $620, $621, $622, $623, $624, $625, $626, $627, $628, $629, $630, $631, $632, $633, $634, $635, $636, $637, $638, $639, $640, $641, $642, $643, $644, $645, $646, $647, $648, $649, $650, $651, $652, $653, $654, $655, $656, $657, $658, $659, $660, $661, $662, $663, $664, $665, $666, $667, $668, $669, $670, $671, $672, $673, $674, $675, $676, $677, $678, $679, $680, $681, $682, $683, $684, $685, $686, $687, $688, $689, $690, $691, $692, $693, $694, $695, $696, $697, $698, $699, $700, $701, $702, $703, $704, $705, $706, $707, $708, $709, $710, $711, $712, $713, $714, $715, $716, $717, $718, $719, $720, $721, $722, $723, $724, $725, $726, $727, $728, $729, $730, $731, $732, $733, $734, $735, $736, $737, $738, $739, $740, $741, $742, $743, $744, $745, $746, $747, $748, $749, $750, $751, $752, $753, $754, $755, $756, $757, $758, $759, $760, $761, $762, $763, $764, $765, $766, $767, $768, $769, $770, $771, $772, $773, $774, $775, $776, $777, $778, $779, $780, $781, $782, $783, $784, $785, $786, $787, $788, $789, $790, $791, $792, $793, $794, $795, $796, $797, $798, $799, $800, $801, $802, $803, $804, $805, $806, $807, $808, $809, $810, $811, $812, $813, $814, $815, $816, $817, $818, $819, $820, $821, $822, $823, $824, $825, $826, $827, $828, $829, $830, $831, $832, $833, $834, $835, $836, $837, $838, $839, $840, $841, $842, $843, $844, $845, $846, $847, $848, $849, $850, $851, $852, $853, $854, $855, $856, $857, $858, $859, $860, $861, $862, $863, $864, $865, $866, $867, $868, $869, $870, $871, $872, $873, $874, $875, $876, $877, $878, $879, $880, $881, $882, $883, $884, $885, $886, $887, $888, $889, $890, $891, $892, $893, $894, $895, $896, $897, $898, $899, $900, $901, $902, $903, $904, $905, $906, $907, $908, $909, $910, $911, $912, $913, $914, $915, $916, $917, $918, $919, $920, $921, $922, $923, $924, $925, $926, $927, $928, $929, $930, $931, $932, $933, $934, $935, $936, $937, $938, $939, $940, $941, $942, $943, $944, $945, $946, $947, $948, $949, $950, $951, $952, $953, $954, $955, $956, $957, $958, $959, $960, $961, $962, $963, $964, $965, $966, $967, $968, $969, $970, $971, $972, $973, $974, $975, $976, $977, $978, $979, $980, $981, $982, $983, $984, $985, $986, $987, $988, $989, $990, $991, $992, $993, $994, $995, $996, $997, $998, $999, $1000, $1001, $1002, $1003, $1004, $1005, $1006, $1007, $1008, $1009, $1010, $1011, $1012, $1013, $1014, $1015, $1016, $1017, $1018, $1019, $1020, $1021, $1022, $1023]))
                Storage Table Read Requests: 1
                Storage Table Read Execution Time: 0.658 ms
    ->  Index Scan using pk_artist on public.artist ar  (cost=0.00..2.16 rows=1 width=262) (actual time=0.728..0.732 rows=6 loops=1)
          Output: ar.name, ar.artistid
          Index Cond: (ar.artistid = ANY (ARRAY[a.artistid, $1025, $1026, $1027, $1028, $1029, $1030, $1031, $1032, $1033, $1034, $1035, $1036, $1037, $1038, $1039, $1040, $1041, $1042, $1043, $1044, $1045, $1046, $1047, $1048, $1049, $1050, $1051, $1052, $1053, $1054, $1055, $1056, $1057, $1058, $1059, $1060, $1061, $1062, $1063, $1064, $1065, $1066, $1067, $1068, $1069, $1070, $1071, $1072, $1073, $1074, $1075, $1076, $1077, $1078, $1079, $1080, $1081, $1082, $1083, $1084, $1085, $1086, $1087, $1088, $1089, $1090, $1091, $1092, $1093, $1094, $1095, $1096, $1097, $1098, $1099, $1100, $1101, $1102, $1103, $1104, $1105, $1106, $1107, $1108, $1109, $1110, $1111, $1112, $1113, $1114, $1115, $1116, $1117, $1118, $1119, $1120, $1121, $1122, $1123, $1124, $1125, $1126, $1127, $1128, $1129, $1130, $1131, $1132, $1133, $1134, $1135, $1136, $1137, $1138, $1139, $1140, $1141, $1142, $1143, $1144, $1145, $1146, $1147, $1148, $1149, $1150, $1151, $1152, $1153, $1154, $1155, $1156, $1157, $1158, $1159, $1160, $1161, $1162, $1163, $1164, $1165, $1166, $1167, $1168, $1169, $1170, $1171, $1172, $1173, $1174, $1175, $1176, $1177, $1178, $1179, $1180, $1181, $1182, $1183, $1184, $1185, $1186, $1187, $1188, $1189, $1190, $1191, $1192, $1193, $1194, $1195, $1196, $1197, $1198, $1199, $1200, $1201, $1202, $1203, $1204, $1205, $1206, $1207, $1208, $1209, $1210, $1211, $1212, $1213, $1214, $1215, $1216, $1217, $1218, $1219, $1220, $1221, $1222, $1223, $1224, $1225, $1226, $1227, $1228, $1229, $1230, $1231, $1232, $1233, $1234, $1235, $1236, $1237, $1238, $1239, $1240, $1241, $1242, $1243, $1244, $1245, $1246, $1247, $1248, $1249, $1250, $1251, $1252, $1253, $1254, $1255, $1256, $1257, $1258, $1259, $1260, $1261, $1262, $1263, $1264, $1265, $1266, $1267, $1268, $1269, $1270, $1271, $1272, $1273, $1274, $1275, $1276, $1277, $1278, $1279, $1280, $1281, $1282, $1283, $1284, $1285, $1286, $1287, $1288, $1289, $1290, $1291, $1292, $1293, $1294, $1295, $1296, $1297, $1298, $1299, $1300, $1301, $1302, $1303, $1304, $1305, $1306, $1307, $1308, $1309, $1310, $1311, $1312, $1313, $1314, $1315, $1316, $1317, $1318, $1319, $1320, $1321, $1322, $1323, $1324, $1325, $1326, $1327, $1328, $1329, $1330, $1331, $1332, $1333, $1334, $1335, $1336, $1337, $1338, $1339, $1340, $1341, $1342, $1343, $1344, $1345, $1346, $1347, $1348, $1349, $1350, $1351, $1352, $1353, $1354, $1355, $1356, $1357, $1358, $1359, $1360, $1361, $1362, $1363, $1364, $1365, $1366, $1367, $1368, $1369, $1370, $1371, $1372, $1373, $1374, $1375, $1376, $1377, $1378, $1379, $1380, $1381, $1382, $1383, $1384, $1385, $1386, $1387, $1388, $1389, $1390, $1391, $1392, $1393, $1394, $1395, $1396, $1397, $1398, $1399, $1400, $1401, $1402, $1403, $1404, $1405, $1406, $1407, $1408, $1409, $1410, $1411, $1412, $1413, $1414, $1415, $1416, $1417, $1418, $1419, $1420, $1421, $1422, $1423, $1424, $1425, $1426, $1427, $1428, $1429, $1430, $1431, $1432, $1433, $1434, $1435, $1436, $1437, $1438, $1439, $1440, $1441, $1442, $1443, $1444, $1445, $1446, $1447, $1448, $1449, $1450, $1451, $1452, $1453, $1454, $1455, $1456, $1457, $1458, $1459, $1460, $1461, $1462, $1463, $1464, $1465, $1466, $1467, $1468, $1469, $1470, $1471, $1472, $1473, $1474, $1475, $1476, $1477, $1478, $1479, $1480, $1481, $1482, $1483, $1484, $1485, $1486, $1487, $1488, $1489, $1490, $1491, $1492, $1493, $1494, $1495, $1496, $1497, $1498, $1499, $1500, $1501, $1502, $1503, $1504, $1505, $1506, $1507, $1508, $1509, $1510, $1511, $1512, $1513, $1514, $1515, $1516, $1517, $1518, $1519, $1520, $1521, $1522, $1523, $1524, $1525, $1526, $1527, $1528, $1529, $1530, $1531, $1532, $1533, $1534, $1535]))
          Storage Table Read Requests: 1
          Storage Table Read Execution Time: 0.660 ms
  Planning Time: 1.103 ms
  Execution Time: 6.056 ms
  Storage Read Requests: 5
  Storage Read Execution Time: 3.880 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 0
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 3.880 ms
  Peak Memory Usage: 1208 kB
  (49 rows)

  yugabyte=#
  ```

</details>

### prepare statements

```sql
prepare employee_salary(int) as select ename, sal from emp where empno=$1;

execute employee_salary(7900);
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# prepare employee_salary(int) as select ename, sal from emp where empno=$1;
  PREPARE
  yugabyte=#
  yugabyte=# execute employee_salary(7900);
  ename | sal
  -------+-----
  JAMES | 950
  (1 row)

  yugabyte=#
  ```

</details>

### common table expression (cte)

```sql
with emp_evaluation_period as (
  select ename,
    deptno,
    hiredate,
    hiredate + case
      when job in ('MANAGER', 'PRESIDENT') then interval '3 month'
      else interval '4 weeks'
    end evaluation_end
  from emp
)
select *
from emp_evaluation_period e1
  join emp_evaluation_period e2 on (e1.ename > e2.ename)
  and (e1.deptno = e2.deptno)
where (e1.hiredate, e1.evaluation_end) overlaps (e2.hiredate, e2.evaluation_end);
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# with emp_evaluation_period as (
  yugabyte(#   select ename,
  yugabyte(#     deptno,
  yugabyte(#     hiredate,
  yugabyte(#     hiredate + case
  yugabyte(#       when job in ('MANAGER', 'PRESIDENT') then interval '3 month'
  yugabyte(#       else interval '4 weeks'
  yugabyte(#     end evaluation_end
  yugabyte(#   from emp
  yugabyte(# )
  yugabyte-# select *
  yugabyte-# from emp_evaluation_period e1
  yugabyte-#   join emp_evaluation_period e2 on (e1.ename > e2.ename)
  yugabyte-#   and (e1.deptno = e2.deptno)
  yugabyte-# where (e1.hiredate, e1.evaluation_end) overlaps (e2.hiredate, e2.evaluation_end);
  ename  | deptno |  hiredate  |   evaluation_end    | ename  | deptno |  hiredate  |   evaluation_end
  --------+--------+------------+---------------------+--------+--------+------------+---------------------
  MILLER |     10 | 1982-01-23 | 1982-02-20 00:00:00 | KING   |     10 | 1981-11-17 | 1982-02-17 00:00:00
  TURNER |     30 | 1981-09-08 | 1981-10-06 00:00:00 | MARTIN |     30 | 1981-09-28 | 1981-10-26 00:00:00
  WARD   |     30 | 1981-02-22 | 1981-03-22 00:00:00 | ALLEN  |     30 | 1981-02-20 | 1981-03-20 00:00:00
  (3 rows)

  yugabyte=#
  ```

</details>

### recursive cte

```sql
with recursive emp_manager as (
  select empno,
    ename,
    ename as path
  from emp
  where ename = 'JONES'
  union all
  select emp.empno,
    emp.ename,
    emp_manager.path || ' manages ' || emp.ename
  from emp
    join emp_manager on emp.mgr = emp_manager.empno
)
select * from emp_manager;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# with recursive emp_manager as (
  yugabyte(#   select empno,
  yugabyte(#     ename,
  yugabyte(#     ename as path
  yugabyte(#   from emp
  yugabyte(#   where ename = 'JONES'
  yugabyte(#   union all
  yugabyte(#   select emp.empno,
  yugabyte(#     emp.ename,
  yugabyte(#     emp_manager.path || ' manages ' || emp.ename
  yugabyte(#   from emp
  yugabyte(#     join emp_manager on emp.mgr = emp_manager.empno
  yugabyte(# )
  yugabyte-# select * from emp_manager;
  empno | ename |               path
  -------+-------+-----------------------------------
    7566 | JONES | JONES
    7788 | SCOTT | JONES manages SCOTT
    7902 | FORD  | JONES manages FORD
    7876 | ADAMS | JONES manages SCOTT manages ADAMS
    7369 | SMITH | JONES manages FORD manages SMITH
  (5 rows)

  yugabyte=#
  ```

</details>

### window functions

```sql
select dname,
  ename,
  job,
  coalesce (
    'hired ' || to_char(
      hiredate - lag(hiredate) over (per_dept_hiredate),
      '999'
    ) || ' days after ' || lag(ename) over (per_dept_hiredate),
    format('(1st hire in %L)', dname)
  ) as "last hire in dept"
from emp
  join dept using(deptno) window per_dept_hiredate as (
    partition by dname
    order by hiredate
  )
order by dname,
  hiredate;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# select dname,
  yugabyte-#   ename,
  yugabyte-#   job,
  yugabyte-#   coalesce (
  yugabyte(#     'hired ' || to_char(
  yugabyte(#       hiredate - lag(hiredate) over (per_dept_hiredate),
  yugabyte(#       '999'
  yugabyte(#     ) || ' days after ' || lag(ename) over (per_dept_hiredate),
  yugabyte(#     format('(1st hire in %L)', dname)
  yugabyte(#   ) as "last hire in dept"
  yugabyte-# from emp
  yugabyte-#   join dept using(deptno) window per_dept_hiredate as (
  yugabyte(#     partition by dname
  yugabyte(#     order by hiredate
  yugabyte(#   )
  yugabyte-# order by dname,
  yugabyte-#   hiredate;
    dname    | ename  |    job    |      last hire in dept
  ------------+--------+-----------+------------------------------
  ACCOUNTING | CLARK  | MANAGER   | (1st hire in 'ACCOUNTING')
  ACCOUNTING | KING   | PRESIDENT | hired  161 days after CLARK
  ACCOUNTING | MILLER | CLERK     | hired   67 days after KING
  RESEARCH   | SMITH  | CLERK     | (1st hire in 'RESEARCH')
  RESEARCH   | JONES  | MANAGER   | hired  106 days after SMITH
  RESEARCH   | FORD   | ANALYST   | hired  245 days after JONES
  RESEARCH   | SCOTT  | ANALYST   | hired  371 days after FORD
  RESEARCH   | ADAMS  | CLERK     | hired   34 days after SCOTT
  SALES      | ALLEN  | SALESMAN  | (1st hire in 'SALES')
  SALES      | WARD   | SALESMAN  | hired    2 days after ALLEN
  SALES      | BLAKE  | MANAGER   | hired   68 days after WARD
  SALES      | TURNER | SALESMAN  | hired  130 days after BLAKE
  SALES      | MARTIN | SALESMAN  | hired   20 days after TURNER
  SALES      | JAMES  | CLERK     | hired   66 days after MARTIN
  (14 rows)

  yugabyte=#
  ```

</details>

### group by

```sql
with groups as (
  select ntile(3) over (
      order by empno
    ) group_num,
    *
  from emp
)
select string_agg(format('<%s> %s', ename, email), ', ')
from groups group by group_num;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# with groups as (
  yugabyte(#   select ntile(3) over (
  yugabyte(#       order by empno
  yugabyte(#     ) group_num,
  yugabyte(#     *
  yugabyte(#   from emp
  yugabyte(# )
  yugabyte-# select string_agg(format('<%s> %s', ename, email), ', ')
  yugabyte-# from groups group by group_num;
                                                            string_agg
  -------------------------------------------------------------------------------------------------------------------------------
  <ADAMS> ADAMS@acme.org, <JAMES> JAMES@acme.org, <FORD> FORD@acme.com, <MILLER> MILLER@acme.com
  <BLAKE> BLAKE@hotmail.com, <CLARK> CLARK@acme.com, <SCOTT> SCOTT@acme.com, <KING> KING@aol.com, <TURNER> TURNER@acme.com
  <SMITH> SMITH@acme.com, <ALLEN> ALLEN@acme.com, <WARD> WARD@compuserve.com, <JONES> JONES@gmail.com, <MARTIN> MARTIN@acme.com
  (3 rows)

  yugabyte=#
  ```

</details>

### procedure

```sql
-- create procedure
create or replace procedure commission_transfer(
  empno1 int,
  empno2 int,
  amount int
) as $$
begin
  update
    emp
  set
    comm = comm-commission_transfer.amount
  where
    empno=commission_transfer.empno1
    and
    comm > commission_transfer.amount;

  if not found
  then
    raise exception 'Cannot transfer % from %',amount,empno1;
  end if;
  update
    emp
  set
    comm = comm+commission_transfer.amount
  where
    emp.empno = commission_transfer.empno2;

  if not found
  then
    raise exception 'Cannot transfer from %',empno2;
  end if;
end;
$$ language plpgsql;

-- call the procedure
call commission_transfer(7521,7654,100);

-- select from emp
select * from emp where comm is not null;

-- call the procedure
call commission_transfer(7521,7654,1000000);
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# -- create procedure
  yugabyte=# create or replace procedure commission_transfer(
  yugabyte(#   empno1 int,
  yugabyte(#   empno2 int,
  yugabyte(#   amount int
  yugabyte(# ) as $$
  yugabyte$# begin
  yugabyte$#   update
  yugabyte$#     emp
  yugabyte$#   set
  yugabyte$#     comm = comm-commission_transfer.amount
  yugabyte$#   where
  yugabyte$#     empno=commission_transfer.empno1
  yugabyte$#     and
  yugabyte$#     comm > commission_transfer.amount;
  yugabyte$#
  yugabyte$#   if not found
  yugabyte$#   then
  yugabyte$#     raise exception 'Cannot transfer % from %',amount,empno1;
  yugabyte$#   end if;
  yugabyte$#   update
  yugabyte$#     emp
  yugabyte$#   set
  yugabyte$#     comm = comm+commission_transfer.amount
  yugabyte$#   where
  yugabyte$#     emp.empno = commission_transfer.empno2;
  yugabyte$#
  yugabyte$#   if not found
  yugabyte$#   then
  yugabyte$#     raise exception 'Cannot transfer from %',empno2;
  yugabyte$#   end if;
  yugabyte$# end;
  yugabyte$# $$ language plpgsql;
  edure
  call commission_transfer(7521,7654,1000000);
  CREATE PROCEDURE
  yugabyte=#
  yugabyte=# -- call the procedure
  yugabyte=# call commission_transfer(7521,7654,100);
  CALL
  yugabyte=#
  yugabyte=# -- select from emp
  yugabyte=# select * from emp where comm is not null;
  empno | ename  |   job    | mgr  |  hiredate  | sal  | comm | deptno |        email        | other_info
  -------+--------+----------+------+------------+------+------+--------+---------------------+------------
    7521 | WARD   | SALESMAN | 7698 | 1981-02-22 | 1250 |  300 |     30 | WARD@compuserve.com |
    7654 | MARTIN | SALESMAN | 7698 | 1981-09-28 | 1250 | 1600 |     30 | MARTIN@acme.com     |
    7499 | ALLEN  | SALESMAN | 7698 | 1981-02-20 | 1600 |  300 |     30 | ALLEN@acme.com      |
    7844 | TURNER | SALESMAN | 7698 | 1981-09-08 | 1500 |    0 |     30 | TURNER@acme.com     |
  (4 rows)

  yugabyte=#
  yugabyte=# -- call the procedure
  yugabyte=# call commission_transfer(7521,7654,1000000);
  ERROR:  Cannot transfer 1000000 from 7521
  CONTEXT:  PL/pgSQL function commission_transfer(integer,integer,integer) line 14 at RAISE
  yugabyte=#
  ```

</details>

### triggers

```sql
-- add column
alter table dept add last_update timestamptz;

-- create trigger
create or replace function dept_last_update()
returns trigger as $$
begin
  new.last_update:=transaction_timestamp();
  return new;
end;
$$ language plpgsql;

-- add trigger
create trigger dept_last_update
before update on dept
for each row
execute procedure dept_last_update();

-- select table
select deptno, dname, loc, last_update from dept;

-- update table
begin transaction;
update dept set loc='SUNNYVALE' where deptno=30;
select pg_sleep(3);
update dept set loc='SUNNYVALE' where deptno=40;
commit;

-- select table
select deptno, dname, loc, last_update from dept;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# -- add column
  yugabyte=# alter table dept add last_update timestamptz;
  ALTER TABLE
  yugabyte=#
  yugabyte=# -- create trigger
  yugabyte=# create or replace function dept_last_update()
  yugabyte-# returns trigger as $$
  yugabyte$# begin
  yugabyte$#   new.last_update:=transaction_timestamp();
  yugabyte$#   return new;
  yugabyte$# end;
  yugabyte$# $$ language plpgsql;
  CREATE FUNCTION
  yugabyte=#
  yugabyte=# -- add trigger
  yugabyte=# create trigger dept_last_update
  yugabyte-# before update on dept
  yugabyte-# for each row
  yugabyte-# execute procedure dept_last_update();
  CREATE TRIGGER
  yugabyte=#
  yugabyte=# -- select table
  yugabyte=# select deptno, dname, loc, last_update from dept;
  deptno |   dname    |   loc    | last_update
  --------+------------+----------+-------------
      10 | ACCOUNTING | NEW YORK |
      20 | RESEARCH   | DALLAS   |
      30 | SALES      | CHICAGO  |
      40 | OPERATIONS | BOSTON   |
  (4 rows)

  yugabyte=#
  yugabyte=# -- update table
  yugabyte=# begin transaction;
  BEGIN
  yugabyte=# update dept set loc='SUNNYVALE' where deptno=30;
  UPDATE 1
  yugabyte=# select pg_sleep(3);
  pg_sleep
  ----------

  (1 row)

  yugabyte=# update dept set loc='SUNNYVALE' where deptno=40;
  UPDATE 1
  yugabyte=# commit;
  COMMIT
  yugabyte=#
  yugabyte=# -- select table
  yugabyte=# select deptno, dname, loc, last_update from dept;
  deptno |   dname    |    loc    |          last_update
  --------+------------+-----------+-------------------------------
      10 | ACCOUNTING | NEW YORK  |
      20 | RESEARCH   | DALLAS    |
      30 | SALES      | SUNNYVALE | 2023-11-20 03:25:47.367507+00
      40 | OPERATIONS | SUNNYVALE | 2023-11-20 03:25:47.367507+00
  (4 rows)

  yugabyte=#
  ```

</details>

### materialized views

```sql
-- create materialized view
create materialized view report_sal_per_dept as
select deptno,
  dname,
  sum(sal) sal_per_dept,
  count(*) num_of_employees,
  string_agg(distinct job, ', ') distinct_jobs
from dept
  join emp using(deptno)
group by deptno,
  dname
order by deptno;

-- create index
create index report_sal_per_dept_sal on report_sal_per_dept(sal_per_dept desc);

-- refresh materialized view
refresh materialized view report_sal_per_dept;

-- select from materialized view
select *
from report_sal_per_dept
where sal_per_dept <= 10000
order by sal_per_dept;

-- explain plan
:ea
select *
from report_sal_per_dept
where sal_per_dept <= 10000
order by sal_per_dept;
```

<details>
  <summary>
  Sample Output
  </summary>

  ```sql
  yugabyte=# -- create materialized view
  yugabyte=# create materialized view report_sal_per_dept as
  yugabyte-# select deptno,
  yugabyte-#   dname,
  yugabyte-#   sum(sal) sal_per_dept,
  yugabyte-#   count(*) num_of_employees,
  yugabyte-#   string_agg(distinct job, ', ') distinct_jobs
  yugabyte-# from dept
  yugabyte-#   join emp using(deptno)
  yugabyte-# group by deptno,
  yugabyte-#   dname
  yugabyte-# order by deptno;
  SELECT 3
  yugabyte=#
  yugabyte=# -- create index
  yugabyte=# create index report_sal_per_dept_sal on report_sal_per_dept(sal_per_dept desc);
  CREATE INDEX
  yugabyte=#
  yugabyte=# -- refresh materialized view
  yugabyte=# refresh materialized view report_sal_per_dept;
  REFRESH MATERIALIZED VIEW
  yugabyte=#
  yugabyte=# -- select from materialized view
  yugabyte=# select *
  yugabyte-# from report_sal_per_dept
  yugabyte-# where sal_per_dept <= 10000
  yugabyte-# order by sal_per_dept;
  deptno |   dname    | sal_per_dept | num_of_employees |       distinct_jobs
  --------+------------+--------------+------------------+---------------------------
      10 | ACCOUNTING |         8750 |                3 | CLERK, MANAGER, PRESIDENT
      30 | SALES      |         9400 |                6 | CLERK, MANAGER, SALESMAN
  (2 rows)

  yugabyte=#
  yugabyte=# -- explain plan
  yugabyte=# :ea
  yugabyte-# select *
  yugabyte-# from report_sal_per_dept
  yugabyte-# where sal_per_dept <= 10000
  yugabyte-# order by sal_per_dept;
                                                                            QUERY PLAN
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------
  Index Scan Backward using report_sal_per_dept_sal on public.report_sal_per_dept  (cost=0.00..5.33 rows=10 width=84) (actual time=1.368..1.371 rows=2 loops=1)
    Output: deptno, dname, sal_per_dept, num_of_employees, distinct_jobs
    Index Cond: (report_sal_per_dept.sal_per_dept <= 10000)
    Storage Table Read Requests: 1
    Storage Table Read Execution Time: 0.639 ms
    Storage Index Read Requests: 1
    Storage Index Read Execution Time: 0.646 ms
  Planning Time: 0.084 ms
  Execution Time: 1.413 ms
  Storage Read Requests: 2
  Storage Read Execution Time: 1.285 ms
  Storage Write Requests: 0.000
  Catalog Read Requests: 0
  Catalog Write Requests: 0.000
  Storage Flush Requests: 0
  Storage Execution Time: 1.285 ms
  Peak Memory Usage: 24 kB
  (17 rows)

  yugabyte=#
  ```

</details>

[Back to Workshop Home][home]

[home]: ../../README.md
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
[gp-qt]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws/qt
