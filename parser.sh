#!/bin/bash

INFILE=$1
LIST=$2

DIR=`echo "$INFILE" | sed 's/\.mp3//'`
mkdir "$DIR"

i=0
cut -d' ' -f 1 "$LIST" > time.txt
while read line
do
 t_array[i]="$line"
 (( i++ ))
done < time.txt

i=0
cut -d' ' -f 2- "$LIST" > songs.txt
while read line
do
 s_array[i]="$line"
 (( i++ ))
done < songs.txt

finish_t=`ffmpeg -i "$INFILE" 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,// | cut -d '.' -f 1`
#echo "$finish_t"
for index in ${!t_array[*]}
do
 tmp=`echo "${t_array[$index]}" "${t_array[$index+1]}"`
 t_array[$index]="$tmp"
 if [ "$index" -eq $(( ${#t_array[*]} -1 )) ] ; then
  t_array[$index]=`echo "${t_array[$index]}""$finish_t"`
 fi
 #echo "$index" "${#t_array[*]}"
 #echo "${t_array[$index]}"
 start_t=`echo "${t_array[$index]}" | cut -d ' ' -f 1`
 end_t=`echo "${t_array[$index]}" | cut -d ' ' -f 2`
 
ffmpeg -i "$INFILE" -ss "$start_t" -to "$end_t" -c copy "$DIR/$(( $index +1 )) - ${s_array[$index]}".mp3 #>> ffmpeg_convert.log
done

rm time.txt
rm songs.txt
