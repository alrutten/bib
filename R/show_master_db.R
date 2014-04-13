
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

	# IDs
	ids = data.frame(id = unique(na.omit(c( as.character(na.omit(d$ID )), as.character(na.omit(d$cb )), as.character(na.omit(d$transponder )) )))   )
	ids = tableGrob(ids, h.even.alpha=1, h.odd.alpha=1,  v.even.alpha=0.5, v.odd.alpha=1,  show.rownames = FALSE)

	# Tarsus
	tl = tarsusDataFetch()
	tl = ggplot(tl, aes(x=tarsus, fill= sex) ) + geom_density(alpha=.3) + geom_vline(mean(d$tarsus, na.rm = TRUE)) geom_hline(aes(yintercept = z), hline.data)
	tl
	
	# Plots
	grid.arrange
	grid.draw(ids)

  
  
  
  
  
  
  
  
  
 }
