# Workshop Instructor Guide


[![Open in Gitpod][logo-gitpod]][gp-workshop]

- This is a central repository for all experience workshops for YugabyteDB.
- All workshops are designed to be self contained and run on [gitpod](https://gitpod.io).
- Every workshop should be run in their own gitpod workspace.
- Attendees should launch workshops from the [README.md](README.md) page


## Tags

- *main* : Main branch which is central to the workshop. All assets should be created and update on
- *ws/\** : Workshop specific tag.
  - This is needed for keeping *.gitpod.yml*
  - `.gitpod.yml` is a configuration file that has workspace creation settings in it for a repo
  - Gitpod does not have a way of specifying `.gitpod.yml` location in repo.
  - `.gitpod.yml` is required to be in root of the repo.


## How to make changes in a workshops

- You should make change on ws/* folder for each workshop
- Ones all the changes are done, run `bin/workshop.sh prepare` to arrange the tags properly

Example

Objective: Update instructions for dsql lab.
Steps:
1. Open the repository on gitpod.
2. Open the `ws/dsql/README.md` and make changes
   1. Optionally, test all the changes

- Run `bin/workshop.sh prepare`
  - This will copy `ws/*/.gitpod.yml` to `.gitpod.yml`
  - Adds it to the git and commits
  - Moves the `ws/*` tag
  - Pushes commits and tags to git repo
  - Recreate all branches from the head
  - On each workspace branch copies `./ws/*/.gitpod.yml` to `./.gitpod.yml`


## How to add a new  workshops

- A workshop can be designed under `ws/` folder
  - It should have at least two files:
    - `.gitpod.yml` - Gitpod workspace config file.
    - `README.md` - Workshop instructions
  - Any other assets (sql files, docker compose file, etc.)
  - You can copy on from the existing workshop for quick start
- Update the [README.md](README.md)
  - Add a link  at the bottom

      ```md
      [gp-myws]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop/tree/ws/myws
      [doc-myws]: ws/myws/README.md
      ```

  - Add a row for the new workshop

      ```md
      | ![Ops][badge-ops] | [My Workshop][doc-myws] | [![Open in Gitpod][logo-gitpod]][gp-myws] |
      ```

      Add badge as per the workshop target audience
- Run `bin/workshop.sh prepare` to setup the tags


## How to fork this repository

- Fork [this][repo-workshop] repo, all branch
- Update github repository refs in
  - [README.md](README.md)
  - [README-legacy.md](README-legacy.md)
  - [WORKSHOP-INSTRUCTOR.md](WORKSHOP-INSTRUCTOR.md) (this file)
  - If you build a custom image, update image reference in all .gitpod.yml
- Fork this other repos
  - [ybdb-workshop-boot-data][repo-boot-data]
  - [ybdb-workshop-cdc-streams][repo-cdc-streams]
  - [ybdb-workshop-ms-data][repo-ms-data]
  - [ybdb-workshop-sealed-secrets][repo-sealed-secrets]


[gp-workshop]: https://gitpod.io/#https://github.com/yogendra/ybdb-workshop
[repo-workshop]: https://github.com/yogendra/ybdb-workshop
[repo-boot-data]: https://github.com/yogendra/ybdb-workshop-boot-data
[repo-cdc-streams]: https://github.com/yogendra/ybdb-workshop-cdc-streams
[repo-ms-data]: https://github.com/yogendra/ybdb-workshop-ms-data
[repo-sealed-secrets]: https://github.com/yogendra/ybdb-workshop-sealed-secrets
[logo-gitpod]: https://gitpod.io/button/open-in-gitpod.svg
