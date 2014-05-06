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
FIXSYMTMP='s/^\/\?[Tt][Mm][Pp]/${HOME}\/AppData\/Local\/Temp/'



## DO NOT EDIT FROM HERE ON UNLESS YOU REALLY REALLY KNOW WHAT YOU ARE DOING 

# sed RegEx to replace / by \ in Path
PATHFIX='s/\//\\/g'
# sed RegEx to replace trailing ./ with \
TRAILFIX='s/^.\//\\/'
# Remove ending / or \
ENDFIX='s/[\\/]+$//g'''
# Make Path suitable for Windows (C: instead of /c)
#--This now also ensures that we have something that looks like /c/, rather than just /c. This caused an issue with unexpected paths (like /TMP/->T:/MP)
MKWINPATH='s/^\/\([a-z]\)\//\U\1:/'
# Check if Path is abolsute: if either ^/@/ or ^@:\ where @ is the drive letter
ABSPATH='^([a-zA-Z]:\\|/[a-zA-Z]/)'
