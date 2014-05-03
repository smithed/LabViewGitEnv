#!/bin/bash

# LabView Executable
LabViewBin="C:\Program Files (x86)\National Instruments\LabVIEW 2013\LabVIEW.exe"

# LabView Shared Path for Compare and Merge
LabViewShared="C:\Program Files (x86)\National Instruments\Shared"

#set regex to replace \ by /
FWSPATH='s/\\/\//g'
#Remove leading ./
REMLEADDOT='s/^.\///'
#expand USR
FIXSYMUSR='s/^\/\?[Uu][Ss][Rr]/\/c\/Program Files \(x86\)\/Git/'
#expand TMP
FIXSYMTMP='s/^\/\?[Tt][Mm][Pp]/\/c\/Users\/Daniel\/AppData\/Local\/Temp/'


## DO NOT EDIT FROM HERE ON UNLESS YOU REALLY REALLY KNOW WHAT YOU ARE DOING 

# sed RegEx to replace / by \ in Path
PATHFIX='s/\//\\/g'
# sed RegEx to replace trailing ./ with \
TRAILFIX='s/^.\//\\/'
# Remove ending / or \
ENDFIX='s/[\\/]+$//g'''
# Make Path suitable for Windows (C: instead of /c)
MKWINPATH='s/^\/\([a-z]\)\//\U\1:/'
# Check if Path is abolsute: if either ^/@/ or ^@:\ where @ is the drive letter
ABSPATH='^([a-zA-Z]:\\|/[a-zA-Z]/)'

# Repository directory in windows path notation
WD=$(pwd | sed -e "${ENDFIX}" | sed -e "${MKWINPATH}" | sed -e  "${PATHFIX}")

