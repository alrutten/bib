
addMarks <- function(marks) {

	k = data.frame(marks[ c('box', 'col', 'text')], stringsAsFactors = FALSE)
	m = merge( data.frame(boxes), k, by = 'box')
	m$x = m$coords.x1+10
	m$y = m$coords.x2-10
	coordinates(m)  = ~ x+y
	
	points(m, pch = 15, col = m$col, cex = 1.7)
	text(m, labels = m$text, cex = .8, col = 'white')
	
	if( !is.null(marks$legend) ) try(marks$legend() , silent = TRUE)
	
	
}

marksmap <- function(input) {
  if(input$marks == "Yes") 
		try( addMarks(marks = eval(parse(text = input$marksList)) ), silent = TRUE )
	
}

# mapping
	basemap <- function(input, pdf = FALSE, ...) {
		
		if(pdf) pdf(..., width = 8.3, height = 11.7)
		 par(mai = c(0,0,0,0))
			plot(boxes, pch = setmap$box.pch, col = add.alpha('#C0C0C0', input$transp), cex = input$boxCex)
			text(boxes, labels = boxes$box, pos = setmap$text.pos, cex = input$textCex, offset = setmap$box.offset)
			plot(streets, col = "grey", add = T)
			plot(roads, add = T, col = "grey")
		
		marksmap(input = input)
		experimentsMap(input = input)
		
		  if(pdf) dev.off()

		}

	map <- function(input,  pdf = FALSE, ...) {
		 
		 if(pdf) pdf(..., width = 8.3, height = 11.7) 

			
			par(mai = c(0,0,0,0) )# , bg = if(!pdf) "whitesmoke" else "white")
		 
			# fetch data
			d = nestDataFetch(date_ = input$date, 
						stagesNFO = stagesInfo, stages = input$nestStages, 
						safeHatchCheck = input$safeHatchCheck, 
						youngAgeYN = input$youngAgeYN, youngAge = input$youngAge,
						host = input$host
						)

			# map layout
			plot(boxes, pch = setmap$box.pch, col = add.alpha('#C0C0C0', input$transp)  , cex = setmap$box.cex)
			plot(streets, col = "grey", add = TRUE)
			plot(roads, add = TRUE, col = "grey")
			box(col = "grey")
			
			# nest stages (point)
			points(d, col = add.alpha(d@data$stageCol, input$transp) , pch = setmap$box.pch, cex = input$boxCex)

			# box number (left)
			text(boxes, labels = boxes$box, pos = setmap$text.pos, cex = input$textCex, offset = setmap$box.offset, font = 1)
			
			# last check (left)
			text(d, labels = d$last_check, cex = input$textCex, pos = setmap$lastCheckPos, offset = setmap$lastCheck.offset, font = 1)

			# eggs/chicks OR FEMALE (bottom)
			if(input$parents == 'NO')
				text(d, labels = d$eggs_young, cex = input$textCex, pos = setmap$clutch.pos , offset = setmap$box.offset, font = 1) else
					text(d, labels = d$femaleID, cex = input$textCex , pos = setmap$clutch.pos , offset = setmap$box.offset, font = 1)

			
			# hatching OR young age / MALE (top)
			if(input$parents == 'NO')
				text(d, labels = d$hatch_or_youngAge, cex = input$textCex, pos = setmap$hatchEst.pos , offset = setmap$hatchEst.offset, font = 1) else
				text(d, labels = d$maleID, cex = input$textCex, pos = setmap$hatchEst.pos , offset = setmap$hatchEst.offset, font = 1)
			
				
			#NOW hatching  
			if(input$hatchNow) points(d[ which(d$hatch_or_youngAge < 1 & d$nest_stage == 'E') ,], pch = setmap$hatchingNow$pch,cex = setmap$hatchingNow$cex, col = setmap$hatchingNow$col )
			

			
			###########################
			
			# legend
			LG = unique(d@data[order(d$stageRank),c("nest_stage","stageCol")])
			LG = merge(LG,data.frame(xtabs(~nest_stage,d)),by = "nest_stage",sort = FALSE)
			LG$nam = paste(LG$nest_stage, " ( ", LG$Freq, ")", sep = "")
			legend(x = legend.pos[1],y = legend.pos[2], 
						legend = LG$nam,  
						col = add.alpha(LG$stageCol, input$transp), 
						pch = setmap$box.pch, pt.cex = input$boxCex, 
						title = paste("Nest stages(", sum(LG$Freq), ")"), 
						bty = "n") # 
			
			# legend symbols
			lc = list(x = info.pos[1] ,y = info.pos[2])   
			points(lc,col   = "grey70",pch = setmap$box.pch,cex = setmap$box.cex)
			text(lc, labels = "box", cex = .7, pos = 4,offset = .4)
			text(lc, labels = if(input$parents == 'NO') "eggs|chicks\n(?=guessed)" else "female", cex = .7, pos = 1,offset = .5)
			text(lc, labels = if(input$parents == 'NO') "days till hatching or chick age" else "male", cex = .7, pos = 3,offset = .5)
			text(lc, labels = "checked days ago", cex = .7, pos = 2,offset = .28)

			# Titles, Stapms
			rfd = input$date
			when = difftime(rfd, Sys.Date() , units = 'days')
			
			mtext(   paste('Reference date:', format(rfd, "%d-%b-%Y" ) ) , side = 3, line = -1, font = 4 )
			mtext(   paste('[ printed on',  format(Sys.Date(), "%d-%b-%Y") ,"]") , side = 1, line = -2, font = 2,  cex = if (when > 2) 2 else 1, col =  if (when > 2) 2 else 1)
			
			
			if(as.numeric(strftime(input$date, format = "%Y"))  < as.numeric(format(Sys.Date(), format = "%Y"))  ) 
				mtext(strftime(input$date, format = "%Y"), side = 2, line = -6, cex = 8, col = "grey80", font = 4)
			
	
			marksmap(input = input)
			experimentsMap(input = input)
			
		if(pdf)  dev.off()
		 
		 
		 

		}

