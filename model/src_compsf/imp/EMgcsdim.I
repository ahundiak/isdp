/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for general composite surfaces.
 *
 * HISTORY:
 *
 *  WBC    Added a call to BSfreecv to free geom_surface.sfgen_cv 01/08/93
 *  WBC    Replaced the call to BSmdistptsf with a call to BSprptarrsf 01/08/93
 *  DLB    mod fillet to use txt-w-leader 9/15/91
 *  jhw    Creation         06/12/91
 *  Sudha      06/21/93     Modified to handle BSprototype ansification
 *  Sudhakar   31Jul'93     Modified to handle auto-dimensioning of 
 *                          composite offset surfaces with multiple offset
 *                          distances.
 *  Sudhakar   20Sep'93     Fixed a problem with auto-dimensioning for
 *                          multiple offset distances. 
 *  Sudhakar   24Sep'93     Modified to handle changed 'recompute' info
 *                          for 'EMS_ASsurface_by_offsetting_surface' type.
 *                          Modified 'auto-dimensioning' to work without
 *                          edge parents.
 *  Satya      05 Nov 93    Modified dm$place_text_with_leader. It now has
 *			    one new argument value_type -- TR 119307898
 *  Sudhakar   27 Nov 93    Modified args of the function
 *                          'EFget_edge_near_point_on_sf'.
 *  Sudhakar   23 Dec 93    Speeded up the auto-dimensioning by avoiding 
 *                          projections.
 */
class implementation EMSgencompsf;

#include "OMmacros.h"
#include "dimdef.h"
#include "gocmacros.h"
#include "bserr.h"
#include "dimplcmacros.h"
#include "REsfsolid.h"
#include "bsgeom_cvsf.h"
#include "bsparameters.h"
#include "bssfptseval.h"
#include "bsprptarrsf.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsconstprcv.h"
#include "bsmdistptsf.h"
#include "dimmacros.h"
#include "REgencompsf.h"
#include "EMSssprops.h"

#define SURFACE1        0
#define SURFACE2        1
#define START_POINT     2
#define START_RADIUS    3
#define END_POINT       4
#define END_RADIUS      5

#define SURFACE         0
#define OFFSET          1

#define CURVE           0
#define HEIGHT          1
#define DIRECTION       2
#define ANGLE           3

#define WBC_USE_NEW_MATH 1

#define XYZ_POINT   1
#define UV_POINT    2

#define USE_PROJECT 1
#define USE_KEY     2

#define REVERSE_NORMAL 1

from EMSparamgm import EMgetgeom;
from expression import NDgive_value;
from EMSsubbs import EMget_props;
from GRcurve import GRendpts;

extern OMuword OPP_DMroot_class_id;

method EMdim ( IGRlong             * msg;
               struct GRmd_env     * mod_env;
               IGRushort     options;
               IGRint                type;
               IGRchar             * info;
               IGRint                num_parents;
               struct GRid         * parents )
{
    IGRlong       om_msg = OM_S_SUCCESS, msg_loc;
    struct GRid   assoc_id, source_id, dim_id;
    IGRpoint      dumpt;
    IGRint        trak_dir;

