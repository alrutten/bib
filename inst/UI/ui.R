
# SITE SCHEME
# fluidPage
# 	absolutePanel
#	fluidRow
#		column(9, tabsetPanel + tabPanel)
#		column(3, right setting panel:
#			tools common for all panels
# 			conditionalPanel(condition = "input.tools == 'tab panel name'"

shinyUI(
fluidPage(style="padding-top: 80px;",
	# js	
	HTML("
	<script src='http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/js/bootstrap-tooltip.min.js'></script> 
	<script type='text/javascript'>$(document).ready(function () {$('a').tooltip({'selector': '','placement': 'bottom', 'html': 'true'});});</script>
	"),

	# html bricks 
	includeHTML(system.file('HTML', 'data_entry_help.html', package = 'bib')),

# top fixed bar start >>>>>>>>>>>>>>>>
absolutePanel(
    top = 0, left = 0, right = 0,
    fixed = TRUE,
    div(style="padding: 8px; border-bottom: 1px solid #CCC; background: #FFFFEE;",
	 class="row-fluid",

	div(class = "span12", 
	
	HTML( 	   
		paste('<ul class="nav nav-pills">', 
			paste('<li >', 
				paste('<a data-toggle="tooltip" title=', shQuote(bib::bibDescription()) , '>'), 
				 'WESTERHOLZ', format(Sys.Date(), "%Y"), '</a> </li>'),
			paste('<li class="active"><a href=', links("man"), 'target="_blank">Manual </a> </li>'),
			paste('<li class="active"><a href=', links("journal"), 'target="_blank"> Journal </a></li>'), 
			paste('<li class="active"> <a data-toggle="modal" href= "#dataEntry" >Data entry</a></li>'), 
			paste('<li class="active"><a href= "http://scicomp.orn.mpg.de:3838/shiny-server/SNB/" target="_blank"> snb </a></li>'), 
		 "</ul>")
		)
		
	#	
		

	)
	)), #  top fixed bar end <<<<<<<<<


fluidRow(
column(9, 
# TABSET menu
	tabsetPanel(type = "tabs", id = "tools",

		tabPanel("MAPPING", plotOutput("maps",  height = 1000, width = 1000) ), 
		tabPanel("NEST HISTORY", plotOutput( 'nestGraph',height = 1000, width = 1300)  ) , 
		tabPanel("FORECASTING", plotOutput( 'forecastGraph',height = 1000, width = 1300)  ) , 
		tabPanel("BUGS", dataTableOutput( 'bugs')  ), 
		tabPanel("WARNINGS", dataTableOutput( 'warnings')  ), 
		tabPanel("PHENOLOGY", plotOutput( 'phenoGraph',  height = 800, width = 1000 )  ), 
		tabPanel("info", htmlOutput("info") ), 
		tabPanel("HELP", dataTableOutput("colComments") )
		

		)
	), 


column(3,
	## REFERENCE DATE
	   div(class="row", p(" ") , div(class="span1", icon("wrench")),
	   dateInput('date', 
		label = HTML('<a data-toggle="tooltip" class="label label-info" title=  "This is the reference date, anything is done as if this date is today" >Date:</a>'),
		min = '2007-03-01', max = Sys.Date()+7,
		format = "dd-M-yyy",
		value = Sys.Date(), 
		startview = "decade"
		)) ,

	
	
	# MAPPING MENU start >>>>>>>>>>>>>>>>>>>>>>>>>>>
	conditionalPanel(condition = "input.tools == 'MAPPING'",
	
	div(class="row", p(" ") , div(class="span1", icon("wrench")),
	# map type
	div(class="span3", 
		selectInput("mapType", 
			label =  HTML('<a data-toggle="tooltip" class="label label-info" title="Map type: 
					interactive or a simple base map with no decorations." > Map type: </a>'), 
			choices = list('active' = 'activeMap', 'base'= 'baseMap'), 
			selected = "activeMap") ), 
			
	# add marks
	div(class="span3", 
		radioButtons("marks", 
			label = HTML('<a data-toggle="tooltip" class="label label-info" title=  "Add user defined markers to the current map." >
				Add marks:</a>'),
			choices = c("Yes", "No") , selected = "No" )
			)
	),
	

	#  add marks start >>>>>>>>>>>>>>>>>>>
	conditionalPanel(condition = "input.marks == 'Yes'",		
			
	div(class="row", p(" "), div(class="span1", icon("pencil")),
		HTML('<div class="span2 control-group">
			  <a data-toggle="tooltip" class="label label-info" 
			  title=  "Add markers using a list with 3 components: box, color, text. Follow the template in the box." >
			  Define markers:</a>
			  <textarea id="marksList" rows="10" cols="30">
list( 
	box = c(65, 137, 271, 277), 
	col = c("red", "blue"), 
	text = ( c(1,2,"x") )
	)
			  </textarea>
			</div>') )	
			
	),	
		
		
		
	#  add marks end <<<<<<<<<<<<<<<<<<<<<
	
	# PDF start >>>> 
	div(class="row", p(" "), div(class="span1", icon("print")),
		div(class="span1", 
		downloadButton('pdf', HTML('<button class="btn btn-small btn-primary" type="button"> PDF </button>') ) ) ), 
	# PDF end <<<
		
	
	#  visual settings start >>>>>>>>>>>>>>>>>>>
	# text & box size
	div(class="row", p(" ") , div(class="span1", icon("wrench")),
		div(class="span5", sliderInput("textCex", 
						label = div(HTML('<a data-toggle="tooltip" class="label label" title="Size of the text on screen map, it will also affect the pdf maps.">Text size: </a>')), 
						min = 0.5, max = 1.5, value = 0.8, step = 0.05) ), 
		div(class="span5", sliderInput("boxCex", 
						label = div(HTML('<a data-toggle="tooltip" class="label label"  title="Size of the box symbols on screen map, it will also affect the pdf maps.">Box size: </a>')), 
						min = 0.5, max = 3, value = 2, step = 0.25) ) ),
	#transparency					
	div(class="row", p(" ") , div(class="span1", icon("wrench")),
		div(class="span5", sliderInput("transp", 
						label = div(HTML('<a data-toggle="tooltip" class="label label" title="box transparency.">Transparency: </a>')), 
						min = 0, max = .95, value = 0.5, step = 0.05) ) ),
	#  visual settings end <<<<<<<<<<<<<<<<<<<<<
	
	#  active map start >>>>>>>>>>>>>>>>>>>
	conditionalPanel(condition = "input.mapType == 'activeMap'", 
	# nest stages
	div(class="row", p(" "),
		div(class="span1", icon("pencil")),
		HTML('<div class="span2 control-group">
              <label class="control-label" for="nestStages"><a data-toggle="tooltip" class="text-info" title=  "Nest stages" >Stages:</a></label>
              <input name="nestStages" type="checkbox" value="U"/> <a data-toggle="tooltip" class="text-success" title=  "Used" > U </a> <br/>
              <input name="nestStages" type="checkbox" value="LT"/><a data-toggle="tooltip" class="text-success" title=  "Little" >LT</a> <br/>
              <input name="nestStages" type="checkbox" value="R" checked="checked"/><a data-toggle="tooltip" class="text-success" title= "Ring" >R</a> <br/>
              <input name="nestStages" type="checkbox" value="B" checked="checked"/><a data-toggle="tooltip" class="text-success" title= "Bottom" >B</a><br/>
              <input name="nestStages" type="checkbox" value="BC" checked="checked"/> <a data-toggle="tooltip" class="text-success" title= "Bottom-Cup" >BC</a><br/>
              <input name="nestStages" type="checkbox" value="C" checked="checked"/><a data-toggle="tooltip" class="text-success" title= "Cup" >C</a><br/>
              <input name="nestStages" type="checkbox" value="LIN" checked="checked"/><a data-toggle="tooltip" class="text-success" title=  "Lining" >LIN</a><br/>
              <input name="nestStages" type="checkbox" value="E" checked="checked"/><a data-toggle="tooltip" class="text-success" title=  "Eggs" >E</a><br/>
              <input name="nestStages" type="checkbox" value="WE" checked="checked"/><a data-toggle="tooltip" class="text-success" title=  "Warm eggs" >WE</a><br/>
              <input name="nestStages" type="checkbox" value="Y" checked="checked"/><a data-toggle="tooltip" class="text-success" title=  "Young" >Y</a><br/>
              <input name="nestStages" type="checkbox" value="NOTA"/><a data-toggle="tooltip" class="text-success" title=  "Not Active" >NOTA</a><br/>
              <input name="nestStages" type="checkbox" value="WSP" checked="checked"/><a data-toggle="tooltip" class="text-success" title=  "Wasp nest" >WSP</a> <br/> </div>'),
			  
		#hatching estimation
		div(class = "span3 control-group success",
			selectInput("safeHatchCheck", 
				label = HTML('<a data-toggle="tooltip" class="label label-info" title=" How many days in advance to check for hatching. 0 selects the predicted hatching date" > Hatch check: </a>'), 
				choices = 0:-3, selected =  -3), 
				hr(),
			checkboxInput("hatchNow", 
				label = div(class = "control-group success", HTML('<a data-toggle="tooltip" class="label label-info" title="Emphasise boxes where hatching is imminent">Hatching NOW:</a>')), 
				value = TRUE)), 
		
		#young age
			div(class="span3 control-group success", radioButtons("youngAgeYN", 
			label = HTML('<a data-toggle="tooltip" class="label label-info" title=  "Check  SELECT to select nests with particular young ages." >Young age:</a>'),
			choices = c("ALL", "SELECT") , selected = "ALL" ), 
	
	conditionalPanel(condition = "input.youngAgeYN == 'SELECT'",		
		selectInput("youngAge", 
			label = HTML('<a data-toggle="tooltip" class="label label-info" title="Select particular young ages <hr> HOLD CTR or SHIFT TO SELECT MULTIPLE VALUES!">Age on map:</a>'), 
				choices = 1:25, selected = 14, multiple =  TRUE) ) ), 
				
		# parents
		div(class="span1 control-group success", radioButtons("parents", 
			label = HTML('<a data-toggle="tooltip" class="label label-info" title=  "Show caught parents on the curent map." >Parents:</a>'),
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
						
		) 
	
	# Nest history end  <<<<<<<<<<<<<<
	
	
	
	
	

) # tool right bar end <<<<<<<<<

)))














 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 