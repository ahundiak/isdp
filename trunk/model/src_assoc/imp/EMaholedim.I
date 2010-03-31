/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 * These are the autodimension methods for associative holes/countersink/
 * counterbore features
 *
 * History:
 *
 * Nilesh   08/06/96 Fix for TR 119424167 - Countersink angle with md=mm gets
                     multiplied with 25.4.
 * Samuel   08/05/93 Partial fix for TR 11925031 - option to change no. of
 *                   decimal palces of dimensions.
 * Sudha    06/01/93 modified to handle BSprototype headers
 * Tapadia  02/16/93 Support for dimensioning the diameter on the start surface
 *		     when a reference plane is selected - Fix for TR 11925801. 
 * DLB      01/06/93 Support partial delete of hole/cbore/csink.
 * Tapadia  07/24/92 Support of reference planes for circular holes
 * Nirmal   01/11/92 Depth is dimensioned using single parallel
 * Tapadia  11/26/91 Projected the center point onto the surface so as to 
 *                   place the dimension at the right position 
 * Tapadia  08/14/91 Support for different dimensioning standards
 * Tapadia  08/09/91 Support for blind holes/c-bores/c-sinks
 * Tapadia  07/25/91 Creation 
 *
 */

class implementation EMSslboolfea;

%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "dimdef.h"
#include "dim.h"
#include "igr.h"
#include "go.h"
#include "dimmacros.h"
#include "parametric.h"
#include "EMSdimdef.h"
#include "EMSas.h"
#include "EMSasnuc.h"
#include "EMSasfeatdef.h"
#include "EMSsfparms.h"
#include "EMSconstruct.h"
#include "dimplcmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include <string.h>
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"
#include "bsvalues.h"
#include "mascalvc.h"
#include "bsnorvec.h"
#include "bsmdistptsf.h"
#include "bsdotp.h"
#include "bscrossp.h"

#define COUNTERSINK 0
#define COUNTERBORE 1

#define TOP_VIEW    0
#define FRONT_VIEW  1
#define RIGHT_VIEW  2
#define NUM_VIEWS   3

#define DEG_TO_RAD M_PI/180

#define DIM_ANSI    0
#define DIM_ISO     1
#define DIM_BSI     2
#define DIM_JIS     3
#define DIM_DIN     4

from EMSparamgm   import EMgetgeom;
from EMSloopset import EMget_edges;
from EMSedge import EMendpts;
from expression import NDgive_value;
from DMroot import return_dim_go;
from EMSsubbs import EMget_unit_norm;
from EMSpartsupp import EMget_partial_suppress_id, EMget_comp_info;


/* This method calls the dimension macro for holes/c-bores/c-sinks.
For holes the dia & depth are dimensioned. For c-bores the hole dia, 
cbore dia & cbore depth are dimesnioned. For c-sinks the hole dia,
csink dia & csink angle are dimensioned */


method EMdim(IGRlong            *msg;
    struct GRmd_env             *mod_env;
    IGRushort                   options;
    IGRint                      type;
    IGRchar                     *info;
    IGRint                      num_parents;
    struct GRid                 *parents)
{
    IGRlong     status = OM_S_SUCCESS, msg_loc;
    IGRboolean  hole_flag, axis_normal, through_hole, ref_plane;
    IGRint      i, num_parts, part_type, var_par, surf_par;
    IGRint      txt_len, expr_count, p_in, hole_dia_index;
    IGRint      index, c_bore_dia_index, dep_ang_index, val_type, dim_type = -1;         
    IGRchar     txt_str1[50],txt_str2[50],txt_str3[50],pat_str[50],tmp_str[50]; 
    IGRpoint    origpt;
    IGRdouble   attach_point[3];
    IGRdouble   brk_pt[6], radius, angle, min_len;
    IGRvector   dim_plane_xaxis, y_axis, zaxis;
    extern void EFret_hole_cpart_data_mod();
    IGRushort hole_type, depth_type;
    struct EMSplace_hole *plhole_info;
    struct IGRplane dim_plane;
    struct GRid expr_list[3], my_grid, dim_grid, dim_grid_2; 
    struct GRid dim_grid_3, attach_grid;
    struct EMSgeomdata dim_geom;
    extern IGRdouble cos(), sin();
    struct DMsenv_param dim_par;
    IGRuint         g_comp_cnt=0;
    struct DMloc_param loc_param;


    msg_loc = *msg = EMS_S_Success;
    surf_par = 1; /* start surface */
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    dim_grid.objid = NULL_OBJID;
    dim_grid_2.objid = NULL_OBJID;
    dim_grid_3.objid = NULL_OBJID;
    expr_count = 1;

    /* Get's the data of EMslboolfea class  depending on type */
    EFret_hole_cpart_data_mod(msg, type, &hole_flag, &axis_normal,
                &var_par, &hole_type, &depth_type, &part_type,
                &through_hole, &ref_plane);

    EMerr_hndlr(!(1& *msg), *msg, EMS_E_Fail, ret_end);

    dm$get_dim_param(type = DM_SENV_PARAM,
                        dim_objid = NULL_OBJID,
                        dim_osnum = OM_Gw_current_OS,
                        p_data = &dim_par);

/* Fix for TR# 11925031 */
    status = dm$get_dim_param(
                        type = DM_LOC_PARAM,
                        dim_objid = NULL_OBJID,
                        dim_osnum = OM_Gw_current_OS,
                        p_data = (char *) &loc_param);
    if(loc_param.deci_frac == DECIMAL_MODE)
		sprintf (txt_str1,"Dia %%.%dlf",loc_param.primary.decacc);
    else
                strcpy(txt_str1,"Dia %.3lf");

    strcpy(txt_str2, txt_str1);
    strcpy(txt_str3, txt_str1);
/* end of fix */

    /* This is done so that the leader lines do not become smaller than the
    arrow (at the attach point when the radius is very small) */

    min_len = 3.0 * dim_par.txt_heig;