#  active and base map
	maps <- function(input, pdf = FALSE, ...) {

			if(input$mapType == 'activeMap')  	map(input = input, pdf = pdf, ...)
			if(input$mapType == 'baseMap')  	basemap(input = input, pdf = pdf, ...)
			
		}	
		
# Nest history
	nestGraph <- function(input, pdf = FALSE, ...) {
	
      # settings
	    safeHatchCheck = input$safeHatchCheck
	    year = dd2yy(input$date)
			box1 = input$NestId
			box2 = input$NestIdEntry 
				if( is.na(box2) )  box  = box1 else  box = box2
			
      #check
			if( nchar(box) == 0) stop("First choose a box!")	
			
			#  data
	
			d = nestData(year, box, safeHatchCheck = safeHatchCheck, host = input$host)
      
			# PLOT xlim =  c(1,8)
			par(mai= c(2,2,0.5,0))
			plot(ID ~ ID, d, axes = FALSE, type = 'n', ylab = '', xlab = '',   xlim =  c(1,8),
           sub = paste('box', box, 'in', year) )
			
			axis(2, at = 1:nrow(d), label = format(as.POSIXct(d$date_time), "%d-%b" ), las = 1)
			
			#1, author & guessed
			mtext("Author\n(guessed):", side = 3, at = 1, line = -1)
			text(rep(1, nrow(d)), d$ID, label = paste(d$author, gsub(1, '(?)', gsub(0, '', d$guessed) ) )    )

			#2,  nest developement, predicted hatch, clutch/brood size
			mtext("Nest\ndevelopement:", side = 3, at = 2, line = -1)
			points(rep(2, nrow(d)), d$ID, col = d$stageCol, cex = round(sqrt(d$CBS))+ 4 , pch = 20)
			text(rep(2, nrow(d)), d$ID, label = d$CBS, col  = ifelse( d$nest_stage%in%c( "U", "LT" ,"NOTA", "E"), 'black', 'white') , font = 4   )
			x = d[d$nest_stage == 'estHatch', ]
      if(nrow(x) > 0)
        points(rep(2, nrow(x)), x$ID,col = 2, pch = 5, cex = 4)
			
			
			
			#3,  female_inside_box 
			mtext("Female\nin box:", side = 3, at = 3, line = -1)
			x = d[!is.na(d$female_inside_box), ]
      if(nrow(x) > 0) 
        points(rep(3, nrow(x)), x$ID,col = 2, pch = 13, cex = 2.5)
			
			#4,  warm_eggs
			mtext("Warm\neggs:", side = 3, at = 4, line = -1)
			x = d[ which(d$warm_eggs ==1) , ]
      if(nrow(x) > 0) 
        points(rep(4, nrow(x)), x$ID,col = 1, pch = 19, cex = 2)
			
			#5,  eggs_covered
			mtext("Covered\neggs:", side = 3, at = 5, line = -1)
			x = d[!is.na(d$eggs_covered), ]
      if(nrow(x) > 0) 
        points(rep(5, nrow(x)), x$ID,col = 1, pch = 19, cex = 2)
			
			
			#6,  TODO
			mtext("Visits per day\n(SNB):", side = 3, at = 6, line = -1)
			
			grid(nx = nrow(d) )
			
			# legend (static)
			LG = stagesInfo[,1:2]; names(LG) = c("nam", "col")
			LG$point = 20
			LG = rbind( LG, data.frame(nam = 'Estimated hatching date', col = 2, point = 5) )
			legend('topright', legend = LG$nam,  col = LG$col, pch = LG$point, pt.cex = 3, title = "Nest stages:", bty = "n")
			legend('bottomright', legend = 1:12,  col = 2, pch = 20, pt.cex = sqrt(1:12)+1, title = "Clutch or\nbrood size:", bty = "n")
								
			}

# Forecasting graphs
	forecastGraph <- function(input, pdf = FALSE, ...) {

			d = nestDataFetch(date_ = input$date, 
						stagesNFO = stagesInfo, stages = input$nestStages, 
						safeHatchCheck = input$safeHatchCheck, 
						youngAgeYN = input$youngAgeYN, youngAge = input$youngAge
						)	
			d = d[which(is.na(d$guessed)), ]
			
			d$predHatchDate = as.Date(d$predHatchDate)
			x = subset(data.frame(xtabs(~  predHatchDate + nest_stage, d)), nest_stage%in%c('E', 'Y') )
			

			par(mar = c(5,5,5,0) )
			 if(pdf) pdf(..., width = 8.3, height = 11.7) 

			barplot(x$Freq, names.arg = strftime (as.Date(x$predHatchDate ), '%d-%b') , horiz = TRUE, cex.names = .9, width = 1, xlab = "No of nests", main = 'Predicted hatch date')
			

		 
			if(pdf)  dev.off()

			
			
		}
		


