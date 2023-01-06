allShots <- shotDF
gameData <- gameDF
name <- "RJ Davis"
#name <- "Armando Bacot"
team <- NA
ID <- NA
teamPlot <- FALSE
#teamPlot <- TRUE
defense <- FALSE
#name <- "Arizona"
plotType <- "shots"
lastNgames <- "all"
oppList <- "all"
colPalette <- "blueRed"
saveDir <- "/Users/ryan/Dropbox (Personal)/misc/bball_stats/gz22/plots"

plotShots <- function(allShots = shotDF, gameData = gameDF, name = "Caleb Love", ID = NA, 
                      team = NA, teamPlot = FALSE, defense = FALSE,
                      plotType = "shots", lastNgames = "all", oppList = "all",
                      colPalette = "blueRed", 
                      saveDir = "~/Dropbox (Personal)/misc/bball_stats/") {
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
  
  #limit games
  if (lastNgames != "all") {
    shooterGames <- unique(plotShots$gameNum)
    shooterGameData <- gameData[gameData$gameNum %in% shooterGames,]
    #sort the games by reverse date
    shooterGameData <- shooterGameData[order(as.Date(shooterGameData$date, format = "%B %d %Y"), decreasing = TRUE),]
    plotGames <- shooterGameData$gameNum[1:lastNgames]
    
    plotShots <- subset(plotShots, gameNum %in% plotGames)
    
    playerTitle <- paste0(plotShots$playerName[1],"last",lastNgames,"games")
    
  } else if (oppList != "all") {
    #limit opponents
    plotShots <- subset(plotShots, oppTeam %in% oppList)
  }
  
  #generate +/- average
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
  
  
  
  shotPlot <- ggplot(data = plotShots,
         aes(x = baseline,
             y = depth,
             col = sqDiffLim)) +
    geom_polygon(data = court[court$side==1,], aes(x = x, y = y, group = group), col = "gray50") +
    coord_equal() + xlim(-3,54) + ylim(-3,50) +
    xlab("") + ylab("") +
    geom_jitter(alpha = 2/3, size = 2.5, width = .5, height = .5) +
    #geom_point(alpha = .66, size = 2) +
    scale_colour_gradientn(colors = plotCols3,limits=c(-25, 25)) +
    labs(col = "FG% +/-\nNCAA Avg") +
    ggtitle(playerTitle) +
    theme_classic() +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(), axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(), axis.title = element_blank(),
          axis.line=element_blank())
  
  #add last n games, opponents, colors, 
  ggsave(filename = paste0(saveDir,"/",playerTitle,"_shots.png"), 
         plot = shotPlot)
  
  
  
  ### zone version
  zonePlot <- ggplot() +
    geom_polygon(data = court[court$side==1,], aes(x = x, y = y, group = group), col = "gray50") +
    geom_polygon(data = sqPoly, aes(x = x, y = y, group = group, fill = sqDiffLim), alpha = .75) +
    geom_jitter(data = plotShots,
               aes(x = baseline,
                   y = depth),
                   alpha = .15, size = 2.5) +
    coord_equal() +
    scale_y_continuous(breaks = c(0, 23.5, 47)) +
    scale_x_continuous(breaks = c(0, 12.5, 25, 37.5, 50)) +
    xlab("") + ylab("") +
    scale_fill_gradientn(colours = plotCols3,limits=c(-25, 25)) +
    labs(fill = "FG% +/-\nNCAA Avg") +
    ggtitle(playerTitle) +
    theme_classic() +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(), axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(), axis.title = element_blank(),
          axis.line=element_blank())
  
  ggsave(filename = paste0(saveDir,"/",playerTitle,"_zones.png"), 
         plot = zonePlot)
  
  #data frame of: zones, percents, number shots, points added
  
}