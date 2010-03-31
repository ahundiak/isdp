/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  This is the autodimension method for drafted lift face.
 *
 * HISTORY:
 *
 *  Tapadia  Creation   08/12/91
 *  DLB      Dimension draft angles  8/15/91
 *  DLB      Cant do dumpt[3]={0,0,0} on the SUN.
 *  Sudha   06/01/93    modified to handle BSprototype headers
 *  Satya   11/03/93    Added value_type argument to dm$place_text_with_leader
			for TR 119307898
 */
class implementation EMSsfdlift;

#include "OMmacros.h"
#include "dimdef.h"
#include "dimplcmacros.h"
#include "dimmacros.h"
#include "EMSdimdef.h"
#include "EMSlift.h"
#include "bserr.h"
%safe
#include "math.h"
#include "bsdotp.h"
%endsafe

#define MAGNITUDE       0
#define DEG_TO_RAD M_PI/180

from expression import NDgive_value;

extern OMuword OPP_DMroot_class_id;

/* This method calls the appropriate auto dimensioning */

method EMdim(IGRlong             *EMmsg;
             struct GRmd_env     *env;
             IGRushort   options;
             IGRint              type;
             IGRchar             *info;
             IGRint              num_parents;
             struct GRid         *parents)
{
  IGRpoint          dumpt;
  IGRdouble         attach_pt[3], min_len;
  IGRpoint          orig_pt;
  IGRdouble         break_pt[6], flip, dotp, draft;
  IGRvector         dim_plane_xaxis, z_axis;
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            dim_type=-1;        
  OMuint            txt_len, expr_count, num_sfs, trak_dir;
  OMuint            ii, jj, *parent_type=NULL, cur_par;
  BSrc              bsrc;
  struct EMSdlft_info    *dlift_info;
  struct EMSdrafted_lift *dlft_recomp_info=NULL;
  struct GRid       source_id;
  struct GRid       expr_list, my_grid, dim_grid, attach_grid;
  struct IGRplane   dim_plane;
  struct EMSgeomdata dim_geom;
  IGRchar           txt_str[100], txt_str1[100];
  struct DMsenv_param dim_par;


  *EMmsg = EMS_S_Success;

  dumpt[0] = dumpt[1] = dumpt[1] = 0;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  dm$get_dim_param(type = DM_SENV_PARAM,
			dim_objid = NULL_OBJID,
			dim_osnum = OM_Gw_current_OS,
			p_data = &dim_par);

  /* Tapadia - 01/27/92. This is done so that the leader lines do not become 
  smaller than the arrow (at the attach point when the radius is very small) */

  min_len = 2.0 * dim_par.txt_heig;

  EFget_parent_source(&my_grid, &source_id);

  /* Dimension the magnitude */
  if(!(EFselect_first_component(&parents[MAGNITUDE],
                                OPP_DMroot_class_id,
                                &dim_grid) & 1))
  {
    dim_grid.objid = NULL_OBJID;
    trak_dir = 1;
    dm$place_sglpara(orig_grid  = &source_id,
                     orig_pt    = dumpt,
                     plane_grid = &source_id,
                     trak_dir   = trak_dir,
                     owner      = &parents[MAGNITUDE],
                     dim_grid   = &dim_grid);
    if (dim_grid.objid == NULL_OBJID) {*EMmsg = EMS_E_Fail; goto wrapup;}
  }
  
