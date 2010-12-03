digit  [0-9]
letter [A-Za-z]
%{
    int count;
%}
%%
%{
  /* A comment */
%}
{letter}({letter}|{digit})*  { count++; printf("identifier: %s\n",yytext); }
(.|\n) ;
%%

int yywrap(void) { return 1; }

int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
    yylex();
    printf("number of identifiers = %d\n", count);
    return 0;
}
