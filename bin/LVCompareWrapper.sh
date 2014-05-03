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
WD=$(pwd)
WD=$(echo "$WD" | sed -e "${FWSPATH}")
WD=$(echo "$WD" | sed -e  "${FIXSYMUSR}")
WD=$(echo "$WD" | sed -e "${FIXSYMTMP}")

#convert to fw slash if we were backslashed--sourcetree fix
LOCAL=$(echo "$1" | sed -e "${FWSPATH}")
REMOTE=$(echo "$2" | sed -e "${FWSPATH}")

#fix /usr and /tmp
LOCAL=$(echo "$LOCAL" | sed -e "${FIXSYMUSR}")
REMOTE=$(echo "$REMOTE" | sed -e  "${FIXSYMUSR}")
LOCAL=$(echo "$LOCAL" | sed -e "${FIXSYMTMP}")
REMOTE=$(echo "$REMOTE" | sed -e  "${FIXSYMTMP}")

#try to resolve the existence of relative paths, there are situations where paths are given within a few levels of each other
if [ ! -e "$LOCAL" ]
then
	TEMP=$LOCAL
	REMOTEBASE=$REMOTE
	while [ ! -e "$TEMP" ];	do
		LASTBASE=$REMOTEBASE
		REMOTEBASE=${REMOTEBASE%/*}
		TEMP=$REMOTEBASE"/"$LOCAL
		if [ "$LASTBASE" == "$REMOTEBASE" ]
		then	
			break
		fi
	done
	if [ -e "$TEMP" ]
	then
		LOCAL=$TEMP
	fi
fi

if [ ! -e "$REMOTE" ]
then
	TEMP=$REMOTE
	LOCALBASE=$LOCAL
	while [ ! -e "$TEMP" ];	do
		LASTBASE=$LOCALBASE
		LOCALBASE=${LOCALBASE%/*}
		TEMP=$LOCALBASE"/"$REMOTE
		if [ "$LASTBASE" == "$LOCALBASE" ]
		then	
			break
		fi
	done
	if [ -e "$TEMP" ]
	then
		REMOTE=$TEMP
	fi
fi

#make sure filenames match
#get filename
LOCALFILE=$(basename "$LOCAL")
#strip off everything before the last .
EXTENSION=${LOCALFILE##*.}
#strip off last .X
LOCALFILE=${LOCALFILE%.*}
#same
REMOTEFILE=$(basename "$REMOTE")
REMOTEFILE=${REMOTEFILE%.*}

#LV can't handle the same file name
if [ "$LOCALFILE" == "$REMOTEFILE" ]
then
	#get dir file is in
	LOCALDIR=$(dirname "$LOCAL")
	#build up new filename
	LOCALTEMP=$LOCALDIR"/"$LOCALFILE"."$RANDOM"."$EXTENSION
fi




#fix paths to windows
LOCAL=$(echo "$LOCAL" | sed -e "${PATHFIX}")
REMOTE=$(echo "$REMOTE" | sed -e  "${PATHFIX}")
if [ "$LOCALTEMP" != "" ]
then
	LOCALTEMP=$(echo "$LOCALTEMP" | sed -e "${PATHFIX}")
fi

WD=$(echo "$WD" | sed -e "${MKWINPATH}")
WD=$(echo "$WD" | sed -e "${PATHFIX}")

# Check if absolute path and complete with working directory if not
echo "$LOCAL" | grep -qE $ABSPATH || LOCAL="${WD}\\${LOCAL}"
echo "$REMOTE" | grep -qE $ABSPATH || REMOTE="${WD}\\${REMOTE}"

if [ "$LOCALTEMP" != "" ]
then
	echo "$LOCALTEMP" | grep -qE $ABSPATH || LOCALTEMP="${WD}\\${LOCALTEMP}"
fi

#rename original file to one with random ext
if [ "$LOCALTEMP" != "" ]
then
	mv "$LOCAL" "$LOCALTEMP"
fi

LOCALVI=$LOCAL
if [ "$LOCALTEMP" != "" ]
then
	LOCALVI=$LOCALTEMP
fi


# Execute Compare
"${LabViewShared}\LabVIEW Compare\LVCompare.exe" "${REMOTE}" "${LOCALVI}" "-lvpath" "${LabViewBin}"
sleep 5

#rename back to scc tool deletes the file
if [ "$LOCALTEMP" != "" ]
then
	mv "$LOCALTEMP" "$LOCAL"
fi
