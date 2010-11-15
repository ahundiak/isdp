/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**
**		File name:	lod_sample1.rc
**		Purpose:	To demonstrate the functionality of RisLodDescriptor
**		CommandLine Equivalence:
**			risload -i ris.load	-s inf1 all 
**								-s inf2 all
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
	risloddes.filemode = 'w';
	strcpy(risloddes.mainfile,"ris.load");

	/* Assign number of schemas to be loaded */
	risloddes.schema_count = 2;

	/* Allocate memory space to hold information concerning each schema */
	risloddes.schemas = 
		(rislodsch *) calloc(risloddes.schema_count,sizeof(rislodsch));
	
	/* Assign appropriate information concerning each schema */
	/* Schema 0 */
	strcpy(risloddes.schemas[0].schname,"inf1");
	risloddes.schemas[0].select_mode = 'a'; 

	/* Schema 1 */
	strcpy(risloddes.schemas[1].schname,"inf2");
	risloddes.schemas[1].select_mode = 'a'; 

	/* Call load function passing the address of the descriptor */
	if( RIS_loader(&risloddes) == -1 )
		printf("Return Failure\n");

	/* Print the descriptor */
	RISlod_print_risloddes(&risloddes);
}
