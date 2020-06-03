# functions for producing segregation map / conditional probability heat map

prep_heatmap <- function(pred_values, gr, n_class) {
  #A function to transform the predicted probabilities to Matrix over specified area
  #input: pred_values - dataframe of predicted probabilities
  #       gr - grid to peoject predicted values
  #       n_class - number of classes/category
  #output: C(number of category) matrices to be used to make heatmap 
  
  n_row <- length(levels(as.factor(gr$north)))
  n_col <- length(levels(as.factor(gr$east)))
  w_row <- (max(gr$north)-min(gr$north))/(n_row-1)
  w_col <- (max(gr$east)-min(gr$east))/(n_col-1)
  temp <- merge(gr, pred_values, all=T)
  temp[is.na(temp)] <- NaN
  A <- vector("list", n_class)
  
  for (c in 1:n_class){
    A[[c]] <- matrix(rep(0, n_row*n_col), nrow = n_row, ncol = n_col)
    for(i in 1:n_row){
      for (j in 1:n_col){
        A[[c]][i,j] <- temp[,c+2][temp$east==min(temp$east)+(j-1)*w_col & temp$north==min(temp$north)+(n_row-i)*w_row ]
      }
    }
  }
  return(A)
}

heatmap <- function(pred_values, gr, n_class, filenames){
  #input: pred_values - dataframe of predicted probabilities
  #       gr - grid/datapoints
  #       n_class - number of classes
  #       filenames - the charactor vector of the names of the plots
  #output: C(number of category) heatmaps of predicted conditional probability 
  long_max <- max(gr[,1]); long_min <- min((gr[,1]))
  lat_max <- max(gr[,2]); lat_min <- min((gr[,2]))
  n_row <- length(levels(as.factor(gr$north)))
  n_col <- length(levels(as.factor(gr$east)))
  temp <- SpatialPoints(matrix(c(long_min, long_max, lat_max, lat_min), 2, 2), proj4string = CRS("+init=epsg:27700"))
  temp <- coordinates(spTransform(temp, CRS("+init=epsg:3857")))
  pr <- raster(nrows = n_row, ncols = n_col, 
               xmn = temp[1, 1], xmx = temp[2, 1], ymn = temp[2,2], ymx = temp[1, 2], crs = CRS("+init=epsg:3857"))
  
  p_mat <- prep_heatmap(pred_values, gr, n_class)
  cpal <- rev(heat.colors(64, alpha = 0.5))
  
  for (c in 1:n_class){
    ras <- raster(p_mat[[c]], xmn = long_min, xmx = long_max,  ymn = lat_min, ymx = lat_max, crs = CRS("+init=epsg:27700"))
    tp <- projectRaster(ras, pr)
    # plot
    par(mar=rep(2,4))
    par("fin"=c(width=5.5, height=5.5))
    png(filename=paste(filenames[c]),  width = 550, height = 550)
    plot(sdmc$window, main = "", lwd = 0.5)
    plot(ncmap, add = TRUE)
    #plot(ncmap)
    plot(tp, add = TRUE, legend = FALSE, col = cpal, zlim = c(0, 1))
    dev.off()
  }
}

segregation_map <- function(pred_values, n_class, name, cutoff){
  #input: pred_values - dataframe of predicted probabilities
  #       n_class - number of classes
  #       name - names of the segregation plot
  #       cutoff - threshhold probability
  #output: segragation/classification map 
  temp<- pred_values
  coordinates(temp)<-~east+north
  proj4string(temp)<-CRS("+init=epsg:27700")
  map <- coordinates(spTransform(temp, CRS("+init=epsg:3857")))
  map <- cbind(map, pred_values[,3:(n_class+4)])
  map <- subset(map, map[,n_class+3]>cutoff)
  
  par(mar=rep(2,4))
  par("fin"=c(width=5.5, height=5.5))
  png(filename = paste(name),  width = 550, height = 550)
  plot(sdmc$window, main = "", lwd = 0.5)
  plot(ncmap, add = TRUE)
  #plot(ncmap)
  for (c in 1:n_class){
    points(map$east[map[,n_class+4]==c], map$north[map[,n_class+4]==c], type="p", col=cols[c], pch=20) 
  }
  dev.off()
}
