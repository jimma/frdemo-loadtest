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
CONTROLLER=$(oc get route hyperfoil --template='http://{{.spec.host}}')
OPENSHIFT_SERVER=$(oc get route frdemo --template='https://{{.spec.host}}')
while (( "$#" )); do
  case "$1" in
    setup|run|load|help)
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
      setup            Setup hyperfoil in openshift cluster
      run              Run script to prepare data and load tests
      load             Only run the load test after the data prepared
      help             Print this help message
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
  ###
  #${HYCLIENT_DIR}/bin/cli.sh connect $(oc get route hyperfoil --template='http://{{.spec.host}}')
/usr/bin/expect << EOF
      set timeout 300
      spawn ${HYCLIENT_DIR}/bin/cli.sh
      expect "\[hyperfoil"
      send -- "connect $CONTROLLER\r"
      expect "\[hyperfoil\@"
      send -- "upload frdemo.hf.yaml\r"
      expect "\[hyperfoil\@"
      send -- "upload frdemo-init.hf.yaml\r"
      expect "\[hyperfoil\@"
      send -- "run frdemo-init -PSERVER=${OPENSHIFT_SERVER}\r"
      expect "\[hyperfoil\@"
      send -- "run frdemo -PSERVER=${OPENSHIFT_SERVER}\r"
      expect "\[hyperfoil\@"
      send -- "stats\r"
      expect "\[hyperfoil"
      send -- "exit\r\n"
      expect eof
EOF
}
test.load() {
  if [ ! -d "$HYCLIENT_DIR" ]
  then
    wget https://github.com/Hyperfoil/Hyperfoil/releases/download/release-${HYVERSION}/hyperfoil-${HYVERSION}.zip
    unzip -o hyperfoil-${HYVERSION}.zip
    rm hyperfoil-${HYVERSION}.zip
  fi
  ###
  ###
  #${HYCLIENT_DIR}/bin/cli.sh connect $(oc get route hyperfoil --template='http://{{.spec.host}}')
/usr/bin/expect << EOF
      set timeout 300
      spawn ${HYCLIENT_DIR}/bin/cli.sh
      expect "\[hyperfoil"
      send -- "connect $CONTROLLER\r"
      expect "\[hyperfoil\@"
      send -- "upload frdemo.hf.yaml\r"
      expect "\[hyperfoil\@"
      send -- "run frdemo -PSERVER=${OPENSHIFT_SERVER}\r"
      expect "\[hyperfoil\@"
      send -- "stats\r"
      expect "\[hyperfoil"
      send -- "exit\r\n"
      expect eof
EOF
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