/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**
**		File name:	lod_sample3.rc
**		Purpose:	To demonstrate the functionality of RisLodDescriptor
**		CommandLine Equivalence:
**			risload -i ris.load	-s inf1 rename inf3 .inf3pass 
**										clear table with all 
**										view all 
**										index all
**										grant all
**
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

	/* Assign number of schemas to be loaded */
	risloddes.schema_count = 1;

	/* Allocate memory space to hold information concerning each schema */
	risloddes.schemas = 
		(rislodsch *) calloc(risloddes.schema_count,sizeof(rislodsch));
	
	/* Assign appropriate information concerning each schema */
	/* Schema 0 */
	strcpy(risloddes.schemas[0].schname,"inf1");
	risloddes.schemas[0].select_mode = 's'; /* why ?? */

	strcpy(risloddes.schemas[0].new_schname,"inf3");
	strcpy(risloddes.schemas[0].new_schpass,"inf3pass");

	/* Table Information */
	risloddes.schemas[0].tabinfo.select_mode = 'a';
	risloddes.schemas[0].tabinfo.with_data = 1;
	risloddes.schemas[0].tabinfo.ignore_create_error = 1;
	risloddes.schemas[0].tabinfo.clear_exist_data = 1; /* 'cause of this */

	/* View Information */
	risloddes.schemas[0].viewinfo.select_mode = 'a';

	/* Index Information */
	risloddes.schemas[0].indxtabinfo.select_mode = 'a';

	/* Grant Information */
	risloddes.schemas[0].granttabinfo.select_mode = 'a';

	/* Call load function passing the address of the descriptor */
	if( RIS_loader(&risloddes) == -1 )
		printf("Return Failure\n");

	/* Print the descriptor */
	RISlod_print_risloddes(&risloddes);
}
