%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

int   ireg[26];
float rreg[26];
int   ireg_defined[26];
int   rreg_defined[26];

extern int yyline;
extern int yylex(void);
void yyerror(const char *s);

typedef enum { T_INT, T_REAL } ValType;
typedef struct {
    ValType type;
    union { int ival; float rval; } v;
} Val;

Val make_int(int i)    { Val v; v.type=T_INT;  v.v.ival=i; return v; }
Val make_real(float r) { Val v; v.type=T_REAL; v.v.rval=r; return v; }

void print_val(Val v) {
    if (v.type == T_INT) printf("%d\n", v.v.ival);
    else                 printf("%g\n", v.v.rval);
}
%}

%union {
    int   ival;
    float rval;
    int   reg;
    struct {
        int type;
        union { int ival; float rval; } v;
    } val;
}

%token <ival>  INTLIT
%token <rval>  REALLIT
%token <reg>   INTREG REALREG
%token ASSIGN SEMICOLON LPAREN RPAREN
%token PLUS MINUS TIMES DIV IDIV MOD
%token LSHIFT RSHIFT
%token NOT AND OR XOR
%token TOREAL
%token LEXERROR

%type <val> int_expr real_expr stmt

%left  OR
%left  XOR
%left  AND
%left  LSHIFT RSHIFT
%left  PLUS MINUS
%left  TIMES DIV IDIV MOD
%right UMINUS UPLUS NOT TOREAL
%left  LPAREN

%%

program
    : stmtlist
    ;

stmtlist
    : 
    | stmtlist stmt SEMICOLON
    | stmtlist error SEMICOLON
        {
            fprintf(stderr, "  (recuperacio d'error a la linia %d, es continua)\n", yyline);
            yyerrok;
        }
    ;

stmt
    : INTREG ASSIGN int_expr
        {
            ireg[$1] = $3.v.ival;
            ireg_defined[$1] = 1;
        }
    | REALREG ASSIGN real_expr
        {
            rreg[$1] = $3.v.rval;
            rreg_defined[$1] = 1;
        }
    | int_expr
        { printf("%d\n", $1.v.ival); }
    | real_expr
        { printf("%g\n", $1.v.rval); }
    ;

int_expr
    : INTLIT
        { $$.type=0; $$.v.ival=$1; }
    | INTREG
        {
            if (!ireg_defined[$1])
                fprintf(stderr, "Avis: registre '%c' no inicialitzat\n", 'a'+$1);
            $$.type=0; $$.v.ival=ireg[$1];
        }
    | int_expr PLUS  int_expr  { $$.type=0; $$.v.ival=$1.v.ival + $3.v.ival; }
    | int_expr MINUS int_expr  { $$.type=0; $$.v.ival=$1.v.ival - $3.v.ival; }
    | int_expr TIMES int_expr  { $$.type=0; $$.v.ival=$1.v.ival * $3.v.ival; }
    | int_expr IDIV  int_expr
        {
            if ($3.v.ival == 0) { yyerror("divisio entera per zero"); $$.v.ival=0; }
            else $$.v.ival = $1.v.ival / $3.v.ival;
            $$.type=0;
        }
    | int_expr MOD   int_expr
        {
            if ($3.v.ival == 0) { yyerror("modul per zero"); $$.v.ival=0; }
            else $$.v.ival = $1.v.ival % $3.v.ival;
            $$.type=0;
        }
    | int_expr LSHIFT int_expr { $$.type=0; $$.v.ival=$1.v.ival << $3.v.ival; }
    | int_expr RSHIFT int_expr { $$.type=0; $$.v.ival=$1.v.ival >> $3.v.ival; }
    | int_expr AND    int_expr { $$.type=0; $$.v.ival=$1.v.ival & $3.v.ival; }
    | int_expr OR     int_expr { $$.type=0; $$.v.ival=$1.v.ival | $3.v.ival; }
    | int_expr XOR    int_expr { $$.type=0; $$.v.ival=$1.v.ival ^ $3.v.ival; }
    | NOT int_expr             { $$.type=0; $$.v.ival= ~$2.v.ival; }
    | MINUS int_expr %prec UMINUS { $$.type=0; $$.v.ival= -$2.v.ival; }
    | PLUS  int_expr %prec UPLUS  { $$.type=0; $$.v.ival=  $2.v.ival; }
    | LPAREN int_expr RPAREN   { $$=$2; }
    ;

