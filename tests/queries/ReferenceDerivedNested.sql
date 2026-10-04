select t1.a,t4.y from t1,(select t2.a as y from t2,(select t3.b from t3 where t3.a>3) as t5  where t2.b=t5.b) as t4  where t1.a = t4.y;
