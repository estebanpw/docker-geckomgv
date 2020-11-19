#!/usr/bin/env bash

INPUT=$1
OUTPUT=$2
DND_OUT=$3

if [ $# != 3 ]; then
	echo "***ERROR*** Use: $0 INPUT OUTPUT DNDOUT"
	exit -1
fi

GECKO_DIR=$(pwd)
MUSCLE_BIN="${GECKO_DIR}/media/scripts/muscle_3_8"

$MUSCLE_BIN -in $INPUT -out $OUTPUT.fake -clw -tree2 $DND_OUT



echo "CLUSTAL O(1.2.4) multiple sequence alignment" > $OUTPUT

sed -i 's/\./_/g' $OUTPUT.fake

tail -n +2 $OUTPUT.fake >> $OUTPUT
rm $OUTPUT.fake
