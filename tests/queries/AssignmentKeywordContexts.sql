SET select.x=1, persist.x=2, default.x=3;
SET GLOBAL select.x=1;
SET @@global.select=1, @@global.select.x=2, @@global.select .x=3;
SET @@global . select.x=1, @@persist.persist .x=2;
SET @@global.global=1, @@global.default=2;
INSTALL COMPONENT 'file://c' SET select.x=1, persist.x=2, `global`=3;
