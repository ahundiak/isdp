/*
**  Copyright 1993, Intergraph Corporation, All Rights Reserved
*/

/*
**
**		File name:	uld_sample3.rc
**		Purpose:	To demonstrate the functionality of RisUldDescriptor
**		CommandLine equivalence: 
**			risunload 	-mw -s schr table with var dfile data all
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
	risulddes.filemode = 'w';

	/* Assign number of schemas to be unloaded */
	risulddes.schema_count 		= 1;

	/* Allocate memory space to hold information concerning each schema */
	risulddes.schemas = 
		(risuldsch *) calloc(risulddes.schema_count,sizeof(risuldsch));
	
	/* Assign appropriate information concerning each schema */
	/* Schema 0 */
	strcpy(risulddes.schemas[0].schname,"schr");
	risulddes.schemas[0].select_mode = 'a'; 

	/* Call load function passing the address of the descriptor */
	if( RIS_unloader(&risulddes) == -1 )
		printf("Return Failure\n");

	/* Print the descriptor */
	RISuld_print_risulddes(&risulddes);
}
