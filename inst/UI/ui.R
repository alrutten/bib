 
require(bib)

shinyUI(pageWithSidebar(

  headerPanel = headerPanel(
	HTML( paste('<h6>WESTERHOLZ field work [', format(Sys.Date(), "%d-%b-%Y"), '</strong>]</h6>') )

  ), 
  		
  mainPanel = mainPanel(
    # js scripts	
	HTML("
		<script src='http://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.0/jquery.js'></script>
		<script src='http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/js/bootstrap-tooltip.min.js'></script> 

		<script type='text/javascript'>$(document).ready(function () {$('a').tooltip({'selector': '','placement': 'top', 'html': 'true'});});</script>
		"),
  
   
	# messages
	 HTML('<span class="label label-info">MESSAGES</span>' ),
	htmlOutput("messages"),
	
	# bugs 
	HTML('<span class="label label-warning">BUGS</span>' ),
	HTML('<div id="bugs" class = "table table-striped table-condensed shiny-html-output"> </div>'),
	HTML('<span class="label label-important">WARNINGS</span>' ),
	HTML('<div id="warnings" class = "table table-striped table-condensed shiny-html-output"> </div>'),
	
	# plot
	div(class="span12", plotOutput("PLOT"))
  ), 
 
 
 
 sidebarPanel = sidebarPanel(
	
	# LINKS/HELP/...
	div(class="row", p(" "),
	div(class="span1", icon("book")),
	div(HTML( 	   
		paste("<ul", 
		 paste('class="nav nav-pills"><li class="active"><a href=', links("man"), 'target="_blank">Manual </a> </li>'),
		 paste('<li class="active"><a href=', links("journal"), 'target="_blank"> Journal </a></li>'), 
		 paste('<li class="active"> <a data-toggle="modal" href= "#dataEntry" >Data entry</a></li>'), 
		paste('<li class="active"><a href= "http://scicomp.orn.mpg.de:3838/shiny-server/SNB/" target="_blank"> snb </a></li>'), 
		  "</ul>")
		))
	),
   
   #help popup
	includeHTML(system.file('HTML', 'data_entry_help.html', package = 'bib')),
   
   hr(),
   
   # TOOLS
   div(class="row", p(" "), div(class="span1", icon("flag")) ,
   	
	div(class="span3  control-group success", radioButtons("tools", 
			label = HTML('<a data-toggle="tooltip" class="label label-success" title=  "Settings (e.g. year) apply to both Nest history and Mapping" >TOOLS:</a>'),
			choices = c("PHENOLOGY", "NEST HISTORY", "MAPPING", "FORECASTING") , selected = "MAPPING" )), 
	
	# PHENOLOGY
	conditionalPanel(condition = "input.tools == 'PHENOLOGY'",
				
		selectInput("phenoType", label = HTML('<a class="label label-info" ">Map type:</a>'), 
			list('firstEgg' = 'firstEgg', 'hatchDate'= 'hatchDate' , 'fledgeDate'= 'fledgeDate'), "firstEgg")
	
		) , 	
		
	# Nest history
	conditionalPanel(condition = "input.tools == 'NEST HISTORY'",
				
		div(class="span6", sliderInput("NestId", 
						label = div(HTML('<a data-toggle="tooltip" class="label label" title="Press play or use the slider to choose a box ">Box: </a>')),
						min = 1, max = 277, value = 1, step = 1, ticks = FALSE,
						animate  =  animationOptions(interval = 1300, loop = FALSE, 
						playButton = div(HTML('<button class="btn btn-mini btn-primary" type="button">Play</button>')), 
						pauseButton = div(HTML('<button class="btn btn-mini btn-danger" type="button">Stop</button>')))) ), 
						
		numericInput("NestIdEntry", HTML('<a data-toggle="tooltip" class = "label label" title = "Type a box number here. Delete entry here to activate back the slider" >Type Box: </a>'), NULL)
						
		) , 
		
	# Mapping	
	conditionalPanel(condition = "input.tools == 'MAPPING'",
		selectInput("mapType", label = HTML('<a class="label label-info" ">Map type:</a>'), list('active' = 'activeMap', 'base'= 'baseMap'), "activeMap") )
	
	
   ),

   tags$style(type='text/css', "#NestIdEntry { width: 30px; height: 10px; color: black}"),
   tags$style(type='text/css', "#tools { font-size: 11pt}"),
   tags$style(type='text/css', "#mapType { width: 75px; }"),
   tags$style(type='text/css', "#phenoType { width: 75px; }"),
	hr(),

  
  # date
	div(class="row", p(" "),
		div(class="span1", icon("pencil")),
		div(class="span2 control-group success",selectInput("month", 
			label = HTML('<a data-toggle="tooltip" class="label label-info" title="Reference month.">Month:</a>'), 
			choices = 3:7, 
			selected = focusMonth()   )), 
		
		div(class="span2 control-group success",selectInput("day", 
			label = HTML('<a data-toggle="tooltip" class="label label-info" title="Reference day.">Day:</a>'), 
			choices = 1:31, 
			selected = focusDay()  ) ), 
		
		
		div(class="span2 control-group success",selectInput ("year", 
			label = HTML('<a href="#" data-toggle="tooltip" class="label label-info" title="Reference year.">Year: </a>'), 
			choices = 2007:format(Sys.Date(), format = "%Y"), 
			selected = focusYear()  ) )
		),
	
	tags$style(type='text/css', "#month { width: 55px; color: black}"),
	tags$style(type='text/css', "#day { width: 55px; ; color: red }"),
	tags$style(type='text/css', "#year { width: 70px; }"),
	
	hr(),
	
	# DATA settings
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
				
			
	),
	
	tags$style(type='text/css', "#nestStages { width: 150px;}"),
	tags$style(type='text/css', "#safeHatchCheck { width: 55px;}"),
	tags$style(type='text/css', "#CI_hatchEst { width: 55px;}"),
	tags$style(type='text/css', "#youngAge   { width: 55px; height: 150px} "),

		hr(),
	
	# MAP settings
	# text & box size
	div(class="row", p(" ") , div(class="span1", icon("wrench")),
		div(class="span5", sliderInput("textCex", 
						label = div(HTML('<a data-toggle="tooltip" class="label label" title="Size of the text on screen map, it will also affect the pdf maps.">Text size: </a>')), 
						min = 0.5, max = 1.5, value = 0.8, step = 0.05) ), 
		div(class="span5", sliderInput("boxCex", 
						label = div(HTML('<a data-toggle="tooltip" class="label label"  title="Size of the box symbols on screen map, it will also affect the pdf maps.">Box size: </a>')), 
						min = 0.5, max = 3, value = 2, step = 0.25) ) ),
						
	div(class="row", p(" ") , div(class="span1", icon("wrench")),
		div(class="span5", sliderInput("transp", 
						label = div(HTML('<a data-toggle="tooltip" class="label label" title="box transparency.">Transparency: </a>')), 
						min = 0, max = .95, value = 0.5, step = 0.05) ) ), 

						
						
						
						
	
	hr(),
	
	# downloads
	div(class="row", p(" "), div(class="span1", icon("print")),
	div(class="span1", downloadButton('pdf', HTML('<button class="btn btn-large btn-primary" type="button"> PDF </button>') ) ) ),
	 
	# footnote
	hr(),
	div(class="row", p(" "), div(class="span1", icon("question-sign")),
		div(class="span2", HTML( '<p><a <span class="badge"> Questions&rarr; valcu@orn.mpg.de </span> </a></p>')) ) ,
	
	div(class="row", p(" "), div(class="span1", icon("globe")), 
	 div(class="span10",  HTML(paste('<p><small>', strsplit(R.version$version.string, "\\(")[[1]][1], '& shiny', packageVersion('shiny')) )  )
	 )
	   

  
)
))


























