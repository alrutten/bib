
# date time utils
dayOfyear = function(date) {
	as.numeric(strftime(as.POSIXct(date), format = "%j"))
}
	
dayofyear2date <- function(dayofyear, year) {
	ans = as.Date(dayofyear - 1, origin = paste(year, "01-01", sep = "-"))
	as.POSIXct(round( as.POSIXct(ans), units = "days"))
	
	}

dd2yy <- function(date)  {
	as.numeric(strftime(date, format = "%Y"))
	}	

# DB	
credentials <-function(w) {
	  switch(w,
         user = 'bt',
         pwd = 'bt')
}
	
# find database name from year
yy2dbnam <- function(year) {
	if(year == format(Sys.Date(), format = "%Y") ) 
		db = 'FIELD_BTatWESTERHOLZ' else 
		db = paste('FIELD', year, 'BTatWESTERHOLZ', sep = "_")
		return(db)
}
	
## query function
Q <- function(year, query, db) {
    
	if(missing(year)) 
		year = format(Sys.Date(), format = "%Y")
	if(missing(db)) 
		db = yy2dbnam(year)	
		
  CON = dbcon(user = credentials ('user'), password = credentials ('pwd'), database = db )
  on.exit(  closeCon (CON)  )
  return(dbq(CON, query))
}

uef <-function(fun, ID, year) { 
	# update function in the EXPERIMENTS table
	stopifnot( inherits(fun, 'function') )
	stopifnot( require('RMySQL') )
	
	fstring = paste(deparse(fun), collapse= "\n")
	sql = paste("UPDATE EXPERIMENTS SET function=", shQuote(fstring, type ='sh') ," WHERE ID=", ID)

	  CON = dbcon(user = credentials ('user'), password = credentials ('pwd'), database = yy2dbnam(year) )
	
	 dbSendQuery(CON, sql)
	dbDisconnect(CON)
	
	}

# ...
is.breeding	<- function() {
	d = as.numeric(format(Sys.time(), "%m"))
	if(d %in% 3:5) TRUE else FALSE
	}
	
add.alpha <- function (col,alpha) { sprintf("%s%02X",col,floor(alpha*256))	
	}
		
bibDescription <-function() {
	x = packageDescription('bib', fields=c('Package', 'Type', 'Version', 'Date', 'Maintainer', 'Depends', 'Suggests','Description')) 
	
	print(xtable::xtable(data.frame(info = unlist(x))), type = 'html')
}


















































	

