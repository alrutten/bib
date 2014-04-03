

hr <- function(...) { 
 HTML("<hr>")
	}
	

links <-function(nam) {
  switch(nam,
         man     = shQuote("http://scidb.orn.mpg.de/scidbwiki/westerholz/doku.php?id=current_field_manual"),
         journal = shQuote("http://scidb.orn.mpg.de/scidbwiki/westerholz/doku.php?id=current_field_journal"), 
         snb = shQuote("http://scicomp.orn.mpg.de:3838/shinyAPP2/SNBatWESTERHOLZ/")
  )
}


bugsHTML <-function( size = 1) {
	n = bugs(n_only=T)
	if(n > 0) HTML(rep( paste0('<i class="fa fa-bug fa-', size, 'x fa-spin"></i>'), n ) )
	}

tipsHTML <-function() {
	tp = c(
	"When printing the map of tomorrow already today remember to change the date !", 
	"If there are bugs in the data your daily map could be wrong or incomplete!",
	"LAYING_START and HATCHING_START columns are redundant but they serve as a double check!",
	
	
	)
	
	sample(tp, 1)
	
	

}	

	
	
	
	
westerholz <- function() {
  require(bib)
  require(shiny)
  shiny::runApp(system.file('UI', package = 'bib'))
}





































  