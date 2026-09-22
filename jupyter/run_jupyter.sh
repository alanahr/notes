#!/bin/bash

set -e

d=`date +%m-%d-%Y`

RED='\033[0;31m'
CYAN='\033[0;36m'
ORANGE='\033[1;33m'
LT_GREEN='\033[1;32m'
NC='\033[0m' # No Color

NOTEBOOK_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

LOG_DIR="${NOTEBOOK_DIR}/logs"
PY_LIB="python3"
PY_PATH="/opt/homebrew/bin/python3"
PY_BREW_LIB="python@3.9"

function check_cmd {
  command -v "${1}"
  if ! eval "command -v ${1}" ; then
    echo "${RED}ERROR: ${NC} Didn't find cmd or program or library: ${1}"
    return 1
  else
    return 0
  fi
}

function check_path {
  has_matches=`echo $PATH | grep -c "${1}"`
  if [[ $has_matches -gt 0 ]] ; then
    return 1
  else
    return 0
  fi
}

function check_running_processes {
  has_matches=`ps -ef | grep -c "${1}"`
  return $has_matches
}

echo "${CYAN}Step 1: ${NC} Getting python info"
py_ver_check=`$PY_LIB -c 'import sys; print("{0}.{1}".format(sys.version_info[0:][0],sys.version_info[1:][0]))'`
echo $py_ver_check
echo "${PY_LIB:6:3}"
if [[ $py_ver_check != "${PY_LIB:6:3}" ]]; then
  echo "${ORANGE}WARNING: ${NC} python version does not match."
fi

echo "${CYAN}Step 2: ${NC} Checking for existing virtual environment directory named jupyter-env by checking for existing directory with -d ( or you can use ls -a to view hidden .* files)"
if [ -d "${NOTEBOOK_DIR}/jupyter-env" ]; then
  echo "${ORANGE}WARNING: ${NC} jupyter-env exists already. "
  read -p "Enter y to delete it and continue, any other key to exit " yn
  case $yn in
      [Yy]* ) rm -r "${NOTEBOOK_DIR}/jupyter-env";;
      * ) exit 1;;
  esac
fi

echo "${CYAN}Step 3:${NC} Checking if existing virtual environment activated"
echo $VIRTUAL_ENV
if [[ $VIRTUAL_ENV != "" ]]; then
  echo "${RED}ERROR: ${NC} Existing virtual environment in this instance found"
  echo "  Check the VIRTUAL_ENV environment variable to figure out where it is"
  echo "  then go there and run deactivate"
  echo "  then try running this script again."
  exit 1;
fi

echo "${CYAN}Step 4:${NC} Creating and activating a virtual environment (path: jupyter-env)"

cd "${NOTEBOOK_DIR}" && "${PY_PATH}" -m venv "${NOTEBOOK_DIR}/jupyter-env"
cd "${NOTEBOOK_DIR}" && source "${NOTEBOOK_DIR}/jupyter-env/bin/activate"
if [[ $VIRTUAL_ENV != "" ]]; then
  echo "created and activated virtual env (see the VIRTUAL_ENV environment variable)"
else
  echo "${RED}ERROR: ${NC} error creating and activating the virtual env"
  exit 1;
fi


echo "${CYAN}Step 5: ${NC} Installing pip requirements for jupyter and making kernel"
"${VIRTUAL_ENV}/bin/pip" -v install ipykernel 2>&1 | tee -a  "${NOTEBOOK_DIR}/pip-installs.log"
if [ $? -eq 0 ]; then
  echo "pip install of ipykernel finished successfully, now creating kernel"
else
  echo "${RED}ERROR: ${NC} error installing ipykernel"
  exit 1;
fi

"${VIRTUAL_ENV}/bin/python" -m ipykernel install --user --name=jupyter-env
if [ $? -eq 0 ]; then
  echo "jupyter-env kernel created successfully"
else
  echo "${RED}ERROR: ${NC} error creating kernel"
  exit 1;
fi


echo "${CYAN}Step 6: ${NC} Installing other pip requirements"
if [ -f "${NOTEBOOK_DIR}/requirements.txt" ]; then
  "${VIRTUAL_ENV}/bin/pip" -v install -r "${NOTEBOOK_DIR}/requirements.txt" 2>&1 | tee -a  "${NOTEBOOK_DIR}/pip-installs.log"
  if [ $? -eq 0 ]; then
    echo "pip install of requirements.txt finished successfully"
    "${VIRTUAL_ENV}/bin/pip" list > "${NOTEBOOK_DIR}/pip-list.log"
  else
    echo "${RED}ERROR: ${NC} error installing the pip requirements"
    exit 1;
  fi
else
  echo "${ORANGE}WARNING: ${NC} no requirements.txt file found-- double-check your imports"
fi
echo "Done with all setup steps for ${NOTEBOOK_DIR}/jupyter-env and virtual env ${VIRTUAL_ENV}."


echo "${CYAN} --------------------------------------- ${NC}"
echo " To use this kernel and installed libraries with jupyter again,"
echo " cd  to ${NOTEBOOK_DIR}, then enter the command:"
echo "  ${LT_GREEN} source jupyter-env/bin/activate ${NC}"
echo "  To exit the virtual environment, just type ${LT_GREEN} deactivate ${NC}"
echo "${CYAN} --------------------------------------- ${NC}"

echo "${ORANGE}Would you like to run jupyter lab now?${NC}"
read -p " Enter y to run it, any other key to exit." yn
case $yn in
    [Yy]* ) jupyter lab;;
    * ) echo "Goodbye!" && exit 1;;
esac
