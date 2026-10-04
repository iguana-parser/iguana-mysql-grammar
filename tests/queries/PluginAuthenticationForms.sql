CREATE USER 'example' IDENTIFIED WITH caching_sha2_password AS 'example-authentication-string';
CREATE USER 'example' IDENTIFIED WITH caching_sha2_password BY RANDOM PASSWORD;
ALTER USER 'example' IDENTIFIED WITH caching_sha2_password AS 'example-authentication-string' RETAIN CURRENT PASSWORD;
ALTER USER 'example' IDENTIFIED WITH caching_sha2_password BY RANDOM PASSWORD;
