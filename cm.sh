#!/bin/bash
# cm - cosmetic maint

# cosmetic_partにさらに##があるならエラー
function check1()
{
	domain_part=$1
	cosmetic_part=$2
	#echo "$domain_part"
	#echo "$cosmetic_part"
	if [[  $cosmetic_part =~ \#\# ]]; then
		echo "$cosmetic_part"
		echo "ERROR"
	fi
}

# 要素のAttributeの値にクオテーションが使われてないならエラー
function check2()
{
	domain_part=$1
	cosmetic_part=$2
	#if [[  $cosmetic_part =~ \[[a-z]\$?=([\"\']) ]]; then
	#	return
	#fi
	if [[  $cosmetic_part =~ \[[a-z]+\$?=([^\"\']) ]]; then
		echo "$cosmetic_part"
		echo "ERROR"
	fi
}

# cosmeticなのに||がついてたらエラー
function check3()
{
	domain_part=$1
	cosmetic_part=$2
	if [[ $domain_part =~ \|\| ]]; then
		echo "$domain_part"
		echo "ERROR"
	fi
}

# セレクタが#.になっている
function check4()
{
	domain_part=$1
	cosmetic_part=$2
	if [[  $cosmetic_part =~ \#\. ]]; then
		echo "$cosmetic_part"
		echo "ERROR"
	fi
}

function sub()
{
	FILE=$1
	echo "----$FILE"
	while IFS=$'\r' read line; do
		# コメント行は読み飛ばす
		if [[ $line =~ \! ]]; then
			continue
		fi
		if [[ ! $line =~ \#\# ]]; then
			continue
		fi
		#echo "[$line]"
		#echo "$line"

		domain_part=${line%%\#\#*}
		#echo "$domain_part"

		cosmetic_part=${line##*\#\#}
		#echo "$cosmetic_part"

		check1 $domain_part $cosmetic_part 
		check2 $domain_part $cosmetic_part 
		check3 $domain_part $cosmetic_part 
		check4 $domain_part $cosmetic_part 

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
