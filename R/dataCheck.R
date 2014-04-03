

# BUGS 
bugs <- function(input, n_only = FALSE) {
	if( missing(input) ) 
		date_ = Sys.Date() else
		date_ = input$date 
	year = as.numeric(strftime(date_, format = "%Y"))
	
	f = system.file('SQL', 'BUGS.SQL', package = 'bib')

	d = Q(year = year, paste(readLines(con = f, warn = FALSE), collapse = " "))
	d = d[!is.na(d$boxes), ]
	
	if(n_only) return(nrow(d)) else {
		if(nrow(d) == 0) 
			d = data.frame(info = "There are no bugs for now.", date = date_ )
		row.names(d) = NULL
		return(d)
	}
 }

 # WARNINGS 
warnings <- function(input, n_only = FALSE) {
	if( missing(input) ) 
		date_ = Sys.Date() else
		date_ = input$date 
	year = as.numeric(strftime(date_, format = "%Y"))
	
	f = system.file('SQL', 'WARNINGS.SQL', package = 'bib')

	d = Q(year = year, paste(readLines(con = f, warn = FALSE), collapse = " "))
	d = d[!is.na(d$boxes), ]
	
	if(n_only) return(nrow(d)) else {
		if(nrow(d) == 0) 
			d = data.frame(info = "There are no warnings for now.", date = date_ )
		row.names(d) = NULL
		return(d)
	}
 }


  
 
# MESSAGES
predHatchDate <- function(input, ...) { 
	d = nestDataFetch(date_ = input$date, 
              stagesNFO = stagesInfo, stages = input$nestStages, 
              safeHatchCheck = input$safeHatchCheck, 
              youngAgeYN = input$youngAgeYN, youngAge = input$youngAge
        )
	
	# pred hatch: dist from laying date + CS date mean and range
	d1 = d[which(d$maxClutch > 6), ]
	x = round(difftime(d1$predHatchDate  ,  as.Date(d1$firstEggDate) + d1$maxClutch , units = 'days'))
	
	predhatch = paste('Predicted days of incubation (day 0 = last egg day): Mean = ', 
                    round(mean(x, na.rm = T), 1), 'days', '; range= (', 
                    paste(round(range(x, na.rm = T),1), collapse = ','), ')' )
	cat(predhatch)
	
}














