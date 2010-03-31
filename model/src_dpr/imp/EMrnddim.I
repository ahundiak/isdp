class implementation EMSsfround;

/*
  History

       Sudha   06/23/93     Modified for BSprototype ansification
*/

%safe
#include <math.h>
%endsafe

#include "OMmacros.h"
#include "dimdef.h"
#include "dim.h"
#include "EMSdimdef.h"
#include "EMSas.h"
#include "EMSasnuc.h"
#include "EMSsfparms.h"
#include "dimplcmacros.h"
#include "dimmacros.h"
#include "bserr.h"
#include "EMSdpr.h"
#include <string.h>

#include "bsparameters.h"
#include "bststcvfln.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bscveval.h"
#include "bscrossp.h"
#include "bsconstprcv.h"
#include "bsalloccv.h"

#define ABS(X) ((X) >= 0 ? (X) : -(X))

#define X 0
#define Y 1
#define Z 2
#define DEG_TO_RAD M_PI/180

from EMSparamgm import EMgetgeom;
from EMSedge    import EMget_bcxyz_geom, EMtangent;
from expression import NDgive_value;
from EMSsubbs   import EMget_edges, EMtangent_normal;
from EMSloop    import EMget_edges;

IGRlong EFget_num_fillet_sfs(EMmsg, parent_grid, dpr_id, num_sfs)
IGRlong         *EMmsg;
struct GRid     *parent_grid;
GRobjid         dpr_id;
IGRint          *num_sfs;
{
  IGRlong            OM_stat=OM_S_SUCCESS;
  IGRint             num_edges;
  IGRuint    parent_type=EMSgrid;
  GRobjid            parent_id;
  union EMSparent_info parent_info;
  OMuword            osnum;

  *EMmsg = EMS_S_Success;
  
  osnum = parent_grid->osnum;

  /*Get the real topology parent*/
  OM_stat = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg,
                          NULL, 
                          1, (IGRchar *) parent_grid,
                          &parent_type, &parent_info),
                    senderid = NULL_OBJID,
                    targetid = dpr_id,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        
  parent_id = parent_info.grobj.grid.objid;

  /*See if its a loop*/
  if (EFisAncestryValid(EMmsg, parent_id, osnum, OPP_EMSloop_class_id, FALSE))
  {
    /*Rounding a loop, so find out how many fillet sfs to skip*/
    num_edges = 0;
    OM_stat = om$send(msg = message EMSloop.EMget_edges(EMmsg, 1,
                            EMS_OPT_NONDEG, NULL, NULL,
                            &num_edges),  
                      senderid = NULL_OBJID,
                      targetid = parent_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    *num_sfs = num_edges;
  }
  else *num_sfs = 1;

wrapup:
  return(OM_stat);
}

method EMdim(IGRlong           *EMmsg;
             struct GRmd_env   *env;
             IGRushort options;
             IGRint            type;
             IGRchar           *info;
             IGRint            num_parents;
             struct GRid       *parents)
