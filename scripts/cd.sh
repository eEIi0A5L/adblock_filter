#!/bin/bash

# ドメインが存在するかチェックする

function get_domain()
{
    line="$1"
    #if [[ $line =~ \|\|([^\^/]+)[\^/] ]]; then
    if [[ $line =~ \#@\# ]]; then
        domain_part=${line%%\#@\#*}
        echo $domain_part
        #echo ""
        return
    fi
    if [[ $line =~ \#\# ]]; then
        domain_part=${line%%\#\#*}
        echo $domain_part
        #echo ""
        return
    fi
    #if [[ $line =~ ^\|\|([^\^/]+)[\^] ]]; then
    #if [[ $line =~ ^\|\|([^\^/]+)\^ ]]; then
    #if [[ $line =~ ^\|\|([^\^/]+)([\\^/])$ ]]; then
    if [[ $line =~ ^\|\|([^\^/]+)([\\^/]) ]]; then
        domain=${BASH_REMATCH[1]}
        # ポート番号付きの奴はここでポート番号を削除する
        if [[ $domain =~ (.+):[0-9]+ ]]; then
            domain=${BASH_REMATCH[1]}
        fi
        echo $domain
        return
    fi
    echo ""
}

function get_topdomain()
{
    domain=$1
    topdomain=$domain
    if [[ $domain =~ \.(.+\..+) ]]; then
        topdomain=${BASH_REMATCH[1]}
    fi
    echo $topdomain
}

function check_domain_exist()
{
    domain=$1
    TMP=`host $domain`
    result=$?
    if [ $result -eq 0 ]; then
        return 0
    fi

    TMP2=`whois $domain`
    result2=$?
    if [ $result2 -eq 0 ]; then
        return 0
    fi
    return 1

    topdomain=`get_topdomain $domain`
    if [ ! $topdomain = $domain ]; then
        #echo "domain=$domain"
        #echo "topdomain=$topdomain"
        TMP3=`whois $topdomain`
        result3=$?
        if [ $result3 -eq 0 ]; then
            return 0
        fi
    fi

    return 1
}

function sub()
{
    FILE=$1
    DOMAIN_LIST=/tmp/.domain_list
    DOMAIN_LIST2=/tmp/.domain_list2
    if [ -f $DOMAIN_LIST ]; then
        rm $DOMAIN_LIST
    fi
    echo "----$FILE"
    #grep -v -E "##" $i | grep -v "||" | grep -v -E "^[ \t]*!" | grep -v "domain" | grep -v "#@#" | grep -v -E "^$"
    while IFS=$'\r' read line; do
        # コメント行は読み飛ばす
        if [[ $line =~ \! ]]; then
            continue
        fi
        domain_part=`get_domain "$line"`
        if [ "$domain_part" = "" ]; then
            continue
        fi
        domain_list=(${domain_part//,/ })
        #echo ${domain_list[@]}
        for item in ${domain_list[@]}; do
            if [[ $item =~ ^\.[^\.]+$ ]]; then
                continue
            fi
            echo $item >> $DOMAIN_LIST
        done
    done < $FILE
    if [ ! -f $DOMAIN_LIST ]; then
        return
    fi
    sort $DOMAIN_LIST | uniq > $DOMAIN_LIST2
    #debug
    #exit 1
    while read line; do
        #echo $line
        check_domain_exist $line
        result=$?
        if [ $result -ne 0 ]; then
            echo "ERROR: $line is not exist"
        fi
    done < $DOMAIN_LIST2
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
