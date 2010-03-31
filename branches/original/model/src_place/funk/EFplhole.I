/* ###################   APOGEE COMPILED   ################## */
class implementation EMSslboolfea;

#include "EMSas.h"
#include "EMSasnucdef.h"
#include "EMSasfeatdef.h"

/*  
 *  This function creates the feature hole. The feature can be placed as
 *  a associative or non-associative entity.
 *
 *  Tapadia  07/27/92 - Support of reference planes for hole. Changes made
 *			for new specs (2.1). We are always storing the vector
 *			for a cirular hole. This vector is later used for
 *			constraining the axis. 
 *  Tapadia  07/23/91 - Axis is not stored as a parent if it's normal to the
 *			surface. The same information is stored in the 
 *			recomputation information. 
 *  Tapadia  07/12/91 - Holes of different diameters can't be placed. Axis
 *			orientation same as first hole. 
 *			i.e the user can place multiple holes but they will be
 *			of same diameter. This simplifies auto dimensioning.
 *  Tapadia  05/22/91 - Mod so the surface(s) for placing holes is on the
 *			parent channel rather than stored as a tag.
 *  Tapadia  04/24/91 - Support for efficient placement of multiple holes
 *			of same diameter. Number of holes of same dia. is 
 *			stored which simplifies the dimensioning code. 
 *  Tapadia  03/30/91 - Creation
 */

extern GRclassid OPP_EMSpervcnstr_class_id;

from EMSsubbs import EMget_unit_norm;
from EMScnstr import EMinit;

IGRlong EFplace_hole_mod(EMmsg, init_opts, ref_plane, axis_normal, hole_type, 
		depth_type, cenpt, dia, depth, surf_info, v_angle, 
		construct_list, num_holes, hole_info, cons_id, gen_opts)

