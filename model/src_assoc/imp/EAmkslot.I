/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslslotfea;

%safe
#include <math.h>
%endsafe
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "bserr.h"
#include "bsparameters.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSas.h"
#include "EMSasfeatdef.h"
#include "EMSasnucdef.h"
#include "EMSconstruct.h"
#include "EMSdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsptlnplan.h"

#define THR_ALL 	0
#define THR_UNTIL 	1
#define THR_NEXT 	2
#define BLIND 		3

from EMSsubbs import EMget_unit_norm;
extern OMuword OPP_GRcompcurve_class_id;

method EMconstruct_associative(IGRlong *EMmsg; IGRushort options;
		GRobjid  old_objid; IGRint num_par; IGRchar *parent_info;
		IGRint type; IGRchar *recomp_info; 
		struct GRvg_construct *construct_list)

/*****************************************************************
Description
 This method does the actual construction of slot

Arguments
Input
  options: ubiquitous argument. Currently not supported and is set to NULL.
  num_par : number of parents.
  list : GRid of parents.
  type : Type to interpret the recomputation information.
  recomp_info: Recomputation information. 
  construct_list: construction information.

Output
 EMmsg: Completion code.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

Recomputation informaton for feature slot:
 OMuint surface; Surface on which slot was placed.

Objects connected on the parent channel:
 Profile, depth or surfaces on which slot was made.

History
DLB      4/02/92 - Dont disconnect components if failure but in recompute.
		  	TR92n2956
Tapadia  01/06/92 - Support for closed profile
Tapadia  08/20/91 - Creation of associativity slot feature

Sudha   06/01/93    modified to handle BSprototype headers
*******************************************************************/

