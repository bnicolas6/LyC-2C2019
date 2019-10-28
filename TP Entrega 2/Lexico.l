%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include <float.h>
#include <math.h>
#include <limits.h>
#include "y.tab.h"
FILE  *yyin;

/* REGISTRO DE TABLA DE SIMBOLOS */

struct renglonTS {
	char *nombre;
	char *tipo;
	char *valor;
	char *longitud;
};

struct renglonTS tablaSimbolos[100];
int cantRenglonesTS =0;

int sd_array_TipoDato[100];
int sd_contador_TipoDato  = 0;
int sd_contador_Id;
int sd_procesando;
int sd_procesando_tipoDato = 0;

int tipoInt = 1;
int tipoFloat = 2;
int tipoString = 3;

/* FUNCIONES */

int validarCteInt(int entero);
int validarCteReal(float flotante);
int validarCteString(char *str);

int insertarCteIntEnTS(int entero);
int insertarCteRealEnTS(float flotante);
int insertarCteStringEnTS(char *str);
int insertarIDEnTS(char *id);

void insertarEnTS(char *nombre, char *tipo, char *valor, char *longitud);
int noExisteEnTS(char *nombre);
void guardarRenglonesEnTS();

void insertar_tipoDato(int tipo);
void mostrar_tipoDato();
char *nombreTipoDato(int tipo);

void sector_declaracion_Id_reiniciar();
void sector_declaracion_tipoDato_reiniciar();
char *getNombre_tipoDato(int tipoDato);
void sector_declaracion_almacenar_tipoDato(int tipoDato);
int sector_declaracion_almacenar_Id(char *id);

int filter_validarTipoVariable(char *tipoDato);

%}

%option noyywrap
%option yylineno

