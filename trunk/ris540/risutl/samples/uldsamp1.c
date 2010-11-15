/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**
**		File name:	uld_sample1.rc
**		Purpose:	To demonstrate the functionality of RisUldDescriptor
**		CommandLine Equivalence:
**			risunload -o ris.dmp	-s inf1 all
**									-s inf2 all
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
	/* Define a descriptor of type risulddes */
	risulddes risulddes;

	/* Initialize the descriptor */
	memset((char *) &risulddes, 0, sizeof(risulddes));

	/* Assign necessary fields */
	risulddes.filemode = 'a';
	strcpy(risulddes.mainfile,"ris.dmp");

	/* Assign number of schemas to be unloaded */
	risulddes.schema_count = 2;

	/* Allocate memory space to hold information concerning each schema */
	risulddes.schemas = 
		(risuldsch *) calloc(risulddes.schema_count,sizeof(risuldsch));
	
	/* Assign appropriate information concerning each schema */
	/* Schema 0 */
	strcpy(risulddes.schemas[0].schname,"inf1");
	risulddes.schemas[0].select_mode = 'a'; 

	/* Schema 1 */
	strcpy(risulddes.schemas[1].schname,"inf2");
	risulddes.schemas[1].select_mode = 'a'; 

	/* Call unload function passing the address of the descriptor */
	if( RIS_unloader(&risulddes) == -1 )
		printf("Return Failure\n");


	/* Print the descriptor */
	/*
	RISuld_print_risulddes(&risulddes);
	*/
}
