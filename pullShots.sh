#!/bin/bash

cd /Users/ryan/Documents/giterdone/ncaaShots/tmpFiles
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

GAMENUM=$1

chrome --headless --disable-gpu --dump-dom  `echo "http://gamezone.stats.com/gz3/basketball/cbk/"$GAMENUM` > tmp.html 2> err.txt

SHOTNUM=`cat tmp.html | grep "gz_shot" | wc -l | sed 's/ //g'`
SUBNUM=`cat tmp.html | grep -c Substitution`

if [[ SHOTNUM -gt 20 ]]; then

	if [[ SUBNUM -eq 1 ]]; then

		HOME=`cat tmp.html | grep -A1 '<tr id="homeLineScore">' | tail -n1 | sed 's/.*<td>//g' | sed 's/ <.td>.*//g'`
		HOMEABBV=`grep -A2 -m1 "<td>Event</td>" tmp.html | tail -n1 | sed 's/.*<td>//g' | sed 's/<.td>.*//g'`

		AWAY=`cat tmp.html | grep -A1 '<tr id="awayLineScore">' | tail -n1 | sed 's/.*<td>//g' | sed 's/ <.td>.*//g'`
		AWAYABBV=`grep -A1 -m1 "<td>Event</td>" tmp.html | tail -n1 | sed 's/.*<td>//g' | sed 's/<.td>.*//g'`

		MATCHUP=`echo $AWAY vs $HOME`
		DATE=`cat tmp.html | grep " vs " | grep "<p>" | grep "|" | sed 's/.* | //g' | sed 's/<.p>//g'`
		DATESC=`echo $DATE | sed 's/,//g'`

		DAY=`echo $DATESC | cut -d" " -f2`
		MONTH=`echo $DATESC | cut -d" " -f1`
		YEAR=`echo $DATESC | cut -d" " -f3`

		HOMESCORE=`cat tmp.html | grep -m1 -A1 gz_homeTm | tail -n1 | sed 's/.*<div class="gz_tmScore"><span class="mvc_total">//g' | sed 's/<.span>.*//g'`
		AWAYSCORE=`cat tmp.html | grep -m1 -B2 gz_homeTm | head -n1 | sed 's/.*<div class="gz_tmScore"><span class="mvc_total">//g' | sed 's/<.span>.*//g'`

		echo $GAMENUM,$YEAR,$MONTH,$DAY,$DATESC,$AWAY,$AWAYABBV,$AWAYSCORE,$HOME,$HOMEABBV,$HOMESCORE > summary.csv


		grep Substitution tmp.html | sed 's/<tr pbpid="." class="shsRow1Row shsPBPRow">/\n/g' \
					 | sed 's/<tr pbpid=".." class="shsRow1Row shsPBPRow">/\n/g' \
					 | sed 's/<tr pbpid="..." class="shsRow1Row shsPBPRow">/\n/g' \
					 | sed 's/<tr class="shsColTtlRow shsMorePBPRow mvc_pbpHeader"><td>H<.td><td>Time<.td><td>Team<.td><td>Event<.td>.*<.tr>//g' \
					 | sed 's/ .*<td class="shsNamD"> .*1st .*<.td> .*<td class="shsTotD">/1st;/g' \
					 | sed 's/ .*<td class="shsNamD"> .*2nd .*<.td> .*<td class="shsTotD">/2nd;/g' \
					 | sed 's/ .*<td class="shsNamD"> .* OT .*<.td> .*<td class="shsTotD">/1OT;/g' \
					 | sed 's/ .*<td class="shsNamD"> .*2OT .*<.td> .*<td class="shsTotD">/2OT;/g' \
					 | sed 's/ .*<td class="shsNamD"> .*3OT .*<.td> .*<td class="shsTotD">/3OT;/g' \
					 | sed 's/ .*<td class="shsNamD"> .*4OT .*<.td> .*<td class="shsTotD">/4OT;/g' \
					 | sed 's/ .*<td class="shsNamD"> .*5OT .*<.td> .*<td class="shsTotD">/5OT;/g' \
					 | sed 's/ .*<td class="shsNamD"> .*6OT .*<.td> .*<td class="shsTotD">/6OT;/g' \
					 | sed 's/ .*<td class="shsNamD"> .*7OT .*<.td> .*<td class="shsTotD">/7OT;/g' \
					 | sed 's/<.td>/;/g' | sed 's/<td class="shsNamD">/;/g' \
					 | sed 's/<.td><.tr>//g' | sed 's/&nbsp;//g' | sed 's/<strong>//g' | sed 's/<.strong>//g' | grep -v "PlayByPlayTable" > pbp.ssv

		cat pbp.ssv | cut -d";" -f1,2,4,8,10,11 | sed 's/<.tr>//g' | sed 's/ //g' > nonTextPBP.ssv
		cat pbp.ssv | cut -d";" -f6 > textPBP.ssv

		paste nonTextPBP.ssv textPBP.ssv | sed 's/	                 //g' | sed 's/,//g' | sed 's/;/,/g' > pbp.csv


		PBPLINES=`wc -l pbp.csv | sed 's, pbp.csv,,g' | sed 's, ,,g'`
		rm pbpWsectime.csv

		for P in `seq 1 $PBPLINES`; do
			PLAY=`head -n$P pbp.csv | tail -n1`
			HALF=`echo $PLAY | cut -d, -f1 | cut -c1`
			OVERTIME=`echo $PLAY | cut -d, -f1 | cut -c2-3`
			TIME=`echo $PLAY | cut -d, -f2`
			MIN=`echo $TIME | cut -d: -f1`
			SEC=`echo $TIME | cut -d: -f2`
			SECTENS=`echo $TIME | cut -d: -f2 | cut -c1`

			if [[ SECTENS -eq 0 ]]; then
				SEC=`echo $TIME | cut -d: -f2 | cut -c2`
			fi

			MININ=$((`echo $((19 - MIN))` * 60))
			SECIN=$((60 - SEC))

			HALFADJ=$((`echo $((HALF - 1))` * 1200))

			SECTIME=$((MININ + SECIN + HALFADJ))

			if [ "$OVERTIME" = "OT" ]; then
				SECTIME=$((MININ + SECIN + 1200))
				OTTIME=$((300 * HALF))
				OTSECTIME=$((SECTIME + OTTIME))
				SECTIME=$OTSECTIME
			fi

			echo $GAMENUM,$SECTIME,$PLAY >> pbpWsectime.csv
		done

		grep boxPlayers tmp.html | sed 's/<.tr>/\n/g' | sed 's/.*playerPopout/;/g' | sed 's/<.span>.*/;/g' | grep -v "<.tbody>" > playerList.tmp 
		AWAYROWS=`grep -n totalRow playerList.tmp | cut -d: -f1 | head -n1`
		HOMEROWS=`grep -n totalRow playerList.tmp | cut -d: -f1 | tail -n1`


		head -n$((AWAYROWS - 1)) playerList.tmp | sed 's/ currentBoxTeamId, event);">                                          //g' \
					| sed 's/                                      ;//g' | sed 's/, Jr./ Jr./g' \
					| sed 's/;(//g' | sed 's/$/,'"$AWAY"','"$AWAYABBV"'/g' > awayPlayers.csv

		tail -n$((HOMEROWS - AWAYROWS)) playerList.tmp | head -n $((HOMEROWS - AWAYROWS - 1)) \
					| sed 's/ currentBoxTeamId, event);">                                          //g' \
					| sed 's/                                      ;//g' | sed 's/, Jr./ Jr./g' \
					| sed 's/;(//g' | sed 's/$/,'"$HOME"','"$HOMEABBV"'/g' > homePlayers.csv

		cat awayPlayers.csv homePlayers.csv > players.csv

		A1=`head -n1 awayPlayers.csv | cut -d, -f1 | tail -n1`
		A2=`head -n2 awayPlayers.csv | cut -d, -f1 | tail -n1`
		A3=`head -n3 awayPlayers.csv | cut -d, -f1 | tail -n1`
		A4=`head -n4 awayPlayers.csv | cut -d, -f1 | tail -n1`
		A5=`head -n5 awayPlayers.csv | cut -d, -f1 | tail -n1`
		H1=`head -n1 homePlayers.csv | cut -d, -f1 | tail -n1`
		H2=`head -n2 homePlayers.csv | cut -d, -f1 | tail -n1`
		H3=`head -n3 homePlayers.csv | cut -d, -f1 | tail -n1`
		H4=`head -n4 homePlayers.csv | cut -d, -f1 | tail -n1`
		H5=`head -n5 homePlayers.csv | cut -d, -f1 | tail -n1`

		echo $GAMENUM,0,1st,20:00,,,,Tip-off. > subsWTip.csv
		grep ,,,Substitution: pbpWsectime.csv | sort -n | grep ,1st, >> subsWTip.csv
		echo $GAMENUM,0,2nd,20:00,,,,Tip-off. >> subsWTip.csv
		grep ,,,Substitution: pbpWsectime.csv | sort -n | grep ,2nd, >> subsWTip.csv
		grep ,,,Substitution: pbpWsectime.csv | sort -n | grep OT, >> subsWTip.csv

		SUBCOUNT=`wc -l subsWTip.csv | sed 's/ subsWTip.csv//g' | sed 's/ //g'`

		rm subLineups.csv
		for S in `seq 1 $SUBCOUNT`; do
			SUB=`head -n$S subsWTip.csv | tail -n1`
			TIPOFF=`echo $SUB | grep -c ,Tip-off.`
			if [[ TIPOFF -eq 1 ]]; then
				ONTHEFLOOR=`echo $A1,$A2,$A3,$A4,$A5,$H1,$H2,$H3,$H4,$H5`
			else
				PLAYERIN=`echo $SUB | sed 's/.*Substitution: //g' | sed 's/ in for .*//g'`
				PLAYEROUT=`echo $SUB | sed 's/.* in for //g' | sed 's/\.  .*//g'`
				SUBAWAY=`echo $SUB | grep -c "$AWAYABBV"`
				if [[ SUBAWAY -eq 1 ]]; then
					NUMBERIN=`grep "$PLAYERIN" awayPlayers.csv | cut -d, -f1`
					NUMBEROUT=`grep "$PLAYEROUT" awayPlayers.csv | cut -d, -f1`
				else
					NUMBERIN=`grep "$PLAYERIN" homePlayers.csv | cut -d, -f1`
					NUMBEROUT=`grep "$PLAYEROUT" homePlayers.csv | cut -d, -f1`
				fi
				NEWONTHEFLOOR=`echo $ONTHEFLOOR | sed 's/,'$NUMBEROUT'/,'$NUMBERIN'/g'`
				ONTHEFLOOR=`echo $NEWONTHEFLOOR`
			fi
			echo $SUB,$ONTHEFLOOR | sed 's/,0,2nd,20:00,,,,Tip-off.,/,1200,2nd,20:00,,,,Tip-off.,/g' >> subLineups.csv
		done

		cat tmp.html | grep -B2 "mvc_sc_period=" \
					 | sed '$!N;s/\n/,/' | sed 's,<span class=,\n<span class=,g' \
					 | tail -n +2 | sed '$!N;s/\n/,/' | sed 's,<span class=.gz_shot gz_,,g' \
					 | sed 's/. team=./,/g' | sed 's/. mvc_sc_playerid=./,/g' \
					 | sed 's/. title=./,/g' | sed 's/; display: block;.><.span>//g' \
					 | sed 's/1st /1st,/g' | sed 's/2nd /2nd,/g' | sed 's/OT /OT,/g' | sed 's/,OT,/,1OT,/g' \
					 | sed 's/.. mvc_sc_period=./,half/g' | sed 's/. style=.top: /,/g' | sed 's/%; left: /,/g' | sed 's/%//g' | sed 's/<.div>//g' > dehtml.csv

		LINES=`wc -l dehtml.csv | sed 's, dehtml.csv,,g' | sed 's, ,,g'`
		HALFLINES=`echo $((LINES / 2))`

		head -n$HALFLINES dehtml.csv > uniqhtml.csv

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
			if [[ DUNK -eq 1 ]]; then
				DIST=0
			else
			DIST=`echo $TEXT | sed 's/.* from //g' \
							 | sed 's/ feet out.*//g' \
							 |  sed 's/ foot out.*//g'`
			fi

			KEEPTEXT=`echo $SHOT | cut -d, -f1-6,8-10`

			HALF=`echo $SHOT | cut -d, -f5 | cut -c1`
			OVERTIME=`echo $SHOT | cut -d, -f5 | cut -c2-3`
			TIME=`echo $SHOT | cut -d, -f6`
			MIN=`echo $TIME | cut -d: -f1`
			SEC=`echo $TIME | cut -d: -f2`
			SECTENS=`echo $TIME | cut -d: -f2 | cut -c1`

			if [[ SECTENS -eq 0 ]]; then
				SEC=`echo $TIME | cut -d: -f2 | cut -c2`
			fi


			MININ=$((`echo $((19 - MIN))` * 60))
			SECIN=$((60 - SEC))
			
			HALFADJ=$((`echo $((HALF - 1))` * 1200))

			SECTIME=$((MININ + SECIN + HALFADJ))

			if [ "$OVERTIME" = "OT" ]; then
				SECTIME=$((MININ + SECIN + 1200))
				OTTIME=$((300 * HALF))
				OTSECTIME=$((SECTIME + OTTIME))
				SECTIME=$OTSECTIME
			fi


			HOMESHOT=`echo $SHOT | grep -c ,home,`

			if [[ HOMESHOT -eq 1 ]]; then
				OPP=$AWAY
				OPPABBV=$AWAYABBV
				SHOTTEAM=$HOME
			else
				OPP=$HOME
				OPPABBV=$HOMEABBV
				SHOTTEAM=$AWAY
			fi

			echo $GAMENUM,$SECTIME,$KEEPTEXT,$DIST,$ASSIST,$ASSISTER,$BLOCK,$BLOCKER,$THREEPT,$DUNK,$LAYUP,$HOOK,$JUMPER,$SHOTTEAM,$OPP,$OPPABBV,$TEXT >> shots.csv
		done

		sed 's/,goal,/,make,/g' shots.csv > shotsNoGoal.csv

		mv shotsNoGoal.csv shots.csv

		rm awayPlayers.csv err.txt nonTextPBP.ssv pbp.ssv playerList.tmp tmp.html dehtml.csv homePlayers.csv pbp.csv subsWTip.csv textPBP.ssv uniqhtml.csv

	fi

fi

