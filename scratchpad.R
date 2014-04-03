
{  # runApp 

	require(shiny); require(bib)
	options(shiny.reactlog=TRUE)  
	shiny::runApp('/home/valcu/M/SOFTWARE/R/PACKAGES/bib/inst/UI/')
	runApp('~/git/bib/inst/UI/')
	shiny::runApp('/home/mihai/gitHub/bib/inst/UI/')

}

{ # EDA egg protocol 2014
	require(bib)
	# date of 1st nest sign vs. date of 1st egg ----
	d = lapply(2007:2013, function(x) Q(x, "select S1.box, S1.dt1, S2.dt2, DATEDIFF(S2.dt2, S1.dt1) diffDate FROM 

	-- 1st date of stage > B and < E
	( SELECT min(dt1) dt1, box FROM (
	  select b.box, b.date_time dt1, nest_stage stg1
			from (select * from NESTS where date_time <  (select min(date_time) fe from NESTS where laying_START is not NULL)
				and nest_stage in ('LT', 'B', 'BC', 'C', 'R', 'LIN') ) b ) B group by box ) S1
	LEFT JOIN 
	-- 1st egg
	(select box,  date_time dt2 from NESTS where laying_START is not NULL ) S2
	ON S1.box = S2.box") )

	x = data.frame( do.call(rbind,  lapply(d, function(x) table(is.na(x$diffDate)))  ))
	x$N = apply(x, 1, sum)
	x$year = 2007:2013
	x$prop = round(x$TRUE. / x$N,2)*100

	# in pop: last date of dt1 vs 1st date of dt2 ----
	z = lapply(d, function(x)  data.frame( Min = min(x$dt2, na.rm = T), Max = max(x$dt1)  ) )
	z = data.frame( do.call(rbind, z) )
	z$dltD = difftime(z$Max, z$Min)

	### clutch disr ----
	x = dbq(q = "select count(clutch) fr, clutch from  BREEDING group by clutch")
	a = sum(x[x$clutch<=10, "fr"])
	b = sum(x$fr)
	a/b

	40*16/100















}

{ # Sampling function egg protocol 2014

# random sampling of 40 nests (30 + 10)
d = Q(year = year, nestDataQuery(Sys.Date() )   )	
d = d[d$nest_stage%in% c("B", "BC", "C", "LIN", "E", "WE") , ]

set.seed(1973)
x = sample(d$box, 40) 
x[x == 198] # 198 is in !!

edit( sort(x[1:30]) )
edit( sort(x[31:40]) )

p=c(10,17,21,36,50,64,67,68,109,117,122,125,131,137,140,152,161,167,179,180,198,200,217,218,219,235,249,256,263,269)
s=c(26,29,38,84,85,121,177,178,247,261)



s = function(input) {
	resample = FALSE
	if(resample) { 	# random sampling of 40 nests (30 + 10)
		d = bib::Q(year = year, nestDataQuery(Sys.Date() )   )	
		d = d[d$nest_stage%in% c("B", "BC", "C", "LIN", "E", "WE") , ]

		set.seed(1973)
		x = sample(d$box, 40) 
		x[x == 198] # 198 is in !!

		edit( sort(x[1:30]) ) # p vector
		edit( sort(x[31:40]) ) # s vector
		}	
	
	p=c(10,17,21,36,50,64,67,68,109,117,122,125,131,137,140,152,161,167,179,180,198,200,217,218,219,235,249,256,263,269)
	s=c(26,29,38,84,85,121,177,178,247,261)

	# frame
	sqlf = paste("SELECT  box,",  shQuote(input$date, type = 'sh') ,"date_,  'p' type from NESTS where box in (", paste(p, collapse = ","), ") UNION
				   SELECT  box,",  shQuote(input$date, type = 'sh') ,"date_, 's' type from NESTS where box in (", paste(s, collapse = ","), ")
				")
	# DATA	
	d = Q(2014,  
			paste("select d.box, d.type, d.date_ as refDate, lastColDate, DATEDIFF(d.date_,lastColDate) daysSinceLastCol
			from (", sqlf, ") d", 
				"left join 
				( select box, max(date_time) as lastColDate from NESTS where collect_eggs = 1 group by box ) z
				ON d.box = z.box"
			) )
	
	# decisions (TODO)
	d$col = 'red'
	d$n = 1
	d[which(d$box == 198), 'col']  = NA
	d[which(d$box == 198), 'n'] = NA

	out = list( box = d$box, col = d$col, text = d$n )
	
	# add legend
	L = function() {
			legend(x = legend.pos[1]-100, y = legend.pos[2] , 
			legend = c('collect', 'mark'), 
			pch = 15, col = c('red', 'blue') , 
			bty = "n", 
			title = 'Egg collection:'
			)
	}
	
	out$legend = L
	
	
	return(out)
	
	}
	 
	 
uef(s, 2, 2014) 
	 
	 
	 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

}


































