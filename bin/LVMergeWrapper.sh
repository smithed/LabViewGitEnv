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

#BASE="${WD}\\$(echo "$1" | sed -e "${TRAILFIX}")"
BASE=$(echo "$1" | sed -e "${REMLEADDOT}")
BASE=$(echo "$BASE" | sed -e "${PATHFIX}")
BASE=$(echo "$BASE" | sed -e "${TRAILFIX}")
BASE="${WD}\\$(echo "$BASE")"
echo $BASE

#THEIRS="${WD}\\$(echo "$2" | sed -e "${TRAILFIX}")"
THEIRS=$(echo "$2" | sed -e "${REMLEADDOT}")
THEIRS=$(echo "$THEIRS" | sed -e "${PATHFIX}")
THEIRS=$(echo "$THEIRS" | sed -e "${TRAILFIX}")
THEIRS="${WD}\\$(echo "$THEIRS")"
echo $THEIRS

#YOURS="${WD}\\$(echo "$3" | sed -e  "${TRAILFIX}")"
YOURS=$(echo "$3" | sed -e "${REMLEADDOT}")
YOURS=$(echo "$YOURS" | sed -e "${PATHFIX}")
YOURS=$(echo "$YOURS" | sed -e "${TRAILFIX}")
YOURS="${WD}\\$(echo "$YOURS")"
echo $YOURS

#MERGED="${WD}\\$(echo "$4" | sed -e  "${TRAILFIX}")"
MERGED=$(echo "$4" | sed -e "${REMLEADDOT}")
MERGED=$(echo "$MERGED" | sed -e "${PATHFIX}")
MERGED=$(echo "$MERGED" | sed -e "${TRAILFIX}")
MERGED="${WD}\\$(echo "$MERGED")"
echo $MERGED



# Execute Compare
"${LabViewShared}\LabVIEW Merge\LVMerge.exe" "${LabViewBin}" "${BASE}" "${THEIRS}" "${YOURS}" "${MERGED}"
