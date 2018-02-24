#!/bin/sh

LIST=`ls *.txt`
for i in $LIST; do
	echo "=====[$i]====="
	grep -v -E ".+##" $i | grep -v "||" | grep -v -E "^!" | grep -v "domain"
done
