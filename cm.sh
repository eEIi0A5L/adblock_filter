#!/bin/bash
# cm - cosmetic maint

function sub()
{
	FILE=$1
	echo "----$FILE"
	while IFS=$'\r' read line; do
		if [[ ! $line =~ \#\# ]]; then
			continue
		fi
		#echo "[$line]"
		#echo "$line"

		domain_part=${line%%\#\#*}
		#echo "$domain_part"

		cosmetic_part=${line##*\#\#}
		#echo "$cosmetic_part"

		if [[ ! $cosmetic_part =~ \#\# ]]; then
			continue
		fi
		echo "$line"
		echo "ERROR"

	done < $FILE
}

function main()
{
	for i in *.txt; do
		#echo $i
		sub $i
	done
}
main
