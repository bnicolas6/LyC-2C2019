%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
FILE  *yyin;
int yylval;

%}

DIGITO			[0-9]
LETRA			[a-zA-Z]
CARACTER        [a-z|A-Z|0-9|=|>|<|!|:|+|-|*|/|?|¿|!|¡|@|%|#|&|°|´|^|`|~|/|\\|-|_|.|,|;|¬||]
CTE_STRING      "{CARACTER}*"
CTE_REAL        {DIGITO}+"."{DIGITO}*
CTE_INT         {DIGITO}+
REPEAT			[REPEAT|repeat]
UNTIL			[UNTIL|until]
IF				[IF|if]
ELSE			[ELSE|else]
OP_ESC			[PRINT|print]
OP_LEC			[READ|read]
VAR_INI			[VAR|var]
VAR_FIN			[ENDVAR|endvar]
INT 			[INT|int]
FLOAT			[FLOAT|float]
STRING 			[STRING|string]
FILTER			[FILTER|filter]
INLIST			[INLIST|inlist]
COMENTARIO 		--/({CARACTER}*|--/{CARACTER}*/--)/--
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
"+"				{ return MAS; }
"-"				{ return MENOS; }
"*"				{ return MULT; }
"/"				{ return DIVI; }
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
{ID} 			{ return ID; }
{CTE_INT}		{ return CTE_INT; }
{CTE_REAL}		{ return CTE_REAL; }
{CTE_STRING}	{ return CTE_STRING; }
" "
"\t"
"\n"
%%