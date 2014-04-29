
# Lying, incubation, young ----
nestDataQuery <- function(date_) {
paste(
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
			
			LEFT JOIN (SELECT box, DAYOFYEAR(date_time) firstEgg, date_time firstEggDate FROM NESTS WHERE laying_START is not NULL and date_time <=  ",shQuote(date_), ") B 
        ON A.box = B.box 
			
			LEFT JOIN (SELECT box, DAYOFYEAR(date_time) firstYoung, date_time firstYoungDate, DATEDIFF(",shQuote(date_),", date_time) youngAge FROM 
					NESTS WHERE hatching_START is not NULL and date_time <=  ",shQuote(date_), ") C ON A.box = C.box 
			
			LEFT JOIN (SELECT box, max(eggs) maxClutch FROM NESTS WHERE COALESCE(guessed,0) = 0 AND date_time <=  ",shQuote(date_), "GROUP BY box)  D ON A.box = D.box
			
			LEFT JOIN (SELECT box, FUNCTIONS.combo(UL, LL, UR, LR) maleID FROM ADULTS WHERE sex = 1 AND 
          date_time_caught BETWEEN (SELECT min(date_time) from NESTS) AND  ",shQuote(date_), ")  E ON A.box = E.box
			LEFT JOIN (SELECT box, FUNCTIONS.combo(UL, LL, UR, LR) femaleID FROM ADULTS WHERE sex = 2 AND
          date_time_caught BETWEEN (SELECT min(date_time) from NESTS) AND  ",shQuote(date_), ")  F ON A.box = F.box
			
		")

	}

nestDataFetch <- function(date_, stages = NULL, stagesNFO = stagesInfo, safeHatchCheck, youngAgeYN, youngAge, ...) {
	year = dd2yy(date_)
	# data
	O = Q(year = year, nestDataQuery(date_), ...)				
	
	if(nrow(O) == 0) stop("There are no data available on this date!") 
					 
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
	O$caught = ifelse( is.na(O$maleID) & is.na(O$femaleID),   'none', (
    ifelse (!is.na(O$maleID) & is.na(O$femaleID), 'male', (
      ifelse(!is.na(O$maleID) & is.na(O$femaleID), 'female', 'both')))))
	
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
	

# 1st egg Predict ----
ldPredictDataFetch <- function(...) { 
    d = Q(query = "SELECT  F.year_, firstEgg, firstEgg_AprilDay, avg_temp FROM 
    ( SELECT year(firstEgg) year_, firstEgg, dayofyear(firstEgg) - 
  			dayofyear(STR_TO_DATE( concat_WS('-', year(firstEgg), 'Apr-1'), '%Y-%M-%d'))+1 firstEgg_AprilDay
  				FROM ( select date(min(firstEgg)) firstEgg, year_ from BTatWESTERHOLZ.BREEDING group by year_) x ) F
  JOIN 
  
  ( select avg(temperature_min) avg_temp, year_  from LOGGERSatWESTERHOLZ.ENVIRONMENTAL
    where 
       dayofyear(date_) BETWEEN 81 AND 100 group by year_ ) T
        
  ON 
  F.year_= T.year_", ...)

}

# get table comments ----
getComments <- function(tab = "NESTS", date_ = Sys.Date(), ... ) {
  
  year = dd2yy(date_)
  if(year < 2014) stop("For years < 2014 go to the corresponding database and check `columns_dafinition´ table.")

  x = Q(year = year, paste("show full columns from", tab), ... )
  
  x[, c("Field" , "Comment")]
  
  }


# nest history data ----
nestData <- function(year, box, safeHatchCheck = -3, ...) {
options(stringAsFactors = FALSE) 
 d = Q(year = year,  paste(
        'SELECT DISTINCT date_time, dayofyear(date_time) jd, nest_stage,eggs, author, female_inside_box, warm_eggs, eggs_covered, 
          COALESCE(guessed, 0) guessed, laying_START, fledging_START, chicks
            FROM NESTS where box =', box), ... )

  #check
  if(nrow(d) == 0) stop( paste("selected box", box, "is empty in", year))					   
  
  # min laying date in pop
  minFirstEgg = Q(year = year,  'SELECT MIN(DAYOFYEAR(date_time)) firstEgg FROM NESTS WHERE laying_START is not NULL', ...)[1,1]
  
  d$date_time = as.Date(d$date_time)
  d = merge(d, stagesInfo, by = 'nest_stage',sort = FALSE)
  
  dd = data.frame(date_time = seq.Date(min(d$date_time),max(d$date_time), by = 1) )
  d = merge(dd, d, all.x = TRUE)
  
  # predict hatching
  toPred = data.frame(clutch = max(d$eggs, na.rm = TRUE), firstEgg = dayOfyear( d[which(d$laying_START == 1), "date_time"][1] ) - minFirstEgg )
  
  ph = try( predict(hatchDateGLM, toPred ,  level = 0) , silent = TRUE)
  
  if( is.numeric(ph) ) {
    ph = ph + minFirstEgg 	# back to Julian
    ph = ph + as.numeric(safeHatchCheck)
    phAbs = data.frame( date_time = dayofyear2date(floor(ph), year), predHatchDate = ph )
    d = merge(d, phAbs, by = 'date_time', all.x = TRUE, all.y = TRUE)
    d[!is.na(d$predHatchDate), 'nest_stage'] = 'estHatch'
  }
  
  # prepare d
  d[is.na(d$author), "author"] = ""
  d[is.na(d$guessed), "guessed"] = ""
  
  d = d[order(d$date_time, decreasing  = TRUE), ]
  d$ID = 1:nrow(d)
  # size is prop with clutch and brood size
  d$CBS = d$eggs
  
  cks = d[which(!is.na(d$chicks)), 'chicks']
  if(length(cks) > 0) d[which(!is.na(d$chicks)), 'CBS'] = cks
  d[is.na(d$CBS), "CBS"] = 0
  
  d
  
  
 }

















