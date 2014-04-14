
# phenology graphs
phenoGraph <- function(input) {
  
  require(ggplot2)
  require(gridExtra)
  
  what = input$phenoType
  d = phenologyDataFetch(what)
  
  P = ggplot(d, aes(x= var , fill = Year), environment=environment()) + 
    geom_density(alpha = 0.7) + 
    xlab( paste(what, "(day 1 = April 1st)" ) )
  
  #first egg prediction based on Apr temperature
  if( what == 'firstEgg') {
    d = ldPredictDataFetch()
    p2 = ggplot(d, aes(x = avg_temp, y = firstEgg_AprilDay, label= year_)) + theme_bw() + 
      geom_text(vjust= -0.5, hjust = -0.4, size = 4) + 
      geom_point(size = 5)  + 
      ylab("First Egg (day 1 = 1st April)") + 
      xlab("Average minimum daily temperature [14 Mar-1Apr]")+ 
      scale_y_continuous(breaks=seq(1, 20, 1)) + 
      xlim(-4,5)
  }
  
  if( what == 'firstEgg')
    grid.arrange(P, p2) else print(P) 
  
  
  
}	

# ID history
IDGraph <- function(input) {
	require(gridExtra)
	require(ggplot2)
  
	d = idDataFetch(id = input$birdID)
	d$x = d$x - min(d$x)
	d$y = d$y - min(d$y)

	# IDs
	ids = data.frame(id = unique(na.omit(c( as.character(na.omit(d$ID )), as.character(na.omit(d$cb )), as.character(na.omit(d$transponder )) )))   )
	names(ids) = d$sex[1]
	ids = tableGrob(ids, h.even.alpha=1, h.odd.alpha=1,  v.even.alpha=0.5, v.odd.alpha=1,  show.rownames = FALSE)

	# Tarsus
	tl = tarsusDataFetch()
	tl = ggplot(tl, aes(x=tarsus, fill= sex) ) + geom_density(alpha=.3) + geom_vline(xintercept = mean(d$tarsus, na.rm = TRUE) ) +  theme(plot.margin = unit(c(0,0,0,0), "mm"))
	
	# Body mass
	bm = massDataFetch()
	bm = ggplot(bm, aes(x=weight, fill= sex) ) + geom_density(alpha=.3) + geom_vline(xintercept = mean(d$weight, na.rm = TRUE) ) +  theme(plot.margin = unit(c(0,0,0,0), "mm"))
	
	
	# Boxes  & dates
	mp = ggplot(d, aes(x, y, col = tab) ) +  geom_point(size = 5, alpha = .5) + geom_text( aes(label=box), hjust=.5,  vjust=-1) + geom_text( aes(label=year_), hjust=.5,  vjust=1) + 
		xlab("x (meters)") + ylab("y (meters)") +  xlim(-10, max(d$x)+10  )  +  ylim(-10, max(d$y)+10  )  + theme(plot.margin = unit(c(0,0,0,0), "mm"))
	

	# Plots
	print(grid.arrange(ids, mp, tl, bm, ncol = 2))
	
 }
