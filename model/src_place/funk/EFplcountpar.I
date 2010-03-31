/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslboolfea;

#include "OMmacros.h"
#include "EMSas.h"
#include "EMSasnucdef.h"
#include "EMSasfeatdef.h"

/*
 * This function creates the feature c-bore/c-sink. The feature can be 
 * placed as an associative or non-associative entity.
 *
 * Tapadia    7/23/91 - Axis is not stored as a parent if it's normal to the
 *			surface. 
 * Tapadia    7/12/91 - Axis orientation for multiple c-bore/c-sink is 	same as
 *			the first one
 * Tapadia    5/22/91 - Mod so the surface for placing c-bore/c-sink is on
 *			the parent channel rather than sorted as tag
 * Tapadia    4/17/91 - Support associative & non associative placement
 * Tapadia    4/11/91 - Creation
 */

IGRlong EFplace_counterpart(EMmsg, init_opts, construct_list, type, axis_nor, 
		thru_hole, cen_pt_eve, bot_ang_eve, surf_info, num_parts, 
		part_info, coun_dep_eve, coun_dia_eve, hole_dia_eve,
		hole_dep_eve, cons_id, gen_opts)

IGRlong 	*EMmsg;
IGRushort init_opts;   
struct 		GRvg_construct *construct_list; /* Construction information */
IGRint 		type;			/* type of part to be constructed */
IGRboolean	axis_nor;		/* indicates whether axis is normal */
IGRboolean 	thru_hole;		/* flag for hole depth */
struct GRevent  *cen_pt_eve;	/* center stored as an event structure */
struct GRevent  *bot_ang_eve;	/* bottom angle stored as an event structure */
struct 		GRlc_info *surf_info; 	/* Surface on which a part is placed */
IGRlong 	num_parts;           	/* Number of c-sink/c-bore */
struct 		part_data *part_info;	/* counterpart(s) information */
struct GRevent  *coun_dep_eve;	/* c-bore/c-sink depth as an event structure */
struct GRevent  *coun_dia_eve;	/* c-bore/c-sink dia as an event structure */
struct GRevent  *hole_dia_eve;	/* hole dia as an event structure */
struct GRevent  *hole_dep_eve;	/* hole depth as an event structure */
struct GRid 	*cons_id;         	/* Resultant id */
IGRushort gen_opts;   
{
IGRlong 	sts;
IGRint 		i, num_parents, index, recomp_type, fixed_par, var_par, pt_size;
IGRint          iam_what;
IGRshort 	mattyp;
IGRdouble 	*mat;
GRspacenum 	constros;
struct GRid 	start_surf_GRid;
extern OMuword 	OPP_EMSslboolfea_class_id;
struct EMSobject_info *list_ptr = NULL;
struct EMSpoint_info cenpt;
struct EMSvector_info axis_vec;
struct EMSvalue_info hole_dep, bot_ang, hole_dia, c_bs_dia, c_ang_depth;
extern IGRlong	EMgetparpt_object(), EMgetparval_object(), EMgetparvec_object();

	*EMmsg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	pt_size = sizeof(IGRpoint);
	index = 0;
	cons_id->objid = NULL_OBJID;

	constros = construct_list->env_info->md_id.osnum;
	mattyp = construct_list->env_info->md_env.matrix_type;
	mat = construct_list->env_info->md_env.matrix;

	fixed_par = 1;	/* center point */
	if(axis_nor) 
		var_par = 3;	/* hole rad, c-sink dia & angle */
	else 
		var_par = 4;	/* hole rad, c-sink dia, axis & angle */

	/* hole diameter */
	hole_dia.type = EMSdatainfo_event;
	hole_dia.valevent = &hole_dia_eve[0]; 

	/* Bottom angle & hole depth for a blind hole */
	if(!thru_hole) {
		bot_ang.type = EMSdatainfo_event;
		bot_ang.valevent = &bot_ang_eve[0];
		hole_dep.type = EMSdatainfo_event;	
		hole_dep.valevent = &hole_dep_eve[0];
	}

	/* c-bore/c-sink diameter */
	c_bs_dia.type = EMSdatainfo_event;
	c_bs_dia.valevent = &coun_dia_eve[0];

	/* c-bore depth or c-sink angle */
	c_ang_depth.type = EMSdatainfo_event;
	c_ang_depth.valevent = &coun_dep_eve[0];

	if(type == 0) {
		if(axis_nor && thru_hole) 
			recomp_type = EMS_ASCSINK_AXIS_NOR_AND_THRU;
		else if(!axis_nor && thru_hole) 
			recomp_type = EMS_ASCSINK_AXIS_ALI_AND_THRU;
		else if(axis_nor && !thru_hole) {
			recomp_type = EMS_ASCSINK_AXIS_NOR_AND_BLIND;
			var_par += 2;	/* above var_par + bot angle & 
					hole_depth for blind hole */
		}
		else {
			recomp_type = EMS_ASCSINK_AXIS_ALI_AND_BLIND;
			var_par += 2;
		}
	}
	else if(type == 1) {
		if(axis_nor && thru_hole) 
			recomp_type = EMS_ASCBORE_AXIS_NOR_AND_THRU;
		else if(!axis_nor && thru_hole) 
			recomp_type = EMS_ASCBORE_AXIS_ALI_AND_THRU;
		else if(axis_nor && !thru_hole) {
			recomp_type = EMS_ASCBORE_AXIS_NOR_AND_BLIND;
			var_par += 2;	/* above var_par + bot angle and 
					hole_depth for blind hole */
		}
		else {
			recomp_type = EMS_ASCBORE_AXIS_ALI_AND_BLIND;
			var_par += 2;
		}
	}
	/* 2 (surface info & state parent) */
	num_parents = num_parts * fixed_par + 2 + var_par;

	list_ptr = (struct EMSobject_info *) stackalloc(sizeof
		(struct EMSobject_info)* (num_parents));
	EMerr_hndlr(!list_ptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

	for(i = 0; i < num_parts; i++) {
		cenpt.type = EMSdatainfo_event;	 	/* center point */
		cenpt.ptevent = &cen_pt_eve[i];
		sts = EMgetparpt_object(EMmsg, mattyp, mat, constros, &cenpt,
		    	&list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
		index++;
	} /* num_parts */

	/* axis_vector */
	if(!axis_nor) {
		axis_vec.type = EMSdatainfo_numeric;
		OM_BLOCK_MOVE(part_info[0].axis_dir, axis_vec.vec, pt_size);
		sts = EMgetparvec_object(EMmsg, mattyp, mat, constros, 
			&axis_vec, &list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
		index++;
	}

	/* hole diameter */
	sts = EMgetparval_object(EMmsg, constros, NULL, &hole_dia,
	    	&list_ptr[index]);
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
	index++;

	/* hole depth & bottom angle for c-bore/c-sink */
	if(!thru_hole) { /* for blind c-bore/c-sink */
		sts = EMgetparval_object(EMmsg, constros, NULL, &hole_dep,
	    		&list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
		index++;
		sts = EMgetparval_object(EMmsg, constros, NULL, &bot_ang,
		    	&list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
		index++;
	}

	/* c-bore/c-sink diameter */
	sts = EMgetparval_object(EMmsg, constros, NULL, &c_bs_dia,
	    	&list_ptr[index]);
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
	index++;

	/* c-bore depth or c-sink angle */
	sts = EMgetparval_object(EMmsg, constros, NULL, &c_ang_depth,
	    	&list_ptr[index]);
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
	index++;

	/* The surface on which c-bore/c-sink is placed */

	list_ptr[index].grid = surf_info[0].located_obj;
	list_ptr[index].env = surf_info[0].module_info;

	/* The state parent on which the c-bore/c-sink hole is created */

	sts = om$send(msg = message EMSsurface.EMgetactiveid (EMmsg,
	    			&start_surf_GRid, NULL),
	    		senderid = NULL_OBJID,
	    		targetid = surf_info[0].located_obj.objid,
	    		targetos = surf_info[0].located_obj.osnum);
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	list_ptr[num_parents - 1].grid = start_surf_GRid;
	list_ptr[num_parents - 1].env = surf_info[0].module_info;

	/* This function initializes and constructs the associative place 
    	c-bore/c-sink object */

  	sts = om$construct(classid = OPP_EMSslboolfea_class_id,
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
				0, (IGRchar *) NULL, 
				construct_list),
			senderid = NULL_OBJID,
			targetid = cons_id->objid,
			targetos = cons_id->osnum);
	  current_creator = NULL_OBJID;
	}
  	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

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
	if (list_ptr) stackfree (list_ptr);
	EMWRAPUP(*EMmsg, sts, "EFplace c-part/c-sink");
	return (sts);
}
end implementation EMSslboolfea;
