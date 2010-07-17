/* $Id: VSjnputjoint.I,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjnputjoint.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjnputjoint.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/11/14  13:08:50  pinnacle
# Replaced: vsjoint/VSjnputjoint.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSjoint ;

#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
method VSputJoint(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env	*otherFeature ;
			struct GRobj_env	*jnCurve ;
			VSdspRep		jointRep ;
			struct GRvg_construct	*cst ;
			char			*dir ;
			struct GRid		*joint  ) {

	SetProc( VSjoint_VSputJoint ) ; Begin ; __DBGpr_me() ;

	/*
	 * We do not put joints between joints.
	 */
	joint->objid = NULL_OBJID ;
	*msg		= MSSUCC ;

	End
	return OM_S_SUCCESS ;

} /* method VSputJoint */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;

