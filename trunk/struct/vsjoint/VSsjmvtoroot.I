/* $Id: VSsjmvtoroot.I,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsjoint/VSsjmvtoroot.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSsjmvtoroot.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/05/22  19:02:18  pinnacle
# Created: vsjoint/VSsjmvtoroot.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation
***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSsrcJoint ;

#include "nddef.h"
#include "ndmacros.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
method NDmove_to_root(	long		*msg ;
			struct GRid	*src ;
			struct GRmd_env	*myEnv ) {

	long			sts ;
	struct 	GRid		MY_GRid ;

	/*
	 * This object cannot live without parents: move-to-root means delete:
	 * undisplay yourself then put yourself on the delete-batch queue.
	 */
	MY_GRid.objid = my_id ;
	MY_GRid.osnum = OM_Gw_current_OS ;

	sts = vs$bulk_display( 		count  = 1,
                                        dpmode = GRbe,
                                        grids  = &MY_GRid,
					theEnv = myEnv );

	sts = nd$wait_batch(	type 		= GR_DELETED, 
				l_object 	= &MY_GRid, 
				nb_obj 		= 1 ) ;
	*msg = MSSUCC ;
	return sts ;

} /* NDmove_to_root */
/*----------------------------------------------------------------------------*/

end implementation VSsrcJoint;
