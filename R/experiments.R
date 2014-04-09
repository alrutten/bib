

getExperiments <- function(year, expID, ...) {

  x = Q(year = year, paste("SELECT ID, Title, author, function fun FROM EXPERIMENTS 
					where visible = 'YES' and ID in (", 
					paste(expID, collapse = "," ), ")"  ), ...)
					
	  if(nrow(x) > 0) {
  
	   # get function
    funs = split(as.character(x$fun), x$ID)
      for(i in 1:length(funs)) {
      tf = tempfile()
      cat(funs[[i]], file = tf)
      funs[[i]] = try( eval( parse(file = tf ) ), silent = TRUE) 
      file.remove(tf)
      }
    
    funs = funs[sapply(funs, function(f) inherits(f, "function") )]

    funs
  			
  	}

}
  
 experimentsMap <- function(input) {

  if(length(input$experiments) > 0  ) {
  	year = dd2yy(input$date)
  
		e = getExperiments(year, input$experiments)
		lapply(e, function(f) try( addMarks( f(input) ), silent = TRUE)  )
		}
		
}		
	 

fetchExperimentData <- function(input) {
	year = dd2yy(input$date)
	fun = getExperiments(year, input$experiments)[[1]]
	if(is.null(fun)) o = data.frame(x = 1, note = paste('Experiment', input$experiments, 'returns no data')   ) else
	o = fun(input, returnData = TRUE)
	return(o)
}
	 
	 