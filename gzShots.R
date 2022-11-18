
gzShots <- function(gameNum, 
                    shotDB,
                    playerDB,
                    gameDB) {
  if ( !gameNum %in% gameDB$gameNum) {
    
    #if not, run pullShots.sh
    shotCmd <- paste0("sh pullShots.sh ",gameNum)
    system(shotCmd)
    
    pbp <- read.csv(paste0(gitDir,"tmpFiles/pbpWsectime.csv"), header = F, dec = ".", sep = ",")
    players <- read.csv(paste0(gitDir,"tmpFiles/players.csv"), header = F, dec = ".", sep = ",")
    shots <- read.csv(paste0(gitDir,"tmpFiles/shots.csv"), header = F, dec = ".", sep = ",")
    subs <- read.csv(paste0(gitDir,"tmpFiles/subLineups.csv"), header = F, dec = ".", sep = ",")
    summ <- read.csv(paste0(gitDir,"tmpFiles/summary.csv"), header = F, dec = ".", sep = ",")
    
    #combine shots/subs/pbp (for shot clock)
    colnames(pbp) <- c("gameNum","secs","half","gameClock","team",
                       "awayScore","homeScore","playText")
    pbp <- pbp[order(-as.numeric(rownames(pbp))),]
    
    colnames(subs) <- c("gameNum","secs","half","gameClock","team",
                        "awayScore","homeScore","playText",
                        "a1","a2","a3","a4","a5",
                        "h1","h2","h3","h4","h5")
    
    colnames(shots) <- c("gameNum","secs","outcome","team","playerID",
                         "playerName","half","gameClock","halfN","xPos","yPos",
                         "textDist","assist","assister","block","blocker",
                         "three","dunk","layup","hook","jumper",
                         "shotTeam","oppTeam","oppAbbv",
                         "playText")
    
    colnames(summ) <- c("gameNum","year","month","day","date",
                        "away","awayAbbv","awayScore",
                        "home","homeAbbv","homeScore")
    
    colnames(players) <- c("playerID","playerName","team","teamAbbv")
    
    pbp$fullReset <- FALSE
    pbp$shortReset <- FALSE
    
    #full resets
    pbp$fullReset[grep(pattern = " makes ", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$fullReset[grep(pattern = " misses ", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$fullReset[grep(pattern = "turnover", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$fullReset[grep(pattern = "defensive rebound", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$fullReset[grep(pattern = "offensive foul", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$fullReset[grep(pattern = "Start of the ", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$fullReset[grep(pattern = " steals ", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$fullReset[grep(pattern = "Personal foul committed ", x = pbp$playText, ignore.case = T)] <- TRUE
    
    #short resets
    pbp$shortReset[grep(pattern = "turnover", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$shortReset[grep(pattern = "offensive rebound", x = pbp$playText, ignore.case = T)] <- TRUE
    pbp$shortReset[grep(pattern = "Start of the ", x = pbp$playText, ignore.case = T)] <- TRUE
    
    pbp$shotClock <- 30
    
    for (p in 1:dim(pbp)[1]) {
      #not a half start
      if (!grepl(pattern = "Start of the ", x = pbp$playText[p])) {
        clockTime <- pbp$secs[p]
        lastFullReset <- tail(subset(pbp, secs < clockTime & fullReset)$secs, n = 1)
        lastShortReset <- tail(subset(pbp, secs < clockTime & shortReset)$secs, n = 1)
        if (lastShortReset > lastFullReset) {
          pbp$shotClock[p] <- 21 - (clockTime - lastShortReset)
        } else {
          pbp$shotClock[p] <- 31 - (clockTime - lastFullReset)
        }
      }
    }
    
    pbp$a1 <- ""; pbp$a2 <- ""; pbp$a3 <- ""; pbp$a4 <- ""; pbp$a5 <- ""
    pbp$h1 <- ""; pbp$h2 <- ""; pbp$h3 <- ""; pbp$h4 <- ""; pbp$h5 <- ""
    
    pbpLineupCols <- which(colnames(pbp) %in% c("a1","a2","a3","a4","a5","h1","h2","h3","h4","h5"))
    subLineupCols <- which(colnames(subs) %in% c("a1","a2","a3","a4","a5","h1","h2","h3","h4","h5"))
    
    for (s in 1:dim(subs)[1]) {
      pbp[pbp$secs >= subs$secs[s],12:21] <- subs[s,9:18]
    }
    
    #all the shots:
    pbpShots <- pbp[sort(c(grep(x = pbp$playText, pattern = " shot"),
                           grep(x = pbp$playText, pattern = " layup"),
                           grep(x = pbp$playText, pattern = " dunk"))),]
    
    ##merge by secs, can't have 2 shots at once (right)
    pbpShots <- pbpShots[order(pbpShots$secs),]
    shots <- shots[order(shots$secs),]
    
    shotsPBP <- merge(shots,pbpShots, by = c("secs","gameClock","gameNum","half"))
    
    ### rotate shots
    shotMatrix <- as.matrix(shotsPBP[,which(colnames(shotsPBP) %in% c("xPos","yPos"))])
    
    #move the numbers to positive space
    shotMatrix[,1] <- shotMatrix[,1] + 5
    
    #rotate
    rotShotMatrix <- 100 + (shotMatrix %*% matrix(c(-1,0,0,-1), ncol = 2, nrow = 2))
    
    #make the court 100x50
    rotShotMatrix[,1] <- .5 * rotShotMatrix[,1]
    
    shotsPBP$xPosRot <- rotShotMatrix[,1]
    shotsPBP$yPosRot <- rotShotMatrix[,2]
    
    shotsPBP$xFinal <- ifelse(shotsPBP$team.x == "away", .5 * (shotsPBP$xPos + 5), shotsPBP$xPosRot) - 25
    shotsPBP$ysemiFinal <- .94 * ifelse(shotsPBP$team.x == "away", shotsPBP$yPos, shotsPBP$yPosRot)
    shotsPBP$yFinal <- ifelse(shotsPBP$team.x == "away", shotsPBP$ysemiFinal + 1, shotsPBP$ysemiFinal - 2)
    
    shotsPBP$baseline <- shotsPBP$xFinal + 25
    shotsPBP$depth <- shotsPBP$yFinal
    
    #no heaves
    shotsPBP <- subset(shotsPBP, yFinal <= 48)
    hoop <- c(0,4.75)
    shotsPBP$calcDist <- round(sqrt((shotsPBP$xFinal - hoop[1])^2 + (shotsPBP$yFinal - hoop[2])^2), digits = 1)
    
    #remove extra columns
    shotsPBP <- shotsPBP[,which(!colnames(shotsPBP) %in% c("yPosRot","xPosRot","ysemiFinal","xFinal","yFinal"))]
    
    #extras
    shotsPBP$FGtype <- ifelse(shotsPBP$three == 1,3,2)
    shotsPBP$points <- ifelse(shotsPBP$outcome == "make", shotsPBP$FGtype, 0)
    
    #add shotLocation (shotLoc)
    #swapping for 0-5,5-10,10-15,15-3pt
    #matches NBA site
    #if the scorer called it a 3 it is a 3
    #otherwise, if it is within 5' mark it 0-5ft
    shotsPBP$shotLoc <- ifelse(shotsPBP$three == 1, "Three",
                               ifelse(shotsPBP$calcDist <= 5, "0-5ft",
                                      ifelse(shotsPBP$calcDist > 5 & shotsPBP$calcDist <= 10,"5-10ft","10-22ft")))
    
    #add shot angle, where 0 degrees is directly from the left baseline
    shotsPBP$angle <- ifelse(shotsPBP$baseline >= 25, 
                             180 + round(atan(-(shotsPBP$depth - hoop[2])/(shotsPBP$baseline - 25)) * 180/pi, digits = 1),
                             round(atan(-(shotsPBP$depth - hoop[2])/(shotsPBP$baseline - 25)) * 180/pi, digits = 1))
    
    shotsPBP$angleGrp <- ifelse(shotsPBP$angle < 36, "Right",
                                ifelse(shotsPBP$angle >= 36 & shotsPBP$angle < 72, "Right-Mid",
                                       ifelse(shotsPBP$angle >= 72 & shotsPBP$angle <= 108, "Center",
                                              ifelse(shotsPBP$angle > 108 & shotsPBP$angle <= 144, "Left-Mid","Left"))))
    
    shotsPBP$angleShort <- ifelse(shotsPBP$angle < 50, "Right",
                                  ifelse(shotsPBP$angle >= 50 & shotsPBP$angle <= 130, "Center","Left"))
    
    shotsPBP$Location <- paste0(shotsPBP$shotLoc,"_",shotsPBP$angleGrp)
    shotsPBP$LocShort <- paste0(shotsPBP$shotLoc,"_",shotsPBP$angleShort)
    
    #fix 3s so right and left are corners - 15 feet baseline max
    shotsPBP$angleGrp[which(shotsPBP$three == 1 & shotsPBP$depth > 15 & shotsPBP$angleGrp == "Left")] <- "Left-Mid"
    shotsPBP$angleGrp[which(shotsPBP$three == 1 & shotsPBP$depth > 15 & shotsPBP$angleGrp == "Right")] <- "Right-Mid"
    
    shotsPBP$Location <- paste0(shotsPBP$shotLoc,"_",shotsPBP$angleGrp)
    
    #final shot groups...
    shotsPBP$shotQuadrant <- ifelse(shotsPBP$shotLoc == "0-5ft","AtRim",
                                    ifelse(shotsPBP$shotLoc == "5-10ft",shotsPBP$LocShort,shotsPBP$Location))
    
    shotsPBP <- shotsPBP[,which(!colnames(shotsPBP) %in% c("angleShort","LocShort","angleGrp","Location"))]
    
    #add to DB
    shotDB <- rbind.data.frame(shotDB,shotsPBP)
    gameDB <- rbind.data.frame(gameDB,summ)
    playerDB <- unique(rbind.data.frame(playerDB,players))
    saveRDS(shotDB, paste0(gitDir,"shotDatabase.RDS"))
    saveRDS(gameDB, paste0(gitDir,"gameDatabase.RDS"))
    saveRDS(playerDB, paste0(gitDir,"playerDatabase.RDS"))
  }
}

  