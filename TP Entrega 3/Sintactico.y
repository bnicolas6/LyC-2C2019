
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

typedef struct s_nodo_lista_etiqueta{
    
    t_info info;
    struct s_nodo_lista_etiqueta *siguiente;
}
t_nodo_lista_etiqueta;

typedef struct s_nodo_pila{
    
    int posicion;
    struct s_nodo_pila *siguiente;
}
t_nodo_pila;

typedef struct s_nodo_pila_ASM{
    
    char *elemento;
    struct s_nodo_pila_ASM *siguiente;
}
t_nodo_pila_ASM;

typedef struct s_nodo_data{
    
    char *elemento;
    struct s_nodo_data *siguiente;
}
t_nodo_lista_data;

typedef t_nodo_lista *t_lista;
typedef t_nodo_pila *t_pila;
typedef t_nodo_pila_ASM *t_pila_ASM;
typedef t_nodo_lista_etiqueta *t_lista_etiqueta;
typedef t_nodo_lista_data *t_lista_data;


FILE  *yyin;
char *yyltext;
char *yytext;
char tipoActual[10]={""};
char listaVariables[10][20]={""};
int variableActual=0;


t_lista lista;
t_lista_etiqueta lista_etiqueta;
t_lista_data lista_data;
t_pila pila_IF;
t_pila pila_REPEAT;
t_pila pila_FILTER_1;
t_pila pila_FILTER_2;
t_pila pila_FILTER_3;
t_pila pila_INLIST;
t_pila pila_INLIST_INCOND;
t_pila_ASM pila_ASM;
char tipo_salto[10];
int posicion_polaca = 1;
int condicion_AND = 0;
int condicion_OR = 0;
int contar_variable = 0;
int contar_tipo_dato = 0;
int inicio_asignacion = 0;
int tipo_dato_asignacion;
int tipo_dato_id_asignacion;
char* id_Inlist;
int inicio_inlist = 0;
int tengo_inlist = 0;
int tengo_cond_inlist = 0;
int negacion_inlist = 0;
int inicio_repeat = 0;
int numero_variable_auxiliar = 1;
int variable_auxiliar = 0;
int auxiliar_posicion_polaca = 0;

/*VALIDACIONES*/

void ValidarVariablesEnDeclaracion();
void ValidarTipoDatoEnAsignacion(int tipoDato);

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

/*Pila - INLIST_INCOND*/

void crear_pila_INLIST_INCOND(t_pila *pila);
void apilar_INLIST_INCOND(t_pila *pila);
int desapilar_INLIST_INCOND(t_pila *pila);

/* CODIGO ASM */
void insertar_cabezera_asm(FILE **pf_asm);
void generar_asm(t_lista *lista, t_lista_etiqueta *lista_etiqueta, t_lista_data *lista_data);
void crear_pila_ASM(t_pila_ASM *pila);
void apilar_ASM(t_pila_ASM *pila, char *elemento, t_lista_data *lista_data);
char *desapilar_ASM(t_pila_ASM *pila);

char *get_nombre_asm(char *elemento);
char* generarAuxiliar(int x, char *inicial);

void crear_lista_etiqueta(t_lista_etiqueta *lista_etiqueta);
void insertar_lista_etiqueta(t_lista_etiqueta *lista_etiqueta, char* elemento, int posicion);
void guardar_etiquetas(t_lista *lista, t_lista_etiqueta *lista_etiqueta);
int existe_etiqueta(t_lista_etiqueta **lista_etiqueta, int posicion);

void crear_lista_data(t_lista_data *lista_data);
void insertar_lista_data(t_lista_data *lista_data, char* elemento);

int esOperador(char **elemento);
int esAsignacion(char **elemento);
int esComparacion(char **elemento);
int esSalto(char **elemento);
int esEtiqueta(char **elemento);
int esRead(char **elemento);
int esWrite(char **elemento);
/* FIN CODIGO ASM*/


%}

%union {
int intVal;
double realVal;
char *strVal;
}

%token <strVal>ID <intVal>CTE_INT <realVal>CTE_REAL <strVal>CTE_STRING
%right OP_ASIG
%left OP_SUMA OP_RESTA 
%left OP_MULT OP_DIV
%token OP_AND OP_OR OP_NOT
%token OP_MAYOR OP_MENOR OP_MAYOR_IGUAL OP_MENOR_IGUAL OP_IGUAL OP_DISTINTO
%token PAR_A PAR_C COR_A COR_C LLAVE_A LLAVE_C
%token VAR_ASIG
%token SEPARADOR PUNTO_COMA
%token GUION_BAJO
%token VAR_INI VAR_FIN
%token OP_ESC OP_LEC
%token INT FLOAT STRING
%token FILTER
%token INLIST
%token REPEAT UNTIL
%token IF ELSE 
%%

start : declaracion programa { guardar_polaca(&lista); guardar_etiquetas(&lista, &lista_etiqueta);  liberar_memoria(&lista); };

declaracion : VAR_INI lista_sentencia_declaracion VAR_FIN ;

lista_sentencia_declaracion :   lista_sentencia_declaracion sentencia_declaracion
                              | sentencia_declaracion
                              ;


sentencia_declaracion : COR_A lista_tipo_dato COR_C VAR_ASIG COR_A lista_variable COR_C PUNTO_COMA { ValidarVariablesEnDeclaracion(); } ;


lista_tipo_dato :   lista_tipo_dato SEPARADOR tipo_dato { contar_tipo_dato++; }
                  | tipo_dato { contar_tipo_dato++; }
                  ;

