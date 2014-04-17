
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

tarsusDataFetch  <- function(db = "BTatWESTERHOLZ", ...) {

   Q(query = '
	SELECT avg(tarsus) tarsus, CASE when sex  = 1 THEN "male" when sex = 2 THEN "female" END sex
		from (SELECT tarsus, s.sex, a.ID FROM ADULTS a JOIN SEX s on a.ID = s.ID where tarsus is not NULL) x 
				group by ID, sex', db = db )
	


  
}

massDataFetch    <- function(db = "BTatWESTERHOLZ", ...) {

   Q(query = '
	SELECT avg(weight) weight, CASE when sex  = 1 THEN "male" when sex = 2 THEN "female" END sex
		from (SELECT weight, s.sex, a.ID FROM ADULTS a JOIN SEX s on a.ID = s.ID where weight is not NULL) x 
				group by ID, sex', db = db )
	


  
}

recordsDataFetch <- function(db = "BTatWESTERHOLZ", ...) {
   Q(query = "
-- body mass & size
	(SELECT 'Heaviest male' record, a.ID, weight measure, 'grams' comments 
		FROM ADULTS a  JOIN SEX s on a.ID = s.ID where s.sex = 1 order by weight desc limit 1)
	UNION
	( SELECT 'Heaviest female' record, a.ID, weight measure , 'grams' comments  FROM ADULTS a  JOIN SEX s on a.ID = s.ID where s.sex = 2 order by weight desc limit 1)
	UNION
-- age
	(SELECT 'Oldest male' record, x.ID, age  measure, 'years; using ADULTS' comments 
	FROM
	(SELECT dt1, dt2, ROUND(DATEDIFF(dt2, dt1)/365,1) age, a.ID
	 FROM (SELECT min(capture_date_time) dt1, ID FROM ADULTS a GROUP BY ID ) a 
		JOIN (SELECT max(capture_date_time) dt2, ID FROM ADULTS a GROUP BY ID ) b 
			ON a.ID = b.ID where dt1 <> dt2 ) x
		JOIN SEX s on s.ID = x.ID 
			where sex = 1
			order by age desc limit 1)
	UNION		
	(SELECT 'Oldest female' record, x.ID, age  measure, 'years; using ADULTS' comments 
	FROM
	(SELECT dt1, dt2, ROUND(DATEDIFF(dt2, dt1)/365,1) age, a.ID 
	 FROM (SELECT min(capture_date_time) dt1, ID FROM ADULTS a GROUP BY ID ) a 
		JOIN (SELECT max(capture_date_time) dt2, ID FROM ADULTS a GROUP BY ID ) b 
			ON a.ID = b.ID where dt1 <> dt2 ) x
		JOIN SEX s on s.ID = x.ID 
			where sex = 2
			order by age desc limit 1)
-- promiscuity	
	UNION
	(select 'Most promiscuous male' record, father ID, sum(epy) measure, 'EPY (within-season)' comments 
		FROM PATERNITY where father is not NULL group by father, year_ order by sum(epy) desc limit 1)	
-- worst year
UNION
 (select 'Worst breeding season' record,  a.year_ ID, (failed/all_)*100 measure  ,'% failed nests' FROM 
	(select year_, COUNT(box) failed FROM BREEDING where hatched = 0 group by year_) f
	JOIN
	(select year_, COUNT(box) all_ FROM BREEDING where hatched > 0 group by year_) a
		ON f.year_ = a.year_ order by failed/all_ desc limit 1)
		
UNION
 (select 'Best breeding season' record, a.year_ ID,  (failed/all_)*100 measure, '% failed nests' FROM 
	(select year_, COUNT(box) failed FROM BREEDING where hatched = 0 group by year_) f
	JOIN
	(select year_, COUNT(box) all_ FROM BREEDING where hatched > 0 group by year_) a
		ON f.year_ = a.year_ order by failed/all_ asc limit 1)

UNION

(SELECT 'Number of nest checks' record, NULL ID, 
	(SELECT ( (SELECT COUNT(*) x FROM FIELD_2007_BTatWESTERHOLZ.NESTS) +
			(SELECT COUNT(*) x FROM FIELD_2008_BTatWESTERHOLZ.NESTS) +
			(SELECT COUNT(*) x FROM FIELD_2009_BTatWESTERHOLZ.NESTS) +
			(SELECT COUNT(*) x FROM FIELD_2010_BTatWESTERHOLZ.NESTS) +
			(SELECT COUNT(*) x FROM FIELD_2011_BTatWESTERHOLZ.NESTS) +
			(SELECT COUNT(*) x FROM FIELD_2012_BTatWESTERHOLZ.NESTS) +
			(SELECT COUNT(*) x FROM FIELD_2013_BTatWESTERHOLZ.NESTS) +
			(SELECT COUNT(*) x FROM FIELD_BTatWESTERHOLZ.NESTS) ) ) 	 measure, 
			'nest checks since 13-Mar-2007' comments
	)		
		
		
		
  ", db = db )
   
  
}



































