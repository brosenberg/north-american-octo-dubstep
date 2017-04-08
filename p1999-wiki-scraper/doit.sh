#!/bin/bash
set -e
set -u
./p1999wiki.py sort -n | uniq | awk -F~ '{print "|-\n| {{:" $2 "}}\n| [[" $3 "]]\n| " $1;}' > wepprocs-formatted
