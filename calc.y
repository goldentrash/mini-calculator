%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "calc.h"

  #define HASHSIZE 101
  
  struct nlist {
    struct nlist *next;
    char *name;
    enum Num_Type type;
    union num_value value;
  };

  struct nlist *hashtab[HASHSIZE];

  int hash(char *s) {
    unsigned hashval;
    for (hashval = 0; *s != '\0'; s++)
      hashval = *s + 31 * hashval;
    return hashval % HASHSIZE;
  }

  struct nlist *lookup(char *s) {
    struct nlist *np;
    for (np = hashtab[hash(s)]; np != NULL; np = np->next)
      if (strcmp(s, np->name) == 0)
        return np;
    return NULL;
  }

  struct nlist *install(char *name, enum Num_Type type, int ival, double fval) {
    struct nlist *np;
    unsigned hashval;
    if ((np = lookup(name)) == NULL) {
      np = (struct nlist *) malloc(sizeof(*np));
      if (np == NULL || (np->name = strdup(name)) == NULL)
        return NULL;
      hashval = hash(name);
      np->next = hashtab[hashval];
      hashtab[hashval] = np;
    }
    np->type = type;
    if (type == INT_TYPE)
      np->value.ival = ival;
    else
      np->value.fval = fval;
    return np;
  }

  void print_symbol_table() {
    printf("\n====== Symbol Table ======\n");
    struct nlist *np;
    for (int i = 0; i < HASHSIZE; i++) {
      for (np = hashtab[i]; np != NULL; np = np->next) {
        if (np->type == INT_TYPE)
          printf("%s\t= %d\n", np->name, np->value.ival);
        else
          printf("%s\t= %f\n", np->name, np->value.fval);
      }
    }
  }

  extern int line_count;
  extern int column_count;

  void yyerror(const char *s) {
    fprintf(stderr, "Error(Ln %d, Col %d): %s\n", line_count, column_count, s);
  }

  int yylex(void);
%}

%union {
  int ival;
  double fval;
  char *id;
  struct value val;
}

%right '='
%left '+' '-'
%left '*' '/'
%left '(' ')'

%token  <ival>   INT
%token  <fval>   FLOAT
%token  <id>     ID
%type   <val>    E

%%

S: S L            { printf("\tYACC(%d, %d)\tS: S L\n", line_count, column_count); }
 | L              { printf("\tYACC(%d, %d)\tS: L\n", line_count, column_count); }
 ;

L: E '\n'         { 
                    printf("\tYACC(%d, %d)\tL: E\n", line_count, column_count);
                    if ($1.type == INT_TYPE) 
                      printf("YACC(%d, %d)\t%d\n", line_count, column_count, $1.val.ival); 
                    else 
                      printf("YACC(%d, %d)\t%f\n", line_count, column_count, $1.val.fval);
                  }
 | ID '=' E '\n'  { 
                    printf("\tYACC(%d, %d)\tL: ID = E\n", line_count, column_count);
                    if ($3.type == INT_TYPE) 
                      install($1, INT_TYPE, $3.val.ival, 0.0); 
                    else 
                      install($1, FLOAT_TYPE, 0, $3.val.fval); 
                  }
 | '$'            { 
                    printf("\tYACC(%d, %d)\tL: END\n", line_count, column_count); 
                    print_symbol_table(); 
                    exit(0); 
                  }
 ;

E: E '+' E        { 
                    printf("\tYACC(%d, %d)\tE: E + E\n", line_count, column_count);
                    if ($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) 
                    { 
                      $$ = (struct value) {FLOAT_TYPE, .val.fval = ($1.type == INT_TYPE ? $1.val.ival : $1.val.fval) + ($3.type == INT_TYPE ? $3.val.ival : $3.val.fval)}; 
                    } 
                    else 
                    { 
                      $$ = (struct value) {INT_TYPE, .val.ival = $1.val.ival + $3.val.ival}; 
                    } 
                  }
 | E '-' E        { 
                    printf("\tYACC(%d, %d)\tE: E - E\n", line_count, column_count);
                    if ($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) 
                    { 
                      $$ = (struct value) {FLOAT_TYPE, .val.fval = ($1.type == INT_TYPE ? $1.val.ival : $1.val.fval) - ($3.type == INT_TYPE ? $3.val.ival : $3.val.fval)}; 
                    } 
                    else 
                    { 
                      $$ = (struct value) {INT_TYPE, .val.ival = $1.val.ival - $3.val.ival}; 
                    } 
                  }
 | E '*' E        { 
                    printf("\tYACC(%d, %d)\tE: E * E\n", line_count, column_count);
                    if ($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) 
                    { 
                      $$ = (struct value) {FLOAT_TYPE, .val.fval = ($1.type == INT_TYPE ? $1.val.ival : $1.val.fval) * ($3.type == INT_TYPE ? $3.val.ival : $3.val.fval)}; 
                    } 
                    else 
                    { 
                      $$ = (struct value) {INT_TYPE, .val.ival = $1.val.ival * $3.val.ival}; 
                    } 
                  }
 | E '/' E        { 
                    printf("\tYACC(%d, %d)\tE: E / E\n", line_count, column_count);
                    if ($1.type == FLOAT_TYPE || $3.type == FLOAT_TYPE) 
                    { 
                      $$ = (struct value) {FLOAT_TYPE, .val.fval = ($1.type == INT_TYPE ? $1.val.ival : $1.val.fval) / ($3.type == INT_TYPE ? $3.val.ival : $3.val.fval)}; 
                    } 
                    else 
                    { 
                      $$ = (struct value) {INT_TYPE, .val.ival = $1.val.ival / $3.val.ival}; 
                    } 
                  }
 | '(' E ')'      { 
                    printf("\tYACC(%d, %d)\tE: (E)\n", line_count, column_count); 
                    $$ = $2; 
                  }
 | ID             { 
                    printf("\tYACC(%d, %d)\tE: ID(\"%s\")\n", line_count, column_count, $1);
                    struct nlist *np = lookup($1); 
                    if (np) 
                    { 
                      if (np->type == INT_TYPE) 
                      { 
                        $$ = (struct value) {INT_TYPE, .val.ival = np->value.ival}; 
                      } 
                      else 
                      { 
                        $$ = (struct value) {FLOAT_TYPE, .val.fval = np->value.fval}; 
                      } 
                    } 
                    else 
                    { 
                      yyerror("undefined variable"); 
                      $$ = (struct value) {INT_TYPE, .val.ival = 0}; 
                    } 
                  }
 | INT            { 
                    printf("\tYACC(%d, %d)\tE: INT(%d)\n", line_count, column_count, $1); 
                    $$ = (struct value) {INT_TYPE, .val.ival = $1}; 
                  }
 | FLOAT          { 
                    printf("\tYACC(%d, %d)\tE: FLOAT(%lf)\n", line_count, column_count, $1); 
                    $$ = (struct value) {FLOAT_TYPE, .val.fval = $1}; 
                  }
 ;

%%

int main(void) {
  while(yyparse() == 0)
    ;
  return 0;
}
