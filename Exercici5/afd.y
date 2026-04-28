%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

#define MAX_STATES 100
#define MAX_ALPHA  50
#define MAX_NAME   64

/* --- Estructures de dades globals --- */
char states[MAX_STATES][MAX_NAME];
int  num_states = 0;

char alpha[MAX_ALPHA][MAX_NAME];
int  num_alpha = 0;

int initial_state    = -1;
int final_states[MAX_STATES];
int transitions[MAX_STATES][MAX_ALPHA];

/* --- Funcions de cerca --- */
int find_state(const char *name) {
    for (int i = 0; i < num_states; i++)
        if (strcmp(states[i], name) == 0) return i;
    return -1;
}

int find_symbol(const char *name) {
    for (int i = 0; i < num_alpha; i++)
        if (strcmp(alpha[i], name) == 0) return i;
    return -1;
}

/* --- Funcions de construccio --- */
void add_state(const char *name) {
    if (find_state(name) != -1) {
        fprintf(stderr, "Avis (linia %d): estat '%s' duplicat, s'ignora.\n", yylineno, name);
        return;
    }
    if (num_states >= MAX_STATES) {
        fprintf(stderr, "Error: nombre maxim d'estats (%d) superat.\n", MAX_STATES);
        exit(1);
    }
    strncpy(states[num_states], name, MAX_NAME - 1);
    states[num_states][MAX_NAME - 1] = '\0';
    num_states++;
}

void add_symbol(const char *name) {
    if (find_symbol(name) != -1) {
        fprintf(stderr, "Avis (linia %d): simbol '%s' duplicat, s'ignora.\n", yylineno, name);
        return;
    }
    if (num_alpha >= MAX_ALPHA) {
        fprintf(stderr, "Error: nombre maxim de simbols (%d) superat.\n", MAX_ALPHA);
        exit(1);
    }
    strncpy(alpha[num_alpha], name, MAX_NAME - 1);
    alpha[num_alpha][MAX_NAME - 1] = '\0';
    num_alpha++;
}

void set_initial(const char *name) {
    int idx = find_state(name);
    if (idx == -1)
        fprintf(stderr, "Error semantic (linia %d): estat inicial '%s' no definit a la llista d'estats.\n",
                yylineno, name);
    else
        initial_state = idx;
}

void add_final(const char *name) {
    int idx = find_state(name);
    if (idx == -1)
        fprintf(stderr, "Error semantic (linia %d): estat final '%s' no definit a la llista d'estats.\n",
                yylineno, name);
    else
        final_states[idx] = 1;
}

void add_transition(const char *from, const char *sym, const char *to) {
    int fi  = find_state(from);
    int si  = find_symbol(sym);
    int ti  = find_state(to);
    int err = 0;

    if (fi == -1) {
        fprintf(stderr, "Error semantic (linia %d): estat origen '%s' no definit.\n", yylineno, from);
        err = 1;
    }
    if (si == -1) {
        fprintf(stderr, "Error semantic (linia %d): simbol '%s' no definit en l'alfabet.\n", yylineno, sym);
        err = 1;
    }
    if (ti == -1) {
        fprintf(stderr, "Error semantic (linia %d): estat desti '%s' no definit.\n", yylineno, to);
        err = 1;
    }
    if (err) return;

    if (transitions[fi][si] != -1) {
        fprintf(stderr,
                "Error semantic (linia %d): transicio (%s, %s) ja definida "
                "(un AFD te una sola transicio per estat i simbol).\n",
                yylineno, from, sym);
        return;
    }
    transitions[fi][si] = ti;
}

