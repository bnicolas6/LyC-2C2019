
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     OP_ASIG = 258,
     OP_AND = 259,
     OP_OR = 260,
     OP_NOT = 261,
     OP_MAYOR = 262,
     OP_MENOR = 263,
     OP_MAYOR_IGUAL = 264,
     OP_MENOR_IGUAL = 265,
     OP_IGUAL = 266,
     OP_DISTINTO = 267,
     PAR_A = 268,
     PAR_C = 269,
     COR_A = 270,
     COR_C = 271,
     LLAVE_A = 272,
     LLAVE_C = 273,
     VAR_ASIG = 274,
     SEPARADOR = 275,
     PUNTO_COMA = 276,
     OP_SUMA = 277,
     OP_RESTA = 278,
     OP_MULT = 279,
     OP_DIV = 280,
     GUION_BAJO = 281,
     VAR_INI = 282,
     VAR_FIN = 283,
     OP_ESC = 284,
     OP_LEC = 285,
     INT = 286,
     FLOAT = 287,
     STRING = 288,
     FILTER = 289,
     INLIST = 290,
     REPEAT = 291,
     UNTIL = 292,
     IF = 293,
     ELSE = 294,
     ID = 295,
     CTE_INT = 296,
     CTE_REAL = 297,
     CTE_STRING = 298
   };
#endif
/* Tokens.  */
#define OP_ASIG 258
#define OP_AND 259
#define OP_OR 260
#define OP_NOT 261
#define OP_MAYOR 262
#define OP_MENOR 263
#define OP_MAYOR_IGUAL 264
#define OP_MENOR_IGUAL 265
#define OP_IGUAL 266
#define OP_DISTINTO 267
#define PAR_A 268
#define PAR_C 269
#define COR_A 270
#define COR_C 271
#define LLAVE_A 272
#define LLAVE_C 273
#define VAR_ASIG 274
#define SEPARADOR 275
#define PUNTO_COMA 276
#define OP_SUMA 277
#define OP_RESTA 278
#define OP_MULT 279
#define OP_DIV 280
#define GUION_BAJO 281
#define VAR_INI 282
#define VAR_FIN 283
#define OP_ESC 284
#define OP_LEC 285
#define INT 286
#define FLOAT 287
#define STRING 288
#define FILTER 289
#define INLIST 290
#define REPEAT 291
#define UNTIL 292
#define IF 293
#define ELSE 294
#define ID 295
#define CTE_INT 296
#define CTE_REAL 297
#define CTE_STRING 298




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 14 ".\\Sintactico.y"

int intVal;
double realVal;
char *strVal;



/* Line 1676 of yacc.c  */
#line 146 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


