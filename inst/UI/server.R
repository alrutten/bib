

    

shinyServer( function(input, output) {
 	
	source( system.file('settings.R', package = 'bib') )


	
  output$bugs <- renderTable({
    bugs(year = input$year) }, include.rownames = FALSE, include.colnames = FALSE )	

  output$warnings <- renderTable({
    bugs(year = input$year,  warnings = TRUE) }, include.rownames = FALSE, include.colnames = FALSE )	
	
		
	
  output$messages <- renderPrint({
 cat( paste(length(input$nestStages), 'out of', nrow(stagesInfo) , 'stages selected! <br>'))  		 
 cat( paste('Hatch check is set to', abs(as.numeric(input$safeHatchCheck)), ' days in advance! <br>'))  		 
 dataSummaries(input =input)
	


	
  })
  


  output$PLOT <- renderPlot({
	

	
	PLOT(input = input)

	
   } 
  
  ,width  = 210*4 , height = 297*3.2
  )
  
   
    output$pdf <- downloadHandler(
		filename = tempfile(fileext='.pdf'),
		content = function(file) {
		PLOT(input = input, pdf = TRUE, file = file)
		
	
	}
  )

  
  
  
 })
 
 
 
 
 
