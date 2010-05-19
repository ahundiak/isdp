/* $Id: ACheadxform.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / ACheadxform.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACheadxform.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation ACheader;

#include "AS_status.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "ndmacros.h"
#include "grerr.h"
#include "bserr.h"
#include "grsymdef.h"
#include "ASmsg.h"
#include "msmacros.h"

#define	AS_DEBUG

from	ACcpx_defn	import	ACgive_name;

from	ACmodel		import	ACdisconnect_head;

/* ************ MSG GRxform () ****************************************	*/

method GRxform( IGRlong *rc; struct GRmd_env *obj_dsenv; 
		IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid )

{
IGRlong		sts, msg;
IGRint		i;
IGRshort	new_type;
IGRdouble	new_mat[16];

	/*| initialization */
	*rc	= OM_S_SUCCESS;
/*^
	printf(" obj_dsenv : id/os = (%d/%d)\n", obj_dsenv->md_id.objid, obj_dsenv->md_id.osnum ); 
	pr_mat(" obj_mat", 4, 4, obj_dsenv->md_env.matrix);
	printf(" MAIDMX = %d; matrix_type = %d\n", MAIDMX, *matrix_type );
	pr_mat(" x mat", 4, 4, matrix );
*/

	if( me->STATE & ncpx_root ){

		if( *matrix_type != MAIDMX ){

			if( obj_dsenv->md_id.objid != NULL_OBJID ) {

				sts = om$send(	msg	 = message 
						GRgraphics.GRremwrng
							( &msg, obj_dsenv ),
						targetid = my_id );
			}

			sts = om$send(	msg	 = message GRowner.GRget_matrix(
							&msg,
							matrix_type,
							matrix,
							&new_type,
							new_mat ),
					targetid = my_id );
			as$status( sts = sts );

/*^			pr_mat(" new_mat ", 4, 4, new_mat ); */

			/*| set instance data */
			me->origin[0]	= new_mat[3];
			me->origin[1]	= new_mat[7];
			me->origin[2]	= new_mat[11];

			for( i=0; i<3; i++ ){

				me->matrix[i]	= new_mat[i];
				me->matrix[i+3]	= new_mat[i+4];
				me->matrix[i+6]	= new_mat[i+8];
			}

			if( obj_dsenv->md_id.objid != NULL_OBJID ) {

				/*| up date range */
				sts = om$send(	msg	 = message GRgraphics.GRaddwrng
							( &msg, obj_dsenv ),
						targetid = my_id );
				as$status( sts = sts );
			}

			/*| up date depencies */
			sts = om$send(	msg	 = message NDnode.NDchange_node
							( NULL ),
					targetid = my_id );
			as$status( sts = sts );

		}/*end diff MAIDMX*/

	} else {

		/*| send message */
		sts = om$send(	msg	 = message ACcpx.GRxform(
						rc,
						obj_dsenv,
						matrix_type,
						matrix,
						newobjid ),
				mode	 = OM_e_wrt_message,
				targetid = my_id );
		as$status( sts = sts );

	}/*end else root*/

	*newobjid = my_id;

return	OM_S_SUCCESS;
}

end implementation ACheader;

