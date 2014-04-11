
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
  id = input$birdID
  
  plot(1, main = 'UNDER CONSTRUCTION', sub = id)
  
  
  
  }