tipo_dato :   INT
            | FLOAT
            | STRING
            ;

lista_variable : lista_variable SEPARADOR ID { contar_variable++; }
                 | ID { contar_variable++; }
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

factor :    ID { insertar_polaca(&lista, $1);
                 tipo_dato_id_asignacion = getTipoDatoId($1);
                 ValidarTipoDatoEnAsignacion(tipo_dato_id_asignacion); }
          | CTE_INT { insertar_polaca_int(&lista, $1);
                      ValidarTipoDatoEnAsignacion(1); }
          | CTE_REAL { insertar_polaca_real(&lista, $1);
                       ValidarTipoDatoEnAsignacion(2); }
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

asignacion :   ID  OP_ASIG { 
                             inicio_asignacion = 1;
                             tipo_dato_asignacion = getTipoDatoId($1);              
                           } 
                             expresion PUNTO_COMA { 
                                                    insertar_polaca(&lista, $1);                                     
                                                    insertar_polaca(&lista, "=");
                                                    inicio_asignacion = 0;
                                                  }
             | ID  OP_ASIG CTE_STRING PUNTO_COMA { insertar_polaca(&lista, $3); 
                                                   insertar_polaca(&lista, $1); 
                                                   insertar_polaca(&lista, "=");
                                                   inicio_asignacion = 1;
                                                   tipo_dato_asignacion = getTipoDatoId($1);
                                                   ValidarTipoDatoEnAsignacion(3);
                                                   inicio_asignacion = 0; }
             ;


ciclo : REPEAT {apilar_REPEAT(&pila_REPEAT); inicio_repeat = 1; } 
        LLAVE_A lista_sentencia LLAVE_C UNTIL PAR_A lista_condicion PAR_C PUNTO_COMA {
                                                                                        inicio_repeat = 0;
                                                                                        if(tengo_inlist == 0)
                                                                                        {
                                                                                          insertar_polaca(&lista, "BI");
                                                                                          insertar_polaca_int(&lista, desapilar_REPEAT(&pila_REPEAT));
                                                                                          agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                                          if(decision_AND_detectada() == 1){
                                                                                            agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                                            condicion_AND = 0;
                                                                                          }
                                                                                        }
                                                                                        if(tengo_inlist == 1)
                                                                                        {
                                                                                          if(negacion_inlist == 1)
                                                                                          {
                                                                                            insertar_polaca(&lista, "BI");
                                                                                            insertar_polaca_int(&lista, desapilar_REPEAT(&pila_REPEAT));
                                                                                            while(pila_INLIST)
                                                                                            {
                                                                                              agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca);
                                                                                            }
                                                                                          }
                                                                                          else
                                                                                          {
                                                                                            insertar_polaca(&lista, "BI");
                                                                                            insertar_polaca_int(&lista, desapilar_REPEAT(&pila_REPEAT));
                                                                                            while(pila_INLIST_INCOND)
                                                                                            {
                                                                                              agregar_salto(&lista, desapilar_INLIST_INCOND(&pila_INLIST_INCOND), posicion_polaca); 
                                                                                            }
                                                                                            if(tengo_cond_inlist == 1)
                                                                                            {
                                                                                              agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      };


decision :   IF PAR_A lista_condicion PAR_C LLAVE_A lista_sentencia LLAVE_C {
																			  condicion_AND = 0;
                                                                              if(tengo_inlist == 0 || tengo_cond_inlist == 1)
                                                                              {
                                                                                agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                                if(decision_AND_detectada() == 1){
                                                                                  agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                                                  condicion_AND = 0;
                                                                                }
                                                                              }
                                                                              if(tengo_inlist == 1)
                                                                              {
                                                                                if (negacion_inlist == 1)
                                                                                {
                                                                                  while(pila_INLIST)
                                                                                  {
                                                                                    agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca);
                                                                                  }
                                                                                  negacion_inlist = 0;
                                                                                }
                                                                                else
                                                                                {
                                                                                  while(pila_INLIST_INCOND)
                                                                                  {
                                                                                    agregar_salto(&lista, desapilar_INLIST_INCOND(&pila_INLIST_INCOND), posicion_polaca);
                                                                                  } 
                                                                                }
                                                                                tengo_inlist = 0;
                                                                              }
                                                                            }
           | IF PAR_A lista_condicion PAR_C LLAVE_A lista_sentencia LLAVE_C ELSE  { 
                                                                                    if(tengo_inlist == 0)
                                                                                    {
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
                                                                                    else
                                                                                    {
                                                                                      if (negacion_inlist == 1)
                                                                                      {
                                                                                        insertar_polaca(&lista, "BI");
                                                                                        while(pila_INLIST)
                                                                                        {
                                                                                          agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                                                                        }
                                                                                        apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                                                                        insertar_espacio_polaca(&lista);
                                                                                        avanzar();
                                                                                      }
                                                                                      else
                                                                                      {
                                                                                          insertar_polaca(&lista, "BI");
                                                                                          if(tengo_cond_inlist == 1)
                                                                                          {
                                                                                            agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca+1);
                                                                                          }
                                                                                          while(pila_INLIST_INCOND)
                                                                                          {
                                                                                            agregar_salto(&lista, desapilar_INLIST_INCOND(&pila_INLIST_INCOND), posicion_polaca+1);
                                                                                          }
                                                                                          apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                                                                          insertar_espacio_polaca(&lista);
                                                                                          avanzar(); 
                                                                                      }
                                                                                    }
                                                                                  } 
             LLAVE_A lista_sentencia LLAVE_C { 
                                                if(tengo_inlist == 0)
                                                {
                                                  agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca);
                                                }
                                                else
                                                {
                                                  while(pila_INLIST_INCOND)
                                                  {
                                                    agregar_salto(&lista, desapilar_INLIST_INCOND(&pila_INLIST_INCOND), posicion_polaca);
                                                  }
                                                  if(negacion_inlist == 1)
                                                  {
                                                    negacion_inlist = 0;
                                                  }
                                                  tengo_inlist = 0;
                                                } 
                                             }
           ;

