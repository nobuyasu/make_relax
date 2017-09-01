run_boxplot <- function( data, name )
{
  names( data ) <- filenames
  data.melt <- melt( data )
  data.melt$L1 <- factor( data.melt$L1, filenames, labels=filenames )
  g1 <- ggplot( data=data.melt, aes( x=L1, y=value ) )
  g1 <- g1 + geom_boxplot()
  g1 <- g1 + ggtitle( name )
  g1 <- g1 + xlab( "" )
  g1 <- g1 + ylab( name )
  return( g1 )
}

library(gridExtra)
library(stringr)
library(ggplot2)
library(reshape2)

args = commandArgs(trailingOnly=TRUE)
title = args[1]
outfile = args[2]
sizex   = args[3]
sizey   = args[4]

readdir = commandArgs(trailingOnly=TRUE)[5:length(args)]

pdf( outfile, family = "Helvetica", width=sizez, height=sizey )

score <- list()
vdw   <- list()
hbond <- list()
solv  <- list()
filenames  <- vector()

for( jj in 5:length( readdir ) ) {

  filename  = rev( str_split( readdir[jj], "/" )[[1]] )[1]
  files = list.files( path=readdir[jj], pattern="*.sc" )

  for( ii in 1:length( files ) ) {
    if( ii == 1 ) {
      data <- read.table( paste( readdir[jj], "/", files[ii], sep="" ), header=TRUE, skip=1 )
    } else {
         d <- read.table( paste( readdir[jj], "/", files[ii], sep="" ), header=TRUE, skip=1 )
      data <- rbind( data, d )
    }
  }

  s <- data$score - data$ref
  v <- data$fa_atr + data$fa_rep
  h <- data$hbond_sr_bb + data$hbond_lr_bb + data$hbond_sc + data$hbond_bb_sc
  o <- data$fa_sol

  score <- c( score, list( s ) )
    vdw <- c(   vdw, list( v ) )
  hbond <- c( hbond, list( h ) )
   solv <- c(  solv, list( o ) )

  filenames <- c( filenames, filename )
}

g1 <- run_boxplot( score, "total_score" )
g2 <- run_boxplot( vdw,   "vdw")
g3 <- run_boxplot( hbond, "hbond")
g4 <- run_boxplot( solv,  "solv")

grid.arrange( g1, g2, g3, g4, ncol=2, top=title )

dev.off()
