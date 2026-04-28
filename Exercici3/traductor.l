%{
#include "traductor.tab.h"
#include <stdlib.h>
extern int yylineno;
%}

%option noyywrap

%%

"p"                 { return P_HEADER; }
"cnf"               { return CNF; }
"0"                 { return ZERO; }
-?[0-9]+            { yylval.val = atoi(yytext); return INT; }
^c[^\n]*            { ; /* Comentaris que comencen per c al principi de línia */ }
[ \t\r]+            { ; /* Ignorar espais */ }
\n                  { yylineno++; }
.                   { printf("Error lèxic a la línia %d: %s\n", yylineno, yytext); }

%%
