#!/bin/bash

# LabView Executable, relative to mingw path $PROGRAMFILES=C:\Program Files (x86)\
LabViewBin="${PROGRAMFILES}\National Instruments\LabVIEW 2013\LabVIEW.exe"

# LabView Shared Path for Compare and Merge $PROGRAMFILES=C:\Program Files (x86)\
LabViewShared="${PROGRAMFILES}\National Instruments\Shared"


#set regex to replace \ by /
FWSPATH='s/\\/\//g'
#Remove leading ./
REMLEADDOT='s/^.\///'
#expand USR
FIXSYMUSR='s/^\/\?[Uu][Ss][Rr]/\/c\/Program Files \(x86\)\/Git/'
#expand TMP
#FIXSYMTMP='s/^\/\?[Tt][Mm][Pp]/\/c\/Users\/(USERNAME)\/AppData\/Local\/Temp/'
#This version is dynamic, but requires you to call <VAR>=$(eval echo $<VAR>) after running the SED to expand the $HOME var. May be a better way but this seems to work
FIXSYMTMP='s/^\/\?[Tt][Mm][Pp]/$HOME\/AppData\/Local\/Temp/'


## DO NOT EDIT FROM HERE ON UNLESS YOU REALLY REALLY KNOW WHAT YOU ARE DOING 

# sed RegEx to replace / by \ in Path
PATHFIX='s/\//\\/g'
# sed RegEx to replace trailing ./ with \
#TRAILFIX='s/^.\//\\/'
# Remove ending / or \
ENDFIX='s/[\\/]+$//g'''
# Make Path suitable for Windows (C: instead of /c)
#--This now also ensures that we have something that looks like /c/, rather than just /c. This caused an issue with unexpected paths (like /TMP/->T:/MP)
MKWINPATH='s/^\/\([a-z]\)\//\U\1:\//'
# Check if Path is abolsute: if either ^/@/ or ^@:\ where @ is the drive letter
ABSPATH='^([a-zA-Z]:\\|/[a-zA-Z]/)'
#Has ./
REGLOCALDIR='^\.\/'


toUnpackedLinuxPath ()
{
tPath=$1

#Convert to fw slash so we can concatenate with everything else we are manipulating. This will be reversed later, if it even did anything here
tPath=$(echo "${tPath}" | sed -e "${FWSPATH}")

#In case sourcetree was lying to us and said, for example, the working dir is /usr/blah or /tmp/blah.
#TEMP should happen first because the eval causes issues with program files (x86)
#should find a better way of doing this
tPath=$(echo "${tPath}" | sed -e "${FIXSYMTMP}")
tPath=$(eval echo "${tPath}")
tPath=$(echo "${tPath}" | sed -e  "${FIXSYMUSR}")

#fix ./* and replace with PWD/*
TEMPVAR=""
echo "${tPath}" | grep -qE $REGLOCALDIR || TEMPVAR="OK"
if [ "$TEMPVAR" != "OK" ]
then
	tPath=$(echo "${tPath}" | sed -e "${REMLEADDOT}")
	tPath="$(pwd)/${tPath}"
fi


#return
echo ${tPath}
}

toFullWindowsPath ()
{
tPath=$1

#convert any full path /c/ to c:\ (must happen before converting to bslash)
tPath=$(echo "${tPath}" | sed -e  "${MKWINPATH}")

#Convert to backslash fix paths to windows
tPath=$(echo "${tPath}" | sed -e "${PATHFIX}")

#return
echo ${tPath}
}

addWorkingDir ()
{
tPath=$1
WD=$2
#remove ending /\
WD=$(echo "$WD" | sed -e "${ENDFIX}")
echo "${tPath}" | grep -qE $ABSPATH || tPath="${WD}\\${tPath}"
echo ${tPath}
}

resolveRelPath ()
{
tPath=$1
tRelPath=$2
if [ ! -e "${tPath}" ]
then
	TEMP=${tPath}
	RELBASE=$tRelPath
	while [ ! -e "${TEMP}" ];	do
	#split off the last path delimiter from RELBASE (ie /blah/foo/1.vi becomes /blah/foo and then /blah)
		LASTBASE=$RELBASE
		RELBASE=${RELBASE%/*}
		#concat the base path with the local path
		TEMP="${RELBASE}/${tPath}"
		#stop if we've reached something we can't work on, like "/" or "~"
		if [ "$LASTBASE" == "$RELBASE" ]
		then	
			break
		fi
	done
	if [ -e "$TEMP" ]
	then
	#only set this if our TEMP exists...at the very least we want the original for error handling, and maybe we can do something else later.
		tPath="${TEMP}"
	fi
fi
echo "${tPath}"
}
