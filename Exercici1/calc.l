%{
#include "calc.tab.h"
#include <stdlib.h>
#include <string.h>

int yyline = 1;
%}

%option noyywrap

DIGIT       [0-9]
INT         {DIGIT}+
REAL        {DIGIT}+"."{DIGIT}*|"."{DIGIT}+
LOWER       [a-z]
UPPER       [A-Z]

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

"="      { return ASSIGN; }
";"      { return SEMICOLON; }
"("      { return LPAREN; }
")"      { return RPAREN; }

"+"      { return PLUS; }
"-"      { return MINUS; }
"*"      { return TIMES; }
"/"      { return DIV; }

"div"    { return IDIV; }
"mod"    { return MOD; }

"<<"     { return LSHIFT; }
">>"     { return RSHIFT; }

"~"      { return NOT; }
"&"      { return AND; }
"|"      { return OR; }
"^"      { return XOR; }

"(real)" { return TOREAL; }

{REAL}   {
             yylval.rval = atof(yytext);
             return REALLIT;
         }

{INT}    {
             yylval.ival = atoi(yytext);
             return INTLIT;
         }

{LOWER}  {
             yylval.reg = yytext[0] - 'a';
             return INTREG;
         }

{UPPER}  {
             yylval.reg = yytext[0] - 'A';
             return REALREG;
         }

.        {
             fprintf(stderr, "Error lexic a la linia %d: caracter desconegut '%s'\n", yyline, yytext);
             return LEXERROR;
         }

%%
