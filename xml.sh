#!/bin/bash
XML_FILE=xmltv.xml
TMP_FILE="/tmp/xmltv.sh.tmp"
XML_STR=`sed -n '/<\/channel>/=' $XML_FILE | sed -n '$p'`

if [[ $#  -eq 0 || $# -gt 2 ]]; then
    echo "Usage: $0 [-i] NAME"
    exit 1
elif [[ $# -eq 1 ]]; then
    SEARCH_PATTERN=$1
elif [[ $# -eq 2 ]]; then
    case $1 in 
        -i) CS="-i";  SEARCH_PATTERN=$2
            ;;
        *) echo "Unknown parameter $1" 
           exit 1
            ;;
    esac
fi

if [ -f $TMP_FILE ]; then rm $TMP_FILE; fi

echo -e "ID|Channel name|Channel Icon" >> $TMP_FILE
echo " | | " >> $TMP_FILE
for i in `head -n $XML_STR $XML_FILE | grep $CS -n 'dis.*>.*'$SEARCH_PATTERN'[^<]*<' | sed 's/:.*//'`; do 
    CHANNEL_NAME=`tail -n +$i $XML_FILE |head -n 1| sed -n 's/^<dis.*>\(.*\)<.*/\1/p'`
    CHANNEL_ID=`tail -n +$(($i-1)) $XML_FILE |head -n 1|sed -n 's/.*"\(.*\)".*/\1/p'`
    CHANNEL_ICO=`tail -n +$(($i+1)) $XML_FILE |head -n 1|sed -n 's/.*"\(.*\)".*/\1/p'`

        echo "$CHANNEL_ID|$CHANNEL_NAME|$CHANNEL_ICO" >> $TMP_FILE
    SUM=$(($SUM+1))
done
echo -e "\r"
cat $TMP_FILE | column -t -s '|'
echo -e "\nTotal channels: $SUM"
rm $TMP_FILE
