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
# Check nearby
if [ -e ../etc/LVConfig.sh ]
then
	source ../etc/LVConfig.sh
fi



# Gets the repository path, local file path, and remote path and converts them to linux paths for processing
WD=$(toUnpackedLinuxPath $(pwd))
LOCAL=$(toUnpackedLinuxPath "$1")
REMOTE=$(toUnpackedLinuxPath "$2")

#try to resolve the existence of relative paths, there are situations where paths are given within a few levels of each other
#That is, sourcetree may specify the wd as /tmp/blah/foo, vi A as tmp/blah/foo/1.vi, and vi B as /bar/1.vi, or something else odd
#so what we need to do is take the various paths and do a limited search to see if we can find everything
#what we are looking for is VI B=/tmp/blah/bar/1.vi
LOCAL=$(resolveRelPath "${LOCAL}" "${REMOTE}")
REMOTE=$(resolveRelPath "${REMOTE}" "${LOCAL}")


#check if filenames match
#get filename
LOCALFILE=$(basename "${LOCAL}")
#strip off everything before the last . (ie what is most likely ".vi" but could be something like ".llb"
EXTENSION=${LOCALFILE##*.}
#strip off last .X
LOCALFILE=${LOCALFILE%.*}
#same for remote except I am assuming extension is the same. If not, I think your scc is magic.
REMOTEFILE=$(basename "${REMOTE}")
REMOTEFILE=${REMOTEFILE%.*}

#The shipping lv diff tool can't support two files with the same name because it doesn't open the files in different contexts 
#Opening in different contexts is how the Tools>>compare option works. We're going to have to manipulate the VI names.
if [ "${LOCALFILE}" == "${REMOTEFILE}" ]
then
	#get dir file is in
	LOCALDIR=$(dirname "${LOCAL}")
	#build up new filename, essentially the same as the old one except instead of foo.vi we have foo.3353.vi (where 3353 is a random number)
	#this is a separate value so we can easily determine what we need to do later on.
	LOCALTEMP="${LOCALDIR}/${LOCALFILE}.${RANDOM}.${EXTENSION}"
fi

#now that we've done our path manipulation and tried to find our files fix paths to windows
WD=$(toFullWindowsPath "${WD}")
LOCAL=$(toFullWindowsPath "${LOCAL}")
REMOTE=$(toFullWindowsPath "${REMOTE}")

#If we have to, go ahead and fix the path of the temporary file as well
if [ "${LOCALTEMP}" != "" ]
then
	LOCALTEMP=$(toFullWindowsPath "${LOCALTEMP}")
fi


# Check if absolute path and complete with working directory if not
LOCAL=$(addWorkingDir "${LOCAL}" "${WD}")
REMOTE=$(addWorkingDir "${REMOTE}" "${WD}")

#if we have a temp file, do the same
if [ "${LOCALTEMP}" != "" ]
then
	LOCALTEMP=$(addWorkingDir "${LOCALTEMP}" "${WD}")
fi

#rename original file to the temp file with a random number in the name if we decided we had to earlier
#for ease of coding, store the path we're actually using, whatever it is, in $LOCALACT
LOCALACT=$LOCAL
if [ "${LOCALTEMP}" != "" ]
then
	mv "${LOCAL}" "${LOCALTEMP}"
	LOCALACT=$LOCALTEMP
fi

# Execute Compare
"${LabViewShared}\LabVIEW Compare\LVCompare.exe" "${REMOTE}" "${LOCALACT}" "-lvpath" "${LabViewBin}"

#Since lvcompare.exe exits immediately, give labview time to load the file before you delete it
#there doesn't appear to be any way to check if the diff window exited.
sleep 5

#rename back to the original name so that the scc tool deletes the file
if [ "${LOCALTEMP}" != "" ]
then
	mv "${LOCALTEMP}" "${LOCAL}"
	LOCALTEMP=$LOCALACT
fi
