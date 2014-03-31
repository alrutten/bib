
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

# marks is a list with 3 elements (box, col, text)
# marks is an optional argument for basemap() and map()
# e.g. marks = list( c(28,29,44), c(2,2,2), c(5,6,7) )
addMarks <- function(marks, x_0 = 4500013L, y_0 = -8L) {
	require(rgdal)
	
	m = boxes[boxes$box%in%marks[[1]], ]
	m = spTransform(m, 
		CRS(paste0("+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=",x_0," +y_0=",y_0," +datum=potsdam +units=m +no_defs") ) )
	points(m, pch = 15, col = marks[[2]], cex = 1.7)
	text(m, labels = marks[[3]], cex = .8, col = 'white')
	
	}


#experimentIDs = function(year = dd2yy( Sys.Date() ) ) {
#  res = try(Q(year, "select ID from EXPERIMENTS where visible = 'YES'" ), silent = TRUE)
#  if(inherits(res, "data.frame") && nrow(res) > 0) res else NA
#}	















	

