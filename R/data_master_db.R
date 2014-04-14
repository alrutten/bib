
# phenology ----
phenologyDataFetch  <- function(what = 'firstEgg', db = "BTatWESTERHOLZ", ...) {
  
  d = Q(query = 
          paste("select year_, 
                dayofyear(", what, ") - dayofyear(STR_TO_DATE( concat_WS('-', year(",what,"), 'Apr-1'), '%Y-%M-%d')) as var ",
                "FROM BREEDING 
                where", what ,
                "is not NULL")
        , 
        db = db, ...)
  
  d$Year = factor(d$year_)
  d
}

# ID  (TO DO add to UI)----
idDataFetch <- function(id , db = "BTatWESTERHOLZ") {

  # Adults table
    A = Q(query = paste('
	SELECT tab, year_,  x.box, x,y, dt, x.ID, cb, case when sex = 1 then "male" when sex = 2 then "female" end sex, transponder, tarsus, weight, author
		FROM	
		(SELECT "ADULTS" tab, year_,  box, capture_date_time dt, ID,  FUNCTIONS.COMBO(UL, LL, UR, LR) cb, transponder, tarsus,weight, author
			FROM ADULTS WHERE ID    = ',shQuote(id) ,'  or transponder  = ',shQuote(id) ,' or FUNCTIONS.COMBO(UL, LL, UR, LR) = ',shQuote(id),
		'UNION  						
		SELECT "CHICKS" tab, year_, box, date_time dt, ID,  FUNCTIONS.COMBO("", "", "", "M") cb, transponder, tarsus,weight, author
			FROM CHICKS WHERE ID  = ',shQuote(id) ,'  or transponder = ',shQuote(id), ') x
			JOIN BOX_geoCoordinates g on x.box = g.box
			JOIN SEX s on s.ID = x.ID
			'),
	db = db )
	
	

    A
  
  
}

tarsusDataFetch <- function(db = "BTatWESTERHOLZ", ...) {

   Q(query = '
	SELECT avg(tarsus) tarsus, CASE when sex  = 1 THEN "male" when sex = 2 THEN "female" END sex
		from (SELECT tarsus, s.sex, a.ID FROM ADULTS a JOIN SEX s on a.ID = s.ID where tarsus is not NULL) x 
				group by ID, sex', db = db )
	


  
}

massDataFetch <- function(db = "BTatWESTERHOLZ", ...) {

   Q(query = '
	SELECT avg(weight) weight, CASE when sex  = 1 THEN "male" when sex = 2 THEN "female" END sex
		from (SELECT weight, s.sex, a.ID FROM ADULTS a JOIN SEX s on a.ID = s.ID where weight is not NULL) x 
				group by ID, sex', db = db )
	


  
}



























