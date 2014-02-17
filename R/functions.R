
###### SERVER

# accessories
refDate <- function(month, day, year) { 
	strptime(paste(month, day, year, sep = "/"), "%m/%d/%Y") 
	}
	
dayOfyear = function(date) {
	as.numeric(strftime(as.POSIXct(date), format = "%j"))
}
	
dayofyear2date = function(dayofyear, year) {
	ans = as.Date(dayofyear - 1, origin = paste(year, "01-01", sep = "-"))
	as.POSIXct(round( as.POSIXct(ans), units = "days"))
	
	}

add.alpha <- function (col,alpha) { sprintf("%s%02X",col,floor(alpha*256))	
	}

WGWeather <-function(query) {
	require(RJSONIO)
   
  conWG =  url(sprintf('%s/q/%s.%s', "http://api.wunderground.com/api/4806e6e8e9e9f68b/forecast", query = query, 'json') )
    wg = readLines(conWG, n=-1L, ok=TRUE)
	close.connection(conWG)
  
  if( length(grep('error', wg)) > 0 ) wd = NULL else {
  
  wd = fromJSON(paste(wg, collapse=""))
  wd = wd$forecast$simpleforecast$forecastday
  
  wd = lapply(wd, function(x) 
      data.frame(date_ = ISOdate(x$date$year, x$date$month, x$date$day), 
                temphigh = x$high[2], 
                 templow = x$low[2], 
                 rainprob = x$pop, 
                 maxwind = x$maxwind$kph, 
                 avehumid = x$avehumidity
                 ) )

   wd = do.call(rbind, wd)
  rownames(wd) = NULL
  wd$dtp = format(wd$date_, "%d-%b")
    
  }
  
  wd


}


Q <- function(year, query, ...) {
	
	if(missing(year)) year = format(Sys.Date(), format = "%Y")
	if(year == format(Sys.Date(), format = "%Y") ) db = 'FIELD_BTatWESTERHOLZ' else db = paste('FIELD', year, 'BTatWESTERHOLZ', sep = "_")
	
	CON = dbcon(user = "guest", password = "guest", database = db)

	on.exit(  closeCon (CON)  )
	return(dbq(CON, query))
}

