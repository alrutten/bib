

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


westerholz <- function() {
  require(bib)
  require(shiny)
  shiny::runApp(system.file('UI', package = 'bib'))
}





































  