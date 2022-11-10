#!/bin/bash

cd /Users/ryan/Documents/giterdone/ncaaShots/tmpFiles
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

GAMENUM=$1

chrome --headless --disable-gpu --dump-dom  `echo "http://gamezone.stats.com/gz3/basketball/cbk/"$GAMENUM` > tmp.html

#want

## summary file
#home
HOME=`cat tmpFiles/tmp.html | grep -A1 '<tr id="homeLineScore">' | tail -n1 | sed 's/.*<td>//g' | sed 's/ <.td>.*//g'`
#away
AWAY=`cat tmpFiles/tmp.html | grep -A1 '<tr id="awayLineScore">' | tail -n1 | sed 's/.*<td>//g' | sed 's/ <.td>.*//g'`
#date
MATCHUP=`echo $AWAY vs $HOME`
DATE=`cat tmpFiles/tmp.html | grep $MATCHUP | grep "|" | sed 's/.* | //g' | sed 's/<.p>//g'`

#final score
HOMESCORE=`cat tmpFiles/tmp.html | grep -m1 -A1 gz_homeTm | tail -n1 | sed 's/.*<div class="gz_tmScore"><span class="mvc_total">//g' | sed 's/<.span>.*//g'`
AWAYSCORE=`cat tmpFiles/tmp.html | grep -m1 -B2 gz_homeTm | head -n1 | sed 's/.*<div class="gz_tmScore"><span class="mvc_total">//g' | sed 's/<.span>.*//g'`

#find out Neutral?

## play by play
#works pretty well, text is a big block though...
grep Substitution tmpFiles/tmp.html | sed 's/<tr pbpid="." class="shsRow1Row shsPBPRow">/\n/g' \
			 | sed 's/<tr pbpid=".." class="shsRow1Row shsPBPRow">/\n/g' \
			 | sed 's/<tr pbpid="..." class="shsRow1Row shsPBPRow">/\n/g' \
			 | sed 's/ //g' | sed 's/<trclass="shsColTtlRowshsMorePBPRowmvc_pbpHeader"><td>H<.td><td>Time<.td><td>Team<.td><td>Event<.td>.*<.tr>//g' \
			 | sed 's/<tdclass="shsNamD">//g' | sed 's/<.td><tdclass="shsTotD">/,/g' \
			 | sed 's/<.td><.tr>//g' | sed 's/<.td>/,/g' | sed 's/&nbsp;//g' | sed 's/<strong>//g' | sed 's/<.strong>//g'

## box score

## shot list
cat tmp.html | grep -B2 "mvc_sc_period=" \
			 | sed '$!N;s/\n/,/' | sed 's,<span class=,\n<span class=,g' \
			 | tail -n +2 | sed '$!N;s/\n/,/' | sed 's,<span class=.gz_shot gz_,,g' \
			 | sed 's/. team=./,/g' | sed 's/. mvc_sc_playerid=./,/g' \
			 | sed 's/. title=./,/g' | sed 's/; display: block;.><.span>//g' \
			 | sed 's/1st /1st,/g' | sed 's/2nd /2nd,/g' | sed 's/.. mvc_sc_period=./,half/g' \
			 | sed 's/. style=.top: /,/g' | sed 's/%; left: /,/g' | sed 's/%//g' | sed 's/<.div>//g' > dehtml.csv

LINES=`wc -l dehtml.csv | sed 's, dehtml.csv,,g' | sed 's, ,,g'`
HALFLINES=`echo $((LINES / 2))`

## the shot chart is a duplicate <shruggie>, just use the top half
head -n$HALFLINES dehtml.csv > uniqhtml.csv

### COMBINE PBP AND SHOTS, TO GET SHOT CLOCK TIME

rm shots.csv

for L in `seq 1 $HALFLINES`; do
	SHOT=`head -n$L uniqhtml.csv | tail -n1`
	PLAYER=`echo $SHOT | cut -d, -f4`
	TEXT=`echo $SHOT | cut -d, -f7`
	ASSIST=`echo $TEXT | grep -c " with the assist"`
	ASSISTER=`echo ""`
	if [[ ASSIST -eq 1 ]]; then
	 	ASSISTER=`echo $TEXT | sed 's/.* feet out. //g' | sed 's/ with the assist//g' | sed 's/.* dunks. //g'`
	 fi
	BLOCK=`echo $TEXT | grep -c " blocks a "`
	BLOCKER=`echo ""`
	if [[ BLOCK -eq 1 ]]; then
	 	BLOCKER=`echo $TEXT | sed 's/ blocks a .*//g'`
	 fi
	DUNK=`echo $TEXT | grep -c dunk`
	LAYUP=`echo $TEXT | grep -c " a layup "`
	HOOK=`echo $TEXT | grep -c " a hook shot "`
	THREEPT=`echo $TEXT | grep -c "a 3-point jump shot "`
	JUMPER=`echo $TEXT | grep -c " a jump shot "`
	DIST=`echo $TEXT | sed 's/ a dunk/ a dunk from 0 feet out/g' | sed 's/ dunks/ dunks from 0 feet out/g' | sed 's/.* from //g' | sed 's/ feet out.*//g'`
	KEEPTEXT=`echo $SHOT | cut -d, -f1-6,8-10`

	echo $GAMENUM,$KEEPTEXT,$DIST,$ASSIST,$ASSISTER,$BLOCK,$BLOCKER,$THREEPT,$DUNK,$LAYUP,$HOOK,$JUMPER,$TEXT >> shots.csv
done
