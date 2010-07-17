/* $Id: VSmodusratt.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSmodusratt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSmodusratt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:45:22  pinnacle
# Created: ./vsapis/VSmodusratt.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSfeature ;

#include <stdio.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "VDSsymb_def.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */

/*----------------------------------------------------------------------------*/
long VSmodify_user_attribute( msg,
			      elemId,
			      attName,
			      attValue )

long			*msg ;
struct GRid		*elemId ;
char			*attName ;
char			*attValue ; {

	/*
	 * This function is interfaced by macro 'vs$modify_user_attribute'.
	 */

	long			sts ;
	char			loc_attName[1024],
				*p_name,
				*p_value ;

	SetProc( VSmodify_user_attribute ) ; Begin

	__DBGpr_obj( "Element", *elemId ) ;

#ifdef vsDEBUG
	if( attName )
		__DBGpr_str( "Attribute name", attName ) ;
	else
		__DBGpr_com( "No attribute name given" ) ;

	if( attValue )
		__DBGpr_str( "Attribute value", attValue ) ;
	else
		__DBGpr_com( "No attribute value given" ) ;
#endif

      	/*
	 * See if input arguments are valid.
	 */
	if( !attName & !attValue )
		vs$inv_arg() ;


	/*
	 * See if the attribute should be removed or modified.
	 */
	if( *attName & !attValue ) {
		// Remove
		strcpy( loc_attName, "!" ) ;
		strcat( loc_attName, attName ) ;
	} else	strcpy( loc_attName, attName ) ;

	/*
	 * Modify user attribute.
	 */
	p_name  = loc_attName ;
	p_value = attValue ;

	sts = om$send( msg	= message VSfeature.VSmodUsrAttributes( msg,
									1,
									&p_name,
									&p_value ),
		       senderid = NULL_OBJID,
		       targetid = elemId->objid,
		       targetos = elemId->osnum ) ;

	__CheckRC( sts, *msg, "VSfeature.VSmodUsrAttributes", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSmodify_user_attribute */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
