## Data sharding and horizontal scalability

[Back to Workshop Home][home]

[![Open in Gitpod][logo-gitpod]][gp-scale-v2]

- Open the workload-simulator url (from the ports tab)
- Click on the *three bar* menu on top-left
- On the dialog > Usable Operations
  - Select "Create Tables"
  - Click "Run Create Table Workload"
  - Wait for the workload run to finish in background
  - Select on "Seed Data"
  - Click "Run Seed Data Workload"
  - Wait for the workload run to finish in background
  - Select "Simulation"
  - Click "Run Simulation Workload"
  - Close the dialog
  - Observe the Latency and Throughput graph
- Run the DB scale out task via `ybdb-scale` shell
  - After each scale command, see the network graph updated in workload simulator

[Back to Workshop Home][home]

[home]: ../../README.md
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
[gp-scale-v2]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws/scale-v2