  /*Dimension the draft angles*/
  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, NULL, NULL,
                          (IGRchar **) &dlft_recomp_info),
                    targetid = my_id);                          
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  dlift_info = dlft_recomp_info->dlift_info;
  
  parent_type = (OMuint *) alloca(num_parents * sizeof(OMuint));
  if (!parent_type) {*EMmsg=EMS_E_NoStackMemory; goto wrapup;}

  if (dlift_info->uniform_surface) parent_type[2] = EMSangle;
  else
  {
    for(ii=0, cur_par=2; ii<dlift_info->num_lps; ii++)
    {
      if (dlift_info->lps_info[ii].is_uniform)
      {
        parent_type[cur_par++] = EMSgrid;
        parent_type[cur_par++] = EMSangle;
      }
      else
      {
        for(jj=0; jj<dlift_info->lps_info[ii].num_eds; jj++)
        {
          parent_type[cur_par++] = EMSgrid;
          parent_type[cur_par++] = EMSangle;
        }
      }
    }
  }

  dim_plane.point = orig_pt;
  dim_plane.normal = z_axis;

  for(ii=2; ii<num_parents; ii++)
  {
    if (parent_type[ii] == EMSangle)
    {
      /* Get the draft angle */
      OM_stat = om$send(msg= message expression.NDgive_value(&draft),
                        targetid = parents[ii].objid,
                        targetos = parents[ii].osnum);
      if (!(1 & OM_stat)) goto wrapup;

      if (draft == 0.0) continue;

      dim_grid.objid = NULL_OBJID;
      dim_geom.geomtype = GEOMDATA_NULL;

      OM_stat = om$send(msg = message EMSdim.EMdimparam(EMmsg,
                              env, options, type, info, num_parents, parents,
                              ii /*Parent paramval index*/,  
                              &dim_plane, dim_plane_xaxis, &dim_geom,
                              &dim_type), 
                        targetid = my_id);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
      OM_BLOCK_MOVE(dim_geom.point, attach_pt, sizeof(IGRpoint));
  
      for(jj=0; jj<3; jj++)
      {
        break_pt[jj] = attach_pt[jj] + dim_geom.vector[jj] * min_len;
      }
  
      dotp = BSdotp(&bsrc, dim_geom.vector, dim_plane_xaxis);
    
      if (dotp < 0) flip = -1.0;
      else flip = 1.0;

      for(jj=3; jj<6; jj++)
      {
        break_pt[jj] = break_pt[jj - 3] + 
                       (flip * 1.2 * min_len * dim_plane_xaxis[jj - 3]);  
      }

      strcpy(txt_str, "%2.1lf Deg. Draft");

      if (dlift_info->uniform_surface)
      {
        for(jj=0, num_sfs = 0; jj<dlift_info->num_lps; jj++)
          num_sfs += dlift_info->lps_info[jj].num_eds;
      }
      else
      {
        OM_stat = EFget_num_fillet_sfs(EMmsg, &parents[ii-1], my_id,
                                       &num_sfs); 
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
  
      /*** Added value_type argument -- 05 Nov 93 -- Satya ***/
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
                                dim_grid = &dim_grid);
      if (dim_grid.objid == NULL_OBJID)
      {*EMmsg = EMS_E_Fail; goto wrapup;}
    }
  }

wrapup:
  if (dlft_recomp_info)
  {
    if (dlft_recomp_info->view_info) om$dealloc
                                     (ptr = dlft_recomp_info->view_info); 
    om$dealloc(ptr = dlft_recomp_info);
  }
  EMWRAPUP(*EMmsg, OM_stat, "sfdlft.EMdim")
  return(OM_stat);
}

