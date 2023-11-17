#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(cd $SCRIPT_DIR/..; pwd)
SCRIPT=$0
WS_BRANCHES="$(git branch | grep ws/ |  sed 's/[* ] //')"

function update-gitpod-yml(){
  echo "$WS_BRANCHES" | while read DEST_BRANCH
  do
    branch-file-update main "$DEST_BRANCH/.gitpod.yml" "$DEST_BRANCH" ".gitpod.yml"
  done
}
function update-dockerfile(){
  branch-file-update-inplace .ybdb.Dockerfile
}

function branch-file-update-inplace(){
  file=$1
  echo "$WS_BRANCHES" | while read DEST_BRANCH
  do
    branch-file-update main "$file" "$DEST_BRANCH" "$file"
  done
}

function _help(){
  cat <<EOF
YugabyteDB Workshop Intstructor Utility
$SCRIPT <COMMANDS> [parameters...]

COMAMNDS
  workshop-update-gitpod-yml - helps in updating workshop in the branches
EOF
}
function ws-branches-recreate(){
  echo "$WS_BRANCHES" | while read WS_BRANCH
  do
    git branch -D $WS_BRANCH
    git push origin -d $WS_BRANCH
  done

  find ws -type d | grep -v 'ws$' | while read WS_BRANCH
  do
    git branch $WS_BRANCH
    branch-file-update main "$WS_BRANCH/.gitpod.yml" "$WS_BRANCH" ".gitpod.yml"
    git push origin $WS_BRANCH
  done
}
function workshop-branch-asset-updates(){
  echo "$WS_BRANCHES" | while read DEST_BRANCH
  do
    echo branch-dir-update main $DEST_BRANCH $DEST_BRANCH
  done
}
function branch-file-update(){
  SRC_BRANCH=$1;shift
  SRC_FILE=$1; shift
  DEST_BRANCH=$1;shift
  DEST_FILE=$1; shift
  DESC="syncing [$SRC_BRANCH]:$SRC_FILE to [$DEST_BRANCH]:$DEST_FILE"

  cbranch=$(git rev-parse --abbrev-ref HEAD)
  git checkout $DEST_BRANCH
  git checkout $SRC_BRANCH $SRC_FILE
  [[ -d $(dirname $DEST_FILE) ]] || mkdir -p $(dirname $DEST_FILE)
  [[ $SRC_FILE == $DEST_FILE ]] || cp $SRC_FILE $DEST_FILE

  if [[ $(git status --porcelain) ]]; then
    git add $SRC_FILE $DEST_FILE
    git commit -m "$DESC"
  else
    echo "[$SRC_BRANCH]:$SRC_FILE -> [$DEST_BRANCH]:/$DEST_FILE :: Skipped - No change"
  fi
  git checkout $cbranch
}
function branch-dir-update(){
  SRC_BRANCH=$1;shift
  SRC_DIR=$1;shift
  DEST_BRANCH=$1;shift
  DESC="syncing [$SRC_BRANCH]$SRC_DIR to [$DEST_BRANCH]$SRC_DIR"
  cbranch=$(git rev-parse --abbrev-ref HEAD)

  [[ -d $SRC_DIR ]] || (print $SRC_DIR: not a directory; exit 1)

  git checkout $DEST_BRANCH
  git checkout $SRC_BRANCH $SRC_DIR
  if [[ $(git status --porcelain) ]]; then
    git add $SRC_DIR
    git commit -m "$DESC"
  else
    echo "[$SRC_BRANCH]:$SRC_DIR -> [$DEST_BRANCH]:$DEST_DIR: Skipped - No change"
  fi
}

OP=${1:-_help}
if [[ $# -gt 1 ]] ; then shift ; fi

$OP "$@"