escritura :   OP_ESC ID PUNTO_COMA { insertar_polaca(&lista, $2); insertar_polaca(&lista, "WRITE"); }
            | OP_ESC CTE_INT PUNTO_COMA { insertar_polaca_int(&lista, $2); insertar_polaca(&lista, "WRITE"); }
            | OP_ESC CTE_REAL PUNTO_COMA { insertar_polaca_real(&lista, $2); insertar_polaca(&lista, "WRITE"); }
            | OP_ESC CTE_STRING PUNTO_COMA { insertar_polaca(&lista, $2); insertar_polaca(&lista, "WRITE"); }
            ;


lectura : OP_LEC ID PUNTO_COMA { insertar_polaca(&lista, $2); insertar_polaca(&lista, "READ"); } ;




filter : FILTER { 
          variable_auxiliar = numero_variable_auxiliar++;
          insertar_polaca(&lista, "BI");
          insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "BR"));
          apilar_FILTER(&pila_FILTER_2); 
        } 
        PAR_A filter_lista_condicion SEPARADOR COR_A filter_lista_variable  {
                                                                              if(tengo_inlist == 0)
                                                                              {
                                                                              	   condicion_AND = 0;
	                                                                               insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "RTA")); 
	                                                                               insertar_polaca_int(&lista, 0);
	                                                                               insertar_polaca(&lista, "=");
	                                                                               agregar_salto(&lista, desapilar_FILTER(&pila_FILTER_3), posicion_polaca);
	                                                                               if(condicion_OR == 1)
	                                                                               {
	                                                                               	 agregar_salto(&lista, desapilar_FILTER(&pila_FILTER_3), posicion_polaca);
	                                                                               	 condicion_OR = 0;
	                                                                               }
                                                                                


                                                                                insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "BR"));
                                                                                insertar_polaca(&lista, generarAuxiliar(posicion_polaca+2, "POS"));
                                                                                insertar_polaca(&lista, "=");
                                                                                insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "RTA"));                                                     
                                                                                variable_auxiliar--;
                                                                              }
                                                                              else
                                                                              {
                                                                                if (negacion_inlist == 1)
                                                                                {
                                                                                  insertar_polaca(&lista, "BI");
                                                                                  while(pila_INLIST)
                                                                                  {
                                                                                    agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                                                                  }
                                                                                  apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                                                                  insertar_espacio_polaca(&lista);
                                                                                  avanzar();
                                                                                }
                                                                                else
                                                                                {
                                                                                    insertar_polaca(&lista, "BI");
                                                                                    if(tengo_cond_inlist == 1)
                                                                                    {
                                                                                      agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca+1);
                                                                                    }
                                                                                    while(pila_INLIST_INCOND)
                                                                                    {
                                                                                      agregar_salto(&lista, desapilar_INLIST_INCOND(&pila_INLIST_INCOND), posicion_polaca+1);
                                                                                    }
                                                                                    apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                                                                    insertar_espacio_polaca(&lista);
                                                                                    avanzar(); 
                                                                                }
                                                                              }
                                                                            } 
                                                                              COR_C PAR_C

