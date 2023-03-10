#!/bin/bash
# This script sets up HyperFoil in the openshift cluster and run the load test for the frdemo
# More information about HyperFoil, please look at https://hyperfoil.io/
# Before run this script you need to login openshift cluster.
#
set -euo pipefail

COMMAND="help"
SRCDIR=`dirname "$0"`
HYVERSION=0.23
HYCLIENT=hyperfoil-${HYVERSION}
HYCLIENT_DIR=$SRCDIR/${HYCLIENT}

while (( "$#" )); do
  case "$1" in
    setup|run|help)
      COMMAND=$1
      shift
      ;;
    -*|--*)
      echo "Error: Unknown option $1 "
      exit 1
      ;;
    *)
      echo "Error: Invalid Command $1 "
      exit 1
  esac
done

check_command() {
  fn=$1;
  [[ $(type -t "$fn") == "function" ]]
}
test.help() {
  cat <<-EOF
  frdemo_backend load test tool to set up hyperfoil and run test script.
  NOTE: Before run this script, please login openshift cluster
  Usage:
      loadtest.sh [command] [options]

  Example:
      loadtest.sh setup

  COMMANDS:
      setup             Setup hyperfoil in openshift cluster
      run              Run hyperfoil test script
      help              Print this help message
  OPTIONS:

EOF
}
test.setup() {
  oc apply -f ${SRCDIR}/hyperfoil.yaml
}

test.run() {
  if [ ! -d "$HYCLIENT_DIR" ]
  then
    wget https://github.com/Hyperfoil/Hyperfoil/releases/download/release-${HYVERSION}/hyperfoil-${HYVERSION}.zip
    unzip -o hyperfoil-${HYVERSION}.zip
    rm hyperfoil-${HYVERSION}.zip
  fi
  ###
  ## TODO: ASK HyperFoil team how to get this cli works. It can't pass these flags to cli.sh
  ###
  #${HYCLIENT_DIR}/bin/cli.sh connect $(oc get route hyperfoil --template='http://{{.spec.host}}')
  exec ${HYCLIENT_DIR}/bin/cli.sh
}

info() {
    printf "\n INFO: $@\n"
}

err() {
  printf "\n ERROR: $1\n"
  exit 1
}
main() {
  fn="test.$COMMAND"
  check_command "$fn" || {
    err "Unimplemented command '$COMMAND'"
  }
  $fn
  return $?
}

main