    if(hole_flag) { /* Holes */
        through_hole = TRUE; /* used to specify that it's not a blind hole */
        plhole_info = (struct EMSplace_hole *)info;
        num_parts = plhole_info->hole_count;
        axis_normal = plhole_info->axis_normal;

        if(hole_type == 2) { /* Profile hole */
        ex$message (msgnumb = EMS_I_ClearStatusField);
        goto ret_end;
        }
        p_in = num_parts + 1;
        index = p_in;
    }
    else { /* c-bores/c-sinks */
        num_parts = num_parents - surf_par - var_par;
        /* Index of c-bore/c-sink diameter in the parent list */
        p_in = num_parents - 3;
        /* Attach point is got based on hole diameter - first time */
        if(dim_par.dim_stan == DIM_BSI)
                index = -1;
        else if(dim_par.dim_stan == DIM_JIS) {
            if(part_type == COUNTERBORE)
                index = -1;
        }
        /* Attach point is got based on c-bore diameter - first time */
        else 
                index = -2;
    }

    {/*INTENTIONAL - DLB*/
      GRobjid         part_supp_id=NULL_OBJID;
      OM_S_CHANSELECT to_children;


      EMmake_chanselect(NDchildren_children, &to_children);
      status = om$send(msg = message EMSpartsupp.EMget_partial_suppress_id
                             (msg, &part_supp_id, NULL),
                       p_chanselect = &to_children);                 
      if (status == OM_W_UNKNOWN_MSG) status = OM_S_SUCCESS;
      else if (!(1&status&*msg)) goto ret_end;
                 
      if (part_supp_id != NULL_OBJID)
      {
        status = om$send(msg = message EMSpartsupp.EMget_comp_info(msg,
                                       &g_comp_cnt, NULL, NULL,
                                       NULL),  
                         targetid = part_supp_id);                 
        if (!(1&status&*msg)) goto ret_end;
      }
    }

    /*See if the entire group feature is suppressed/deleted*/ 
    if ((num_parts - g_comp_cnt) <= 0) goto ret_end;

    /* Get the plane & attach point. Then compute the break points for the
    first dimension (hole & c-bore/c-sink) */

    dim_plane.point = origpt;
    dim_plane.normal = zaxis;
    dim_geom.geomtype = GEOMDATA_NULL;

    status = om$send(msg = message EMSslboolfea.EMdimparam(msg,
                        mod_env, options, type, info,
                        num_parents, parents, index,
                        &dim_plane, dim_plane_xaxis,
                        &dim_geom, &dim_type),
                targetid = my_id);

    EMerr_hndlr(!(1&status&*msg), *msg, EMS_F_Fail, ret_end);

    BScrossp(&msg_loc, dim_plane.normal, dim_plane_xaxis, y_axis);
    BSnorvec(&msg_loc, y_axis);
    memcpy(attach_point, dim_geom.point, sizeof(IGRpoint));

    /* Get the hole or c-bore/c-sink radius */
    status = om$send(msg= message expression.NDgive_value(&radius),
                        senderid = NULL_OBJID,
                        targetid = parents[p_in].objid,
                        targetos = parents[p_in].osnum);

    EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);

    radius *= 0.5;
    if(radius < min_len)  radius = min_len;

    angle = 45 * DEG_TO_RAD;

    for(i = 0; i < 3; i++) {
        brk_pt[i] = attach_point[i] + radius * y_axis[i] * cos(angle) +
                radius * dim_plane_xaxis[i] * sin(angle);
    }
    for(i = 3; i < 6; i++) 
        brk_pt[i] = brk_pt[i - 3] + (0.5 * radius * dim_plane_xaxis[i - 3]);

    if(hole_flag) {
        /* For multiple holes - more like pattern features */
        if((num_parts-g_comp_cnt) > 1)
                sprintf(pat_str,"%dX ",num_parts-g_comp_cnt);
/*************
        if(depth_type != 3)
                strcpy(txt_str1,"Dia %.3lf THRU");
        else
                strcpy(txt_str1,"Dia %.3lf");
***************/

/* Fix for TR# 11925031*/
        if(depth_type != 3)
                strcat(txt_str1," THRU");
/* end of fix  */

        if((num_parts-g_comp_cnt) > 1) {
                strcat(pat_str,txt_str1);
                strcpy(txt_str1,pat_str);
        }
        txt_len = strlen(txt_str1);

        expr_list[0].objid = parents[p_in].objid;
        expr_list[0].osnum = parents[p_in].osnum;
        attach_grid.objid = expr_list[0].objid;
        attach_grid.osnum = expr_list[0].osnum;

        /* Dimension the diameter */
        dm$place_text_with_leader(attach_ele = &my_grid,
                                attach_pt = attach_point,
                                num_brkpt = 2,
                                brkpt = brk_pt,
                                text_length = txt_len,
                                text_string = txt_str1,
                                expr_count = expr_count,
                                expr_list = expr_list,
                                plane_grid = &my_grid,
                                owner = &attach_grid, 
                                dim_grid = &dim_grid);

        EMerr_hndlr(dim_grid.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
    } /* if hole flag */
    else { /* c-bore/c-sink */
        /* For multiple c-bores/c-sinks - more like pattern features */
        if((num_parts-g_comp_cnt) > 1)
                sprintf(pat_str,"%dX ",num_parts-g_comp_cnt);
        /* specify the hole diameter */

/*************************
        if(through_hole) {
            if(dim_par.dim_stan == DIM_BSI) 
                strcpy(txt_str1,"Dia %.3lf");
            else if(dim_par.dim_stan == DIM_JIS) { 
                if(part_type == COUNTERSINK)
                    strcpy(txt_str1,"Dia %.3lf");
                else
                    strcpy(txt_str1,"%.3lf drill ");
            } 
            else 
                strcpy(txt_str1,"Dia %.3lf THRU");
        }
        else {
            if(dim_par.dim_stan == DIM_JIS) {
                if(part_type == COUNTERBORE)
                    strcpy(txt_str1,"%.3lf drill ");
                else
                    strcpy(txt_str1,"Dia %.3lf");
            }
            else 
                strcpy(txt_str1,"Dia %.3lf");
        }
************************/

/* Fix for TR# 11925031 */
        if(through_hole) {
            if(dim_par.dim_stan == DIM_JIS) { 
                if(part_type != COUNTERSINK) {
		    strcpy(tmp_str, &txt_str1[4]);
		    strcpy(txt_str1, tmp_str);
                    strcat(txt_str1," drill ");
		}
            } 
            else if (dim_par.dim_stan != DIM_BSI)
                strcat(txt_str1," THRU");
        }
        else {
            if(dim_par.dim_stan == DIM_JIS) {
                if(part_type == COUNTERBORE) {
		    strcpy(tmp_str, &txt_str1[4]);
		    strcpy(txt_str1, tmp_str);
                    strcat(txt_str1," drill ");
		}
            }
        }
/* end of fix  */

        if((num_parts-g_comp_cnt) > 1) {
                strcat(pat_str,txt_str1);
                strcpy(txt_str1,pat_str);
        }
        txt_len = strlen(txt_str1);

        if(axis_normal) 
                hole_dia_index = num_parts; 
        else 
                hole_dia_index = num_parts + 1; 

        /* Hole diameter */
        expr_list[0].objid = parents[hole_dia_index].objid;
        expr_list[0].osnum = parents[hole_dia_index].osnum;
        attach_grid.objid = expr_list[0].objid;
        attach_grid.osnum = expr_list[0].osnum;

        /* Dimension the hole diameter */
        dm$place_text_with_leader(attach_ele = &my_grid,
                                attach_pt = attach_point,
                                num_brkpt = 2,
                                brkpt = brk_pt,
                                text_length = txt_len,
                                text_string = txt_str1,
                                expr_count = expr_count,
                                expr_list = expr_list,
                                plane_grid = &my_grid,
                                owner = &attach_grid, 
                                dim_grid = &dim_grid);

        EMerr_hndlr(dim_grid.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);

/***********************
        if(part_type == COUNTERSINK) {
            if(dim_par.dim_stan == DIM_BSI) 
                strcpy(txt_str2,"CSK AT %.3lf Deg.");
            else 
                strcpy(txt_str2,"Dia %.3lf");
        }
        else {
            if(dim_par.dim_stan == DIM_BSI) 
                strcpy(txt_str2,"CBORE Dia %.3lf");
            else if(dim_par.dim_stan == DIM_JIS) 
                strcpy(txt_str2,"%.3lf counterboring ");
            else 
                strcpy(txt_str2,"Dia %.3lf CBORE");

        }
********************/

/* Fix for TR# 11925031 */
        if(part_type == COUNTERSINK) {
            if(dim_par.dim_stan == DIM_BSI) {
                strcpy(tmp_str, &txt_str2[4]);
                strcpy(txt_str2,"CSK AT ");
                strcat(txt_str2, tmp_str);
                strcat(txt_str2, " Deg.");
	    }
        }
        else {
            if(dim_par.dim_stan == DIM_BSI) {
                strcpy(tmp_str, txt_str2);
                strcpy(txt_str2,"CBORE ");
                strcat(txt_str2, tmp_str);
	    }
            else if(dim_par.dim_stan == DIM_JIS) {
                strcpy(tmp_str, &txt_str2[4]);
                strcpy(txt_str2, tmp_str);
                strcat(txt_str2, " counterboring ");
	    }
            else {
                strcat(txt_str2," CBORE ");
	    }
        }
/* end of fix  */

        txt_len = strlen(txt_str2);
        
        /* CSK angle */
        if(dim_par.dim_stan == DIM_BSI && part_type == COUNTERSINK)  
                c_bore_dia_index = num_parents - 2;
        else 
                c_bore_dia_index = num_parents - 3;

        index = c_bore_dia_index;
        dim_plane.point = origpt;
        dim_plane.normal = zaxis;
        dim_geom.geomtype = GEOMDATA_NULL;

        /* Get the attach point for the cbore/csink diameter */
        status = om$send(msg = message EMSslboolfea.EMdimparam(msg,
                        mod_env, options, type, info,
                        num_parents, parents, index,
                        &dim_plane, dim_plane_xaxis,
                        &dim_geom, &dim_type),
                targetid = my_id);

        EMerr_hndlr(!(1&status&*msg), *msg, EMS_F_Fail, ret_end);

        memcpy(attach_point, dim_geom.point, sizeof(IGRpoint));

        expr_list[0].objid = parents[c_bore_dia_index].objid;
        expr_list[0].osnum = parents[c_bore_dia_index].osnum;
        attach_grid.objid = expr_list[0].objid;
        attach_grid.osnum = expr_list[0].osnum;
        
        /* Dimension the cbore/csink dia */
        dm$place_text_with_leader(attach_ele = &dim_grid,
                                attach_pt = attach_point,
                                num_brkpt = 0,
                                brkpt = NULL,
                                text_length = txt_len,
                                text_string = txt_str2,
                                expr_count = expr_count,
                                expr_list = expr_list,
                                plane_grid = &my_grid,
                                owner = &attach_grid, 
                                dim_grid = &dim_grid_2);

        EMerr_hndlr(dim_grid_2.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);

/*********************
        if(part_type == COUNTERSINK) {
            if(dim_par.dim_stan == DIM_BSI) 
                strcpy(txt_str3,"TO Dia %.3lf");
            else
                strcpy(txt_str3,"X %.3lf Deg. CSK");
        }
        else {
            if(dim_par.dim_stan == DIM_BSI) 
                strcpy(txt_str3,"X %.3lf");
            else if(dim_par.dim_stan == DIM_JIS) 
                strcpy(txt_str3,"depth %.3lf");
            else
                strcpy(txt_str3,"%.3lf DEEP");
        }
*************************/

/* Fix for TR# 11925031 */
        if(part_type == COUNTERSINK) {
            if(dim_par.dim_stan == DIM_BSI) {
                strcpy(tmp_str, txt_str3);
                strcpy(txt_str3,"TO ");
                strcat(txt_str3, tmp_str);
	    }
            else {
                strcpy(tmp_str, &txt_str3[4]);
                strcpy(txt_str3,"X ");
                strcat(txt_str3, tmp_str);
                strcat(txt_str3, " Deg. CSK");
	    }
        }
        else {
            if(dim_par.dim_stan == DIM_BSI) {
                strcpy(tmp_str, &txt_str3[4]);
                strcpy(txt_str3,"X ");
                strcat(txt_str3, tmp_str);
	    }
            else if(dim_par.dim_stan == DIM_JIS) {
                strcpy(tmp_str, &txt_str3[4]);
                strcpy(txt_str3,"depth ");
                strcat(txt_str3, tmp_str);
	    }
            else {
                strcpy(tmp_str, &txt_str3[4]);
                strcpy(txt_str3, tmp_str);
                strcat(txt_str3," DEEP");
	    }
        }
/* end of fix  */

        txt_len = strlen(txt_str3);
        
        /* CSK diameter */
        if(dim_par.dim_stan == DIM_BSI && part_type == COUNTERSINK)  
                dep_ang_index = num_parents - 3;
        else 
                dep_ang_index = num_parents - 2;

        index = dep_ang_index;
        dim_plane.point = origpt;
        dim_plane.normal = zaxis;
        dim_geom.geomtype = GEOMDATA_NULL;

        /* Get the attach point for the cbore depth/csink angle */
        status = om$send(msg = message EMSslboolfea.EMdimparam(msg,
                        mod_env, options, type, info,
                        num_parents, parents, index,
                        &dim_plane, dim_plane_xaxis,
                        &dim_geom, &dim_type),
                targetid = my_id);

        EMerr_hndlr(!(1&status&*msg), *msg, EMS_F_Fail, ret_end);

        memcpy(attach_point, dim_geom.point, sizeof(IGRpoint));

        expr_list[0].objid = parents[dep_ang_index].objid;
        expr_list[0].osnum = parents[dep_ang_index].osnum;
        attach_grid.objid = expr_list[0].objid;
        attach_grid.osnum = expr_list[0].osnum;
        
        /* Dimension the cbore depth/csink angle */
        if(part_type == COUNTERSINK)
          val_type = DIM_ANGLE;
        else
          val_type = DIM_DISTANCE;

        dm$place_text_with_leader(attach_ele = &dim_grid_2,
                                attach_pt = attach_point,
                                num_brkpt = 0,
                                brkpt = NULL,
                                text_length = txt_len,
                                text_string = txt_str3,
                                expr_count = expr_count,
                                expr_list = expr_list,
                                plane_grid = &my_grid,
                                owner = &attach_grid, 
                                value_type = val_type,
                                dim_grid = &dim_grid_3);

        EMerr_hndlr(dim_grid_3.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
        
    } /* if c-bore/s-sink */

    /* Depth for holes, counterbores & countersinks */

    if((hole_flag && depth_type == 3) || (!through_hole)) {
        struct GRid     assoc_id, source_id, dim_id;
        IGRpoint        dumpt;
        IGRint          trak_dir;

        dumpt[0] = dumpt[1] = dumpt[2] = 0.0;
        dim_id.objid = NULL_OBJID;
        assoc_id.objid = my_id;
        assoc_id.osnum = OM_Gw_current_OS;
        trak_dir = 1;

        EFget_parent_source (&assoc_id, &source_id);

        if(hole_flag)   p_in = num_parts + 2;
        else {
            if(axis_normal)     p_in = num_parts + 1;
            else        p_in = num_parts + 2;
        }

        dm$place_sglpara(orig_grid    = &source_id,
                           orig_pt      = dumpt,
                           plane_grid   = &source_id,
                           trak_dir     = trak_dir,
                           owner        = &parents[p_in],
                           dim_grid     = &dim_id);

        EMerr_hndlr(dim_id.objid == NULL_OBJID, *msg, EMS_E_Fail, ret_end);
    }

ret_end:
    EMWRAPUP (*msg, status, "EMSslboolfea.EMdim");
    return (status);
}

/* This method returns the geometry & plane information of holes/cbores/csinks
to the dimension macro */

method EMdimparam ( IGRlong            *msg; 
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
    IGRint             *dim_type )
{
    IGRlong     msg_loc, status, buf_size;
    OMuint      count;
    IGRint      i, j, k, rad_index, part_type, p_in,
                var_par, surf_par, num_parts, cbore_dia_index, ldr_index, 
                depth_index, ret_index, surf_index, tmp_index, ii=0;
    GRobjid     dia_id, hole_id;
    IGRdouble   radius, angle, new_text_pt[3], distance;
    OMuword     dum_os;
    IGRvector   x_axis, y_axis, z_axis, axis_nor;
    IGRboolean  hole_flag, axis_normal, through_hole , stat_func, ref_plane;
    extern IGRdouble cos(), sin();
    struct EMSgeomdata center, axis;
    struct EMSplace_hole *plhole_info;
    struct GRid surf_grid, text_grid, solid_grid;
    struct DMsenv_param dim_hei_param;
    struct IGRlbsys lbsys;
    struct IGRbsp_surface *surf;
    BSpair uv_point;
    IGRpoint xyz_point;
    IGRushort hole_type, depth_type;
    OM_S_CHANSELECT to_comps, to_father;
    OM_S_OBJECT_LINKAGE txt_ls, fir_ls;
    extern void EFret_hole_cpart_data_mod();
    void EFret_hole_cpart_XZ_axis();
    extern IGRlong EFpton_ref_plane();
    IGRulong location;

    if (ME.EMSdpr->dpr_props & EMS_NULL_STATE)
    {
      *msg = EMS_E_Fail;
      return(OM_S_SUCCESS);
    }

    *msg = EMS_S_Success;
    status = OM_S_SUCCESS;
    msg_loc = EMS_S_Success;
    surf = NULL;
    surf_par = 1; /* start surface */

    /* Get's the data of EMslboolfea class  depending on type */
    EFret_hole_cpart_data_mod(msg, type, &hole_flag, &axis_normal,
                        &var_par, &hole_type, &depth_type, &part_type,
                        &through_hole, &ref_plane);

    EMerr_hndlr(!(1& *msg), *msg, EMS_E_Fail, ret_end);

    status = EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, ret_end);

    status = EMmake_chanselect(NDfather_father, &to_father);
    EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, ret_end);

    if(dim_type) 
        *dim_type = TEXT_WITH_LEADER;

    if(hole_flag) { /* Holes */
        through_hole = TRUE; /* used to specify that it's not a blind hole */
        plhole_info = (struct EMSplace_hole *)info;
        num_parts = plhole_info->hole_count;
        axis_normal = plhole_info->axis_normal;
        if(depth_type == 1)     surf_index = num_parents - 2;
        else    surf_index = num_parents - 1;
        ret_index = num_parts + 1;      
    }
    else { /* c-bore/c-sink */
        num_parts = num_parents - surf_par - var_par;
        if(axis_normal) ret_index = num_parts;  /* Center(s) */
        else ret_index = num_parts + 1;         /* Axis */
        surf_index = num_parents - 1;
    }

    {/*INTENTIONAL - DLB*/
      GRobjid         part_supp_id=NULL_OBJID;
      IGRuint         g_comp_cnt=0, jj;
      OM_S_CHANSELECT to_children;
      IGRushort       *g_comp_indices=NULL;


      EMmake_chanselect(NDchildren_children, &to_children);
      status = om$send(msg = message EMSpartsupp.EMget_partial_suppress_id
                             (msg, &part_supp_id, NULL),
                       p_chanselect = &to_children);                 
      if (status == OM_W_UNKNOWN_MSG) status = OM_S_SUCCESS;
      else if (!(1&status&*msg)) goto ret_end;
                 
      if (part_supp_id != NULL_OBJID)
      {
        status = om$send(msg = message EMSpartsupp.EMget_comp_info(msg,
                                       &g_comp_cnt, NULL, &g_comp_indices,
                                       NULL),  
                         targetid = part_supp_id);                 
        if (!(1&status&*msg)) goto ret_end;

        for(ii=0; ii<num_parts; ii++)
        {
          for(jj=0; jj<g_comp_cnt; jj++)
          {
            if (ii == g_comp_indices[jj]) break;
          }
          if (jj == g_comp_cnt) break;  /*ii is a good index to use*/
        }
        if (g_comp_indices) om$dealloc(ptr = g_comp_indices);
      }

      /*Entire group fea may be suppress/deleted*/
      if ((num_parts - g_comp_cnt) <= 0) goto ret_end;
    }

    /* This is done for thru. until & blind holes. If it's a blind hole the 
    diameter is dimensioned at the surface & the depth dimensioning starts
    at the reference plane */

    if(hole_flag && ref_plane) {
	if(depth_type == 1 || depth_type == 3) {
	    if(hole_type == 1) /* Finite hole with V bottom */
		tmp_index = num_parents - index - 2;
	    else 
		tmp_index = num_parents - index - 1;
	}
	else 
		tmp_index = num_parents - index;
    }

    /* Common data computed for holes/c-bores/c-sinks */
    /* To place a dimension with respect to the center or axis */
    if(index >= 0) {
            if(index < ret_index) {
                status = om$send(mode = OM_e_wrt_parent,
                                msg = message EMSslboolfea.EMdimparam(msg, 
                                                mod_env, options, type, info,
                                                num_parents, parents, index,
                                                dim_plane, dim_plane_xaxis,
                                                dim_geom, dim_type),
                                        targetid = my_id);
                EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);
                goto ret_end;
            }
    }

    /* Get the center point of the first hole */
    status= om$send(msg = message EMSparamgm.EMgetgeom(msg, NULL,
                        &mod_env->md_env.matrix_type,
                        mod_env->md_env.matrix, &center),
                senderid = NULL_OBJID,
                targetid = parents[0].objid,
                targetos = parents[0].osnum);

    EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);

    /* Get the surface id */
    status = om$send(msg = message NDnode.ASreturn_go(&surf_grid,
                        &mod_env->md_env.matrix_type,
                        mod_env->md_env.matrix),
                senderid = NULL_OBJID,
                targetid = parents[surf_index].objid,
                targetos = parents[surf_index].osnum);

    EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, ret_end);

    /* Get the surface geometry */
    if(!ref_plane) {
        status = om$send(msg = message EMSsubbs.GRgetsize(&msg_loc, 
                        &mod_env->md_env.matrix_type,
                        mod_env->md_env.matrix, &buf_size),
                targetid = surf_grid.objid,
                targetos = surf_grid.osnum);

        EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, ret_end);

        surf = (struct IGRbsp_surface *) om$malloc(size = buf_size);
        if(!surf) {
                *msg = EMS_E_NoDynamicMemory;
                goto ret_end;
        }

        status = om$send(msg = message EMSsubbs.GRgetgeom(&msg_loc, 
                        &mod_env->md_env.matrix_type,
                        mod_env->md_env.matrix, (IGRchar *) surf),
                targetid = surf_grid.objid,
                targetos = surf_grid.osnum);

        EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, ret_end);

        /* project the point on the surface */
        stat_func = BSmdistptsf(&msg_loc, surf, center.point, 
                &uv_point[0], &uv_point[1], xyz_point, &distance);
    }
    else { /* Reference plane */
        struct GRlc_info ref_info;

        ref_info.module_info = *mod_env;
        ref_info.located_obj.objid = surf_grid.objid;
        ref_info.located_obj.osnum = surf_grid.osnum;
        status = EFpton_refplane(msg, &ref_info, center.point, 
                xyz_point);
        EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);

        /* Get the solid id */
	if(dim_geom && tmp_index == 2) {
		status = om$get_objid_at_index(objid = my_id,
			p_chanselect = &to_comps,
			index = 0,
			objidaddr = &solid_grid.objid,
			osnumaddr = &dum_os);
		if(!(1 & status)) goto ret_end;

		solid_grid.osnum = surf_grid.osnum;

		/* Find out if the point is inside the solid (case when the 
		reference plane is intersecting the solid). In that case we 
		don't worry about projecting the point onto the surface from 
		where the hole is punched */

		status = om$send(msg = message EMSsolid.EMpoint_locate(msg,
				mod_env, NULL, xyz_point, NULL, &location),
			senderid = NULL_OBJID,
			targetid = solid_grid.objid,
			targetos = solid_grid.osnum);

        	EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);
	}
    }
    OM_BLOCK_MOVE(xyz_point, center.point, sizeof(IGRpoint));

    /* Get the axis vector */
    if(hole_flag || (!hole_flag && !axis_normal)) {
        status= om$send(msg= message EMSparamgm.EMgetgeom(msg, NULL,
                                &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix, &axis),
                        senderid = NULL_OBJID,
                        targetid = parents[num_parts].objid,
                        targetos = parents[num_parts].osnum);

        EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);
    }

    /* Axis is normal to the surface */
    else if(!hole_flag && axis_normal) {
        /* Get the normal from the center & surface information */
        status = om$send(msg = message EMSsubbs.EMget_unit_norm(msg, FALSE, 
                        NULL, &mod_env->md_env, center.point, axis_nor),
                senderid = NULL_OBJID,
                targetid = surf_grid.objid,
                targetos = surf_grid.osnum);
/*
 * Ben returns a status of 2, if the point is not lying on the surface.
 * pp 08/24/91
 */
        if (status == 2) status = 1;

        EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);
        memcpy(axis.vector, axis_nor, sizeof(IGRvector));
    }

    /* If the reference point is outside the solid, then pass a ray thru. the 
    solid after obtaining the range points. The first intersection point is 
    taken as the attach point for the diameter dimensioning */

    if(hole_flag && ref_plane && dim_geom && tmp_index == 2) {
	if(location != EMS_S_INSOLID && location != EMS_S_ONSOLID) {
		struct IGRbsp_curve curve;
		IGRlong num_slots, num_intersect;
		struct GRparms *sf_inter_parm, *cv_inter_parm;
		IGRdouble *inter_pts, vec[3], check_dir, knots[4], poles[6];
		IGRulong *inter_props;
		GRrange range;
		IGRboolean world = TRUE;
		extern IGRboolean rlw_get_better_line();
		IGRpoint better_line[2], end_pt;
		struct IGRline line;

		sf_inter_parm = cv_inter_parm = NULL;
		inter_pts = NULL;
		inter_props = NULL;

		/* Obtain the solid range */
		status = om$send(msg = message GRvg.GRgetrang(&msg_loc, 
		    	&mod_env->md_env.matrix_type, 
		    	mod_env->md_env.matrix, 
		    	&world, range),
		    senderid = NULL_OBJID,
		    targetid = solid_grid.objid,
		    targetos = solid_grid.osnum);
		EMerr_hndlr(!(1&status&msg_loc), *msg, EMS_E_Fail, ret_end);

		vec[0] = xyz_point[0] + axis.vector[0];
		vec[1] = xyz_point[1] + axis.vector[1];
		vec[2] = xyz_point[2] + axis.vector[2];
		line.point1 = xyz_point;
		line.point2 = vec;

		stat_func = rlw_get_better_line(range, &line,better_line,
			&msg_loc);
		if(!stat_func) goto ret_end;
		
		vec[0] = better_line[1][0] - better_line[0][0];
		vec[1] = better_line[1][1] - better_line[0][1];
		vec[2] = better_line[1][2] - better_line[0][2];

		/* check the direction of axis vector */
		check_dir = vec[0] * axis.vector[0] + vec[1] * axis.vector[1] +
			vec[2] * axis.vector[2];

		/* Get the axis points */
		if(check_dir < 0)  
			OM_BLOCK_MOVE(better_line[0], end_pt,sizeof(IGRpoint)); 
		else 
	 		OM_BLOCK_MOVE(better_line[1], end_pt, sizeof(IGRpoint));

		/* Fill the IGRbsp_curve structure - for the ray */
		curve.poles = curve.knots = curve.weights = curve.bdrys = NULL;
		curve.poles = poles;
		curve.knots = knots;
		curve.order = curve.num_poles = 2;
		curve.num_knots = 4;
		curve.knots[0] = curve.knots[1] = 0.0;
		curve.knots[2] = curve.knots[3] = 1.0;
		curve.periodic = curve.rational = curve.phy_closed = FALSE;
		curve.non_uniform = curve.planar = TRUE;
		curve.num_boundaries = 0;
		OM_BLOCK_MOVE(xyz_point, curve.poles, sizeof(IGRpoint));
		curve.poles[3] = end_pt[0];
		curve.poles[4] = end_pt[1];
		curve.poles[5] = end_pt[2];

		num_slots = num_intersect = 0;

		/* Intersect the ray with the solid */
		status = om$send(msg = message EMSsolid.EMcrvsrfint(&msg_loc, 
		    	NULL, &mod_env->md_env,
		    	&curve, NULL, NULL, TRUE, &num_slots,
		    	&num_intersect, NULL, &sf_inter_parm,
		    	&cv_inter_parm, &inter_pts, &inter_props), 
		    senderid = NULL_OBJID,
		    targetid = solid_grid.objid,
		    targetos = solid_grid.osnum);
		EMerr_hndlr(!(1&status&msg_loc), *msg, EMS_E_Fail, ret_end);

		EMsort_by_parameter(sf_inter_parm, cv_inter_parm, inter_pts,
		    inter_props, num_intersect);
		
		if(num_intersect > 0) 
    		    	OM_BLOCK_MOVE(&inter_pts[0], center.point, 
				sizeof(IGRpoint));
	}
    }

    /* Returns the x & z axis */
    EFret_hole_cpart_XZ_axis(axis.vector, x_axis, z_axis);

    if(dim_plane) {
        memcpy(dim_plane->point,center.point,sizeof(IGRpoint));
        memcpy(dim_plane->normal,z_axis,sizeof(IGRvector));
    }
    if(dim_plane_xaxis) 
        memcpy(dim_plane_xaxis, x_axis, sizeof(IGRvector));

    if(hole_flag) { /* Hole specific computation */
        /* Get the radius */
        if(dim_geom) {
            if(depth_type != 3) 
                rad_index = index;
            else 
                rad_index = num_parts + 1;

            status = om$send(msg= message expression.NDgive_value(&radius),
                        targetid = parents[rad_index].objid,
                        targetos = parents[rad_index].osnum);

            EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, ret_end);

            radius *= 0.5;
            BScrossp(&msg_loc, z_axis, x_axis, y_axis);
            BSnorvec(&msg_loc, y_axis);
            angle = 45 * DEG_TO_RAD;

            dim_geom->geomtype = GEOMDATA_POINT;
            /* This attach point is used for first dimension */
            for( i = 0; i < 3; i++) {
                dim_geom->point[i] = center.point[i] + 
                        radius * y_axis[i] * cos(angle) + 
                        radius * x_axis[i] * sin(angle); 
            }
        } /* if dim_geom */
    } /* if hole flag */
    else { /* c-bore/c-sink specific computation */
        if(dim_geom) {
            if(axis_normal) p_in = num_parts;
            else  p_in = num_parts + 1;

            /* Attach point is got based on hole diameter */
            if(index == -1) 
                rad_index = p_in;
            /* Attach point is got based on cbore diameter */
            else if(index == -2)
                rad_index = num_parents - 3;
            else {
                status = om$get_objid_at_index(objid = my_id,
                                        p_chanselect = &to_father,
                                        index = p_in,
                                        objidaddr = &hole_id,
                                        osnumaddr = &dum_os);

                EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, ret_end);
        
                /* Dimension object (DMtxldr) Id is obtained to determine
                the previous dimensions standard */
                status = om$get_channel_objects(objid = hole_id, 
                                        osnum = OM_Gw_current_OS,
                                        p_chanselect = &to_comps,
                                        list = &fir_ls, size = 1, 
                                        count = &count);

                EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, ret_end);

                dm$get_dim_param(type = DM_SENV_PARAM,
                                dim_objid = fir_ls.S_objid,
                                dim_osnum = fir_ls.osnum,
                                p_data = &dim_hei_param);

                if(dim_hei_param.dim_stan == DIM_BSI) 
                        rad_index = p_in;
                else if(dim_hei_param.dim_stan == DIM_JIS && 
                        part_type == COUNTERBORE) 
                        rad_index = p_in;
                else
                        rad_index = num_parents - 3;
            }

            status = om$send(msg= message expression.NDgive_value(&radius),
                        targetid = parents[rad_index].objid,
                        targetos = parents[rad_index].osnum);

            EMerr_hndlr(!(1&status), *msg, EMS_E_Fail, ret_end);

            radius *= 0.5;
            BScrossp(&msg_loc, z_axis, x_axis, y_axis);
            BSnorvec(&msg_loc, y_axis);
            angle = 45 * DEG_TO_RAD;

            if(index == (num_parents - 3)) 
                cbore_dia_index = index;
            else
                cbore_dia_index = num_parents - 2;

            dim_geom->geomtype = GEOMDATA_POINT;
            /* This attach point is used for first dimension */
            if(index != cbore_dia_index) {
                for( i = 0; i < 3; i++) {
                        dim_geom->point[i] = center.point[i] + 
                                radius * y_axis[i] * cos(angle) + 
                                radius * x_axis[i] * sin(angle); 
                }
            }
            /* Compute the new attach point based on the previous dimension 
                text position */
            else {
                /* Parent Id is obtained */
                if(index == (num_parents - 3)) {
                    if(axis_normal) 
                        ldr_index = num_parts;
                    else
                        ldr_index = num_parts + 1;
                }
                else {
                    if(dim_hei_param.dim_stan == DIM_BSI && 
                        part_type == COUNTERSINK) { 
                        if(axis_normal) 
                                ldr_index = num_parts;
                        else
                                ldr_index = num_parts + 1;
                    }
                    else
                        ldr_index = num_parents - 3; 
                }

                status = om$get_objid_at_index(
                                objid = my_id,
                                p_chanselect = &to_father,
                                index = ldr_index,
                                objidaddr = &dia_id,
                                osnumaddr = &dum_os);

                EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, ret_end);

                /* Dimension object (DMtxldr) Id is obtained */
                status = om$get_channel_objects(objid = dia_id, 
                                osnum = OM_Gw_current_OS,
                                p_chanselect = &to_comps,
                                list = &txt_ls, size = 1, count = &count);

                EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, ret_end);

                /* Text (DMtext) object Id is obtained */
                status = om$send(msg = message DMroot.return_dim_go(
                                (IGRint *)msg, DIM_TEXT, FALSE, DM_TEXT,
                                        mod_env, &text_grid),
                                senderid = NULL_OBJID,
                                targetid = txt_ls.S_objid,
                                targetos = txt_ls.osnum);

                EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_OMerror, ret_end);

                /* Text position is got */
                status = om$send(msg = message GRvg.GRgetgeom(msg,
                                &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix,
                                (IGRchar *)&lbsys),
                        senderid = NULL_OBJID,

                        targetid = text_grid.objid,
                        targetos = text_grid.osnum);

                EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, ret_end);

                /* Dimension parameters is got from previous dimension */
                dm$get_dim_param(type = DM_SENV_PARAM,
                                dim_objid = txt_ls.S_objid,
                                dim_osnum = txt_ls.osnum,
                                p_data = &dim_hei_param);

                /* Based on the parttype & the dimension standard calculate
                the textposition */
                for(j = 0; j < 3; j++) {
                    k = j + (3 * j); 
                    if(part_type == COUNTERBORE) {
                        if(dim_hei_param.dim_stan == DIM_BSI ||
                          dim_hei_param.dim_stan == DIM_JIS)
                                new_text_pt[j] = lbsys.diag_pt2[0] * 
                                        lbsys.matrix[k] + lbsys.diag_pt2[1] *
                                        lbsys.matrix[k+1] + lbsys.diag_pt2[2] *
                                        lbsys.matrix[k+2] + lbsys.matrix[k+3];
                        else
                                new_text_pt[j] = lbsys.diag_pt1[0] * 
                                        lbsys.matrix[k] + lbsys.diag_pt1[1] *
                                        lbsys.matrix[k+1] + lbsys.diag_pt1[2] *
                                        lbsys.matrix[k+2] + lbsys.matrix[k+3];
                    }
                    else {
                        if(index == (num_parents - 2)) 
                                new_text_pt[j] = lbsys.diag_pt2[0] * 
                                        lbsys.matrix[k] + lbsys.diag_pt2[1] *
                                        lbsys.matrix[k+1] + lbsys.diag_pt2[2] *
                                        lbsys.matrix[k+2] + lbsys.matrix[k+3];
                        else 
                                new_text_pt[j] = lbsys.diag_pt1[0] * 
                                        lbsys.matrix[k] + lbsys.diag_pt1[1] *
                                        lbsys.matrix[k+1] + lbsys.diag_pt1[2] *
                                        lbsys.matrix[k+2] + lbsys.matrix[k+3];
                    }   
                }
                for( i = 0; i < 3; i++) {
                    if(part_type == COUNTERBORE) {
                        if(dim_hei_param.dim_stan == DIM_BSI ||
                           dim_hei_param.dim_stan == DIM_JIS)
                                dim_geom->point[i] = new_text_pt[i] - 
                                        fabs(y_axis[i]) * 1.4 * 
                                        dim_hei_param.txt_heig + 
                                        fabs(x_axis[i]) * 
                                        dim_hei_param.txt_widt;
                        else 
                                dim_geom->point[i] = new_text_pt[i] - 
                                        fabs(y_axis[i]) * 1.5 * 
                                        dim_hei_param.txt_heig;
                    }
                    else {
                        if(index == (num_parents - 2)) 
                                dim_geom->point[i] = new_text_pt[i] - 
                                        fabs(y_axis[i]) * 1.4 * 
                                        dim_hei_param.txt_heig + 
                                        fabs(x_axis[i]) * 
                                        dim_hei_param.txt_widt;
                        else 
                                dim_geom->point[i] = new_text_pt[i] - 
                                        fabs(y_axis[i]) * 1.5 * 
                                        dim_hei_param.txt_heig;
                    } /* else */
                } /* for */
            } /* else */
        } /*if dim_geom */
    } /* else */

    /* This computes the data for dimensioning the depth */
   
    if(hole_flag) 
        depth_index = num_parts + 2;
    else {
        if(axis_normal) depth_index = num_parts + 1;
        else  depth_index = num_parts + 2;
    }
    if(((hole_flag && depth_type == 3) || (!through_hole)) && depth_index ==
        index) {

        IGRdouble           depth, c_bore_sink_radius ;
        IGRvector           depth_vector;
        IGRpoint            depth_point;
        IGRint              dep_index;

        status = om$send(msg = message expression.NDgive_value(&depth),
                       targetid = parents[depth_index].objid,
                       targetos = parents[depth_index].osnum);

        EMerr_hndlr (EMSerror (status), *msg, EMS_E_Fail, ret_end);

        BSnorvec(&msg_loc, axis.vector);
        MAscalvc ( &msg_loc, &depth, axis.vector, depth_vector);
        BScrossp(&msg_loc,axis.vector,x_axis,y_axis);
        BSnorvec(&msg_loc, y_axis);
        BScrossp(&msg_loc,axis.vector,y_axis,x_axis);
        BSnorvec(&msg_loc, x_axis);
        for(i=0; i<3; ++i)
                depth_point[i] = center.point[i] + depth_vector[i];

        if(dim_type)
                *dim_type =  SINGLE_PARALLEL;

        if(dim_plane) {
                memcpy(dim_plane->point, depth_point, sizeof(IGRpoint));
                memcpy(dim_plane->normal, y_axis, sizeof(IGRvector));
        }

        if(dim_plane_xaxis)
                memcpy (dim_plane_xaxis, x_axis, sizeof (IGRvector));

        if(dim_geom) {
            if(hole_flag) 
                dep_index = rad_index;
            else
                dep_index = num_parents - 3; /* the counter bore radius */
        
            status = om$send(msg = message expression.NDgive_value
                                (&c_bore_sink_radius),
                       targetid = parents[dep_index].objid,
                       targetos = parents[dep_index].osnum );

            EMerr_hndlr(EMSerror(status), *msg, EMS_E_Fail, ret_end);

            c_bore_sink_radius /= 2.0;
 
            dim_geom->geomtype = GEOMDATA_LINE;
            dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

            for(i=0; i<3; ++i) {
                dim_geom->line.line_pt1[i] = center.point[i] + 
                        (c_bore_sink_radius * x_axis[i]);
                dim_geom->line.line_pt2[i] = depth_point[i] + 
                        (c_bore_sink_radius * x_axis[i]);
            }
        }
    }

