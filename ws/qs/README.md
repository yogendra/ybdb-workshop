# YugabyteDB Quick Start Lab

[Back to Workshop Home](../../README.md)

**Adapted from [YugabyteDB / Quick Start / Linux](doc-yb-qs)**

## Create a single node cluster

Run commands in the `ybdb` shell

1. Check python version


    ```bash
    python --version
    ```


    <details>
      <summary>
      Sample Output
      </summary>

      ```bash

      ```

    </details>

1. YugabyteDB package is  already downloaded and configured, so we just have to check the version


    ```bash
    yugabyted version
    ```

    <details>
      <summary>
      Sample Output
      </summary>

      ```bash

      ```

    </details>

1. Create a local cluster


    ```bash
    yugabyted start
    ```

    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      Starting yugabyted...
      ✅ System checks
      - Starting the YugabyteDB Processes...
      ✅ YugabyteDB Started
      ✅ UI ready
      ✅ Data placement constraint successfully verified

      ⚠ WARNINGS:
      - Cluster started in an insecure mode without authentication and encryption enabled. For non-production use only, not to be used without firewalls blocking the internet traffic.


      +----------------------------------------------------------------------------------------------------------+
      |                                                yugabyted                                                 |
      +----------------------------------------------------------------------------------------------------------+
      | Status              : Running.                                                                           |
      | Replication Factor  : 1                                                                                  |
      | Web console         : http://127.0.0.1:7000                                                              |
      | JDBC                : jdbc:postgresql://127.0.0.1:5433/yugabyte?user=yugabyte&password=yugabyte                   |
      | YSQL                : bin/ysqlsh   -U yugabyte -d yugabyte                                               |
      | YCQL                : bin/ycqlsh   -u cassandra                                                          |
      | Data Dir            : /Users/yrampuria/var/data                                                          |
      | Log Dir             : /Users/yrampuria/var/logs                                                          |
      | Universe UUID       : 0a50fd08-ff1a-4321-aee4-828caf3e7574                                               |
      +----------------------------------------------------------------------------------------------------------+
      🚀 YugabyteDB started successfully! To load a sample dataset, try 'yugabyted demo'.
      🎉 Join us on Slack at https://www.yugabyte.com/slack
      👕 Claim your free t-shirt at https://www.yugabyte.com/community-rewards/
      ```

    </details>


1. Check status of the cluster


    ```bash
    yugabyted status
    ```

    <details>
      <summary>
      Sample Output
      </summary>

      ```bash

      ```

    </details>


1. Connect to YSQL API by running following command in shell


    ```bash
    ysqlsh
    ```

    <details>
      <summary>
      Sample Output
      </summary>

      ```bash

      ```

    </details>

1. (Optional) Run some sample SQLs in the `ysqlsh`

    ```sql
    select version();
    ```

    <details>
      <summary>
      Sample Output
      </summary>

      ```bash

      ```

    </details>

1. Quick `ysqlsh`

      ```sql
      \q
      ```



## Access UIs


1. Open the cluster UI  for the database. In the *Ports* tab, open the *yugabyted-ui* URL.

1. Open the master UI for the database. In the *Ports* tab, open the *master* URL.

2. Open the tserver UI for the database, In the *Ports* tab, open the *tserver* URL.






[Back to Workshop Home](../../README.md)
