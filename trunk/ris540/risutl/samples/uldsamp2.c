/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**
**		File name:	uld_sample2.rc
**		Purpose:	To demonstrate the functionality of RisUldDescriptor
**		CommandLine equivalence: 
**			risunload 	-s inf1 table with dfile data
**						employee "join emp_dept where ename = 'Hitesh Patel'"
**						view uniename uniename1
**						index emp_dept
**						grant inf2.project
**						-s inf5 .inf5pass all	
*/

/*
**	INCLUDES
*/
#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <malloc.h>
#include "rislduld.h"

extern void main()
{
	/* For where clause */
	char	wherebuffer[100];

	/* Define a descriptor of type risulddes */
	risulddes risulddes;

	/* Initialize the descriptor */
	memset((char *) &risulddes, 0, sizeof(risulddes));

	/* Assign necessary fields */
	risulddes.filemode = 'a';

	/* Assign number of schemas to be unloaded */
	risulddes.schema_count 		= 2;

	/* Allocate memory space to hold information concerning each schema */
	risulddes.schemas = 
		(risuldsch *) calloc(risulddes.schema_count,sizeof(risuldsch));
	
	/* Assign appropriate information concerning each schema */
	/* Schema 0 */
	strcpy(risulddes.schemas[0].schname,"inf1");
	risulddes.schemas[0].select_mode = 's'; 

	/* Table Information */
	risulddes.schemas[0].tabinfo.select_mode 		= 's';
	risulddes.schemas[0].tabinfo.with_data 			= 1;
	risulddes.schemas[0].tabinfo.separate_dfile		= 1;
	risulddes.schemas[0].tabinfo.table_count		= 1;
    risulddes.schemas[0].tabinfo.tables =
			(risuldtab *) calloc(risulddes.schemas[0].tabinfo.table_count,
								sizeof(risuldtab));
	strcpy(risulddes.schemas[0].tabinfo.tables[0].tabname,"employee");
	strcpy(wherebuffer,"join emp_dept where ename = 'Hitesh Patel'");
	risulddes.schemas[0].tabinfo.tables[0].whereclause = wherebuffer;

	/* View Information */
	risulddes.schemas[0].viewinfo.select_mode 		= 's';
	risulddes.schemas[0].viewinfo.view_count		= 2;
    risulddes.schemas[0].viewinfo.views =
			(risuldview *) calloc(risulddes.schemas[0].viewinfo.view_count,
								sizeof(risuldview));
	strcpy(risulddes.schemas[0].viewinfo.views[0].viewname,"uniename");
	strcpy(risulddes.schemas[0].viewinfo.views[1].viewname,"uniename1");

	/* Index Information */
	risulddes.schemas[0].indxtabinfo.select_mode 	= 's';
	risulddes.schemas[0].indxtabinfo.indxtab_count	= 1;
    risulddes.schemas[0].indxtabinfo.indxtabs =
			(risuldindx *) calloc(risulddes.schemas[0].indxtabinfo.indxtab_count, sizeof(risuldindx));
	strcpy(risulddes.schemas[0].indxtabinfo.indxtabs[0].tabname,"emp_dept");

	/* Grant Information */
	risulddes.schemas[0].granttabinfo.select_mode 		= 's';
	risulddes.schemas[0].granttabinfo.granttab_count	= 1;
    risulddes.schemas[0].granttabinfo.granttabs =
			(risuldgrant *) calloc(risulddes.schemas[0].granttabinfo.granttab_count, sizeof(risuldgrant));
	strcpy(risulddes.schemas[0].granttabinfo.granttabs[0].table_owner,"inf2");
	strcpy(risulddes.schemas[0].granttabinfo.granttabs[0].tabname,"project");


	/* Schema 1 */
	strcpy(risulddes.schemas[1].schname,"inf3");
	strcpy(risulddes.schemas[1].schpass,"inf3pass");
	risulddes.schemas[1].select_mode = 'a'; 


	/* Call load function passing the address of the descriptor */
	if( RIS_unloader(&risulddes) == -1 )
		printf("Return Failure\n");

	/* Print the descriptor */
	RISuld_print_risulddes(&risulddes);
}
