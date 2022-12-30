allShots <- shotDF
gameData <- gameDF
name <- "Caleb Love"
#name <- "RJ Davis"
#name <- "Armando Bacot"
#name <- "Pete Nance"
team <- NA
ID <- NA
teamPlot <- FALSE
plotType <- "shots"
lastNgames <- "all"
oppList <- "all"
colPalette <- "blueRed"
saveDir <- "/Users/ryan/Dropbox (Personal)/misc/bball_stats/gz22/plots"

plotShots <- function(allShots = shotDF, gameData = gameDF, name = "Caleb Love", ID = NA, 
                      team = NA, teamPlot = FALSE,
                      plotType = "shots", lastNgames = "all", oppList = "all",
                      colPalette = "blueRed", 
                      saveDir = "~/Dropbox (Personal)/misc/bball_stats/") {
  ###############
  ## draw the court ##

  
  # http://stackoverflow.com/questions/6862742/draw-a-circle-with-ggplot2
  # Function to create circles
  circle_fun <- function(center=c(0,0), diameter=1, npoints=500, start=0, end=2){
    tt <- seq(start*pi, end*pi, length.out=npoints)
    data.frame(
      x = center[1] + diameter / 2 * cos(tt),
      y = center[2] + diameter / 2 * sin(tt)
    )
  }
  
  # Gives y coordinates of the opposite side
  rev_y <- function(y) 94-y
  
  # Converts inches to feet
  inches_to_feet <- function(x) x/12
  
  # Given the angle theta and the court data frame,
  # rotates the coordinates of the court by an angle theta
  rotate_court <- function(court, theta=pi/2){
    court_r <- court
    court_r$x <- court_r$x / 180 * pi
    court_r$y <- court_r$y / 180 * pi
    matrice_r <- matrix(c(cos(theta), sin(theta), -sin(theta), cos(theta)), ncol = 2)
    coords_r <- apply(court_r[,c("x","y")], 1, function(x) x %*% matrice_r)
    court_r$x <- coords_r[1,] ; court_r$y <- coords_r[2,]
    court_r$x <- court_r$x * 180 / pi
    court_r$y <- court_r$y * 180 / pi
    return(court_r)
  }
  
  # From x and y coordinates for a line (represented by a polygon here),
  # a number of group and a short description
  # creates a data.frame for this line
  # in order to use it with ggplot2.
  new_coords <- function(x, y, group, descri){
    new_coords_df <- data.frame(x = x, y = y)
    new_coords_df$group <- group
    new_coords_df$side <- 1
    group <- group + 1
    
    # The same thing for the opposite side
    new_coords_df2 <- data.frame(x = x, y = rev_y(y))
    new_coords_df2$group <- group
    new_coords_df2$side <- 2
    group <<- group + 1
    
    # On reunit les donnees
    new_coords_df <- rbind(new_coords_df, new_coords_df2)
    new_coords_df$descri <- descri
    
    return(new_coords_df)
  }
  

  ## THE COURT ##

  
  # 3 pts circle
  cercle_3pts.out <- circle_fun(center = c(25,inches_to_feet(63)), diameter = (20+inches_to_feet(9))*2)
  cercle_3pts.in <- circle_fun(center = c(25,inches_to_feet(63)), diameter = (20+inches_to_feet(7))*2)
  # Basket circle
  cercle_ce <- circle_fun(center = c(25,5+3/12), diameter = 1.5)
  # Free throw circle
  cercle_lf.out <- circle_fun(center = c(25,19), diameter = 6*2)
  cercle_lf.in <- circle_fun(center = c(25,19), diameter = (6-1/6)*2)
  # Middle circle
  cercle_mil.out <- circle_fun(center = c(25,47), diameter = 6*2)
  cercle_mil.in <- circle_fun(center = c(25,47), diameter = (6-1/6)*2)
  
  
  group <- 1 # We assign the first group, and it gets incremented with each use of new_coords()
  court <- new_coords(c(0-1/6,0-1/6,53 + 1/6,53 + 1/6), c(0 - 1/6,0,0,0 - 1/6), group = group, descri = "ligne de fond")
  court <- rbind(court, new_coords(x = c(0-1/6,0-1/6,0,0), y = c(0,47-1/12,47-1/12,0), group = group, descri = "ligne gauche"))
  court <- rbind(court, new_coords(x = c(50,50,50+1/6,50+1/6), y = c(0,47-1/12,47-1/12,0), group = group, descri = "ligne droite"))
  court <- rbind(court, new_coords(x = c(47,47,53,53), y = c(28,28+1/6,28+1/6,28), group = group, descri = "marque entraineur droite"))
  court <- rbind(court, new_coords(x = c(inches_to_feet(51),inches_to_feet(51),inches_to_feet(51)+1/6,inches_to_feet(51)+1/6), y = c(0,inches_to_feet(63),inches_to_feet(63),0), group = group, descri = "3pts bas gauche"))
  court <- rbind(court, new_coords(x = c(50-inches_to_feet(51)-1/6,50-inches_to_feet(51)-1/6,50-inches_to_feet(51),50-inches_to_feet(51)), y = c(0,inches_to_feet(63),inches_to_feet(63),0), group = group, descri = "3pts bas droit"))
  court <- rbind(court, new_coords(x = c(19,19,19+1/6,19+1/6), y = c(0,19,19,0), group = group, descri = "LF bas gauche"))
  court <- rbind(court, new_coords(x = c(31-1/6,31-1/6,31,31), y = c(0,19,19,0), group = group, descri = "LF bas droit"))
  court <- rbind(court, new_coords(x = c(19,19,31,31), y = c(19-1/6,19,19,19-1/6), group = group, descri = "LF tireur"))
  court <- rbind(court, new_coords(x = c(22, 22, 28, 28), y = c(4-1/6,4,4,4-1/6), group = group, descri = "planche"))
  court <- rbind(court, new_coords(x = c(cercle_3pts.out[1:250,"x"], rev(cercle_3pts.in[1:250,"x"])),
                                   y = c(cercle_3pts.out[1:250,"y"], rev(cercle_3pts.in[1:250,"y"])), group = group, descri = "cercle 3pts"))
  court <- rbind(court, new_coords(x = c(cercle_lf.out[1:250,"x"], rev(cercle_lf.in[1:250,"x"])),
                                   y = c(cercle_lf.out[1:250,"y"], rev(cercle_lf.in[1:250,"y"])), group = group, descri = "cercle LF haut"))
  court <- rbind(court, new_coords(x = c(19-0.5,19-0.5,19,19), y = c(7,8,8,7), group = group, descri = "marque 1 LF gauche"))
  court <- rbind(court, new_coords(x = c(19-0.5,19-0.5,19,19), y = c(11,11+inches_to_feet(2),11+inches_to_feet(2),11), group = group, descri = "marque 2 LF gauche"))
  court <- rbind(court, new_coords(x = c(19-0.5,19-0.5,19,19), y = c(14+inches_to_feet(2),14+inches_to_feet(4),14+inches_to_feet(2),14+inches_to_feet(2)), group = group, descri = "marque 3 LF gauche"))
  court <- rbind(court, new_coords(x = c(19-0.5,19-0.5,19,19), y = c(17+inches_to_feet(4),17+inches_to_feet(6),17+inches_to_feet(6),17+inches_to_feet(4)), group = group, descri = "marque 4 LF gauche"))
  court <- rbind(court, new_coords(x = c(31,31,31+0.5,31+0.5), y = c(7,8,8,7), group = group, descri = "marque 1 LF droite"))
  court <- rbind(court, new_coords(x = c(31,31,31+0.5,31+0.5), y = c(11,11+inches_to_feet(2),11+inches_to_feet(2),11), group = group, descri = "marque 2 LF droite"))
  court <- rbind(court, new_coords(x = c(31,31,31+0.5,31+0.5), y = c(14+inches_to_feet(2),14+inches_to_feet(4),14+inches_to_feet(4),14+inches_to_feet(2)), group = group, descri = "marque 3 LF droite"))
  court <- rbind(court, new_coords(x = c(0-1/6,0-1/6,50+1/6,50+1/6), y = c(94/2-1/12,94/2, 94/2, 94/2-1/12), group = group, descri = "ligne mediane"))
  court <- rbind(court, new_coords(x = c(31,31,31+0.5,31+0.5), y = c(17+inches_to_feet(4),17+inches_to_feet(6),17+inches_to_feet(6),17+inches_to_feet(4)), group = group, descri = "marque 4 LF droite"))
  court <- rbind(court, new_coords(x = c(cercle_mil.out[250:500,"x"], rev(cercle_mil.in[250:500,"x"])),
                                   y = c(cercle_mil.out[250:500,"y"], rev(cercle_mil.in[250:500,"y"])), group = group, descri = "cercle milieu grand"))
  court <- rbind(court, new_coords(x = cercle_ce[,"x"], y = cercle_ce[,"y"], group = group, descri = "anneau"))
  
  
  ## PLOTS ##
  
  # Half court
  P_half <- ggplot() + geom_polygon(data = court[court$side==1,], aes(x = x, y = y, group = group), col = "gray") +
    coord_equal() +
    xlim(-3,54) +
    ylim(-3,50) +
    scale_y_continuous(breaks = c(0, 23.5, 47)) +
    scale_x_continuous(breaks = c(0, 12.5, 25, 37.5, 50)) +
    xlab("") + ylab("") +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(), axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank(), axis.title = element_blank()
    )
  #P_half
  
  ###############
  
  #plotType - shots, zones
  
  if(colPalette == "blueRed") {
    plotCols3 <- c("#4B9CD3","gray80","#E63238")
    plotCols2 <- c("#4B9CD3","#E63238")
  }
  
  ###team plot
  if (teamPlot == TRUE) {
    
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
  }
  
  #limit games
  if (lastNgames != "all") {
    shooterGames <- unique(plotShots$gameNum)
    shooterGameData <- gameData[gameData$gameNum %in% shooterGames,]
    #sort the games by reverse date
    shooterGameData <- shooterGameData[order(as.Date(shooterGameData$date, format = "%B %d %y"), decreasing = TRUE),]
    plotGames <- shooterGameData$gameNum[1:lastNgames]
    
    plotShots <- subset(plotShots, gameNum %in% plotGames)
    
  } else if (oppList != "all") {
    #limit opponents
    plotShots <- subset(plotShots, oppTeam %in% oppList)
  }
  
  #generate +/- average
  plotShots$sqDiff <- 0
  
  for (sq in unique(plotShots$shotQuadrant)) {
    #sq <- "Three_Center"
    quadrantAvg <- mean(subset(plotShots, shotQuadrant == sq)$points != 0)
    qNCAAAavg <- mean(subset(plotShots, shotQuadrant == sq)$expFGPer)
    sqDiff <- 100 * (quadrantAvg - qNCAAAavg)
    plotShots$sqDiff[plotShots$shotQuadrant == sq] <- sqDiff
    print(paste0(sq," - ",sqDiff))
  }
  
  plotShots$sqDiffLim <- ifelse(plotShots$sqDiff > 25, 25,
                                ifelse(plotShots$sqDiff < -25, -25, plotShots$sqDiff))
  
  playerTitle <- plotShots$playerName[1]
  
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
  ggsave(filename = paste0(saveDir,"/",playerTitle,".png"), 
         plot = shotPlot)
  
  ### zone version
  #getting the convex hull of each unique point set
  #df <- nomissing
  find_hull <- function(df) df[chull(df$baseline, df$depth), ]
  hulls <- ddply(allShots, "shotQuadrant", find_hull)
  
  sQuads <- data.frame(c(20,20,30,30),
                       c(5,10,10,5),
                       c(1,1,1,1),
                       c("AtRim","AtRim","AtRim","AtRim"))
  
  colnames(sQuads) <- c("baseline","depth","group","sq")
  
  ggplot(data = plotShots,
         aes(x = baseline,
             y = depth,
             col = shotQuadrant)) +
    geom_polygon(data = court[court$side==1,], aes(x = x, y = y, group = group), col = "gray50") +
    geom_polygon(data = sQuads, aes(x = baseline, y = depth, group = group, col = sq, fill = sq), alpha = .2) +
    coord_equal() + xlim(-3,54) + ylim(-3,50) +
    xlab("") + ylab("") +
    geom_point(alpha = 2/3, size = 2.5)
  
}