gitDir <- "~/Documents/giterdone/ncaaShots/"
dataDir <- paste0(gitDir,"data/")

#court and quadrants

### court
###############
## draw the court ##

hoop <- c(0,4.75)
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

halfcourt <- court[court$side==1,]
## PLOTS ##

# Half court
ggplot() + 
  geom_polygon(data = halfcourt, aes(x = x, y = y, group = group), col = "black") +
  coord_equal() +
  #xlim(-3,54) +
  #ylim(-3,50) +
  scale_y_continuous(breaks = c(0, 23.5, 47)) +
  scale_x_continuous(breaks = c(0, 12.5, 25, 37.5, 50)) +
  xlab("") + ylab("") +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(), axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(), axis.title = element_blank()
  )

saveRDS(halfcourt,
        file = paste0(dataDir,"court.RDS"))

#### quadrants

#rim poly
atRimCirc <- circle_fun(center = c(25,4.75), diameter = 5*2)
atRimCirc$group <- "AtRim"

atRimCirc <- subset(atRimCirc, y > 4)

atRimCirc$angle <- ifelse(atRimCirc$x >= 25,
                             180 + round(atan(-(atRimCirc$y - hoop[2])/(atRimCirc$x - 25)) * 180/pi, digits = 1),
                             round(atan(-(atRimCirc$y - hoop[2])/(atRimCirc$x - 25)) * 180/pi, digits = 1))

#short right
shortRightCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 10*2),
                    circle_fun(center = c(25,4.75), diameter = 5.1*2)[dim(circle_fun(center = c(25,4.75), diameter = 5.1*2))[1]:1,])
shortRightCirc$group <- "5-10ft_Right"

shortRightCirc$angle <- ifelse(shortRightCirc$x >= 25, 
       180 + round(atan(-(shortRightCirc$y - hoop[2])/(shortRightCirc$x - 25)) * 180/pi, digits = 1),
       round(atan(-(shortRightCirc$y - hoop[2])/(shortRightCirc$x - 25)) * 180/pi, digits = 1))

shortRightCirc <- subset(shortRightCirc, angle <= 50 & y > 3)

#short mid
shortMidCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 10*2),
                        circle_fun(center = c(25,4.75), diameter = 5.1*2)[dim(circle_fun(center = c(25,4.75), diameter = 5.1*2))[1]:1,])
shortMidCirc$group <- "5-10ft_Center"

shortMidCirc$angle <- ifelse(shortMidCirc$x >= 25, 
                               180 + round(atan(-(shortMidCirc$y - hoop[2])/(shortMidCirc$x - 25)) * 180/pi, digits = 1),
                               round(atan(-(shortMidCirc$y - hoop[2])/(shortMidCirc$x - 25)) * 180/pi, digits = 1))

shortMidCirc <- subset(shortMidCirc, angle >= 50 & angle <= 130)

#short left
shortLeftCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 10*2, start = 1, end = 3),
                      circle_fun(center = c(25,4.75), diameter = 5.1*2, start = 1, end = 3)[dim(circle_fun(center = c(25,4.75), diameter = 5.1*2))[1]:1,])
shortLeftCirc$group <- "5-10ft_Left"

shortLeftCirc$angle <- ifelse(shortLeftCirc$x >= 25, 
                             180 + round(atan(-(shortLeftCirc$y - hoop[2])/(shortLeftCirc$x - 25)) * 180/pi, digits = 1),
                             round(atan(-(shortLeftCirc$y - hoop[2])/(shortLeftCirc$x - 25)) * 180/pi, digits = 1))

shortLeftCirc <- subset(shortLeftCirc, angle >= 130 & y > 3)

#mid right
midRightCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 20.5*2),
                        circle_fun(center = c(25,4.75), diameter = 10.1*2)[dim(circle_fun(center = c(25,4.75), diameter = 10.1*2))[1]:1,])
midRightCirc$group <- "10-22ft_Right"

midRightCirc$angle <- ifelse(midRightCirc$x >= 25, 
                               180 + round(atan(-(midRightCirc$y - hoop[2])/(midRightCirc$x - 25)) * 180/pi, digits = 1),
                               round(atan(-(midRightCirc$y - hoop[2])/(midRightCirc$x - 25)) * 180/pi, digits = 1))

midRightCirc <- subset(midRightCirc, angle <= 36 & y > 2)

