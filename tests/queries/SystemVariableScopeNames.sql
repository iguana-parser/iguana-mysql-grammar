SELECT @@global.select, @@global._utf8mb4, @@session.123;
SELECT @@global . select.x, @@global .select .x;
SELECT @@global.'ordinary'.x, @@global.'glo\bal'.x;
SET @@global.select=1, @@global._utf8mb4=2, @@global.123=3;