/* This method returns the geometry, plane & axis to the dimensioning macro */
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
  IGRlong                OM_stat=OM_S_SUCCESS;
  OMuint                 ii, jj, parent_index, sf_index;
  GRobjid                cham_id;
  struct EMSdlft_info    *dlift_info;
  struct EMSdrafted_lift *dlft_recomp_info=NULL;
  OM_S_CHANSELECT        to_comps; 
  OMuword                dumosnum;


  if (ME.EMSdpr->dpr_props & EMS_NULL_STATE)
  {
    *EMmsg = EMS_E_Fail;
    return(OM_S_SUCCESS);
  }

  *EMmsg = EMS_S_Success;

  if(index == 0)
  { 
    /* for drafted magnitude */
    OM_stat= om$send(mode = OM_e_wrt_parent,
                     msg = message EMSsfdlift.EMdimparam(EMmsg, env,
                           options, type, info, 
                           num_parents, parents, index, 
                           dim_plane, dim_plane_xaxis,
                           dim_geom, dim_type),
                     targetid = my_id);
  }
  else
  {
    OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL, NULL,
                            NULL, (IGRchar **) &dlft_recomp_info),
                      targetid = my_id);                          
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (! dim_geom)
    {
      /*The dim orientation is only needed so just extract it from my instance
       * data.
       */
      OMuword best_view_index;

      if (dlft_recomp_info->num_views)
      {
        for(ii=0; ii<dlft_recomp_info->num_views; ii++)
        {
          if (dlft_recomp_info->view_info[ii].parent_index == index) break;
        }
        best_view_index = dlft_recomp_info->view_info[ii].view_index ;
      }
      else {*EMmsg = EMS_E_InvalidCase; goto wrapup;}  /*NO_VIEW*/
   
      if (best_view_index == NO_VIEW)
      {*EMmsg = EMS_E_InvalidCase; goto wrapup;}  /*NO_VIEW*/

      if (dim_plane) 
      {
        dim_plane->point[0] = dim_plane->point[1] = dim_plane->point[2] = 0.0;
         
        if (best_view_index == TOP_VIEW)
        {
          dim_plane->normal[0] = 0.0;
          dim_plane->normal[1] = 0.0;
          dim_plane->normal[2] = 1.0;
        }
        else if (best_view_index == FRONT_VIEW)
        {
          dim_plane->normal[0] = 0.0;
          dim_plane->normal[1] = -1.0;
          dim_plane->normal[2] = 0.0;
        }      
        else
        {
          dim_plane->normal[0] = 1.0;
          dim_plane->normal[1] = 0.0;
          dim_plane->normal[2] = 0.0;
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
      dlift_info = dlft_recomp_info->dlift_info;

      sf_index = 2; /*Start with first chamfer surface on to_comps*/
    
      if (!dlift_info->uniform_surface)
      {
        for(ii=0, parent_index=2; ii<dlift_info->num_lps; ii++)
        {
          if (dlift_info->lps_info[ii].is_uniform)
          {
            parent_index++;  /*Go past objid*/          
            if (parent_index == index) break;
            else
            {
              parent_index++; /*Go to next objid*/
              sf_index += dlift_info->lps_info[ii].num_eds; /*skip past sfs*/
            }
          }
          else
          {
            for(jj=0; jj<dlift_info->lps_info[ii].num_eds; jj++)
            {
              parent_index++;  /*Go past objid*/          
              if (parent_index == index) break;
              else
              {
                parent_index++; /*Go to next objid*/
                sf_index++;     /*skip past sf*/
              }
            }
            if (parent_index == index) break;
          }
        }
      }
  
      /*Get the chamfer surface to query*/
      EMmake_chanselect(GRcmpowner_to_components, &to_comps);
      OM_stat = om$get_objid_at_index(object = me,
                                      p_chanselect = &to_comps,
                                      index = sf_index,
                                      objidaddr = &cham_id,
                                      osnumaddr = &dumosnum);
      if (OM_stat == OM_E_INVINDEX)
      {
        /*During recompute the surfaces went away.*/
        OM_stat = OM_S_SUCCESS;
        goto wrapup;
      }
      else if (!(1 & OM_stat)) goto wrapup;                                  
    
      /*Get the dim information*/
      OM_stat = EFget_dim_info(EMmsg, cham_id, OM_Gw_current_OS, env,
                               info, num_parents, parents, 
                               dim_plane, dim_plane_xaxis, dim_geom, dim_type, 
                               NULL);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (dim_geom)
      {
        if (dim_plane)
        {
          OMuint num_views;

          num_views = dlft_recomp_info->num_views;
          if (!num_views)
            dlft_recomp_info->view_info = (struct EMSview_info *) 
                                 om$malloc(size = sizeof(struct EMSview_info));
          else
          {
            dlft_recomp_info->view_info = (struct EMSview_info *)
                           om$realloc(ptr = (IGRchar *)dlft_recomp_info->view_info,
                                      size = (num_views+1) * 
                                             sizeof(struct EMSview_info));
          }
          if (!dlft_recomp_info->view_info)
          {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}

          dlft_recomp_info->view_info[num_views].parent_index = index;

          if (dim_plane->normal[2] == 1.0) 
            dlft_recomp_info->view_info[num_views].view_index = TOP_VIEW;
          else if (dim_plane->normal[1] == -1.0)
            dlft_recomp_info->view_info[num_views].view_index = FRONT_VIEW;
          else
            dlft_recomp_info->view_info[num_views].view_index = RIGHT_VIEW;

          dlft_recomp_info->num_views++;

          OM_stat = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL,
                                  type, sizeof(struct EMSdrafted_lift),
                                  (IGRchar *)dlft_recomp_info), 
                            targetid = my_id);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        }
      }
    }
  }

wrapup:
  if (dlft_recomp_info)
  {
    if (dlft_recomp_info->view_info) om$dealloc
                                     (ptr = dlft_recomp_info->view_info); 
    om$dealloc(ptr = dlft_recomp_info);
  }
  EMWRAPUP(*EMmsg, OM_stat, "dlft.EMdimparam")
  return(OM_stat);
}
end implementation EMSsfdlift;