{
	IGRlong 	status, buf_size, om_stat;
	union 		EMSparent_info *roots = NULL;
	IGRuint 	*root_type = NULL, surf_par, root_count; 
	IGRint 		i, j, index = 0, num_slot, num_pts, rcode, comp_count; 
	IGRboolean  	is_dir_rev, is_pro_nor_rev, is_closed, is_comp, 
			recompute;
	struct GRid 	my_GRid, start_surf_GRid, new_prof_id;
	IGRpoint	*cur_pts = NULL;
	struct GRmd_env *mod;
	struct EMSslot 	slot;
	IGRvector 	nor_vec;
	OMuword 	classid;
	OM_S_CHANSELECT to_comps;
	struct GRlc_info surf_info[3];
	IGRushort 	depth_type;
	struct IGRbsp_curve *boundary = NULL;
	struct EMSplace_slot *plslot_info;
        OM_S_OBJID save_mdid;

	status = OM_S_SUCCESS;
	*EMmsg = EMS_S_Success;

	my_GRid.objid = my_id;
	my_GRid.osnum = OM_Gw_current_OS;
	mod = construct_list->env_info;
	surf_par = 1; /* start surface */
	recompute = options & EMSasconst_recompute;
	depth_type = THR_ALL; /* through all slot */
	new_prof_id.objid = NULL_OBJID;
	is_comp = is_closed = FALSE;

	status= EMmake_chanselect(GRcmpowner_to_components, &to_comps);

	switch (type) {
    	    case EMS_AS_THRU_ALL_SLOT_TYPE:
		break;

    	    case EMS_AS_THRU_UNTIL_SLOT_TYPE:
		depth_type = THR_UNTIL;
		break;

    	    case EMS_AS_THRU_NEXT_SLOT_TYPE:
		depth_type = THR_NEXT;
		break;

    	    case EMS_AS_FINITE_SLOT_TYPE:
		depth_type = BLIND;
		break;

    	    default:
		*EMmsg = EMS_I_CantRecompute;
		break;
	}
	/* we get the direction information of profile & profile normal
	information from recomputation */

	plslot_info = (struct EMSplace_slot *)recomp_info;
	is_dir_rev = plslot_info->dir_rev;
	is_pro_nor_rev = plslot_info->pro_nor_rev;

	/* Number of parents that I am associated with */
	root_count = num_par;
	num_slot = 1;

	root_type = (IGRuint *) stackalloc(sizeof(IGRint) * root_count);
	EMerr_hndlr(!root_type, *EMmsg, EMS_E_NoStackMemory,wrapup);

	roots =(union EMSparent_info *) stackalloc(sizeof(union EMSparent_info)
		* root_count);
	EMerr_hndlr(!roots, *EMmsg, EMS_E_NoStackMemory,wrapup);

	/* Profile */
	root_type[index] = EMSgrid;

	/* start surface information */
	if(depth_type != THR_ALL && depth_type != BLIND) {
		index++;
		root_type[index] = EMSgrid;
	}
	if(depth_type == BLIND) { /* depth */
		index++;
		root_type[index] = EMSdistance;
	}
	/* exit surface for thru until slot */
	else if(depth_type == THR_UNTIL) { 
		index++;
		root_type[index] = EMSgrid;
	}
	/* last parent */
	index++;
	root_type[index] = EMSgrid;

	status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
	    		root_count, parent_info, root_type, roots),
	    	targetid = my_id);
	EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	index = 0;

	/* Profile information */
	surf_info[2].located_obj = roots[index].grobj.grid;
	surf_info[2].module_info = roots[index].grobj.env;

	/* start surface information */
	if(depth_type != THR_ALL && depth_type != BLIND) {
		index++;
		surf_info[0].located_obj = roots[index].grobj.grid;

		if(surf_info[0].located_obj.objid == NULL_OBJID) {
			*EMmsg = EMS_I_CantRecompute;
			goto wrapup;
		}
		surf_info[0].module_info = *mod;
	}

	if(depth_type == BLIND) { /* read depth */
	    	index++;
		slot.depth = roots[index].value;
	}

	/* Error out if the slot depth is invalid */
	if(depth_type == BLIND &&  slot.depth <= 0.0 ) {
		ex$message(msgnumb = EMS_S_InvalidSlotDepth);
		sleep(2);
		*EMmsg = EMS_I_CantRecompute;
		goto wrapup;
	}

	/* exit surface for thru until slot */
	if(depth_type == THR_UNTIL) { 
		index++;
		surf_info[1].located_obj = roots[index].grobj.grid;
		if(surf_info[1].located_obj.objid == NULL_OBJID) {
			*EMmsg = EMS_I_CantRecompute;
			goto wrapup;
		}
		surf_info[1].module_info = *mod;
	}
	
	/* Last parent - active solid */
	index++;
	start_surf_GRid = roots[index].grobj.grid;

	if(depth_type == THR_ALL || depth_type == BLIND) {
		surf_info[0].located_obj = roots[index].grobj.grid;

		if(surf_info[0].located_obj.objid == NULL_OBJID) {
			*EMmsg = EMS_I_CantRecompute;
			goto wrapup;
		}
		surf_info[0].module_info = *mod;
	}

	/* check - profile is planar */
	status = om$send(msg = message GRvg.GRgetsize(EMmsg,
			&surf_info[2].module_info.md_env.matrix_type,
			surf_info[2].module_info.md_env.matrix,
			&buf_size),
		targetid = surf_info[2].located_obj.objid,
		targetos = surf_info[2].located_obj.osnum);

   	EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

	boundary = (struct IGRbsp_curve *) stackalloc(buf_size);

	if(!boundary) {
		status = EMS_E_Fail;
		goto wrapup;
	}

	status = om$send(msg = message GRvg.GRgetgeom(EMmsg,
			&surf_info[2].module_info.md_env.matrix_type,
			surf_info[2].module_info.md_env.matrix,
			(IGRchar *) boundary),
		targetid = surf_info[2].located_obj.objid,
		targetos = surf_info[2].located_obj.osnum);

   	EMerr_hndlr (!(1&status&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

	if(boundary->phy_closed) 
		is_closed = TRUE;
	else
		is_comp = TRUE;

	if(recompute) {
		num_pts = (IGRint)boundary->num_poles;

		cur_pts = (IGRpoint *) stackalloc(num_pts * sizeof(IGRpoint));
		if(!cur_pts) {
			status = 0;
			goto wrapup;
		}

		for(i = 0; i < num_pts; i++) {
		    j = 3 * i;
		    if(boundary->rational) {
			cur_pts[i][0] = boundary->poles[j] /
				boundary->weights[i];
			cur_pts[i][1] = boundary->poles[j+1] / 
				boundary->weights[i];
			cur_pts[i][2] = boundary->poles[j+2] / 
				boundary->weights[i];
		    }
		    else {
			cur_pts[i][0] = boundary->poles[j];  
			cur_pts[i][1] = boundary->poles[j+1];
			cur_pts[i][2] = boundary->poles[j+2];
		    }
		}

		BSptlnplan(num_pts, FALSE, cur_pts, NULL, &rcode, 
			nor_vec, EMmsg);

		/* Error out if the profile is not planar */
		if(rcode != 3) {
		    if(rcode == 1)
			ex$message(msgnumb = EMS_I_PtElmentNotSupported)
		    else if(rcode == 2)
			ex$message(msgnumb = EMS_I_LinearElmentNotSupported);
		    sleep(1);
		    *EMmsg = EMS_I_CantRecompute;
		    goto wrapup;
		}
	}

	if(is_closed) {
	    *EMmsg = om$get_classid(objid = surf_info[2].located_obj.objid,
			osnum = surf_info[2].located_obj.osnum,
			p_classid = &classid);
   	    EMerr_hndlr (!(1 & *EMmsg),*EMmsg,EMS_E_OMerror,wrapup);

	    status = om$is_ancestry_valid(subclassid = classid,
			superclassid = OPP_GRcompcurve_class_id);
	    if(status == OM_S_SUCCESS)
		is_comp = TRUE;
	}

	/* Creates a new profile from the original one to be used later */
        save_mdid = surf_info[0].module_info.md_id.objid;
        surf_info[0].module_info.md_id.objid = NULL_OBJID;
	if(is_closed) 
		status = EFslot_ret_closed_prof(EMmsg, &surf_info[0], 
			&start_surf_GRid, &depth_type, &slot, 
			is_pro_nor_rev, &new_prof_id);
	else 
		status = EFslot_ret_prof(EMmsg, &surf_info[0], 
			&start_surf_GRid, &depth_type, &slot, construct_list,
			is_pro_nor_rev, &new_prof_id);
        surf_info[0].module_info.md_id.objid = save_mdid;

	EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	/* Gets the slot axis points */
	status = EFcomp_slot_depth(EMmsg, &depth_type, &surf_info[0],
		&start_surf_GRid, &slot);

	EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	/* Create the slot feature */
	status = om$send(msg = message EMSslslotfea.EMmake_slot(EMmsg,
			&depth_type, is_dir_rev, &new_prof_id, is_closed, 
			&surf_info[0], construct_list, &slot, 
			&start_surf_GRid),
		targetid = my_id);

	EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	/* This condition occurs when there are no components created even 
	though the slot creation was successful (when the solids are disjoint)
	due to invalid input data. In such a case I am forcing an error 
	condition to avoid other problems */

	comp_count = 0;
	om_stat = om$get_channel_count(osnum= my_GRid.osnum,
			objid = my_GRid.objid,
			p_chanselect = &to_comps,
			count = (OMuint *)&comp_count);
	if(!comp_count) {
		*EMmsg = EMS_E_Fail;
		goto wrapup;
	}

wrapup:
	/* Disconnect the components when an error occurs */
	/* BUT ONLY IF NOT IN RECOMPUTE!!!! - DLB 4/2/92 TR92n2956*/
	if(!(1&status&*EMmsg) && !recompute) {
       	    	IGRlong l_msg;
		
		comp_count = 0;
		om_stat = om$get_channel_count(osnum= my_GRid.osnum,
					objid = my_GRid.objid,
					p_chanselect = &to_comps,
					count = (OMuint *)&comp_count);

		if(comp_count) {
			om$send(msg = message GRconnector.GRdisconn(&l_msg,
					&my_GRid),	
				p_chanselect = &to_comps);
		}
	}

	/* Delete the new profile created */
	if(new_prof_id.objid != NULL_OBJID && is_comp) {
		GRobjid *comp_ids;
		OMuword dum_os;

		comp_count = 0;
		status = om$get_channel_count(p_chanselect = &to_comps,
				objid = new_prof_id.objid, 
				osnum = new_prof_id.osnum,
				count = (OMuint *)&comp_count);

		comp_ids = (GRobjid *) stackalloc(sizeof(GRobjid) * comp_count);
		EMerr_hndlr(!comp_ids, *EMmsg, EMS_E_NoStackMemory,wrapup);

		/* get all the components */
		for(i = 0; i < comp_count; i++) {
			status = om$get_objid_at_index(
				objid = new_prof_id.objid, 
				p_chanselect = &to_comps,
				index = i,
				objidaddr = &comp_ids[i],
				osnumaddr = &dum_os);
		}

		/* delete all the components */
		for(i = 0; i < comp_count; i++) {
			status = om$send(msg = message Root.delete(1),
				senderid = NULL_OBJID,
				targetid = comp_ids[i],
				targetos = OM_Gw_current_OS);
		}
	}

	if(new_prof_id.objid != NULL_OBJID) {
		/* delete the owner */
		status = om$send(msg = message Root.delete(1),
			senderid = NULL_OBJID,
			targetid = new_prof_id.objid,
			targetos = new_prof_id.osnum);
	}

	if (root_type) stackfree(root_type);
	EMWRAPUP (*EMmsg,status, "In EAmkslot:error");
	return (status);
}

end implementation EMSslslotfea;
