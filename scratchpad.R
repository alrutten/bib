

{  # runApp
westerholz()
shiny::runApp('/home/valcu/M/SOFTWARE/R/PACKAGES/bib/inst/UI/')
shiny::runApp('/home/mihai/gitHub/bib/inst/UI/')

require(shiny); require(bib)
runApp('~/git/bib/inst/UI/')

}

{ # egg protocol: 2014

 require(bib)

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


# in pop: last date of dt1 vs 1st date of dt2
z = lapply(d, function(x)  data.frame( Min = min(x$dt2, na.rm = T), Max = max(x$dt1)  ) )
z = data.frame( do.call(rbind, z) )
z$dltD = difftime(z$Max, z$Min)
}















