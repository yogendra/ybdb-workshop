#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(cd $SCRIPT_DIR/..; pwd)
SCRIPT=$0
WS_BRANCHES="$(git branch | grep ws- | tr -d ' ')"
function update-gitpod-yml(){
  branch-file-update main init-dsql/.gitpod-dsql.yml ws-dsql .gitpod.yml
  branch-file-update main init-cdc/.gitpod-cdc.yml ws-cdc .gitpod.yml
  branch-file-update main init-ft/.gitpod-ft.yml ws-ft .gitpod.yml
  branch-file-update main init-iloop/.gitpod-iloop.yml ws-iloop .gitpod.yml
  branch-file-update main init-qt/.gitpod-qt.yml ws-qt .gitpod.yml
  branch-file-update main init-scale/.gitpod-scale.yml ws-scale .gitpod.yml
  branch-file-update main init-voyager/.gitpod-voyager.yml ws-voyager .gitpod.yml
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

function branch-file-update(){
  SRC_BRANCH=$1;shift
  SRC_FILE=$1; shift
  DEST_BRANCH=$1;shift
  DEST_FILE=$1; shift
  DESC="syncing $SRC_BRANCH/$SRC_FILE to $DEST_BRANCH/$DEST_FILE"

  cbranch=$(git rev-parse --abbrev-ref HEAD)
  git checkout $DEST_BRANCH
  git checkout $SRC_BRANCH $SRC_FILE
  [[ -d $(dirname $DEST_FILE) ]] || mkdir -p $(dirname $DEST_FILE)
  [[ $SRC_FILE == $DEST_FILE ]] || cp $SRC_FILE $DEST_FILE

  if [[ $(git status --porcelain) ]]; then
    git add $SRC_FILE $DEST_FILE
    git commit -m "$DESC"
  else
    echo "$SRC_BRANCH/$SRC_FILE -> $DEST_BRANCH/$DEST_FILE: Skipped - No change"
  fi
  git checkout $cbranch
}
function workshop-branch-asset-updates(){
  echo branch-dir-update main init-dsql/ ws-dsql
  echo branch-dir-update main init-cdc/ ws-cdc
  echo branch-dir-update main init-ft/ ws-ft
  echo branch-dir-update main init-iloop/ ws-iloop
  echo branch-dir-update main init-qt/ ws-qt
  echo branch-dir-update main init-scale/ ws-scale
  echo branch-dir-update main init-voyager/ ws-voyager
}
function branch-dir-update(){
  SRC_BRANCH=$1;shift
  SRC_DIR=$1;shift
  DEST_BRANCH=$1;shift
  DESC="syncing $SRC_BRANCH/$SRC_DIR to $DEST_BRANCH/$SRC_DIR"
  cbranch=$(git rev-parse --abbrev-ref HEAD)

  [[ -d $SRC_DIR ]] || (print $SRC_DIR: not a directory; exit 1)

  git checkout $DEST_BRANCH
  git checkout $SRC_BRANCH $SRC_DIR
  if [[ $(git status --porcelain) ]]; then
    git add $SRC_DIR
    git commit -m "$DESC"
  else
    echo "$SRC_BRANCH/$SRC_DIR -> $DEST_BRANCH/$DEST_DIR: Skipped - No change"
  fi
}

OP=${1:-_help}
if [[ $# -gt 1 ]] ; then shift ; fi

$OP "$@"