filter_lista_condicion :  filter_condicion {
                                              if(inicio_inlist == 0)
                                              {
                                                insertar_polaca(&lista, "CMP");
                                                insertar_polaca(&lista, tipo_salto);
                                                apilar_FILTER(&pila_FILTER_3);
                                                insertar_espacio_polaca(&lista);
                                                avanzar();
                                              }
                                              else
                                              {
                                                insertar_polaca(&lista, "BI");
                                                while(pila_INLIST)
                                                {
                                                  agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                                }
                                                apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                                insertar_espacio_polaca(&lista); 
                                                avanzar();
                                                inicio_inlist = 0;
                                                tengo_inlist = 1;
                                                tengo_cond_inlist = 1;
                                              }
                                           } 
                                            OP_AND filter_condicion {
                                                                      if(inicio_inlist == 0)
                                                                      {
                                                                        insertar_polaca(&lista, "CMP");
                                                                        insertar_polaca(&lista, invertir_salto(tipo_salto));
                                                                        agregar_salto(&lista, desapilar_FILTER(&pila_FILTER_3), posicion_polaca+1); 
                                                                        apilar_FILTER(&pila_FILTER_3);
                                                                        insertar_espacio_polaca(&lista); 
                                                                        avanzar();
                                                                        if (tengo_inlist)
                                                                        {
                                                                          condicion_AND = 0;
                                                                        }
                                                                        else
                                                                        {
                                                                          condicion_AND = 1;
                                                                        }  
                                                                      }
                                                                      else
                                                                      {
                                                                        insertar_polaca(&lista, "BI");
                                                                        while(pila_INLIST)
                                                                        {
                                                                          agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                                                        }
                                                                        inicio_inlist = 0;
                                                                        tengo_inlist = 1;
                                                                        if (tengo_cond_inlist == 1)
                                                                        {
                                                                          tengo_cond_inlist = 0;
                                                                        }
                                                                        else
                                                                        {
                                                                          tengo_cond_inlist = 1;
                                                                        }
                                                                        apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                                                        insertar_espacio_polaca(&lista); 
                                                                        avanzar();
                                                                      } 
                                                                    }
                        | filter_condicion 
                          {
                            if(inicio_inlist == 0)
                            {
                              condicion_OR = 1;
                              insertar_polaca(&lista, "CMP");
                              insertar_polaca(&lista, invertir_salto(tipo_salto));
                              apilar_FILTER(&pila_FILTER_3);
                              insertar_espacio_polaca(&lista);
                              avanzar();
                            }
                            else
                            {
                              insertar_polaca(&lista, "BI");
                              while(pila_INLIST)
                              {
                                agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                              }
                              apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                              insertar_espacio_polaca(&lista); 
                              avanzar();
                              inicio_inlist = 0;
                              tengo_inlist = 1;
                              tengo_cond_inlist = 1;
                            }
                          } 
                          OP_OR filter_condicion 
                          {
                            if(inicio_inlist == 0)
                            {
                              insertar_polaca(&lista, "CMP");
                              insertar_polaca(&lista, invertir_salto(tipo_salto));
                              apilar_FILTER(&pila_FILTER_3);
                              insertar_espacio_polaca(&lista); 
                              avanzar();
                              if (tengo_inlist)
                              {
                                condicion_AND = 0;
                              }
                              else
                              {
                                condicion_AND = 1;
                              }  
                            }
                            else
                            {
                              insertar_polaca(&lista, "BI");
                              while(pila_INLIST)
                              {
                                agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                              }
                              inicio_inlist = 0;
                              tengo_inlist = 1;
                              if (tengo_cond_inlist == 1)
                              {
                                tengo_cond_inlist = 0;
                              }
                              else
                              {
                                tengo_cond_inlist = 1;
                              }
                              apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                              insertar_espacio_polaca(&lista); 
                              avanzar();
                            } 
                          }

                        | OP_NOT PAR_A filter_condicion PAR_C { 
			                                                    if(inicio_inlist == 0)
			                                                    {
			                                                      insertar_polaca(&lista, "CMP"); 
			                                                      insertar_polaca(&lista, tipo_salto); 
			                                                      apilar_FILTER(&pila_FILTER_3);
			                                                      insertar_espacio_polaca(&lista); 
			                                                      avanzar(); 
			                                                    }
			                                                    else
			                                                    {
			                                                      negacion_inlist = 1;
			                                                      inicio_inlist = 0;
			                                                      tengo_inlist = 1;
			                                                    }
			                                                  }
                        | filter_condicion 	{ 
		                                      insertar_polaca(&lista, "CMP"); 
		                                      insertar_polaca(&lista, invertir_salto(tipo_salto));
		                                      apilar_FILTER(&pila_FILTER_3);
		                                      insertar_espacio_polaca(&lista); 
		                                      avanzar();
                                     		} 
                        ;

filter_condicion :    GUION_BAJO { insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "RTA")); } comparacion expresion
                    | expresion comparacion GUION_BAJO { insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "RTA")); }
                    ;

filter_lista_variable :   filter_lista_variable SEPARADOR ID {
                                            filter_validarTipoVariable(yylval.strVal);
                                            insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "RTA"));
                                            insertar_polaca(&lista, $3);
                                            insertar_polaca(&lista, "=");
                                            insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "AUX"));
                                            insertar_polaca(&lista, generarAuxiliar(posicion_polaca+4, "POS"));
                                            insertar_polaca(&lista, "=");
                                            insertar_polaca(&lista, "BI");
                                            insertar_polaca(&lista, generarAuxiliar(auxiliar_posicion_polaca, "POS"));
                               }
                        | ID {
                            filter_validarTipoVariable(yylval.strVal);
                            insertarStringEnTS(generarAuxiliar(variable_auxiliar, "BR"), generarAuxiliar(posicion_polaca, "POS"));
                            insertar_polaca(&lista, "BI");
                            insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "AUX")); //DARLE VALOR: posicion_polaca o posicion_polaca+1 (fijarse)
                            insertarStringEnTS(generarAuxiliar(variable_auxiliar, "AUX"), generarAuxiliar(posicion_polaca, "POS"));
                            insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "RTA"));
                            insertar_polaca(&lista, $1);
                            insertar_polaca(&lista, "=");
                            insertar_polaca(&lista, generarAuxiliar(variable_auxiliar, "AUX"));
                            insertar_polaca(&lista, generarAuxiliar(posicion_polaca+4, "POS"));
                            insertar_polaca(&lista, "=");
                            insertar_polaca(&lista, "BI");
                            auxiliar_posicion_polaca = desapilar_FILTER(&pila_FILTER_2);
                            insertar_polaca(&lista, generarAuxiliar(auxiliar_posicion_polaca, "POS"));
                          }
                        ;