real_expr
    : REALLIT
        { $$.type=1; $$.v.rval=$1; }
    | REALREG
        {
            if (!rreg_defined[$1])
                fprintf(stderr, "Avis: registre '%c' no inicialitzat\n", 'A'+$1);
            $$.type=1; $$.v.rval=rreg[$1];
        }
    | TOREAL int_expr
        { $$.type=1; $$.v.rval=(float)$2.v.ival; }
    | real_expr PLUS  real_expr  { $$.type=1; $$.v.rval=$1.v.rval + $3.v.rval; }
    | real_expr MINUS real_expr  { $$.type=1; $$.v.rval=$1.v.rval - $3.v.rval; }
    | real_expr TIMES real_expr  { $$.type=1; $$.v.rval=$1.v.rval * $3.v.rval; }
    | real_expr DIV   real_expr
        {
            if ($3.v.rval == 0.0) { yyerror("divisio real per zero"); $$.v.rval=0.0; }
            else $$.v.rval = $1.v.rval / $3.v.rval;
            $$.type=1;
        }
    | real_expr PLUS  int_expr   { $$.type=1; $$.v.rval=$1.v.rval + (float)$3.v.ival; }
    | int_expr  PLUS  real_expr  { $$.type=1; $$.v.rval=(float)$1.v.ival + $3.v.rval; }
    | real_expr MINUS int_expr   { $$.type=1; $$.v.rval=$1.v.rval - (float)$3.v.ival; }
    | int_expr  MINUS real_expr  { $$.type=1; $$.v.rval=(float)$1.v.ival - $3.v.rval; }
    | real_expr TIMES int_expr   { $$.type=1; $$.v.rval=$1.v.rval * (float)$3.v.ival; }
    | int_expr  TIMES real_expr  { $$.type=1; $$.v.rval=(float)$1.v.ival * $3.v.rval; }
    | real_expr DIV   int_expr
        {
            if ($3.v.ival == 0) { yyerror("divisio per zero"); $$.v.rval=0.0; }
            else $$.v.rval = $1.v.rval / (float)$3.v.ival;
            $$.type=1;
        }
    | int_expr  DIV   real_expr
        {
            if ($3.v.rval == 0.0) { yyerror("divisio per zero"); $$.v.rval=0.0; }
            else $$.v.rval = (float)$1.v.ival / $3.v.rval;
            $$.type=1;
        }
    | MINUS real_expr %prec UMINUS { $$.type=1; $$.v.rval= -$2.v.rval; }
    | PLUS  real_expr %prec UPLUS  { $$.type=1; $$.v.rval=  $2.v.rval; }
    | LPAREN real_expr RPAREN      { $$=$2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactic a la linia %d: %s\n", yyline, s);
}

int main(void) {
    int i;
    memset(ireg_defined, 0, sizeof(ireg_defined));
    memset(rreg_defined, 0, sizeof(rreg_defined));
    memset(ireg, 0, sizeof(ireg));
    memset(rreg, 0, sizeof(rreg));

    yyparse();

    printf("\n--- Registres definits ---\n");
    for (i = 0; i < 26; i++)
        if (ireg_defined[i]) printf("%c = %d\n", 'a'+i, ireg[i]);
    for (i = 0; i < 26; i++)
        if (rreg_defined[i]) printf("%c = %g\n", 'A'+i, rreg[i]);

    return 0;
}