#mircent right
midRightCenterCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 20.5*2),
                      circle_fun(center = c(25,4.75), diameter = 10.1*2)[dim(circle_fun(center = c(25,4.75), diameter = 10.1*2))[1]:1,])
midRightCenterCirc$group <- "10-22ft_Right-Mid"

midRightCenterCirc$angle <- ifelse(midRightCenterCirc$x >= 25, 
                             180 + round(atan(-(midRightCenterCirc$y - hoop[2])/(midRightCenterCirc$x - 25)) * 180/pi, digits = 1),
                             round(atan(-(midRightCenterCirc$y - hoop[2])/(midRightCenterCirc$x - 25)) * 180/pi, digits = 1))

midRightCenterCirc <- subset(midRightCenterCirc, angle >= 36 & angle <= 72)

#midcent
midCenterCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 20.5*2),
                            circle_fun(center = c(25,4.75), diameter = 10.1*2)[dim(circle_fun(center = c(25,4.75), diameter = 10.1*2))[1]:1,])
midCenterCirc$group <- "10-22ft_Center"

midCenterCirc$angle <- ifelse(midCenterCirc$x >= 25, 
                                   180 + round(atan(-(midCenterCirc$y - hoop[2])/(midCenterCirc$x - 25)) * 180/pi, digits = 1),
                                   round(atan(-(midCenterCirc$y - hoop[2])/(midCenterCirc$x - 25)) * 180/pi, digits = 1))

midCenterCirc <- subset(midCenterCirc, angle >= 72 & angle <= 108)

#midcent left
midLeftCenterCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 20.5*2, start = 1, end = 3),
                       circle_fun(center = c(25,4.75), diameter = 10.1*2, start = 1, end = 3)[dim(circle_fun(center = c(25,4.75), diameter = 10.1*2))[1]:1,])
midLeftCenterCirc$group <- "10-22ft_Left-Mid"

midLeftCenterCirc$angle <- ifelse(midLeftCenterCirc$x >= 25, 
                              180 + round(atan(-(midLeftCenterCirc$y - hoop[2])/(midLeftCenterCirc$x - 25)) * 180/pi, digits = 1),
                              round(atan(-(midLeftCenterCirc$y - hoop[2])/(midLeftCenterCirc$x - 25)) * 180/pi, digits = 1))

midLeftCenterCirc <- subset(midLeftCenterCirc, angle >= 108 & angle <= 144)

#mid left
midLeftCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 20.5*2, start = 1, end = 3),
                       circle_fun(center = c(25,4.75), diameter = 10.1*2, start = 1, end = 3)[dim(circle_fun(center = c(25,4.75), diameter = 10.1*2))[1]:1,])
midLeftCirc$group <- "10-22ft_Left"

midLeftCirc$angle <- ifelse(midLeftCirc$x >= 25, 
                              180 + round(atan(-(midLeftCirc$y - hoop[2])/(midLeftCirc$x - 25)) * 180/pi, digits = 1),
                              round(atan(-(midLeftCirc$y - hoop[2])/(midLeftCirc$x - 25)) * 180/pi, digits = 1))

midLeftCirc <- subset(midLeftCirc, angle >= 144 & y > 2)


#three right
threeRightCirc <- rbind(c(1,1.197461),
                        #circle_fun(center = c(25,4.75), diameter = 30*2),
                      circle_fun(center = c(25,4.75), diameter = 21*2)[dim(circle_fun(center = c(25,4.75), diameter = 21*2))[1]:1,],
                      c(1,15))
threeRightCirc$group <- "Three_Right"

threeRightCirc$angle <- ifelse(threeRightCirc$x >= 25, 
                             180 + round(atan(-(threeRightCirc$y - hoop[2])/(threeRightCirc$x - 25)) * 180/pi, digits = 1),
                             round(atan(-(threeRightCirc$y - hoop[2])/(threeRightCirc$x - 25)) * 180/pi, digits = 1))

threeRightCirc <- subset(threeRightCirc, y >= 1 & y <= 15 & angle <= 36 & x >= 1)

#three cent right
threeRightCenterCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 30*2),
                              c(1,15.25),
                            circle_fun(center = c(25,4.75), diameter = 21*2)[dim(circle_fun(center = c(25,4.75), diameter = 21*2))[1]:1,])
threeRightCenterCirc$group <- "Three_Right-Mid"