lista_condicion :   condicion { if(inicio_inlist == 0)
                                {
                                  insertar_polaca(&lista, "CMP");
                                  insertar_polaca(&lista, tipo_salto);
                                  apilar_IF(&pila_IF);
                                  insertar_espacio_polaca(&lista);
                                  avanzar();
                                }
                                else
                                {
                                  insertar_polaca(&lista, "BI");
                                  while(pila_INLIST)
                                  {
                                    agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                  }
                                  apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                  insertar_espacio_polaca(&lista); 
                                  avanzar();
                                  inicio_inlist = 0;
                                  tengo_inlist = 1;
                                  tengo_cond_inlist = 1;
                                }
                              }
                    OP_AND condicion { 
                                      if(inicio_inlist == 0)
                                      {
                                        insertar_polaca(&lista, "CMP");
                                        insertar_polaca(&lista, tipo_salto); 
                                        apilar_IF(&pila_IF);
                                        insertar_espacio_polaca(&lista); 
                                        avanzar();
                                        if (tengo_inlist)
                                        {
                                          condicion_AND = 0;
                                        }
                                        else
                                        {
                                          condicion_AND = 1;
                                        }  
                                      }
                                      else
                                      {
                                        insertar_polaca(&lista, "BI");
                                        while(pila_INLIST)
                                        {
                                          agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                        }
                                        inicio_inlist = 0;
                                        tengo_inlist = 1;
                                        if (tengo_cond_inlist == 1)
                                        {
                                          tengo_cond_inlist = 0;
                                        }
                                        else
                                        {
                                          tengo_cond_inlist = 1;
                                        }
                                        apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                        insertar_espacio_polaca(&lista); 
                                        avanzar();
                                      }     
                                     }
                  | condicion { 
                                if(inicio_inlist == 0)
                                {
                                  insertar_polaca(&lista, "CMP"); 
                                  insertar_polaca(&lista, invertir_salto(tipo_salto)); 
                                  apilar_IF(&pila_IF);
                                  insertar_espacio_polaca(&lista); 
                                  avanzar(); 
                                }
                                else
                                {                               
                                  inicio_inlist = 0;
                                  tengo_inlist = 1;
                                  tengo_cond_inlist = 1;
                                }
                              } 
                    OP_OR condicion {
                                      if(inicio_inlist == 0)
                                      {
                                        insertar_polaca(&lista, "CMP"); 
                                        insertar_polaca(&lista, tipo_salto); 
                                        if(tengo_cond_inlist == 1)
                                        {
                                          while(pila_INLIST)
                                          {
                                            agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                          }
                                        }
                                        else
                                        {
                                          agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca+1);
                                        }
                                        apilar_IF(&pila_IF);
                                        insertar_espacio_polaca(&lista);
                                        avanzar();
                                      }
                                      else
                                      {
                                        insertar_polaca(&lista, "BI");
                                        while(pila_INLIST)
                                        {
                                          agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                        }
                                        apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                        if (tengo_cond_inlist == 1)
                                        {
                                          tengo_cond_inlist = 0;
                                        }
                                        else
                                        {
                                          agregar_salto(&lista, desapilar_IF(&pila_IF), posicion_polaca+1);
                                        }
                                        insertar_espacio_polaca(&lista); 
                                        avanzar();
                                        inicio_inlist = 0;
                                        tengo_inlist = 1;
                                      }
                                    }

                  | OP_NOT PAR_A condicion PAR_C  { 
                                                    if(inicio_inlist == 0)
                                                    {
                                                      insertar_polaca(&lista, "CMP"); 
                                                      insertar_polaca(&lista, invertir_salto(tipo_salto)); 
                                                      apilar_IF(&pila_IF);
                                                      insertar_espacio_polaca(&lista); 
                                                      avanzar(); 
                                                    }
                                                    else
                                                    {
                                                      negacion_inlist = 1;
                                                      inicio_inlist = 0;
                                                      tengo_inlist = 1;
                                                    }
                                                  }

                  | condicion { 
                                if(inicio_inlist == 0)
                                {
                                  insertar_polaca(&lista, "CMP"); 
                                  insertar_polaca(&lista, tipo_salto); 
                                  apilar_IF(&pila_IF);
                                  insertar_espacio_polaca(&lista); 
                                  avanzar(); 
                                }
                                else
                                {
                                  insertar_polaca(&lista, "BI");
                                  while(pila_INLIST)
                                  {
                                    agregar_salto(&lista, desapilar_INLIST(&pila_INLIST), posicion_polaca+1);
                                  }
                                  apilar_INLIST_INCOND(&pila_INLIST_INCOND);
                                  insertar_espacio_polaca(&lista); 
                                  avanzar();
                                  inicio_inlist = 0;
                                  tengo_inlist = 1;
                                }
                              }
                  ;

condicion :   expresion comparacion expresion
            | inlist { inicio_inlist = 1; }
            ;

comparacion :   OP_MAYOR { strncpy(tipo_salto, "BLE", 10); }
              | OP_MENOR { strncpy(tipo_salto, "BGE", 10); }
              | OP_MAYOR_IGUAL { strncpy(tipo_salto, "BLT", 10); }
              | OP_MENOR_IGUAL { strncpy(tipo_salto, "BGT", 10); }
              | OP_IGUAL { strncpy(tipo_salto, "BNE", 10); }
              | OP_DISTINTO { strncpy(tipo_salto, "BEQ", 10); }
              ;


inlist : INLIST PAR_A ID { id_Inlist = $3; 
                         } PUNTO_COMA COR_A lista_expresiones COR_C PAR_C ;

