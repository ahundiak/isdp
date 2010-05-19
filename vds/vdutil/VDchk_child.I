/* $Id: VDchk_child.I,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil/VDchk_child.I
 *
 * Description:
 *		When generated a make_source of a object in a defined 
 *		context, we check if the child object is already 
 *		created. When this is the case, we return the existing
 *		child object and we can generate a recompute.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDchk_child.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/01  17:57:58  pinnacle
# Replaced: vdutil/VDchk_child.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/02/15  18:11:58  pinnacle
# Created: vdutil/VDchk_child.I by azuurhou r#
# rno
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/14/95	adz		creation date
 * -------------------------------------------------------------------*/

/*
ABSTRACT : 
	I/VDS

CHANGE HISTORY
	Function VDchk_child_on_class 
*/

class implementation Root;

#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "asdef.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "v_dbgmacros.h"
#include "v_miscmacros.h"

extern	GRclassid	OPP_ACpretend_class_id;

from	NDnode		import NDget_objects;

VDchk_child_on_class( msg, parent, source, class, child )
IGRlong			*msg ;
struct	GRid		*parent ;
struct	GRid		*source ;
IGRchar			*class ;
struct	GRid		*child ;
{
IGRint			sts = OM_S_SUCCESS ,
			count ,
			found ,
			i ;
GRname			className ;
struct	GRid		list[100] ;

	SetProc( VDchk_child_on_class ); Begin

	*msg	= MSFAIL ;
	found	= 0 ;
	count	= 100;

	if( child )	child->objid = NULL_OBJID ;

	if( ! source || ! class ) goto wrapup ;

	if( ! parent ){
		__DBGpr_com(" No Parent reference ");
	}

#ifdef	vdsDEBUG
	if( parent ) VD_ShowObj( parent );
	VD_ShowObj( source );
#endif

	if( ! vd_$is_ancestry_valid(	object	= source,
					classid	= OPP_ACpretend_class_id )){
		/*
		 * No Pretend object found.
		 */
		if( ! IF_EQ_GRID( *source, *parent )){
			goto wrapup ;
		}
	}

	__DBGpr_com(" FOUND an Pretend OBJECT ");

	sts =
	_VD_SEND_OBJN(	*source,
			NDnode.NDget_objects(	ND_CHILDREN,
						list,
						count,
						NULL,
						0,
						count,
						&count ));
	__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	__DBGpr_int(" Get_objects ", count );

	/*
	 * check for the classname of the child object.
	 */
	for ( i=0 ; i< count ; i++ ){
	  
	  sts =
	  om$get_classname(	objid   = list[i].objid,
				osnum	= list[i].osnum,
				classname = className  );

#ifdef	DEBUG
	  VD_ShowObj( & list[i] );
#endif

	  if( strcmp( className, class ) == 0 ){

	    if( child ) *child = list[i] ;

	    __DBGpr_obj(" OBJECT ", list[i] );
	    found ++ ;
	  }
	}

	/*
	 * check if more objects are found.
	 */
	*msg = ( found == 1 ) ? MSSUCC : MSFAIL ;

	wrapup:
		__DBGpr_int(" FOUND ....", found );	
		End ;
		return ( found ) ;
}

end implementation Root;

