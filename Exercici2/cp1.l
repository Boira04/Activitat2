%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "cp1.tab.h"

int yyline = 1;
%}

%option noyywrap

DIGIT    [0-9]
VAR      x{DIGIT}+
CONST    [a-w]{DIGIT}*|y{DIGIT}*|z{DIGIT}*
PREDSYM  [A-Z][A-Za-z0-9]*
FUNCSYM  [a-z][a-z0-9]*

%%

"//".* {}
"/*" {
    int c;
    while ((c = input()) != EOF) {
        if (c == '\n') yyline++;
        if (c == '*') {
            c = input();
            if (c == '/') break;
            else unput(c);
        }
    }
}

[ \t\r]+ {}
"\n"     { yyline++; }

"forall"  { return FORALL; }
"exists"  { return EXISTS; }
"and"     { return AND; }
"or"      { return OR; }
"not"     { return NOT; }

"->"      { return IMPLIES; }
"<->"     { return IFF; }
"!"       { return NOT; }
"^"       { return AND; }
"v"       { return OR; }

"("       { return LPAREN; }
")"       { return RPAREN; }
","       { return COMMA; }
";"       { return SEMICOLON; }

{VAR}     { yylval.name = strdup(yytext); return VAR; }
{PREDSYM} { yylval.name = strdup(yytext); return PREDSYM; }
{FUNCSYM} { yylval.name = strdup(yytext); return IDSYM; }

. {
    fprintf(stderr, "Error lexic linia %d: caracter desconegut '%s'\n", yyline, yytext);
    return LEXERROR;
}

%%
