
{  # runApp ----
   westerholz()
   require(shiny); require(bib)
   shiny::runApp('/home/valcu/M/SOFTWARE/R/PACKAGES/bib/inst/UI/')
   runApp('~/git/bib/inst/UI/')
   shiny::runApp('/home/mihai/gitHub/bib/inst/UI/')
   
   
   
}

{# content of input list as used by shiny ----

input = list(
	transp = 0.5,
	textCex = 0.8 ,
	parents = "NO",
	tools = "MAPPING",
	NestIdEntry = NA,
	nestStages = stagesInfo$nest_stage,
	mapType = "activeMap",
	phenoType = "firstEgg",
	NestId = 1,
	hatchNow = TRUE,
	youngAge = 14,
	youngAgeYN = "ALL", 
	boxCex = 2,
	safeHatchCheck = "-3",
	date = Sys.Date() )

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
d = Q(2014,  'SELECT distinct box from NESTS where nest_stage in ("R", "B", "BC", "C", "LIN", "E", "WE") ')
set.seed(1973)
x = sample(d$box, 40)
# replace x[1] with box 198 ( the 1st egg)
x[1] = 198

p = c(198, 67, 137, 186, 223, 22, 161, 10, 256, 214, 128, 251, 204, 
	263, 138, 17, 269, 48, 262, 147, 178, 271, 217, 63, 218, 247, 
	64, 108, 121, 36)
s = c(28, 167, 244, 29, 261, 72, 177, 37, 68, 216)



s = function(input) {
	p = c(10, 17, 22, 36, 48, 63, 64, 67, 108, 121, 128, 137, 138, 147, 161, 178, 186, 198, 204, 214, 217, 218, 223, 247, 251, 256, 262, 263, 269, 271)
	s = c(28, 29, 37, 68, 72, 167, 177, 216, 244, 261)

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
	
	# decisions (2014-Apr-02 21:24:18, in work)
	# d[which(d$type == 's' & d$daysSinceLastCol == 0), ]	
	d[which(d$box == 198), 'col']  = 'blue'
	d[-which(d$box == 198), 'col'] = 'red'	
	
	d[which(d$box == 198), 'n'] = NA
	d[-which(d$box == 198), 'n'] = 1

	out = list( box = d$box, col = d$col, text = d$n )
	
	return(out)
	
	}
	 
	 
	 uef(s, 2, 2014) 
	 
	 
	 
 
 ##### 2014-Apr-02 16:06:20 
 select d.box, d.type, d.date_ as refDate, lastColDate, 
DATEDIFF(d.date_,lastColDate) daysSinceLastCol

from 
-- 
	(SELECT  box, '2014-04-01' date_,  'p' type from NESTS where box in ( 198,67,137,186,223,22,161,10,256,214,128,251,204,263,138,17,269,48,262,147,178,271,217,63,218,247,64,108,121,36 ) UNION
				   SELECT  box, '2014-04-02' date_, 's' type from NESTS where box in ( 28,167,244,29,261,72,177,37,68,216 ) ) d
--

left join 
( select box, max(date_time) as lastColDate from NESTS where collect_eggs = 1 group by box ) z
ON d.box = z.box
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

}












