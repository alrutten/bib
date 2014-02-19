

# BUGS & WARNINGS
bugs <- function(year, warnings = FALSE) {
	
  ff = list.files(system.file('SQL', package = 'bib'), full.names = TRUE)
  
	if(warnings) f = ff[grep('WARNINGS', ff)] else f = ff[grep('BUGS', ff)]
	
  
  strg = paste(readLines(con = f, warn = FALSE), collapse = " ")
	d = Q(year = year, strg)
	d = d[!is.na(d$boxes), ]
	
	if(nrow(d) == 0) d = data.frame(info =   if(warnings)   "There are no warnings for now." else "There are no bugs for now." )
	row.names(d) = NULL
	d
 } 
  
 
# MESSAGES
predHatchDate <- function(input, ...) { 
	d = dataFetch(year = input$year, month  = input$month, day = input$day, 
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














