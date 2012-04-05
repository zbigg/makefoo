#!/bin/bash

component=$1
shift

{ 
    if ! "$@" 2>&1 ; then
        echo "$component build FAILED, please see $component.log"
        exit 1
    fi
} | tee -a $component.log
exit ${PIPESTATUS[0]}