/*
Description:
    These are the autodimension methods for associative round/chamfer

Notes
    None so far.

History
    DLB     08/08/91    Creation.
*/
{
  IGRdouble         attach_pt[3], min_len;
  IGRpoint          orig_pt;
  IGRdouble         break_pt[6], radius, flip, dotp;   
  IGRvector         dim_plane_xaxis, z_axis;
  IGRlong           OM_stat=OM_S_SUCCESS;
  BSrc              bsrc;
  IGRint            txt_len, expr_count, num_sfs;
  IGRint            dim_type=-1;        
  OMuint            ii, jj;
  struct GRid       expr_list, my_grid, dim_grid, attach_grid;
  struct IGRplane   dim_plane;
  struct EMSgeomdata dim_geom;
  IGRboolean        uniform;
  unsigned short    op_type;
  IGRchar           txt_str[100], txt_str1[40];
  struct DMsenv_param dim_par;

  *EMmsg = EMS_S_Success;

  /*EMadd has not yet been done so num_parents is correct*/

  if (type == EMS_ASround || type == EMS_ASround_uniform)
  {
    op_type = EMS_ROUND_OPR;
    uniform = (type == EMS_ASround_uniform);
  }
  else if (type == EMS_ASchamfer || type == EMS_ASchamfer_uniform)
  {
    op_type = EMS_CHAMFER_OPR;
    uniform = (type == EMS_ASchamfer_uniform);
  }

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
    
  dim_plane.point = orig_pt;
  dim_plane.normal = z_axis;

  dm$get_dim_param(type = DM_SENV_PARAM,
			dim_objid = NULL_OBJID,
			dim_osnum = OM_Gw_current_OS,
			p_data = &dim_par);

  /* Tapadia - 01/27/92. This is done so that the leader lines do not become 
  smaller than the arrow (at the attach point when the radius is very small) */

  min_len = 3.0 * dim_par.txt_heig;

  for(ii=0; ii<num_parents; ii+=2)
  {
    dim_grid.objid = NULL_OBJID;
    dim_geom.geomtype = GEOMDATA_NULL;

    OM_stat = om$send(msg = message EMSdim.EMdimparam(EMmsg,
                            env, options, type, info, num_parents, parents,
                            ii /*Parent paramval index*/,  
                            &dim_plane, dim_plane_xaxis, &dim_geom, &dim_type),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    OM_BLOCK_MOVE(dim_geom.point, attach_pt, sizeof(IGRpoint));

    /* Get the fillet radius */
    OM_stat = om$send(msg= message expression.NDgive_value(&radius),
                      targetid = parents[ii].objid,
                      targetos = parents[ii].osnum);
    if (!(1 & OM_stat)) goto wrapup;

    if(radius < min_len)
	radius = min_len;
  
    for(jj=0; jj<3; jj++)
    {
      break_pt[jj] = attach_pt[jj] + dim_geom.vector[jj] * radius * 0.85;
    }
  
    dotp = BSdotp(&bsrc, dim_geom.vector, dim_plane_xaxis);
    
    if (dotp < 0) flip = -1.0;
    else flip = 1.0;

    for(jj=3; jj<6; jj++)
    {
      break_pt[jj] = break_pt[jj - 3] + 
                     (flip * radius * dim_plane_xaxis[jj - 3]);  
    }

    if (op_type == EMS_ROUND_OPR) strcpy(txt_str, "R %4.3lf");      
    else strcpy(txt_str, "CHAM %4.3lf");      

    if (uniform)
    {
      IGRint tmp_num_sfs;

      num_sfs = 0;
      for(jj=ii+1; jj<num_parents; jj++)
      {
        OM_stat = EFget_num_fillet_sfs(EMmsg, &parents[jj], my_id, 
                                       &tmp_num_sfs);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        num_sfs += tmp_num_sfs;
      }
    }
    else
    {
      OM_stat = EFget_num_fillet_sfs(EMmsg, &parents[ii+1], my_id, &num_sfs);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    if (num_sfs > 1)
    {
      sprintf(txt_str1, "\n(%d places)", num_sfs);
      strcat(txt_str, txt_str1);
    }

    txt_len = strlen(txt_str);
  
    expr_list.objid = parents[ii].objid;
    expr_list.osnum = parents[ii].osnum;
  
    attach_grid.objid = parents[ii].objid;
    attach_grid.osnum = parents[ii].osnum;
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
                              dim_grid = &dim_grid);
    if (dim_grid.objid == NULL_OBJID)
    {*EMmsg = EMS_E_Fail; goto wrapup;}

    if (uniform) break; /*Only dimension first fillet surface if uniform*/
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "rnd.EMdim")
  return(OM_stat);
}

method EMdimparam(IGRlong            *EMmsg; 
                  struct GRmd_env    *env;
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
  IGRlong           OM_stat=OM_S_SUCCESS;
  OMuint            ii, sf_index;
  IGRint            num_sfs;
  IGRuint   type, size;
  OM_S_CHANSELECT   to_comps; 
  struct EMSround_chamfer *r_c_info=NULL;
  GRobjid           fill_id;
  OMuword           dumosnum, op_type, best_view_index;
  IGRboolean        uniform;
  extern IGRlong    EFget_dim_info();  

  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg,
                          NULL, &type, &size, 
                          (IGRchar **) &r_c_info),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      

  if (! dim_geom)
  {
    /*The dim orientation is only needed so just extract it from my instance
     * data.
     */
    if (r_c_info->num_views)
    {
      for(ii=0; ii<r_c_info->num_views; ii++)
      {
        if (r_c_info->view_info[ii].parent_index == index) break;
      }
      best_view_index = r_c_info->view_info[ii].view_index ;
    }
    else {*EMmsg = EMS_E_InvalidCase; goto wrapup;}  /*NO_VIEW*/
   
    if (best_view_index == NO_VIEW || size < sizeof(struct EMSround_chamfer))
    {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

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
    /*Compute the surface to use for dimparam info*/
  
    if (type == EMS_ASround || type == EMS_ASround_uniform)
    {
      op_type = EMS_ROUND_OPR;
      uniform = (type == EMS_ASround_uniform);
    }
    else if (type == EMS_ASchamfer || type == EMS_ASchamfer_uniform)
    {
      op_type = EMS_CHAMFER_OPR;
      uniform = (type == EMS_ASchamfer_uniform);
    }
  
    if (uniform && index != 0)
    {*EMmsg = EMS_E_InvalidCase; goto wrapup;}
  
    sf_index = 1; /*Start with first fillet surface on to_comps*/
  
    if (!uniform)
    {
      for(ii=0; ii<num_parents;)   /*NO INCREMENT*/
      {
        if (ii == index) break;
        else
        {
          ii++;  /*Increment to topology parent*/
  
          OM_stat = EFget_num_fillet_sfs(EMmsg, &parents[ii], my_id, &num_sfs);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;

          sf_index += num_sfs;  

          ii++; /*Increment to param parent*/
        }
      }
    }
  
    /*Get the fillet surface to query*/
    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$get_objid_at_index(object = me,
                                    p_chanselect = &to_comps,
                                    index = sf_index,
                                    objidaddr = &fill_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;                                  
  
    /*Get the dim information*/
    OM_stat = EFget_dim_info(EMmsg, fill_id, OM_Gw_current_OS, env,
                             info, num_parents, parents, 
                             dim_plane, dim_plane_xaxis, dim_geom, dim_type, 
                             NULL);

    if (dim_geom)
    {
      if (dim_plane)
      {
        OMuint                  num_views, new_size;
        struct EMSround_chamfer *new_r_c_info=NULL;

        num_views = r_c_info->num_views;

        new_size = sizeof(struct EMSround_chamfer) + 
                   (num_views + 1) * sizeof(struct EMSview_info);
        new_r_c_info = (struct EMSround_chamfer *) stackalloc(new_size);
        if (!new_r_c_info) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}

        OM_BLOCK_MOVE(r_c_info,
                      new_r_c_info,
                      new_size);

        new_r_c_info->view_info[num_views].parent_index = index;

        if (dim_plane->normal[2] == 1.0)
          new_r_c_info->view_info[num_views].view_index = TOP_VIEW;
        else if (dim_plane->normal[1] == -1.0)
          new_r_c_info->view_info[num_views].view_index = FRONT_VIEW;
        else
          new_r_c_info->view_info[num_views].view_index = RIGHT_VIEW;

        new_r_c_info->num_views++;

        OM_stat = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL, type,
                                new_size, (IGRchar *) new_r_c_info),
                          targetid = my_id);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;

        if (new_r_c_info) stackfree(new_r_c_info);
      }
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "rnd.EMdimparam")
  if(r_c_info)
    {
    om$dealloc(ptr = r_c_info);
    r_c_info = NULL;
    }
  return(OM_stat);
}

