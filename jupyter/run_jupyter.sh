#!/bin/bash

set -e

d=`date +%m-%d-%Y`

RED='\033[0;31m'
CYAN='\033[0;36m'
ORANGE='\033[1;33m'
LT_GREEN='\033[1;32m'
NC='\033[0m' # No Color

NOTEBOOK_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function check_cmd {
  command -v "${1}"
  if ! eval "command -v ${1}" ; then
    echo "${RED}ERROR: ${NC} Didn't find cmd or program or library: ${1}"
    return 1
  else
    return 0
  fi
}



echo "${CYAN}Step 1: ${NC} Checking for uv"
  check_command("uv")
  if [ $? -eq 0 ]; then
    echo "uv installed"
  else
    echo "${RED}ERROR: ${NC} install uv or check previous versions for virtualenv + pip version"
    exit 1;
  fi

echo "${CYAN} --------------------------------------- ${NC}"
echo " To use this kernel and installed libraries with jupyter again,"
echo " run:"
echo "  ${LT_GREEN} uv run --with jupyter jupyter lab ${NC}"
echo "  "
echo "${CYAN} --------------------------------------- ${NC}"

