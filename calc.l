%{
  #include "calc.h"
  #include "calc.tab.h"

  int line_count = 1;
  int column_count = 1;
%}

digit         [0-9]
letter        [a-zA-Z]
id            {letter}({letter}|{digit})*
int_num       {digit}+
float_num     {digit}+[\.]{digit}*
del           [\n]

%%

{id}          { 
                yylval.id = strdup(yytext);
                column_count += strlen(yytext);
                printf("\tLEX(%d, %d)\tid\t%s\n", line_count, column_count, yylval.id); 
                return ID; 
              }
{float_num}   { 
                yylval.fval = atof(yytext); 
                column_count += strlen(yytext);
                printf("\tLEX(%d, %d)\tf\t%lf\n", line_count, column_count, yylval.fval); 
                return FLOAT; 
              }
{int_num}     { 
                yylval.ival = atoi(yytext); 
                column_count += strlen(yytext);
                printf("\tLEX(%d, %d)\ti\t%d\n", line_count, column_count, yylval.ival); 
                return INT; 
              }
[\t\r ]+      { 
                column_count += strlen(yytext);
                printf("\tLEX(%d, %d)\tw\n", line_count, column_count); 
              }
{del}         { 
                line_count++;
                column_count = 1;
                printf("\tLEX(%d, %d)\tdel\n", line_count, column_count); 
                return yytext[0]; 
              }
.             { 
                column_count += strlen(yytext);
                printf("\tLEX(%d %d)\tch\t%c\n", line_count, column_count, yytext[0]); 
                return yytext[0]; 
              }

%%

int yywrap() {
  return 1;
}
