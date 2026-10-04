SET @x=1, @@global.max_connections=200;
SET SESSION sql_mode='';
SET NAMES utf8mb4 COLLATE utf8mb4_bin;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@session.autocommit, @x:=2;
