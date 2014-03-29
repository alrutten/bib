
dayOfyear = function(date) {
	as.numeric(strftime(as.POSIXct(date), format = "%j"))
}
	
dayofyear2date <- function(dayofyear, year) {
	ans = as.Date(dayofyear - 1, origin = paste(year, "01-01", sep = "-"))
	as.POSIXct(round( as.POSIXct(ans), units = "days"))
	
	}

is.breeding	<- function() {
	d = as.numeric(format(Sys.time(), "%m"))
	if(d %in% 3:5) TRUE else FALSE
	}
	
add.alpha <- function (col,alpha) { sprintf("%s%02X",col,floor(alpha*256))	
	}

## query function
Q <- function(year, query, db) {
    
  if(missing(db)) {
	if(missing(year)) year = format(Sys.Date(), format = "%Y")
	if(year == format(Sys.Date(), format = "%Y") ) db = 'FIELD_BTatWESTERHOLZ' else db = paste('FIELD', year, 'BTatWESTERHOLZ', sep = "_")
	}
	
  CON = dbcon(user = "bt", password = "bt", database = db)

  on.exit(  closeCon (CON)  )

  return(dbq(CON, query))
}

# ...
getInputCopy <- function() {
	if( ! exists('inputCopy', .GlobalEnv) )
	source( system.file('settings.R', package = 'bib') )
	return(inputCopy)
	}

bibDescription <-function() {
	x = packageDescription('bib', fields=c('Package', 'Type', 'Version', 'Date', 'Maintainer', 'Depends', 'Suggests','Description')) 
	
	print(xtable::xtable(data.frame(info = unlist(x))), type = 'html')
}


