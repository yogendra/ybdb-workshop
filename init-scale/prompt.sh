#!/usr/bin/env bash

. pscript

TYPE_SPEED=50

DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

MSG="Check the load distribution at $(gp url 7000) or $(gp url 15433)!"

clear

PROMPT_TIMEOUT=1

p "Press enter to trigger the scale out task!"

PROMPT_TIMEOUT=0

pe "yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd4 --advertise_address=\$HOST_LB4 --join=\$HOST_LB --cloud_location=ybcloud.pandora.az1 --fault_tolerance=zone"

PROMPT_TIMEOUT=1

p "${MSG}"

p "Press enter to continue"

PROMPT_TIMEOUT=0

pe "yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd5 --advertise_address=\$HOST_LB5 --join=\$HOST_LB --cloud_location=ybcloud.pandora.az2 --fault_tolerance=zone"

PROMPT_TIMEOUT=1

p "${MSG}"

p "Press enter to continue"

PROMPT_TIMEOUT=0

pe "yugabyted start --base_dir=${GITPOD_REPO_ROOT}/ybdb/ybd6 --advertise_address=\$HOST_LB6 --join=\$HOST_LB --cloud_location=ybcloud.pandora.az3 --fault_tolerance=zone"

PROMPT_TIMEOUT=1

p "${MSG}"

p "That's it with the scale out task!"

cmd

p ""
