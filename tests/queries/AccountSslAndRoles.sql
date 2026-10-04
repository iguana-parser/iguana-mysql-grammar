CREATE USER 'u'@'localhost' IDENTIFIED BY 'password' DEFAULT ROLE 'reader' REQUIRE CIPHER 'cipher' AND ISSUER 'issuer' SUBJECT 'subject';
GRANT SELECT ON TABLE db.* TO 'u'@'localhost' WITH GRANT OPTION;
GRANT SELECT ON db.t TO 'u'@'localhost' AS 'grantor' WITH ROLE ALL EXCEPT 'reader';
REVOKE IF EXISTS SELECT ON db.t FROM 'u'@'localhost' IGNORE UNKNOWN USER;
