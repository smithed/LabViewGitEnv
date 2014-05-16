#!/bin/bash -x

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
# Check nearby
if [ -e ../etc/LVConfig.sh ]
then
	source ../etc/LVConfig.sh
fi

# Repository directory in windows path notation
WD=$(toFullWindowsPath $(pwd))

#The following used to have an issue in sourcetree in some cases, where the path would be ./ (remleaddot)
#I think this makes trailfix invalid, but I wasn't sure why it didn't work in the first place so I left it
#Pathfix is then used to make sure any repository relative paths are in windows path notation
#Finally we take the windows form of the working dir and since the relative paths have no leading token, we just concatenate
#This covers issues with ./blah.vi, for example, as well as \folder1\folder2\test.vi

BASE=$1
THEIRS=$2
YOURS=$3
MERGED=$4

BASE=$(toUnpackedLinuxPath "$BASE")
THEIRS=$(toUnpackedLinuxPath "$THEIRS")
YOURS=$(toUnpackedLinuxPath "$YOURS")
MERGED=$(toUnpackedLinuxPath "$MERGED")

BASE=$(toFullWindowsPath "$BASE")
THEIRS=$(toFullWindowsPath "$THEIRS")
YOURS=$(toFullWindowsPath "$YOURS")
MERGED=$(toFullWindowsPath "$MERGED")

BASE=$(addWorkingDir "$BASE" "$WD")
THEIRS=$(addWorkingDir "$THEIRS" "$WD")
YOURS=$(addWorkingDir "$YOURS" "$WD")
MERGED=$(addWorkingDir "$MERGED" "$WD")

# Execute Compare
"${LabViewShared}\LabVIEW Merge\LVMerge.exe" "${LabViewBin}" "${BASE}" "${THEIRS}" "${YOURS}" "${MERGED}"