threeRightCenterCirc$angle <- ifelse(threeRightCenterCirc$x >= 25, 
                                   180 + round(atan(-(threeRightCenterCirc$y - hoop[2])/(threeRightCenterCirc$x - 25)) * 180/pi, digits = 1),
                                   round(atan(-(threeRightCenterCirc$y - hoop[2])/(threeRightCenterCirc$x - 25)) * 180/pi, digits = 1))

#threeRightCenterCirc <- subset(threeRightCenterCirc, angle >= 36 & angle <= 72)
threeRightCenterCirc <- subset(threeRightCenterCirc, y > 15 & angle <= 72 & x >= 1)

#three three
threeCenterCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 30*2),
                       circle_fun(center = c(25,4.75), diameter = 21*2)[dim(circle_fun(center = c(25,4.75), diameter = 21*2))[1]:1,])
threeCenterCirc$group <- "Three_Center"

threeCenterCirc$angle <- ifelse(threeCenterCirc$x >= 25, 
                              180 + round(atan(-(threeCenterCirc$y - hoop[2])/(threeCenterCirc$x - 25)) * 180/pi, digits = 1),
                              round(atan(-(threeCenterCirc$y - hoop[2])/(threeCenterCirc$x - 25)) * 180/pi, digits = 1))

threeCenterCirc <- subset(threeCenterCirc, angle >= 72 & angle <= 108)

#three cent left
threeLeftCenterCirc <- rbind(circle_fun(center = c(25,4.75), diameter = 30*2, start = 1, end = 3),
                           circle_fun(center = c(25,4.75), diameter = 21*2, start = 1, end = 3)[dim(circle_fun(center = c(25,4.75), diameter = 21*2))[1]:1,],
                           c(49,15.25))
threeLeftCenterCirc$group <- "Three_Left-Mid"

threeLeftCenterCirc$angle <- ifelse(threeLeftCenterCirc$x >= 25, 
                                  180 + round(atan(-(threeLeftCenterCirc$y - hoop[2])/(threeLeftCenterCirc$x - 25)) * 180/pi, digits = 1),
                                  round(atan(-(threeLeftCenterCirc$y - hoop[2])/(threeLeftCenterCirc$x - 25)) * 180/pi, digits = 1))

#threeLeftCenterCirc <- subset(threeLeftCenterCirc, angle >= 108 & angle <= 144)
threeLeftCenterCirc <- subset(threeLeftCenterCirc, angle >= 108 & y >= 15 & x <= 49)

#three left 
threeLeftCirc <- rbind(c(49,15),
                     circle_fun(center = c(25,4.75), diameter = 21*2, start = 1, end = 3)[dim(circle_fun(center = c(25,4.75), diameter = 21*2))[1]:1,],
                     c(49,1.197461))
threeLeftCirc$group <- "Three_Left"

threeLeftCirc$angle <- ifelse(threeLeftCirc$x >= 25, 
                            180 + round(atan(-(threeLeftCirc$y - hoop[2])/(threeLeftCirc$x - 25)) * 180/pi, digits = 1),
                            round(atan(-(threeLeftCirc$y - hoop[2])/(threeLeftCirc$x - 25)) * 180/pi, digits = 1))

#threeLeftCirc <- subset(threeLeftCirc, angle >= 144 & y > 1)
threeLeftCirc <- subset(threeLeftCirc, angle >= 144 & y <= 15 & y >= 1 & x < 50)


sqPoly <- rbind.data.frame(atRimCirc,
                           shortRightCirc,
                           shortMidCirc,
                           shortLeftCirc,
                           midRightCirc,
                           midRightCenterCirc,
                           midCenterCirc,
                           midLeftCenterCirc,
                           midLeftCirc,
                           threeRightCirc,
                           threeRightCenterCirc,
                           threeCenterCirc,
                           threeLeftCenterCirc,
                           threeLeftCirc)


ggplot() +
  geom_polygon(data = sqPoly, aes(x = x, y = y, fill = group)) +
  geom_polygon(data = halfcourt, aes(x = x, y = y, group = group), col = "black") +
  coord_equal() +
  scale_y_continuous(breaks = c(0, 23.5, 47)) +
  scale_x_continuous(breaks = c(0, 12.5, 25, 37.5, 50)) +
  xlab("") + ylab("") +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(), axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(), axis.title = element_blank()
  )

saveRDS(sqPoly,
        file = paste0(dataDir,"sqPoly.RDS"))
