CREATE USER 'u'@'localhost' IDENTIFIED BY 'dummy';
ALTER USER 'u'@'localhost' IDENTIFIED BY RANDOM PASSWORD RETAIN CURRENT PASSWORD;
ALTER USER 'u'@'localhost' ACCOUNT LOCK;
RENAME USER 'u'@'localhost' TO 'v'@'localhost';
SET PASSWORD FOR 'v'@'localhost' = 'dummy';
DROP USER IF EXISTS 'v'@'localhost';
