#!/bin/bash

# 構文チェック
function cosmetic_filter_check()
{
    LINE="$1"
    #echo "[C]$LINE"

    # クラス指定なのに#を三つ付けてしまうミスのチェック
    if [[ $LINE =~ \#\#\#\. ]]; then
        echo "match1: LINE=[$LINE]"
        return 1 # error
    fi

    # タグ指定なのに#を三つ付けてしまうミスのチェック
    if [[ $LINE =~ \#\#\#([^ :]*) ]]; then
        id=${BASH_REMATCH[1]}
        echo "id=[$id]"
        if [[ $id =~ ^(html|head|body)$ ]]; then
            echo "match1: LINE=[$LINE]"
            return 1 # error
        fi
        if [[ $id =~ ^(meta|link|base|bdo)$ ]]; then
            echo "match2: LINE=[$LINE]"
            return 1 # error
        fi
        if [[ $id =~ ^(h[1-6]|p|div|span|center|hr|br|address)$ ]]; then
            echo "match3: LINE=[$LINE]"
            return 1 # error
        fi
        if [[ $id =~ ^(ul|ol|li|dl|dt|dd|dir)$ ]]; then
            echo "match4: LINE=[$LINE]"
            return 1 # error
        fi
        if [[ $id =~ ^(table|caption|tbody|thead|tfoot|tr~th~td~col~colgroup)$ ]]; then
            echo "match5: LINE=[$LINE]"
            return 1 # error
        fi
        if [[ $id =~ ^(frame|iframe)$ ]]; then
            echo "match6: LINE=[$LINE]"
            return 1 # error
        fi
        return 0
    fi
    return 0
}
function regexp_check()
{
    LINE="$1"
    echo "regexp_check(): LINE=[$LINE]"
    if [[ $LINE =~ \/(.*)\/ ]]; then
        nakami=${BASH_REMATCH[1]}
        echo "nakami=[$nakami]"
        #if [[ $nakami !~ ^\^ ]]; then
        #if [[ $nakami !~ abc ]]; then
        #if [[ ! $nakami =~ abc ]]; then
        if [[ ! $nakami =~ ^\^ ]]; then
            if [[ ! $nakami =~ \$$ ]]; then
                echo "regexp_check(): error: LINE=[$LINE]"
                return 1 # error
            fi
        fi
        
    fi
    return 0
}
function is_regexp_filter()
{
    LINE="$1"
    if [[ $LINE =~ ^\/(.*)\/$ ]]; then
        nakami=${BASH_REMATCH[1]}
        echo "nakami=[$nakami]"
        return 0
    fi
    return 1
}
function network_filter_check()
{
    LINE="$1"
    #echo "[N]$LINE"
    is_regexp_filter "$LINE"
    result=$?
    if [ $result -eq 0 ]; then
        regexp_check "$LINE"
        result=$?
        if [ $result -ne 0 ]; then
            echo "error: LINE=[$LINE]"
            return $result # error
        fi
    fi

    return 0
}

function is_cosmetic_filter()
{
    LINE="$1"
    
    if [[ $LINE =~ \#\# ]]; then
        return 0
    fi
    if [[ $LINE =~ \#@\# ]]; then
        return 0
    fi
    return 1
}

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
        regexp='!'
        if [[ $line =~ $regexp ]]; then
            continue
        fi
        #echo "$line"
        is_cosmetic_filter "$line"
        result=$?
        #echo "result=[$result]"
        if [ $result -eq 0 ]; then
            cosmetic_filter_check "$line"
            result=$?
        else
            network_filter_check "$line"
            result=$?
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
