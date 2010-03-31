/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  This is the autodimension method for finite slot
 *
 * HISTORY:
 *
 *  Tapadia  Creation  	10/11/91
 *  Sudha   06/01/93    modified to handle BSprototype headers
 */
class implementation EMSslslotfea;

#include "OMmacros.h"
#include "dimdef.h"
#include "EMSasfeatdef.h"
#include "dimplcmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "mabcmidpt.h"
#include "bserr.h"
#include "bscvnormal.h"

from expression import NDgive_value;


extern OMuword OPP_DMroot_class_id;

/* This method calls the appropriate auto dimensioning */

method EMdim(IGRlong        *msg;
     	struct GRmd_env     *mod_env;
        IGRushort   options;
        IGRint              type;
        IGRchar             *info;
        IGRint              num_parents;
        struct GRid         *parents )
{
    	IGRlong     	om_msg = OM_S_SUCCESS;
    	struct GRid    	dim_id, source_id, assoc_id;
	IGRpoint   	dumpt;
	IGRint     	trak_dir;	

    	*msg = EMS_S_Success;

	dumpt[0] = dumpt[1] = dumpt[2] = 0.0;
	assoc_id.objid = my_id;
	assoc_id.osnum = OM_Gw_current_OS;

	if(type != EMS_AS_FINITE_SLOT_TYPE) { /* Not a finite slot */
         ex$message ( msgnumb = EMS_S_ClearStatusField);
         goto ret_end;
	}

	EFget_parent_source(&assoc_id, &source_id);

    	/* Perform auto-dimensioning */
	if(!(EFselect_first_component(&parents[1], OPP_DMroot_class_id, 
			&dim_id) & 1)) {
		dim_id.objid = NULL_OBJID;
		trak_dir = 1;
		
		dm$place_sglpara(orig_grid  = &source_id,
				orig_pt     = dumpt,
				 plane_grid = &source_id,
				 trak_dir   = trak_dir,
				 owner      = &parents[1],
				 dim_grid   = &dim_id);

		EMerr_hndlr(dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail,
			ret_end);
	}

ret_end:
    	EMWRAPUP (*msg, om_msg, "EMSslslotfea.EMdim");
    	return (om_msg);
}

/* This method returns the geometry, plane & axis to the dimensioning macro */