    msg_loc = *msg = EMS_S_Success;

    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    /*
     * Perform the appropriate auto-dimensioning.
     */
    switch (type)
    {
    /*-----------------------------------------------------------*/
    /* added to support new fillet surface types. 08/20/93 : JSY */
    /*-----------------------------------------------------------*/
    case EMS_ASfillet_by_edge_radii:
    case EMS_ASfillet_by_edge_radii_w_track_pt:
    case EMS_ASfillet_by_surface_surface_radii:
    case EMS_ASfillet_by_surface_surface_radii_w_track_pt:
    case EMS_ASfillet_by_edge_radius:
    case EMS_ASfillet_by_edge_radius_w_track_pt:
    case EMS_ASfillet_by_surface_surface_radius:
    case EMS_ASfillet_by_surface_surface_radius_w_track_pt:
    case EMS_ASfillet_by_curve_surface_radius:
    case EMS_ASfillet_by_curve_surface_radius_w_track_pt:
      {
	IGRdouble          attach_pt[3];
	IGRpoint           orig_pt;
	IGRdouble          break_pt[6], radius1, radius2, radius3, flip, dotp;
	IGRvector          dim_plane_xaxis, z_axis;
	IGRint             radius_index1, radius_index2, radius_index3;
	IGRint             dim_type = -1, expr_count, txt_len;
	OMuint             num_radius, cur_rad, ii, jj;
	BSrc               bsrc;
	struct IGRplane    dim_plane;
	struct EMSgeomdata dim_geom;
	struct GRid        expr_list, my_grid, attach_grid;
	IGRchar            txt_str[100];

	/* shut off compiler warning */
	radius_index1 = radius_index2 = radius_index3 = 0;

	num_radius = 1;	/* number of radius for dimensioning */
	
	if (type == EMS_ASfillet_by_edge_radius ||
	    type == EMS_ASfillet_by_edge_radius_w_track_pt)
	  radius_index1 = 1;
	else if (type == EMS_ASfillet_by_surface_surface_radius ||
	         type == EMS_ASfillet_by_surface_surface_radius_w_track_pt)
	  radius_index1 = 2;
	else if (type == EMS_ASfillet_by_edge_radii ||
	         type == EMS_ASfillet_by_edge_radii_w_track_pt)
	  radius_index1 = 3;
	else if (type == EMS_ASfillet_by_surface_surface_radii ||
	         type == EMS_ASfillet_by_surface_surface_radii_w_track_pt)
	  radius_index1 = 4;
	else
	  radius_index1 = 2;
	
	/*
	 * If the sweep radius is not already dimensioned ...
	 */
	if (!(EFselect_first_component(&parents[radius_index1],
				       OPP_DMroot_class_id, 
				       &dim_id ) & 1))
	{
	  my_grid.objid = my_id;
	  my_grid.osnum = OM_Gw_current_OS;

	  dim_id.objid = NULL_OBJID;
	  dim_geom.geomtype = GEOMDATA_NULL;

	  dim_plane.point = orig_pt;
	  dim_plane.normal = z_axis;

	  om_msg = om$send(msg = message EMSdim.EMdimparam(msg,
							   mod_env,
							   options,
							   type,
							   info,
							   num_parents,
							   parents, 
							   radius_index1,
							   &dim_plane,
							   dim_plane_xaxis,
							   &dim_geom,
							   &dim_type), 
			   targetid = my_id);
	  if (!(1 & om_msg & *msg)) goto ret_end;
	  
	  OM_BLOCK_MOVE(dim_geom.point, attach_pt, sizeof(IGRpoint));
  
	  /* Get the fillet radius */
	  om_msg = om$send(msg= message expression.NDgive_value(&radius1),
			   targetid = parents[radius_index1].objid,
			   targetos = parents[radius_index1].osnum);
	  if (!(1 & om_msg)) goto ret_end;

	  if (type == EMS_ASfillet_by_edge_radii ||
	      type == EMS_ASfillet_by_edge_radii_w_track_pt ||
	      type == EMS_ASfillet_by_surface_surface_radii ||
	      type == EMS_ASfillet_by_surface_surface_radii_w_track_pt)
	  {
	    num_radius++;

	    if (type == EMS_ASfillet_by_edge_radii ||
		type == EMS_ASfillet_by_edge_radii_w_track_pt)
	    {
	      radius_index2 = 4;

	      if (type == EMS_ASfillet_by_edge_radii &&
		  num_parents == 7 ||
		  type == EMS_ASfillet_by_edge_radii_w_track_pt &&
		  num_parents == 8)
	      {
		radius_index3 = 5;
		num_radius++;
	      }
	    }
	    else
	    {
	      radius_index2 = 5;

	      if (type == EMS_ASfillet_by_surface_surface_radii &&
		  num_parents == 10 ||
		  type == EMS_ASfillet_by_surface_surface_radii_w_track_pt &&
		  num_parents == 11)
	      {
		radius_index3 = 9;
		num_radius++;
	      }
	    }

	    /* Get the ending fillet radius */
	    om_msg = om$send(msg= message expression.NDgive_value(&radius2),
			     targetid = parents[radius_index2].objid,
			     targetos = parents[radius_index2].osnum);
	    if (!(1 & om_msg)) goto ret_end;

	    if (num_radius == 3)
	    {
	      /* Get the fillet maxmin radius */
	      om_msg = om$send(msg= message expression.NDgive_value(&radius3),
			       targetid = parents[radius_index3].objid,
			       targetos = parents[radius_index3].osnum);
	      if (!(1 & om_msg)) goto ret_end;
	    }
	  }

	  dotp = BSdotp(&bsrc, dim_geom.vector, dim_plane_xaxis);
	  
	  if (dotp < 0) flip = -1.0;
	  else flip = 1.0;
	  
	  strcpy(txt_str, "R %4.3lf");      
	  txt_len = strlen(txt_str);
	  
	  cur_rad = radius_index1;
	  for (ii = 0; ii < num_radius; ii++)
	  {
	    if (ii == 1)
	    {
	      radius1 = radius2;
	      cur_rad = radius_index2;
	    }
	    else if (ii == 2)
	    {
	      radius1 = radius3;
	      cur_rad = radius_index3;
	    }
	    
	    for (jj = 0; jj < 3; jj++)
	    {
	      break_pt[jj] = attach_pt[jj] + 
		dim_geom.vector[jj] * radius1 * 0.85; 
	    }
	    
	    for (jj = 3; jj < 6; jj++)
	    {
	      break_pt[jj] = break_pt[jj - 3] + 
		(flip * radius1 * dim_plane_xaxis[jj - 3]);  
	    }
	    
	    expr_list.objid = parents[cur_rad].objid;
	    expr_list.osnum = parents[cur_rad].osnum;
  
	    attach_grid.objid = parents[cur_rad].objid;
	    attach_grid.osnum = parents[cur_rad].osnum;
	    expr_count = 1;
  
	    dm$place_text_with_leader(attach_ele = &my_grid,
				      attach_pt = attach_pt,
				      num_brkpt = 2,
				      brkpt = break_pt,
				      text_length = txt_len,
				      text_string = txt_str,
				      expr_count = expr_count,
				      expr_list = &expr_list,
				      plane_grid = &my_grid,
				      owner = &attach_grid, 
				      dim_grid = &dim_id);
	    if (dim_id.objid == NULL_OBJID)
	    {
	      *msg = EMS_E_Fail;
	      goto ret_end;
	    }
	  }
	}
      }
      break;

        case EMS_ASfillet_by_surfaces_and_radii:
        case EMS_ASfillet_by_surfaces_and_radii_w_track_pt:
        {
          IGRdouble         attach_pt[3];
          IGRpoint          orig_pt;
          IGRdouble         break_pt[6], radius1, radius2, flip, dotp;   
          IGRvector         dim_plane_xaxis, z_axis;
          IGRint            dim_type=-1, expr_count, txt_len;
          OMuint            cur_rad, ii, jj;
          BSrc              bsrc;
          struct IGRplane   dim_plane;
          struct EMSgeomdata dim_geom;
          struct GRid       expr_list, my_grid, attach_grid;
          IGRboolean        not_const=FALSE;
          IGRchar           txt_str[100];

          /*
           * If the sweep radius is not already dimensioned ...
           */
          if (!(EFselect_first_component(&parents[START_RADIUS], 
                                         OPP_DMroot_class_id, 
                                         &dim_id ) & 1))
          {
            my_grid.objid = my_id;
            my_grid.osnum = OM_Gw_current_OS;

            dim_id.objid = NULL_OBJID;
            dim_geom.geomtype = GEOMDATA_NULL;

            dim_plane.point = orig_pt;
            dim_plane.normal = z_axis;

            om_msg = om$send(msg = message EMSdim.EMdimparam(msg,
                                   mod_env, options, type, info, num_parents,
                                   parents, 
                                   START_RADIUS /*Parent paramval index*/,  
                                   &dim_plane, dim_plane_xaxis, &dim_geom,
                                   &dim_type), 
                             targetid = my_id);
            if (!(1 & om_msg & *msg)) goto ret_end;
  
            OM_BLOCK_MOVE(dim_geom.point, attach_pt, sizeof(IGRpoint));
  
            /* Get the fillet radius */
            om_msg = om$send(msg= message expression.NDgive_value(&radius1),
                              targetid = parents[START_RADIUS].objid,
                              targetos = parents[START_RADIUS].osnum);
            if (!(1 & om_msg)) goto ret_end;
  
            if (num_parents > 4)
            {
              /* Get the ending fillet radius */
              om_msg = om$send(msg= message expression.NDgive_value(&radius2),
                                targetid = parents[END_RADIUS].objid,
                                targetos = parents[END_RADIUS].osnum);
              if (!(1 & om_msg)) goto ret_end;
              not_const = TRUE;
            }
        
            dotp = BSdotp(&bsrc, dim_geom.vector, dim_plane_xaxis);

            if (dotp < 0) flip = -1.0;
            else flip = 1.0;

            strcpy(txt_str, "R %4.3lf");      
            txt_len = strlen(txt_str);
      
            cur_rad = START_RADIUS;
            for(ii=0; ii<2; ii++)
            {
              if (not_const && ii != 0)
              {
                radius1 = radius2;
                cur_rad = END_RADIUS;
              }

              for(jj=0; jj<3; jj++)
              {
                break_pt[jj] = attach_pt[jj] + 
                               dim_geom.vector[jj] * radius1 * 0.85; 
              }
   
              for(jj=3; jj<6; jj++)
              {
                break_pt[jj] = break_pt[jj - 3] + 
                               (flip * radius1 * dim_plane_xaxis[jj - 3]);  
              }

              expr_list.objid = parents[cur_rad].objid;
              expr_list.osnum = parents[cur_rad].osnum;
  
              attach_grid.objid = parents[cur_rad].objid;
              attach_grid.osnum = parents[cur_rad].osnum;
              expr_count = 1;
  
              dm$place_text_with_leader(attach_ele = &my_grid,
                                        attach_pt = attach_pt,
                                        num_brkpt = 2,
                                        brkpt = break_pt,
                                        text_length = txt_len,
                                        text_string = txt_str,
                                        expr_count = expr_count,
                                        expr_list = &expr_list,
                                        plane_grid = &my_grid,
                                        owner = &attach_grid, 
                                        dim_grid = &dim_id);
              if (dim_id.objid == NULL_OBJID)
              {*msg = EMS_E_Fail; goto ret_end;}

              if (dim_id.objid == NULL_OBJID) {*msg=EMS_E_Fail;goto ret_end;}
        
              if (!not_const) break;
            }
          }
          break;
        }

        case EMS_ASsurface_by_offsetting_surface:
        case EMS_ASsurface_by_offsetting_surface1:
        {
          struct EMSoffset_surface *recomp=NULL,old_recomp;
          IGRint                   ii, dimcount, par_index, num_spec_tks;
          IGRdouble                trak_dist;
          IGRint size_of_struct=0;
          IGRuint dum_type,info_size;

        /* Get the 'number of multiple thicknesses' from the recompute-info.
         *  The first one is the 'common thickness'. The rest are
         *  multiple thicknesses.
         */
 
            om_msg = om$send(msg =
                message EMSassoc.EMget_info(&msg_loc, NULL,
                                   &dum_type, &info_size, NULL),
                     targetid = my_id);
            EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
 
            size_of_struct= sizeof(struct EMSoffset_surface);

          if(info_size < size_of_struct)
            {
            recomp = &old_recomp;
            recomp->props = *(unsigned long  *) info;
            recomp->num_spec_tks = 0;
            recomp->off_surf_views[0].num_sfs_per_tks=0;
            recomp->off_surf_views[0].best_view_index=0;
            recomp->off_surf_views[0].uv_point[0]=0;
            recomp->off_surf_views[0].uv_point[1]=0;
            }
          else
          recomp = (struct EMSoffset_surface *) info;
          num_spec_tks = recomp->num_spec_tks;
          dimcount = num_spec_tks + 1;

          for(ii = 0; ii < dimcount; ii++)
          {

            /* Setup an index value to take the following into consideration:
                common offset distance is the 2nd parent,
                specific offset distance parents start from the 4th.
             */
             par_index = (ii == 0 ? 1 : 2);

            /*
             * If the offset value is not already dimensioned ...
             */
            if (!( EFselect_first_component( &parents[ii+par_index],
                                             OPP_DMroot_class_id, 
                                             &dim_id ) & 1))
            {
                dim_id.objid = NULL_OBJID;

                trak_dir = 1;
                trak_dist = 0.0;

                dm$place_sglpara ( orig_grid    = &source_id,
                                   orig_pt      = dumpt,
                                   plane_grid   = &source_id,
                                   brk_pos      = BRK_LEFT,
                                   trak_dir     = trak_dir,
                                   trak_dist    = trak_dist,
                                   owner        = &parents[ii+par_index],
                                   dim_grid     = &dim_id );
                if (dim_id.objid == NULL_OBJID){*msg=EMS_E_Fail;goto ret_end;}
            }
          }
          break;
        }

        case EMS_ASdrafted_surface:
        case EMS_ASdrafted_surface1:
        {
          IGRdouble         attach_pt[3];
          IGRpoint          orig_pt;
          IGRdouble         break_pt[6], draft, flip, dotp;   
          IGRvector         dim_plane_xaxis, z_axis;
          IGRint            dim_type=-1, expr_count, txt_len;
          OMuint            ii, jj, par_inx;
          BSrc              bsrc;
          struct IGRplane   dim_plane;
          struct EMSgeomdata dim_geom;
          struct GRid       expr_list, my_grid, attach_grid;
          struct EMSdrafted_surface *r_c_info;
          IGRboolean        send_to_sfsolid;
          IGRchar           txt_str[100];
          extern OMuword    OPP_EMSsfsolid_class_id;
	  struct DMloc_param loc_param;
          IGRint status;


          /*
           * If the height value is not already dimensioned ...
           */
          if (!( EFselect_first_component ( &parents[HEIGHT], 
                                            OPP_DMroot_class_id, 
                                            &dim_id ) & 1))
          {
            IGRint  axis = 1;

            dim_id.objid = NULL_OBJID;
            trak_dir = 0;

            dm$place_stack_linear ( orig_grid  = &source_id,
                                    orig_pt    = dumpt,
                                    meas_grid  = &source_id,
                                    meas_pt    = dumpt,
                                    plane_grid = &source_id,
                                    trak_dir   = trak_dir,
                                    axis       = axis,
                                    owner      = &parents[HEIGHT],
                                    dim_grid   = &dim_id );
            if (dim_id.objid == NULL_OBJID){*msg=EMS_E_Fail;goto ret_end;}
          }

          /*
           * If the angle value is not already dimensioned ...
           */
          if (!(EFselect_first_component(&parents[ANGLE], 
                                         OPP_DMroot_class_id, 
                                         &dim_id ) & 1) )
          {
            dim_plane.point = orig_pt;
            dim_plane.normal = z_axis;

            /*If im owned by a sf solid then send the dimparm thru him.
             * Oh the games we play...
             */

            if (send_to_sfsolid = (IGRboolean) EFisAncestryValid(msg,
                                               sender_id, 
                                               OM_Gw_current_OS, 
                                               OPP_EMSsfsolid_class_id, FALSE))
            {
              my_grid.objid = sender_id;
              type = EMS_ASsolid_drafted_surface1;
            }
            else              
              my_grid.objid = my_id;

            my_grid.osnum = OM_Gw_current_OS;

            r_c_info = (struct EMSdrafted_surface *) info;
            
            par_inx = ANGLE;
            for(ii=0; ii<r_c_info->num_sides; ii++, par_inx++)
            {
              /* Get the draft angle */
              om_msg = om$send(msg= message expression.NDgive_value(&draft),
                               targetid = parents[par_inx].objid,
                               targetos = parents[par_inx].osnum);
              if (!(1 & om_msg)) goto ret_end;
  
              if (draft == 0.0) continue;

              dim_id.objid = NULL_OBJID;
              dim_geom.geomtype = GEOMDATA_NULL;

              om_msg = om$send(msg = message EMSdim.EMdimparam(msg,
                                     mod_env, options, type, info, num_parents,
                                     parents,
                                     par_inx,
                                     &dim_plane, dim_plane_xaxis, &dim_geom,
                                     &dim_type),
                               targetid = send_to_sfsolid ? sender_id : my_id);
              if (!(1 & om_msg & *msg)) goto ret_end;
  
              OM_BLOCK_MOVE(dim_geom.point, attach_pt, sizeof(IGRpoint));
  
              dotp = BSdotp(&bsrc, dim_geom.vector, dim_plane_xaxis);

              if (dotp < 0) flip = -1.0;
              else flip = 1.0;

	      status =
                        dm$get_dim_param(
                                type = DM_LOC_PARAM,
                                dim_objid = NULL_OBJID,
                                dim_osnum = OM_Gw_current_OS,
                                p_data = (char *) &loc_param);
              if(loc_param.deci_frac == DECIMAL_MODE) {
                txt_str[0] = '%';
                txt_str[1] = '2';
                txt_str[2] = '.';
                txt_str[3] = (loc_param.primary.decacc - DECI_ACC1) + '0';
                txt_str[4] = 'l';
                txt_str[5] = 'f';
                txt_str[6] = '\0';
                strcat(txt_str," Deg. Draft");
              }
              else
              strcpy(txt_str, "%2.1lf Deg. Draft");      

              if (r_c_info->num_sides == 1)
              {
                OMuint          cnt=0;
                struct GRid     curve_grid;
                OM_S_CHANSELECT to_comps;

                om_msg = om$send(msg = message NDnode.ASreturn_go 
                                       (&curve_grid,
                                       &mod_env->md_env.matrix_type,
                                       mod_env->md_env.matrix),
                                 targetid = parents[CURVE].objid,
                                 targetos = parents[CURVE].osnum);
                if (!(1 & om_msg)) goto ret_end;

                EMmake_chanselect(GRcmpowner_to_components, &to_comps);

                /*If not a composite cnt will be 0*/
                om$get_channel_count(objid = curve_grid.objid,
                                     osnum = curve_grid.osnum,
                                     p_chanselect = &to_comps,
                                     count = &cnt);
                if (cnt > 1)
                {
                  IGRchar txt_str1[40];

                  sprintf(txt_str1, "\n(%d places)", cnt);
                  strcat(txt_str, txt_str1);
                }
              }

              txt_len = strlen(txt_str);
        
              for(jj=0; jj<3; jj++)
              {
                break_pt[jj] = attach_pt[jj] + 
                               dim_geom.vector[jj] * 0.25; 
              }
   
              for(jj=3; jj<6; jj++)
              {
                break_pt[jj] = break_pt[jj - 3] + 
                               (flip * 0.3 * dim_plane_xaxis[jj - 3]);  
              }

              expr_list.objid = parents[par_inx].objid;
              expr_list.osnum = parents[par_inx].osnum;
  
              attach_grid.objid = parents[par_inx].objid;
              attach_grid.osnum = parents[par_inx].osnum;
              expr_count = 1;
  
	      /*** Added value_type argument -- 05 Nov 1993 ***/
              dm$place_text_with_leader(attach_ele = &my_grid,
                                        attach_pt = attach_pt,
                                        num_brkpt = 2,
                                        brkpt = break_pt,
                                        text_length = txt_len,
                                        text_string = txt_str,
                                        expr_count = expr_count,
                                        expr_list = &expr_list,
                                        plane_grid = &my_grid,
                                        owner = &attach_grid, 
					value_type = DIM_ANGLE,
                                        dim_grid = &dim_id);
              if (dim_id.objid == NULL_OBJID)
              {*msg = EMS_E_Fail; goto ret_end;}
            }
          }
          break;
        }

        default:
        {
          goto ret_end;
        }
    }

ret_end:

