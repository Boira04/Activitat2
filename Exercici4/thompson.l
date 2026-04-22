%{
#include "thompson.tab.h"
#include <string.h>
extern int yylineno;
%}

%option noyywrap

%%

[ \t\r\n]+          { /* Ignorar espais i salts de línia */ }
"//"[^\n]*          { /* Comentaris de línia */ }

"BUIDA"|"buida"     { return LAMBDA; }
"a"|"b"|"c"|"d"     { yylval.simbol = yytext[0]; return SIMBOL; }

"|"                 { return OR; }
"."                 { return CONCAT; }
"*"                 { return STAR; }
"+"                 { return PLUS; }
"?"                 { return QMARK; }
"("                 { return LPAREN; }
")"                 { return RPAREN; }
";"                 { return SEMI; }

.                   { printf("Error lèxic a la línia %d: '%s'\n", yylineno, yytext); }

%%