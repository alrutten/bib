
shinyServer( function(input, output) {
 	
   source( system.file('settings.R', package = 'bib') )
	
  output$bugs <- renderDataTable({ bugs(input = input) } )	
  output$warnings <- renderDataTable({ bugs(input = input,  warnings = TRUE) } )	
		
	
  output$info <- renderPrint({
    
   cat( paste(length(input$nestStages), 'out of', nrow(stagesInfo) , 'stages selected! <br>'))
      
  cat( paste('Hatch check is set to', abs(as.numeric(input$safeHatchCheck)), ' days in advance! <br>'))  		 
   predHatchDate(input =input)
   
   cat('<hr> Internal info, for debugging only: <br>')
   a = reactiveValuesToList(input, all.names = TRUE)
   lapply(a, function(x) cat(x, "<br>") )
	
  })
  
  output$maps <- renderPlot( {maps(input = input)}  )
  output$phenoGraph <- renderPlot( {phenoGraph(input = input)}  )
  output$nestGraph <- renderPlot( {nestGraph(input = input)}  )
  output$firstEggPrediction <- renderPlot( {egg1Graph(input = input)}  )
  output$forecastGraph <- renderPlot( {forecastGraph(input = input)}  )
  
   
  output$pdf <- downloadHandler(
		filename = tempfile(fileext='.pdf'),
		content = function(file) {
		maps(input = input, pdf = TRUE, file = file)
	})

  
  
  
 })
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
