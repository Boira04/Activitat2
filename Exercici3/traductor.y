%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

int vars_esperades = 0;
int clausules_esperades = 0;
int clausules_comptades = 0;
int primer_literal = 1;
%}

%union {
    int val;
}

%token P_HEADER CNF ZERO
%token <val> INT

%%

axioma:
    capcalera llista_clausules {
        if (clausules_comptades != clausules_esperades) {
            fprintf(stderr, "\nError semàntic: S'esperaven %d clàusules, però n'hi ha %d.\n", 
                    clausules_esperades, clausules_comptades);
        } else {
            printf("\n");
        }
    }
    ;

capcalera:
    P_HEADER CNF INT INT {
        vars_esperades = $3;
        clausules_esperades = $4;
        printf("%d variables, %d clàusules\n\n", $3, $4);
    }
    ;

llista_clausules:
    clausula
    | llista_clausules clausula
    ;

clausula:
    literals ZERO {
        printf(")");
        clausules_comptades++;
        primer_literal = 1;
    }
    ;

literals:
    INT {
        if (primer_literal) {
            if (clausules_comptades > 0) printf(" ^ ");
            printf("(");
            primer_literal = 0;
        } else {
            printf(" v ");
        }

        if ($1 > 0) printf("p%d", $1);
        else printf("!p%d", -$1);
    }
    | literals INT {
        printf(" v ");
        if ($2 > 0) printf("p%d", $2);
        else printf("!p%d", -$2);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintàctic a la línia %d: %s\n", yylineno, s);
}

int main() {
    return yyparse();
}
