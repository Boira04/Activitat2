%{
#include "afd.tab.h"
#include <string.h>

extern int yylineno;
%}

%option noyywrap

%%

"//"[^\n]*\n        { yylineno++; }
[ \t\r]+            { }
\n                  { yylineno++; }

"alfabet"           { return ALFABET; }
"estats"            { return ESTATS; }
"inicial"           { return INICIAL; }
"finals"            { return FINALS; }
"transicions"       { return TRANSICIONS; }

"{"                 { return OCLAVE; }
"}"                 { return TCLAVE; }
","                 { return COMA; }
";"                 { return SEMI; }
":"                 { return DOSPUNTS; }
"->"                { return FLETXA; }

[a-zA-Z][a-zA-Z0-9]* {
    strncpy(yylval.str, yytext, 63);
    yylval.str[63] = '\0';
    return ID;
}

[0-9]+ {
    strncpy(yylval.str, yytext, 63);
    yylval.str[63] = '\0';
    return ID;
}

.   { fprintf(stderr, "Error lexic a la linia %d: caracter inesperat '%s'\n", yylineno, yytext); }

%%
