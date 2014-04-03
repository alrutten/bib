

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


westerholz <- function() {
  require(bib)
  require(shiny)
  shiny::runApp(system.file('UI', package = 'bib'))
}





































  