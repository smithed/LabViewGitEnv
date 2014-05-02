#!/bin/bash

# Read System wide config
if [ -e /usr/local/etc/LVConfig.sh ]
then
	source /usr/local/etc/LVConfig.sh
fi
# Read User Config
if [ -e ~/etc/LVConfig.sh ]
then
	source ~/etc/LVConfig.sh
fi
# Read Local Config
if [ -e ./LVConfig.sh ]
then
	source ./LVConfig.sh
fi

BASE="${WD}\\$(echo "$1" | sed -e "${TRAILFIX}")"
THEIRS="${WD}\\$(echo "$2" | sed -e "${TRAILFIX}")"
YOURS="${WD}\\$(echo "$3" | sed -e  "${TRAILFIX}")"
MERGED="${WD}\\$(echo "$4" | sed -e  "${TRAILFIX}")"
# Execute Compare
"${LabViewShared}/LabVIEW Merge/LVMerge.exe" "${LabViewBin}" "${BASE}" "${THEIRS}" "${YOURS}" "${MERGED}"
