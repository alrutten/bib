
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

	

Q <- function(year, query, ...) {
  
  if(missing(year)) year = format(Sys.Date(), format = "%Y")
  if(year == format(Sys.Date(), format = "%Y") ) db = 'FIELD_BTatWESTERHOLZ' else db = paste('FIELD', year, 'BTatWESTERHOLZ', sep = "_")
  
  CON = dbcon(user = "bt", password = "bt", database = db)

  on.exit(  closeCon (CON)  )

  return(dbq(CON, query))
}