    EMWRAPUP (*msg, om_msg, "EMSgencompsf.EMdim")

    return (om_msg);
}

method EMdimparam ( IGRlong            * msg; 
                    struct GRmd_env    * mod_env;
                    IGRushort    options;
                    IGRint               type;
                    IGRchar            * info;
                    IGRint               num_parents;
                    struct GRid        * parents;
                    IGRint               index; 
                    struct IGRplane    * dim_plane;
                    IGRdouble          * dim_plane_xaxis;
                    struct EMSgeomdata * dim_geom;
                    IGRint             * dim_type )
{
extern void EFinit_geom_surface() ;
    IGRlong                 msg_loc, ma_msg, om_msg = OM_S_SUCCESS;
    IGRint                  i;
    struct IGRbsp_surface * bspsurface=NULL;
    struct BSgeom_bsp_surf  geom_surface;
    OM_S_CHANSELECT         to_components_chansel;

    extern IGRlong EFget_dimension_plane_and_geom();
    extern IGRlong EFget_edge_near_point_on_sf();
    extern IGRlong EFfind_outer_surface_and_edge_by_ptproject();

    geom_surface.sfgen_cv = NULL;
    EMmake_chanselect (GRcmpowner_to_components, &to_components_chansel);

    *msg = msg_loc = EMS_S_Success;

    ma_msg = BSSUCC;

    if (type != EMS_ASdrafted_surface && 
        type != EMS_ASdrafted_surface1 &&
        type != EMS_ASfillet_by_surfaces_and_radii &&
        type != EMS_ASfillet_by_surfaces_and_radii_w_track_pt &&
	type != EMS_ASfillet_by_edge_radius &&
	type != EMS_ASfillet_by_edge_radius_w_track_pt &&
	type != EMS_ASfillet_by_surface_surface_radius &&
        type != EMS_ASsurface_by_offsetting_surface &&
        type != EMS_ASsurface_by_offsetting_surface1 &&
	type != EMS_ASfillet_by_surface_surface_radius_w_track_pt &&
	type != EMS_ASfillet_by_edge_radii &&
	type != EMS_ASfillet_by_edge_radii_w_track_pt &&
	type != EMS_ASfillet_by_surface_surface_radii &&
	type != EMS_ASfillet_by_surface_surface_radii_w_track_pt &&
	type != EMS_ASfillet_by_curve_surface_radius &&
	type != EMS_ASfillet_by_curve_surface_radius_w_track_pt)
    {
        /*
         * Determine my surface geometry.
         */
        om_msg = om$send ( msg = message GRvg.GRgenabsg
                                                ( &msg_loc,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  (IGRchar **)&bspsurface ),
                           p_chanselect = &to_components_chansel,
                           from = 0,
                           to = 0 );
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

    if (type == EMS_ASfillet_by_edge_radius ||
	type == EMS_ASfillet_by_edge_radius_w_track_pt ||
	type == EMS_ASfillet_by_surface_surface_radius ||
	type == EMS_ASfillet_by_surface_surface_radius_w_track_pt ||
	type == EMS_ASfillet_by_edge_radii ||
	type == EMS_ASfillet_by_edge_radii_w_track_pt ||
	type == EMS_ASfillet_by_surface_surface_radii ||
	type == EMS_ASfillet_by_surface_surface_radii_w_track_pt ||
	type == EMS_ASfillet_by_curve_surface_radius ||
	type == EMS_ASfillet_by_curve_surface_radius_w_track_pt)
    {
      struct EMSfillet_surface_new *r_c_info = NULL;
      GRobjid fill_id;
      OMuword dumosnum, best_view_index;

      r_c_info = (struct EMSfillet_surface_new *) ME.EMSassoc->info;

      if (! dim_geom)
      {
        /*
	 * The dim orientation is only needed so just extract it from my
         * instance data.
         */
        best_view_index = r_c_info->view_index;
   
        if (best_view_index == NO_VIEW)
        {
	  *msg = EMS_E_InvalidCase;
	  goto ret_end;
	}

        if (dim_plane) 
        {
          dim_plane->point[0] = dim_plane->point[1] = dim_plane->point[2] = 0;
      
          if (best_view_index == TOP_VIEW)
          {
            dim_plane->normal[0] = 0;
            dim_plane->normal[1] = 0;
            dim_plane->normal[2] = 1;
          }
          else if (best_view_index == FRONT_VIEW)
          {
            dim_plane->normal[0] = 0;
            dim_plane->normal[1] = -1;
            dim_plane->normal[2] = 0;
          }      
          else
          {
            dim_plane->normal[0] = 1;
            dim_plane->normal[1] = 0;
            dim_plane->normal[2] = 0;
          }      
        }
    
        if (dim_plane_xaxis) 
        {
          if (best_view_index == TOP_VIEW ||
              best_view_index == FRONT_VIEW)
          {
            dim_plane_xaxis[0] = 1.0;
            dim_plane_xaxis[1] = 0.0;
          }
          else
          {
            dim_plane_xaxis[0] = 0.0;
            dim_plane_xaxis[1] = 1.0;
          }
      
          dim_plane_xaxis[2] = 0.0;
        }
      }
      else
      {
        /*
	 * Get the fillet surface to query
	 */
        om_msg = om$get_objid_at_index(object = me,
                                       p_chanselect = &to_components_chansel,
                                       index = 0,
                                       objidaddr = &fill_id,
                                       osnumaddr = &dumosnum);
        if (!(1 & om_msg)) goto ret_end;
  
        /*
	 * Get the dim information
	 */
        om_msg = EFget_dim_info(msg, fill_id, OM_Gw_current_OS, mod_env,
                                info, num_parents, parents, 
                                dim_plane, dim_plane_xaxis, dim_geom,
                                dim_type, NULL);
        if (!(1 & om_msg & *msg)) goto ret_end;

        if (dim_geom)
        {
          if (dim_plane)
          {
            if (dim_plane->normal[2] == 1.0)
              r_c_info->view_index = TOP_VIEW;
            else if (dim_plane->normal[1] == -1.0)
              r_c_info->view_index = FRONT_VIEW;
            else
              r_c_info->view_index = RIGHT_VIEW;
          }
        }
      }
    }
    else if (type == EMS_ASfillet_by_surfaces_and_radii ||
        type == EMS_ASfillet_by_surfaces_and_radii_w_track_pt)
    {
      struct EMSfillet_surface *r_c_info=NULL;
      GRobjid                  fill_id;
      OMuword                  dumosnum, best_view_index;

      r_c_info = (struct EMSfillet_surface *) ME.EMSassoc->info;

      if (! dim_geom)
      {
        /*The dim orientation is only needed so just extract it from my
         * instance data.
         */
        best_view_index = r_c_info->view_index;
   
        if (best_view_index == NO_VIEW)
        {*msg = EMS_E_InvalidCase; goto ret_end;}

        if (dim_plane) 
        {
          dim_plane->point[0] = dim_plane->point[1] = dim_plane->point[2] = 0;
      
          if (best_view_index == TOP_VIEW)
          {
            dim_plane->normal[0] = 0;
            dim_plane->normal[1] = 0;
            dim_plane->normal[2] = 1;
          }
          else if (best_view_index == FRONT_VIEW)
          {
            dim_plane->normal[0] = 0;
            dim_plane->normal[1] = -1;
            dim_plane->normal[2] = 0;
          }      
          else
          {
            dim_plane->normal[0] = 1;
            dim_plane->normal[1] = 0;
            dim_plane->normal[2] = 0;
          }      
        }
    
        if (dim_plane_xaxis) 
        {
          if (best_view_index == TOP_VIEW ||
              best_view_index == FRONT_VIEW)
          {
            dim_plane_xaxis[0] = 1.0;
            dim_plane_xaxis[1] = 0.0;
          }
          else
          {
            dim_plane_xaxis[0] = 0.0;
            dim_plane_xaxis[1] = 1.0;
          }
      
          dim_plane_xaxis[2] = 0.0;
        }
      }
      else
      {
        /*Get the fillet surface to query*/
        om_msg = om$get_objid_at_index(object = me,
                                       p_chanselect = &to_components_chansel,
                                       index = 0,
                                       objidaddr = &fill_id,
                                       osnumaddr = &dumosnum);
        if (!(1 & om_msg)) goto ret_end;
  
        /*Get the dim information*/
        om_msg = EFget_dim_info(msg, fill_id, OM_Gw_current_OS, mod_env,
                                info, num_parents, parents, 
                                dim_plane, dim_plane_xaxis, dim_geom,
                                dim_type, NULL);
        if (!(1 & om_msg & *msg)) goto ret_end;

        if (dim_geom)
        {
          if (dim_plane)
          {
            if (dim_plane->normal[2] == 1.0)
              r_c_info->view_index = TOP_VIEW;
            else if (dim_plane->normal[1] == -1.0)
              r_c_info->view_index = FRONT_VIEW;
            else
              r_c_info->view_index = RIGHT_VIEW;
          }
        }
      }
    }
    else if (type == EMS_ASsurface_by_offsetting_surface ||
             type == EMS_ASsurface_by_offsetting_surface1)
    {
      IGRpoint            point1, point2;
      IGRpoint            dimplpt;
      IGRvector           dimplnor, dimplxaxis;
      IGRdouble           dimgeom[6];
      IGRdouble           distance;
      IGRboolean          is_inward;
      struct EMSoffset_surface  *recomp=NULL;
      struct surfs_per_thickness *mult_tk_sfs=NULL;
      OMuword             best_view_index = 0;
      IGRint              ii, temp; 
      IGRint              parent_surf_index, num_mult_tks;
      struct  GRid        surf_pointer_GRid, dimension_surf_GRid,
                          dimension_edge_GRid;
      IGRpoint            uv_point;
      GRobjid             nearest_edge;
      IGRuchar            props;
      IGRboolean          pos_orient=TRUE, is_primitive_surface;
      OMuword             classid;

      struct EMSoffset_surface old_recomp;
      IGRint size_of_struct=0;
      IGRuint dum_type,info_size;
 
      om_msg = om$send(msg =
             message EMSassoc.EMget_info(&msg_loc, NULL,
                              &dum_type, &info_size, NULL),
                     targetid = my_id);
      EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
      size_of_struct= sizeof(struct EMSoffset_surface);
      if(info_size < size_of_struct)
        {
        recomp = &old_recomp;
        recomp->props = *(unsigned long  *) info;
        recomp->num_spec_tks = 0;
        recomp->off_surf_views[0].num_sfs_per_tks=0;
        recomp->off_surf_views[0].best_view_index=0;
        recomp->off_surf_views[0].uv_point[0]=0;
        recomp->off_surf_views[0].uv_point[1]=0;
        parent_surf_index = 0; 
        }
      else
        {
        recomp = (struct EMSoffset_surface *) info;

        /* Initialize num_mult_tks. Fix for UMR. Vidya/Hari */
        num_mult_tks = recomp->num_spec_tks;

        parent_surf_index = 3 + num_mult_tks;
        }
      is_inward = recomp->props & EMS_NATURAL_NORMAL;
      mult_tk_sfs = recomp->off_surf_views;
      num_mult_tks = recomp->num_spec_tks;

      /* Determine the Current Offset distance */
      om_msg = om$send (msg = message expression.NDgive_value (&distance),
             targetid = parents[index].objid);
      EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_InvalidCase, ret_end);

      /* Get the parent-index and dimension-edge-object corresponding to the
         current thickness  */


      if(index > 1)     /* refers to a multiple thickness */
      {
         parent_surf_index++;  /* Index to first multiple thick surface */

         for(ii=3; (ii<index) && (index < num_mult_tks+3); ii++)
                parent_surf_index += mult_tk_sfs[ii-2].num_sfs_per_tks;
      }

      OM_BLOCK_MOVE(&parents[parent_surf_index], &surf_pointer_GRid,
                                          sizeof(struct GRid));

      om_msg = om$send (msg = message NDnode.ASreturn_go
                               (&dimension_surf_GRid,
                                &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix),
                   targetid = surf_pointer_GRid.objid,
                   targetos = surf_pointer_GRid.osnum,
                   senderid = NULL_OBJID);
      EMerr_hndlr(!(1 & om_msg) || dimension_surf_GRid.objid == NULL_OBJID,
                                           *msg, EMS_E_Fail, ret_end);

     /* Get the view index from the instance data */
      temp = (index == 1 ? 0 : (index - 2));
      if(!(temp > recomp->num_spec_tks))
        best_view_index =
                mult_tk_sfs[temp].best_view_index;
      else
      {
#ifdef DEBUG
        printf("Error - 'index' exceeds 'num_mult_tks' \n");
#endif
        goto ret_end;
      }

      /* Get the 'uv' point from the instance data */
      uv_point[0] = mult_tk_sfs[temp].uv_point[0];
      uv_point[1] = mult_tk_sfs[temp].uv_point[1];

      /* Determine the edge nearest to the 'uv' point on the surface */

      om_msg = EFget_edge_near_point_on_sf(&msg_loc, mod_env,
                                          dimension_surf_GRid,
                                          UV_POINT,
                                          uv_point,
                                          NULL,   /* want an edge in anycase*/
                                          &nearest_edge, NULL, NULL);
      EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_EdgeError, ret_end);

      dimension_edge_GRid.objid = nearest_edge;
      dimension_edge_GRid.osnum = dimension_surf_GRid.osnum;

      om_msg = om$get_classid (objid = parents[0].objid,
                      osnum = parents[0].osnum,
                      p_classid = &classid );
      EMerr_hndlr(!(1&om_msg), *msg, EMS_E_OMerror, ret_end);

#ifdef DEBUG
  printf("The classid of the original surface (%d) is %d\n", parents[0].objid,
                                              classid);
#endif

      if (!(om$is_ancestry_valid(superclassid = OPP_EMScompsurf_class_id,
                                  subclassid = classid) == OM_S_SUCCESS))
      {
        is_primitive_surface = TRUE;
        om_msg = om$send(msg = message EMSsubbs.EMget_props(&msg_loc, &props),
                       senderid = NULL_OBJID,
                       targetid = dimension_surf_GRid.objid,
                       targetos = dimension_surf_GRid.osnum);
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
        pos_orient = !(props & EMSIS_NRML_REVERSED);
        /* Is this bit always set when the pos_orient of the surface is
           '0'? */
      }
      else
         is_primitive_surface = FALSE;

      EFget_dimension_plane_and_geom(&msg_loc,
                                     mod_env, 
                                (is_primitive_surface ?
                                 (is_inward ^ pos_orient ? REVERSE_NORMAL : 0) :
                                 (is_inward ? 0 : REVERSE_NORMAL)),
                                     &distance,
                                     dimension_surf_GRid,
                                     dimension_edge_GRid,
                                     best_view_index,
                                     &dimplpt[0],
                                     &dimplnor[0],
                                     &dimplxaxis[0],
                                     &dimgeom[0]);

      if (dim_type)
          *dim_type = SINGLE_PARALLEL;

      if (dim_plane)
      {
          memcpy (dim_plane->point, dimplpt, sizeof(IGRpoint));
          memcpy (dim_plane->normal, dimplnor, sizeof (IGRvector));
      }

      if (dim_plane_xaxis)
      {
          memcpy (dim_plane_xaxis, dimplxaxis, sizeof (IGRvector));
      }
      if (dim_geom)
      {
        for (i=0; i<3; ++i)
        {
            point1[i] = dimgeom[i];
            point2[i] = dimgeom[i+3];
        };
        dim_geom->geomtype = GEOMDATA_LINE;
        dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
        dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;

       /* Ensure the dimension is always outside if the input is a
          solid. */
        if(is_inward)
        {
          memcpy (dim_geom->line.line_pt1, point1, sizeof(IGRpoint));
          memcpy (dim_geom->line.line_pt2, point2, sizeof(IGRpoint));
        }
        else  
        {
          memcpy (dim_geom->line.line_pt1, point2, sizeof(IGRpoint));
          memcpy (dim_geom->line.line_pt2, point1, sizeof(IGRpoint));
        }
      }
    }
    else if (type == EMS_ASdrafted_surface || type == EMS_ASdrafted_surface1)
    {
      if (index < ANGLE)
      {
        struct GRid           curve, my_grid;
        struct EMSgeomdata    direction;
        IGRdouble             height;
        IGRvector             x_axis, y_axis, z_axis;
        IGRdouble             height_line[6], angle_line[6];
        IGRpoint              startpt, endpt;
        
        my_grid.objid = my_id;
        my_grid.osnum = OM_Gw_current_OS;

        om_msg = om$send(msg = message NDnode.ASreturn_go(&curve,
                               &mod_env->md_env.matrix_type,
                               mod_env->md_env.matrix),
                         targetid = parents[CURVE].objid,
                         targetos = parents[CURVE].osnum );
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
                      
        om_msg = om$send(msg = message EMSparamgm.EMgetgeom 
                                                ( &msg_loc, 
                                                  NULL,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  &direction ), 
                         targetid = parents[DIRECTION].objid,
                         targetos = parents[DIRECTION].osnum );
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        om_msg = om$send(msg = message expression.NDgive_value(&height),
                         targetid = parents[HEIGHT].objid,
                         targetos = parents[HEIGHT].osnum );
        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

/*
 * Compute the start and endpoints of the curve. This gives us the
 * point to place the height dimension.
 * Ignore the stuff that is computed by the function as it is erroneous.
 * The function assumes that the projection direction is the v direction
 * which is not always true.
 * PP 11/9/93
 */

        om_msg = om$send (msg = message GRcurve.GRendpts(&msg_loc,
                  &mod_env->md_env.matrix_type,
                  mod_env->md_env.matrix, startpt, endpt),
                 targetid = curve.objid,
                 targetos = curve.osnum);
        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

/* end pp*/

        /*
         * Determine the geometry for the projection line and angle lines.
         */
        if (! EFget_draft_dimgeom(mod_env,
                                  &my_grid,
                                  &curve,
                                  FALSE,
                                  height_line,
                                  angle_line))
        {
          *msg = EMS_E_Fail;
          goto ret_end;
        }

        if (dim_geom)
        {
            dim_geom->geomtype = GEOMDATA_LINE;
            dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
            dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
        }
        
        switch (index)
        {
          case CURVE:
          {
            break;
          }
              
          case HEIGHT:
          case DIRECTION:
          {
            height_line[0] = startpt[0];
            height_line[1] = startpt[1];
            height_line[2] = startpt[2];

            for (i=0;i<3;i++)
            {
             height_line[i] = startpt[i];
             height_line[i+3] = height_line[i] + direction.vector[i] * height;
            }
            for (i=0; i<3; ++i)
               x_axis[i] = (height_line[i] +
                           (direction.vector[i] * height)) - height_line[i];

            EFget_normal_from_axis ( &msg_loc, 
                                     &parents[HEIGHT],
                                     mod_env, 
                                     x_axis,  /* In/Out */
                                     y_axis, 
                                     z_axis );

            if (dim_type) *dim_type = STACKED_LINEAR;

            if (dim_plane)
            {
              memcpy (dim_plane->point, height_line, sizeof(IGRpoint));
              memcpy (dim_plane->normal, z_axis, sizeof (IGRvector));
            }

            if (dim_plane_xaxis)
              memcpy (dim_plane_xaxis, x_axis, sizeof (IGRvector));

            if (dim_geom)
            {
              memcpy(dim_geom->line.line_pt1, height_line, sizeof(IGRpoint));
              memcpy(dim_geom->line.line_pt2, &height_line[3], 
                     sizeof(IGRpoint));
            }

            if (index == DIRECTION)
            {
              for (i=0; i<3; ++i)
              {
                dim_geom->line.line_pt1[i] -= x_axis[i] * DISPAXIS_FACTOR;
                dim_geom->line.line_pt2[i] += x_axis[i] * DISPAXIS_FACTOR;
              }
            }
            break;
          }
          default:
          {
            break;
          }
        }
      }
      else
      {
        GRobjid                   draft_id;
        OMuword                   dumosnum;
  
        /*get dimparams for angle*/

        /*Get the draft surface to query*/
        om_msg = om$get_objid_at_index(object = me,
                                       p_chanselect = &to_components_chansel,
                                       index = index - ANGLE,
                                       objidaddr = &draft_id,
                                       osnumaddr = &dumosnum);
        if (!(1 & om_msg)) goto ret_end;
    
        /*Get the dim information*/
        om_msg = EFget_dim_info(msg, draft_id, OM_Gw_current_OS, mod_env,
                                info, num_parents, parents, 
                                dim_plane, dim_plane_xaxis, dim_geom,
                                dim_type, NULL);
        if (!(1 & om_msg & *msg)) goto ret_end;
      }
    }

