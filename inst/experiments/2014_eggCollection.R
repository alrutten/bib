	require(bib)

	# random sampling of 40 nests (30 + 10)
	d = bib::Q(year = 2014, nestDataQuery(Sys.Date() )   )	
	d = d[d$nest_stage%in% c("B", "BC", "C", "LIN", "E", "WE") , ]

	set.seed(1973)
	x = sample(d$box, 46) 
	x[x == 198] # ok
	# edit(x)


	s = function(input) {
		
		x=c(10, 17, 21, 26, 29, 32, 36, 38, 50, 63, 64, 67, 68, 72, 84, 85, 109, 117, 121, 122, 123, 125, 131, 137, 138, 140, 152, 161, 
			167, 177, 178, 179, 180, 198, 200, 214, 217, 218, 219, 235, 247, 249, 256, 261, 263, 269)

		# frame
		sqlf = paste("SELECT distinct box,",  shQuote(input$date, type = 'sh') ,"refDate  from NESTS where box in (", paste(x, collapse = ","), ")")
		
		# DATA	
		d = Q(2014,  
				paste("select d.box, d.refDate, z.lastColDate, a.firstColDate,
							  DATEDIFF(d.refDate,z.lastColDate) daysSinceLastCol,
							  DATEDIFF(d.refDate,a.firstColDate) daysSinceFirstCol,
							  e.maxClutch
							  
					from (", sqlf, ") d LEFT JOIN
						(select box, max(date_time) as lastColDate from NESTS where collect_eggs = 1 group by box ) z ON d.box = z.box
						LEFT JOIN
						(select box, min(date_time) as firstColDate from NESTS where collect_eggs = 1 group by box ) a ON d.box = a.box
						LEFT JOIN
						(select box, max(eggs) as maxClutch from NESTS  group by box ) e ON d.box = e.box
					order by firstColDate desc
					"
				) )
		
		# DECISIONS
		# 1) proteomics (p)) or sperm (s)) nest
			# 1 & 2 = p nest 3 = s nest, then every fourth  = sperm nest
		d$nestType = c( c("p", "p", "s"), rep(c(rep("p", 3), "s"),  11))[-47]
		d[is.na(d$firstColDate), 'nestType'] = NA
		
		# 2) mark
		d[ which(d$nestType == 'p' && d$daysSinceFirstCol == 7),   'col'] = 'blue'
		d[ which(d$nestType == 'p' && d$daysSinceFirstCol>= 8 && d$maxClutch < 8),   'col'] = 'blue'
		
		d[ which(d$nestType == 's' && d$maxClutch %in% seq(1, 15, by = 2)    ),   'col'] = 'blue'
		
		# 3) collect
		d[ which(d$nestType == 'p' && d$daysSinceFirstCol >= 8 && d$maxClutch == 8),   'col'] = 'red'
		d[ which(d$nestType == 'p' && d$daysSinceFirstCol >= 8 && d$maxClutch == 8),   'n'] = 9
		
		d[ which(d$nestType == 's' && d$maxClutch %in% seq(2, 16, by = 2)   ),   'col'] = 'red'
		d[ which(d$nestType == 's' && d$maxClutch %in% seq(2, 16, by = 2)   ),   'n'] = d[ which(d$nestType == 's' && d$maxClutch %in% seq(2, 16, by = 2)   ),   'maxClutch'] + 1
		
		d[ which(is.na(d$firstColDate)),   'col'] = 'red'
		d[ which(is.na(d$firstColDate)),   'n'] = 1
		
		
		# DATA
		out = list( box = d$box, col = d$col, text = d$n )
		
		# LEGEND
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
		 

# update EXPERIMENTAL table		 
uef(s, 2, 2014) 
 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 