#!/bin/bash
# This is basically a copy/paste of the script from chapter 5 in Vickie Li's excellent Bug Bounty Bootcamp book.
# Will add my own stuff as I go.
source ./scan.lib
while getopts "m:i" OPTION; do
    case $OPTION in
        m)
            MODE=$OPTARG
            ;;
        i)
            INTERACTIVE=true
            ;;
    esac
done

scan_domain(){
    DOMAIN=$1
    DIRECTORY=${DOMAIN}_recon
    echo "Creating directory ${DIRECTORY}..."
    mkdir $DIRECTORY
    case $MODE in
        nmap-only)
            nmap_scan
            ;;
        dirsearch-only)
            dirsearch_scan
            ;;
        crt-only)
            crt_scan
            ;;
        *)
            nmap_scan
            dirsearch_scan
            crt_scan
            ;;
    esac
}
report_domain(){
    DOMAIN=$1
    DIRECTORY=${DOMAIN}_recon
    echo "Generating report for ${DOMAIN}..."
    TODAY=$(date)
    echo "This scan was created $TODAY." > $DIRECTORY/report
    if [ -f $DIRECTORY/nmap ];then
        echo "\nNmap scan results:" >> $DIRECTORY/report
        grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
    fi
    if [ -f $DIRECTORY/dirsearch ];then
        echo "\nDirsearch scan results:" >> $DIRECTORY/report
        cat $DIRECTORY/dirsearch >> $DIRECTORY/report
    fi
    if [ -f $DIRECTORY/crt ];then
        echo "\nCrt.sh scan results:" >> $DIRECTORY/report
        jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report
    fi
}

if [ $INTERACTIVE ];then
    INPUT="BLANK"
    while [ $INPUT != "quit" ];do
        echo "Please enter a domain"
        read INPUT
        if [ $INPUT != "quit" ];then
            scan_domain $INPUT
            report_domain $INPUT
        fi
    done
else
    for i in "${@:OPTIND:$#}";do
        scan_domain $i
        report_domain $i
    done
fi