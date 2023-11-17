#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(cd $SCRIPT_DIR/..; pwd)
SCRIPT=$0
WS_BRANCHES=$(git branch | grep ws- | tr -d ' ')
function workshop-update-gitpod-yml(){
    update-branch-file main init-dsql/.gitpod-dsql.yml ws-dsql .gitpod.yml
    update-branch-file main init-cdc/.gitpod-cdc.yml ws-cdc .gitpod.yml
    update-branch-file main init-ft/.gitpod-ft.yml ws-ft .gitpod.yml
    update-branch-file main init-iloop/.gitpod-iloop.yml ws-iloop .gitpod.yml
    update-branch-file main init-qt/.gitpod-qt.yml ws-qt .gitpod.yml
    update-branch-file main init-scale/.gitpod-scale.yml ws-scale .gitpod.yml
    update-branch-file main init-voyager/.gitpod-voyager.yml ws-voyager .gitpod.yml
}
function workshop-update-dockerfile(){
  workshop-update-file-inplace .ybdb.Dockerfile
}

function workshop-update-file-inplace(){
    file=$1
    echo $WS_BRANCHES | while read DEST_BRANCH
    do
      echo update-branch-file main "$file" "$DEST_BRANCH" "$file"
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

function update-branch-file(){
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

OP=${1:-_help}
if [[ $# -gt 1 ]] ; then shift ; fi

$OP "$@"


