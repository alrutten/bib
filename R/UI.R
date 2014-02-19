

hr <- function(...) { 
 HTML("<hr>")
	}
	
icon <- function(nam) { 
	HTML( paste('<i class="icon-', nam, '"></i>', sep = ""))

	}

links <-function(nam) {
  switch(nam,
         man     = shQuote("http://scidb.orn.mpg.de/scidbwiki/westerholz/doku.php?id=current_field_manual"),
         journal = shQuote("http://scidb.orn.mpg.de/scidbwiki/westerholz/doku.php?id=current_field_journal")
  )
}


westerholz <- function() {
  require(shiny)
  shiny::runApp(system.file('UI', package = 'bib'))
}





































  