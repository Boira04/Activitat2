%{
#include <stdio.h>
#include <stdlib.h>

/* Declaracions de funcions i variables externes */
extern int yylex();
extern int yylineno;
void yyerror(const char *s);

/* Variables globals per a la verificació semàntica */
int vars_esperades = 0;
int clausules_esperades = 0;
int clausules_comptades = 0;
int primer_literal_de_clausula = 1;
%}

/* Definició del tipus de dades per als tokens (en aquest cas, enters) */
%union {
    int val;
}

%token P_HEADER CNF ZERO
%token <val> INT

%%

/* Regla principal: un fitxer DIMACS té una capçalera i després les clàusules */
input:
    capcalera llista_clausules {
        /* Verificació semàntica: comprovar si el nombre de clàusules és correcte */
        if (clausules_comptades != clausules_esperades) {
            fprintf(stderr, "\nError semàntic: S'esperaven %d clàusules, però s'han trobat %d.\n", 
                    clausules_esperades, clausules_comptades);
        } else {
            printf("\n\nTraducció finalitzada amb èxit.\n");
        }
    }
    ;

/* Regla per a la capçalera: p cnf <variables> <clausules> */
capcalera:
    P_HEADER CNF INT INT {
        vars_esperades = $3;
        clausules_esperades = $4;
        printf("/* Traducció a notació clausal (%d variables, %d clàusules) */\n", $3, $4);
    }
    ;

llista_clausules:
    clausula
    | llista_clausules clausula
    ;

/* Una clàusula és una llista de literals seguida d'un zero */
clausula:
    literals ZERO {
        printf(")");
        clausules_comptades++;
        primer_literal_de_clausula = 1;
    }
    ;

literals:
    INT {
        /* Comprovar si la variable existeix segons la capçalera */
        int v = ($1 < 0) ? -$1 : $1;
        if (v > vars_esperades) {
            fprintf(stderr, "\nAvís semàntic (línia %d): La variable %d és més gran que el màxim definit (%d).\n", 
                    yylineno, v, vars_esperades);
        }

        /* Lògica per imprimir els connectors ^ i v correctament */
        if (primer_literal_de_clausula) {
            if (clausules_comptades > 0) printf(" ^ ");
            printf("(");
            primer_literal_de_clausula = 0;
        } else {
            printf(" v ");
        }

        /* Imprimir el literal: pX si és positiu, !pX si és negatiu */
        if ($1 > 0) printf("p%d", $1);
        else printf("!p%d", -$1);
    }
    | literals INT {
        int v = ($2 < 0) ? -$2 : $2;
        if (v > vars_esperades) {
            fprintf(stderr, "\nAvís semàntic (línia %d): La variable %d és més gran que el màxim definit (%d).\n", 
                    yylineno, v, vars_esperades);
        }

        printf(" v ");
        if ($2 > 0) printf("p%d", $2);
        else printf("!p%d", -$2);
    }
    ;

%%

/* Funció que es crida quan hi ha un error de sintaxi */
void yyerror(const char *s) {
    fprintf(stderr, "Error sintàctic a la línia %d: %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    /* Si vols llegir d'un fitxer directament podries configurar yyin aquí */
    return yyparse();
}