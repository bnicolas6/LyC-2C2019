
%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "y.tab.h"

typedef struct{
    
    int posicion;
    char *elemento;
}
t_info;

typedef struct s_nodo_lista{
    
    t_info info;
    struct s_nodo_lista *siguiente;
}
t_nodo_lista;

typedef struct s_nodo_pila{
    
    int posicion;
    struct s_nodo_pila *siguiente;
}
t_nodo_pila;


typedef t_nodo_lista *t_lista;
typedef t_nodo_pila *t_pila;


FILE  *yyin;
char *yyltext;
char *yytext;
char tipoActual[10]={""};
char listaVariables[10][20]={""};
int variableActual=0;


t_lista lista;
t_pila pila_IF;
t_pila pila_REPEAT;
t_pila pila_FILTER;
t_pila pila_INLIST;
char tipo_salto[10];
int posicion_polaca = 1;
int condicion_AND = 0;

/*FUNCIONES POLACA - PRINCIPALES*/

void crear_lista (t_lista *lista);
void insertar_polaca_int(t_lista *lista, int elemento);
void insertar_polaca_real(t_lista *lista, float elemento);
void insertar_polaca(t_lista *lista, char *elemento);
void insertar_espacio_polaca(t_lista *lista);
void guardar_polaca(t_lista *lista);
void agregar_salto(t_lista *lista, int posicion_desde, int posicion_hasta);
void avanzar();

/*FUNCIONES POLACAS - AUXILIARES*/

void mostrar_polaca(t_lista *lista);
void liberar_memoria(t_lista *lista);
char *integer_to_string(int integer);
char *invertir_salto(char *salto);
int decision_AND_detectada();



/*FUNCIONES PILA*/

void crear_pila(t_pila *pila);
void apilar(t_pila *pila);
int desapilar(t_pila *pila);

/*Pila - IF*/

void crear_pila_IF(t_pila *pila);
void apilar_IF (t_pila *pila);
int desapilar_IF (t_pila *pila);


/*Pila - REPEAT*/

void crear_pila_REPEAT(t_pila *pila);
void apilar_REPEAT(t_pila *pila);
int desapilar_REPEAT(t_pila *pila);

/*Pila - FILTER*/

void crear_pila_FILTER(t_pila *pila);
void apilar_FILTER(t_pila *pila);
int desapilar_FILTER(t_pila *pila);

/*Pila - INLIST*/

void crear_pila_INLIST(t_pila *pila);
void apilar_INLIST(t_pila *pila);
int desapilar_INLIST(t_pila *pila);

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

start : declaracion programa { guardar_polaca(&lista); liberar_memoria(&lista); };

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
asignacion :   ID  OP_ASIG { insertar_polaca(&lista, $1);  } expresion PUNTO_COMA { insertar_polaca(&lista, "="); }
             | ID  OP_ASIG { insertar_polaca(&lista, $1); } CTE_STRING PUNTO_COMA { insertar_polaca(&lista, "="); }
             ;


ciclo : REPEAT {apilar_REPEAT(&pila_REPEAT); } 
        LLAVE_A lista_sentencia LLAVE_C UNTIL PAR_A lista_condicion PAR_C PUNTO_COMA {
                                                                                        insertar_polaca(&lista, "BI");
                                                                                        insertar_polaca_int(&lista, desapilar_REPEAT(&pila_REPEAT));
                                                                                        agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                                        if(decision_AND_detectada() == 1){
                                                                                          agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                                          condicion_AND = 0;
                                                                                        }
                                                                                     };


decision :   IF PAR_A lista_condicion PAR_C LLAVE_A lista_sentencia LLAVE_C {
                                                                              agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                              if(decision_AND_detectada() == 1){
                                                                                agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                                condicion_AND = 0;
                                                                              } 
                                                                            }
           | IF PAR_A lista_condicion PAR_C LLAVE_A lista_sentencia LLAVE_C ELSE  { 
                                                                                    insertar_polaca(&lista, "BI");
                                                                                    agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca+1);
                                                                                    if(decision_AND_detectada() == 1){
                                                                                      agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca+1);
                                                                                      condicion_AND = 0;
                                                                                    }
                                                                                    apilar_IF(&pila_IF);
                                                                                    insertar_espacio_polaca(&lista);
                                                                                    avanzar();
                                                                                  } 
             LLAVE_A lista_sentencia LLAVE_C { agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca); }
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


