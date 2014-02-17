
require('RMySQL')
require('nlme')
require(effects)


con  = dbConnect(dbDriver("MySQL"), user = "guest", password = "guest", host = "scidb.orn.mpg.de", dbname = 'BTatWESTERHOLZ')

# DATA
d = mysqlQuickSQL(con, 'select year_, box, DAYOFYEAR(firstEgg)  firstEgg_DaYofYear , firstEgg, clutch, DAYOFYEAR(hatchDate) hatchDate_DaYofYear, hatchDate , laying_gap 
				FROM BREEDING WHERE year_ > 2007 and firstEgg is not NULL and clutch is not NULL')
d$firstEgg = unlist(lapply( split(d, d$year), function(x) { x$firstEgg_DaYofYear  - min(x$firstEgg_DaYofYear) } ))
d$hatchDate_Day = unlist(lapply( split(d, d$year), function(x) { x$hatchDate_DaYofYear  - min(x$firstEgg_DaYofYear) } ))

# check for outliers
plot(table(with (d, hatchDate_Day - (firstEgg+clutch) )))
d = d[which( with (d, hatchDate_Day - (firstEgg+clutch) ) > 9 & with (d, hatchDate_Day - (firstEgg+clutch) ) < 19 ), ]
plot(table(with (d, hatchDate_Day - (firstEgg+clutch) )))
				
# Plots

plot(hatchDate_Day ~ firstEgg, d)

# lm
fm = lm(hatchDate_Day ~ poly(clutch,2) + firstEgg, d, na.action = na.exclude)
summary(fm)
plot(allEffects(fm), ask = FALSE, ylab = 'Hatching date', main = '')

fm = lme( hatchDate_Day ~ poly(clutch,2) + firstEgg, random = (~firstEgg|year_)  , d, na.action = na.exclude)



# x -check
d$predHatch = predict(fm,   level = 0)

d$esthatchDate = as.POSIXct(NA)

dl = split(d, d$year)
for(i in 1:length(dl) ) 
	d[d$year_ == names(dl)[i], 'esthatchDate'] = dayofyear2date( d[d$year_ == names(dl)[i], 'predHatch']  + min( d[d$year_ == names(dl)[i], 'firstEgg_DaYofYear'] ) , names(dl)[i])
	
d$predMismatch =   difftime(d$esthatchDate, d$hatchDate, units = 'days')

table(d$predMismatch  <= 0)
xtabs( ~ I(predMismatch  <= 0) + year_, d)


d[d$predMismatch <= 0 & d$year_ == 2012, ]
d[d$box == 3 & d$year_ == 2012, ]

# save glm
hatchDateGLM = fm
save(hatchDateGLM, file = '/var/shiny-server/www/BTatWESTERHOLZ/hatchDateGLM')
 
 



















