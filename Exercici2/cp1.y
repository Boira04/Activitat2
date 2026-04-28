%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yyline;
extern int yylex(void);
void yyerror(const char *s);

int formula_line;
%}

%union {
    char *name;
}

%token <name> PREDSYM IDSYM VAR
%token FORALL EXISTS
%token AND OR NOT
%token IMPLIES IFF
%token LPAREN RPAREN COMMA SEMICOLON
%token LEXERROR

%%

program
    : stmtlist
    ;

stmtlist
    :
    | stmtlist formula SEMICOLON
        {
            printf("Formula CP1 Correcta Linia %d\n", yyline - 1 < formula_line ? formula_line : yyline);
        }
    | stmtlist error SEMICOLON
        {
            printf("ERROR Formula INCORRECTA Linia %d\n", yyline);
            yyerrok;
        }
    ;

formula
    : formula IMPLIES disj
    | formula IFF     disj
    | disj
    ;

disj
    : disj OR conj
    | conj
    ;

conj
    : conj AND quant
    | quant
    ;

quant
    : FORALL VAR quant
    | EXISTS VAR quant
    | neg
    ;

neg
    : NOT neg
    | atom
    ;

atom
    : PREDSYM LPAREN termlist RPAREN
    | PREDSYM
    | LPAREN formula RPAREN
    ;

termlist
    : term
    | termlist COMMA term
    ;

term
    : VAR
    | IDSYM
    | IDSYM LPAREN termlist RPAREN
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "syntax error ERROR a la linia %d: %s\n", yyline, s);
}

int main(void) {
    yyparse();
    return 0;
}
