%{
#include "traductor.tab.h"
#include <stdlib.h>

/* Variable externa per portar el control de la línia actual */
extern int yylineno;
%}

/* Opció per no haver d'implementar yywrap */
%option noyywrap

%%

"c"[^\n]*\n         { yylineno++; /* Ignorar comentaris que comencen amb 'c' */ }
"p"                 { return P_HEADER; }
"cnf"               { return CNF; }
"0"                 { return ZERO; }

/* Identificar enters positius o negatius (literals) */
-?[1-9][0-9]*       { yylval.val = atoi(yytext); return INT; }

[ \t\r]+            { /* Ignorar espais, tabuladors i retorns de carro */ }
\n                  { yylineno++; /* Incrementar comptador de línies */ }

.                   { printf("Error lexic a la linia %d: caracter inesperat '%s'\n", yylineno, yytext); }

%%