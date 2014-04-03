
shinyServer( function(input, output, clientData, session) {

# load components	
	source( system.file('components.R', package = 'bib') )
	source( system.file('settings.R', package = 'bib') )

# update UI based on user data
#  observe( {
#    expID = experimentIDs( dd2yy(input$date) )
#    updateSelectInput(session, "experiments",
#                choices = expID,
#                selected = expID)
#    })      
  
# data tables	
	output$bugs      <- renderDataTable({ bugs(input = input) } )	
	output$warnings  <- renderDataTable({ warnings(input = input) } )	
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

	if(input$tools == 'info') assign('input', a, .GlobalEnv)
	
	cat('<hr> Current settings:')
	print(xtable::xtable(x), type="html")
	
	cat('<hr> ')
	
	
		
  })
 
# graphics 
	output$maps <- renderPlot( {maps(input = input)}  )
	output$phenoGraph <- renderPlot( {phenoGraph(input = input)}  )
	output$nestGraph <- renderPlot( {nestGraph(input = input)}  )
	output$firstEggPrediction <- renderPlot( {egg1Graph(input = input)}  )
	output$forecastGraph <- renderPlot( {forecastGraph(input = input)}  )


# DOWNLOADS	
	
# PDF
	output$pdf <- downloadHandler(
		filename = tempfile(fileext='.pdf'),
		content = function(file) {
		maps(input = input, pdf = TRUE, file = file)
	})

  
 })
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
