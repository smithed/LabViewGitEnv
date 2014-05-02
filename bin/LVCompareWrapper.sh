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


LOCAL=$(echo "$1" | sed -e "${PATHFIX}")
REMOTE=$(echo "$2" | sed -e  "${PATHFIX}")

# Check if absolute path and complete with working directory if not
echo "$LOCAL" | grep -qE $ABSPATH || LOCAL="${WD}\\${LOCAL}"
echo "$REMOTE" | grep -qE $ABSPATH || REMOTE="${WD}\\${REMOTE}"


# Execute Compare
"${LabViewShared}/LabVIEW Compare/LVCompare.exe" "${REMOTE}" "${LOCAL}" "-lvpath" "${LabViewBin}"
