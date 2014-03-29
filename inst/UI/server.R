
shinyServer( function(input, output) {

# load components	

	source( system.file('components.R', package = 'bib') )
	source( system.file('settings.R', package = 'bib') )

# data tables	
	output$bugs <- renderDataTable({ bugs(input = input) } )	
	output$warnings <- renderDataTable({ bugs(input = input,  warnings = TRUE) } )	
  output$colComments <- renderDataTable({ getComments(tab = input$tabNamHelp, date = input$date) } )
		
# print
	output$info <- renderPrint({

	cat( paste(length(input$nestStages), 'out of', nrow(stagesInfo) , 'stages selected! <br>'))
	  
	cat( paste('Hatch check is set to', abs(as.numeric(input$safeHatchCheck)), ' days in advance! <br>'))  		 
	predHatchDate(input =input)

	# input content
	a = reactiveValuesToList(input, all.names = FALSE)
	x = data.frame(what = names(unlist(a)), v = unlist(a))
	row.names(x) = NULL

	cat('<hr> Current settings:')
	print(xtable::xtable(x), type="html")
	
	#NOTES:
	cat(markdown::markdownToHTML(fragment.only=TRUE, text = 
"<hr> *NOTES*  
You can use this interface (and the software behind it)   
independently of the `scicomp` server:    
* Open `R`  
* install `devtools` package with `install.packages(devtools)`  
* install the `bib` and the `sdb` packages with:  
	* `devtools::install_github(c('valcu/sdb', 'valcu/bib'))`
* to open the user interface run:
	* bib::westerholz()  

Here are a few useful functions:
* nestDataQuery()
* map()
* basemap()

"))
	
	
	
  })
 
# graphics 
	output$maps <- renderPlot( {maps(input = input)}  )
	output$phenoGraph <- renderPlot( {phenoGraph(input = input)}  )
	output$nestGraph <- renderPlot( {nestGraph(input = input)}  )
	output$firstEggPrediction <- renderPlot( {egg1Graph(input = input)}  )
	output$forecastGraph <- renderPlot( {forecastGraph(input = input)}  )

# PDF
	output$pdf <- downloadHandler(
		filename = tempfile(fileext='.pdf'),
		content = function(file) {
		maps(input = input, pdf = TRUE, file = file)
	})

  
  
  
 })
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
