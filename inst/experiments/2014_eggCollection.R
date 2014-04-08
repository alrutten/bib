	require(bib)

	# random sampling of 40 nests (30 + 10)
	d = bib::Q(year = 2014, nestDataQuery(Sys.Date() )   )	
	d = d[d$nest_stage%in% c("B", "BC", "C", "LIN", "E", "WE") , ]

	set.seed(1973)
	x = sample(d$box, 46) 
	x[x == 198] # ok
	# edit(x)


	s = function (input) {
	  x = c(10, 17, 21, 26, 29, 32, 36, 38, 50, 63, 64, 67, 68, 
	        72, 84, 85, 109, 117, 121, 122, 123, 125, 131, 137, 138, 
	        140, 152, 161, 167, 177, 178, 179, 180, 183, 198, 200, 214, 
	        218, 219, 225, 235, 249, 256, 261, 263, 269)
	  
	  sqlf = paste("SELECT distinct box,", shQuote(input$date, 
	                                               type = "sh"), "refDate  from NESTS where box in (", paste(x, collapse = ","), ")")
	  
	  d = Q(2014, paste("select d.box, d.refDate, z.lastColDate, a.firstColDate,
	                    DATEDIFF(d.refDate,z.lastColDate) daysSinceLastCol,
	                    DATEDIFF(d.refDate,a.firstColDate) daysSinceFirstCol,
	                    e.maxClutch
	                    
	                    from (", 
	                    sqlf, ") d LEFT JOIN
	                    (select box, max(date_time) as lastColDate from NESTS where collect_eggs = 1 group by box ) z ON d.box = z.box
	                    LEFT JOIN
	                    (select box, min(date_time) as firstColDate from NESTS where collect_eggs = 1 group by box ) a ON d.box = a.box
	                    LEFT JOIN
	                    (select box, max(eggs) as maxClutch from NESTS  group by box ) e ON d.box = e.box
	                    order by -firstColDate desc, box
	                    "))
	  
	  Type = c( c(rep("p", 4), "s", rep("p", 8)),  rep("s", 3), c("p", "s"), rep( c(rep("p", each = 3), "s"),  7) )
	  
	  d$nestType = Type
	  
	  d[is.na(d$firstColDate), "nestType"] = NA
	  d[which(d$nestType == "p" & d$daysSinceFirstCol == 7), "col"] = "blue"
	  
	  d[which(d$nestType   == "p" & d$daysSinceFirstCol >= 8 & d$maxClutch < 8), "col"] = "blue"
	  d[which(d$nestType   == "s" & d$maxClutch %in% seq(1, 15, by = 2)), "col"] = "blue"
	  d[which(d$nestType   == "p" & d$daysSinceFirstCol >= 8 & d$maxClutch == 8), "col"] = "red"
	  d[which(d$nestType   == "p" & d$daysSinceFirstCol >= 8 & d$maxClutch == 8), "n"] = 9
	  d[which(d$nestType   == "s" & d$maxClutch %in% seq(2, 16,  by = 2)), "col"] = "red"
	  d[which(d$nestType   == "s" & d$maxClutch %in% seq(2, 16,  by = 2)), "n"] = 
	    d[which(d$nestType   == "s" & d$maxClutch %in% seq(2, 16, by = 2)), "maxClutch"] + 1
	  d[which(is.na(d$firstColDate)), "col"] = "red"
	  d[which(is.na(d$col)), "col"] = "grey"
	  d[which(is.na(d$firstColDate)), "n"] = 1
	  
	  d$n = sub('NA', '', paste0(d$nestType , d$n) )
	  
	  
	  
	  # require(XLConnect) ;  writeWorksheetToFile(  paste0("samplingEggs2014", make.names(as.character(Sys.time() )) ,".xlsx")  , d, sheet='Sheet1')
	  
	  out = list(box = d$box, col = d$col, text = d$n)
	  
	  L = function() {
	    legend(x = "topright", legend = c(
	      paste0("collect:", nrow(d[which(d$col == "red"), ])), 
	      paste0("mark:", nrow(d[which(d$col == "blue"), ])), 
	      paste0("idle:", nrow(d[which(d$col == "grey"), ]))), pch = 15, 
	      col = c("red", "blue", "grey"), bty = "n", title = "Egg collection:")
	  }
	  
	  out$legend = L
	  return(out)
	}
	
	# update EXPERIMENTAL table		 
	uef(s, 2, 2014) 
	
	 
  
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
