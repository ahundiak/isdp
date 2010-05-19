
/* $Id: VDdrwatt2ext.C,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwatt2ext.C
 *
 * Description:
 *	Macro and attribute information for external use
 *
 * Dependencies:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	3/15/95		tlb		Add SetProc's
 *
 *************************************************************************/
/*
 * I/VDS	Copy
 */
#include <stdlib.h>
#include "msdef.h"
#include "v_drwdef.h"
#include "v_drwmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_ioproto.h"
#include "v_strngproto.h"
/*----------------------------------------------------------------------------*/
int VD_drwAddMacInfo( info, macDefName )

VD_drwMacInfo	**info ;
const char	*macDefName ; {

	/*
	 * If `*info' is NULL, this is the head of the list and the list is
	 * empty; otherwise add at the end of the linked list.
	 */
	if( !*info ) {
		if(    !( *info = _MALLOC( 1, VD_drwMacInfo ) )
		    || !( (*info)->macDefName = VD_strdup( macDefName ) ) )
			return 0 ;
		(*info)->drwMacName	= NULL ;
		(*info)->attrList	= NULL ;
		(*info)->next		= NULL ;
	} else {
		VD_drwMacInfo	*curr	= *info,
				*last	= curr,
				*new	= NULL ;
		while( curr ) {
			last = curr ; curr = curr->next ;
		}
		if(    !( new = _MALLOC( 1, VD_drwMacInfo ) )
		    || !( new->macDefName = VD_strdup( macDefName ) ) )
			return 0 ;
		new->drwMacName	= NULL ;
		new->attrList	= NULL ;
		new->next	= NULL ;
		last->next	= new ;
	}
	return 1 ;

} /* VD_drwAddMacInfo */
/*----------------------------------------------------------------------------*/
int VD_drwAddMacDrwName( info, drwMacName )

VD_drwMacInfo	*info ;
const char	*drwMacName ; {

	/*
	 * Add name of drawing macro for the last macro.
	 */
	VD_drwMacInfo	*curr	= info,
			*last	= curr ;
	while( curr ) {
		last = curr ; curr = curr->next ;
	}
	if( !( last->drwMacName = VD_strdup( drwMacName ) ) )
		return 0 ;
	return 1 ;

} /* VD_drwAddMacDrwName */
/*----------------------------------------------------------------------------*/
int VD_drwAddAttrToMacInfo( info, attrName ) 

VD_drwMacInfo	*info ;
const char	*attrName ; {

	/*
	 * Add attribute name to the attribute list of the last macro.
	 */
	VD_drwMacInfo	*curr	= info,
			*last	= curr ;
	while( curr ) {
		last = curr ; curr = curr->next ;
	}
	
	/*
	 * If `last->attrList' is NULL, this is the head of the list and the
	 * list is empty; otherwise add at the end of the linked list.
	 */
	if( !last->attrList ) {
		if(    !( last->attrList = _MALLOC( 1, VD_drwAttrList ) )
		    || !( last->attrList->attrName = VD_strdup( attrName ) ) )
		    	return 0 ;
		last->attrList->next = NULL ;
	} else {
		VD_drwAttrList	*Curr	= last->attrList,
				*Last	= Curr,
				*New	= NULL ;
		while( Curr ) {
			Last = Curr ; Curr = Curr->next ;
		}

		if(    !( New = _MALLOC( 1, VD_drwAttrList ) )
		    || !( New->attrName = VD_strdup( attrName ) ) )
			return 0 ;
		New->next	= NULL ;
		Last->next	= New ;
	}

	return 1 ;

} /* VD_drwAddAttrToMacInfo */
/*----------------------------------------------------------------------------*/
void VD_drwFreeExtractMacInfo( info )
	
VD_drwMacInfo	*info ; {

	VD_drwMacInfo	*i,
			*nexti ;
	VD_drwAttrList	*a,
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

} /* VD_drwFreeExtractMacInfo */
/*----------------------------------------------------------------------------*/
int VD_drwGetExtractionInfo( msg, setup, xinfo )
	
long		*msg ;
const	char	*setup ;
VD_drwMacInfo	**xinfo ; {

	long		sts ;
	GRname		filepath ;
	VD_drwMacInfo	*info = NULL ;
	VD_drwInputData	inp ;

        SetProc( VD_drwGetExtractionInfo); Begin
	*xinfo = NULL ;

	/*
	 * create relative path from product entry.
	 */
	if( setup ){
		sprintf( filepath, "%s/%s", VD_K_DRW_CONFIG_RELPATH, setup );
	}
	else{
		sprintf( filepath, "%s", VD_K_DRW_SETUP_RELPATH );
	}

	/*
	 * Look for Drawing Extraction config file, then open it.
	 */
	VD_drwInitStackOfInputFiles( &inp.inputFiles ) ;

	if( !VD_drwPushInputFile(	filepath,
					TRUE,
					&inp.inputFiles ) ) {
		*msg = MSFAIL ;
		goto wrapup ;
	}

	sts = vd_$drwInterpretConfigFile(	msg	= msg,
						input	= &inp,
						xinfo	= &info,
						output	= NULL ) ;

	if( sts != 0 ) {
		*msg = MSFAIL ;
#ifdef vdsDEBUG
		printf( "ERROR extracting macro info\n" ) ;
#endif
	} else {
#ifdef vdsDEBUG
		VD_drwMacInfo	*i ;
		VD_drwAttrList	*a ;
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
	VD_drwCloseInputFiles( &inp.inputFiles ) ;
	End
	return *msg & 1 ;

} /* VD_drwGetExtractionInfo */
/*----------------------------------------------------------------------------*/

