#!/bin/bash

# 包括ドメインの調査

function get_domain()
{
    line="$1"
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
    if [[ $line =~ ^\|\|([^\^/]+)([\\^/])$ ]]; then
        domain=${BASH_REMATCH[1]}
        echo $domain
        return
    fi
    echo ""
}

function check_domain()
{
    domain=$1
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

        pattern="\.$domain"
        if [[ $line =~ $pattern ]]; then
            echo "found."
            echo "found domain=[$domain]"
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
        domain=`get_domain "$line"`
        if [ "$domain" = "" ]; then
            continue
        fi
        #echo "line=[$line]"
        #echo "domain=[$domain]"
        check_domain $domain $FILE
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
