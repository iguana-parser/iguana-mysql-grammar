-- Default MySQL quoting and numeric categories.
SELECT NULL, TRUE, FALSE, 0, 2147483648, 9223372036854775808;
SELECT 18446744073709551616, 1., .5, 1.e-2, -2.3E+4;
SELECT 'a' 'b', N'national', "double quoted", X'ff', 0xff, b'01', 0b01;
SELECT DATE '2026-01-02', TIME '12:34:56', TIMESTAMP '2026-01-02 12:34:56';
SELECT 'a\'b', 'a\\b', 'a''b';
