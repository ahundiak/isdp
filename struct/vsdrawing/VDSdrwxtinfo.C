/*
	I/STRUCT
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
#include <stdlib.h>
#include <string.h>
#include "vsdrwmacros.h"
#include "macro.h"		/* For `macro_MAX_CHAR'		*/

static VSdrwMacInfo	*VS_Gp_drwMacInfo	= NULL,
			*VS_Gp_drwCurMacInfo	= NULL ;
/*----------------------------------------------------------------------------*/
int VDinit_from_drawing_setup __(( void )) {

	long	msg ;

	/*
	 * Scan "setup" file in search of
	 *	"extract as ... with ..., ..., ... ;"
	 * statements and collect the info in a liked list.
	 */
	VSdrwGetExtractionInfo( &msg, &VS_Gp_drwMacInfo ) ;

	if( msg & 1 ) {
		/*
		 * Set current pointer to beginning of linked list.
		 */
		msg =  TRUE ; VS_Gp_drwCurMacInfo = VS_Gp_drwMacInfo ;
	} else {
		/*
		 * Failed ! Reset everything.
		 */
		msg = FALSE ; VS_Gp_drwCurMacInfo = VS_Gp_drwMacInfo = NULL ;
	}

	return msg ;

} /* VDinit_from_drawing_setup */
/*----------------------------------------------------------------------------*/
int VDread_from_drawing_setup(	drwMacName, macDefName, feetNames, feetCount,
				sizeOfFeetArray )

char	drwMacName[macro_MAX_CHAR],	/* OUT : name of "drawing" macro   */
	macDefName[macro_MAX_CHAR],	/* OUT : name of macro in 3d model */
	*feetNames[] ;			/* OUT : name of feet to transfer  */
int	*feetCount,			/* OUT : count of feet to transfer */
	sizeOfFeetArray ; {		/* IN  : size of array 'feetNames' */

	VSdrwMacInfo	*i ;
	VSdrwAttrList	*a ;
	int		max ;

	*drwMacName	= '\0' ;
	*macDefName	= '\0' ;
	*feetCount	= 0 ;

	/*
	 * Starting the extraction of elements.
	 */
	VSdrwSetExtractionFlg( TRUE ) ;

	if( !VS_Gp_drwCurMacInfo ) {
		/*
		 * No more info.
		 */
		if( VS_Gp_drwMacInfo ) {
			VSdrwFreeExtractMacInfo( VS_Gp_drwMacInfo ) ;
			VS_Gp_drwMacInfo = NULL ;
		}
		return EOF ;
	}

	i = VS_Gp_drwCurMacInfo ; max = macro_MAX_CHAR - 1 ;

	/*
	 * This ( i->macDefName == NULL ) should not happen but we never know !
	 */
	if( i->macDefName ) {
		strncpy( macDefName, i->macDefName, max )[max] = '\0' ;
	} else {
		*macDefName = '\0' ;
	}

	/*
	 * This ( i->drwDefName == NULL ) may happen if there is no "extract"
	 * statement for some element in the "setup" file.
	 */
	if( i->drwMacName ) {
		strncpy( drwMacName, i->drwMacName, max )[max] = '\0' ;
	} else {
		*drwMacName = '\0' ;
	}

	for(	a = i->attrList	,  *feetCount = 0 ;
		a		&& *feetCount < sizeOfFeetArray ;
		a = a->next	, (*feetCount)++ ) {

			if( a->attrName ) {
				strncpy(	feetNames[(*feetCount)],
						a->attrName,
						max )[max] = '\0' ;
			} else {
				*feetNames[(*feetCount)] = '\0' ;
			}
	}

	/*
	 * Get ready for next call ...
	 */
	VS_Gp_drwCurMacInfo = VS_Gp_drwCurMacInfo->next ;

	return TRUE ;

} /* VDread_from_drawing_setup */
/*----------------------------------------------------------------------------*/
