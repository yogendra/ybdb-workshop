# YugabyteDB xCluster Demo

[Back to Workshop Home][home]

[![Open in Gitpod][logo-gitpod]][gp-xcluster]

## Checkout the cluster details

Run the following from `C1-ysqlsh` shell

1. In `C1-ysqlsh`, run following SQL to see  the cluster node configuration

     ```sql
    select host, port, cloud, region, zone, public_ip from yb_servers() order by host;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select host, port, cloud, region, zone, public_ip from yb_servers() order by host;
        host    | port |  cloud  | region  | zone | public_ip 
      -----------+------+---------+---------+------+-----------
      127.0.0.1 | 5433 | ybcloud | pandora | az1  | 127.0.0.1
      127.0.0.2 | 5433 | ybcloud | pandora | az2  | 127.0.0.2
      127.0.0.3 | 5433 | ybcloud | pandora | az3  | 127.0.0.3
      (3 rows)

      ```
    </details>


1. In `C2-ysqlsh`, run following SQL to see  the cluster node configuration

     ```sql
    select host, port, cloud, region, zone, public_ip from yb_servers() order by host;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select host, port, cloud, region, zone, public_ip from yb_servers() order by host; 
        host    | port |  cloud  |  region  | zone | public_ip 
      -----------+------+---------+----------+------+-----------
      127.0.0.4 | 5433 | ybcloud | centaury | az1  | 127.0.0.4
      127.0.0.5 | 5433 | ybcloud | centaury | az2  | 127.0.0.5
      127.0.0.6 | 5433 | ybcloud | centaury | az3  | 127.0.0.6
      (3 rows)

      ```
    </details>

## Examine the categories data

1. In `C1-ysqlsh`, run following SQL to list `category` data in cluster 1.

    ```sql
    select category_id, category_name from categories order by category_id;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select category_id, category_name from categories order by category_id;
      category_id | category_name  
      -------------+----------------
                1 | Beverages
                2 | Condiments
                3 | Confections
                4 | Dairy Products
                5 | Grains/Cereals
                6 | Meat/Poultry
                7 | Produce
                8 | Seafood
                9 | Computer Parts
                10 | Auto Part
      (10 rows)

      ```
    </details>

1. In `C2-ysqlsh`, run following SQL to list `category` data in cluster 2.

    ```sql
    select category_id, category_name from categories order by category_id;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select category_id, category_name from categories order by category_id;
      category_id | category_name  
      -------------+----------------
                1 | Beverages
                2 | Condiments
                3 | Confections
                4 | Dairy Products
                5 | Grains/Cereals
                6 | Meat/Poultry
                7 | Produce
                8 | Seafood
                9 | Computer Parts
                10 | Auto Part
      (10 rows)

      ```
    </details>

## Demonstrate replication from Cluster 1 to Cluster 2

1. In `C2-ysqlsh`, run following SQL to start watching/monitoring for a new record

    ```sql
    select category_id, category_name from categories where category_id = 9;
    \watch 1
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select category_id, category_name from categories where category_id = 9;
      category_id | category_name 
      -------------+---------------
      (0 rows)

      demo=# \watch 1
      Thu 04 Apr 2024 02:59:27 PM UTC (every 1s)

      category_id | category_name 
      -------------+---------------
      (0 rows)
      ....
      .... 
      ```

    </details>

1. In `C1-ysqlsh`, run following SQL to insert a record

    ```sql
    insert into categories ( category_id, category_name) values (9, 'Computer Parts');
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# insert into categories ( category_id, category_name) values (9, 'Computer Parts');
      INSERT 0 1
      ```

    </details>

    Observe the record appearing on the `C2-ysqlsh`.

    ```sql
    Thu 04 Apr 2024 03:02:35 PM UTC (every 1s)

    category_id | category_name  
    -------------+----------------
              9 | Computer Parts
    (1 row)
    ```
    
    Stop watching/monitoring on `C2-ysqlsh` by pressing `Control + C`

    ```sql
    ^Cdemo=# 
    ```

## Demonstrate replication from Cluster 2 to Cluster 1

1. In `C1-ysqlsh`, run following SQL to start watching/monitoring for a new record

    ```sql
    select category_id, category_name from categories where category_id = 10;
    \watch 1
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select category_id, category_name from categories where category_id = 10;
      category_id | category_name 
      -------------+---------------
      (0 rows)

      demo=# \watch 1
      Thu 04 Apr 2024 03:06:59 PM UTC (every 1s)

      category_id | category_name 
      -------------+---------------
      (0 rows)
      ....
      .... 
      ```

    </details>

1. In `C2-ysqlsh`, run following SQL to insert a record

    ```sql
    insert into categories ( category_id, category_name) values (10, 'Auto Parts');
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# insert into categories ( category_id, category_name) values (10, 'Auto Parts');
      INSERT 0 1
      ```

    </details>

    Observe the record appearing on the `C2-ysqlsh`.

    ```sql

    Thu 04 Apr 2024 03:08:13 PM UTC (every 1s)

    category_id | category_name 
    -------------+---------------
              10 | Auto Parts
    (1 row)
    ```
    
    Stop watching/monitoring on `C2-ysqlsh` by pressing `Control + C`

    ```sql
    ^Cdemo=# 
    ```


[Back to Workshop Home][home]

[home]: ../../README.md
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
[gp-xcluster]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws/xcluster
