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


# Gets the repository path (or what SHOULD be the repo path, unless someone is lying to us, sourcetree)
WD=$(pwd)
#Convert to fw slash so we can concatenate with everything else we are manipulating. This will be reversed later, if it even did anything here
WD=$(echo "$WD" | sed -e "${FWSPATH}")
#In case sourcetree was lying to us and said, for example, the working dir is /usr/blah or /tmp/blah.
WD=$(echo "$WD" | sed -e  "${FIXSYMUSR}")
WD=$(eval echo $(echo "$WD" | sed -e "${FIXSYMTMP}"))

#convert to fw slash if we were backslashed so that stuff downstream will all have a consistent slash scheme. Only convert to winpath before we call lv.
LOCAL=$(echo "$1" | sed -e "${FWSPATH}")
REMOTE=$(echo "$2" | sed -e "${FWSPATH}")

#fix /usr/ and /tmp/ for these variables. I didn't see this issue, but it doesn't hurt.
LOCAL=$(echo "$LOCAL" | sed -e "${FIXSYMUSR}")
REMOTE=$(echo "$REMOTE" | sed -e  "${FIXSYMUSR}")
LOCAL=$(eval echo $(echo "$LOCAL" | sed -e "${FIXSYMTMP}"))
REMOTE=$(eval echo $(echo "$REMOTE" | sed -e  "${FIXSYMTMP}"))

#try to resolve the existence of relative paths, there are situations where paths are given within a few levels of each other
#That is, sourcetree may specify the wd as /tmp/blah/foo, vi A as tmp/blah/foo/1.vi, and vi B as /bar/1.vi, or something else odd
#so what we need to do is take the various paths and do a limited search to see if we can find everything
#what we are looking for is VI B=/tmp/blah/bar/1.vi
#For flexibility, we do this twice.

#if what we think of as $LOCAL doesnt exist...
if [ ! -e "$LOCAL" ]
then
	TEMP=$LOCAL
	REMOTEBASE=$REMOTE
	while [ ! -e "$TEMP" ];	do
	#split off the last path delimiter from REMOTEBASE (ie /blah/foo/1.vi becomes /blah/foo and then /blah)
		LASTBASE=$REMOTEBASE
		REMOTEBASE=${REMOTEBASE%/*}
		#concat the base path with the local path
		TEMP=$REMOTEBASE"/"$LOCAL
		#stop if we've reached something we can't work on, like "/" or "~"
		if [ "$LASTBASE" == "$REMOTEBASE" ]
		then	
			break
		fi
	done
	if [ -e "$TEMP" ]
	then
	#only set this if our TEMP exists...at the very least we want the original for error handling, and maybe we can do something else later.
		LOCAL=$TEMP
	fi
fi

#same as above, but I don't know how to make functions in bash
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

#check if filenames match
#get filename
LOCALFILE=$(basename "$LOCAL")
#strip off everything before the last . (ie what is most likely ".vi" but could be something like ".llb"
EXTENSION=${LOCALFILE##*.}
#strip off last .X
LOCALFILE=${LOCALFILE%.*}
#same for remote except I am assuming extension is the same. If not, I think your scc is magic.
REMOTEFILE=$(basename "$REMOTE")
REMOTEFILE=${REMOTEFILE%.*}

#The shipping lv diff tool can't support two files with the same name because it doesn't open the files in different contexts 
#Opening in different contexts is how the Tools>>compare option works. We're going to have to manipulate the VI names.
if [ "$LOCALFILE" == "$REMOTEFILE" ]
then
	#get dir file is in
	LOCALDIR=$(dirname "$LOCAL")
	#build up new filename, essentially the same as the old one except instead of foo.vi we have foo.3353.vi (where 3353 is a random number)
	#this is a separate value so we can easily determine what we need to do later on.
	LOCALTEMP=$LOCALDIR"/"$LOCALFILE"."$RANDOM"."$EXTENSION
fi

#now that we've done our path manipulation and tried to find our files fix paths to windows
LOCAL=$(echo "$LOCAL" | sed -e "${PATHFIX}")
REMOTE=$(echo "$REMOTE" | sed -e  "${PATHFIX}")


#If we have to, go ahead and fix the path of the temporary file as well
if [ "$LOCALTEMP" != "" ]
then
	LOCALTEMP=$(echo "$LOCALTEMP" | sed -e "${PATHFIX}")
fi

#Unlike in merge, we never fixed the WD path to make it use windows stuff (c:\ vs /c/ and then slash fixes)
WD=$(echo "$WD" | sed -e "${MKWINPATH}")
WD=$(echo "$WD" | sed -e "${PATHFIX}")

# Check if absolute path and complete with working directory if not
echo "$LOCAL" | grep -qE $ABSPATH || LOCAL="${WD}\\${LOCAL}"
echo "$REMOTE" | grep -qE $ABSPATH || REMOTE="${WD}\\${REMOTE}"

#if we have a temp file, do the same
if [ "$LOCALTEMP" != "" ]
then
	echo "$LOCALTEMP" | grep -qE $ABSPATH || LOCALTEMP="${WD}\\${LOCALTEMP}"
fi

#rename original file to the temp file with a random number in the name if we decided we had to earlier
#for ease of coding, store the path we're actually using, whatever it is, in $LOCALACT
LOCALACT=$LOCAL
if [ "$LOCALTEMP" != "" ]
then
	mv "$LOCAL" "$LOCALTEMP"
	LOCALACT=$LOCALTEMP
fi

# Execute Compare
"${LabViewShared}\LabVIEW Compare\LVCompare.exe" "${REMOTE}" "${LOCALACT}" "-lvpath" "${LabViewBin}"

#Since lvcompare.exe exits immediately, give labview time to load the file before you delete it
#there doesn't appear to be any way to check if the diff window exited.
sleep 5

#rename back to the original name so that the scc tool deletes the file
if [ "$LOCALTEMP" != "" ]
then
	mv "$LOCALTEMP" "$LOCAL"
fi
