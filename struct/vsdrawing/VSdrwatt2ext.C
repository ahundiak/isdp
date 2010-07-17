/* $Id: VSdrwatt2ext.C,v 1.2 2001/02/28 22:06:35 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:	vsdrawing/VSdrwatt2ext.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdrwatt2ext.C,v $
 *	Revision 1.2  2001/02/28 22:06:35  ramarao
 *	Fixed TR# 4785.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.4  1998/01/29  22:23:40  pinnacle
 * ah
 *
 *
 * History:
 *	MM/DD/YY  AUTHOR  DESCRIPTION
 *	01/29/98  ah      Got rid of global VDdraw_setup_Name
 * -------------------------------------------------------------------*/

#include <stdlib.h>
#include "OMmacros.h"
#include "msdef.h"
#include "vsdrwdef.h"
#include "vsdrwmacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
#include "vsstrngproto.h"

/*----------------------------------------------------------------------------*/
int VSdrwAddMacInfo( info, macDefName )

VSdrwMacInfo	**info ;
const char	*macDefName ; {

	/*
	 * If `*info' is NULL, this is the head of the list and the list is
	 * empty; otherwise add at the end of the linked list.
	 */
	if( !*info ) {
		if(    !( *info = _MALLOC( 1, VSdrwMacInfo ) )
		    || !( (*info)->macDefName = VSstrdup( macDefName ) ) )
			return 0 ;
		(*info)->drwMacName	= NULL ;
		(*info)->attrList	= NULL ;
		(*info)->next		= NULL ;
	} else {
		VSdrwMacInfo	*curr	= *info,
				*last	= curr,
				*new	= NULL ;
		while( curr ) {
			last = curr ; curr = curr->next ;
		}
		if(    !( new = _MALLOC( 1, VSdrwMacInfo ) )
		    || !( new->macDefName = VSstrdup( macDefName ) ) )
			return 0 ;
		new->drwMacName	= NULL ;
		new->attrList	= NULL ;
		new->next	= NULL ;
		last->next	= new ;
	}
	return 1 ;

} /* VSdrwAddMacInfo */
/*----------------------------------------------------------------------------*/
int VSdrwAddMacDrwName( info, drwMacName )

VSdrwMacInfo	*info ;
const char	*drwMacName ; {

	/*
	 * Add name of drawing macro for the last macro.
	 */
	VSdrwMacInfo	*curr	= info,
			*last	= curr ;
	while( curr ) {
		last = curr ; curr = curr->next ;
	}
	if( !( last->drwMacName = VSstrdup( drwMacName ) ) )
		return 0 ;
	return 1 ;

} /* VSdrwAddMacDrwName */
/*----------------------------------------------------------------------------*/
int VSdrwAddAttrToMacInfo( info, attrName ) 

VSdrwMacInfo	*info ;
const char	*attrName ; {

	/*
	 * Add attribute name to the attribute list of the last macro.
	 */
	VSdrwMacInfo	*curr	= info,
			*last	= curr ;
	while( curr ) {
		last = curr ; curr = curr->next ;
	}
	
	/*
	 * If `last->attrList' is NULL, this is the head of the list and the
	 * list is empty; otherwise add at the end of the linked list.
	 */
	if( !last->attrList ) {
		if(    !( last->attrList = _MALLOC( 1, VSdrwAttrList ) )
		    || !( last->attrList->attrName = VSstrdup( attrName ) ) )
		    	return 0 ;
		last->attrList->next = NULL ;
	} else {
		VSdrwAttrList	*Curr	= last->attrList,
				*Last	= Curr,
				*New	= NULL ;
		while( Curr ) {
			Last = Curr ; Curr = Curr->next ;
		}

		if(    !( New = _MALLOC( 1, VSdrwAttrList ) )
		    || !( New->attrName = VSstrdup( attrName ) ) )
			return 0 ;
		New->next	= NULL ;
		Last->next	= New ;
	}

	return 1 ;

} /* VSdrwAddAttrToMacInfo */
/*----------------------------------------------------------------------------*/
void VSdrwFreeExtractMacInfo( info )
	
VSdrwMacInfo	*info ; {

	VSdrwMacInfo	*i,
			*nexti ;
	VSdrwAttrList	*a,
			*nexta ;

	i = info ;
	while( i ) {
		_FREE( i->macDefName ) ;
		_FREE( i->drwMacName ) ;

		a = i->attrList ;
		while( a ) {
			_FREE( a->attrName ) ;
			nexta = a->next ;
			_FREE( a ) ;
			a = nexta ;
		}
		nexti = i->next ;
		_FREE( i ) ;
		i = nexti ;
	}

} /* VSdrwFreeExtractMacInfo */
/*----------------------------------------------------------------------------*/
int VSdrwGetExtractionInfo( msg, xinfo ) long *msg ; VSdrwMacInfo **xinfo ; {

	long		sts ;
	VSdrwMacInfo	*info = NULL ;
	VSdrwInputData	inp ;

  IGRchar setupName[128];

	*xinfo = NULL ;

	/*
	 * Look for Drawing Extraction config file, then open it.
	 */
	VSdrwInitStackOfInputFiles( &inp.inputFiles ) ;


/**********   Read The Setup File     ********/

        VDdrwGetSetupFileName(setupName);
        if (strlen(setupName) == 0) strcpy(setupName,"setup");

	if( !VSdrwPushInputFile(	setupName,
					TRUE,
					&inp.inputFiles ) ) {
		*msg = MSFAIL ;
		goto wrapup ;
	}

        sts = VSdrwExecConfigAddFunctions();
        if ( !(1 & sts)) goto wrapup;

	sts = vs$drwInterpretConfigFile(	msg	= msg,
						input	= &inp,
						xinfo	= &info,
						output	= NULL ) ;
	if( sts != 0 ) {
		*msg = MSFAIL ;
#ifdef vsDEBUG
		printf( "ERROR extracting macro info\n" ) ;
#endif
	} else {
#ifdef vsDEBUG
		VSdrwMacInfo	*i ;
		VSdrwAttrList	*a ;
		printf( "START DUMP\n" ) ;
		for( i = info ; i ; i = i->next ) {
			printf( "Mac <%s> drawing <%s>\n",
				i->macDefName ? i->macDefName : "NULL",
				i->drwMacName ? i->drwMacName : "NULL" ) ;
			for( a = i->attrList ; a ; a = a->next ) {
				printf( "\t\t<%s>\n",
				a->attrName ? a->attrName : "NULL" ) ;
			}
		}
		printf( "END DUMP\n" ) ;
#endif

		*xinfo = info ;
	}

	wrapup :
		VSdrwExecConfigRmFunctions();
		VSdrwCloseInputFiles( &inp.inputFiles ) ;

		return *msg & 1 ;

} /* VSdrwGetExtractionInfo */
/*----------------------------------------------------------------------------*/