lista_condicion :   condicion { 
                                insertar_polaca(&lista, "CMP");
                                insertar_polaca(&lista, tipo_salto);
                                apilar_IF(&pila_IF);
                                insertar_espacio_polaca(&lista);
                                avanzar();
                              }
                    OP_AND condicion { 
                                      insertar_polaca(&lista, "CMP");
                                      insertar_polaca(&lista, tipo_salto); 
                                      apilar_IF(&pila_IF);
                                      insertar_espacio_polaca(&lista); 
                                      avanzar();
                                      condicion_AND = 1;      
                                     }
                  | condicion { 
                                insertar_polaca(&lista, "CMP"); 
                                insertar_polaca(&lista, invertir_salto(tipo_salto)); 
                                apilar_IF(&pila_IF);
                                insertar_espacio_polaca(&lista); 
                                avanzar(); 
                              } 
                    OP_OR condicion {
                                      insertar_polaca(&lista, "CMP"); 
                                      insertar_polaca(&lista, tipo_salto);
                                      agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca+1);
                                      apilar_IF(&pila_IF);
                                      insertar_espacio_polaca(&lista);
                                      avanzar();
                                    }

                  | OP_NOT PAR_A condicion PAR_C  { 
                                                    insertar_polaca(&lista, "CMP"); 
                                                    insertar_polaca(&lista, invertir_salto(tipo_salto)); 
                                                    apilar_IF(&pila_IF);
                                                    insertar_espacio_polaca(&lista); 
                                                    avanzar(); 
                                                  }

                  | condicion { 
                                insertar_polaca(&lista, "CMP"); 
                                insertar_polaca(&lista, tipo_salto); 
                                apilar_IF(&pila_IF);
                                insertar_espacio_polaca(&lista); 
                                avanzar(); 
                              }
                  ;

condicion :   expresion comparacion expresion
            | inlist
            ;

//char tipo_salto[10]; strncpy(tipo_salto, "BLE", 100);
comparacion :   OP_MAYOR { strncpy(tipo_salto, "BLE", 10); }
              | OP_MENOR { strncpy(tipo_salto, "BGE", 10); }
              | OP_MAYOR_IGUAL { strncpy(tipo_salto, "BLT", 10); }
              | OP_MENOR_IGUAL { strncpy(tipo_salto, "BGT", 10); }
              | OP_IGUAL { strncpy(tipo_salto, "BNE", 10); }
              | OP_DISTINTO { strncpy(tipo_salto, "BEQ", 10); }
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
    crear_pila_IF(&pila_IF);
    crear_pila_REPEAT(&pila_REPEAT);
    crear_pila_FILTER(&pila_FILTER);
    crear_pila_INLIST(&pila_INLIST);
  }
  fclose(yyin);
  return 0;
}

int yyerror(void){
  printf("Syntax Error\n");
	system ("Pause");
	exit (1);
}

/*FUNCIONES POLACA - PRINCIPALES*/

