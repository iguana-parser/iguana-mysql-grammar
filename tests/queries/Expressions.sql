SELECT a+b*c, (a+b)*c, a-b-c, a<<2, a&b|c, ~a, !b FROM t;
SELECT NOT a=b AND c OR d, a BETWEEN 1 AND 2, a NOT IN (1,2) FROM t;
SELECT a LIKE (b+c) ESCAPE '!', a REGEXP 'x', a IS NOT NULL, a<=>b FROM t;
SELECT CASE WHEN a THEN b ELSE c END, CASE a WHEN 1 THEN b END FROM t;
SELECT ROW(a,b), EXISTS(SELECT 1), INTERVAL 1 DAY + d FROM t;
