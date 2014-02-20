
# Lying, incubation, young
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
			
			LEFT JOIN (SELECT box, DAYOFYEAR(date_time) firstEgg, date_time firstEggDate FROM NESTS WHERE laying_START is not NULL and date_time <=  ",shQuote(date_), ")     B ON A.box = B.box 
			
			LEFT JOIN (SELECT box, DAYOFYEAR(date_time) firstYoung, date_time firstYoungDate, DATEDIFF(",shQuote(date_),", date_time) youngAge FROM 
					NESTS WHERE hatching_START is not NULL and date_time <=  ",shQuote(date_), ") C ON A.box = C.box 
			
			LEFT JOIN (SELECT box, max(eggs) maxClutch FROM NESTS WHERE COALESCE(guessed,0) = 0 AND date_time <=  ",shQuote(date_), "GROUP BY box)  D ON A.box = D.box
			
			LEFT JOIN (SELECT box, FUNCTIONS.combo(UL, LL, UR, LR) maleID FROM ADULTS WHERE sex = 1 AND date_time_caught <=  ",shQuote(date_), ")  E ON A.box = E.box
			LEFT JOIN (SELECT box, FUNCTIONS.combo(UL, LL, UR, LR) femaleID FROM ADULTS WHERE sex = 2 AND date_time_caught <=  ",shQuote(date_), ")  F ON A.box = F.box
			
		")

	}

nestDataFetch <- function(year, month, day, stages = NULL, stagesNFO = stagesInfo, safeHatchCheck, youngAgeYN, youngAge) {
	
	date_ = refDate(month, day, year)
	
	# data
	O = Q(year = year, nestDataQuery(date_)   )				
	
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
	
phenologyDataFetch	 <- function(what = 'firstEgg', db = "BTatWESTERHOLZ") {

	d = Q(query = 
		paste("select year_, 
		dayofyear(", what, ") - dayofyear(STR_TO_DATE( concat_WS('-', year(",what,"), 'Apr-1'), '%Y-%M-%d')) as var ",
			"FROM BREEDING 
				where", what ,
					"is not NULL")
				, 
		db = db)
	
	 d$Year = factor(d$year_)
	d
	}
	
