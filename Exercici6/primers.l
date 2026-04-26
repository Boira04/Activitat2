%{
#include "primers.tab.h"
extern int yylineno;
%}

%option noyywrap

%%

"//"[^\n]*\n    { yylineno++; }
[ \t\r]+        { }
\n              { yylineno++; }

[A-Z]   { yylval.ch = yytext[0]; return NONTERMINAL; }
[a-z]   { yylval.ch = yytext[0]; return TERMINAL; }
":"     { return COLON; }
"|"     { return PIPE; }
";"     { return SEMI; }

.   { fprintf(stderr, "Error lexic a la linia %d: caracter inesperat '%s'\n", yylineno, yytext); }

%%
