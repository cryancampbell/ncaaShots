#!/bin/bash

cd /Users/ryan/Documents/giterdone/ncaaShots/tmpFiles
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

DATE=$1

chrome --headless --disable-gpu --dump-dom  `echo " http://gamezone.stats.com/cbk/scoreboard.asp?day="$DATE"&conf=-1"` > scoreboard.html 2> err.txt

grep "http://gamezone.stats.com/gz/basketball/cbk/" scoreboard.html | sed 's,.*http://gamezone.stats.com/gz/basketball/cbk/,,g' | cut -c1-7 | uniq > gameList.txt

