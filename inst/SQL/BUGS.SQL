SELECT  "nest_stage SHOULD NEVER BE EMPTY!!:" BUG, group_concat(box) boxes, 
IF(author IS NULL, CONCAT_WS(",", "UNKNOWN", group_concat(author)), group_concat(author) ) "author(s)" from 

(SELECT distinct box, author from NESTS where nest_stage is NULL group by box, author
) x

UNION
	
SELECT  "author SHOULD NEVER BE EMPTY!!:" BUG, group_concat(box) boxes, 
IF(author IS NULL, CONCAT_WS(",", "UNKNOWN", group_concat(author)), group_concat(author) ) "author(s)" from 

(SELECT distinct box, author from NESTS where author is NULL group by box, author
) x


UNION
	

SELECT  "date_time SHOULD NEVER BE EMPTY!!:" BUG, group_concat(box) boxes, 
IF(author IS NULL, CONCAT_WS(",", "UNKNOWN", group_concat(author)), group_concat(author) ) "author(s)"   from 

(SELECT distinct box, author from NESTS where date_time is NULL group by box, author
) x

UNION
	

SELECT  "Clutch size is wrong:" BUG, group_concat(box) boxes, group_concat(author) "author(s)" from 
(SELECT distinct box, author from NESTS where eggs NOT BETWEEN 0 AND 19 group by box 
) x
UNION
	
SELECT  "Box does not exist:" BUG, group_concat(box) boxes, group_concat(author) "author(s)" from 
(SELECT distinct box, author from NESTS where box NOT BETWEEN 1 AND 277 and YEAR(date_time) <> 2009 group by box 
) x
UNION
	
SELECT  "Nest stage is wrong:" BUG, group_concat(box) boxes, group_concat(author) "author(s)" from 
(SELECT distinct box, author from NESTS where nest_stage NOT IN  ( "U", "LT" , "R" ,  "B"  , "BC" , "C" , "LIN"  ,  "E"  , "WE", "Y", "NOTA", "WSP") group by box 
) x
UNION
	
SELECT  "Date is wrong:" BUG, group_concat(box) boxes, group_concat(author) "author(s)" from 
(SELECT distinct box, author from NESTS where month(date_time) NOT IN (2,3,4,5,6,7,8) OR YEAR(date_time) NOT BETWEEN 2007 AND YEAR(CURDATE()) group by box 
) x
UNION
	
SELECT  "There are EGGS but  LAYING_START is missing:" BUG, group_concat(box) , group_concat(author) from 
(SELECT distinct box,author  from NESTS group by box  having count(eggs) > 0 and count(laying_start) = 0 ) x
UNION
	
SELECT  "There are CHICKS but  HATCHING_START is missing:" BUG, group_concat(box) , group_concat(author) from 
(SELECT distinct box,author  from NESTS group by box  having count(chicks) > 0 and count(hatching_start) = 0 ) x

UNION
	
SELECT  "NEST STAGE  IS E but  eggs column is empty:" BUG, group_concat(box) , group_concat(author) from 
(SELECT distinct box,author  from NESTS where  nest_stage = "E" group by box  having count(nest_stage) > 0 and count(eggs) = 0 ) x

UNION
	
SELECT  "NEST STAGE  IS E  but there are already young:" BUG, group_concat(box) , group_concat(author) from 
(SELECT distinct box,author from NESTS where  nest_stage = "E" and chicks is NOT NULL group by box  having count(nest_stage) > 0 and count(chicks) = 0 ) x

UNION
	
SELECT  "laying_START is ambiguous:" BUG, group_concat(box) , group_concat(author) from 
(SELECT distinct box,author from NESTS group by box  having sum(laying_START) > 1 ) x



