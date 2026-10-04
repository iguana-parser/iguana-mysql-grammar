EXPLAIN FORMAT=JSON INTO @plan SELECT 1;
EXPLAIN FORMAT=`JsOn` INTO @'plan' SELECT 1;
-- MySQL's parse action skips the explicit-format guard for empty targets.
EXPLAIN INTO @'' SELECT 1;
EXPLAIN INTO @`` SELECT 1;
EXPLAIN FORMAT=TREE INTO @"" SELECT 1;
