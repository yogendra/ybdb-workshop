# Workshop Instructor Guide

[![Open in Gitpod][logo-gitpod]][gp-workshop] 

This repository has multiple branch. Each branch is setup to be opened in Gitpod.
All workshops are listed on main [README.md](README.md). Main goal is to run everything in workshop on cloud and require almost no local resources.

## Branches

- *main* : Main branch which is central to the workshop. All assets should be created and update on this branch
- *ws/\** : Workshop specific branch.
  - This is needed for keeping *.gitpod.yml*.
  - `.gitpod.yml` is a configu file that has workspace creation settings in it for a repo
  - Gitpod does not have a way of specifying `.gitpod.yml` location in repo.
  - `.gitpod.yml` is required to be in root of the repo.


## How to make changes in a workshops

*DO NOT EDIT workshop branch (ws/\*)*

*DO NOT EDIT workshop branch (ws/\*)*

*DO NOT EDIT workshop branch (ws/\*)*

- You should make change on the main branch for each workshop.
- And recreate the branches. This is easiest way to keep everything clean.
- You could make changes on workspace branch and then merge it on to the main branch before recreating workshop branches

Example:

You want to update the `ws/dsql/README.md` with additional steps, sqls, intructions etc.

- You can open that branch in gitpod
- Make change and test everything
- Merge changes from that branch on to main.
- Change to main branch
- Run `bin/workshop.sh ws-branches-recreate`
  - This will delete all branches locally and on github
  - Recreate all branches from the head
  - On each workspace branch copies `./ws/*/.gitpod.yml` to `./.gitpod.yml`


## How to add a new  workshops

- Add a new folder under `ws/` directory.
- Add a .gitpod.yml file in it.
- You can copy on from the existing workshop for quick start
- Update the [README.md](README.md)
  - Add a row for the new workshop
- Run `bin/workshop.sh ws-branches-recreate` to create workshop


## How to fork this

- Fork [this][repo-workshop] repo, all branch
- Update refs in
  - [README.md](README.md)
  - [README-legacy.md](README-legacy.md)
  - [WORKSHOP-INSTRUCTOR.md](WORKSHOP-INSTRUCTOR.md) (this file)
- Fork this other repos
  - [ybdb-workshop-boot-data][repo-boot-data]
  - [ybdb-workshop-cdc-streams][repo-cdc-streams]
  - [ybdb-workshop-ms-data][repo-ms-data]
  - [ybdb-workshop-sealed-secrets][repo-sealed-secrets]


[gp-workshop]: https://gitpod.io/# https://github.com/yogendra/ybdb-workshop 
[repo-workshop]: https://github.com/yogendra/ybdb-workshop
[repo-boot-data]: https://github.com/yogendra/ybdb-workshop-boot-data
[repo-cdc-streams]: https://github.com/yogendra/ybdb-workshop-cdc-streams
[repo-ms-data]: https://github.com/yogendra/ybdb-workshop-ms-data
[repo-sealed-secrets]: https://github.com/yogendra/ybdb-workshop-sealed-secrets
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
