/* Do not alter this line: $Revision: 1.1.54.1 $ */
/*
** Syntax: program > output.sql
**
**	output to stdout
**	prompts to stderr
**	input from stdin
**
** This program generates statements of the form
**
**		create table tab??? (col??? integer, col??? integer, ... );
**	  or
**		drop table tab???;
**
** Table names always start at tab001 and run up as high as you wish.
** Column names always start at col001 and go up no higher than col254.
**
** If desired, "!date" will be put in for timing.
*/

#include <stdio.h>

#define ITEMS_PER_LINE	5

int tables;
int columns;
int timing = 0;
int create;
int drop;

void createtab(name)
char *name;
{
	int i,j;

	printf("create table %s (\n",name);

	for (i=1; i<=columns; )
	{
		for (j=0; i<=columns && j<ITEMS_PER_LINE; ++j,++i)
		{
			printf("col%03d integer",i);
			if (i != columns )
				printf(",");
		}
		if (i < columns)
			printf("\n");
	}
	printf(");\n");
}

void droptab(name)
char *name;
{
	printf("drop table %s;\n",name);
	
}

void getdata()
{
	char c;

	fprintf(stderr,
		"\nGenerate \"create table\" or \"drop table\" statements? (c/d) : ");
	fflush(stderr);
	fflush(stdin);
	scanf("%c",&c);
	drop =  (c == 'd' || c == 'D');
	fprintf(stderr, "\n  -- \"%s\" --\n", drop ? "DROP" : "CREATE" );
	create = !drop;
	
	fprintf(stderr,"\nHow many statements should I make?: ");
	fflush(stderr);
	scanf("%d",&tables);

	if (create)
	{
		fprintf(stderr,"\nHow many columns in each table?: ");
		fflush(stderr);
		scanf("%d",&columns);
		if (columns > 254)
		{
			columns = 254;
			fprintf(stderr, "\n  -- limit of 254 columns per table --\n");
		}
	}

	fprintf(stderr,"\nDo you want a \"!date\" put in for timing? (y/n): ");
	fflush(stderr);
	fflush(stdin);
	scanf("%c",&c);
	timing =  (c == 'y' || c == 'Y');
	fprintf(stderr, "\n  -- timing is %s --\n", timing ? "ON" : "OFF" );

	fprintf(stderr,"\nStatements for %d tables ",tables);
	if (create)
		fprintf(stderr,"of %d columns each ", columns);
	fflush(stderr);
}

void header(prog)
char *prog;
{
char c;
fprintf(stderr,"\n\nYou should be running this as \" %s > output \"\n",prog);
fprintf(stderr,"\nPress return to continue ...");
fflush(stderr);
scanf("%c",&c);
}

extern void main(argc,argp)
int argc;
char *argp[];
{
	int i;
	char	tabname[19];

	argc = argc;
	header(argp[0]);
	getdata();
	for (i=1; i<=tables; ++i)
	{
		sprintf(tabname,"tab%03d",i);
		if (timing)
			printf("!date\n");
		if (create)
			createtab(tabname);
		else
			droptab(tabname);
		fprintf(stderr,".");
		fflush(stderr);
	}
	if (timing)
		printf("!date\n");
	fprintf(stderr,"\n");
}
  