ret_end:
    if(surf) om$dealloc(ptr = surf);
    EMWRAPUP (*msg, status, "EMSslboolfea.EMdimparam");
    return(status);
}

/* Tapadia - 08/04/91 - This function returns the x & z axis to be used for
determining the dimension plane. The dot product of the feature axis & the
standard view normal is computed. */

void EFret_hole_cpart_XZ_axis(fea_axis, xaxis, zaxis)
        IGRvector fea_axis, xaxis, zaxis;
{
        IGRint          i, best_view_index;
        IGRvector       *view_vec, *best_view;
        IGRdouble       sum, best_sum = 0.0;
        BSrc            bsrc;
/* Automatic aggregate initialization not allowed by SUN c compiler - Ashok */
        IGRvector           top /* ={0,0,1}*/,
                            front /* ={0,1,0} */,
                            right /*={1,0,0} */;

	view_vec = NULL;
	best_view = NULL;
        top[0]=0.0; top[1]=0.0; top[2]=1.0;
        front[0]=0.0; front[1]= -1.0; front[2]=0.0;
        right[0]=1.0; right[1]=0.0; right[2]=0.0;

        for(i = 0; i < NUM_VIEWS; i++) {
                if(i == TOP_VIEW) view_vec = (IGRvector *) top;
                else if(i == FRONT_VIEW) view_vec = (IGRvector *) front;
                else if(i == RIGHT_VIEW) view_vec = (IGRvector *) right;

                sum = BSdotp(&bsrc, view_vec[0], fea_axis);
                sum = fabs(sum);

                if(sum > best_sum) {
                        best_sum = sum;
                        best_view = view_vec;
                        best_view_index = i;
                }
        }

	/* The best view which can be obtained */
	if(best_view) {
    	    memcpy(zaxis, best_view, sizeof(IGRvector));

    	    if(best_view_index == TOP_VIEW || best_view_index == FRONT_VIEW) {
		xaxis[0] = 1.0;
		xaxis[1] = 0.0;
    	    }
    	    else {
		xaxis[0] = 0.0;
		xaxis[1] = 1.0;
    	    }
	    xaxis[2] = 0.0;
	}
	else { /* assigning the front view as the best view */
		zaxis[0] = 0.0;
		zaxis[1] = -1.0;
		zaxis[2] = 0.0;
		xaxis[0] = 1.0;
		xaxis[1] = 0.0;
		xaxis[2] = 0.0;
	}
} /* EFret_hole_cpart_XZ_axis() */

end implementation EMSslboolfea;


