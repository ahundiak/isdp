/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							write.c
**	AUTHORS:						
**	CREATION DATE:					
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <sys/types.h>
#include "tpg.h"

/*
**	FUNCTION PROTOTYPES
*/
#define write_c
#include "write.prt"
#include "generate.prt"
#include "sys.prt"


/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern void write_data_list(
	FILE *fp,
	data_s *data)
{
	for (; data; data = data->next)
	{
		my_fputs(data->name, fp);
		if (data->next)
			my_fputs(" ", fp);
	}
	my_fputs("\n", fp);
}

extern void write_rule_list(
	FILE	*fp,
	rule_s	*rule)
{
	my_fputs(":\t", fp);
	for (; rule; rule = rule->next)
	{
		write_data_list(fp, rule->data);
		if (rule->next)
			my_fputs("|\t", fp);
	}
	my_fputs(";\n", fp);
}

extern void write_prod(
	FILE *fp,
	prod_s *prod)
{
	my_fprintf(fp, "%s\n", prod->name);
	write_rule_list(fp, prod->rule);
}

extern void write_prod_list(
	FILE *fp)
{
	prod_s *prod;

	for(prod = prod_list; prod; prod = prod->next)
	{
		write_prod(fp, prod);
		if (prod->next)
			my_fputs("\n", fp);
	}
}

extern void write_header(
	FILE *fp,
	char *filename)
{
	char *ptr;

	my_fputs("/*\n", fp);
	my_fputs("------------------------------------------------------------------------\n", fp);
	my_fputs("\n", fp);

	if ((ptr = strrchr(filename, PATH_CHAR)) != NULL)
		ptr++;
	else
		ptr = filename;
	my_fprintf(fp, "Name:\t\t\t\t\t\t\t\t%s\n", ptr);

	my_fputs("Authors:\t\t\t\t\t\t\tHAL9000\n", fp);
	my_fputs("\n", fp);
	my_fputs("------------------------------------------------------------------------\n", fp);
	my_fputs("*/\n", fp);
	my_fputs("\n", fp);
}
