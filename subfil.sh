#!/bin/bash

# サブフィルタの調査

function get_subfil()
{
    line="$1"
    #echo "line=[$line]"
    #if [[ $line =~ \|\|([^\^/]+)[\^/] ]]; then
    if [[ $line =~ \#\# ]]; then
        echo ""
        return
    fi
    if [[ $line =~ \#@\# ]]; then
        echo ""
        return
    fi
    #if [[ $line =~ ^\|\|([^\^/]+)[\^] ]]; then
    #if [[ $line =~ ^\|\|([^\^/]+)\^ ]]; then
    if [[ $line =~ ^\|\|(.+/)$ ]]; then
        subfil=${BASH_REMATCH[1]}
        echo $subfil
        return
    fi
    echo ""
}

function check_subfil()
{
    subfil=$1
    FILE2=$2
    #echo "FILE2=[$FILE2]"
    while IFS=$'\r' read line; do
        regexp='!'
        if [[ $line =~ $regexp ]]; then
            continue
        fi
        # $popupは特殊なので除外する
        if [[ $line =~ \$ ]]; then
            continue
        fi
        if [[ $line =~ \#\# ]]; then
            continue
        fi
        if [[ $line =~ \#@\# ]]; then
            continue
        fi
        if [[ $line =~ @@ ]]; then
            continue
        fi
        # 自分自身は除外する
        if [[ $line =~ $subfil$ ]]; then
            continue
        fi

        pattern="$subfil"
        if [[ $line =~ $pattern ]]; then
            echo "found."
            echo "found subfil=[$subfil]"
            echo "pattern=[$pattern]"
            echo "line=[$line]"
        fi
    done < $FILE2
}

function sub()
{
    FILE=$1
    echo "----$FILE"
    #grep -v -E "##" $i | grep -v "||" | grep -v -E "^[ \t]*!" | grep -v "domain" | grep -v "#@#" | grep -v -E "^$"
    while IFS=$'\r' read line; do
        subfil=`get_subfil "$line"`
        if [ "$subfil" = "" ]; then
            continue
        fi
        #echo "line=[$line]"
        #echo "subfil=[$subfil]"
        check_subfil $subfil $FILE
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
