/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslboolfea;

#include "OMmacros.h"
#include "EMSas.h"
#include "EMSasdef.h"
#include "nddef.h"
#include "asbox.h"

from EMSsubbs import EMget_unit_norm;

/* History
	Tapadia 7/14/92	Genesis. This function adds a parent (vector) into the 
			parent list so as to properly convert the 2.0 design
			files into 2.1 as the hole storage data is changed. In
			2.0 we were not storing the axis vector for axis normal
			holes but in 2.1 we are always storing the same.
*/

	
IGRlong EFadd_vector(EMmsg, type, parent_info, par_count, hl_count, 
	new_list, bool_id, md_env)

IGRlong 	*EMmsg;
IGRint  	type; 
IGRchar 	*parent_info;
IGRint		par_count, hl_count;
struct GRid 	*new_list;
GRobjid		bool_id;
struct GRmd_env *md_env;
{
	IGRlong sts;
	IGRuint         *root_type = NULL;
        OMuint          count;
	IGRint 		i, my_index, part_type;
	IGRboolean	hole_flag, axis_normal, through_hole, ref_plane;
	IGRuint		var_par, root_count;
	IGRushort 	hole_type, depth_type;
	void 		EFret_hole_cpart_data_mod();
	IGRvector 	axis_dir;
	struct EMSobject_info list_ptr;
	struct EMSvector_info hole_vec;
	union  EMSparent_info *roots = NULL;
	struct GRlc_info surf_info[3];
	OM_S_CHANSELECT	to_father;
	struct GRid *comp_roots = NULL;

	my_index = 0;
	*EMmsg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	EMmake_chanselect(NDfather_father, &to_father);

	sts = om$get_channel_count(objid = bool_id,
			osnum = OM_Gw_current_OS,
			p_chanselect = &to_father,
			count = &count);

	/* This returns the hole type */
	EFret_hole_cpart_data_mod(EMmsg, type, &hole_flag, &axis_normal,  
		&var_par, &hole_type, &depth_type, &part_type, 
		&through_hole, &ref_plane);

	EMerr_hndlr(!(1 & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	/* Number of parents that I am associated with is par_count - 1 since
	one of my parents is a component parent */

	root_count = par_count - 1;

	root_type = (IGRuint *) stackalloc(sizeof(IGRint) * root_count);
	EMerr_hndlr(!root_type, *EMmsg, EMS_E_NoStackMemory,wrapup);

	roots =(union EMSparent_info *) stackalloc(sizeof(union EMSparent_info)
		* root_count);
	EMerr_hndlr(!roots, *EMmsg, EMS_E_NoStackMemory,wrapup);

	for(i = 0; i < hl_count; i++) {
	     	root_type[my_index] = EMSpoint; /* center */
		my_index++;
	}

	/* radius */
	root_type[my_index] = EMSdistance;
	my_index++;

	if(depth_type == 3) { /* depth */
		root_type[my_index] = EMSdistance;
		my_index++;
	}
	if(hole_type == 1) { /* v angle */
		root_type[my_index] = EMSangle;
		my_index++;
	}
	/* start surface information */
	root_type[my_index] = EMSgrid;

	/* exit surface for thru until hole */
	if(depth_type == 1) { 
		my_index++;
		root_type[my_index] = EMSgrid;
	}

	sts = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
	    		root_count, parent_info, root_type, roots),
		senderid = NULL_OBJID,
	    	targetid = bool_id,
		targetos = OM_Gw_current_OS);
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	/* start surface information */
	if(depth_type == 1) 
		surf_info[0].located_obj = roots[root_count - 2].grobj.grid;
	else 
		surf_info[0].located_obj = roots[root_count - 1].grobj.grid;

	if(surf_info[0].located_obj.objid == NULL_OBJID) {
		*EMmsg = EMS_I_CantRecompute;
		goto wrapup;
	}
	surf_info[0].module_info = *md_env;

	/* Error out if the axis direction is invalid */
	sts = om$send(msg = message EMSsubbs.EMget_unit_norm(EMmsg, FALSE, 
			NULL, &surf_info[0].module_info.md_env,
			roots[0].point,axis_dir),
		senderid = NULL_OBJID,
		targetid = surf_info[0].located_obj.objid,
		targetos = surf_info[0].located_obj.osnum);

    	EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);

	hole_vec.type = EMSdatainfo_numeric;
	hole_vec.vec[0] = axis_dir[0];
	hole_vec.vec[1] = axis_dir[1];
	hole_vec.vec[2] = axis_dir[2];
	
	sts = EMgetparvec_object(EMmsg, md_env->md_env.matrix_type,
			md_env->md_env.matrix, md_env->md_id.osnum,
			&hole_vec, &list_ptr);
    	EMerr_hndlr (!(1&sts&*EMmsg),*EMmsg,EMS_E_Fail,wrapup);
	
	count++;
	comp_roots = (struct GRid *) alloca(count * sizeof(struct GRid));
	if(!comp_roots) {
		*EMmsg = MSFAIL;
		goto wrapup;
	}

	/* Adding the vector at the right position i.e after the center points
	objects are stored */
	for(i = 0; i < count; i++) {
 	    int j;
	    if(i > hl_count)
		j = i - 1;
	    else j = i;
	    if(i == hl_count) {
		comp_roots[hl_count].objid = list_ptr.grid.objid; 
		comp_roots[hl_count].osnum = list_ptr.grid.osnum; 
	    }
	    else {
		sts = om$get_objid_at_index(objid = bool_id,
			osnum = OM_Gw_current_OS,
			p_chanselect = &to_father,
			index = j,
			objidaddr = &comp_roots[i].objid,
			osnumaddr = &comp_roots[i].osnum);
		if(!(1 & sts)) goto wrapup;
	    }
	}

	/* storing the list in a new array to be passsed later */
	for(i = 0; i < count; i++) {
		new_list[i].objid = comp_roots[i].objid;
		new_list[i].osnum = comp_roots[i].osnum;
	}

	/* disconnecting the old parent list to add the new object in the list*/
	sts = om$send(msg = message NDnode.NDdisconnect(0, NULL),
		senderid = NULL_OBJID,
		targetid = bool_id,
		targetos = OM_Gw_current_OS);

	if(!(1 & sts)) goto wrapup;

	sts = om$send(msg = message NDnode.NDconnect(count, comp_roots,
			NULL_GRID, ND_ADD),
		senderid = NULL_OBJID,
		targetid = bool_id,
		targetos = OM_Gw_current_OS);

	if(!(1 & sts)) goto wrapup;

wrapup:
	return(sts);
}

end implementation EMSslboolfea;

