# YugabyteDB xCluster Demo

[Back to Workshop Home][home]

[![Open in Gitpod][logo-gitpod]][gp-xcluster]

## Checkout the cluster details

Run the following from `C1-ysqlsh` shell

1. Check data on in Cluster 1 `categories` table. Execure in `C1-ysqlsh` shell

    ```sql
    select * from categories;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select * from categories;
      category_id | category_name  |                        description                         | picture 
      -------------+----------------+------------------------------------------------------------+---------
                4 | Dairy Products | Cheeses                                                    | \x
                1 | Beverages      | Soft drinks, coffees, teas, beers, and ales                | \x
                2 | Condiments     | Sweet and savory sauces, relishes, spreads, and seasonings | \x
                7 | Produce        | Dried fruit and bean curd                                  | \x
                3 | Confections    | Desserts, candies, and sweet breads                        | \x
                8 | Seafood        | Seaweed and fish                                           | \x
                5 | Grains/Cereals | Breads, crackers, pasta, and cereal                        | \x
                6 | Meat/Poultry   | Prepared meats                                             | \x
      (8 rows)
      ```
    </details>

1. Check data on in Cluster 2 `categories` table. Execure in `C2-ysqlsh` shell

    ```sql
    select * from categories;
    ```

    <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select * from categories;
      category_id | category_name  |                        description                         | picture 
      -------------+----------------+------------------------------------------------------------+---------
                4 | Dairy Products | Cheeses                                                    | \x
                1 | Beverages      | Soft drinks, coffees, teas, beers, and ales                | \x
                2 | Condiments     | Sweet and savory sauces, relishes, spreads, and seasonings | \x
                7 | Produce        | Dried fruit and bean curd                                  | \x
                3 | Confections    | Desserts, candies, and sweet breads                        | \x
                8 | Seafood        | Seaweed and fish                                           | \x
                5 | Grains/Cereals | Breads, crackers, pasta, and cereal                        | \x
                6 | Meat/Poultry   | Prepared meats                                             | \x
      (8 rows)
      ```
    </details>

2. In `C1-ysqlsh`, run following to insert a record

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

1. On `C2-ysqlsh`, execute following to verify that the row is replicated over to second cluster

    ```sql
    select * from categories where category_id=9
    ```

     <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select * from categories where category_id=9;
      category_id | category_name  | description | picture 
      -------------+----------------+-------------+---------
                9 | Computer Parts |             | 
      (1 row)

      ```

    </details>

1. On `C2-ysqlsh`, execute following to insert a record

    ```sql
    insert into categories ( category_id, category_name) values (10, 'Auto Part');
    ```

     <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# insert into categories ( category_id, category_name) values (10, 'Auto Part');
      INSERT 0 1

      ```
1. On `C1-ysqlsh`, execute following to verify the record is replicated over

    ```sql
    select * from categories where category_id=10;
    ```

     <details>
      <summary>
        Sample Output
      </summary>

      ```sql
      demo=# select * from categories where category_id=10;
      category_id | category_name | description | picture 
      -------------+---------------+-------------+---------
                10 | Auto Part     |             | 
      (1 row)

      ```

    </details>


[Back to Workshop Home][home]

[home]: ../../README.md
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
[gp-xcluster]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws/xcluster
