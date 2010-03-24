%{
#include "stdio.h"

int parflag = 0;
int parcount;
char *parlist;
char *name;
%}

%%
^PARENT			parflag = 1;
[_a-zA-Z0-9]+		if (parflag)
			{
				name = &parlist[16 * parcount];
				strcpy(name, yytext);
				parcount++;
				parflag = 0;
			}
\n			;
.			;
%%

yywrap()
{
	return(1);
}

load_parents(filename, list, count)
char *filename;
char *list;
int  *count;
{
	yyin = fopen(filename, "r");
	if (yyin == NULL)
	{
		fprintf(stderr, "Cannot open class definition file %s\n", filename);
		return(0);
	}

	parflag = 0;
	parcount = 0;
	parlist  = list;
	yylex();
	*count = parcount;
	fclose(yyin);
	return(1);
}

