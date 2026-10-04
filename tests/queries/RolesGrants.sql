CREATE ROLE 'reader';
GRANT SELECT(a), UPDATE ON db.t TO 'u'@'localhost';
GRANT SELECT ON *.* TO 'u' AS 'admin' WITH ROLE 'reader';
REVOKE SELECT ON db.t FROM 'u';
GRANT 'reader' TO 'u';
SET ROLE ALL EXCEPT 'reader';
SET DEFAULT ROLE 'reader' TO 'u';
DROP ROLE 'reader';
