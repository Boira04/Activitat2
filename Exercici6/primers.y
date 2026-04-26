%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

#define MAX_PRODS 200

/* Ordre de definicio dels no terminals (per preservar l'ordre de sortida) */
int nt_order[26];
int nt_count  = 0;
int nt_defined[26];

/*
 * Primer simbol de cada produccio per a cada no terminal.
 * Codificacio: 0-25 = terminal (a-z), 26-51 = no terminal (A-Z).
 */
int prods[26][MAX_PRODS];
int prod_cnt[26];

/* Taula FIRST: first[nt][t] = 1 si el terminal t pertany a FIRST(nt) */
int first_set[26][26];

int current_nt = -1;

void define_nt(char c) {
    int idx = c - 'A';
    if (!nt_defined[idx]) {
        nt_defined[idx] = 1;
        nt_order[nt_count++] = idx;
    }
    current_nt = idx;
}

void record_prod(int sym) {
    if (current_nt < 0 || prod_cnt[current_nt] >= MAX_PRODS) return;
    prods[current_nt][prod_cnt[current_nt]++] = sym;
}

void compute_first() {
    /* Pas 1: afegir directament els terminals que encapçalen produccions */
    for (int i = 0; i < 26; i++)
        for (int p = 0; p < prod_cnt[i]; p++) {
            int s = prods[i][p];
            if (s < 26) first_set[i][s] = 1;
        }

    /* Pas 2: propagar a traves dels no terminals (punt fix) */
    int changed = 1;
    while (changed) {
        changed = 0;
        for (int i = 0; i < 26; i++)
            for (int p = 0; p < prod_cnt[i]; p++) {
                int s = prods[i][p];
                if (s >= 26) {
                    int nt = s - 26;
                    for (int t = 0; t < 26; t++) {
                        if (first_set[nt][t] && !first_set[i][t]) {
                            first_set[i][t] = 1;
                            changed = 1;
                        }
                    }
                }
            }
    }
}

void print_first() {
    for (int k = 0; k < nt_count; k++) {
        int i = nt_order[k];
        printf("%c=", 'A' + i);
        for (int t = 0; t < 26; t++)
            if (first_set[i][t]) printf(" %c", 'a' + t);
        printf("\n");
    }
}
%}

%union {
    char ch;
    int  val;
}

%token <ch> NONTERMINAL TERMINAL
%token COLON PIPE SEMI
%type <val> symbol symbols alt

%%

grammar:
    rules { compute_first(); print_first(); }
    ;

rules:
    rule
    | rules rule
    ;

rule:
    NONTERMINAL COLON { define_nt($1); } alts SEMI
    | error SEMI { yyerrok; }
    ;

alts:
    alt             { record_prod($1); }
    | alts PIPE alt { record_prod($3); }
    ;

alt:
    symbols { $$ = $1; }
    ;

symbols:
    symbol           { $$ = $1; }
    | symbols symbol { $$ = $1; /* conservem el primer simbol */ }
    ;

symbol:
    TERMINAL    { $$ = $1 - 'a'; }        /* 0-25  */
    | NONTERMINAL { $$ = 26 + ($1 - 'A'); } /* 26-51 */
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactic a la linia %d: %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    extern FILE *yyin;
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            fprintf(stderr, "Error: no s'ha pogut obrir el fitxer '%s'\n", argv[1]);
            return 1;
        }
        yyin = f;
    }
    return yyparse();
}
