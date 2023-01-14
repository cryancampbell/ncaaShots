plotShots <- subset(shotDF, playerName == "Caleb Love" & team.x == "home" & gameNum != 2475386 & gameNum != 2479353)
plotTitle <- "Caleb Home Cookin'"
gameData <- gameDF
playerData <- playerDF
colPalette <- "blueRed"
saveDir <- "/Users/ryan/Dropbox (Personal)/misc/bball_stats/gz22/plots"

plotFromDF <- function(plotShots = shotsToPlot, gameData = gameDF, playerData = playerDF,
                       plotTitle = "Just a Plot", colPalette = "blueRed", 
                       saveDir = "/Users/ryan/Dropbox (Personal)/misc/bball_stats/gz22/plots") {
  
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
  
  #plot info
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
    coord_equal() + xlim(-3,54) + ylim(-3,50) +
    scale_y_continuous(breaks = c(0, 23.5, 47)) +
    scale_x_continuous(breaks = c(0, 12.5, 25, 37.5, 50)) +
    xlab("") + ylab("") +
    geom_jitter(data = plotShots, aes(x = baseline,
                                     y = depth,
                                     col = sqDiffLim,
                                     shape = outcome), size = 3, stroke = 2, height = .4, width = .4) +
    scale_shape_manual(values = c(4,1)) +
    scale_colour_gradientn(colors = plotCols3,limits=c(-25, 25)) +
    labs(col = "FG% +/-\nNCAA Avg") +
    ggtitle(paste0(plotTitle),
            subtitle = paste0(plusOrMinus,addedPointsPerGame," points/game on ",totalShotsPerGame," shots/game, ",plotGames," games")) +
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
  
  shotPlot <- shotPlot + geom_image(x = 5, y = 42, aes(image = "~/Dropbox (Personal)/misc/bball_stats/5F/5F.png"), size = .1)
  
  #add last n games, opponents, colors, 
  ggsave(filename = paste0(saveDir,"/",plotTitle,"_shots.png"), 
         plot = shotPlot, height = 8, width = 8)
  
  
  sqPolySingleGame <- subset(sqPoly, group %in% unique(plotShots$shotQuadrant))
  
  ### zone version
  zonePlot <- ggplot() +
    geom_polygon(data = sqPolySingleGame, aes(x = x, y = y, group = group, fill = sqDiffLim), alpha = .75) +
    geom_jitter(data = plotShots,
                aes(x = baseline,
                    y = depth,
                    shape = outcome),
                alpha = 1/3, size = 2, stroke = 1.5, height = .25, width = .25) +
    geom_polygon(data = court[court$side==1,], aes(x = x, y = y, group = group), col = "gray50") +
    coord_equal() + xlim(-3,54) + ylim(-3,50) +
    scale_y_continuous(breaks = c(0, 23.5, 47)) +
    scale_x_continuous(breaks = c(0, 12.5, 25, 37.5, 50)) +
    xlab("") + ylab("") +
    scale_fill_gradientn(colours = plotCols3,limits=c(-25, 25)) +
    labs(fill = "FG% +/-\nNCAA Avg") +
    scale_shape_manual(values = c(4,1)) +
    ggtitle(paste0(plotTitle),
            subtitle = paste0(plusOrMinus,addedPointsPerGame," points/game on ",totalShotsPerGame," shots/game, ",plotGames," games")) +
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
  
  zonePlot <- zonePlot + geom_image(x = 5, y = 42, aes(image = "~/Dropbox (Personal)/misc/bball_stats/5F/5F.png"), size = .1)
  
  ggsave(filename = paste0(saveDir,"/",plotTitle,"_zones.png"), 
         plot = zonePlot, height = 8, width = 8)
  
  #data frame of: zones, percents, number shots, points added
  
}
