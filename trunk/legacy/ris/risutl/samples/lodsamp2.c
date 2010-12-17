/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**
**		File name:	lod_sample2.rc
**		Purpose:	To demonstrate the functionality of RisLodDescriptor
**		CommandLine Equivalence:
**			risload -i ris.load -c5	-s inf1 new table with data dept view uniename
**									-s inf3 .inf3pass all
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
	risloddes.schema_count 		= 2;

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
	strcpy(risloddes.schemas[0].tabinfo.tables[0].tabname,"dept");

	/* View Information */
	risloddes.schemas[0].viewinfo.select_mode 		= 's';
	risloddes.schemas[0].viewinfo.view_count 		= 1;
    risloddes.schemas[0].viewinfo.views =
			(rislodview *) calloc(risloddes.schemas[0].viewinfo.view_count,
								sizeof(rislodview));
	strcpy(risloddes.schemas[0].viewinfo.views[0].viewname,"uniename");

	/* Index Information */
	risloddes.schemas[0].indxtabinfo.select_mode = 'a';

	/* Grant Information */
	risloddes.schemas[0].granttabinfo.select_mode = 'a';

	/* Schema 1 */
	strcpy(risloddes.schemas[1].schname,"inf3");
	strcpy(risloddes.schemas[1].schpass,"inf3pass");
	risloddes.schemas[1].select_mode = 'a'; 


	/* Call load function passing the address of the descriptor */
	if( RIS_loader(&risloddes) == -1 )
		printf("Return Failure\n");

	/* Print the descriptor */
	RISlod_print_risloddes(&risloddes);
}
