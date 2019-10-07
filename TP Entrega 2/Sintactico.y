
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

typedef struct{
    
    int posicion_desde;
    int posicion_hasta;
}
t_info_posicion;

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

typedef struct s_nodo_pila_posicion{
    
    t_info_posicion posiciones;
    struct s_nodo_pila_posicion *siguiente;
}
t_nodo_pila_posicion;


typedef t_nodo_lista *t_lista;
typedef t_nodo_pila *t_pila;
typedef t_nodo_pila_posicion *t_pila_posicion;


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
t_pila pila_FILTER_2;
t_pila_posicion pila_FILTER_3;
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


//////////////////////////////////////////////////*NUEVAS FUNCIONES*///////////////////////////////////////////////////////////////
void reemplazar_elemento_polaca(t_lista *lista, char *elemento, int posicion_desde);
void vaciar_pila(t_lista *lista, t_pila *pila);
char *get_numero_variable_auxiliar(char *string, int entero);

int inicio_filter = 0;
int fin_filter = 0; //CREO QUE NO SE USA, REVISAR
int filter_numero_variable_aux = 0;
int contar_expresion = 0;

t_lista lista_aux;


int posicion_inicial_expresion = 0;
int posicion_final_expresion = 0;


void reubicar_elementos_polaca(t_lista *lista, int posicion_desde, int posicion_hasta);
void unir_listas(t_lista *lista_1, t_lista *lista_2, int pos_inicial, int pos_hasta);


void crear_pila_FILTER_posicion(t_pila_posicion *pila);
void apilar_posicion(t_pila_posicion *pila, int posicion_desde, int posicion_hasta);
t_info_posicion desapilar_posicion(t_pila_posicion *pila);

t_info_posicion posicion_pila;

void copiar_rango_polaca(t_lista *lista_1, t_lista *lista_2, int pos_inicial);

void insertar_copia(t_lista *lista_1, t_lista *lista_2);

int posicion_auxiliar = 0;
int cantidad_copiada = 0;

void insertar_saltos(t_lista *lista, int pos_desde);
//////////////////////////////////////////////////*NUEVAS FUNCIONES*///////////////////////////////////////////////////////////////

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
          | filter { insertar_polaca(&lista, get_numero_variable_auxiliar("aux_", filter_numero_variable_aux)); }
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
asignacion :   ID  OP_ASIG { posicion_inicial_expresion = posicion_polaca; } expresion PUNTO_COMA { insertar_polaca(&lista, $1); insertar_polaca(&lista, "="); }
             | ID  OP_ASIG CTE_STRING PUNTO_COMA { insertar_polaca(&lista, $1); insertar_polaca(&lista, "="); }
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

escritura :   OP_ESC ID PUNTO_COMA { insertar_polaca(&lista, "PRINT"); insertar_polaca(&lista, yylval.strVal); }
            | OP_ESC CTE_INT PUNTO_COMA { insertar_polaca(&lista, "PRINT"); insertar_polaca_int(&lista, $2); }
            | OP_ESC CTE_REAL PUNTO_COMA { insertar_polaca(&lista, "PRINT"); insertar_polaca_real(&lista, $2); }
            | OP_ESC CTE_STRING PUNTO_COMA { insertar_polaca(&lista, "PRINT"); insertar_polaca(&lista, $2); }
            ;


lectura : OP_LEC ID PUNTO_COMA ; 


//GUARDAR POSICION inicial y Final en una estructura de datos por ej { pos_ini; pos_fin } para luego apilarlo (para evitar problemas en los anidamientos)
filter : FILTER PAR_A { 
                                     
                        posicion_final_expresion = posicion_polaca-1;
                        apilar_posicion(&pila_FILTER_3, posicion_inicial_expresion, posicion_final_expresion);

                      } filter_lista_condicion {
                                                filter_numero_variable_aux++; 
                                                printf("VALOR: %d\n", filter_numero_variable_aux);
                                                insertar_polaca(&lista, get_numero_variable_auxiliar("aux_", filter_numero_variable_aux));
                                               
                                                insertar_polaca(&lista, "_");
                                                insertar_polaca(&lista, "=");
                                                insertar_polaca(&lista, "BI");
                                                apilar_FILTER(&pila_FILTER_2);
                                                insertar_espacio_polaca(&lista); 
                                                avanzar();
                                               } 

SEPARADOR COR_A filter_lista_variable COR_C PAR_C {
                                                     insertar_polaca(&lista, get_numero_variable_auxiliar("aux_", filter_numero_variable_aux));
                                                     insertar_polaca(&lista, "0");
                                                     insertar_polaca(&lista, "=");
                                                     vaciar_pila(&lista, &pila_FILTER_2);
                                                     posicion_pila = desapilar_posicion(&pila_FILTER_3);
                                                     reubicar_elementos_polaca(&lista, posicion_pila.posicion_desde, posicion_pila.posicion_hasta+1);
                                                  }

