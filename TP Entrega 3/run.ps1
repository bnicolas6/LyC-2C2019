flex .\Lexico.l
bison -dyv .\Sintactico.y
gcc .\lex.yy.c .\y.tab.c -o Tercera.exe
.\Tercera.exe .\Prueba.txt

del .\lex.yy.c
del .\y.output
del .\y.tab.c
del .\y.tab.h
#del .\ejecutable.exe