# data
# Lying, incubation, young
dataFetch <- function(year, month, day, stages = NULL, stagesNFO = stagesInfo, safeHatchCheck, youngAgeYN, youngAge) {
	
	date_ = refDate(month, day, year)
	
	# data
	O = Q(year = year, paste(
	"SELECT DISTINCT A.box, A.date_time, DATEDIFF(" ,shQuote(date_), ",A.date_time) last_check, 
			N.nest_stage, N.eggs clutch, N.chicks, N.guessed, 
			
			/* CONCAT_WS(if(guessed = 1, '?|', '|'),
				 if( (coalesce(eggs, 0) - coalesce(dead_eggs, 0))    < 1, '', (coalesce(eggs, 0) - coalesce(dead_eggs, 0))),
				 if( (coalesce(chicks, 0) - coalesce(dead_chicks,0)) < 1, '',  (coalesce(chicks, 0) - coalesce(dead_chicks,0)) )) eggs_young, */

			 CONCAT_WS(if(guessed = 1, '?|', '|'),
				 if( coalesce(eggs, 0)   < 1, '', (coalesce(eggs, 0) ) ),
				 if( coalesce(chicks, 0)  < 1, '',  coalesce(chicks, 0)  ) ) eggs_young, 
	
				B.firstEgg, B.firstEggDate, 
				C.firstYoung, C.youngAge, 
				D.maxClutch, 
				E.maleID, F.femaleID
				
				FROM (SELECT box, max(date_time) date_time FROM NESTS  WHERE date_time <=  ",shQuote(date_),"  GROUP BY box ORDER BY box) A
			LEFT JOIN  NESTS N ON A.box = N.box AND A.date_time = N.date_time
			
			LEFT JOIN (SELECT box, DAYOFYEAR(date_time) firstEgg, date_time firstEggDate FROM NESTS WHERE laying_START is not NULL and date_time <=  ",shQuote(date_), ")     B ON A.box = B.box 
			
			LEFT JOIN (SELECT box, DAYOFYEAR(date_time) firstYoung, date_time firstYoungDate, DATEDIFF(",shQuote(date_),", date_time) youngAge FROM 
					NESTS WHERE hatching_START is not NULL and date_time <=  ",shQuote(date_), ") C ON A.box = C.box 
			
			LEFT JOIN (SELECT box, max(eggs) maxClutch FROM NESTS WHERE COALESCE(guessed,0) = 0 AND date_time <=  ",shQuote(date_), "GROUP BY box)  D ON A.box = D.box
			
			LEFT JOIN (SELECT box, FUNCTIONS.combo(UL, LL, UR, LR) maleID FROM ADULTS WHERE sex = 1 AND date_time_caught <=  ",shQuote(date_), ")  E ON A.box = E.box
			LEFT JOIN (SELECT box, FUNCTIONS.combo(UL, LL, UR, LR) femaleID FROM ADULTS WHERE sex = 2 AND date_time_caught <=  ",shQuote(date_), ")  F ON A.box = F.box
			
		"))				
	
	if(nrow(O) == 0) stop("There are no data available. Did you choose an invalid date?") 
					 
	# selected nest stages
	if(!is.null(stages) ) O = O[O$nest_stage%in%stages, ] else O$nest_stage = NA
	O = merge(O, stagesNFO, by = "nest_stage", sort = FALSE)  
	
	#FIRST EGG in pop
	minFirstEgg =  min(O$firstEgg, na.rm = TRUE) 
	
	O$firstEgg =  O$firstEgg - minFirstEgg
	
	# hatch and young age
	O$hatch_or_youngAge = O$youngAge
	
	# predict hatchDate
	predHatchDat = O[ !is.na(O$maxClutch) & !is.na(O$firstEgg) & is.na(O$hatch_or_youngAge) , c("maxClutch", "firstEgg")]; names(predHatchDat) = c("clutch", "firstEgg")
	
	predHatch = try( predict(hatchDateGLM , newdata = predHatchDat, level = 0 )    , silent = TRUE ) 
	
		 
	if( class(predHatch) != "try-error") {
		predHatch  = predHatch + minFirstEgg 				 # back to Julian
		predHatch  = predHatch  + as.numeric(safeHatchCheck) # substract n days to make sure all hatching dates are recorded
		
		relHatchDate  = floor( predHatch  - dayOfyear(date_) )  # days till hatching relative to date_
		absHatchDate  = dayofyear2date( predHatch+1  , year)		# abs pred hatch date
		
		O[!is.na(O$maxClutch) & !is.na(O$firstEgg) & is.na(O$hatch_or_youngAge), 'tmp']  = 1
		
		O[!is.na(O$tmp), 'hatch_or_youngAge'] =  relHatchDate  
		
		O$predHatchDate = as.POSIXct(NA)
		O[!is.na(O$tmp), 'predHatchDate'] =  absHatchDate
		O$tmp = NULL
	 }	
	
	
	# adults
	O$caught = ifelse( is.na(O$maleID) & is.na(O$femaleID),   'none', (ifelse (!is.na(O$maleID) & is.na(O$femaleID), 'male', (ifelse(!is.na(O$maleID) & is.na(O$femaleID), 'female', 'both')))))
	
	# selected young age
	  if(youngAgeYN == 'SELECT') {
		sy = which(O$nest_stage == 'Y' & !O$hatch_or_youngAge%in%youngAge)
		if(length(sy) > 0) 		O = O[ - sy , ]
		}	
	
	# coordinates
	O = merge(O, cbind(boxes@data, coordinates(boxes)), by = "box", sort = FALSE)
		if(nrow(O) == 0) stop("There are no data available") 
	coordinates(O) = ~ coords.x1 + coords.x2
	
	
	O

	}
	
# bugs
bugs <- function(year, warnings = FALSE) {
	
	if(!warnings) f = "BUGS.SQL" else f = "WARNINGS.SQL"
	
	d = Q(year = year, paste(readLines(con = f, warn = FALSE), collapse = " "))
	d = d[!is.na(d$boxes), ]
	
	if(nrow(d) == 0) d = data.frame(info =   if(warnings)   "There are no warnings for now." else "There are no bugs for now." )
	row.names(d) = NULL
	d
 }
 

# mapping
basemap <- function(input, pdf = FALSE,...) {

if(pdf) pdf(..., width = 8.3, height = 11.7)
 par(mai = c(0,0,0,0))
	plot(boxes, pch = setmap$box.pch, col = add.alpha('#C0C0C0', input$transp), cex = input$boxCex)
	text(boxes, labels = boxes$box, pos = setmap$text.pos, cex = input$textCex, offset = setmap$box.offset)
	plot(streets, col = "grey", add = T)
	plot(roads, add = T, col = "grey")
  if(pdf) dev.off()

}

map <- function(input, pdf = FALSE, ...) {
 
  if( is.na(refDate(year = input$year, month  = input$month, day = input$day) ) ) stop("The chosen date is not a valid calendar date, did you choose 31th instead of 30th?)")
 
 
 if(pdf) pdf(..., width = 8.3, height = 11.7) 

	
 	par(mai = c(0,0,0,0) )# , bg = if(!pdf) "whitesmoke" else "white")
 
	# fetch data
	d = dataFetch(year = input$year, month  = input$month, day = input$day, 
				stagesNFO = stagesInfo, stages = input$nestStages, 
				safeHatchCheck = input$safeHatchCheck, 
				youngAgeYN = input$youngAgeYN, youngAge = input$youngAge
				)

	# map layout
	plot(boxes, pch = setmap$box.pch, col = add.alpha('#C0C0C0', input$transp)  , cex = setmap$box.cex)
	plot(streets, col = "grey", add = TRUE)
	plot(roads, add = TRUE, col = "grey")
	if(!pdf) box(col = "grey")
	
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
	
		
	#NOW hathcing  
	if(input$hatchNow) points(d[ which(d$hatch_or_youngAge < 1 & d$nest_stage == 'E') ,], pch = setmap$hatchingNow$pch,cex = setmap$hatchingNow$cex, col = setmap$hatchingNow$col )
	

	
	###########################
	
	# legend
	LG = unique(d@data[order(d$stageRank),c("nest_stage","stageCol")])
	LG = merge(LG,data.frame(xtabs(~nest_stage,d)),by = "nest_stage",sort = FALSE)
	LG$nam = paste(LG$nest_stage, " ( ", LG$Freq, ")", sep = "")
	legend(x = legend.pos[1],y = legend.pos[2], legend = LG$nam,  col = add.alpha(LG$stageCol, input$transp), pch = setmap$box.pch, pt.cex = input$boxCex, title = "Nest stages:", bty = "n") # 


	# legend symbols
	lc = list(x = info.pos[1] ,y = info.pos[2])   
	points(lc,col   = "grey70",pch = setmap$box.pch,cex = setmap$box.cex)
	text(lc, labels = "box", cex = .7, pos = 4,offset = .4)
	text(lc, labels = if(input$parents == 'NO') "eggs|chicks\n(?=guessed)" else "female", cex = .7, pos = 1,offset = .5)
	text(lc, labels = if(input$parents == 'NO') "days till hatching or chick age" else "male", cex = .7, pos = 3,offset = .5)
	text(lc, labels = "checked days ago", cex = .7, pos = 2,offset = .28)

	# Titles, Stapms
	rfd = refDate(year = input$year, month  = input$month, day = input$day)
	when = difftime(rfd, Sys.Date() , units = 'days')
	
	mtext(   paste('Reference date:', format(rfd, "%d-%b-%Y" ) ) , side = 3, line = -1, font = 4 )
	mtext(   paste('[ printed on',  format(Sys.Date(), "%d-%b-%Y") ,"]") , side = 1, line = -2, font = 2,  cex = if (when > 2) 2 else 1, col =  if (when > 2) 2 else 1)
	
	
	if( input$year < as.numeric(format(Sys.Date(), format = "%Y"))  ) mtext(input$year, side = 2, line = -6, cex = 8, col = "grey80", font = 4)
	
	# chance of rain
	W = try( WGWeather("Germany/Landsberg") , silent = TRUE)
	if(!is.null(W) && inherits( W, 'data.frame') && inherits( W$date, 'POSIXct') && any(as.Date(W$date_)%in%as.Date(rfd)) )
		try( legend(x = rain.pos[1],y = rain.pos[2], legend = paste(W$dtp, paste(W$rainprob, "%", sep = '')), title = 'Chance of rain:', bty = "n", text.col = 'grey30'), silent = TRUE)
	
	
if(pdf)  dev.off()
 
 
 

}

# Nest history
nestGraph <- function(input, pdf = FALSE, ...) {
	
	box1 = input$NestId
	box2 = input$NestIdEntry 
	
	if( is.na(box2) )  box  = box1 else  box = box2
	
	
	year = input$year
	safeHatchCheck = input$safeHatchCheck
	
	#check 1
	if( nchar(box) == 0) stop("First choose a box!")
	
	
	if(pdf) pdf(..., width = 8.3, height = 11.7)
		
	#  data
	d = Q(year = year,  paste(
		'SELECT DISTINCT date_time, dayofyear(date_time) jd, nest_stage,eggs, author, female_inside_box, warm_eggs, eggs_covered, COALESCE(guessed, 0) guessed, laying_START, fledging_START, chicks
			FROM NESTS where box =', box
			) )
	
	#check 2
	if(nrow(d) == 0) stop( paste("selected box", box, "is empty in", year))					   

	# min laying date in pop
	minFirstEgg = Q(year = year,  'SELECT MIN(DAYOFYEAR(date_time)) firstEgg FROM NESTS WHERE laying_START is not NULL')[1,1]
	
	d$date_time = as.POSIXct(d$date_time)
	d = merge(d, stagesInfo, by = 'nest_stage',sort = FALSE)
	
	# predict hatching
	toPred = data.frame(clutch = max(d$eggs, na.rm = TRUE), firstEgg = dayOfyear( d[which(d$laying_START == 1), "date_time"][1] ) - minFirstEgg )
	
	ph = try( predict(hatchDateGLM, toPred ,  level = 0) , silent = TRUE)
	
	if( is.numeric(ph) ) {
		ph = ph + minFirstEgg 				 # back to Julian
		ph = ph + as.numeric(safeHatchCheck)
		phAbs = data.frame( date_time = dayofyear2date(floor(ph), year), predHatchDate = ph )
		d = merge(d, phAbs, by = 'date_time', all.x = TRUE, all.y = TRUE)
		d[!is.na(d$predHatchDate), 'nest_stage'] = 'estHatch'
	}
	
	# prepare d
	d = d[order(d$date_time, decreasing  = TRUE), ]
	d$ID = 1:nrow(d)
	# size is prop with clutch and brood size
	d$CBS = d$eggs; d[which(!is.na(d$chicks)), 'CBS'] = d[which(!is.na(d$chicks)), 'chicks']; d[is.na(d$CBS), "CBS"] = 0
	
	# PLOT xlim =  c(1,8)
	par(mai= c(2,2,0.5,0))
	plot(ID ~ ID, d, axes = FALSE, type = 'n', ylab = '', xlab = '', sub = paste('box', box, 'in', year) , 
			xlim =  c(1,8)
			
			)
	
	axis(2, at = 1:nrow(d), label = format(as.POSIXct(d$date_time), "%d-%b" ), las = 1)
	
	#1, author & guessed
	mtext("Author\n(guessed):", side = 3, at = 1, line = -1)
	text(rep(1, nrow(d)), d$ID, label = paste(d$author, gsub(1, '(?)', gsub(0, '', d$guessed) ) )    )

	#2,  nest developement, predicted hatch, clutch/brood size
	mtext("Nest\ndevelopement:", side = 3, at = 2, line = -1)
	points(rep(2, nrow(d)), d$ID, col = d$stageCol, cex = round(sqrt(d$CBS))+1.2 , pch = 20)
	text(rep(2, nrow(d)), d$ID, label = d$CBS, col  = ifelse( d$nest_stage%in%c( "U", "LT" ,"NOTA", "E"), 'black', 'white') , font = 4   )
	x = d[d$nest_stage == 'estHatch', ] ; if(nrow(x) > 0)  points(rep(2, nrow(x)), x$ID,col = 2, pch = 5, cex = 3.5)
	
	
	
	#3,  female_inside_box 
	mtext("Female\nin box:", side = 3, at = 3, line = -1)
	x = d[!is.na(d$female_inside_box), ]; if(nrow(x) > 0) points(rep(3, nrow(x)), x$ID,col = 2, pch = 13, cex = 2)
	
	#4,  warm_eggs
	mtext("Warm\neggs:", side = 3, at = 4, line = -1)
	x = d[ which(d$warm_eggs ==1) , ]; if(nrow(x) > 0) points(rep(4, nrow(x)), x$ID,col = 1, pch = 19, cex = 1)
	
	#5,  eggs_covered
	mtext("Covered\neggs:", side = 3, at = 5, line = -1)
	x = d[!is.na(d$eggs_covered), ]; if(nrow(x) > 0) points(rep(5, nrow(x)), x$ID,col = 1, pch = 19, cex = 1)
	

	

	
	#6,  TODO
	mtext("Visits per day\n(SNB):", side = 3, at = 6, line = -1)
	
	grid(nx = nrow(d) )
	
	# legend (static)
	LG = stagesInfo[,1:2]; names(LG) = c("nam", "col")
	LG$point = 20
	LG = rbind( LG, data.frame(nam = 'Estimated hatching date', col = 2, point = 5) )
	legend('topright', legend = LG$nam,  col = LG$col, pch = LG$point, pt.cex = 3, title = "Nest stages:", bty = "n")
	
	legend('bottomright', legend = 1:12,  col = 2, pch = 20, pt.cex = sqrt(1:12)+1, title = "Clutch or\nbrood size:", bty = "n")
	
	
	
	
	  if(pdf) dev.off()
	
	
	
	}

	
# Forecasting graphs
forecastGraph <- function(input, pdf = FALSE, ...) {
	
	# stop("there is a bug! forecasting will be available soon")
	
	d = dataFetch(year = input$year, month  = input$month, day = input$day, 
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


# MESSAGES
dataSummaries <- function(input, ...) { 
	d = dataFetch(year = input$year, month  = input$month, day = input$day, 
              stagesNFO = stagesInfo, stages = input$nestStages, 
              safeHatchCheck = input$safeHatchCheck, 
              youngAgeYN = input$youngAgeYN, youngAge = input$youngAge
        )
	
	# pred hatch: dist from laying date + CS date mean and range
	d1 = d[which(d$maxClutch > 6), ]
	x = round(difftime(d1$predHatchDate  ,  as.Date(d1$firstEggDate) + d1$maxClutch , units = 'days'))
	
	predhatch = paste('<strong style="color:sienna;text-decoration:underline;"> ', 
					'Predicted days of incubation (day 0 = last egg day): Mean = ', round(mean(x, na.rm = T), 1), 'days', '; range= (', paste(round(range(x, na.rm = T),1), collapse = ','), ")"   , 
					'</strong>' )
	cat(predhatch)
	
	
	
	}


# MAIN PLOT
PLOT <- function(input, pdf = FALSE, ...) {
	
	if(input$tools == 'MAPPING' && input$mapType == 'activeMap')  	map(input = input, pdf = pdf, ...)
	if(input$tools == 'MAPPING' && input$mapType == 'baseMap')  	basemap(input = input, pdf = pdf, ...)

	if(input$tools == 'NEST HISTORY')  nestGraph(input = input, pdf = pdf, ...)
	if(input$tools == 'FORECASTING')  forecastGraph(input, pdf = pdf, ...)
	
	
	
}


######## UI
hr <- function(...) { 
 HTML("<hr>")
	}
	
icon <- function(nam) { 
	HTML( paste('<i class="icon-', nam, '"></i>', sep = ""))

	}

links <-function(nam) {
  switch(nam,
         man     = shQuote("http://scidb.orn.mpg.de/scidbwiki/westerholz/doku.php?id=current_field_manual"),
         journal = shQuote("http://scidb.orn.mpg.de/scidbwiki/westerholz/doku.php?id=current_field_journal")
		 )
}









































  