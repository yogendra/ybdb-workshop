# ybdb-vanguard

## Pre-requisites
- github.com account
- gitpod.io account
- git cli (https://github.com/git-guides/install-git)

## Setup
- Fork this repo
- Run `git clone https://github.com/[REPLACE_REPO_NAME]/ybdb-vanguard.git` to clone the forked repo to the local workstation
- Run `cd ybdb-vanguard` to change the directory to the cloned repo

## Getting Started with Gitpod:
[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/from-referrer/)

## Into the distributed sql and postgres++ universe
[distributed sql:](init-dsql/README.md)
This will help you get started with yugabyte db and explore the distributed sql universe.

```bash
cp init-dsql/.gitpod-dsql.yml .gitpod.yml
git add .gitpod.yml
git commit -m "dsql base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Query tuning tips and tricks
[sql universe:](init-qt/README.md)
This will help you get started with query tuning and have a better understanding of the distributed sql universe.

```bash
cp init-qt/.gitpod-qt.yml .gitpod.yml
git add .gitpod.yml
git commit -m "qt base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Development innerloop workflow
[inner loop:](init-iloop/README.md)
This will explore the development innerloop workflow and guide bulding an application from scratch. This provides a hands-on experience of interacting with yugabyte db.

```bash
cp init-iloop/.gitpod-iloop.yml .gitpod.yml
git add .gitpod.yml
git commit -m "il base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Java microservices
[java microservices:](https://github.com/srinivasa-vasu/yb-ms-data)
This will explore the java microservices like spring boot, quarkus, and micronaut integration with yugabytedb.

## Java testcontainers
[testcontainers:](https://github.com/srinivasa-vasu/ybdb-boot-data)
This will explore the java testcontainers integration with yugabytedb.

## Data migration workflow from mysql to ybdb
[voyager:](init-voyager/README.md)
This will explore the voyager tool to migrate mysql to yugabytedb.

```bash
cp init-voyager/.gitpod-voyager.yml .gitpod.yml
git add .gitpod.yml
git commit -m "voyager base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Change data capture(CDC) workflow from ybdb to postgres
[cdc:](init-cdc/README.md)
This will explore yugabytedb's change data capture.

```bash
cp init-cdc/.gitpod-cdc.yml .gitpod.yml
git add .gitpod.yml
git commit -m "cdc base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Change data capture(CDC) streaming workflow from ysql to ycql
[cdc-stream:](https://github.com/srinivasa-vasu/yb-cdc-streams)
This will explore spring cloud stream microservices based cdc integration from ysql to ycql through a supplier-processor-consumer pattern.

## Data distribution and scalability
[scale out:](init-scale/README.md)
This will explore yugabytedb's data distribution and horizontal scalability.

```bash
cp init-scale/.gitpod-scale.yml .gitpod.yml
git add .gitpod.yml
git commit -m "scale base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.

## Data replication, fault tolerance and high availability
[chaos engineering:](init-ft/README.md)
This will explore yugabytedb's fault tolerance and high availability.

```bash
cp init-ft/.gitpod-ft.yml .gitpod.yml
git add .gitpod.yml
git commit -m "ft base"
git push origin main
```
Launch the repo using [Open in Gitpod](#getting-started-with-gitpod) action.
