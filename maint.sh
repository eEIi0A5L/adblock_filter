#!/bin/sh

LIST=`ls *.txt`
for i in $LIST; do
	echo "=====[$i]====="
	grep -v -E "##" $i | grep -v "||" | grep -v -E "^[ \t]*!" | grep -v "domain" | grep -v "#@#" | grep -v -E "^$"
done