lista_expresiones :   lista_expresiones PUNTO_COMA expresion { insertar_polaca(&lista, id_Inlist);
                                                               insertar_polaca(&lista, "CMP");
                                                               insertar_polaca(&lista, "BEQ");
                                                               apilar_INLIST(&pila_INLIST);
                                                               insertar_espacio_polaca(&lista);
                                                               avanzar();
                                                             }
                    | expresion { insertar_polaca(&lista, id_Inlist);
                                  insertar_polaca(&lista, "CMP");
                                  insertar_polaca(&lista, "BEQ");
                                  apilar_INLIST(&pila_INLIST);
                                  insertar_espacio_polaca(&lista);
                                  avanzar();}
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
    crear_pila_FILTER(&pila_FILTER_1);
    crear_pila_FILTER(&pila_FILTER_2);
    crear_pila_FILTER(&pila_FILTER_3);
    crear_pila_INLIST(&pila_INLIST);
    crear_pila_INLIST_INCOND(&pila_INLIST_INCOND);
    crear_pila_ASM(&pila_ASM);
    crear_lista_etiqueta(&lista_etiqueta);
    crear_lista_data(&lista_data);

  }
  fclose(yyin);
  return 0;
}

int yyerror(void){
  printf("Syntax Error\n");
	system ("Pause");
	exit (1);
}

/*VALIDACIONES*/

void ValidarVariablesEnDeclaracion()
{  
  if(contar_tipo_dato != contar_variable)
  {
    printf("Error semantico - Declaracion con distita cantidad de tipos de datos y de variables\n");
    system ("Pause");
    exit (1);
  }
  contar_tipo_dato = 0;
  contar_variable = 0;
}

