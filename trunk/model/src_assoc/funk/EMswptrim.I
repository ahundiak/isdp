/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
/*
 Description

 This function creates a solid by sweeping a surface which possibly has
 boundaries & then trimming with one/two plane(s).  It is assumed that the 
 resulting solid is valid, i.e. no checks are made to ensure that the solid 
 does not intersect itself, etc..

 Bugs

 This function will not align the normals correctly in some cases where
 the input surface is not planar.

 History

   Sudhakar: 30Jun93 : Fix for TR#119302045. Added an addl. arg to the two
                        functions 'EFget_axis_from_curve_one_pl()' and
                        'EFget_axis_from_curve_two_pls()'. Added code to
                        skip the call to 'EFplsolid_by_trimming_with_planes()'
                        if planes parallel and change the class of the object
                        created to 'EMSsfsolid'.
   Sudha    06/01/93 : Modified to handle BSprototypes
   Tapadia: 03/17/92 : Most of the code is taken from (EMswpsrf.I). Added 
			support for trimming with one or two planes.

 */

class implementation EMSsubbs;

#include "EMS.h"
#include "bs.h"                 /* BSSUCC, etc. */
#include "EMSconstruct.h"       /* Mask for aligning normals */
#include "EMSopt.h"             /* Topology copy options */
#include "godef.h"              /* Properties masks */
#include "msdef.h"              /* MSSUCC, MSFAIL */
#include "OMmacros.h"    
#include "bssfarrevn.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

from EMSsf_lift import EMlift_face;
from EMSsfdpr import EMadd;
from EMSdpr import EMmake_primitive1;
from EMSboundary import EMtpcopy;
from EMSloopset import EMmakeFRT;

extern OMuword OPP_EMSgensolid_class_id;

IGRlong EMsweep_surf_lift_face_trim(construct_list, opts, my_stupid_id,
	curve, st_plane_info, end_plane_info, solid_id, msg)

struct          GRvg_construct *construct_list;
IGRushort opts;
OM_S_OBJID      my_stupid_id;
struct GRlc_info *curve;
struct GRlc_info *st_plane_info;
struct GRlc_info *end_plane_info;
GRobjid         *solid_id;
IGRlong         *msg;