#define CONST_U 1
#define CONST_V 2

#define U 0
#define V 1


from EMSedge import EMendpts;

#ifdef __STDC__
#argsused
#endif
IGRlong EFget_dim_info(EMmsg, surf_id, osnum, env,
                       info, num_parents, parents,
                       dim_plane, dim_plane_xaxis, dim_geom, dim_type, 
                       options)
IGRlong            *EMmsg;
GRobjid            surf_id;
OMuword            osnum;
struct GRmd_env    *env;
IGRchar            *info;
IGRint             num_parents;
struct GRid        *parents;
struct IGRplane    *dim_plane;
IGRdouble          *dim_plane_xaxis;
struct EMSgeomdata *dim_geom;
IGRint             *dim_type;
OMuword            options;

{
  IGRvector           top, front, right;
  IGRvector           my_TN[4], best_nor_vec, *view_vec, *best_view;
  IGRdouble           surface_par[2], sum, best_sum=0.0, par, 
                      uv_beg_pt[2], uv_end_pt[2], best_par[2], basis_tol;
  IGRpoint            mid_pt, tan_vec, nor_vec, test_vec,
                      best_attach_pt, begpt, endpt;
  IGRlong             OM_stat=OM_S_SUCCESS, sf_size;
  IGRint              kk,array_size=0, num_edges=0, num_pars=1;
  BSrc                bsrc;
  struct GRid         *edge_grids=NULL, surf_grid;
  struct IGRbsp_curve curve, *tmp_curve = NULL;
  struct IGRbsp_surface *surface;
  IGRshort            u_or_v;
  OMuword             ii, jj, best_view_index;
  IGRboolean          is_a_line, check_planar=FALSE;
extern IGRdouble cos() , sin() ;

  *EMmsg = EMS_S_Success;

  top[0]=0.0; top[1]=0.0; top[2]=1.0;
  front[0]=0.0; front[1]= -1.0; front[2]=0.0;
  right[0]=1.0; right[1]=0.0; right[2]=0.0;

  OM_stat = om$send(msg = message EMSsubbs.EMget_edges(EMmsg, 1,
                          EMS_OPT_NONDEG, env, &edge_grids, &array_size,
                          &num_edges), 
                    senderid = NULL_OBJID,
                    targetid = surf_id,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  surf_grid.objid = surf_id;
  surf_grid.osnum = osnum;

  OM_stat = om$send(msg = message GRvg.GRgetsize(EMmsg,
                          &env->md_env.matrix_type,
                          env->md_env.matrix, &sf_size),
                    senderid = NULL_OBJID,
                    targetid = surf_id,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  surface = (struct IGRbsp_surface *) alloca(sf_size);

  OM_stat = om$send(msg = message GRvg.GRgetgeom(EMmsg,
                          &env->md_env.matrix_type,
                          env->md_env.matrix, (IGRchar *) surface),
                    senderid = NULL_OBJID,
                    targetid = surf_id,
                    targetos = osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  BSEXTRACTPAR(&bsrc, BSTOLBASIS, basis_tol);

  for(ii=0; ii<num_edges; ii++)
  {
    curve.poles = NULL;
    curve.knots = NULL;
    curve.weights = NULL;
    tmp_curve = NULL;

    OM_stat = om$send(msg = message EMSedge.EMendpts(EMmsg, 
                            uv_beg_pt, uv_end_pt, 
                            NULL, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = edge_grids[ii].objid,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;


    if (ABS(uv_end_pt[U] - uv_beg_pt[U]) < ABS(uv_end_pt[V] - uv_beg_pt[V]))
    {
      par = uv_beg_pt[U];
      u_or_v = CONST_U;
      BSalloccv(surface->v_order, surface->v_num_poles, 
                surface->rational, NULL, &tmp_curve, &bsrc);
    }
    else
    {
      par = uv_beg_pt[V];
      u_or_v = CONST_V;
      BSalloccv(surface->u_order, surface->u_num_poles, 
                surface->rational, NULL, &tmp_curve, &bsrc);
    }
    if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

    BSconstprcv(&bsrc, surface, &u_or_v, &par, &check_planar, tmp_curve);
    if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

    curve = *tmp_curve;

    /*Get the midpt of the curve*/
    /******
    MAbcmidpt(EMmsg, &curve, mid_pt);
    ******/

    {/*INTENTIONAL*/
      IGRdouble  param=0.5, lcs_point[4];

      BScveval(&curve, param, 0, (IGRpoint *)&lcs_point[0], &bsrc);
      if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

      OM_BLOCK_MOVE(lcs_point, mid_pt, sizeof(IGRpoint));       
    }    


    if (!(1 & *EMmsg)) goto wrapup;

    /*Get the tangent of the edge at the mid point (if curve is passed in the
     * edge is only used as a vehicle to compute the tangent.
     */
    OM_stat = om$send(msg = message EMSedge.EMtangent(EMmsg, env, NULL,
                            mid_pt, 1.0, &curve, tan_vec),
                      senderid = NULL_OBJID,
                      targetid = edge_grids[ii].objid,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
                            
    BSnorvec(&bsrc, tan_vec);

    /*Get the param pt at the mid point on the surface*/
    OM_stat = om$send(msg = message GRvg.EMpratpt(EMmsg, 
                            &env->md_env.matrix_type,
                            env->md_env.matrix,
                            mid_pt, surface_par, &num_pars),
                      senderid = NULL_OBJID,
                      targetid = surf_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    /*Get the normal vector on the surface.*/
    OM_stat = om$send(msg = message EMSsubbs.EMtangent_normal(EMmsg,
                            env, surface_par, 1.0, my_TN),
                      senderid = NULL_OBJID,
                      targetid = surf_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    OM_BLOCK_MOVE(my_TN[2], nor_vec, sizeof(IGRvector));

    BSnorvec(&bsrc, nor_vec);

    /*Get the normal vector to the tan-norm vector at the mid pt.*/
    BScrossp(&bsrc, nor_vec, tan_vec, test_vec);
    if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

    for(jj=0; jj<NUM_VIEWS; jj++)
    {
      if      (jj == TOP_VIEW)   view_vec = (IGRvector *) top;
      else if (jj == FRONT_VIEW) view_vec = (IGRvector *) front;
      else if (jj == RIGHT_VIEW) view_vec = (IGRvector *) right;
        
      sum = BSdotp(&bsrc, view_vec[0], test_vec);
      sum = ABS(sum);

      /*Weight sum if curve has more desirable attributes*/
      if (!curve.phy_closed)
        sum += 0.01;

      (void) BStstcvfln(&curve, &is_a_line, begpt, endpt, &bsrc);
      if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

      if (!is_a_line)
        sum += 0.001;

      /* Subtracting basis_tol to alleviate some of the problems caused by
       * roundoff errors or "noise" sometimes present in sum.  WBC 4/14/93
       */

      if (sum - best_sum - basis_tol > 0.0)
      {
        /*Have the best view.*/
        best_sum = sum;
        OM_BLOCK_MOVE(nor_vec, best_nor_vec, sizeof(IGRvector));
        best_view = view_vec; 
        best_view_index = jj;
        best_par[U] = (uv_beg_pt[U] + uv_end_pt[U])/2.0;
        best_par[V] = (uv_beg_pt[V] + uv_end_pt[V])/2.0;
      }
    }

/* fix for mlk */
    if(tmp_curve)
      {
      BSfreecv(&bsrc,tmp_curve);
      tmp_curve = NULL;
      }

    curve.poles = NULL;
    curve.knots = NULL;
    curve.weights = NULL;
  }

  if (dim_type) *dim_type = TEXT_WITH_LEADER;
  
  if (dim_plane || dim_geom)
  {
    OM_stat = om$send(msg = message GRvg.EMptatpr(EMmsg,
                            &env->md_env.matrix_type,
                            env->md_env.matrix,
                            best_par, 2, best_attach_pt),
                      senderid = NULL_OBJID,
                      targetid = surf_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  if (dim_plane) 
  {
    OM_BLOCK_MOVE(best_attach_pt, dim_plane->point, sizeof(IGRpoint));
    OM_BLOCK_MOVE(best_view, dim_plane->normal, sizeof(IGRvector));
  }

  if(dim_geom)
  {
    dim_geom->geomtype = GEOMDATA_POINT;
    OM_BLOCK_MOVE(best_attach_pt, dim_geom->point, sizeof(IGRpoint));

    /*Also need to return the normal vector*/
    for(ii=0; ii<3; ii++)
    {
      dim_geom->vector[ii] = best_nor_vec[ii] * -1;  /*flip from pos orient*/
    }

    if (best_view_index == TOP_VIEW) dim_geom->vector[2] = 0.0;
    else if (best_view_index == FRONT_VIEW) dim_geom->vector[1] = 0.0;
    else if (best_view_index == RIGHT_VIEW) dim_geom->vector[0] = 0.0;
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

wrapup:
  if (edge_grids) om$dealloc(ptr = edge_grids);
  if (tmp_curve)
     BSfreecv(&bsrc, tmp_curve);        
  EMWRAPUP(*EMmsg, OM_stat, "EFget_dim_info")
  return(OM_stat);
}
end implementation EMSsfround;
