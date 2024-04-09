# YugabyteDB Quick Start Lab

[Back to Workshop Home][home]

[![Open in Gitpod][logo-gitpod]][gp-qs]

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
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ python --version
      Python 3.9.18
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
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted version
      /usr/local/yugabyte/version_metadata.json

      ----------------------------------------------------------------------
      |                              Version                               |
      ----------------------------------------------------------------------
      | Version        : 2.20.0.0-b76                                      |
      | Build Time     : 04 Nov 2023 02:23:30 UTC                          |
      | Build Hash     : 0026607ed49516b4d5770f5479dd5d60d44710af          |
      ----------------------------------------------------------------------

      gitpod /workspace/ybdb-workshop ((ws/qs)) $
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
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted start
      Starting yugabyted...
      ✅ YugabyteDB Started
      ✅ UI ready
      ✅ Data placement constraint successfully verified

      ⚠ WARNINGS:
      - Transparent hugepages disabled. Please enable transparent_hugepages.
      - ntp/chrony package is missing for clock synchronization. For centos 7, we recommend installing either ntp or chrony package and for centos 8, we recommend installing chrony package.
      - Cluster started in an insecure mode without authentication and encryption enabled. For non-production use only, not to be used without firewalls blocking the internet traffic.
      Please review the 'Quick start for Linux' docs and rerun the start command: https://docs.yugabyte.com/preview/quick-start/linux/


      +----------------------------------------------------------------------------------------------------------+
      |                                                yugabyted                                                 |
      +----------------------------------------------------------------------------------------------------------+
      | Status              : Running.                                                                           |
      | Replication Factor  : 1                                                                                  |
      | YugabyteDB UI       : http://127.0.0.1:15433                                                             |
      | JDBC                : jdbc:postgresql://127.0.0.1:5433/yugabyte?user=yugabyte&password=yugabyte                   |
      | YSQL                : bin/ysqlsh   -U yugabyte -d yugabyte                                               |
      | YCQL                : bin/ycqlsh   -u cassandra                                                          |
      | Data Dir            : /home/gitpod/var/data                                                              |
      | Log Dir             : /home/gitpod/var/logs                                                              |
      | Universe UUID       : eebb2f26-f2e3-452d-bd09-65f7b1281aed                                               |
      +----------------------------------------------------------------------------------------------------------+
      🚀 YugabyteDB started successfully! To load a sample dataset, try 'yugabyted demo'.
      🎉 Join us on Slack at https://www.yugabyte.com/slack
      👕 Claim your free t-shirt at https://www.yugabyte.com/community-rewards/

      gitpod /workspace/ybdb-workshop ((ws/qs)) $
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
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted status

      +----------------------------------------------------------------------------------------------------------+
      |                                                yugabyted                                                 |
      +----------------------------------------------------------------------------------------------------------+
      | Status              : Running.                                                                           |
      | Replication Factor  : 1                                                                                  |
      | YugabyteDB UI       : http://127.0.0.1:15433                                                             |
      | JDBC                : jdbc:postgresql://127.0.0.1:5433/yugabyte?user=yugabyte&password=yugabyte                   |
      | YSQL                : bin/ysqlsh   -U yugabyte -d yugabyte                                               |
      | YCQL                : bin/ycqlsh   -u cassandra                                                          |
      | Data Dir            : /home/gitpod/var/data                                                              |
      | Log Dir             : /home/gitpod/var/logs                                                              |
      | Universe UUID       : eebb2f26-f2e3-452d-bd09-65f7b1281aed                                               |
      +----------------------------------------------------------------------------------------------------------+

      gitpod /workspace/ybdb-workshop ((ws/qs)) $
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
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ ysqlsh
      ysqlsh (11.2-YB-2.20.0.0-b0)
      Type "help" for help.

      yugabyte=#
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
      yugabyte=# select version();
                                                                                              version

      -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      PostgreSQL 11.2-YB-2.20.0.0-b0 on x86_64-pc-linux-gnu, compiled by clang version 16.0.6 (https://github.com/yugabyte/llvm-project.git 1e6329f40e5c531c09ade7015278078682293ebd)
      , 64-bit
      (1 row)

      yugabyte=#
      ```

    </details>

1. Quit `ysqlsh`

      ```sql
      \q
      ```
    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      yugabyte=# \q
      gitpod /workspace/ybdb-workshop ((ws/qs)) $
      ```

    </details>

1. Destroy cluster

    ```bash
    yugabyted destroy
    ```
    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted destroy
      Stopped yugabyted using config /home/gitpod/var/conf/yugabyted.conf.
      Deleted logs at /home/gitpod/var/logs.
      Deleted data at /home/gitpod/var/data.
      Deleted conf at /home/gitpod/var/conf.
      gitpod /workspace/ybdb-workshop ((ws/qs)) $
      ```

    </details>

## Create a multi-node cluster


1. Create a root dir for storing multiple node base directories

    ```bash
    mkdir -p ${GITPOD_REPO_ROOT}/ybdb
    ```
    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ mkdir -p ${GITPOD_REPO_ROOT}/ybdb
      gitpod /workspace/ybdb-workshop ((ws/qs)) $

      ```

    </details>

1. Start Node 1


    ```bash
    yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd1 --advertise_address=$HOST_LB --cloud_location=ybcloud.pandora.az1 --fault_tolerance=zone
    ```



    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd1 --advertise_address=$HOST_LB --cloud_location=ybcloud.pandora.az1 --fault_tolerance=zone
      Starting yugabyted...
      ✅ YugabyteDB Started
      ✅ UI ready
      ✅ Data placement constraint successfully verified

      ⚠ WARNINGS:
      - Transparent hugepages disabled. Please enable transparent_hugepages.
      - ntp/chrony package is missing for clock synchronization. For centos 7, we recommend installing either ntp or chrony package and for centos 8, we recommend installing chrony package.
      - Cluster started in an insecure mode without authentication and encryption enabled. For non-production use only, not to be used without firewalls blocking the internet traffic.
      Please review the 'Quick start for Linux' docs and rerun the start command: https://docs.yugabyte.com/preview/quick-start/linux/


      +----------------------------------------------------------------------------------------------------------+
      |                                                yugabyted                                                 |
      +----------------------------------------------------------------------------------------------------------+
      | Status              : Running.                                                                           |
      | Replication Factor  : 1                                                                                  |
      | YugabyteDB UI       : http://127.0.0.1:15433                                                             |
      | JDBC                : jdbc:postgresql://127.0.0.1:5433/yugabyte?user=yugabyte&password=yugabyte                   |
      | YSQL                : bin/ysqlsh   -U yugabyte -d yugabyte                                               |
      | YCQL                : bin/ycqlsh   -u cassandra                                                          |
      | Data Dir            : /workspace/ybdb-workshop/ybdb/ybd1/data                                            |
      | Log Dir             : /workspace/ybdb-workshop/ybdb/ybd1/logs                                            |
      | Universe UUID       : b0749440-cf48-4e44-b442-93897dc85450                                               |
      +----------------------------------------------------------------------------------------------------------+
      🚀 YugabyteDB started successfully! To load a sample dataset, try 'yugabyted demo'.
      🎉 Join us on Slack at https://www.yugabyte.com/slack
      👕 Claim your free t-shirt at https://www.yugabyte.com/community-rewards/

      ```

    </details>


1. Start Node 2

    ```bash
    yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd2 --advertise_address=$HOST_LB2 --join=$HOST_LB --cloud_location=ybcloud.pandora.az2 --fault_tolerance=zone
    ```

    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd2 --advertise_address=$HOST_LB2 --join=$HOST_LB --cloud_location=ybcloud.pandora.az2 --fault_tolerance=zone
      Starting yugabyted...
      ✅ YugabyteDB Started
      ✅ Node joined a running cluster with UUID b0749440-cf48-4e44-b442-93897dc85450
      ✅ UI ready
      ✅ Data placement constraint successfully verified

      ⚠ WARNINGS:
      - ntp/chrony package is missing for clock synchronization. For centos 7, we recommend installing either ntp or chrony package and for centos 8, we recommend installing chrony package.
      - Transparent hugepages disabled. Please enable transparent_hugepages.
      - Cluster started in an insecure mode without authentication and encryption enabled. For non-production use only, not to be used without firewalls blocking the internet traffic.
      Please review the 'Quick start for Linux' docs and rerun the start command: https://docs.yugabyte.com/preview/quick-start/linux/


      +----------------------------------------------------------------------------------------------------------+
      |                                                yugabyted                                                 |
      +----------------------------------------------------------------------------------------------------------+
      | Status              : Running.                                                                           |
      | Replication Factor  : 1                                                                                  |
      | YugabyteDB UI       : http://127.0.0.2:15433                                                             |
      | JDBC                : jdbc:postgresql://127.0.0.2:5433/yugabyte?user=yugabyte&password=yugabyte                   |
      | YSQL                : bin/ysqlsh -h 127.0.0.2  -U yugabyte -d yugabyte                                   |
      | YCQL                : bin/ycqlsh 127.0.0.2 9042 -u cassandra                                             |
      | Data Dir            : /workspace/ybdb-workshop/ybdb/ybd2/data                                            |
      | Log Dir             : /workspace/ybdb-workshop/ybdb/ybd2/logs                                            |
      | Universe UUID       : b0749440-cf48-4e44-b442-93897dc85450                                               |
      +----------------------------------------------------------------------------------------------------------+
      🚀 YugabyteDB started successfully! To load a sample dataset, try 'yugabyted demo'.
      🎉 Join us on Slack at https://www.yugabyte.com/slack
      👕 Claim your free t-shirt at https://www.yugabyte.com/community-rewards/

      gitpod /workspace/ybdb-workshop ((ws/qs)) $
      ```

    </details>


1. Start Node 3

    ```bash
    yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd3 --advertise_address=$HOST_LB3 --join=$HOST_LB --cloud_location=ybcloud.pandora.az3 --fault_tolerance=zone
    ```

    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd3 --advertise_address=$HOST_LB3 --join=$HOST_LB --cloud_location=ybcloud.pandora.az3 --fault_tolerance=zone
      Starting yugabyted...
      ✅ YugabyteDB Started
      ✅ Node joined a running cluster with UUID b0749440-cf48-4e44-b442-93897dc85450
      ✅ UI ready
      ✅ Data placement constraint successfully verified

      ⚠ WARNINGS:
      - Transparent hugepages disabled. Please enable transparent_hugepages.
      - ntp/chrony package is missing for clock synchronization. For centos 7, we recommend installing either ntp or chrony package and for centos 8, we recommend installing chrony package.
      - Cluster started in an insecure mode without authentication and encryption enabled. For non-production use only, not to be used without firewalls blocking the internet traffic.
      Please review the 'Quick start for Linux' docs and rerun the start command: https://docs.yugabyte.com/preview/quick-start/linux/


      +----------------------------------------------------------------------------------------------------------+
      |                                                yugabyted                                                 |
      +----------------------------------------------------------------------------------------------------------+
      | Status              : Running.                                                                           |
      | Replication Factor  : 3                                                                                  |
      | YugabyteDB UI       : http://127.0.0.3:15433                                                             |
      | JDBC                : jdbc:postgresql://127.0.0.3:5433/yugabyte?user=yugabyte&password=yugabyte                   |
      | YSQL                : bin/ysqlsh -h 127.0.0.3  -U yugabyte -d yugabyte                                   |
      | YCQL                : bin/ycqlsh 127.0.0.3 9042 -u cassandra                                             |
      | Data Dir            : /workspace/ybdb-workshop/ybdb/ybd3/data                                            |
      | Log Dir             : /workspace/ybdb-workshop/ybdb/ybd3/logs                                            |
      | Universe UUID       : b0749440-cf48-4e44-b442-93897dc85450                                               |
      +----------------------------------------------------------------------------------------------------------+
      🚀 YugabyteDB started successfully! To load a sample dataset, try 'yugabyted demo'.
      🎉 Join us on Slack at https://www.yugabyte.com/slack
      👕 Claim your free t-shirt at https://www.yugabyte.com/community-rewards/

      gitpod /workspace/ybdb-workshop ((ws/qs)) $
      ```

    </details>


1. Configure data placement

    ```bash
    yugabyted configure data_placement --fault_tolerance=zone --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd1
    ```

    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted configure data_placement --fault_tolerance=zone --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd1

      +----------------------------------------------------------------------------------------------------+
      |                                             yugabyted                                              |
      +----------------------------------------------------------------------------------------------------+
      | Status                     : Configuration successful.                                             |
      | Fault Tolerance            : Primary Cluster can survive at most any 1 availability zone failure   |
      +----------------------------------------------------------------------------------------------------+

      gitpod /workspace/ybdb-workshop ((ws/qs)) $
      ```

    </details>


2. Quick status check


    ```bash
    yugabyted status --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd1
    ```


    <details>
      <summary>
      Sample Output
      </summary>

      ```bash

      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted status --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd1

      +----------------------------------------------------------------------------------------------------------+
      |                                                yugabyted                                                 |
      +----------------------------------------------------------------------------------------------------------+
      | Status              : Running.                                                                           |
      | Replication Factor  : 3                                                                                  |
      | YugabyteDB UI       : http://127.0.0.1:15433                                                             |
      | JDBC                : jdbc:postgresql://127.0.0.1:5433/yugabyte?user=yugabyte&password=yugabyte                   |
      | YSQL                : bin/ysqlsh   -U yugabyte -d yugabyte                                               |
      | YCQL                : bin/ycqlsh   -u cassandra                                                          |
      | Data Dir            : /workspace/ybdb-workshop/ybdb/ybd1/data                                            |
      | Log Dir             : /workspace/ybdb-workshop/ybdb/ybd1/logs                                            |
      | Universe UUID       : b0749440-cf48-4e44-b442-93897dc85450                                               |
      +----------------------------------------------------------------------------------------------------------+

      gitpod /workspace/ybdb-workshop ((ws/qs)) $

      ```

    </details>


1. Get cluster information via ysqlsh


    ```bash
    ysqlsh -c 'select * from yb_servers();'
    ```


    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ ysqlsh -c 'select * from yb_servers();'
        host    | port | num_connections | node_type |  cloud  | region  | zone | public_ip |               uuid
      -----------+------+-----------------+-----------+---------+---------+------+-----------+----------------------------------
      127.0.0.3 | 5433 |               0 | primary   | ybcloud | pandora | az3  | 127.0.0.3 | 734bf8bef15144ecbc082b69c275e47f
      127.0.0.2 | 5433 |               0 | primary   | ybcloud | pandora | az2  | 127.0.0.2 | 3f4c8c3b423a4e659555839a87280fc5
      127.0.0.1 | 5433 |               0 | primary   | ybcloud | pandora | az1  | 127.0.0.1 | b979f58bda394b649ac6768c5dbfa462
      (3 rows)

      gitpod /workspace/ybdb-workshop ((ws/qs)) $
      ```

    </details>


1. Destroy cluster

    ```bash
    yugabyted destroy --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd1
    yugabyted destroy --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd2
    yugabyted destroy --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd3
    ```


    <details>
      <summary>
      Sample Output
      </summary>

      ```bash
      gitpod /workspace/ybdb-workshop ((ws/qs)) $ yugabyted destroy --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd1
          yugabyted destroy --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd2
          yugabyted destroy --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd3
      Stopped yugabyted using config /workspace/ybdb-workshop/ybdb/ybd1/conf/yugabyted.conf.
      Deleted logs at /workspace/ybdb-workshop/ybdb/ybd1/logs.
      Deleted data at /workspace/ybdb-workshop/ybdb/ybd1/data.
      Deleted conf at /workspace/ybdb-workshop/ybdb/ybd1/conf.
      Stopped yugabyted using config /workspace/ybdb-workshop/ybdb/ybd2/conf/yugabyted.conf.
      Deleted logs at /workspace/ybdb-workshop/ybdb/ybd2/logs.
      Deleted data at /workspace/ybdb-workshop/ybdb/ybd2/data.
      Deleted conf at /workspace/ybdb-workshop/ybdb/ybd2/conf.
      Stopped yugabyted using config /workspace/ybdb-workshop/ybdb/ybd3/conf/yugabyted.conf.
      Deleted logs at /workspace/ybdb-workshop/ybdb/ybd3/logs.
      Deleted data at /workspace/ybdb-workshop/ybdb/ybd3/data.
      Deleted conf at /workspace/ybdb-workshop/ybdb/ybd3/conf.
      gitpod /workspace/ybdb-workshop ((ws/qs)) $
      ```

    </details>


## Access UIs


1. Open the cluster UI  for the database. In the *Ports* tab, open the *yugabyted-ui(15433)* URL.

2. Open the master UI for the database. In the *Ports* tab, open the *yb-master-web(7000)* URL.

3. Open the tserver UI for the database, In the *Ports* tab, open the *yb-tserver-web(9000)* URL.

## Run a sample application - Workload Simulator

1. Run application

    ```bash
    java -jar yb-workload-simulator.jar
    ```



[Back to Workshop Home][home]

[home]: ../../README.md
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
[gp-qs]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws/qs