void crear_lista(t_lista *lista){
    
    *lista = NULL;
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

void insertar_polaca(t_lista *lista, char *elemento){
    
    t_nodo_lista *nuevo = (t_nodo_lista *)malloc(sizeof (t_nodo_lista));
    if (!nuevo)
        exit(1);

    nuevo->info.elemento = (char *)malloc(strlen(elemento)*sizeof(char));
    if(!nuevo->info.elemento){
        exit(1);
    }

    //nuevo->info.elemento = elemento;
    strcpy(nuevo->info.elemento, elemento);
    nuevo->info.posicion = posicion_polaca++;

    while (*lista)
        lista = &(*lista)->siguiente;

    *lista = nuevo;
    nuevo->siguiente = NULL;
}

void guardar_polaca(t_lista *lista){
    
  FILE * file = fopen("intermedia.txt", "w");
  if(file == NULL){
      printf("(!) ERROR: No se pudo abrir el txt correspondiente al codigo intermedio\n");
  }
  else{
      while(*lista){
            fprintf(file, "%s ", (*lista)->info.elemento);
            lista = &(*lista)->siguiente;
      }
    fclose(file);
  }
}

void agregar_salto(t_lista *lista, int posicion_desde, int posicion_hasta){

    while(*lista && (*lista)->info.posicion != posicion_desde)
        lista = &(*lista)->siguiente;

    (*lista)->info.elemento = integer_to_string(posicion_hasta);
}

void avanzar(){
  
  posicion_polaca++;
}

/*FUNCIONES POLACA - AUXILIARES*/
void mostrar_polaca(t_lista *lista){
     
  while (*lista){
    printf ("Posicion:%d Elemento: %s\n", (*lista)->info.posicion, (*lista)->info.elemento);
    lista = &(*lista)->siguiente;
  }
}

void liberar_memoria(t_lista *lista){
    
    t_nodo_lista *aux;
    while(*lista){
        aux = *lista;
        *lista = aux->siguiente;
        free(aux->info.elemento);
        free(aux);
    }
}

char* integer_to_string(int x){

    char* buffer = malloc(sizeof(char) * sizeof(int) * 4 + 1);
    if (buffer)
         sprintf(buffer, "%d", x);

    return buffer;
}

char *invertir_salto(char *salto){
  
  if(strncmp("BLE", salto, 10) == 0){
    return "BGT";
  }
  if(strncmp("BGE", salto, 10) == 0){
    return "BLT";
  }
  if(strncmp("BLT", salto, 10) == 0){
    return "BGE";
  }
  if(strncmp("BGT", salto, 10) == 0){
    return "BLE";
  }
  if(strncmp("BNE", salto, 10) == 0){
    return "BEQ";
  }
  if(strncmp("BEQ", salto, 10) == 0){
    return "BNE";
  }
}

int decision_AND_detectada(){
  return condicion_AND;
}

/*FUNCIONES PILA*/

void crear_pila(t_pila *pila){
	
	*pila = NULL;
}

void insertar_espacio_polaca(t_lista *lista){
  
  t_nodo_lista *nuevo_nodo_lista = (t_nodo_lista *)malloc(sizeof (t_nodo_lista));
  if(!nuevo_nodo_lista)
      exit(1);

  nuevo_nodo_lista->info.posicion = posicion_polaca;
  nuevo_nodo_lista->siguiente = NULL;

  while (*lista)
    lista = &(*lista)->siguiente;

  *lista = nuevo_nodo_lista;
}
	 
void apilar(t_pila *pila){
	
  t_nodo_pila *nuevo_nodo_pila = (t_nodo_pila *)malloc(sizeof (t_nodo_pila));
  if(!nuevo_nodo_pila)
      exit(1);

  nuevo_nodo_pila->posicion = posicion_polaca;
  nuevo_nodo_pila->siguiente = *pila;
  *pila = nuevo_nodo_pila;     
}

int desapilar(t_pila *pila){

  t_nodo_pila *nodo_aux;
  int posicion = 0;

  if (*pila == NULL)
      exit(1);

  nodo_aux = *pila;
  posicion = nodo_aux->posicion;
  *pila = nodo_aux->siguiente;
  free(nodo_aux);

  return posicion;
}

/*Pila - IF*/

void crear_pila_IF(t_pila *pila){ crear_pila(pila); }
void apilar_IF (t_pila *pila){ apilar(pila); }
int desapilar_IF (t_pila *pila){ desapilar(pila); }

/*Pila - REPEAT*/

void crear_pila_REPEAT(t_pila *pila){ crear_pila(pila); }
void apilar_REPEAT(t_pila *pila){ apilar(pila); }
int desapilar_REPEAT(t_pila *pila){ desapilar(pila); }

/*Pila - FILTER*/

void crear_pila_FILTER(t_pila *pila){ crear_pila(pila); }
void apilar_FILTER(t_pila *pila){ apilar(pila); }
int desapilar_FILTER(t_pila *pila){ desapilar(pila); }

/*Pila - INLIST*/

void crear_pila_INLIST(t_pila *pila){ crear_pila(pila); }
void apilar_INLIST(t_pila *pila){ apilar(pila); }
int desapilar_INLIST(t_pila *pila){ desapilar(pila); }