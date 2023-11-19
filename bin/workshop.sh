#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_DIR=$(cd $SCRIPT_DIR/..; pwd)
SCRIPT=$0
SCRIPT_NAME=$(basename $SCRIPT)
WS_BRANCHES="$(git branch | grep ws/ |  sed 's/[* ] //')"
YB_VERSION_COMMON=(2.20.0.0 2.19.3.0 2.18.4.2 2.16.8.0 2.14.14.0 2.12.12.0)
YB_VERSION_DEFAULT=${YB_VERSION_COMMON[0]}
YBDB_WORKSHOP_IMAGE_NAME=ybdb-workshop-gitpod-ws
YBDB_WORKSHOP_IMAGE_REGISTRIES=(docker.io/yogendra ghcr.io/yogendra quay.io/yogendra)

function _ybdb_release(){
  version=$1
  curl -sSL https://registry.hub.docker.com/v2/repositories/yugabytedb/yugabyte/tags?name=$version |  grep -Eo "$version-b[0-9]+"
}
YB_RELEASE_DEFAULT=$(_ybdb_release $YB_VERSION_DEFAULT)


function _help(){
  cat <<EOF
YugabyteDB Workshop Intstructor Utility
$SCRIPT_NAME <COMMANDS> [parameters...]

COMAMNDS
  ws-branches-recreate
    recreate workshop branches with latest main branch and copy ws/*/.gitpod.yml to the root for that branch.
    existing branches are deleted. Any unmerged changes will be LOST
    usage
      ws-branches-recreate
    parameters
    example
      ws-branches-recreate

  gitpod-workspace-image-build
    builds docker image for gitpod workspace
      usage
        gitpod-workspace-image-build <yb-version> [registry...]
      parameters
        yb-version - YugabtyeDB version to build image from. It should be in the form A.B.C.D. Example: 2.18.1.0. Default: $YB_VERSION_DEFAULT
        registry   - list of registries. Default: ${YBDB_WORKSHOP_IMAGE_REGISTRIES[*]}
      example

        gitpod-workspace-image-build
        Builds Image(s):  $(printf "%s/$YBDB_WORKSHOP_IMAGE_NAME:$YB_RELEASE_DEFAULT" "${YBDB_WORKSHOP_IMAGE_REGISTRIES[@]}")

        gitpod-workspace-image-build 2.18.1.0
        Builds Image(s) : $(printf "%s/$YBDB_WORKSHOP_IMAGE_NAME:$(_ybdb_release 2.18.1.0)" "${YBDB_WORKSHOP_IMAGE_REGISTRIES[@]}")

        gitpod-workspace-image-build 2.18.1.0 docker.io/my-registry
        Builds Image(s) : docker.io/my-registry/$YBDB_WORKSHOP_IMAGE_NAME:$(_ybdb_release 2.18.1.0)

        gitpod-workspace-image-build 2.18.1.0 docker.io/my-registry ghcr.io/my-registry
        Builds Image(s) : docker.io/my-registry/$YBDB_WORKSHOP_IMAGE_NAME:$(_ybdb_release 2.18.1.0) ghcr.io/my-registry/$YBDB_WORKSHOP_IMAGE_NAME:$(_ybdb_release 2.18.1.0)

  gitpod-workspace-image-build-common-versions
    build docker images for common versions (${YB_VERSION_COMMON[*]})
      usage
        gitpod-workspace-image-build-common-versions
      parameter
      example
        gitpod-workspace-image-build-common-versions

  gitpod-workspace-test-container
    run a container with a workshop docker image
      usage
        gitpod-workspace-test-container [<image>]
      parameter
        image - full image name. Default: ${YBDB_WORKSHOP_IMAGE_REGISTRIES[0]}/${YBDB_WORKSHOP_IMAGE_NAME}:${YB_RELEASE_DEFAULT}
      example
        gitpod-workspace-test-container
        Runs container from image ${YBDB_WORKSHOP_IMAGE_REGISTRIES[0]}/${YBDB_WORKSHOP_IMAGE_NAME}:${YB_RELEASE_DEFAULT}

        gitpod-workspace-test-container ${YBDB_WORKSHOP_IMAGE_REGISTRIES[0]}/${YBDB_WORKSHOP_IMAGE_NAME}:$(_ybdb_release 2.18.1.0)
        Runs a container from image ${YBDB_WORKSHOP_IMAGE_REGISTRIES[0]}/${YBDB_WORKSHOP_IMAGE_NAME}:$(_ybdb_release 2.18.1.0)



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
    _branch-file-update main "$WS_BRANCH/.gitpod.yml" "$WS_BRANCH" ".gitpod.yml"
    git push origin $WS_BRANCH
  done
}

function gitpod-workspace-image-build(){
  version=${1:-$YB_VERSION_DEFAULT}
  image_name=$YBDB_WORKSHOP_IMAGE_NAME
  release=$(_ybdb_release $version)
  image_tag=$release
  export registries=("${YBDB_WORKSHOP_IMAGE_REGISTRIES[@]}")

  if [[ $# -gt 1 ]]; then
    shift
    export registries=("${@}")
  fi

  export tags=""
  export images=()
  for registry in ${registries[@]}
  do
    image=$registry/$image_name:$image_tag
    images+=( "$image" )
    tags="$tags -t $image"
  done

  docker buildx build \
    --build-arg YB_RELEASE=$release \
    --platform linux/x86_64 \
    --push \
    $tags \
    -f .ybdb.Dockerfile \
    $PROJECT_DIR
  echo Images created: ${images[*]}
}

function  gitpod-workspace-test-container(){
  image=${1:-${YBDB_WORKSHOP_IMAGE_REGISTRIES[0]}/${YBDB_WORKSHOP_IMAGE_NAME}:${YB_RELEASE_DEFAULT}};
  docker run --rm -it \
    -p 5433:5433 \
    -p 9042:9042 \
    -p 7000:7000 \
    -p 9000:9000 \
    -p 15433:15433 \
    -p 11000:11000 \
    -p 12000:12000 \
    --name ybdb-gp-ws-test \
    --hostname ybdb-gp-ws-test \
    -v $PWD:/workspace \
    -v $PWD:/home/gitpod/workspace \
    $image \
    bash -l
}

function gitpod-workspace-image-build-common-versions(){
  for YB_VERSION in ${YB_VERSION_COMMON[@]}
  do
    gitpod-workspace-image-build $YB_VERSION "$@"
  done
}

function _branch-file-update(){
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


function _update-gitpod-yml(){
  echo "$WS_BRANCHES" | while read DEST_BRANCH
  do
    branch-file-update main "$DEST_BRANCH/.gitpod.yml" "$DEST_BRANCH" ".gitpod.yml"
  done
}

function _update-dockerfile(){
  _branch-file-update-inplace .ybdb.Dockerfile
}

function _branch-file-update-inplace(){
  file=$1
  echo "$WS_BRANCHES" | while read DEST_BRANCH
  do
    branch-file-update main "$file" "$DEST_BRANCH" "$file"
  done
}

OP=${1:-_help}
[[ $# -gt 0 ]] && shift

$OP "$@"
