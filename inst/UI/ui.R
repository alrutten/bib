
# SITE SCHEME
# fluidPage
# 	absolutePanel
#	fluidRow
#		column(9, tabsetPanel + tabPanel)
#		column(3, right setting panel:
#			tools common for all panels
# 			conditionalPanel(condition = "input.tools == 'tab panel name'"
require(bib)

shinyUI(

fluidPage(style="padding-top: 80px;",
	# js	
	includeScript( system.file('UI', 'js', 'bootstrap-tooltip.min.js', package = 'bib') ),
	HTML("<script type='text/javascript'>$(document).ready(function () {$('a').tooltip({'selector': '','placement': 'bottom', 'html': 'true'});});</script>"),
	HTML("<script type='text/javascript'>$(document).ready(function () {$('i').tooltip({'selector': '','placement': 'top', 'html': 'true'});});</script>"),
  
# top fixed bar start >>>>>>>>>>>>>>>>
absolutePanel(top = 2, left = 5, right = 0,fixed = FALSE,
    div(style="padding: 15px; border-bottom: 1px solid #CAD1E6;",
	 class="row-fluid container",
	# Title & links	
	HTML(paste(
			'<a data-toggle="tooltip" title=', shQuote(bibDescription(), type ="sh") , '>', 'WESTERHOLZ', format(Sys.Date(), "%Y"), '</a>',
			icon("bookmark-o"), '<a href=', links("man"), 'target="_blank" class="alert alert-info"> Manual </a> ',
				'<a href=', links("journal"), 'target="_blank" class="alert alert-info"> Journal </a> ',
				'<a href=', links("snb"), 'target="_blank" class="alert alert-info"> SNB </a> '
			)),
	# BUGS & WARNINGS		
	HTML('&nbsp;'), bugsHTML(2) , HTML('&nbsp;'),
	# TIPS
	includeScript( system.file('UI', 'js', 'tips.js', package = 'bib') )

	

	)
	
), #  top fixed bar end <<<<<<<<<


fluidRow(
column(9, 
# TABSET menu
	tabsetPanel(type = "tabs", id = "tools",selected = "MAPPING", 
	    tabPanel("HELP", dataTableOutput("colComments") ),
		tabPanel("MAPPING", plotOutput("maps",  height = 1000, width = 1000) ), 
		tabPanel("NEST HISTORY", plotOutput( 'nestGraph',height = 1000, width = 1300)  ) , 
		tabPanel("FORECASTING", plotOutput( 'forecastGraph',height = 1000, width = 1300)  ) , 
		tabPanel("BUGS", dataTableOutput( 'bugs')  ), 
		tabPanel("WARNINGS", dataTableOutput( 'warnings')  ), 
		tabPanel("experiments", dataTableOutput("experiments") ),
		tabPanel("PHENOLOGY", plotOutput( 'phenoGraph',  height = 800, width = 1000 )  ), 
		tabPanel("ID_history", plotOutput( 'IDGraph',height = 1000, width = 1000)  ), 
		tabPanel("settings", htmlOutput("settings") )

		
		)
	), 


column(3,
	## REFERENCE DATE
	div(class="row", p(""),
	  div(class = "span4", 
		dateInput('date', 
			label = HTML('<i class="fa fa-calendar" data-toggle="tooltip" class="label label-info" 
					title="Reference date."> Date:</i>'),
			min = '2007-03-01', max = Sys.Date()+30,
			format = "dd-M-yyy",
			value = Sys.Date(), 
			startview = "decade"))

    ),

	# HELP MENU start >>>>>>>>>>>>>>>>>>>>>>>>>>>
	conditionalPanel(condition = "input.tools == 'HELP'", 

   # table name
   selectInput("tabNamHelp", 
               label   = labHTML("info", "DATA ENTRY HELP", "Data entry help for each table and column!") ,
			   choices = list('NESTS' , 'ADULTS', 'CHICKS', 'AUTHORS', 'EXPERIMENTS'), 
               selected = "NESTS"),                    
  # data entry help
   includeHTML(system.file('UI', 'txt', 'block1.html', package = 'bib') ),
  # NOTES                
  includeMarkdown(system.file('UI', 'txt', 'block2.md', package = 'bib') )
          
 ),
	# HELP MENU end >>>>>>>>>>>>>>>>>>>>>>>>>>>
  
	# MAPPING MENU start >>>>>>>>>>>>>>>>>>>>>>>>>>>
	conditionalPanel(condition = "input.tools == 'MAPPING'",
	
	div(class="row", p(" ") ,
	# map type
	div(class="span3", 
		selectInput("mapType", 
			label =HTML('<i class="fa fa-globe" data-toggle="tooltip" class="label label-info" 
				title="Map type:interactive or a simple base map with no decorations."> Map type:</i> '), 
			choices = list('active' = 'activeMap', 'base'= 'baseMap'), 
			selected = "activeMap") ), 
			
  
	# add marks
	div(class="span3", 
	    radioButtons("marks", 
	                 label = HTML('<i class="fa fa-compass" data-toggle="tooltip" class="label label-info" 
					 title="Add user defined markers to the current map."> Markers</i>'),
	                 choices = c("Yes", "No") , selected = "No" )
	)
  
      
  ),
	

	#  add marks start >>>>>>>>>>>>>>>>>>>
	conditionalPanel(condition = "input.marks == 'Yes'",		
			
	div(class="row", p(" "), div(class="span1", icon("edit")),
		HTML('<div class="span2 control-group">
			  <a data-toggle="tooltip" class="label label-info" 
			  title=  "Add markers using a list with 3 components: box, color, text. Follow the template in the box." >
			  Define markers:</a>
			  <textarea id="marksList" rows="10" cols="30">
list( 
	box = c(65, 137, 271, 277), 
	col = c("red", "blue", "green", "black"), 
	text = ( c(1,2,"y", "n") )
	)
			  </textarea>
			</div>') )	
			
	),	
		
	#  add marks end <<<<<<<<<<<<<<<<<<<<<
	
	# PDF start >>>> 
	div(class="row",  p(""), 
		div(class="span5", 
		downloadButton('pdf', HTML('<button class="btn btn-small btn-primary" type="button"> PDF </button>') ) ) ), 
	# PDF end <<<
		
	
	#  visual settings start >>>>>>>>>>>>>>>>>>>
	# text & box size
	div(class="row", 
		div(class="span6", sliderInput("textCex",
						label = HTML('<i class="fa fa-gears" data-toggle="tooltip" class="label label-info" 
						title="Size of the text on screen map, it will also affect the pdf maps."> Text</i>'), 
						min = 0.5, max = 1.5, value = 0.8, step = 0.05) ), 
		div(class="span6", sliderInput("boxCex", 
						label = HTML('<i class="fa fa-gears" data-toggle="tooltip" class="label label-info" title="Box size on screen map, it will also affect the pdf maps."> Box size</i>'), 
						min = 0.5, max = 3, value = 2, step = 0.25) ) 
		),
	#transparency					
	div(class="row", p(" ") ,
		div(class="span5", sliderInput("transp", 
						label = HTML('<i class="fa fa-gears" data-toggle="tooltip" class="label label-info" 
						title="Box transparency on screen map, it will also affect the pdf maps."> Transparency</i>'), 
						min = 0, max = .95, value = 0.5, step = 0.05) ) ),
	#  visual settings end <<<<<<<<<<<<<<<<<<<<<
	
	#  active map start >>>>>>>>>>>>>>>>>>>
	conditionalPanel(condition = "input.mapType == 'activeMap'", 
	# nest stages
	div(class="row", p(" "),
		HTML('<div class="span2">  
				  <label for="nestStages"> <i class="fa fa-circle" data-toggle="tooltip" class="label label-info" title="Nest stages"> Stages</i>   </label>
				  <input name="nestStages" type="checkbox" value="U"/> <i data-toggle="tooltip"  title=  "Used" > U </i> <br/>
				  <input name="nestStages" type="checkbox" value="LT"  checked="checked"/><i data-toggle="tooltip"  title=  "Little" >LT</i> <br/>
				  <input name="nestStages" type="checkbox" value="R"   checked="checked"/><i data-toggle="tooltip"  title= "Ring" >R</i> <br/>
				  <input name="nestStages" type="checkbox" value="B"   checked="checked"/><i data-toggle="tooltip"  title= "Bottom" >B</i><br/>
				  <input name="nestStages" type="checkbox" value="BC"  checked="checked"/><i data-toggle="tooltip"  title= "Bottom-Cup" >BC</i><br/>
				  <input name="nestStages" type="checkbox" value="C"   checked="checked"/><i data-toggle="tooltip"  title= "Cup" >C</i><br/>
				  <input name="nestStages" type="checkbox" value="LIN" checked="checked"/><i data-toggle="tooltip"  title=  "Lining" >LIN</i><br/>
				  <input name="nestStages" type="checkbox" value="E"   checked="checked"/><i data-toggle="tooltip"  title=  "Eggs" >E</i><br/>
				  <input name="nestStages" type="checkbox" value="Y"   checked="checked"/><i data-toggle="tooltip"  title=  "Young" >Y</i><br/>
				  <input name="nestStages" type="checkbox" value="NOTA"                 /><i data-toggle="tooltip"  title=  "Not Active" >NOTA</i><br/>
				  <input name="nestStages" type="checkbox" value="WSP" checked="checked"/><i data-toggle="tooltip"  title=  "Wasp nest" >WSP</i> <br/> 
			  </div>'),
			  
		#hatching estimation
		div(class = "span3",
			selectInput("safeHatchCheck", 
				label = HTML('<i class="fa fa-wrench" data-toggle="tooltip" class="label label-info" 
					title="How many days in advance to check for hatching. 0 selects the predicted hatching date"> Hatch check</i> ') , 
				choices = 0:-3, selected =  -3), 
				hr(),
			checkboxInput("hatchNow", 
				label =HTML('<i class="fa fa-wrench" data-toggle="tooltip" class="label label-info"
					title="Emphasise boxes where hatching is imminent"> Hatching NOW:</i>'), 
				value = TRUE)), 
		
		#young age
			div(class="span3", radioButtons("youngAgeYN", 
			label = HTML('<i class="fa fa-wrench" data-toggle="tooltip" class="label label-info" 
					title="Check SELECT to select nests with particular young ages."> Young age</i>'),
			choices = c("ALL", "SELECT") , selected = "ALL" ), 
	
	conditionalPanel(condition = "input.youngAgeYN == 'SELECT'",		
		selectInput("youngAge", 
			label = HTML('<i class="fa fa-wrench" data-toggle="tooltip" class="label label-info" 
				title="Select particular young ages <hr> HOLD CTR or SHIFT TO SELECT MULTIPLE VALUES"> Age on map</i>'), 
				choices = 1:25, selected = 14, multiple =  TRUE) ) ), 
				
		# parents
		div(class="span1", radioButtons("parents", 
			label = HTML('<i class="fa fa-wrench" data-toggle="tooltip" class="label label-info" 
				title="Show caught parents on the curent map."> Parents</i> '),
			choices = c("YES", "NO") , selected = "NO" ) )
	)	
	)
	#  active map end <<<<<<<<<<<<<<<<<

	), # MAPPING MENU end <<<<<<<<<<<<<<<<<

	
	# PHENOLOGY MENU start >>>>>>>>>>>>
	conditionalPanel(condition = "input.tools == 'PHENOLOGY'",
				
		selectInput("phenoType", label = HTML('<a class="label label-info" ">Paramerer:</a>'), 
			list('firstEgg' = 'firstEgg', 'hatchDate'= 'hatchDate' , 'fledgeDate'= 'fledgeDate'), "firstEgg")
	),
	# PHENOLOGY MENU end  <<<<<<<<<<<<<<

	# Nest history start >>>>>>>>>>>>
	conditionalPanel(condition = "input.tools == 'NEST HISTORY'",
				
		sliderInput("NestId", 
						label = div(HTML('<a data-toggle="tooltip" class="label label" title="Press play or use the slider to choose a box ">Box: </a>')),
						min = 1, max = 277, value = 1, step = 1, ticks = FALSE,
						animate  =  animationOptions(interval = 1300, loop = FALSE, 
						playButton = div(HTML('<button class="btn btn-mini btn-primary" type="button">Play</button>')), 
						pauseButton = div(HTML('<button class="btn btn-mini btn-danger" type="button">Stop</button>')))), 
						
		numericInput("NestIdEntry", 
				label= HTML('<a data-toggle="tooltip" class = "label label" title = "Type a box number here. Delete entry here to activate back the slider" >Type Box: </a>'), 
				value = NULL)
						
		), 
	
	# BUGS SQL list start  >>>>>>>>>>>>>>>
	conditionalPanel(condition = "input.tools == 'BUGS'", 
	 includeMarkdown(system.file('UI', 'txt', 'block3.md', package = 'bib') )	
	),
	
	# BUGS SQL list end  <<<<<<<<<<<<<<

	# SETTINGS start >>>>>>>>>>>>
	
	conditionalPanel(condition = "input.tools == 'settings' ",
		selectInput("host", 
		            label =  HTML('<i class="fa fa-home" data-toggle="tooltip" class="label label-info" title=
								"Database server location. Do not change unless the primary host scidb.orn.mpg.de does not work"> 
								Host: </i>'), 
		            choices = list('scidb.orn.mpg.de' , 'localhost', 'scicomp.orn.mpg.de'), 
		            selected = 'scidb.orn.mpg.de') 
	),
	# Settings end  <<<<<<<<<<<<<<
	
 # experiments starts >>>>>>>>>>>>
	conditionalPanel(condition = "input.tools == 'experiments' ",
		selectInput("experiments", 
						label = HTML('<i class="fa fa-bullseye" data-toggle="tooltip" class="label label-info" 
							title="Experiment ID number (see |EXPERIMENTS| table. <hr> Displays experiment on the map and returns data associated 
                         with the selected experiment."> Experiment ID</i> '),
						choices  = 1:10, 
						selected = 2, 
					  multiple =  FALSE)
  ),
	# experiments ends <<<<<<<<<<<<<<
	
 # ID history starts >>>>>>>>>>>>
 conditionalPanel(condition = "input.tools == 'ID_history' ",
                  textInput("birdID", 
                    label = HTML('<i class="fa fa-pencil" data-toggle="tooltip" class="label label-info" 
						      	title="Bird ID: Enter ANY of the three IDs: ring number, color combination (UL/LL|UR/LR) or transponder"> Bird ID</i> '),
                    value  = "B2F5444"),
	
	hr(),	
	HTML(recordsTab())
	
	
					
					
 )
 # ID history ends <<<<<<<<<<<<<<
 
	

) # tool right bar end <<<<<<<<<

)))














 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 