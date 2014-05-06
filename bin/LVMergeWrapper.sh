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

# Repository directory in windows path notation
WD=$(pwd | sed -e "${ENDFIX}" | sed -e "${MKWINPATH}" | sed -e  "${PATHFIX}")

#The following used to have an issue in sourcetree in some cases, where the path would be ./ (remleaddot)
#I think this makes trailfix invalid, but I wasn't sure why it didn't work in the first place so I left it
#Pathfix is then used to make sure any repository relative paths are in windows path notation
#Finally we take the windows form of the working dir and since the relative paths have no leading token, we just concatenate
#This covers issues with ./blah.vi, for example, as well as \folder1\folder2\test.vi


#BASE="${WD}\\$(echo "$1" | sed -e "${TRAILFIX}")"
BASE=$(echo "$1" | sed -e "${REMLEADDOT}")
BASE=$(echo "$BASE" | sed -e "${PATHFIX}")
BASE=$(echo "$BASE" | sed -e "${TRAILFIX}")
BASE="${WD}\\$(echo "$BASE")"

#THEIRS="${WD}\\$(echo "$2" | sed -e "${TRAILFIX}")"
THEIRS=$(echo "$2" | sed -e "${REMLEADDOT}")
THEIRS=$(echo "$THEIRS" | sed -e "${PATHFIX}")
THEIRS=$(echo "$THEIRS" | sed -e "${TRAILFIX}")
THEIRS="${WD}\\$(echo "$THEIRS")"

#YOURS="${WD}\\$(echo "$3" | sed -e  "${TRAILFIX}")"
YOURS=$(echo "$3" | sed -e "${REMLEADDOT}")
YOURS=$(echo "$YOURS" | sed -e "${PATHFIX}")
YOURS=$(echo "$YOURS" | sed -e "${TRAILFIX}")
YOURS="${WD}\\$(echo "$YOURS")"

#MERGED="${WD}\\$(echo "$4" | sed -e  "${TRAILFIX}")"
MERGED=$(echo "$4" | sed -e "${REMLEADDOT}")
MERGED=$(echo "$MERGED" | sed -e "${PATHFIX}")
MERGED=$(echo "$MERGED" | sed -e "${TRAILFIX}")
MERGED="${WD}\\$(echo "$MERGED")"

# Execute Compare
"${LabViewShared}\LabVIEW Merge\LVMerge.exe" "${LabViewBin}" "${BASE}" "${THEIRS}" "${YOURS}" "${MERGED}"

#make sure the tool doesn't delete everything before merge completed
sleep 5