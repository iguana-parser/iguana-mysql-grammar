SELECT value MEMBER OF (json_column) FROM t;
CREATE INDEX idx ON t ((CAST(json_column->'$.items' AS UNSIGNED ARRAY)));
