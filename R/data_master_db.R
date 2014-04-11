
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
idDataFetch <- function(id , transp, combo , db = "BTatWESTERHOLZ", ...) {
  # TODO
  # transp = '67A741F9C66F0001'; id = 'B2F5444'
  
  if( !missing(transp) ) {
    ids = Q(query = paste("select distinct a.ID, transponder, s.sex 
                          from (SELECT distinct ID, transponder  FROM ADULTS UNION SELECT distinct ID, transponder  FROM CHICKS) a 
                            JOIN SEX s ON a.ID = s.ID where transponder = ", shQuote(transp) ), db = db, ...)
    id = ids$ID[1]
  }
  
  if( !missing(id) ) {
    ids = Q(query = paste("select distinct a.ID, transponder, s.sex 
                          from (SELECT distinct ID, transponder  FROM ADULTS UNION SELECT distinct ID, transponder  FROM CHICKS) a 
                          JOIN SEX s ON a.ID = s.ID where a.ID = ", shQuote(id) ), db = db, ...)
  }
  
  if( !missing(combo) ) {
    stop("selecting by color combination not yet implemented!")
  }
  
  
  d =  Q(query = paste("select * from (
    SELECT box, date_time date_ , 0 age, 'capture' recorded FROM CHICKS a  where ID = ", shQuote(id),
                       "UNION
    SELECT box, capture_date_time date_, age,'capture' recorded  FROM ADULTS a where ID = ", shQuote(id), " ) x 
    order by date_ asc"), db = db, ...)
  
  list(ids, d)
  
  
}