IGRlong 	*EMmsg;
IGRushort init_opts;
IGRboolean 	ref_plane;
IGRboolean 	axis_normal;	/* Axis is normal to the surface */
IGRushort hole_type;
IGRushort *depth_type;
struct 	GRevent *cenpt;
struct  GRevent *dia, *depth; 
struct 		GRlc_info *surf_info; /* Surface on which a hole is placed */
IGRdouble 	*v_angle;
struct 		GRvg_construct *construct_list; /* Construction information */
IGRint 		num_holes;           /* Number of holes being passed in */
struct 		EMShole *hole_info;
struct		GRid *cons_id;	/* resultant id */
IGRushort gen_opts;
{
IGRlong 	sts;
IGRint 		i, num_parents, index, recomp_type, var_par, surf_par, cen_par, 
		temp_count, ii ;
IGRshort 	mattyp;
IGRdouble 	*mat;
GRspacenum 	constros;
struct GRid 	start_surf_GRid;
struct		EMSvector_info  hole_vec;
extern IGRlong 	EMgetparpt_object(), EMgetparval_object(), EMgetparvec_object();
struct EMSobject_info *list_ptr = NULL;
extern OMuword OPP_EMSslboolfea_class_id;
struct EMSpoint_info cen;
struct EMSvalue_info diam, dep, holev_ang;
struct EMSplace_hole *plhole_info=NULL;

	*EMmsg = EMS_S_Success;
	sts = OM_S_SUCCESS;
	cons_id->objid = NULL_OBJID;
	index = temp_count = 0;
	surf_par = 1; /* start surface */
	cen_par = 1;  /* center */
	if(hole_type != 2) {  /* Circular hole */
		var_par = 2;	/* diameter & axis */
	}
	else 
		var_par = 0; 	/* Profile hole */

	constros = construct_list->env_info->md_id.osnum;
	mattyp = construct_list->env_info->md_env.matrix_type;
	mat = construct_list->env_info->md_env.matrix;

	if(hole_type == 0) {
		if(*depth_type == 0) { 
		    if(!ref_plane)
			recomp_type = EMS_ASCIR_THRU_ALL_HOLE_TYPE_1;
		    else 
			recomp_type = EMS_ASCIR_THRU_ALL_REFPLANE;
		}
		else if(*depth_type == 1) {
		    if(!ref_plane)
			recomp_type = EMS_ASCIR_THRU_UNTIL_HOLE_TYPE_1;
		    else 
			recomp_type = EMS_ASCIR_THRU_UNTIL_REFPLANE;
		    surf_par = 2;	/* 2 surfaces */
		}
		else if(*depth_type == 2) {
		    if(!ref_plane)
			recomp_type = EMS_ASCIR_THRU_NEXT_HOLE_TYPE_1;
		    else 
			recomp_type = EMS_ASCIR_THRU_NEXT_REFPLANE;
		}
		else {
		    if(!ref_plane)
			recomp_type = EMS_ASCIR_FINITE_FLAT_HOLE_TYPE_1;
		    else 
			recomp_type = EMS_ASCIR_FINITE_FLAT_REFPLANE;
		    surf_par = 2;	/* surface & depth */
		}
	} /* Circular through hole */
	else if(hole_type == 2) {
		if(*depth_type == 0) {
			recomp_type = EMS_ASPRO_THRU_ALL_HOLE_TYPE;
			surf_par = 2;	/* surface, profile */
		}
		else if(*depth_type == 1) {
			recomp_type = EMS_ASPRO_THRU_UNTIL_HOLE_TYPE;
			surf_par = 3;	/* 2 surfaces, profile */
		}
		else if(*depth_type == 2) {
			recomp_type = EMS_ASPRO_THRU_NEXT_HOLE_TYPE;
			surf_par = 2;	/* surface, profile */
		}
	} /* Profile hole */
	else {
	  	if(!ref_plane)
			recomp_type = EMS_ASCIR_FINITE_V_HOLE_TYPE_1;
		else 
			recomp_type = EMS_ASCIR_FINITE_V_REFPLANE;
		surf_par = 3;	/* surface, depth & v-angle */
	} /* Circular hole with v bottom */

	/* if profile holes & num_holes == 1, don't store center point */
	if(hole_type == 2 && num_holes == 1)
		cen_par = 0;

	/* Parents are num_holes * cen_par (center) + var_par + surface(s) 
			+ state parent */ 

	num_parents = num_holes * cen_par + var_par + surf_par + 1;

	list_ptr = (struct EMSobject_info *) stackalloc(num_parents *
		sizeof(struct EMSobject_info));
	EMerr_hndlr(!list_ptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

	/* assign memory for recomputation */
	plhole_info = (struct EMSplace_hole *) stackalloc(sizeof
		(struct EMSplace_hole));
	EMerr_hndlr(!plhole_info, *EMmsg, EMS_E_NoStackMemory, wrapup);

	plhole_info->hole_count = num_holes;
	plhole_info->axis_normal = axis_normal;

	temp_count = 0;

	for(i = 0; i < num_holes; i++) {
	    if(hole_type != 2 || (hole_type == 2 && num_holes > 1)) {
		cen.type = EMSdatainfo_event; /* hole center */
		cen.ptevent = &cenpt[i];
		/* create a parameter point object */
		sts = EMgetparpt_object(EMmsg, mattyp, mat, constros, &cen,
		    	&list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
		index++;
	    }
	} /* num_holes */

	/* read axis for the first hole */
	if(hole_type != 2) {
		hole_vec.type = EMSdatainfo_numeric;

		hole_vec.vec[0] = hole_info[0].axis_line[1][0] -
		   	hole_info[0].axis_line[0][0];
		hole_vec.vec[1] = hole_info[0].axis_line[1][1] -
		   	hole_info[0].axis_line[0][1];
		hole_vec.vec[2] = hole_info[0].axis_line[1][2] -
		   	hole_info[0].axis_line[0][2];

		/* create a parameter vector object */
		sts = EMgetparvec_object(EMmsg, mattyp, mat, 
			constros, &hole_vec, &list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail, wrapup);

		index++;
	}

	if(hole_type != 2) { /* diameter */
		/* store the diameter as event & create an object */
		diam.type = EMSdatainfo_event;
		diam.valevent = &dia[0];
		/* create a parameter value object */
		sts = EMgetparval_object(EMmsg, constros, NULL, 
			&diam, &list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,
			wrapup);
		index++;
	} /* hole_type !=2 */

	if(*depth_type == 3) {  /* depth - finite hole */
		dep.type = EMSdatainfo_event;
		dep.valevent = &depth[0];
		/* create a parameter value object */
		sts = EMgetparval_object(EMmsg, constros, NULL,
			&dep, &list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,
			wrapup);
		index++;
	} /* depth_type == 3 */
	if(hole_type == 1) { /* circular hole with v-bottom */
		holev_ang.type = EMSdatainfo_numeric;
		holev_ang.val = *v_angle;
		/* create a parameter value object */
		sts = EMgetparval_object(EMmsg, constros, NULL, &holev_ang,
		    	&list_ptr[index]);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
		index++;
	}

	if(hole_type == 2) { /* store the profile information */
		list_ptr[index].grid = surf_info[2].located_obj;
		list_ptr[index].env = surf_info[2].module_info;
		index++;
	}

	/* The surface/referance plane on which the hole is created */

	list_ptr[index].grid = surf_info[0].located_obj;
	list_ptr[index].env = surf_info[0].module_info;

	if(!ref_plane) {
		sts = om$send(msg = message EMSsurface.EMgetactiveid (EMmsg,
	    			&start_surf_GRid, NULL),
	    		senderid = NULL_OBJID,
	    		targetid = surf_info[0].located_obj.objid,
	    		targetos = surf_info[0].located_obj.osnum);
		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
	}
	else { /* check if the object is valid */
	        if(om$is_objid_valid(objid = surf_info[0].located_obj.objid,
		    osnum = surf_info[0].located_obj.osnum) == OM_S_SUCCESS) {
		    start_surf_GRid.objid = surf_info[2].located_obj.objid;
		    start_surf_GRid.osnum = surf_info[2].located_obj.osnum;
	        }
	        else { /* the object doesn't exist */
			*EMmsg = EMS_E_InvalidArg;
			goto wrapup;
	    	}
	}

	if( *depth_type == 1) { /* exit surface for through until hole */
		index++;
		list_ptr[index].grid = surf_info[1].located_obj;
		list_ptr[index].env = surf_info[1].module_info;
	}

	/* state parent */
	list_ptr[num_parents - 1].grid = start_surf_GRid;
	list_ptr[num_parents - 1].env = surf_info[0].module_info;

	/* This function initializes and constructs the associative feature 
	hole */

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
				sizeof(struct EMSplace_hole),
				(IGRchar *) plhole_info, 
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
	EMWRAPUP(*EMmsg, sts, "EFplace_hole_mod"); 
	return (sts);
}

end implementation EMSslboolfea;
