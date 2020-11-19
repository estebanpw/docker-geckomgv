#!/usr/bin/env bash

INPUT=$1
OUTPUT=$2
CLEAN_REP=0

if [ $# != 2 ]; then
        echo "***ERROR*** Use: $0 INPUT OUTPUT"
        exit -1
fi

echo "Executing Muscle..."

GECKO_DIR=$(pwd)
EXE="${GECKO_DIR}/media/scripts/csvtopng"

$EXE $INPUT $OUTPUT $CLEAN_REP
