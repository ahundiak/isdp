/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslslotfea;

#include "EMSas.h"
#include "EMSasnucdef.h"
#include "EMSasfeatdef.h"

/*   
 *  This function creates the feature slot. The feature can be placed as
 *  a associative or non-associative entity.
 *
 *  Tapadia  08/20/91 - Creation
 */

IGRlong EFplace_slot(EMmsg, init_opts, is_dir_rev, is_pro_nor_rev, 
		depth_type, depth, surf_info, construct_list, 
		cons_id, gen_opts)

IGRlong 	*EMmsg;
IGRushort init_opts;
IGRboolean 	is_dir_rev;	/* direction reversed */
IGRboolean 	is_pro_nor_rev;	/* profile normal reversed */
IGRushort *depth_type;
struct  GRevent *depth; 
struct 		GRlc_info *surf_info; /* Surface on which a slot is placed */
struct 		GRvg_construct *construct_list; /* Construction information */
struct		GRid *cons_id;	/* resultant id */
IGRushort gen_opts;
{
IGRlong 	sts;
IGRint 		num_parents, index = 0, recomp_type, surf_par;
IGRshort 	mattyp;
IGRdouble 	*mat;
GRspacenum 	constros;
struct GRid 	start_surf_GRid;
extern IGRlong 	EMgetparval_object();
extern OMuword  OPP_EMSslslotfea_class_id;
struct EMSobject_info *list_ptr = NULL;
struct EMSvalue_info dep;
struct EMSplace_slot *plslot_info = NULL;

	*EMmsg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	cons_id->objid = NULL_OBJID;
	surf_par = 2; /* start surface + profile */

	constros = construct_list->env_info->md_id.osnum;
	mattyp = construct_list->env_info->md_env.matrix_type;
	mat = construct_list->env_info->md_env.matrix;

	if(*depth_type == 0) 
		recomp_type = EMS_AS_THRU_ALL_SLOT_TYPE;
	else if(*depth_type == 1) {
		recomp_type = EMS_AS_THRU_UNTIL_SLOT_TYPE;
		surf_par++;	/* exit surface */
	}
	else if(*depth_type == 2) 
		recomp_type = EMS_AS_THRU_NEXT_SLOT_TYPE;
	else {
		recomp_type = EMS_AS_FINITE_SLOT_TYPE;
		surf_par++;	/* depth */
	}

	/* Parents are surface(s) + state parent */ 

	if(*depth_type != 0 && *depth_type != 3) 
		num_parents = surf_par + 1;
	else
		num_parents = surf_par;

	list_ptr = (struct EMSobject_info *) stackalloc(num_parents *
		sizeof(struct EMSobject_info));
	EMerr_hndlr(!list_ptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

	/* assign memoryfor recomputation */
	plslot_info = (struct EMSplace_slot *) stackalloc(sizeof 
			(struct EMSplace_slot));
	EMerr_hndlr(!plslot_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

	plslot_info->dir_rev = is_dir_rev;
	plslot_info->pro_nor_rev = is_pro_nor_rev;

	/* Profile information */

	list_ptr[index].grid = surf_info[2].located_obj;
	list_ptr[index].env = surf_info[2].module_info;

	/* The surface on which the slot is created */

	if(*depth_type != 0 && *depth_type != 3) {
		index++;
		list_ptr[index].grid = surf_info[0].located_obj;
		list_ptr[index].env = surf_info[0].module_info;
	}

	/* get the active solid id */
	if(*depth_type != 0 && *depth_type != 3) {
		sts = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
	    			&start_surf_GRid, NULL),
	    		senderid = NULL_OBJID,
	    		targetid = surf_info[0].located_obj.objid,
	    		targetos = surf_info[0].located_obj.osnum);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	}
	else { /* check if the object is valid */
	    if(om$is_objid_valid(objid = surf_info[0].located_obj.objid,
		osnum = surf_info[0].located_obj.osnum) == OM_S_SUCCESS) {
		start_surf_GRid.objid = surf_info[0].located_obj.objid;
		start_surf_GRid.osnum = surf_info[0].located_obj.osnum;
	    }
	    else { /* the object doesn't exist */
		*EMmsg = EMS_E_InvalidArg;
		goto wrapup;
	    }
	}

	if( *depth_type == 1) { /* exit surface for through until slot */
		index++;
		list_ptr[index].grid = surf_info[1].located_obj;
		list_ptr[index].env = surf_info[1].module_info;
	}
	else if(*depth_type == 3) {  /* depth - finite slot */
		index++;
		dep.type = EMSdatainfo_event;
		dep.valevent = &depth[0];
		/* create a parameter value object */
		sts = EMgetparval_object(EMmsg, constros, NULL,
			&dep, &list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
	} /* depth_type == 3 */

	/* state parent */
	list_ptr[num_parents - 1].grid = start_surf_GRid;
	list_ptr[num_parents - 1].env = surf_info[0].module_info;

	/* This function initializes and constructs the associative feature 
	slot */

	sts = om$construct(classid = OPP_EMSslslotfea_class_id,
	    		osnum = start_surf_GRid.osnum,
	    		p_objid = &cons_id->objid);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

        {
          extern OM_S_OBJID current_creator;
	  current_creator = cons_id->objid;

	  /* If the gen_opts is non-associative, don't auto dimension */
	  if(gen_opts & EMSasconst_notassociative) 
		init_opts |= EMSasconst_noautodimension;

  	  sts = om$send (msg = message EMSassoc.EMinit_associative(EMmsg,
	    			init_opts, 
				num_parents, 
				list_ptr, 
				recomp_type, 
				sizeof(struct EMSplace_slot),
				(IGRchar *) plslot_info,
				construct_list),
	    		senderid = NULL_OBJID,
	    		targetid = cons_id->objid,
	    		targetos = cons_id->osnum);
	  current_creator = NULL_OBJID;
        }
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
 
	/* If non-associative placement disconnect the parents */
	if(gen_opts & EMSasconst_notassociative) {
		sts = om$send(msg = message NDnode.NDmove_to_root(EMmsg, 
				cons_id, &surf_info[0].module_info),
			senderid = NULL_OBJID,
			targetid = cons_id->objid,
			targetos = cons_id->osnum);

		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	}

wrapup:
	if(!(1&sts&*EMmsg)) {
	    IGRlong l_msg;
	    if(cons_id->objid != NULL_OBJID) {
		om$send(msg = message GRgraphics.GRdelete(&l_msg,
				construct_list->env_info),
			senderid = NULL_OBJID,
			targetid = cons_id->objid,
			targetos = cons_id->osnum);
	    }
	    cons_id->objid = NULL_OBJID;
	}
	if (list_ptr) stackfree(list_ptr); 
	EMWRAPUP(*EMmsg, sts, "EFplace_slot"); 
	return (sts);
}

end implementation EMSslslotfea;
