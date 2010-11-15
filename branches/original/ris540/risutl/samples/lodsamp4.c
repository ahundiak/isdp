/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**
**		File name:	lod_sample4.rc
**		Purpose:	To demonstrate the functionality of RisLodDescriptor
**		CommandLine Equivalence:
**			risload -i ris.load -c5	-s	inf1 new table with data emp_dept 
										index employee
										grant inf2.project
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
	/* Define a descriptor of type risloddes */
	risloddes risloddes;

	/* Initialize the descriptor */
	memset((char *) &risloddes, 0, sizeof(risloddes));

	/* Assign necessary fields */
	strcpy(risloddes.mainfile,"ris.load");
	risloddes.commit_interval	= 5;

	/* Assign number of schemas to be loaded */
	risloddes.schema_count 		= 1;

	/* Allocate memory space to hold information concerning each schema */
	risloddes.schemas = 
		(rislodsch *) calloc(risloddes.schema_count,sizeof(rislodsch));
	
	/* Assign appropriate information concerning each schema */
	/* Schema 0 */
	strcpy(risloddes.schemas[0].schname,"inf1");
	risloddes.schemas[0].select_mode = 's'; 

	/* Table Information */
	risloddes.schemas[0].tabinfo.select_mode 		= 's';
	risloddes.schemas[0].tabinfo.with_data 			= 1;
	risloddes.schemas[0].tabinfo.ignore_create_error= 0;
	risloddes.schemas[0].tabinfo.table_count 		= 1;
    risloddes.schemas[0].tabinfo.tables =
			(rislodtab *) calloc(risloddes.schemas[0].tabinfo.table_count,
								sizeof(rislodtab));
	strcpy(risloddes.schemas[0].tabinfo.tables[0].tabname,"emp_dept");

	/* View Information */
	risloddes.schemas[0].viewinfo.select_mode 			= 'n';

	/* Index Information */
	risloddes.schemas[0].indxtabinfo.select_mode 		= 's';
	risloddes.schemas[0].indxtabinfo.indxtab_count 		= 1;
    risloddes.schemas[0].indxtabinfo.indxtabs =
			(rislodindx *) calloc(risloddes.schemas[0].indxtabinfo.indxtab_count,sizeof(rislodindx));
	strcpy(risloddes.schemas[0].indxtabinfo.indxtabs[0].tabname,"employee");


	/* Grant Information */
	risloddes.schemas[0].granttabinfo.select_mode 		= 's';
	risloddes.schemas[0].granttabinfo.granttab_count 	= 1;
    risloddes.schemas[0].granttabinfo.granttabs =
			(rislodgrant *) calloc(risloddes.schemas[0].granttabinfo.granttab_count,sizeof(rislodgrant));
	strcpy(risloddes.schemas[0].granttabinfo.granttabs[0].table_owner,"inf2");
	strcpy(risloddes.schemas[0].granttabinfo.granttabs[0].tabname,"project");


	/* Call load function passing the address of the descriptor */
	if( RIS_loader(&risloddes) == -1 )
		printf("Return Failure\n");

	/* Print the descriptor */
	RISlod_print_risloddes(&risloddes);
}
