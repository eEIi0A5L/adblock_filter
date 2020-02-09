#!/bin/bash

# フィルタをカウントする
function sub()
{
    FILE=$1
    echo "----$FILE"
    NFIL=0
    CFIL=0
    #grep -v -E "##" $i | grep -v "||" | grep -v -E "^[ \t]*!" | grep -v "domain" | grep -v "#@#" | grep -v -E "^$"
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
        #if [[ $line =~ ^\[ \\t\]\*\! ]]; then
        regexp='!'
        if [[ $line =~ $regexp ]]; then
            continue
        fi
        #echo "[$line]"
        if [[ $line =~ \#\# ]]; then
            #echo "This is a CFIL: $line"
            CFIL=$((CFIL + 1))
        elif [[ $line =~ \#@\# ]]; then
            #echo "This is a CFIL: $line"
            CFIL=$((CFIL + 1))
        elif [[ $line =~ ^\# ]]; then
            #echo "This is a CFIL: $line"
            CFIL=$((CFIL + 1))
        else
            #echo "This is a NFIL: $line"
            NFIL=$((NFIL + 1))
        fi
    done < $FILE
    echo "CFIL=$CFIL"
    echo "NFIL=$NFIL"
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