void ValidarTipoDatoEnAsignacion(int tipoDato)
{ 
  if (inicio_asignacion == 1 && tipo_dato_asignacion != tipoDato)
  {
    printf("Error semantico - Asignacion de datos de distinto tipo\n");
    system ("Pause");
    exit (1);
  }
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

    (*lista)->info.elemento = generarAuxiliar(posicion_hasta, "POS");
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

/*Pila - INLIST_INCOND*/

void crear_pila_INLIST_INCOND(t_pila *pila){ crear_pila(pila); }
void apilar_INLIST_INCOND(t_pila *pila){ apilar(pila); }
int desapilar_INLIST_INCOND(t_pila *pila){ desapilar(pila); }

/******************************************************************************/
/******************************************************************************/

/*FUNCIONES PARA ASM*/

void generar_asm(t_lista *lista, t_lista_etiqueta *lista_etiqueta, t_lista_data *lista_data){
  /*Creacion del archivo ASM*/
  FILE *pf_asm;
  char *elemento_aux;
  char *aux;
  int contadorAux = 0;
  int contadorElemento = 0;
  char *salto;
  int i;
  int tipoDato;

  if((pf_asm = fopen("Final.asm", "w")) == NULL)
  {
    printf("Error al generar el asembler \n");
    exit(1);
  }

  insertar_cabezera_asm(&pf_asm);

  while(*lista){

    contadorElemento++;
    if(*lista_etiqueta && (*lista_etiqueta)->info.posicion == contadorElemento)
    {
      printf("%d \n", contadorElemento);
      fprintf(pf_asm, "%s: \n", (*lista_etiqueta)->info.elemento);
      lista_etiqueta = &(*lista_etiqueta)->siguiente;
    }

    elemento_aux = (char *)malloc(strlen((*lista)->info.elemento)*sizeof(char));
    strcpy(elemento_aux, (*lista)->info.elemento);

    if(esOperador(&elemento_aux)){ //Si es  alguno de: {+,  -, *, /}
      fprintf(pf_asm, "\t FILD %s \n", get_nombre_asm(desapilar_ASM(&pila_ASM)));
      fprintf(pf_asm, "\t FILD %s \n", get_nombre_asm(desapilar_ASM(&pila_ASM)));
      fprintf(pf_asm, "\t FXCH \n");
      fprintf(pf_asm, "\t %s \n", elemento_aux);
      fprintf(pf_asm, "\t FSTP %s \n", generarAuxiliar(++contadorAux, "@aux"));
      apilar_ASM(&pila_ASM, generarAuxiliar(contadorAux, "@aux"), lista_data);
      insertarEnTS(generarAuxiliar(contadorAux, "@aux"), "-", "-", "-");
    }
    else if(esAsignacion(&elemento_aux)){  //Si es {=}
      aux = (char *)malloc(30*sizeof(char));
      strcpy(aux, get_nombre_asm(desapilar_ASM(&pila_ASM)));
      fprintf(pf_asm, "\t FILD %s \n", get_nombre_asm(desapilar_ASM(&pila_ASM)));
      fprintf(pf_asm, "\t FSTP %s \n", aux);
    }
    else if(esComparacion(&elemento_aux)){ //Si es: {CMP}
      fprintf(pf_asm, "\t FILD %s \n", get_nombre_asm(desapilar_ASM(&pila_ASM)));
      fprintf(pf_asm, "\t FILD %s \n", get_nombre_asm(desapilar_ASM(&pila_ASM)));
      fprintf(pf_asm, "\t FXCH \n");
      fprintf(pf_asm, "\t FCOM \n");
      fprintf(pf_asm, "\t FSTSW AX \n");
      fprintf(pf_asm, "\t SAHF \n");
    }
    else if(esSalto(&elemento_aux)){ //Si es  alguno de: {BGT, BLT, BGE, BLE, BI, BNE, BEQ}
      salto = (char *)malloc(30*sizeof(char));
      strcpy(salto, elemento_aux);
    }
    else if(esEtiqueta(&elemento_aux)){ //Si es POS_X, entra por aca
      for(i = 0; i <= 3; i++)
      {
        strcpy(elemento_aux, elemento_aux + 1);
      }
      fprintf(pf_asm, "\t %s ETIQ_%s \n", salto, elemento_aux);
    }
    else if(esRead(&elemento_aux))
    {
      elemento_aux = desapilar_ASM(&pila_ASM);
      tipoDato = getTipoDatoId(elemento_aux);
      if((tipoDato == 1) || (tipoDato == 2))
      {
        fprintf(pf_asm, "\t GetFloat %s \n", get_nombre_asm(elemento_aux));
      }
      else if(tipoDato == 3)
      {
        fprintf(pf_asm, "\t GetString %s \n", get_nombre_asm(elemento_aux));
      }
    }
    else if(esWrite(&elemento_aux))
    {
      elemento_aux = desapilar_ASM(&pila_ASM);
      tipoDato = getTipoDatoId(elemento_aux);
      if((tipoDato == 1) || (tipoDato == 2))
      {
        fprintf(pf_asm, "\t DisplayFloat %s,2 \n", get_nombre_asm(elemento_aux));
      }
      else if(tipoDato == 3)
      {
        fprintf(pf_asm, "\t DisplayString %s \n", get_nombre_asm(elemento_aux));
      }
    }
    else{
      apilar_ASM(&pila_ASM, elemento_aux, lista_data); //Si es  un operando,  entra por aca
    }

    lista = &(*lista)->siguiente;
  }

  contadorElemento++;
  if(*lista_etiqueta && (*lista_etiqueta)->info.posicion == contadorElemento)
  {
    printf("%d \n", contadorElemento);
    fprintf(pf_asm, "%s: \n", (*lista_etiqueta)->info.elemento);
    lista_etiqueta = &(*lista_etiqueta)->siguiente;
  }

  fprintf(pf_asm, "\n");
  fprintf(pf_asm, ".DATA \n");
  char* valor = (char *)malloc(30*sizeof(char));

  while(*lista_data)
  {
    strcpy(valor, (char*)data_enTS((*lista_data)->elemento));
    if(strcmpi(valor, "ID") == 0)
    {
      fprintf(pf_asm, "\t %s dd ?\n", get_nombre_asm((*lista_data)->elemento));
    }
    else
    {
      fprintf(pf_asm, "\t %s dd %s\n", get_nombre_asm((*lista_data)->elemento), valor);
    }
    lista_data = &(*lista_data)->siguiente;
  }

  fclose(pf_asm);
}

int esOperador(char **elemento){

  int resultado = 0;
  char *aux;

  if(strcmp(*elemento, "+")== 0)
  {
    aux = "FADD";
    resultado = 1;
  }
  else if(strcmp(*elemento, "-")== 0)
  {
    aux = "FSUB";
    resultado = 1;
  }
  else if(strcmp(*elemento, "*")== 0)
  {
    aux = "FMUL";
    resultado = 1;
  }
  else if(strcmp(*elemento, "/")== 0)
  {
    aux = "FDIV";
    resultado = 1;
  }

  if(resultado)
  {
   *elemento = (char *)malloc(sizeof(char));
    strcpy(*elemento, aux);
  }
  
  return resultado;
}

int esAsignacion(char **elemento){
  
  int resultado = 0;

  if(!strcmp(*elemento, "=")){

    *elemento = (char *)malloc(4*sizeof(char));
    strcpy(*elemento, "MOV");
    resultado = 1;
  }

  return resultado;
}

int esComparacion(char **elemento){
    
    int resultado = 0;

  if(!strcmp(*elemento, "CMP")){

    *elemento = (char *)malloc(5*sizeof(char));
    strcpy(*elemento, "FCOMP");
    resultado = 1;
  }

  return resultado;

}

int esSalto(char **elemento){
  
  int resultado = 0;
  char *aux;

  if(!strcmp(*elemento, "BNE")){

    aux = "JNE";
    resultado = 1;
  }
  else if(!strcmp(*elemento, "BEQ")){

    aux = "JE";
    resultado = 1;
  }
  else if(!strcmp(*elemento, "BGE")){

    aux = "JNA";
    resultado = 1;
  }
  else if(!strcmp(*elemento, "BGT")){

    aux = "JNAE";
    resultado = 1;
  }
  else if(!strcmp(*elemento, "BLE")){

    aux = "JNB";
    resultado = 1;
  }
  else if(!strcmp(*elemento, "BLT")){

    aux = "JNBE";
    resultado = 1;
  }
  else if(!strcmp(*elemento, "BI")){

    aux = "JMP";
    resultado = 1;
  }


  if(resultado){
    *elemento = (char *)malloc(4*sizeof(char));
    strcpy(*elemento, aux);
  }

  return resultado;
}

int esEtiqueta(char **elemento){
  if (strstr(*elemento, "POS_") != NULL)
  {
    return 1;
  }
  return 0;
}

int esRead(char **elemento)
{
  if (strstr(*elemento, "READ") != NULL)
  {
    return 1;
  }
  return 0;
}

int esWrite(char **elemento)
{
  if (strstr(*elemento, "WRITE") != NULL)
  {
    return 1;
  }
  return 0;
}

void insertar_cabezera_asm(FILE **pf_asm){

    fprintf(*pf_asm, "include macros2.asm\n");
    fprintf(*pf_asm, "include number.asm\n");
    fprintf(*pf_asm, ".MODEL  LARGE \n");
    fprintf(*pf_asm, ".386\n");
    fprintf(*pf_asm, ".STACK 200h \n");

    fprintf(*pf_asm, ".CODE \n");
    fprintf(*pf_asm, "MAIN:\n");
    fprintf(*pf_asm, "\n");

    fprintf(*pf_asm, "\n");
    fprintf(*pf_asm, "\t MOV AX,@DATA  ;inicializa el segmento de datos\n");
    fprintf(*pf_asm, "\t MOV DS,AX \n");
    fprintf(*pf_asm, "\t MOV ES,AX \n");
    fprintf(*pf_asm, "\t FNINIT \n");;
    fprintf(*pf_asm, "\n");
}

void crear_pila_ASM(t_pila_ASM *pila){ 

  *pila = NULL;
}

void apilar_ASM(t_pila_ASM *pila, char *elemento, t_lista_data *lista_data){ 

  t_nodo_pila_ASM *nuevo_nodo_pila = (t_nodo_pila_ASM *)malloc(sizeof (t_nodo_pila_ASM));
  char *elemento_aux = (char *)malloc(strlen(elemento)*sizeof(char));

  if(!nuevo_nodo_pila || !elemento_aux)
      exit(1);

  strcpy(elemento_aux, elemento);
  nuevo_nodo_pila->elemento = elemento_aux;
  nuevo_nodo_pila->siguiente = *pila;
  *pila = nuevo_nodo_pila;

  int existeElemento = 0;
  while(*lista_data)
  {
    if(strcmpi((*lista_data)->elemento, elemento_aux) == 0)
    {
      existeElemento = 1;
    }
    lista_data = &(*lista_data)->siguiente;
  }
  if(existeElemento == 0)
  {
    insertar_lista_data(lista_data, elemento_aux);
  }
 }

char *desapilar_ASM(t_pila_ASM *pila){ 

  t_nodo_pila_ASM *nodo_aux;
  char *elemento_aux;

  if (*pila == NULL)
      exit(1);

  nodo_aux = *pila;
  elemento_aux = (char *)malloc(strlen(nodo_aux->elemento)*sizeof(char));
  strcpy(elemento_aux, nodo_aux->elemento);

  *pila = nodo_aux->siguiente;
  free(nodo_aux);

  return elemento_aux;
 }

char *get_nombre_asm(char *elemento){

  if (strstr(elemento, "@") == NULL)
  {
    return (char*)buscar_enTS(elemento);
  }
  return elemento;

}

char* generarAuxiliar(int x, char *inicial){

    char *aux = (char *)malloc(strlen(inicial)*sizeof(char));
    char *buffer = malloc(sizeof(char) * sizeof(int) * 4 + 1);

    if (buffer && aux){
        strcpy(aux, inicial);
        sprintf(buffer, "%s_%d", aux, x);
    }
         

    return buffer;
}
   
void crear_lista_etiqueta(t_lista_etiqueta *lista_etiqueta)
{
  *lista_etiqueta = NULL;
}

void insertar_lista_etiqueta(t_lista_etiqueta *lista_etiqueta, char *elemento, int posicion)
{
  t_nodo_lista_etiqueta *nuevo = (t_nodo_lista_etiqueta *)malloc(sizeof (t_nodo_lista_etiqueta));
  if (!nuevo)
    exit(1);

  nuevo->info.elemento = (char *)malloc(strlen(elemento)*sizeof(char));
  if(!nuevo->info.elemento){
      exit(1);
  }

  strcpy(nuevo->info.elemento, elemento);
  nuevo->info.posicion = posicion;

  while (*lista_etiqueta)
    lista_etiqueta = &(*lista_etiqueta)->siguiente;

  *lista_etiqueta = nuevo;
  nuevo->siguiente = NULL;
}

void guardar_etiquetas(t_lista *lista, t_lista_etiqueta *lista_etiqueta)
{
  char *aux;
  char *toString;
  int contadorEtiqueta = 0;
  int i;
  char *elemento_aux;
  char *elemento_aux2;
  int posicion;

  while(*lista)
    {
      elemento_aux = (char *)malloc(strlen((*lista)->info.elemento)*sizeof(char));
      elemento_aux2 = (char *)malloc(strlen((*lista)->info.elemento)*sizeof(char));
      strcpy(elemento_aux, (*lista)->info.elemento);
      strcpy(elemento_aux2, (*lista)->info.elemento);
      if(esEtiqueta(&elemento_aux))
      {
        for(i = 0; i <= 3; i++)
        {
          strcpy(elemento_aux2, elemento_aux2 + 1);
        }
        contadorEtiqueta++;
        aux = (char *)malloc(30*sizeof(char));
        strcpy(aux, "ETIQ_");
        strcat(aux, elemento_aux2);
        posicion = atoi(elemento_aux2);     
        if(existe_etiqueta(&lista_etiqueta, posicion) == 0)
        {
          insertar_lista_etiqueta(lista_etiqueta, aux, posicion);
        }        
      }
      lista = &(*lista)->siguiente;
    }
}

int existe_etiqueta(t_lista_etiqueta **lista_etiqueta, int posicion)
{
  while(**lista_etiqueta)
  {
    if((**lista_etiqueta)->info.posicion == posicion)
    {
      return 1; 
    }
    *lista_etiqueta = &(**lista_etiqueta)->siguiente;
  }
  return 0;
}

void crear_lista_data(t_lista_data *lista_data)
{
  *lista_data = NULL;
}

void insertar_lista_data(t_lista_data *lista_data, char* elemento)
{
  t_nodo_lista_data *nuevo = (t_nodo_lista_data *)malloc(sizeof (t_nodo_lista_data));
  if (!nuevo)
    exit(1);

  nuevo->elemento = (char *)malloc(strlen(elemento)*sizeof(char));
  if(!nuevo->elemento){
      exit(1);
  }

  strcpy(nuevo->elemento, elemento);

  while (*lista_data)
    lista_data = &(*lista_data)->siguiente;

  *lista_data = nuevo;
  nuevo->siguiente = NULL;
}