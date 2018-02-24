#!/bin/sh

LIST=`ls *.txt`
for i in $LIST; do
	echo "=====[$i]====="
	grep -v "##" $i | grep -v "||" | grep -v -E "^!" | grep -v "domain"
done