{
	OMuword         space_number;
	IGRlong         sts, msg_loc;
	IGRint 		i;
	GRobjid         sf_id, cp_sf_id, cp_ls_id;
	OM_S_CHANSELECT sf_ls_chan, ls_sf_chan;
	struct GRmd_env *md_env;
	IGRboolean 	st_rp_flag, end_rp_flag;
	extern IGRlong 	EFplsolid_by_trimming_with_planes(), 
			EFget_axis_from_curve_one_pl(), 
			EFget_axis_from_curve_two_pls();
	IGRpoint 	axis[2], cur_pt, mid_point, from_point, to_point;
	IGRdouble 	move_dist;
	IGRvector 	move_nor;
	IGRmatrix	matrix;
	struct GRid	new_id, tmp_id;

        IGRboolean      parallel_pls = FALSE;
        char classname [OM_K_MAXCLASS_LEN];


	/* Initialize */

	*msg = MSSUCC;
	sf_id = NULL_OBJID;
	cp_sf_id = NULL_OBJID;
	cp_ls_id = NULL_OBJID;
	*solid_id = NULL_OBJID;
        new_id.objid = NULL_OBJID;
	md_env = construct_list->env_info;
	space_number = md_env->md_id.osnum;
	st_rp_flag = end_rp_flag = TRUE;

	if(st_plane_info->located_obj.objid == NULL_OBJID)
		st_rp_flag = FALSE;
	if(end_plane_info->located_obj.objid == NULL_OBJID)
		end_rp_flag = FALSE;

	if(st_rp_flag) {
		sts = EFget_axis_from_curve_two_pls(&msg_loc, curve, 
		    	st_plane_info, end_plane_info, cur_pt, axis, mid_point,
                        &parallel_pls);

		EMerr_hndlr(EMSerror(msg_loc & sts), *msg, EMS_E_Fail, 
		    	wrapup);

		OM_BLOCK_MOVE(axis[0], from_point, sizeof(IGRpoint));
		OM_BLOCK_MOVE(axis[1], to_point, sizeof(IGRpoint));

		for(i = 14; i > 0; i--) matrix[i] = 0.0;
		matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;

		move_nor[0] = axis[0][0] - cur_pt[0];
		move_nor[1] = axis[0][1] - cur_pt[1];
		move_nor[2] = axis[0][2] - cur_pt[2];
		BSnorvec(&msg_loc, move_nor);

		move_dist = BSdistptpt(&msg_loc, axis[0], cur_pt);
		matrix[3] = move_dist * move_nor[0];
		matrix[7] = move_dist * move_nor[1];
		matrix[11] = move_dist * move_nor[2];

		new_id.objid = NULL_OBJID;

		sts = om$send(msg = message GRgraphics.GRcptform(&msg_loc,
		    		&curve->module_info, matrix,
		    		&curve->module_info,
		    		&new_id.objid),
		    	senderid = NULL_OBJID,
		    	targetid = curve->located_obj.objid,
		    	targetos = curve->located_obj.osnum);

		EMerr_hndlr(EMSerror(msg_loc & sts), *msg, EMS_E_Fail, 
		    	wrapup);

		tmp_id.objid = curve->located_obj.objid;
		curve->located_obj.objid = new_id.objid;
	}
	else if(end_rp_flag) {
		sts = EFget_axis_from_curve_one_pl(&msg_loc, curve, 
		    	end_plane_info, axis, mid_point, &parallel_pls);

		EMerr_hndlr(EMSerror(msg_loc & sts), *msg, EMS_E_Fail, 
		    	wrapup);

		OM_BLOCK_MOVE(axis[0], from_point, sizeof(IGRpoint));
		OM_BLOCK_MOVE(axis[1], to_point, sizeof(IGRpoint));
	}

	/* Make channel selectors */
	sts = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
	if (! (1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	}
	sts = EMmake_chanselect (EMSloopset_to_surface, &ls_sf_chan);
	if (! (1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	}
	/* Copy the original surface to the destination 
	object space (possibly the same) */
	{
	    struct        GRid *id;
	    struct        GRmd_env *old_md_env;

	    id = &curve->located_obj;
	    old_md_env = &curve->module_info;
	    sts = om$send(msg = message GRgraphics.GRcopy(msg, old_md_env,
		    		md_env, &sf_id),
			senderid = my_stupid_id,
		    	targetid = id->objid,
		    	targetos = id->osnum);

	    if(!(1 & sts)) goto wrapup;
	}
	/* If the surface has topology then compress it. If it has no 
	topology then create some */
	{
	    IGRlong       channel_count;

	    sts = om$get_channel_count(objid = sf_id, osnum = space_number,
		    	p_chanselect = &sf_ls_chan,
		    	count = (OMuint *) &channel_count);
	    if (! (1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	    }
	    if(channel_count) {
		sts = om$send(msg = message EMSsubbs.EMcompress_top(msg, 
				md_env),
		 	senderid = my_stupid_id,
			targetid = sf_id,
			targetos = space_number);
		if(!(1 & sts)) {
			*msg = MSFAIL;
			goto wrapup;
		}
	    } /* if (channel_count) */
	    else {
		sts = om$send(msg = message EMSsurface.EMmk_nat_bdry(msg,
			    (struct GRmdenv_info *) md_env, NULL),
			                         /* Don't want the edge id's */
			senderid = my_stupid_id,
			targetid = sf_id,
			targetos = space_number);
		if(! (1 & sts)) {
			*msg = MSFAIL;
			goto wrapup;
		}
	    } /* ELSE FOR if (channel_count) */
	}

	/* Change the symbology of the copied surface */
	{
	    struct	GRsymbology symbology;
	    struct      IGResbs *element_specific;

	    symbology.level = construct_list->level;
	    symbology.display_attr = *(construct_list->display);
	    sts = om$send(msg = message GRvg.GRputsymb(msg, &symbology),
		    	senderid = my_stupid_id,
		    	targetid = sf_id,
		    	targetos = space_number);
	    if(!(1 & sts)) goto wrapup;
	    element_specific = (struct IGResbs *) construct_list->class_attr;
	    sts = om$send(msg = message GRvg.GRputattr(msg,
		    		(IGRchar *) element_specific),
		    	senderid = my_stupid_id,
		    	targetid = sf_id,
		    	targetos = space_number);
	    if(!(1 & sts)) goto wrapup;
	}

	/* Align the normal of the surface.  This logic works 
	well for planes but will not work in the general case  */
	{
	    IGRboolean    status;
	    IGRshort      pos_orient;
	    IGRlong       i, loc_msg;
	    IGRdouble     u, v, dot_p;
	    IGRvector     lift_vec, sf_nrml;
	    IGRpoint      sf_pt;
	    struct        GRmdenv_info *mdenv_info;
	    struct        IGRbsp_surface *surface;

	    mdenv_info = &md_env->md_env;
	    sts = om$send(msg = message GRvg.GRgenabsg(msg, 
				&mdenv_info->matrix_type,
		    		mdenv_info->matrix,
		    		(IGRchar **) &surface),
		  	senderid = my_stupid_id,
		    	targetid = sf_id,
		    	targetos = space_number);
	    if(! (1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	    }
	    u = 0.48;             /* Try and avoid a knot line */
	    v = 0.37;             /* Try and avoid a knot line */
	    BSsfarrevn(&loc_msg, surface, 1, &u, 1, &v, sf_pt, sf_nrml);
	    if (loc_msg != BSSUCC) {
		*msg = MSFAIL;
		goto wrapup;
	    }
		
	    for (i = 0; i < 3; i++)
		lift_vec[i] = to_point[i] - from_point[i];
	    status = BSnorvec(&loc_msg, lift_vec);
	    dot_p = BSdotp(&loc_msg, sf_nrml, lift_vec);
	    if(dot_p >= 0.0)
		pos_orient = TRUE;
	    else
		pos_orient = FALSE;
	    sts = om$send(msg = message EMSsubbs.EMalgnnrml(msg,
		    		EMS_SET_POS_ORIENT,
		    		&pos_orient,
		    		NULL,         /* No orientation point */
				NULL),        /* No enviroment is necessary */
			senderid = my_stupid_id,
		    	targetid = sf_id,
		    	targetos = space_number);
	    if(! (1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	    }
	}

	/* Copy the surface again to form the other cap of the solid.
 	We don't want the topology, just the geometry but we must
 	be careful to ensure that the copy is in the R-tree.  */

	sts = om$send(mode = OM_e_wrt_message, 
			msg = message GRgraphics.GRcopy(msg, md_env,
	    			md_env, &cp_sf_id), 
		senderid = my_stupid_id,
	    	targetid = sf_id,
	    	targetos = space_number);
	if(!(1 & sts)) goto wrapup;

	/* Align the normal of the copied surface to be the 
	opposite of the original surface */

	sts = om$send(msg = message EMSsubbs.EMrevorient(msg),
	    	senderid = my_stupid_id,
	    	targetid = cp_sf_id,
	    	targetos = space_number);
	if(!(1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Copy the topology of the surface with the option to connect 
 	its edges to the corresponding edges of the copied surface  */

	sts = om$send(msg = message EMSboundary.EMtpcopy(msg,
	    		NULL, 		/* No model space edges are required */
			space_number,   /* Old object space */
			space_number,   /* New object space */
		/* Connect copied edges to existing edges */
			EMS_COPY_ONCOMMON,  
			&cp_ls_id),     /* The new loopset */
		senderid = sf_id,
	    	p_chanselect = &sf_ls_chan,
	    	targetos = space_number);
	if(!(1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Connect the newly created loopset to the copied surface */

	sts = om$send(msg = message Root.connect(sf_ls_chan, NULL, cp_ls_id,
	    		space_number,
	    		ls_sf_chan,
	    		NULL),
	    	senderid = my_stupid_id,
	    	targetid = cp_sf_id,
	    	targetos = space_number);
	if(!(1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Make sure the copied surface has it's FRT fixed */
	sts = om$send(msg = message EMSloopset.EMmakeFRT(msg, cp_sf_id),
	    	senderid = my_stupid_id,
	    	targetid = cp_ls_id,
	    	targetos = space_number);
	if(!(1 & sts)) {
		*msg = MSFAIL;
		goto wrapup;
	}

	/* Construct the solid object and connect the two surfaces to it */
	{
		IGRshort      flag, props;
		IGRlong       owners_index;
		struct        GRid owners_id;

		flag = 1;
		props = construct_list->properties | GRIS_NEW;
		sts = om$construct(classid = OPP_EMSgensolid_class_id,
		    		msg = message GRgraphics.GRchgprops(msg,
		    			&flag, &props), 
			p_objid = solid_id,
		    	osnum = space_number);
		if (! (1 & sts)) {
			*msg = MSFAIL;
			goto wrapup;
		}
		owners_id.objid = *solid_id;
		owners_id.osnum = space_number;
		owners_index = 0;
		sts = om$send(msg = message GRconnector.GRrigidconn(msg,
		    		&owners_id,
		    		&owners_index),
		    	senderid = my_stupid_id,
		    	targetid = sf_id,
		    	targetos = space_number);
		if ((! (1 & sts)) || (*msg != MSSUCC)) {
			*msg = MSFAIL;
			goto wrapup;
		}
		sts = om$send(msg = message GRconnector.GRrigidconn(msg,
		    		&owners_id, &owners_index),
		    	senderid = my_stupid_id,
		    	targetid = cp_sf_id,
		    	targetos = space_number);
		if ((! (1 & sts)) || (*msg != MSSUCC)) {
			*msg = MSFAIL;
			goto wrapup;
		}
	}

	/* Perform the lift and compress the resulting state tree */

	{
		struct        GRid surface_to_lift, local_mod;
		struct        GRid solid, compressed_solid;

		surface_to_lift.objid = cp_sf_id;
		surface_to_lift.osnum = space_number;
		sts = om$send(msg = message EMSsurface.EM_lift(msg,
		    		message EMSsf_lift.EMlift_face(msg, md_env,
		    		construct_list, from_point, to_point, 
				surface_to_lift, NULL, NULL, EMS_DO_DISPLAY, 
				NULL, NULL), &local_mod),
		    	senderid = my_stupid_id,
		    	targetid = *solid_id,
		    	targetos = space_number);
		if (! (1 & sts)) {
			*msg = MSFAIL;
			goto wrapup;
		}

		solid.objid = *solid_id;
		solid.osnum = space_number;
		sts = om$send(msg = message EMSsfdpr.EMadd(msg, &solid,
		    		NULL, md_env, NULL), 
			senderid = my_stupid_id,
		    	targetid = local_mod.objid,
		    	targetos = space_number);
		if (! (1 & sts)) {
			*msg = MSFAIL;
			goto wrapup;
		}
		sts = om$send(msg = message EMSdpr.EMmake_primitive1(msg,
		    		md_env, &compressed_solid),
		    	senderid = my_stupid_id,
		    	targetid = local_mod.objid,
		    	targetos = space_number);
		if (! (1 & sts)) {
			*msg = MSFAIL;
			goto wrapup;
		}

                if(!parallel_pls) {
		  /* Trim the solid with one/two plane(s) */
		  sts = EFplsolid_by_trimming_with_planes(&msg_loc,
		      opts, st_rp_flag, solid_id, compressed_solid.objid,
		      end_plane_info, (st_rp_flag) ? st_plane_info : NULL,
		      mid_point, construct_list);

		  if (! (1 & sts)) {
			*msg = MSFAIL;
			goto wrapup;
		  }
                }
                else {
                  strcpy(classname, "EMSsfsolid");
#ifdef DEBUG
printf("The Solid Class name to be constructed = %s\n", classname);
#endif
                  sts = om$change_class(objid = compressed_solid.objid,
                                     osnum = compressed_solid.osnum,
                                     classname = (char *)classname);
                  if (!(1 & sts)) {
                        *msg = MSFAIL;
                        goto wrapup;
                  }

                  *solid_id = compressed_solid.objid;
#ifdef DEBUG
printf("Change class successful\n");
#endif
                }
	}
wrapup:
	if(new_id.objid != NULL_OBJID) {
	    IGRlong      loc_msg;
	    sts = om$send(msg = message GRgraphics.GRdelete(&loc_msg,
			    md_env),
	   	senderid = NULL_OBJID,
		targetid = new_id.objid,
		targetos = space_number);
	}
	if(!(1 & *msg)) {
	    IGRlong      loc_msg;

	    if(sf_id != NULL_OBJID) {
		sts = om$send(msg = message GRgraphics.GRdelete(
				&loc_msg, md_env),
			senderid = my_stupid_id,
			targetid = sf_id,
			targetos = space_number);
	    }
	    if(cp_sf_id != NULL_OBJID) {
		sts = om$send(msg = message GRgraphics.GRdelete(
			    	&loc_msg, md_env),
			senderid = my_stupid_id,
			targetid = cp_sf_id,
			targetos = space_number);
	    }
	    if(*solid_id != NULL_OBJID) {
		sts = om$send(msg = message GRgraphics.GRdelete(
			    &loc_msg, md_env),
			senderid = my_stupid_id,
			targetid = *solid_id,
			targetos = space_number);
	    }		
	    return(FALSE);
	}
	else
		return(TRUE);
}

end implementation EMSsubbs;
