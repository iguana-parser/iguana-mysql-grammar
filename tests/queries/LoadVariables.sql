LOAD DATA INFILE 'input' INTO TABLE t (@v,@v.name,@123,@select);
LOAD DATA INFILE 'input' INTO TABLE t (@'v',@"w",@`x`);
LOAD DATA INFILE 'input' INTO TABLE t (@ v,a,@ 'w',@ `x`);
LOAD XML INFILE 'input' INTO TABLE t (@v,a,@w.name);
