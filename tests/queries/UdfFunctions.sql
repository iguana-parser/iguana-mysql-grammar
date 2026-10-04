CREATE FUNCTION scalar_udf RETURNS STRING SONAME 'scalar_udf.so';
CREATE AGGREGATE FUNCTION aggregate_udf RETURNS REAL SONAME 'aggregate_udf.so';
DROP FUNCTION scalar_udf;
DROP FUNCTION aggregate_udf;
