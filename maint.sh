#!/bin/bash

function sub()
{
	FILE=$1
	echo "----$FILE"
	#grep -v -E "##" $i | grep -v "||" | grep -v -E "^[ \t]*!" | grep -v "domain" | grep -v "#@#" | grep -v -E "^$"
	while IFS=$'\r' read line; do
		if [[ $line =~ \#\# ]]; then
			continue
		fi
		if [[ $line =~ ^\r\n ]]; then
			continue
		fi
		if [[ $line =~ ^$ ]]; then
			continue
		fi
		if [[ $line =~ ^\[Adblock ]]; then
			continue
		fi
		if [[ $line =~ \|\| ]]; then
			continue
		fi
		#if [[ $line =~ ^\[ \\t\]\*\! ]]; then
		regexp='!'
		if [[ $line =~ $regexp ]]; then
			continue
		fi
		if [[ $line =~ domain ]]; then
			continue
		fi
		if [[ $line =~ \#@\# ]]; then
			continue
		fi
		#echo "[$line]"
		echo "$line"
	done < $FILE
}

function main()
{
	for i in *.txt; do
		#echo $i
		sub $i
		echo
	done
}
main
