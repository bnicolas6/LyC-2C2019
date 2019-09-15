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

/* FUNCIONES */

int validarCteInt(int entero);
int validarCteReal(float flotante);
int validarCteString(char *str);

int insertarCteIntEnTS(int entero);
int insertarCteRealEnTS(float flotante);
int insertarCteStringEnTS(char *str);
int insertarIDEnTS(char *id);

void insertarEnTS(char *nombre, char *tipo, char *valor, char *longitud);
int noExisteEnTS(char * nombre);
void guardarRenglonesEnTS();

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
CTE_STRING      "{CARACTER}*"
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
{VAR_INI}		{ return VAR_INI; }
{VAR_FIN}		{ return VAR_FIN; }
{OP_ESC}		{ return OP_ESC; }
{OP_LEC}		{ return OP_LEC; }
{INT}			{ return INT; }
{FLOAT}			{ return FLOAT; }
{STRING}		{ return STRING; }
{FILTER}		{ return FILTER; }
{INLIST}		{ return INLIST; }
{REPEAT}		{ return REPEAT; }
{UNTIL}			{ return UNTIL; }
{IF}			{ return IF; }
{ELSE}			{ return ELSE; }
{ID} 			{ yylval.strVal = strdup(yytext); insertarIDEnTS(yylval.strVal); return ID; }
{CTE_INT}		{ yylval.intVal = atoi(yytext); validarCteInt(yylval.intVal); insertarCteIntEnTS(yylval.intVal); return CTE_INT; }
{CTE_REAL}		{ yylval.realVal = atof(yytext); validarCteReal(yylval.realVal); insertarCteRealEnTS(yylval.realVal); return CTE_REAL; }
{CTE_STRING}	{ yylval.strVal = strdup(yytext); validarCteString(yylval.strVal); insertarCteStringEnTS(yylval.strVal); return CTE_STRING; }
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

int insertarIDEnTS(char *id)
{
	insertarEnTS(id, "","","-");
	return 1;
}

void insertarEnTS(char *nombre, char *tipo, char *valor, char *longitud)
{
	if (noExisteEnTS(nombre))
	{
		//printf("INSERTANDO: ********** | %s | %s | %s | %s | **********\n", nombre, tipo, valor, longitud);
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
			return -1;
	}
	return 1;
}

void guardarRenglonesEnTS()
{
	FILE * file = fopen("ts.txt", "a");
	
	if(file == NULL) 
	{
    	printf("(!) ERROR: No se pudo abrir el txt correspondiente a la tabla de simbolos\n");
	}
	else 
	{
		int i = 0;
		for (i; i < cantRenglonesTS; i++) 
		{
			fprintf(file, "%s\t%s\t%s\t%s\n", tablaSimbolos[i].nombre, tablaSimbolos[i].tipo, tablaSimbolos[i].valor, tablaSimbolos[i].longitud);
		}		
		fclose(file);
	}
}
