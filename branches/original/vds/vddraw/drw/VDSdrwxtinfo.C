/*
	I/VDS	Copy.
*/
/*
	This file contains two functions called by the VDS command
	"Extract Drawing" and defined in VDS. They are overloaded when
	STRUCT.o is dynamically loaded. They allow to read specifications
	in the Drawing Extraction Setup file (remember that the "setup" file
	handling software is in I/STRUCT not I/VDS) and pass them over to
	the "Extract Drawing" command.

	The first function is VDinit_from_drawing_setup(), and is called once
	before any call to the second function VDread_from_drawing_setup() is
	made.

	In the first function VDinit_from_drawing_setup, the "setup" file is
	scanned for

		"extract as ... with ..., ..., ... ;" statements

	and the information is gathered in a linked list.

	When the second function is repetitively called, each element of
	the linked list is processed and the information it contains is
	returned. When the end of the linked list is reached then EOF
	is returned.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "v_drwmacros.h"
#include "v_dbgmacros.h"
#include "macro.h"		/* For `macro_MAX_CHAR'		*/

/*----------------------------------------------------------------------------*/
int VD_drw_init_from_drawing_setup (	setup,	drwMacInfo )

IGRchar		*setup ;	
VD_drwMacInfo	**drwMacInfo ; {

	long	msg ;

	/*
	 * Scan "setup" file in search of
	 *	"extract as ... with ..., ..., ... ;"
	 * statements and collect the info in a liked list.
	 */

	SetProc( VD_drw_init_from_drawing_setup ); Begin

	VD_drwGetExtractionInfo( &msg, setup, drwMacInfo ) ;

	if( msg & 1 ) {
		/*
		 * Set current pointer to beginning of linked list.
		 */
		msg =  TRUE ; 
	} else {
		/*
		 * Failed ! Reset everything.
		 */
		if( *drwMacInfo ) {
			VD_drwFreeExtractMacInfo( *drwMacInfo ) ;
			*drwMacInfo = NULL ;
		}
		msg = FALSE ;
	}

	End
	return msg ;

} /* VD_drw_init_from_drawing_setup */
/*----------------------------------------------------------------------------*/
