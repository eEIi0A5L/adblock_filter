#!/bin/bash

# .js.jsチェック
function sub()
{
    FILE=$1
    echo "----$FILE"
    while IFS=$'\r' read line; do
        if [[ $line =~ ^\r\n ]]; then
            continue
        fi
        if [[ $line =~ ^$ ]]; then
            continue
        fi
        if [[ $line =~ ^\[Adblock ]]; then
            continue
        fi
        if [[ $line =~ ^\! ]]; then
            continue
        fi
        if [[ $line =~ \.js\.js ]]; then
            return 1
        fi

        #echo "result=[$result]"
        if [ ! $result -eq 0 ]; then
            return $result
        fi
    done < $FILE
    return 0
}

function main()
{
    for i in $*; do
        sub $i
        result=$?
        if [ $result -ne 0 ]; then
            return $result
        fi
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
result=$?
if [ $result -ne 0 ]; then
    echo "ERROR: result=$result"
    exit $result
fi
exit 0
