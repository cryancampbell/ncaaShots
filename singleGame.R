allShots <- shotDF
gameData <- gameDF
name <- "RJ Davis"
name <- "Reece Beekman"
#name <- "Caleb Love"
#name <- "Armando Bacot"
team <- NA
ID <- NA
teamPlot <- FALSE
gameID <- NA
#teamPlot <- TRUE
defense <- FALSE
#name <- "Arizona"
plotType <- "shots"
lastNgames <- 3
oppList <- "all"
colPalette <- "blueRed"
zoneColor <- "season"
playerData <- playerDF
#zoneColor <- "plot"
saveDir <- "/Users/ryan/Dropbox (Personal)/misc/bball_stats/gz22/plots"

singleGame <- function(allShots = shotDF, gameData = gameDF, name = "Caleb Love", ID = NA,
                       team = NA, teamPlot = FALSE, defense = FALSE,
                       plotType = "shots", gameID = NA, lastNgames = 3,
                       colPalette = "blueRed", zoneColor = "season",
                       playerData = playerDF, saveDir = "~/Dropbox (Personal)/misc/bball_stats/") {
  ###############
  ## draw the court ##
  court <- readRDS("~/Documents/giterdone/ncaaShots/data/court.RDS")
  sqPoly <- readRDS("~/Documents/giterdone/ncaaShots/data/sqPoly.RDS")
  ## PLOTS ##
  
  
  ###############
  
  #plotType - shots, zones
  
  if(colPalette == "blueRed") {
    plotCols3 <- c("#4B9CD3","gray80","#E63238")
    plotCols2 <- c("#4B9CD3","#E63238")
  }
  
  ###team plot
  if (teamPlot == TRUE) {
    if (defense == FALSE) {
      plotShots <- subset(allShots, shotTeam == name)
      playerTitle <- plotShots$shotTeam[1]
    } else {
      plotShots <- subset(allShots, oppTeam == name)
      playerTitle <- paste0(plotShots$oppTeam[1],"-defense")
    }
    
  } else {
    ###players
    if (is.na(ID)) {
      #use name
      if (name %in% allShots$playerName) {
        plotShots <- subset(allShots, playerName == name)
        if (length(unique(plotShots$shotTeam)) > 1) {
          if (is.na(team)) {
            ### end loop, need specific team
          } else {
            plotShots <- subset(plotShots, shotTeam == team)
          }
        }
      } else {
        ### end loop
      }
      
    } else {
      if (ID %in% allShots$playerID) {
        plotShots <- subset(allShots, playerID == ID)
      } else {
        ### end loop
      }
    }
    playerTitle <- plotShots$playerName[1]
  }
  
  #generate +/- average
  #from player's entire history
  plotShots$sqDiff <- 0
  sqPoly$sqDiff <- 0
  
  for (sq in unique(plotShots$shotQuadrant)) {
    #sq <- "Three_Center"
    quadrantAvg <- mean(subset(plotShots, shotQuadrant == sq)$points != 0)
    qNCAAAavg <- mean(subset(plotShots, shotQuadrant == sq)$expFGPer)
    sqDiff <- 100 * (quadrantAvg - qNCAAAavg)
    plotShots$sqDiff[plotShots$shotQuadrant == sq] <- sqDiff
    sqPoly$sqDiff[sqPoly$group == sq] <- sqDiff
    print(paste0(sq," - ",sqDiff))
  }
  
  plotShots$sqDiffLim <- ifelse(plotShots$sqDiff > 25, 25,
                                ifelse(plotShots$sqDiff < -25, -25, plotShots$sqDiff))
  
  sqPoly$sqDiffLim <- ifelse(sqPoly$sqDiff > 25, 25,
                             ifelse(sqPoly$sqDiff < -25, -25, sqPoly$sqDiff))
  
  
  #limit games
  if (is.na(gameID)) {
    possibleGames <- gameDF[gameDF$gameNum %in% plotShots$gameNum,]
    possibleGames <- possibleGames[order(as.Date(possibleGames$date, format = "%B %d %Y"), decreasing = TRUE),]
    if (is.na(lastNgames)) {
      #default is last game in DB
      plotShots <- subset(plotShots, gameNum == possibleGames$gameNum[1])
    } else {
      #last N games in DB
      plotShots <- subset(plotShots, gameNum %in% possibleGames$gameNum[1:lastNgames])
    }
  } else {
    #specific game
    plotShots <- subset(plotShots, gameNum == gameID)
  }
  
  #from player's entire history
  plotShots$sqDiffnGames <- 0
  
  #generate +/- average from this set of data
  for (sq in unique(plotShots$shotQuadrant)) {
    #sq <- "Three_Center"
    quadrantAvg <- mean(subset(plotShots, shotQuadrant == sq)$points != 0)
    qNCAAAavg <- mean(subset(plotShots, shotQuadrant == sq)$expFGPer)
    sqDiffnGames <- 100 * (quadrantAvg - qNCAAAavg)
    plotShots$sqDiffnGames[plotShots$shotQuadrant == sq] <- sqDiffnGames
    sqPoly$sqDiff[sqPoly$group == sq] <- sqDiffnGames
    print(paste0(sq," - ",sqDiffnGames))
  }
  
  plotShots$sqDiffnGames <- ifelse(plotShots$sqDiffnGames > 50, 50,
                                ifelse(plotShots$sqDiffnGames < -50, -50, plotShots$sqDiffnGames))
  
  #plot info
  teamName <- subset(playerData, team == plotShots$shotTeam[1])$teamAbbv[1]
  plotGames <- length(unique(plotShots$gameNum))
  totalShotsPerGame <- round(dim(plotShots)[1] / plotGames, digits = 1)
  addedPointsPerGame <- round(sum(plotShots$actPts) / plotGames, digits = 1)

  if (addedPointsPerGame > 0) {
    plusOrMinus <- "+"
  } else {
    plusOrMinus <- ""
  }
  
  shotPlot <- ggplot() +
    geom_polygon(data = court[court$side==1,], aes(x = x, y = y, group = group), col = "gray50") +
    coord_equal() + xlim(-1,51) + ylim(-1,47) +
    xlab("") + ylab("") +
    geom_jitter(data = plotShots,
                aes(x = baseline,
                    y = depth,
                    col = sqDiffnGames,
                    shape = outcome), size = 3, height = .2, width = .2, stroke = 2) +
    scale_colour_gradientn(colors = plotCols3,limits=c(-50, 50)) +
    scale_shape_manual(values = c(4,1)) +
    labs(col = "FG% +/-\nNCAA Avg") +
    ggtitle(paste0(playerTitle,", ",teamName),
            subtitle = paste0("Last ",plotGames," games: ",plusOrMinus,addedPointsPerGame," points/game on ",totalShotsPerGame," shots/game")) +
    theme_classic() +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),
          axis.title = element_blank(),
          axis.line=element_blank(),
          legend.position = c(.87,.81),
          legend.background=element_blank(),
          legend.key.size = unit(.75, 'cm'),
          legend.title = element_text(size=9),
          legend.text = element_text(size=7),
          plot.title = element_text(size=42, hjust = .5, vjust = -2, face = "bold"),
          plot.subtitle = element_text(size=16, hjust = .5, vjust = -5.5, face = "italic")) +
    guides(shape = "none")
  
  shotPlot <- shotPlot + geom_image(x = 4, y = 43, aes(image = "~/Dropbox (Personal)/misc/bball_stats/5F/5F.png"), size = .11)

  
  if (length(unique(plotShots$gameNum)) == 1) {
    #add last n games, opponents, colors, 
    shotPlot <- shotPlot + geom_text_repel(data = plotShots, aes(x = baseline, y = depth, label = round(actPts, digits = 1)), size = 2, col = "gray30")
    ggsave(filename = paste0(saveDir,"/",playerTitle,"_v_",plotShots$oppAbbv[1],"_",possibleGames$date[1],"_singleGameShots.png"), 
           plot = shotPlot, height = 8, width = 8)
  } else {
    ggsave(filename = paste0(saveDir,"/",playerTitle,"_last",length(unique(plotShots$gameNum)),"games_",possibleGames$date[1],"_singleGameShots.png"), 
           plot = shotPlot, height = 8, width = 8)
  }
  
  sqPolySingleGame <- subset(sqPoly, group %in% unique(plotShots$shotQuadrant))
  
  ### zone version
  zonePlot <- ggplot() +
    geom_polygon(data = sqPolySingleGame, aes(x = x, y = y, group = group, fill = sqDiffLim), alpha = .75) +
    geom_jitter(data = plotShots,
                aes(x = baseline,
                    y = depth,
                    #col = sqDiffnGames,
                    shape = outcome), alpha = .75, size = 3, height = .2, width = .2, stroke = 2, col = "gray20") +
                    #shape = outcome), alpha = .75, size = 3, height = .2, width = .2, stroke = 2) +
    geom_polygon(data = court[court$side==1,], aes(x = x, y = y, group = group), col = "gray50") +
    coord_equal() +
    scale_y_continuous(breaks = c(0, 23.5, 47)) +
    scale_x_continuous(breaks = c(0, 12.5, 25, 37.5, 50)) +
    xlab("") + ylab("") +
    scale_fill_gradientn(colours = plotCols3,limits=c(-25, 25)) +
    #scale_color_gradientn(colours = plotCols3,limits=c(-50, 50)) +
    scale_shape_manual(values = c(4,1)) +
    labs(fill = "FG% +/-\nNCAA Avg") +
    ggtitle(playerTitle) +
    theme_classic() +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(),
          axis.title = element_blank(),
          axis.line=element_blank(),
          legend.position = c(.9,.84),
          legend.background=element_blank(),
          legend.key.size = unit(.5, 'cm'),
          legend.title = element_text(size=9),
          legend.text = element_text(size=7)) + 
    guides(shape = "none")
  
  zonePlot <- zonePlot + geom_image(x = 4, y = 43, aes(image = "~/Dropbox (Personal)/misc/bball_stats/5F/5F.png"), size = .1)
  
  if (length(unique(plotShots$gameNum)) == 1) {
    ggsave(filename = paste0(saveDir,"/",playerTitle,"_v_",plotShots$oppAbbv[1],"_",possibleGames$date[1],"_singleGameZone.png"), 
           plot = zonePlot, height = 8, width = 8)
  } else {
    ggsave(filename = paste0(saveDir,"/",playerTitle,"_last",length(unique(plotShots$gameNum)),"games_",possibleGames$date[1],"_singleGameZone.png"), 
           plot = zonePlot, height = 8, width = 8)
  }
  
  #data frame of: zones, percents, number shots, points added
  
}
