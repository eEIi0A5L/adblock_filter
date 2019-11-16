#!/bin/bash

# 重複行を表示する
function sub()
{
    FILE=$1
    echo "----$FILE"
    lineno=0
    while IFS=$'\r' read line; do
        lineno=$((lineno + 1))
        if [[ $line =~ ^\r\n ]]; then
            continue
        fi
        if [[ $line =~ ^$ ]]; then
            continue
        fi
        if [[ $line =~ ^\[Adblock ]]; then
            continue
        fi
        regexp='!'
        if [[ $line =~ $regexp ]]; then
            continue
        fi

        count=0
        while IFS=$'\r' read line2; do
            if [ "$line" = "$line2" ]; then
                count=$((count + 1))
            fi
        done < $FILE
        #echo $count
        if [ $count -gt 1 ]; then
            echo "[$lineno]$line"
        fi
    done < $FILE
}

function main()
{
    for i in $*; do
        #echo $i
        sub $i
        #echo
    done
}

if [ "$1" = "" ]; then
    # 無指定の場合はカレントディレクトリの全.txtをチェックする
    LIST=*.txt
else
    # 指定されたファイルをチェックする
    LIST=$*
fi
main $LIST
