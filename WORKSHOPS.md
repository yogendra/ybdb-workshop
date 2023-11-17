# YugabyteDB Immersion Workshops

## Pre-requisites
- github.com account
- gitpod.io account
- git cli (https://github.com/git-guides/install-git)



| Audience                           | Workshop Description                                          | Open in Gitpod                                       |
| ---------------------------------- | ------------------------------------------------------------- | ---------------------------------------------------- |
| ![Dev][badge-dev]![Ops][badge-ops] | Distributed SQL Demo                                          | [![Open in Gitpod][logo-gitpod]][branch-dsql]        |
| ![Dev][badge-dev]![Ops][badge-ops] | Query Tuning Tricks                                           | [![Open in Gitpod][logo-gitpod]][branch-qt]          |
| ![Dev][badge-dev]                  | Development Inner Loop                                        | [![Open in Gitpod][logo-gitpod]][branch-iloop]       |
| ![Dev][badge-dev]                  | Java Microservice                                             | [![Open in Gitpod][logo-gitpod]][repo-ms-data]       |
| ![Dev][badge-dev]                  | Java testcontainers                                           | [![Open in Gitpod][logo-gitpod]][repo-boot-data]     |
| ![Dev][badge-dev]                  | Securing Spring Boot Microservices                            | [![Open in Gitpod][logo-gitpod]][repo-sealed-secret] |
| ![Dev][badge-dev]![Ops][badge-ops] | Data migration workflow from mysql to ybdb                    | [![Open in Gitpod][logo-gitpod]][branch-voyager]     |
| ![Dev][badge-dev]![Ops][badge-ops] | Change data capture(CDC) workflow from ybdb to postgres       | [![Open in Gitpod][logo-gitpod]][branch-cdc]         |
| ![Dev][badge-dev]                  | Change data capture(CDC) streaming workflow from ysql to ycql | [![Open in Gitpod][logo-gitpod]][repo-cdc-streams]   |
| ![Ops][badge-ops]                  | Data distribution and scalability                             | [![Open in Gitpod][logo-gitpod]][branch-scale]       |
| ![Ops][badge-ops]                  | Data replication, fault tolerance and high availability       | [![Open in Gitpod][logo-gitpod]][branch-ft]          |

[badge-dev]: https://img.shields.io/badge/dev-orange?style=for-the-badge
[badge-ops]: https://img.shields.io/badge/ops-blue?style=for-the-badge
[branch-cdc]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws-cdc
[branch-dsql]: https://gitpod.io/https://github.com/yogendra/ybdb-workshop/tree/ws-dsql
[branch-ft]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws-ft
[branch-iloop]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws-iloop
[branch-main]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/main
[branch-qt]: https://gitpod.io/https://github.com/yogendra/ybdb-workshop/tree/ws-qt
[branch-scale]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws-scale
[branch-voyager]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws-voyager
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
[repo-boot-data]:https://gitpod.io/#https://github.com/yogendra/ybdb-workshop-boot-data
[repo-cdc-streams]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop-cdc-streams
[repo-ms-data]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop-ms-data
[repo-sealed-secret]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop-sealed-secrets




## Setup
- Fork this repo
- Run `git clone https://github.com/srinivasa-vasu/ybdb-vanguard.git` to clone the forked repo to the local workstation
- Run `cd ybdb-vanguard` to change the directory to the cloned repo

## Getting Started with Gitpod:
[![Open in Gitpod][logo-gitpod]][branch-main]

## Into the distributed and postgres++ sql universe
<div align="left">

![Dev][badge-dev]
![Ops][badge-ops]
</div>

[distributed sql:](init-dsql/README.md)
This will help you get started with yugabyte db and explore the distributed sql universe.

```bash
yes | cp init-dsql/.gitpod-dsql.yml .gitpod.yml
git add .gitpod.yml
git commit -sm "dsql base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Query tuning tips and tricks
<div align="left">

![Dev][badge-dev]
![Ops][badge-ops]
</div>

[sql universe:](init-qt/README.md)
This will help you get started with query tuning and have a better understanding of the distributed sql universe.

```bash
yes | cp init-qt/.gitpod-qt.yml .gitpod.yml
git add .gitpod.yml
git commit -sm "qt base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Development innerloop workflow
<div align="left">

![Dev][badge-dev]
</div>

[inner loop:](init-iloop/README.md)
This will explore the development innerloop workflow and guide bulding an application from scratch. This provides a hands-on experience of interacting with yugabyte db.

```bash
yes | cp init-iloop/.gitpod-iloop.yml .gitpod.yml
git add .gitpod.yml
git commit -sm "il base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Java microservices
<div align="left">

![Dev][badge-dev]
</div>

[java microservices:](https://github.com/srinivasa-vasu/yb-ms-data)
This will explore the java microservices like spring boot, quarkus, and micronaut integration with yugabytedb.

## Java testcontainers
<div align="left">

![Dev][badge-dev]
</div>

[testcontainers:](https://github.com/srinivasa-vasu/ybdb-boot-data)
This will explore the java testcontainers integration with yugabytedb.

## Securing Spring Boot Microservices
<div align="left">

![Dev][badge-dev]
</div>

[secure by default:](https://github.com/srinivasa-vasu/ybdb-sealed-secrets)
This will explore securing Spring Boot application with YugabyteDB over TLS using the native cloud secret management services

## Data migration workflow from mysql to ybdb
<div align="left">

![Dev][badge-dev]
![Ops][badge-ops]
</div>

[voyager:](init-voyager/README.md)
This will explore the voyager tool to migrate mysql to yugabytedb.

```bash
yes | cp init-voyager/.gitpod-voyager.yml .gitpod.yml
git add .gitpod.yml
git commit -sm "voyager base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Change data capture(CDC) workflow from ybdb to postgres
<div align="left">

![Dev][badge-dev]
![Ops][badge-ops]
</div>

[cdc:](init-cdc/README.md)
This will explore yugabytedb's change data capture.

```bash
yes | cp init-cdc/.gitpod-cdc.yml .gitpod.yml
git add .gitpod.yml
git commit -sm "cdc base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Change data capture(CDC) streaming workflow from ysql to ycql
<div align="left">

![Dev][badge-dev]
</div>

[cdc-stream:](https://github.com/srinivasa-vasu/yb-cdc-streams)
This will explore spring cloud stream microservices based cdc integration from ysql to ycql through a supplier-processor-consumer pattern.

## Data distribution and scalability
<div align="left">

![Ops][badge-ops]
</div>

[scale out:](init-scale/README.md)
This will explore yugabytedb's data distribution and horizontal scalability.

```bash
yes | cp init-scale/.gitpod-scale.yml .gitpod.yml
git add .gitpod.yml
git commit -sm "scale base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Data replication, fault tolerance and high availability
<div align="left">

![Ops][badge-ops]
</div>

[chaos engineering:](init-ft/README.md)
This will explore yugabytedb's fault tolerance and high availability.

```bash
yes | cp init-ft/.gitpod-ft.yml .gitpod.yml
git add .gitpod.yml
git commit -sm "ft base"
git push origin main
```