filter_lista_condicion :  filter_condicion {
                                              insertar_polaca(&lista, "CMP");
                                              insertar_polaca(&lista, tipo_salto);
                                              apilar_FILTER(&pila_FILTER);
                                              insertar_espacio_polaca(&lista);
                                              avanzar();
                                           } 
                          OP_AND filter_condicion {
                                                    insertar_polaca(&lista, "CMP");
                                                    insertar_polaca(&lista, tipo_salto); 
                                                    apilar_FILTER(&pila_FILTER);
                                                    insertar_espacio_polaca(&lista); 
                                                    avanzar();
                                                    condicion_AND = 1;
                                                  }
                        | filter_condicion {
                                            insertar_polaca(&lista, "CMP"); 
                                            insertar_polaca(&lista, invertir_salto(tipo_salto)); 
                                            apilar_FILTER(&pila_FILTER);
                                            insertar_espacio_polaca(&lista); 
                                            avanzar();
                                           } 
                          OP_OR filter_condicion{
                                                  insertar_polaca(&lista, "CMP"); 
                                                  insertar_polaca(&lista, tipo_salto);
                                                  agregar_salto(&lista, desapilar_FILTER(&pila_FILTER), posicion_polaca+1);
                                                  apilar_FILTER(&pila_FILTER);
                                                  insertar_espacio_polaca(&lista);
                                                  avanzar();
                                                }
                        | OP_NOT PAR_A filter_condicion PAR_C {
                                                                insertar_polaca(&lista, "CMP"); 
                                                                insertar_polaca(&lista, invertir_salto(tipo_salto)); 
                                                                apilar_FILTER(&pila_FILTER);
                                                                insertar_espacio_polaca(&lista); 
                                                                avanzar(); 
                                                              }
                        | filter_condicion {
                                             insertar_polaca(&lista, "CMP"); 
                                             insertar_polaca(&lista, tipo_salto); 
                                             apilar_FILTER(&pila_FILTER);
                                             insertar_espacio_polaca(&lista); 
                                             avanzar();
                                           }
                        ;


filter_condicion :     GUION_BAJO { insertar_polaca(&lista, "_"); }comparacion expresion
                    |  { posicion_inicial_expresion = posicion_polaca; } expresion comparacion GUION_BAJO { insertar_polaca(&lista, "_"); }
                    ;

filter_lista_variable :   filter_lista_variable SEPARADOR ID {
                                                              filter_validarTipoVariable(yylval.strVal);
                                                              posicion_auxiliar = posicion_polaca;
                                                              insertar_copia(&lista, &lista_aux);
                                                              reemplazar_elemento_polaca(&lista, yylval.strVal, posicion_auxiliar);
                                                              insertar_saltos(&lista, posicion_auxiliar);
                                                              apilar_FILTER(&pila_FILTER_2);
                                                              insertar_espacio_polaca(&lista); 
                                                              avanzar();
                                                              mostrar_polaca(&lista);
                                                             } 
                        | ID {   

                                filter_validarTipoVariable(yylval.strVal);                     
                                
                                agregar_salto(&lista, desapilar_FILTER(&pila_FILTER), posicion_polaca);
                                if(decision_AND_detectada() == 1){
                                  agregar_salto(&lista, desapilar_FILTER(&pila_FILTER), posicion_polaca);
                                  condicion_AND = 0;
                                }  
                                copiar_rango_polaca(&lista, &lista_aux, posicion_final_expresion+1); //COPIAR PARTE DE LA POLACA
                                reemplazar_elemento_polaca(&lista, yylval.strVal, posicion_final_expresion+1); 
                             }

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

condicion :   { posicion_inicial_expresion = posicion_polaca; } expresion comparacion expresion
            | inlist
            ;

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
    crear_lista(&lista_aux);
    crear_pila_IF(&pila_IF);
    crear_pila_REPEAT(&pila_REPEAT);
    crear_pila_FILTER(&pila_FILTER);
    crear_pila_FILTER(&pila_FILTER_2);
    crear_pila_FILTER_posicion(&pila_FILTER_3);
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
         sprintf(buffer, "POS_%d", x);

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
  nuevo_nodo_lista->info.elemento = (char *)malloc(5*sizeof(char));
  strcpy(nuevo_nodo_lista->info.elemento, " ");
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













void reemplazar_elemento_polaca(t_lista *lista, char *elemento, int posicion_desde){
  while(*lista && (*lista)->info.posicion != posicion_desde){
    lista = &(*lista)->siguiente;
  }

  while(*lista){
    if((*lista)->info.elemento && strncmp((*lista)->info.elemento, "_", 100) == 0){

      char *aux = (char *)malloc(strlen(elemento)*sizeof(char)+1);
      strcpy(aux, elemento);
      (*lista)->info.elemento = (char *)realloc(aux, strlen(aux)*sizeof(char)+1);
    }
    lista = &(*lista)->siguiente;
  }
}

