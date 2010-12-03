%{
    #include "calc.tab.h"
    #include <stdlib.h>
    void yyerror(char *);
    extern int yylval;
%}

%%

[a-z]       {
                /* Variables */
                yylval = *yytext - 'a';
                return VARIABLE;
            }

[0-9]+      {
                /* Integers */
                yylval = atoi(yytext);
                return INTEGER;
            }

[-+()=/*\n] { return *yytext; /* Operators */ }

[ \t]       ; /* skip whitespace */

.           yyerror("invalid character"); /* Everythng else */

%%

int yywrap(void) {
    return 1;
}