ret_end:

    if (geom_surface.sfgen_cv)
        BSfreecv(&ma_msg, geom_surface.sfgen_cv);

    EMWRAPUP (*msg, om_msg, "EMSgencompsf.EMdimparam");
    return (om_msg);
}

IGRint EFget_draft_dimgeom ( mod_env, 
                             compsf_id, 
                             curve_id, 
                             all_sides, 
                             height_line, 
                             angle_lines )
    struct GRmd_env * mod_env;     /* In  */
    struct GRid     * compsf_id;   /* In  */
    struct GRid     * curve_id;    /* In  */
    IGRboolean        all_sides;   /* In  - Return angle lines for all sides? */
    IGRdouble       * height_line; /* Out - If specified. */
    IGRdouble       * angle_lines; /* Out - If specified. */
{
    IGRlong                 msg = EMS_S_Success, om_msg = OM_S_SUCCESS, ma_msg;
    struct GRid             surf_id;
    OMuint                  num_surfs;
    IGRint                   i;
    OM_S_CHANSELECT         to_comps;
    struct IGRbsp_curve   * curve;
    struct IGRbsp_surface * surface;
    IGRdouble               angle_parm = 0.5, height_parm;
    struct GRparms          dummy_parms;
    IGRshort                uv_const = 1 /* u constant */;
    IGRboolean              planar = FALSE;
    OMuword                 classid;
    extern OMuword          OPP_EMSplane_class_id;
    
    
    EMmake_chanselect (GRcmpowner_to_components, &to_comps);

    if (all_sides)
    {
        /*
         * If this is an owner determine the number of surfaces that
         * have been projected.
         */
        om$get_classid ( objid = curve_id->objid,
                         osnum = curve_id->osnum,
                         p_classid = &classid );

        if (om$is_ancestry_valid ( superclassid = OPP_GRowner_class_id,
                                   subclassid = classid ) == OM_S_SUCCESS)
        {
            om$get_channel_count ( objid = curve_id->objid,
                                   osnum = curve_id->osnum,
                                   p_chanselect = &to_comps,
                                   count = &num_surfs );
        }
        else num_surfs = 1;
    }
    else num_surfs = 1;

    /*
     * Allocate a bspline buffer that will hold curve which 
     * runs in the v direction across the surface. This curve
     * will represent a line in all cases.
     */
    for (i=0; i<num_surfs; ++i)
    {
        IGRboolean surf_is_plane;

        /*
         * Determine this surface's geometry.
         */
        om$get_objid_at_index ( objid = compsf_id->objid,
                                osnum = compsf_id->osnum,
                                p_chanselect = &to_comps,
                                index = i,
                                objidaddr = &surf_id.objid,
                                osnumaddr = &surf_id.osnum );
                                
        om_msg = om$send ( msg = message GRvg.GRgenabsg
                                                ( &msg,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix,
                                                  (IGRchar **)&surface ),
                           senderid = NULL_OBJID,
                           targetid = surf_id.objid,
                           targetos = surf_id.osnum );
        EMerr_hndlr (EMSerror (om_msg & msg), msg, EMS_E_Fail, ret_end);

        surf_is_plane = (IGRboolean) EFisAncestryValid(&msg, surf_id.objid,
                                  surf_id.osnum, OPP_EMSplane_class_id, FALSE);

        EFget_curve_buffer ( surface->v_order, 
                             surface->v_num_poles, 
                             surface->rational,
                             NULL, 
                             &curve );

        if (angle_lines)
        {
          BSconstprcv(&ma_msg, surface, &uv_const, &angle_parm, &planar,
                      curve ); 
          memcpy (&angle_lines[i * 6], curve->poles, 6 * sizeof(IGRdouble));

          if (surf_is_plane)
          {
            IGRdouble *p_angle;
            OMbyte    ii;

            for(ii=0; ii<2; ii++)
            {
              if (ii==0) p_angle = &angle_lines[i * 6];
              else       p_angle = &angle_lines[(i * 6) + 3];
  
              om_msg = om$send(msg = message GRvg.GRptproject(&msg, 
                                     &mod_env->md_env.matrix_type,
                                     mod_env->md_env.matrix,
                                     p_angle,
                                     p_angle,
                                     &dummy_parms),
                               senderid = NULL_OBJID,
                               targetid = surf_id.objid,
                               targetos = surf_id.osnum);                      
              EMerr_hndlr (EMSerror (om_msg & msg), msg, EMS_E_Fail, ret_end);
            }
          }
        }

        if (height_line && (i == 0))
        {
          if (surf_is_plane) height_parm = 0.5;
          else               height_parm = 0.0;
            
          BSconstprcv(&ma_msg, surface, &uv_const, &height_parm, &planar, 
                      curve );
          memcpy (height_line, curve->poles, 6 * sizeof(IGRdouble));

          if (surf_is_plane)
          {
            IGRdouble *p_height;
            OMbyte    ii;

            for(ii=0; ii<2; ii++)
            {
              if (ii==0) p_height = height_line;
              else       p_height = &height_line[3];
              
              om_msg = om$send(msg = message GRvg.GRptproject(&msg, 
                                     &mod_env->md_env.matrix_type,
                                     mod_env->md_env.matrix,
                                     p_height,
                                     p_height,
                                     &dummy_parms),
                               senderid = NULL_OBJID,
                               targetid = surf_id.objid,
                               targetos = surf_id.osnum);                        
              EMerr_hndlr (EMSerror (om_msg & msg), msg, EMS_E_Fail, ret_end);
            }
          }
        }
    }

ret_end:
    return (om_msg & msg & 1);
}

end implementation EMSgencompsf;