/* --- Validacio i impressio --- */
void validate_and_print() {
    int ok = 1;

    /* Condicio 1: estat inicial unic i valid */
    if (initial_state == -1) {
        fprintf(stderr, "Error: no s'ha definit cap estat inicial valid.\n");
        ok = 0;
    }

    /* Condicio 4: almenys un estat final */
    int has_final = 0;
    for (int i = 0; i < num_states; i++)
        if (final_states[i]) { has_final = 1; break; }
    if (!has_final) {
        fprintf(stderr, "Error: no hi ha cap estat final definit.\n");
        ok = 0;
    }

    if (!ok) {
        printf("\nERROR: AFD incorrecte.\n");
        return;
    }

    /* Condicio 2: estats assolibles des de l'inicial (BFS) */
    int reachable[MAX_STATES] = {0};
    {
        int queue[MAX_STATES], head = 0, tail = 0;
        reachable[initial_state] = 1;
        queue[tail++] = initial_state;
        while (head < tail) {
            int s = queue[head++];
            for (int a = 0; a < num_alpha; a++) {
                int t = transitions[s][a];
                if (t != -1 && !reachable[t]) {
                    reachable[t] = 1;
                    queue[tail++] = t;
                }
            }
        }
    }

    /* Condicio 3: estats que poden assolir un final (punt fix cap enrere) */
    int can_reach_final[MAX_STATES] = {0};
    {
        for (int i = 0; i < num_states; i++)
            if (final_states[i]) can_reach_final[i] = 1;
        int changed = 1;
        while (changed) {
            changed = 0;
            for (int s = 0; s < num_states; s++) {
                if (!can_reach_final[s]) {
                    for (int a = 0; a < num_alpha; a++) {
                        int t = transitions[s][a];
                        if (t != -1 && can_reach_final[t]) {
                            can_reach_final[s] = 1;
                            changed = 1;
                            break;
                        }
                    }
                }
            }
        }
    }

    /* Verificar condicions 2 i 3 per a cada estat */
    for (int i = 0; i < num_states; i++) {
        if (!reachable[i]) {
            fprintf(stderr,
                    "Error semantic: l'estat '%s' no es assolible des de l'estat inicial '%s'.\n",
                    states[i], states[initial_state]);
            ok = 0;
        }
        if (!can_reach_final[i]) {
            fprintf(stderr,
                    "Error semantic: des de l'estat '%s' no es pot assolir cap estat final.\n",
                    states[i]);
            ok = 0;
        }
    }

    if (!ok) {
        printf("\nERROR: AFD incorrecte.\n");
        return;
    }

    /* --- Impressio de la descripcio del AFD --- */
    printf("\nAFD Correcte!\n");
    printf("=============\n");
    printf("Estat inicial : %s\n", states[initial_state]);
    printf("Estats finals : ");
    for (int i = 0; i < num_states; i++)
        if (final_states[i]) printf("%s ", states[i]);
    printf("\n");
    printf("Num. estats   : %d\n", num_states);
    printf("Alfabet       : ");
    for (int a = 0; a < num_alpha; a++) printf("%s ", alpha[a]);
    printf("\n\n");

    /* Taula de transicions */
    printf("Taula de transicions:\n");
    printf("  (-> = estat inicial, * = estat final)\n\n");

    printf("  %-16s", "Estat");
    for (int a = 0; a < num_alpha; a++)
        printf("  %-12s", alpha[a]);
    printf("\n  ");
    for (int i = 0; i < 16 + 14 * num_alpha; i++) printf("-");
    printf("\n");

    for (int s = 0; s < num_states; s++) {
        char label[MAX_NAME + 5];
        if (s == initial_state && final_states[s])
            snprintf(label, sizeof(label), "->*%s", states[s]);
        else if (s == initial_state)
            snprintf(label, sizeof(label), "->%s", states[s]);
        else if (final_states[s])
            snprintf(label, sizeof(label), "*%s", states[s]);
        else
            snprintf(label, sizeof(label), "%s", states[s]);

        printf("  %-16s", label);
        for (int a = 0; a < num_alpha; a++) {
            int t = transitions[s][a];
            printf("  %-12s", (t != -1) ? states[t] : "-");
        }
        printf("\n");
    }
}

%}

%union {
    char str[64];
}

%token ALFABET ESTATS INICIAL FINALS TRANSICIONS
%token OCLAVE TCLAVE COMA SEMI DOSPUNTS FLETXA
%token <str> ID

%%

input:
    afd
    | error { fprintf(stderr, "Error sintactic a la linia %d: estructura del AFD incorrecta.\n", yylineno); }
    ;

afd:
    sec_alfabet sec_estats sec_inicial sec_finals sec_transicions { validate_and_print(); }
    ;

sec_alfabet:
    ALFABET OCLAVE llista_simbols TCLAVE
    | ALFABET OCLAVE TCLAVE
    ;

sec_estats:
    ESTATS OCLAVE llista_ids_estat TCLAVE
    | ESTATS OCLAVE TCLAVE
    ;

sec_inicial:
    INICIAL ID { set_initial($2); }
    ;

sec_finals:
    FINALS OCLAVE llista_ids_final TCLAVE
    | FINALS OCLAVE TCLAVE
    ;

sec_transicions:
    TRANSICIONS OCLAVE llista_trans TCLAVE
    ;

llista_simbols:
    ID                          { add_symbol($1); }
    | llista_simbols COMA ID    { add_symbol($3); }
    ;

llista_ids_estat:
    ID                           { add_state($1); }
    | llista_ids_estat COMA ID   { add_state($3); }
    ;

llista_ids_final:
    ID                            { add_final($1); }
    | llista_ids_final COMA ID    { add_final($3); }
    ;

llista_trans:
    /* buit */
    | llista_trans transicio
    ;

transicio:
    ID DOSPUNTS ID FLETXA ID SEMI   { add_transition($1, $3, $5); }
    | error SEMI                    { yyerrok; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactic a la linia %d: %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    extern FILE *yyin;

    for (int i = 0; i < MAX_STATES; i++)
        for (int j = 0; j < MAX_ALPHA; j++)
            transitions[i][j] = -1;

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
