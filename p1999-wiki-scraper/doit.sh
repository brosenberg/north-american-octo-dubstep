#!/bin/bash
set -e
set -u
./p1999wiki.py > wepprocs.raw
sort -n wepprocs.raw | uniq | awk -F~ '{print "|-\n| {{:" $2 "}}\n| [[" $3 "]]\n| " $1 "\n| " $4;}' > wepprocs.formatted
