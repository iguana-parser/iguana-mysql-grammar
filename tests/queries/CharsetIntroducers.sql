SELECT _utf8mb4'hello', _latin1 'hello', _binary X'ff';
SELECT _utf8mb4/*gap*/'hello', _unknown 'alias', `_utf8mb4`, t._utf8mb4 FROM t;
