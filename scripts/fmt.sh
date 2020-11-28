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

    # 括弧の数は同じであること
    num1=`perl scripts/count.pl "$LINE" "\("`
    num2=`perl scripts/count.pl "$LINE" "\)"`
    if [ $num1 -ne $num2 ]; then
        echo "count: LINE=[$LINE]"
        echo "num1=$num1"
        echo "num2=$num2"
        return 1 # error
    fi

    # :has()と:has-text()は同時に使用できない
    # → 同時使用できる。2020.11.28
    # https://github.com/eEIi0A5L/adblock_filter/commit/4b7da1f653dcdca0c6a40b4abe54e9d4f49a29ce#comments
    #if [[ $LINE =~ :has\( ]]; then
    #    if [[ $LINE =~ :has-text\( ]]; then
    #        echo ":has() + :has-text()"
    #        echo "$LINE"
    #        return 1 # error
    #    fi
    #fi

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


    # /^
    #echo "$LINE"
    if [[ $LINE =~ \/\^$ ]]; then
        echo "match1: LINE=[$LINE]"
        return 1 # error
    fi

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

    # 'u'だけ書くと誤爆する
    #https://egg.5ch.net/test/read.cgi/software/1562160518/990
    #https://github.com/easylist/easylist/issues/6123
    #https://github.com/easylist/easylist/commit/e743258656e35c2369b0f3bd155472c973dbe544
    len=${#LINE}
    if [ $len -lt 5 ]; then
        # 文字数が少なすぎるのでエラーの可能性がある
        echo "len short: len=[$len]"
        echo "len short: LINE=[$LINE]"
        return 1 # error
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
        if [[ $line =~ ^\! ]]; then
            continue
        fi

        # コメントに!がついていない可能性あり
        if [[ $line =~ [亜-熙ぁ-んァ-ヶ] ]]; then
            if [[ ! $line =~ [\"\(] ]]; then
                if [[ ! $line =~ 今日何食べる ]]; then
                    echo "error: invalid character: $line"
                    return 1
                fi
            fi
        fi
        #regexp="[0-9a-zA-Z\|/\.@\$=,\*\?\^\-:\(\)]+"
        #regexp="[0-9a-zA-Z\|/\.@\$=\*\?,\^\-\[\]]+"
        #regexp="[[:punct:][:alnum:][:blank:]]+"
        #regexp="^[[:punct:][:alnum:]]+$"
        #echo "line=[$line]"
        #if [[ ! $line =~ $regexp ]]; then
        #    if [[ $line =~ ^($regexp) ]]; then
        #        matchstr=${BASH_REMATCH[1]}
        #    fi
        #    echo "error: invalid character: $line"
        #    echo "matchstr=[$matchstr]"
        #    return 1
        #fi
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
        if [ "$i" = "misc/tver.txt" ]; then
            continue
        fi
        if [ "$i" = "misc/tmp.txt" ]; then
            continue
        fi
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
