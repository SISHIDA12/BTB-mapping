# functions for producing the file names for segregation map / conditional probability heat map

heat_names <- function(n_year,cat){
  l <- vector("list", 14)
  for (i in 1:n_year){
    year <- as.character(i + 1988)
    n_cat <- length(cat)
    temp_names <- vector("character",n_cat)
    for (c in 1:n_cat){
      temp_names[c] <- paste0("GPMCst", year, "heat", cat[c], ".png")
    }
    l[[i]] <- temp_names
  }
  return(l)
}

seg_name <- function(n_year, cutoff){
  p <- gsub('[.]', '', as.character(cutoff))
  l <- vector("character", 14)
  for (i in 1:n_year){
    year <- as.character(i + 1988)
    l[i] <- paste0("GPMCst", year, "seg", p, ".png")
  }
  return(l)
}
