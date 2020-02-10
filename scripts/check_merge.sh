#!/bin/bash

grep "<<<<<<< HEAD" *.txt 
result=$?
if [ $result -eq 0 ]; then
    echo "ERROR: merge comment exists."
    exit 1
fi