method EMdimparam(IGRlong  *msg; 
 	struct GRmd_env    *mod_env;
        IGRushort  options;
        IGRint             type;
        IGRchar            *info;
        IGRint             num_parents;
        struct GRid        *parents;
        IGRint             index; 
        struct IGRplane    *dim_plane;
        IGRdouble          *dim_plane_xaxis;
        struct EMSgeomdata *dim_geom;
        IGRint             *dim_type)
{
    	IGRlong             buf_size, om_msg = OM_S_SUCCESS;
    	IGRint              i;
    	IGRdouble           height; 
    	IGRvector           x_axis, y_axis, z_axis, cur_nor;
    	IGRpoint            point1, point2, cur_mid_pt;
    	struct EMSgeomdata  direction;
    	GRclassid           classid;
    	struct GRid         curve;
        extern OMuword OPP_GRcompcurve_class_id;
	struct IGRbsp_curve *cur_geom = NULL;
	IGRboolean 	    is_slot_dir_rev, is_composite = FALSE;
	struct EMSplace_slot *plslot_info;

    	*msg = EMS_S_Success;

	/* get the slot direction from recomputation info */
	plslot_info = (struct EMSplace_slot *)info;
	is_slot_dir_rev = plslot_info->pro_nor_rev;

	/* Obtain the curve information */
    	om_msg = om$send(msg = message NDnode.ASreturn_go 
                          	(&curve, &mod_env->md_env.matrix_type,
                               	mod_env->md_env.matrix ),
                       targetid = parents[0].objid,
                       targetos = parents[0].osnum );

	EMerr_hndlr(!(1&om_msg), *msg, EMS_E_Fail, ret_end);

	/* Get the curve size & geometry */
	om_msg = om$send(msg = message GRvg.GRgetsize(msg,
			&mod_env->md_env.matrix_type,
			mod_env->md_env.matrix,
			&buf_size),
		senderid = NULL_OBJID,
		targetid = curve.objid,
		targetos = curve.osnum);

   	EMerr_hndlr (!(1&om_msg&*msg),*msg,EMS_E_Fail,ret_end);

	cur_geom = (struct IGRbsp_curve *) om$malloc(size = buf_size);
	if(!cur_geom) {
		om_msg = EMS_E_Fail;
		goto ret_end;
	}

	om_msg = om$send(msg = message GRvg.GRgetgeom(msg,
			&mod_env->md_env.matrix_type,
			mod_env->md_env.matrix,
			(IGRchar *)cur_geom),
		senderid = NULL_OBJID,
		targetid = curve.objid,
		targetos = curve.osnum);

   	EMerr_hndlr (!(1&om_msg&*msg),*msg,EMS_E_Fail,ret_end);

	/* curve normal */
	BScvnormal2(msg, cur_geom, cur_nor);

	/* reverse the normal if it's requested by the user */
	if(is_slot_dir_rev) {
		cur_nor[0] *= -1;
		cur_nor[1] *= -1;
		cur_nor[2] *= -1;
	}

	memcpy(direction.vector, cur_nor, sizeof(IGRvector));

	/* Get the slot depth parameter */
        om_msg = om$send ( msg = message expression.NDgive_value  ( &height ),
                           targetid = parents[1].objid,
                           targetos = parents[1].osnum );

	EMerr_hndlr(!(1&om_msg), *msg, EMS_E_Fail, ret_end);

	/* check if it's a composite curve */
	*msg = om$get_classid(objid = curve.objid,
			osnum = curve.osnum,
			p_classid = &classid);
	EMerr_hndlr(!(1 & *msg), *msg, EMS_E_OMerror, ret_end);

	om_msg = om$is_ancestry_valid(subclassid = classid,
			superclassid = OPP_GRcompcurve_class_id);

	if(om_msg == OM_S_SUCCESS)
		is_composite = TRUE;

	/* take the end point of the first segment */
	if(is_composite) {
		point1[0] = cur_geom->poles[3];
		point1[1] = cur_geom->poles[4];
		point1[2] = cur_geom->poles[5];
	}
	else { /* get the mid point of the curve */
		MAbcmidpt(msg, cur_geom, cur_mid_pt);
		if(!(1&*msg)) goto ret_end;
		point1[0] = cur_mid_pt[0];
		point1[1] = cur_mid_pt[1];
		point1[2] = cur_mid_pt[2];
	}

        for(i = 0; i < 3; ++i) {
            point2[i] = point1[i] + (direction.vector[i] * height);
            x_axis[i] = point1[i] - point2[i];
        }

        EFget_normal_from_axis ( msg, 
                                 &parents[1],
                                 mod_env, 
                                 x_axis,  /* In/Out */
                                 y_axis, 
                                 z_axis );
        if (dim_type)
            	*dim_type = SINGLE_PARALLEL;

        if (dim_plane) {
            	memcpy (dim_plane->point, point1, sizeof(IGRpoint));
            	memcpy (dim_plane->normal, z_axis, sizeof (IGRvector));
        }

        if (dim_plane_xaxis)
            	memcpy (dim_plane_xaxis, x_axis, sizeof (IGRvector));

        if (dim_geom) {
            	dim_geom->geomtype = GEOMDATA_LINE;
            	dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            	dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

            	memcpy (dim_geom->line.line_pt1, point1, sizeof(IGRpoint));
            	memcpy (dim_geom->line.line_pt2, point2, sizeof(IGRpoint));
        }

ret_end:
  	EMWRAPUP (*msg, om_msg, "EMSslslotfea.EMdimparam");
/* fix for mlk */
    if(cur_geom)
      {
      om$dealloc(ptr = cur_geom);
      cur_geom = NULL;
      }
  	return (om_msg);
}

end implementation EMSslslotfea;
