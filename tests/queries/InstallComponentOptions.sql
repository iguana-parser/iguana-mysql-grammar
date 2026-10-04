INSTALL COMPONENT 'file://component_test' SET component_test.limit=12+3*4;
INSTALL COMPONENT 'file://component_test' SET GLOBAL component_test.enabled=ON, PERSIST component_test.name='example';
INSTALL COMPONENT 'file://component_test' SET component_test.global=1, `global`=2;
