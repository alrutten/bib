
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
idDataFetch <- function(id , db = "BTatWESTERHOLZ", ...) {

  # Adults table
    A = Q(query = paste('SELECT year_, capture_date_time dt, ID,  FUNCTIONS.COMBO(UL, LL, UR, LR) cb, transponder, tarsus, author
                  FROM ADULTS WHERE ID    = ',shQuote(id) ,'  or 
                         transponder        = ',shQuote(id) ,' or 
                         FUNCTIONS.COMBO(UL, LL, UR, LR) = ',shQuote(id)), db = db )

    A
  
  
}
