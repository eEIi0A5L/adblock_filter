#!/bin/bash

# invalid character
function check()
{
    LINE="$1"
    
    echo "$LINE"
    #if [[ ! $LINE =~ [[:alnum:]] ]]; then
    #if [[ "$LINE" =~ [[:^alnum:]] ]]; then
    #if [[ "$LINE" =~ ([^0-9a-zA-Z\ \[\]\.]) ]]; then
    #if [[ "$LINE" =~ ([^0-9a-zA-Z\.\[\]\"]) ]]; then
    if [[ "$LINE" =~ ^[0-9a-zA-Z\.\ \[\]]*$ ]]; then
        return 0
    fi
    if [[ "$LINE" =~ ([^0-9a-zA-Z\.\ \[\]]) ]]; then
        ma=${BASH_REMATCH[1]}
        echo "icerr: ma=$ma"
    fi
    echo "icerr: line=$LINE"
    return 1
}

function sub()
{
    FILE=$1
    echo "----$FILE"
    while IFS=$'\r' read line; do

        check "$line"
        result=$?
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
    LIST="*.txt */[a-z]*.txt"
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
