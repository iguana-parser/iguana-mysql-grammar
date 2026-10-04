explain
  select * from t1 where a in
    (select a from t1 union select a from t1 order by (select a))
  union select * from t1 order by (select a);
