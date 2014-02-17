
SELECT  "NEST_STAGE has gone down:" BUG, group_concat(box) boxes, group_concat(author)  'author(s)'  from
(SELECT distinct n.box,n.author from NESTS n, (SELECT box, min(date_time) minEgg from NESTS where nest_stage = 'E' group by box) m
	where m.box = n.box and n.date_time>m.minEgg and n.nest_stage NOT IN ('E','Y','NOTA') group by box
UNION
SELECT distinct n.box,n.author from NESTS n, (SELECT box, min(date_time) minYoung from NESTS where nest_stage = 'Y' group by box) m
where m.box = n.box and n.date_time>m.minYoung and n.nest_stage NOT IN ('Y','NOTA') group by box) x


	
	