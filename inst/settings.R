require(shiny)
require(sdb)
require(rgdal)
require(nlme)

# GIS
load(system.file('map', 'spatial', package = 'bib'))
load(system.file('hatchEstimation', 'hatchDateGLM', package = 'bib'))



# nest stages
stagesInfo = data.frame(
  nest_stage = c( "U", "LT" , "R" ,  "B"  , "BC" , "C" , "LIN"  ,  "E"  , "WE", "Y", "NOTA", "WSP") ,
  stageCol   =  c("#EEE9BF", "#8DB6CD", "#8B7E66", "#7CFC00", "#4CBB17", "#426F42", "#9B2CEE" , "#FFD700", "#EE7600", "#EE0000", "#E5E5E5", "#FF3399"), 
  stageRank  =  1:12,
  stringsAsFactors=FALSE)

# map
	setmap = list(
				# BASE MAP
				box.pch = 19,         # box symbol  type
				box.cex = 1,        # box symbol size
				box.col = "grey50",   # default box color
				box.offset = 0.3,     # distance from box to text  
				
				text.cex = 0.5,       # box label size
				text.pos = 4,    # box name placement
				
				#  working maps
				evol.cex   = 1.2,     # nest evolution arrow
				evol.pos = 3,
				evol.offset = -0.3,
				
				clutch.cex = 0.5,     # clutch/hatchings
				clutch.pos = 1  , 
				
				incubStart.pch = 22,  # incubation has started
				incubStart.cex = 0.8/0.95, 
				
				hatchEst.cex = 0.5, 
				hatchEst.pos = 3,
				hatchEst.offset = 0.5,# hatching estimation date
				
				lastCheck.cex = 0.4,  # last check
				lastCheckPos = 2,
				lastCheck.offset = 0.28,
				hatchingNow = list(pch = 20, cex = 5, col = rgb(red=0.98, green = 0.43, blue = 0.32, alpha = .2)  ),
				youngDay5 = list(pch = 20, cex = 5, col = rgb(red=0, green = 0, blue = 0.54, alpha = .2)  ),
				youngDay14 = list(pch = 20, cex = 5, col = rgb(red=0, green = 0.80, blue = 0, alpha = .2)  )
				)

info.pos     = c(x = 4417700, y = 5335000)
legend.pos   = c(x = 4417250, y = 5335020)
rain.pos   = c(x = 4417130, y = 5335020)

















  