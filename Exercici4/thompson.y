%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

/* Estructura per representar una transició */
typedef struct {
    int inici;
    int fi;
    char simbol; // 0 per a Lambda
} Transicio;

/* Estructura per representar un fragment d'AFN */
typedef struct {
    int inici;
    int fi;
} AFN;

Transicio taula[1000];
int num_trans = 0;
int comptador_estats = 1;

/* Funcions auxiliars */
int nou_estat() { return comptador_estats++; }

void afegir_trans(int de, int a, char s) {
    taula[num_trans].inici = de;
    taula[num_trans].fi = a;
    taula[num_trans].simbol = s;
    num_trans++;
}

void imprimir_afn(AFN a) {
    printf("Descripcio del AF:\n");
    printf("Estats numerats del 1 al %d\n", comptador_estats - 1);
    for(int i = 0; i < num_trans; i++) {
        printf("[Estat %d, ", taula[i].inici);
        if(taula[i].simbol == 0) printf("Lambda] ");
        else printf("Simbol %c] ", taula[i].simbol);
        printf("Go to %d\n", taula[i].fi);
    }
    printf("Estat inicial: %d\n", a.inici);
    printf("Estat final: %d\n\n", a.fi);
}

void reiniciar_automata() {
    num_trans = 0;
    comptador_estats = 1;
}

%}

%union {
    char simbol;
    AFN afn;
}

%token <simbol> SIMBOL
%token LAMBDA OR CONCAT STAR PLUS QMARK LPAREN RPAREN SEMI

/* Precedència de menor a major */
%left OR
%left CONCAT
%left STAR PLUS QMARK

%type <afn> expressio

%%

input:
    /* buit */
    | input linia
    ;

linia:
    expressio SEMI {
        imprimir_afn($1);
        reiniciar_automata();
    }
    | error SEMI { yyerrok; reiniciar_automata(); }
    ;

expressio:
    SIMBOL {
        $$.inici = nou_estat();
        $$.fi = nou_estat();
        afegir_trans($$.inici, $$.fi, $1);
    }
    | LAMBDA {
        $$.inici = nou_estat();
        $$.fi = nou_estat();
        afegir_trans($$.inici, $$.fi, 0);
    }
    | expressio OR expressio {
        $$.inici = nou_estat();
        $$.fi = nou_estat();
        afegir_trans($$.inici, $1.inici, 0);
        afegir_trans($$.inici, $3.inici, 0);
        afegir_trans($1.fi, $$.fi, 0);
        afegir_trans($3.fi, $$.fi, 0);
    }
    | expressio CONCAT expressio {
        // Unim el final del primer amb l'inici del segon mitjançant Lambda
        afegir_trans($1.fi, $3.inici, 0);
        $$.inici = $1.inici;
        $$.fi = $3.fi;
    }
    | expressio STAR {
        $$.inici = nou_estat();
        $$.fi = nou_estat();
        afegir_trans($$.inici, $1.inici, 0);
        afegir_trans($$.inici, $$.fi, 0);
        afegir_trans($1.fi, $1.inici, 0);
        afegir_trans($1.fi, $$.fi, 0);
    }
    | expressio PLUS {
        $$.inici = nou_estat();
        $$.fi = nou_estat();
        afegir_trans($$.inici, $1.inici, 0);
        afegir_trans($1.fi, $1.inici, 0);
        afegir_trans($1.fi, $$.fi, 0);
    }
    | expressio QMARK {
        $$.inici = nou_estat();
        $$.fi = nou_estat();
        afegir_trans($$.inici, $1.inici, 0);
        afegir_trans($$.inici, $$.fi, 0);
        afegir_trans($1.fi, $$.fi, 0);
    }
    | LPAREN expressio RPAREN {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintàctic a la línia %d: %s\n", yylineno, s);
}

int main() {
    return yyparse();
}