DIGITO			[0-9]
LETRA			[a-zA-Z]
CARACTER        [a-z|A-Z|0-9|=|>|<|!|:|+|-|*|/|?|¿|!|¡|@|%|#|&|°|´|^|`|~|/|\\|-|_|.|,|;|¬||]
CARACTER_C      [a-z|A-Z|ñÑáéíóúÁÉÍÓÚ\s|0-9|=|>|<|!|:|+|-|*|/|?|¿|!|¡|@|%|#|&|°|´|^|`|~|/|\\|-|_|.|,|;|¬||]
SEC_ESCAPE      [ \t\n\r]
STRING_VAL      ({CARACTER_C}+|{SEC_ESCAPE})*
SUB_COMENT      --\/{STRING_VAL}\/--
COMENTARIO      ({SUB_COMENT}|--\/{STRING_VAL}{SUB_COMENT}{STRING_VAL}\/--)+
CTE_STRING       \"{STRING_VAL}\"
CTE_REAL        {DIGITO}+"."{DIGITO}*
CTE_INT         {DIGITO}+
REPEAT			(REPEAT|repeat)
UNTIL			(UNTIL|until)
IF				(IF|if)
ELSE			(ELSE|else)
OP_ESC			(PRINT|print)
OP_LEC			(READ|read)
VAR_INI			(VAR|var)
VAR_FIN			(ENDVAR|endvar)
INT 			(INT|int)
FLOAT			(FLOAT|float)
STRING 			(STRING|string)
FILTER			(FILTER|filter)
INLIST			(INLIST|inlist)
ID				{LETRA}({LETRA}|{DIGITO})*

%%
"="				{ return OP_ASIG; }
">"				{ return OP_MAYOR; }
"<"				{ return OP_MENOR; }
">="			{ return OP_MAYOR_IGUAL; }
"<="			{ return OP_MENOR_IGUAL; }
"=="			{ return OP_IGUAL; }
"!="			{ return OP_DISTINTO; }
"&&"			{ return OP_AND; }
"||"			{ return OP_OR; }
"!"				{ return OP_NOT; }
"("				{ return PAR_A; }
")"				{ return PAR_C; }
"{"				{ return LLAVE_A; }
"}"				{ return LLAVE_C; }
"["				{ return COR_A; }
"]"				{ return COR_C; }
":"				{ return VAR_ASIG; }
";"				{ return PUNTO_COMA; }
","				{ return SEPARADOR; }
"+"				{ return OP_SUMA; }
"-"				{ return OP_RESTA; }
"*"				{ return OP_MULT; }
"/"				{ return OP_DIV; }
"_"				{ return GUION_BAJO; }
{VAR_INI}		{ sd_procesando = 1; return VAR_INI; }
{VAR_FIN}		{ sd_procesando = 0; return VAR_FIN; }
{OP_ESC}		{ return OP_ESC; }
{OP_LEC}		{ return OP_LEC; }
{INT}			{ sector_declaracion_almacenar_tipoDato(tipoInt); return INT; }
{FLOAT}			{ sector_declaracion_almacenar_tipoDato(tipoFloat); return FLOAT; }
{STRING}		{ sector_declaracion_almacenar_tipoDato(tipoString); return STRING; }
{FILTER}		{ return FILTER; }
{INLIST}		{ return INLIST; }
{REPEAT}		{ return REPEAT; }
{UNTIL}			{ return UNTIL; }
{IF}			{ return IF; }
{ELSE}			{ return ELSE; }
{ID} 			{ yylval.strVal = strdup(yytext); sector_declaracion_almacenar_Id(yylval.strVal); return ID; }
{CTE_INT}		{ yylval.intVal = atoi(yytext); validarCteInt(yylval.intVal); insertarCteIntEnTS(yylval.intVal); return CTE_INT; }
{CTE_REAL}		{ yylval.realVal = atof(yytext); validarCteReal(yylval.realVal); insertarCteRealEnTS(yylval.realVal); return CTE_REAL; }
{CTE_STRING}	{ yylval.strVal = strdup(yytext);
 				  yylval.strVal = yylval.strVal + 1;
				  yylval.strVal[strlen(yylval.strVal)-1] = '\0';
				  validarCteString(yylval.strVal);
				  insertarCteStringEnTS(yylval.strVal);
				  return CTE_STRING;
				}
" "
"\t"
"\n"
{COMENTARIO}
%%

/* FUNCIONES */

int validarCteInt(int entero)
{
	if(entero < -32768 || entero > 32767)
	{
		printf("(!) ERROR: Constante entera fuera de rango (16 bits maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}
	return 1;
}

int validarCteReal(float flotante)
{
	if(flotante < pow(3.4, -38) || flotante > pow(3.4, 38))
	{
		printf("(!) ERROR: Constante real fuera de rango (32 bits maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}
	return 1;
}

int validarCteString(char *str)
{
	if(strlen(str) > 30)
	{
		printf("(!) ERROR: Constante string fuera de rango (30 caracteres maximo) -> Linea %d\n", yylineno);
		fprintf(stderr, "Fin de ejecucion.\n");
		system ("Pause");
		exit (1);
	}
	return 1;
}

int insertarCteIntEnTS(int entero)
{
	char *valor = (char*) malloc(sizeof(int));
	itoa(entero, valor, 10);

	char *nombre = (char*) malloc(sizeof(int) + 1);
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, valor);

	insertarEnTS(nombre, "CTE_INT", valor, "-");
	return 1;
}

int insertarCteRealEnTS(float flotante)
{
	char *valor = (char*) malloc(sizeof(float));
	snprintf(valor, sizeof(float), "%f", flotante);

	char *nombre = (char*) malloc(sizeof(float) + 1);
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, valor);

	insertarEnTS(nombre, "CTE_REAL", valor, "-");
	return 1;
}

int insertarCteStringEnTS(char *str)
{
	char *nombre = (char*) malloc(31 * sizeof(char));
	*nombre = '\0';
	strcat(nombre, "_");
	strcat(nombre, str);

	char *longitud = (char*) malloc(10 * sizeof(char));
	itoa(strlen(str), longitud, 10);

	insertarEnTS(nombre, "CTE_STRING", str, longitud);
	return 1;
}

int insertarStringEnTS(char *nombre, char *valor){
	char *nombre_aux = (char*) malloc(strlen(nombre)* sizeof(char) + 1);
	char *valor_aux = (char*) malloc(strlen(valor)* sizeof(char) + 1);

	if (!nombre_aux || !valor_aux)
		exit(1);

	*nombre_aux = '\0';
	*valor_aux = '\0';


	strcat(nombre_aux, "_");
	strcat(nombre_aux, nombre);

	char *longitud = (char*) malloc(10 * sizeof(char));
	strcpy(valor_aux, valor);
	itoa(strlen(valor_aux), longitud, 10);

	insertarEnTS(nombre_aux, "CTE_STRING", valor_aux, longitud);
	return 1;
}

void insertarEnTS(char *nombre, char *tipo, char *valor, char *longitud)
{
	if (noExisteEnTS(nombre)==-1)
	{
		struct renglonTS renglon;

		renglon.nombre = nombre;
		renglon.tipo = tipo;
		renglon.valor = valor;
		renglon.longitud = longitud;

		tablaSimbolos[cantRenglonesTS] = renglon;
		cantRenglonesTS++;
	}
}

int noExisteEnTS(char * nombre)
{
	int i;
	for(i = 0; i < cantRenglonesTS; i++)
	{
		if (strcmpi(nombre, tablaSimbolos[i].nombre) == 0)
			return i;
	}
	return -1;
}

void guardarRenglonesEnTS()
{
	FILE * file = fopen("ts.txt", "w");

	if(file == NULL)
	{
    	printf("(!) ERROR: No se pudo abrir el txt correspondiente a la tabla de simbolos\n");
	}
	else
	{
		fprintf(file, "%-15s\t\t %-15s\t\t %-15s\t %-15s\n\n", "NOMBRE", "TIPO", "VALOR", "LONGITUD");
		int i = 0;
		for (i; i < cantRenglonesTS; i++)
		{
			fprintf(file, "%-15s\t\t %-15s\t\t %-15s\t %-15s\n", tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
		}
		fclose(file);
	}
}

/*Funciones para insertar el tipo de dato de las variables (sector de declaracion de variables) en la TS*/

void sector_declaracion_Id_reiniciar(){
	sd_contador_Id = 0;
	if(sd_procesando_tipoDato == 0){
		sd_contador_TipoDato = 0;
		sd_procesando_tipoDato = 1;
	}
}

void sector_declaracion_tipoDato_reiniciar(){
	sd_procesando_tipoDato = 0;
}

char *getNombre_tipoDato(int tipoDato){

	switch(tipoDato){
		case 1:
			return "INT";
		case 2:
			return "FLOAT";
		default:
			return "STRING";
	}
}

void sector_declaracion_almacenar_tipoDato(int tipoDato){
	sector_declaracion_Id_reiniciar();
	sd_array_TipoDato[sd_contador_TipoDato] = tipoDato;
	sd_contador_TipoDato++;
}

int sector_declaracion_almacenar_Id(char *id){
	sector_declaracion_tipoDato_reiniciar();
	int i = 0;
	if(sd_procesando && sd_contador_Id < sd_contador_TipoDato){
		if(noExisteEnTS(id)==-1){
			insertarEnTS(id, getNombre_tipoDato(sd_array_TipoDato[sd_contador_Id]), "-", "-");
			sd_contador_Id++;
		}
		else{
			for (i; i < cantRenglonesTS; i++) {
				if (strcmpi(id, tablaSimbolos[i].nombre) == 0){
					tablaSimbolos[i].tipo = getNombre_tipoDato(sd_array_TipoDato[sd_contador_Id]);
				}
			}
			return 1;
		}
	}
}

int filter_validarTipoVariable(char *variable){
  	int i = 0;
	for (i; i < cantRenglonesTS; i++) {
			if (strcmpi(variable, tablaSimbolos[i].nombre) == 0){
				if(!strcmpi("INT", tablaSimbolos[i].tipo) == 0){
					printf("Uno de los parametros de: FILTER, no corresponde a una variable del tipo ENTERO\n");
					exit (1);
				}
			}
	}
}