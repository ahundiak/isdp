%{
	int template_count = 0;
	int template_size = 0;
	char **template = NULL;
%}

SPACES	[ \t\n]+
OSPACES	[ \t\n]*
ID	[a-zA-Z_][a-zA-Z_0-9$]*

%%
^#template{SPACES}.*	{
				char *tname;

				tname = &yytext[9];
				while (isspace(*tname))
					tname++;
				copy_template(tname);
			}
.			ECHO;
%%

yywrap()
{
	return(1);
}

main(argc, argv)
int argc;
char *argv[];
{
	int i;
	char fname[128];
	char errmsg[128];

	if (argc != 2)
	{
		fprintf(stderr, "Usage: %s <.T file (no extension)>\n", argv[0]);
		exit(1);
	}

	sprintf(fname, "%s.T", argv[1]);
	yyin = fopen(fname, "r");
	if (yyin == NULL)
	{
		sprintf(errmsg, "%s: Cannot open <%s>\n", argv[0], fname);
		perror(errmsg);
		exit(2);
	}

	sprintf(fname, "%s.S", argv[1]);
	yyout = fopen(fname, "w");
	if (yyout == NULL)
	{
		sprintf(errmsg, "%s: Cannot open <%s>\n", argv[0], fname);
		perror(errmsg);
		exit(3);
	}

	fprintf(yyout, "class specification %s (1:0) of %s;\n",
			argv[1], argv[1]);

	yylex();

	if (template_count == 0)
	{
		fprintf(stderr, "%s: No template definitions in file\n",
			argv[0]);
		exit(4);
	}

	fprintf(yyout, "instance %s {\n", argv[1]);
	for (i=0; i<template_count; i++)
		fprintf(yyout, "\t%s;\n", template[i]);

	fprintf(yyout, "};\n\nend specification %s;\n\n", argv[1]);
	fclose(yyin);
	fclose(yyout);
	exit(0);
}

char *copy_string(s)
char *s;
{
	char *c;

	c = (char *)malloc(strlen(s) + 1);
	strcpy(c, s);
	return(c);
}

copy_template(t)
char *t;
{
	if (template_size <= template_count)
	{
		if (template_size)
			template = (char **)realloc(template,
				   (template_size + 10) * sizeof(char *));
		else	template = (char **)malloc(10 * sizeof(char *));

		template_size += 10;
	}

	template[template_count++] = copy_string(t);
	return(1);
}