void vaciar_pila(t_lista *lista, t_pila *pila){ //CAMBIAR NOMBRE, NO SOLO VACIA LA PILA
    while(*pila){
      agregar_salto(lista, desapilar_IF(pila), posicion_polaca);
    }
}

char *get_numero_variable_auxiliar(char *auxiliar, int entero){ //CREA UN STRING CONCATENANDO UN STRING CON UN INT

  char *destino = (char *)malloc(100*sizeof(char));
  sprintf(destino, "%s%d", auxiliar, entero);
  return destino;
}

void reubicar_elementos_polaca(t_lista *lista, int posicion_desde, int posicion_hasta){ //MUEVE, ELEMENTOS DE UN RANGO (DESDE-HASTA) AL FINAL DE LA MISMA LISTA

  t_lista aux1 = NULL;
  t_nodo_lista *aux2 = NULL;

  while(*lista && (*lista)->info.posicion != posicion_desde)
    lista = &(*lista)->siguiente;

  while(*lista && (*lista)->info.posicion != posicion_hasta){
    insertar_polaca(&aux1, (*lista)->info.elemento);
    aux2 = *lista;
    *lista = (*lista)->siguiente;
    free(aux2);
  }

  unir_listas(lista, &aux1, posicion_desde, posicion_hasta);
}

void unir_listas(t_lista *lista_1, t_lista *lista_2, int pos_inicial, int pos_hasta){ 
  
  t_nodo_lista *aux2 = NULL;
  posicion_polaca = pos_inicial;

  while(*lista_1){
    (*lista_1)->info.posicion =  posicion_polaca++;
    if((*lista_1)->info.elemento && strstr((*lista_1)->info.elemento, "POS")){
      (*lista_1)->info.elemento = ((*lista_1)->info.elemento+4);
      (*lista_1)->info.elemento = integer_to_string(atoi((*lista_1)->info.elemento) - (pos_hasta - pos_inicial));
    }
    lista_1 = &(*lista_1)->siguiente;
  }

  while(*lista_2){
    insertar_polaca(lista_1, (*lista_2)->info.elemento);
    aux2 = *lista_2;
    *lista_2 = (*lista_2)->siguiente;
    free(aux2);
  }
}

void crear_pila_FILTER_posicion(t_pila_posicion *pila){
  
  *pila = NULL;
}

void apilar_posicion(t_pila_posicion *pila, int posicion_desde, int posicion_hasta){
  
  t_nodo_pila_posicion *nuevo_nodo_pila_posicion = (t_nodo_pila_posicion *)malloc(sizeof (t_nodo_pila_posicion));
  if(!nuevo_nodo_pila_posicion)
      exit(1);

  nuevo_nodo_pila_posicion->posiciones.posicion_desde = posicion_desde;
  nuevo_nodo_pila_posicion->posiciones.posicion_hasta = posicion_hasta;
  *pila = nuevo_nodo_pila_posicion;     
}

t_info_posicion desapilar_posicion(t_pila_posicion *pila){

  t_info_posicion elemento;
  t_nodo_pila_posicion *nodo_aux;

  if (*pila == NULL)
      exit(1);

  nodo_aux = *pila;
  elemento.posicion_desde = (*pila)->posiciones.posicion_desde;
  elemento.posicion_hasta = (*pila)->posiciones.posicion_hasta;
  *pila = nodo_aux->siguiente;
  free(nodo_aux);

  return elemento;
}

void copiar_rango_polaca(t_lista *lista_1, t_lista *lista_2, int pos_inicial){

  while(*lista_1 && (*lista_1)->info.posicion != pos_inicial){
    lista_1 = &(*lista_1)->siguiente;
  }

  while(*lista_1 && (*lista_1)->siguiente){
    insertar_polaca(lista_2, (*lista_1)->info.elemento);
    posicion_polaca--;
    lista_1 = &(*lista_1)->siguiente;
  }
}

void insertar_saltos(t_lista *lista, int pos_desde){
  
  while(*lista && (*lista)->info.posicion != pos_desde){
    lista = &(*lista)->siguiente;
  }

  while(*lista){
    if((*lista)->info.elemento && strstr((*lista)->info.elemento, "POS")){
      (*lista)->info.elemento = ((*lista)->info.elemento+4);
      (*lista)->info.elemento = integer_to_string(atoi((*lista)->info.elemento) + cantidad_copiada + 1);
    }
    lista = &(*lista)->siguiente;
  }

}

void insertar_copia(t_lista *lista_1, t_lista *lista_2){
  cantidad_copiada = 0;
  while(*lista_2){
    insertar_polaca(lista_1, (*lista_2)->info.elemento);
    lista_2 = &(*lista_2)->siguiente;
    cantidad_copiada++;
  }
}




