
%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

FILE  *yyin;
char *yyltext;
char *yytext;
%}


%union {
int intVal;
double realVal;
char *strVal;
}

%token OP_ASIG
%token OP_AND OP_OR OP_NOT
%token OP_MAYOR OP_MENOR OP_MAYOR_IGUAL OP_MENOR_IGUAL OP_IGUAL OP_DISTINTO
%token PAR_A PAR_C COR_A COR_C LLAVE_A LLAVE_C
%token VAR_ASIG
%token SEPARADOR PUNTO_COMA
%token OP_SUMA OP_RESTA OP_MULT OP_DIV
%token GUION_BAJO
%token VAR_INI VAR_FIN
%token OP_ESC OP_LEC
%token INT FLOAT STRING
%token FILTER
%token INLIST
%token REPEAT UNTIL
%token IF ELSE
%token ID
%token CTE_INT CTE_REAL CTE_STRING
%%

start : declaracion programa ;

declaracion : VAR_INI lista_sentencia_declaracion VAR_FIN ;

lista_sentencia_declaracion :   lista_sentencia_declaracion sentencia_declaracion
                              | sentencia_declaracion
                              ;


sentencia_declaracion : COR_A lista_tipo_dato COR_C VAR_ASIG COR_A lista_variable COR_C PUNTO_COMA ;


lista_tipo_dato :   lista_tipo_dato SEPARADOR tipo_dato
                  | tipo_dato
                  ;

tipo_dato :   INT {printf("Tipo de Dato: INT\n");}
            | FLOAT {printf("Tipo de Dato: REAL\n");}
            | STRING {printf("Tipo de Dato: STRING\n");}
            ;

lista_variable : lista_variable SEPARADOR ID {printf("ID es: %s\n",yylval.strVal);} 
                 | ID {printf("ID es: %s\n",yylval.strVal);} 
                 ;

programa : LLAVE_A lista_sentencia LLAVE_C ;

expresion :   expresion OP_SUMA termino
            | expresion OP_RESTA termino
            | termino
            ;

termino :   termino OP_MULT factor
          | termino OP_DIV factor
          | factor
          ;

factor :    ID
          | CTE_INT
          | CTE_REAL
          | filter
          | PAR_A expresion PAR_C
          ;


lista_sentencia :  lista_sentencia sentencia
                  | sentencia
                  ;


sentencia :   asignacion
            | ciclo
            | decision
            | escritura
            | lectura
            ;


asignacion :   ID OP_ASIG expresion PUNTO_COMA
             | ID OP_ASIG CTE_STRING PUNTO_COMA;


ciclo : REPEAT LLAVE_A lista_sentencia LLAVE_C UNTIL PAR_A lista_condicion PAR_C PUNTO_COMA ;


decision :   IF PAR_A lista_condicion PAR_C LLAVE_A lista_sentencia LLAVE_C
           | IF PAR_A lista_condicion PAR_A LLAVE_A lista_sentencia LLAVE_C ELSE LLAVE_A lista_sentencia LLAVE_C
           ;

escritura :   OP_ESC ID PUNTO_COMA
            | OP_ESC CTE_INT PUNTO_COMA
            | OP_ESC CTE_REAL PUNTO_COMA
            | OP_ESC CTE_STRING PUNTO_COMA
            ;


lectura : OP_LEC ID PUNTO_COMA ;




filter : FILTER PAR_A filter_lista_condicion SEPARADOR COR_A lista_variable COR_C PAR_C ;

filter_lista_condicion :  filter_condicion OP_AND filter_condicion
                        | filter_condicion OP_OR filter_condicion
                        | OP_NOT PAR_A filter_condicion PAR_C
                        | filter_condicion
                        ;


filter_condicion :    GUION_BAJO comparacion expresion
                    | expresion comparacion GUION_BAJO
                    ;


lista_condicion :   condicion OP_AND condicion
                  | condicion OP_OR condicion
                  | OP_NOT PAR_A condicion PAR_C
                  | condicion
                  ;

condicion :   expresion comparacion expresion
            | inlist
            ;


comparacion :   OP_MAYOR
              | OP_MENOR
              | OP_MAYOR_IGUAL
              | OP_MENOR_IGUAL
              | OP_IGUAL
              | OP_DISTINTO
              ;


inlist : INLIST PAR_A ID PUNTO_COMA COR_A lista_expresiones COR_C PAR_C ;

lista_expresiones :   lista_expresiones PUNTO_COMA expresion
                    | expresion
                    ;


%%
int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  guardarRenglonesEnTS();
  }
  fclose(yyin);
  return 0;
}
int yyerror(void)
     {
       printf("Syntax Error\n");
	 system ("Pause");
	 exit (1);
     }


