/* $Id: VDtxldri.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDtxldri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDtxldri.I,v $
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
# Revision 1.2  1995/11/20  15:14:04  pinnacle
# Replaced: vdannot/imp/VDtxldri.I for:  by tlbriggs for vds.240
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
 *	11/20/95	tlb		Remove overrideen method get_dim_parms
 *
 * -------------------------------------------------------------------*/

class implementation VDtxldr;

#include "AS_debug.h"
#include "AS_status.h"
#include "dimdef.h"
#include "VDSglobals.h"
#include "VDSannot.h"

#include <stdio.h>
#include <string.h>

#define		AS_DEBUG 1
#define		AN_ROOT_EXPN	3

extern double fabs();

from 	DMsrc	import DMgive_structure, DMgive_tangent;
from 	GRtext	import GRreplace_text;
from 	DMplan 	import give_info;
from	ACcpx	import ACfind_exp_temp_obj;
from	VDtxbox	import set_box_type;


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method GRgetobjinfo(
	IGRlong		  *msg;
	struct GRobj_info *info)
{
     *msg = MSSUCC;
     strcpy(info->type,"Text Expression with Leader");
     return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method NDmove_to_root(
	IGRlong		*msg;
	struct GRid	*src_grid;
	struct GRmd_env	*md_env)
{
	IGRint status;
	extern IGRboolean ASbroadcast_in_progress;

	status =
	om$send(msg = message DMtxldr.NDmove_to_root(
				msg, src_grid, md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
	as$status(action = RET_STATUS);
/*
        status =
        om$send(msg = message NDnode.NDchg_state(ND_DEGRADED, ND_DEGRADED),
                targetid = my_id);
        as$status(action = RET_STATUS);

        status =
        om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_DETACHED),
                p_chanselect = &ND_children,
                senderid = my_id);
        as$status(action = RET_STATUS);
 */
	return(OM_S_SUCCESS);
}
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
method gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	IGRpoint start_pt;
	IGRpoint end_pt;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRmd_env *md_env)
{
	IGRint status, rc, index;
	struct dim_ret_struct dim_str;

	/*| - Get environment parameters */

	status =
	om$send(msg = message DMannot.get_active_senv(par_senv),
			targetid = my_id);
	as$status(action = RET_STATUS);

	/*| - Get the dimension plane */
	status =
	om$send(msg = message DMplan.give_info(&rc, plan_info, md_env),
		targetid = list[DIM_ROOT_PLAN].objid,
		targetos = list[DIM_ROOT_PLAN].osnum);
	as$status(action = RET_STATUS);

	status =
	om$send(msg = message DMsrc.DMgive_structure(	&rc,
							ORIG_INFO,
							FALSE,
							&dim_str,
							md_env ),
		targetid = list[AN_ROOT_ELEM1].objid,
		targetos = list[AN_ROOT_ELEM1].osnum);
	as$status(action = RET_STATUS);

	math_v_equal(start_pt, dim_str.var.dm_ptdist.point);

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[4*index + 3] =
		plan_info->act_plan.matrix[4*index + 3] = start_pt[index];
	}

	return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method DMcompute_node(
	IGRlong *msg;
	IGRint cn_type;
	int count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct ret_struct ret_str;

	status =
	om$send(msg = message NDnode.NDgive_structure(msg, &ret_str, md_env),
		senderid = my_id,
		p_chanselect = &ND_father,
		from = AN_ROOT_EXPN, to = AN_ROOT_EXPN);
	as$status(action = RET_STATUS);
	as$status( sts = *msg, action = RET_STATUS );

	status =
	om$send(msg = message DMroot.replace_text(
				&rc,
				DIM_TEXT,
				(struct GRid *) NULL,
				md_env,
				strlen( ret_str.var.text_st.text_string ),
			        (IGRuchar *) ret_str.var.text_st.text_string ),
		targetid = my_id);
	as$status(action = RET_STATUS);
	as$status( sts = rc, action = RET_STATUS );

	status = om$send(msg = message DMtxldr.DMcompute_node(msg, cn_type,
						count, list, md_env),
			 targetid = my_id,
			 mode = OM_e_wrt_message);
        as$status(action = RET_STATUS);
	as$status( sts = *msg, action = RET_STATUS );

	return( status );
}

end implementation VDtxldr;
