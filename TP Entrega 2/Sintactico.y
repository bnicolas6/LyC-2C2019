
%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"


typedef struct s_nodo
{
    char *elemento;
    struct s_nodo *siguiente;
}
t_nodo;

typedef t_nodo *t_lista;


FILE  *yyin;
char *yyltext;
char *yytext;
char tipoActual[10]={""};
char listaVariables[10][20]={""};
int variableActual=0;
t_lista lista;



void crear_lista (t_lista *lista);
void insertar_polaca_int(t_lista *lista, int elemento);
void insertar_polaca_real(t_lista *lista, float elemento);
void insertar_polaca(t_lista *lista, char *elemento);
void mostrar_polaca(t_lista *lista);
void guardar_polaca(t_lista *lista);
void liberar_memoria(t_lista *lista);

%}

%union {
int intVal;
double realVal;
char *strVal;
}

%token <strVal>ID <intVal>CTE_INT <realVal>CTE_REAL <strVal>CTE_STRING
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
%%

start : declaracion programa { guardar_polaca(&lista); };

declaracion : VAR_INI lista_sentencia_declaracion VAR_FIN ;

lista_sentencia_declaracion :   lista_sentencia_declaracion sentencia_declaracion
                              | sentencia_declaracion
                              ;


sentencia_declaracion : COR_A lista_tipo_dato COR_C VAR_ASIG COR_A lista_variable COR_C PUNTO_COMA ;


lista_tipo_dato :   lista_tipo_dato SEPARADOR tipo_dato
                  | tipo_dato
                  ;

tipo_dato :   INT
            | FLOAT
            | STRING
            ;

lista_variable : lista_variable SEPARADOR ID
                 | ID
                 ;

programa : LLAVE_A lista_sentencia LLAVE_C ;

expresion :   expresion OP_SUMA termino { insertar_polaca(&lista, "+"); }
            | expresion OP_RESTA termino { insertar_polaca(&lista, "-"); }
            | termino
            ;

termino :   termino OP_MULT factor { insertar_polaca(&lista, "*"); }
          | termino OP_DIV factor { insertar_polaca(&lista, "/"); }
          | factor 
          ;

factor :    ID { insertar_polaca(&lista, $1); }
          | CTE_INT { insertar_polaca_int(&lista, $1); }
          | CTE_REAL { insertar_polaca_real(&lista, $1); }
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
//Revisar: No funciona con CTE_STRING
asignacion :   ID  OP_ASIG { insertar_polaca(&lista, $1); } expresion PUNTO_COMA { insertar_polaca(&lista, "="); }
             | ID  OP_ASIG { insertar_polaca(&lista, $1); } CTE_STRING { insertar_polaca(&lista, $3); } PUNTO_COMA { insertar_polaca(&lista, "="); }
             ;


ciclo : REPEAT LLAVE_A lista_sentencia LLAVE_C UNTIL PAR_A lista_condicion PAR_C PUNTO_COMA ;


decision :   IF PAR_A lista_condicion PAR_C LLAVE_A lista_sentencia LLAVE_C
           | IF PAR_A lista_condicion PAR_C LLAVE_A lista_sentencia LLAVE_C ELSE LLAVE_A lista_sentencia LLAVE_C
           ;

escritura :   OP_ESC ID PUNTO_COMA
            | OP_ESC CTE_INT PUNTO_COMA
            | OP_ESC CTE_REAL PUNTO_COMA
            | OP_ESC CTE_STRING PUNTO_COMA
            ;


lectura : OP_LEC ID PUNTO_COMA ;




filter : FILTER PAR_A filter_lista_condicion SEPARADOR COR_A filter_lista_variable COR_C PAR_C

filter_lista_condicion :  filter_condicion OP_AND filter_condicion
                        | filter_condicion OP_OR filter_condicion
                        | OP_NOT PAR_A filter_condicion PAR_C
                        | filter_condicion 
                        ;


filter_condicion :    GUION_BAJO comparacion expresion
                    | expresion comparacion GUION_BAJO
                    ;

filter_lista_variable :   filter_lista_variable SEPARADOR ID {filter_validarTipoVariable(yylval.strVal); }
                        | ID {filter_validarTipoVariable(yylval.strVal); }
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
  	crear_lista(&lista);
  }
  fclose(yyin);
  return 0;
}

int yyerror(void){
  printf("Syntax Error\n");
	system ("Pause");
	exit (1);
}

void crear_lista(t_lista *lista){
    *lista = NULL;
}

void insertar_polaca(t_lista *lista, char *elemento){
    t_nodo *nuevo = (t_nodo *)malloc(sizeof (t_nodo));
    if (!nuevo)
        exit(1);

    nuevo->elemento = (char *)malloc(strlen(elemento)*sizeof(char));
    if(!nuevo->elemento){
        exit(1);
    }

    nuevo->elemento = elemento;

    while (*lista)
        lista = &(*lista)->siguiente;

    *lista = nuevo;
    nuevo->siguiente = NULL;
}

void insertar_polaca_int(t_lista *lista, int elemento){
	char *toString = (char *)malloc(sizeof(int));
	itoa(elemento, toString, 10);
	insertar_polaca(lista, toString);
}

void insertar_polaca_real(t_lista *lista, float elemento){
	char *toString = (char *)malloc(sizeof(float));
	snprintf(toString, sizeof(float), "%e%f", elemento);
	insertar_polaca(lista, toString);
	
}

void mostrar_polaca(t_lista *lista){
     while (*lista){
        printf ("%s\n", (*lista)->elemento);
        lista = &(*lista)->siguiente;
    }
}

void guardar_polaca(t_lista *lista){
    FILE * file = fopen("intermedia.txt", "w");

	if(file == NULL)
	{
    	printf("(!) ERROR: No se pudo abrir el txt correspondiente al codigo intermedio\n");
	}
	else
	{
	    while(*lista){
            fprintf(file, "%s ", (*lista)->elemento);
            lista = &(*lista)->siguiente;
	    }
		fclose(file);
	}
}

void liberar_memoria(t_lista *lista){
    t_nodo *aux;
    while(*lista){
        aux = *lista;
        *lista = aux->siguiente;
        free(aux->elemento);
        free(aux);
    }
}
