set -e

SCRIPT_NAME=`basename "$0"`

function log () {
    echo "$SCRIPT_NAME: $@" 1>&2
}
