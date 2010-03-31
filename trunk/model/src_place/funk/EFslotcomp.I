/* ###################   APOGEE COMPILED   ################## */
class implementation ECplslot;

#include <stdio.h>
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igr.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "EMSmsgdef.h"
#include "EMSfeadef.h"
#include "emserr.h"
#include "bserr.h"

# define BLIND		3
# define ERR		-1

from GRvg	import GRgetrang;

IGRlong	EFcomp_slot_depth(EMmsg, depth_type, surfs_info, active_GRid, slot)

IGRlong			*EMmsg;
IGRushort 	*depth_type;
struct	GRlc_info	*surfs_info;
struct	GRid		*active_GRid;
struct	EMSslot		*slot;

/*
DESCRIPTION:

This method calculates the depth vector and point for the slot.

VARIABLES:

IGRlong	 *EMmsg		Output	Completion code.
IGRshort *depth_type  	Input	slot depth indicator.
GRlc_info  *surfs_info	Input	surfaces information.
struct GRid *active_GRid Input	active state solid id.
struct slot *slot	I/O	relative information of slot.

History:

    Tapadia - 08/28/91    Creation date
*/

{
	IGRboolean  	world, stat_func;
	IGRint  	point_size;
	IGRlong  	sts, msg_loc;
	IGRdouble  	check_dir;
	IGRpoint 	better_line[2];
	GRrange   	range;
	extern IGRboolean  rlw_get_better_line();

	*EMmsg = EMS_S_Success;
	point_size = sizeof(IGRpoint);
	world = TRUE;

	/* If the slot depth is not blind, compute the axis extents */

	if(*depth_type != BLIND) {
		IGRdouble  vec[3];
		struct IGRline  line;
		extern IGRdouble  BSdistptpt();

		sts = om$send(msg = message GRvg.GRgetrang(&msg_loc, 
		    		&surfs_info[2].module_info.md_env.matrix_type, 
		    		surfs_info[2].module_info.md_env.matrix, 
		    		&world, range),
		    	senderid = NULL_OBJID,
		    	targetid = active_GRid->objid,
		    	targetos = active_GRid->osnum);

		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		vec[0] = slot->axis_pts[0][0] + slot->axis_vec[0];
		vec[1] = slot->axis_pts[0][1] + slot->axis_vec[1];
		vec[2] = slot->axis_pts[0][2] + slot->axis_vec[2];
		line.point1 = slot->axis_pts[0];
		line.point2 = vec;

		stat_func = rlw_get_better_line(range, &line,better_line,
			&msg_loc);
		EMerr_hndlr(!(1&sts&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

		vec[0] = better_line[1][0] - better_line[0][0];
		vec[1] = better_line[1][1] - better_line[0][1];
		vec[2] = better_line[1][2] - better_line[0][2];

		/* check the direction of axis vector */

		check_dir = vec[0] * slot->axis_vec[0] + vec[1] * 
			slot->axis_vec[1] + vec[2] * slot->axis_vec[2];

		if(check_dir < 0) OM_BLOCK_MOVE(better_line[0], 
			slot->axis_pts[1], point_size);
		else 	OM_BLOCK_MOVE(better_line[1], slot->axis_pts[1], 
			point_size);

		slot->axis_pts[1][0] += slot->axis_vec[0] * 0.01;
		slot->axis_pts[1][1] += slot->axis_vec[1] * 0.01;
		slot->axis_pts[1][2] += slot->axis_vec[2] * 0.01;
	}
	else { 	/* for a blind slot */
		slot->axis_pts[1][0] = slot->axis_pts[0][0] + slot->depth * 
			slot->axis_vec[0];
		slot->axis_pts[1][1] = slot->axis_pts[0][1] + slot->depth * 
			slot->axis_vec[1];
		slot->axis_pts[1][2] = slot->axis_pts[0][2] + slot->depth * 
			slot->axis_vec[2];
	}

wrapup:
	if(msg_loc != ERR)	return(EMS_S_Success);
	else return(EMS_E_Success);

} /* EFcomp_slot_depth */

end implementation ECplslot;
