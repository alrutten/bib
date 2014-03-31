

hr <- function(...) { 
 HTML("<hr>")
	}
	

experimentIDs = function() {
	Q(dd2yy(Sys.Date()), "select ID from EXPERIMENTS where visible = 'YES'" )$ID
}	
	

links <-function(nam) {
  switch(nam,
         man     = shQuote("http://scidb.orn.mpg.de/scidbwiki/westerholz/doku.php?id=current_field_manual"),
         journal = shQuote("http://scidb.orn.mpg.de/scidbwiki/westerholz/doku.php?id=current_field_journal")
  )
}


westerholz <- function() {
  require(bib)
  require(shiny)
  shiny::runApp(system.file('UI', package = 'bib'))
}





































  