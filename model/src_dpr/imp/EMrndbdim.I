class implementation EMSsfrndbool;

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
#include "EMSlmdef.h"

#include "bsparameters.h"
#include "bsdotp.h"
#include "bsalloccv.h"
#include "bsmdstptcv.h"
#include "bsfreecv.h"
#include "bsconstprcv.h"
#incldue "bsrdcencrcv.h"
#include "bscvnormal.h"
#include "bsproj1.h"


#define ABS(X) ((X) >= 0 ? (X) : -(X))
#define CONST_V 2
#define U 0
#define V 1


#define X 0
#define Y 1
#define Z 2
#define DEG_TO_RAD M_PI/180

from EMSparamgm import EMgetgeom;
from EMSedge    import EMget_bcxyz_geom, EMtangent,EMendpts,EMxyz_endpt;
from expression import NDgive_value;
from EMSsubbs   import EMgetuvrange,EMget_edges, EMtangent_normal;
from EMSloop    import EMget_edges;
from DMroot     import copy_dim_attr;


extern IGRlong is_variable_operation();
extern IGRlong EFget_attach_pt();
extern IGRlong EFcheck_plane();
extern IGRlong EMcompute_breakpts();
extern GRclassid OPP_expression_class_id;
#argsused

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

    Sudha   06/23/93    Modified for BSprototype ansification
    Jack    06/03/93    Added code to deallocate "r_c_info" to fix Purify
                        memory leak.
    Janaka  01/13/93    Made modifications to retain the original auto
                        dimensioning functionality under initial Phoenix
                        modifications to rounding.
    DLB     08/08/91    Creation.
*/
{
  IGRdouble         attach_pt[3],min_len;
  IGRpoint          orig_pt;
  IGRdouble         break_pt[9], radius;   
  IGRvector         dim_plane_xaxis, y_axis,z_axis;
  IGRlong           OM_stat=OM_S_SUCCESS;
  BSrc              bsrc;
  IGRint            incr,new_incr,num_sfs,txt_len,start_rad,dim_type=-1;        
  OMuint            ii, jj;
  struct GRid       expr_list, my_grid, dim_grid,dim_grid1, attach_grid;
  struct IGRplane   dim_plane;
  struct EMSgeomdata dim_geom;
  struct DMsenv_param dim_par;
  struct DMloc_param par_loc;
  IGRboolean        is_variable;
  unsigned short    op_type;
  IGRchar           txt_str[100], txt_str1[40];
  IGRint tmp_num_sfs,expr_count;


  *EMmsg = EMS_S_Success;


  if (type == EMS_ASround )
    op_type = EMS_ROUND_OPR;
  else
    op_type = EMS_CHAMFER_OPR;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
    
  dim_plane.point = orig_pt;
  dim_plane.normal = z_axis;

  dm$get_dim_param(type = DM_SENV_PARAM,
                        dim_objid = NULL_OBJID,
                        dim_osnum = OM_Gw_current_OS,
                        p_data = &dim_par);

  min_len = 3.0 * dim_par.txt_heig;
  /* Tapadia - 01/27/91. This is done so that the leader lines do not become 
  smaller than the arrow (at the attach point when the radius is very small) */

  new_incr = incr = 0;
  for(ii=0; ii<num_parents; ii+=new_incr)
  {
    IGRint num_edges;
    dim_grid.objid = NULL_OBJID;
    dim_grid1.objid = NULL_OBJID;
    dim_geom.geomtype = GEOMDATA_NULL;
    
    OM_stat = is_variable_operation( EMmsg,num_parents, parents, 
                              ii,&num_edges, &is_variable ,&start_rad);
    if( !( 1 & OM_stat & *EMmsg ) )
     goto wrapup;

    new_incr = num_edges+ 1;
    num_sfs = 0;

    OM_stat = om$send(msg = message EMSdim.EMdimparam(EMmsg,
                            env, options, type, info, num_parents, parents,
                            ii /*Parent paramval index*/,  
                            &dim_plane, dim_plane_xaxis, &dim_geom, &dim_type),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  
    OM_BLOCK_MOVE(dim_geom.point, attach_pt, sizeof(IGRpoint));

    OM_stat = dm$get_dim_param(type = DM_LOC_PARAM,
			       dim_objid = NULL_OBJID,
			       dim_osnum = OM_Gw_current_OS,
			       p_data = (char *)&par_loc);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if( par_loc.deci_frac == DECIMAL_MODE)
      {
	if (op_type == EMS_ROUND_OPR) 
	  {
	    if(is_variable)
	      sprintf(txt_str,"Varying Radius  %%.%dlf",par_loc.primary.decacc);
	    else sprintf(txt_str, "R %%.%dlf",par_loc.primary.decacc);      
	  }
	else sprintf(txt_str, "CHAM %%.%dlf",par_loc.primary.decacc);      
      }
    else
      {
 	if (op_type == EMS_ROUND_OPR) 
	  {
	    if(is_variable)
	      strcpy(txt_str, "Varying Radius  %4.3lf");
	    else strcpy(txt_str, "R %4.3lf");      
	  }
	else strcpy(txt_str, "CHAM %4.3lf");      
     }

    if(!is_variable)
      {
      for(jj=ii+1; jj<new_incr+ii; jj++)
        {
        OM_stat = EFget_num_fillet_sfs(EMmsg, &parents[jj], my_id, 
                                       &tmp_num_sfs);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        num_sfs += tmp_num_sfs;
        }

        if (num_sfs > 1)
        {
          sprintf(txt_str1, "\n(%d places)", num_sfs);
          strcat(txt_str, txt_str1);
        }
      }
      OM_stat = om$send(msg= message expression.NDgive_value(&radius),
                      targetid = parents[ii].objid,
                      targetos = parents[ii].osnum);
      if (!(1 & OM_stat)) goto wrapup;
     OM_stat =  EMcompute_breakpts(ii,parents,
                                   dim_plane_xaxis,dim_geom,break_pt);
     if (!(1 & OM_stat)) goto wrapup;

    txt_len = strlen(txt_str);
  
    expr_list.objid = parents[ii].objid;
    expr_list.osnum = parents[ii].osnum;
  
    attach_grid.objid = parents[ii].objid;
    attach_grid.osnum = parents[ii].osnum;
    expr_count = 1;
  
    dm$place_text_with_leader(attach_ele = &my_grid,
                              attach_pt = attach_pt,
                              num_brkpt = 2,
                              brkpt = &break_pt[3],
                              text_length = txt_len,
                              text_string = txt_str,
                              expr_count = expr_count,
                              expr_list = &expr_list,
                              plane_grid = &my_grid,
                              owner = &attach_grid, 
                              dim_grid = &dim_grid);
    if (dim_grid.objid == NULL_OBJID)
      {*EMmsg = EMS_E_Fail; goto wrapup;}
    if(is_variable) 
      {
      ++new_incr;
      if(radius < min_len ) radius = min_len;
      
      OM_BLOCK_MOVE(&break_pt[3], attach_pt, sizeof(IGRpoint));
      BScrossp(&bsrc,dim_plane.normal,dim_plane_xaxis,y_axis);
      for(jj = 0; jj < 3; jj++)
        attach_pt[jj] -= y_axis[jj]*(radius/2 + dim_par.txt_heig) ;

      strcpy(txt_str, "         to %4.3lf");      
      txt_len = strlen(txt_str);
  
      expr_list.objid = parents[ii+1].objid;
      expr_list.osnum = parents[ii+1].osnum;
  
      attach_grid.objid = parents[ii+1].objid;
      attach_grid.osnum = parents[ii+1].osnum;
      expr_count = 1;
  
      dm$place_text_with_leader(attach_ele = &dim_grid,
                              attach_pt = attach_pt,
                              num_brkpt = 0,
                              brkpt = NULL,
                              text_length = txt_len,
                              text_string = txt_str,
                              expr_count = expr_count,
                              expr_list = &expr_list,
                              plane_grid = &my_grid,
                              owner = &attach_grid, 
                              dim_grid = &dim_grid1);
      if (dim_grid1.objid == NULL_OBJID)
        {
        *EMmsg = EMS_E_Fail; 
        goto wrapup;
        }
      }

  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "rnd.EMdim")
  return(OM_stat);
}

/*
DLB     12/12/92    If NULL_STATE return error.    
*/

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
  OMuint            num_edges,ii, sf_index;
  IGRint            tmp_num_sfs,num_sfs,txt_len,dm_msg,
                    new_incr,to_add,view_ind,start_rad,ret_val;
  IGRuint   type, size;
  unsigned short    op_type;
  OM_S_CHANSELECT   to_comps; 
  struct EMSround_chamfer *r_c_info=NULL;
  struct EMSgeomdata dim_geom1;
  struct IGRplane    dim_plane1;
  IGRpoint          orig_pt;
  IGRvector         z_axis;
  GRobjid           dim_id,fill_id;
  OMuword           temp_best_view,dum_view,dumosnum, best_view_index;
  IGRboolean        is_variable;
  struct  GRid      expr_list,dim_grid,my_grid;
  IGRdouble         pts[9],att_pt[3];
  IGRchar           txt_str[100], txt_str1[40];
  enum GRdpmode display_mode ;
  extern IGRlong EMpost_view_info();


  if (ME.EMSdpr->dpr_props & EMS_NULL_STATE)
  {
    *EMmsg = EMS_E_Fail;
    return(OM_S_SUCCESS);
  }

  *EMmsg = EMS_S_Success;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg,
                          NULL, &type, &size, 
                          (IGRchar **) &r_c_info),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
  OM_stat = is_variable_operation( EMmsg,num_parents, parents,index, 
                     &num_edges, &is_variable ,&start_rad);


  if (! dim_geom)
  {
    /*The dim orientation is only needed so just extract it from my instance
     * data.
     */
    if (r_c_info->num_views)
    {
      for(ii=0; ii<r_c_info->num_views; ii++)
      {
        if(is_variable && start_rad == 1)
          if (r_c_info->view_info[ii].parent_index == index -1 ) break;
        if (r_c_info->view_info[ii].parent_index == index) break;
      }
      best_view_index = r_c_info->view_info[ii].view_index ;
      view_ind = ii;

    }
    else {*EMmsg = EMS_E_InvalidCase; goto wrapup;}  /*NO_VIEW */
   
    if (best_view_index == NO_VIEW || size < sizeof(struct EMSround_chamfer))
    {*EMmsg = EMS_E_InvalidCase; goto wrapup;}
   }
  {
    /*Compute the surface to use for dimparam info*/
  
    OM_stat = is_variable_operation( EMmsg,num_parents, parents,index, 
                     &num_edges, &is_variable ,&start_rad);
    if( !( 1 & OM_stat & *EMmsg ))
       goto wrapup;
    new_incr = num_edges + 1;
  
  
    EMmake_chanselect(GRcmpowner_to_components, &to_comps);


    ret_val = EFget_sf_index(num_parents,parents,&fill_id,index,my_grid);

    sf_index = ret_val;
    /*Get the fillet surface to query*/
    OM_stat = om$get_objid_at_index(objid = fill_id,
                                    p_chanselect = &to_comps,
                                    index = sf_index,
                                    objidaddr = &fill_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;                                  
  
    OM_stat = EFcheck_plane(EMmsg, fill_id, OM_Gw_current_OS, env,
                            dim_plane,dim_plane_xaxis, dim_geom, dim_type);
    
    if(!(*EMmsg))
        /*Get the dim information*/
      OM_stat = EFget_dim_info(EMmsg, fill_id, OM_Gw_current_OS, env,
                             info, num_parents, parents, 
                             dim_plane, dim_plane_xaxis, dim_geom, dim_type, 
                             NULL);
      EFget_attach_pt(EMmsg,my_grid,env,num_parents,parents,
                      index,att_pt,num_edges);
      if(dim_geom)
      OM_BLOCK_MOVE(att_pt,dim_geom->point,sizeof(IGRpoint));
      if(dim_plane)
        {
        OM_BLOCK_MOVE(att_pt,dim_plane->point,sizeof(IGRpoint));
        if(!dim_geom)
          {
          if (dim_plane->normal[2] == 1.0)
            dum_view = TOP_VIEW;
          else if (dim_plane->normal[1] == -1.0)
            dum_view = FRONT_VIEW;
          else
            dum_view= RIGHT_VIEW;
          if (best_view_index != dum_view) temp_best_view = dum_view;
          else temp_best_view =  best_view_index ;

          dim_plane->point[0] = dim_plane->point[1] = dim_plane->point[2] = 0;
      
          if (temp_best_view == TOP_VIEW)
            {
            dim_plane->normal[0] = 0;
            dim_plane->normal[1] = 0;
            dim_plane->normal[2] = 1;
            }
          else if (temp_best_view == FRONT_VIEW)
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
        
          if (dim_plane_xaxis) 
            {
            if (temp_best_view == TOP_VIEW || temp_best_view == FRONT_VIEW)
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
            if(best_view_index != dum_view)
              {
              if (type == EMS_ASround ) op_type = EMS_ROUND_OPR;
              else op_type = EMS_CHAMFER_OPR;
              to_add = 0;
              OM_stat = EMpost_view_info(to_add, r_c_info,view_ind,
                                   index,dim_plane,my_grid,type);
              if( !( 1 & OM_stat & *EMmsg )) goto wrapup;
              OM_stat = om$get_objid_at_index(objid = parents[index].objid,
                                    p_chanselect = &to_comps,
                                    index = 0,
                                    objidaddr = &dim_id,
                                    osnumaddr = &dumosnum);
              if( !( 1 & OM_stat & *EMmsg )) goto wrapup;
              dim_plane1.point = orig_pt;
              dim_plane1.normal = z_axis;
              OM_stat = EFcheck_plane(EMmsg, fill_id, OM_Gw_current_OS, env,
                            &dim_plane1,NULL, &dim_geom1, NULL);
              OM_BLOCK_MOVE(att_pt,dim_geom1.point,sizeof(IGRpoint));
              OM_stat =  EMcompute_breakpts(index,parents,
                                   dim_plane_xaxis,dim_geom1,pts);
              if (!(1 & OM_stat)) goto wrapup;
              if (op_type == EMS_ROUND_OPR)
                {
                if(is_variable)
                  strcpy(txt_str, "Varying Radius  %4.3lf");
                else strcpy(txt_str, "R %4.3lf");
                }
              else strcpy(txt_str, "CHAM %4.3lf");
              if(!is_variable)
                {
                num_sfs = tmp_num_sfs = 0;
                for(ii=index+1; ii<new_incr+index; ii++)
                  {
                  OM_stat = EFget_num_fillet_sfs(EMmsg, &parents[ii], my_id,
                                                 &tmp_num_sfs);
                  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
                  num_sfs += tmp_num_sfs;
                  }
          
                  if (num_sfs > 1)
                  {
                    sprintf(txt_str1, "\n(%d places)", num_sfs);
                    strcat(txt_str, txt_str1);
                  }
                }
              txt_len = strlen(txt_str);
              expr_list.objid = parents[index].objid;
              expr_list.osnum = parents[index].osnum;

              display_mode = GRbe;
              OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg,
                                        &env->md_env.matrix_type,
                                        env->md_env.matrix, &display_mode,
                                        &env->md_id),
                                      targetid = dim_id,
                                      targetos = dumosnum);
              if( !( 1 & OM_stat & *EMmsg )) goto wrapup;

              dm$place_text_with_leader(attach_ele = &my_grid,
                              attach_pt = &pts[0],
                              num_brkpt = 2,
                              brkpt = &pts[3],
                              text_length = txt_len,
                              text_string = txt_str,
                              expr_count = 1,
                              expr_list = &expr_list,
                              plane_grid = &my_grid,
                              owner = &expr_list,
                              dim_grid = &dim_grid);
              if (dim_grid.objid == NULL_OBJID)
                {*EMmsg = EMS_E_Fail; goto wrapup;}
              OM_stat = om$send(msg = message DMroot.copy_dim_attr( &dm_msg,0,
                                                     &dim_grid,
                                                     env),
                                      targetid = dim_id,
                                      targetos = dumosnum);
              if( !( 1 & OM_stat & *EMmsg )) goto wrapup;
              OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg,
                                                          env),
                                      targetid = dim_grid.objid,
                                      targetos = dim_grid.osnum);
              if( !( 1 & OM_stat & *EMmsg )) goto wrapup;
              }
          }
        }
    }

    if (dim_geom)
    {
      if (dim_plane)
      {
        view_ind = r_c_info->num_views + 1;
        to_add = 1;
        OM_stat = EMpost_view_info(to_add, r_c_info,view_ind,
                                   index,dim_plane,my_grid,type);
        if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      }
    }

wrapup:

   if ( r_c_info )
     om$dealloc( ptr = r_c_info );

  EMWRAPUP(*EMmsg, OM_stat, "rnd.EMdimparam")
  return(OM_stat);
}



IGRlong is_variable_operation( EMmsg,num_parents, parents,index,
                                     num_edges, is_variable,start_rad)
IGRlong 	*EMmsg;
IGRint		num_parents;
struct GRid	*parents;
IGRint 		index;
IGRint           *num_edges;
IGRboolean	 *is_variable;
IGRint           *start_rad;
{
   IGRint	tmp=0,ii;
   IGRlong	OM_stat;


   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   *num_edges = 0;
   *start_rad = 0;
   *is_variable = FALSE;

   if( num_parents == 2 )  
     {
     tmp = 1;
     goto wrapup;
     }
   ii=index;
   if(ii !=0) 
     if(EFisAncestryValid(EMmsg,parents[ii-1].objid,
                           parents[ii].osnum,
                           OPP_expression_class_id,FALSE))
       {
       *start_rad = 1;
       *is_variable = TRUE;
       }

   ii = index + 1;
   if(EFisAncestryValid(EMmsg,parents[ii].objid,
                           parents[ii].osnum,
                           OPP_expression_class_id,FALSE))
     {
      /*  variable radius round */
      *is_variable = TRUE;
      ++ii ;
     }
   
   for(;ii < num_parents;ii++ ) 
     {
     if(EFisAncestryValid(EMmsg,parents[ii].objid,
                           parents[ii].osnum,
                           OPP_expression_class_id,FALSE))
       break;
     else ++tmp;
     }
    


wrapup:

   *num_edges = tmp;
   EMWRAPUP( *EMmsg, OM_stat, "is_variable_operation" );
   return( OM_stat );
}

IGRint EFget_sf_index(num_parents,parents,fill_id,index,my_grid)
IGRint num_parents;
struct GRid *parents;
GRobjid *fill_id;
IGRint index;
struct GRid my_grid;
{
  IGRint sf_index=0,ii,num_sfs=0;
  IGRlong EMmsg;
  IGRlong	OM_stat;
  OM_S_CHANSELECT   to_comps; 
  GRobjid fil_id;
  OMuword dumosnum;

  OM_stat = OM_S_SUCCESS;
  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  /*See if the 1st comp is a surf or compsf*/
    OM_stat = om$get_objid_at_index(objid = my_grid.objid,
                                    osnum = my_grid.osnum,
                                    p_chanselect = &to_comps,
                                    index = 1,
                                    objidaddr = &fil_id,
                                    osnumaddr = &dumosnum);
    if (!(1 & OM_stat)) goto wrapup;

    if ((IGRboolean) EFisAncestryValid(&EMmsg, fil_id, my_grid.osnum,
                                       OPP_EMScompsurf_class_id, FALSE))
    {
      sf_index = 0;
    }
    else
    {
      fil_id = my_grid.objid;
      sf_index = 1;     /*Start with first fillet surface on to_comps*/
    }
  *fill_id = fil_id;
  for(ii=0; ii<num_parents;)  
    {
    if (ii == index) break;
    else
      {
      ii++;
      if(EFisAncestryValid(&EMmsg,parents[ii].objid,
                           parents[ii].osnum,
                           OPP_expression_class_id,FALSE))
      continue;  /*Increment to topology parent*/

      OM_stat = EFget_num_fillet_sfs(&EMmsg, &parents[ii], 
                                  my_grid.objid, &num_sfs);
      if (!(1 & OM_stat & EMmsg)) goto wrapup;

      sf_index += num_sfs;

      }
    }

wrapup:
   return(sf_index);
}


IGRlong EFget_attach_pt(EMmsg, my_grid, env, num_parents, parents,
                        index,att_pt,numedges)
IGRlong            *EMmsg;
struct GRid        my_grid;
struct GRmd_env    *env;
IGRint             num_parents;
struct GRid        *parents;
IGRint             index;
IGRdouble          *att_pt;
IGRint             numedges;
{
  IGRdouble           best_par[2],range[4];
  IGRpoint            lcs_point;
  IGRlong             OM_stat=OM_S_SUCCESS;
  IGRint              ret_val;
  OMuword             dumosnum;
  GRobjid             fill_id;
  OM_S_CHANSELECT   to_comps; 

  *EMmsg = EMS_S_Success;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  ret_val = EFget_sf_index(num_parents,parents,&fill_id,index,my_grid);

/*
  if(numedges > 1 )
    ret_val += numedges/2;
*/
   
  /*Get the fillet surface to query*/
    OM_stat = om$get_objid_at_index(objid = fill_id,
                                    p_chanselect = &to_comps,
                                    index = ret_val,
                                    objidaddr = &fill_id,
                                    osnumaddr = &dumosnum);

    OM_stat = om$send(msg = message EMSsubbs.EMgetuvrange(EMmsg,
                                     range),
                     senderid = NULL_OBJID,
                      targetid = fill_id,
                      targetos = my_grid.osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    /*Get the midpt of the curve*/
    best_par[U] = (range[0] + range[2])/2;
    best_par[V] = (range[1] + range[3])/2;


    OM_stat = om$send(msg = message GRvg.EMptatpr(EMmsg,
                            &env->md_env.matrix_type,
                            env->md_env.matrix,
                            best_par, 2, lcs_point),
                     senderid = NULL_OBJID,
                      targetid = fill_id,
                      targetos = my_grid.osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    OM_BLOCK_MOVE(lcs_point, att_pt,sizeof(IGRpoint));


wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFget_attach_pt")
  return(OM_stat);
}

IGRlong EFcheck_plane(EMmsg, surf_id, osnum, env,
                       dim_plane, dim_plane_xaxis, dim_geom, dim_type)
IGRlong            *EMmsg;
GRobjid            surf_id;
OMuword            osnum;
struct GRmd_env    *env;
struct IGRplane    *dim_plane;
IGRdouble          *dim_plane_xaxis;
struct EMSgeomdata *dim_geom;
IGRint             *dim_type;

{
  IGRvector           top, front, right,nor_vec;
  IGRvector           my_TN[4], best_nor_vec, *view_vec, *best_view;
  IGRdouble           surface_par[2], sum, best_sum=0.0, par ;
  IGRlong             OM_stat=OM_S_SUCCESS, sf_size;
  BSrc                bsrc;
  struct IGRbsp_curve curve, *tmp_curve = NULL;
  struct IGRbsp_surface *surface;
  IGRshort            u_or_v;
  OMuword             ii, jj, best_view_index;
  IGRboolean          check_planar=TRUE;

  *EMmsg = 0;

  top[0]=0.0; top[1]=0.0; top[2]=1.0;
  front[0]=0.0; front[1]= -1.0; front[2]=0.0;
  right[0]=1.0; right[1]=0.0; right[2]=0.0;


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


  surface_par[0] = surface_par[1] = 0.5;
  /*Get the normal vector on the surface.*/
    OM_stat = om$send(msg = message EMSsubbs.EMtangent_normal(EMmsg,
                            env, surface_par, 1.0, my_TN),
                      senderid = NULL_OBJID,
                      targetid = surf_id,
                      targetos = osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    OM_BLOCK_MOVE(my_TN[2], best_nor_vec, sizeof(IGRvector));


    curve.poles = NULL;
    curve.knots = NULL;
    curve.weights = NULL;
    tmp_curve = NULL;

      par = 0.0;
      u_or_v = CONST_V;
      BSalloccv(surface->u_order, surface->u_num_poles, 
                surface->rational, NULL, &tmp_curve, &bsrc);
    if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

    BSconstprcv(&bsrc, surface, &u_or_v, &par, &check_planar, tmp_curve);
    if (BSERROR(bsrc)) {*EMmsg = EMS_E_BSerror; goto wrapup;}

    curve = *tmp_curve;

    *EMmsg = 0; 
    if(!curve.planar) 
      goto wrapup;

    BScvnormal(&bsrc,&curve,nor_vec);
    for(jj=0; jj<NUM_VIEWS; jj++)
    {
      if      (jj == TOP_VIEW)   view_vec = (IGRvector *) top;
      else if (jj == FRONT_VIEW) view_vec = (IGRvector *) front;
      else if (jj == RIGHT_VIEW) view_vec = (IGRvector *) right;
        
      sum = BSdotp(&bsrc, view_vec[0], nor_vec);
      sum = ABS(sum);
      if(jj == TOP_VIEW) best_sum = sum;

      if (best_sum <= sum  )
      {
        best_sum = sum;
        /*Have the best view.*/
        best_view = view_vec; 
        best_view_index = jj;
      }
    }


  *EMmsg = 1; 
  if (dim_type) *dim_type = TEXT_WITH_LEADER;
  
  if (dim_plane) 
    OM_BLOCK_MOVE(best_view, dim_plane->normal, sizeof(IGRvector));

  if(dim_geom)
  {
    dim_geom->geomtype = GEOMDATA_POINT;

    /*Also need to return the normal vector*/
    for(ii=0; ii<3; ii++)
      dim_geom->vector[ii] = best_nor_vec[ii] * -1;  /*flip from pos orient*/

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
  if (tmp_curve)
     BSfreecv(&bsrc, tmp_curve);        
/*
  EMWRAPUP(*EMmsg, OM_stat, "EFcheck_plane")
*/
  return(OM_stat);
}



IGRlong EMpost_view_info(to_add,r_c_info,view_index,index,
                         dim_plane,my_grid,type)
IGRint to_add;
IGRint view_index;
struct EMSround_chamfer *r_c_info;
IGRint index;
struct IGRplane *dim_plane;
struct GRid my_grid;
IGRuint type;
{
  struct EMSround_chamfer *new_r_c_info=NULL;
  OMuint                  new_size, old_size;
  IGRint                  temp_view;
  IGRlong  OM_stat,EMmsg;

  old_size = sizeof(struct EMSround_chamfer) + 
                   r_c_info->num_views * sizeof(struct EMSview_info);
  if(to_add) temp_view = r_c_info->num_views + 1;
  else temp_view = r_c_info->num_views;

  new_size = sizeof(struct EMSround_chamfer) + 
                   temp_view * sizeof(struct EMSview_info);
  new_r_c_info = (struct EMSround_chamfer *) stackalloc(new_size);
  if (!new_r_c_info) {EMmsg = EMS_E_NoStackMemory; goto wrapup;}

  OM_BLOCK_MOVE(r_c_info, new_r_c_info, old_size);

  new_r_c_info->view_info[view_index].parent_index = index;

  if (dim_plane->normal[2] == 1.0)
     new_r_c_info->view_info[view_index].view_index = TOP_VIEW;
  else if (dim_plane->normal[1] == -1.0)
         new_r_c_info->view_info[view_index].view_index = FRONT_VIEW;
  else
    new_r_c_info->view_info[view_index].view_index = RIGHT_VIEW;
  new_r_c_info->num_views = temp_view;

  OM_stat = om$send(msg = message EMSassoc.EMput_info(&EMmsg, NULL, type,
                                new_size, (IGRchar *) new_r_c_info),
                          senderid = NULL_OBJID,
                          targetid = my_grid.objid,
                          targetos = my_grid.osnum);
  if (!(1 & OM_stat & EMmsg)) goto wrapup;

  if (new_r_c_info) stackfree(new_r_c_info);
wrapup:
  return(OM_stat);
}


IGRlong EMcompute_breakpts(index,parents,dim_plane_xaxis,dim_geom,break_pts)
IGRint index;
struct GRid *parents;
IGRvector dim_plane_xaxis;
struct EMSgeomdata dim_geom;
IGRdouble *break_pts;
{
 IGRint jj;
 IGRdouble radius,min_len;
 IGRdouble flip, dotp;   
 struct DMsenv_param dim_par;
 BSrc bsrc;
 IGRlong OM_stat;
 
 dm$get_dim_param(type = DM_SENV_PARAM,
                        dim_objid = NULL_OBJID,
                        dim_osnum = OM_Gw_current_OS,
                        p_data = &dim_par);

  /* Tapadia - 01/27/91. This is done so that the leader lines do not become 
  smaller than the arrow (at the attach point when the radius is very small) */

 min_len = 3.0 * dim_par.txt_heig;

 dotp = BSdotp(&bsrc, dim_geom.vector, dim_plane_xaxis);
    
 if (dotp < 0) flip = -1.0;
 else flip = 1.0;
  
 /* Get the fillet radius */
 OM_stat = om$send(msg= message expression.NDgive_value(&radius),
                      senderid = NULL_OBJID,
                      targetid = parents[index].objid,
                      targetos = parents[index].osnum);
 if (!(1 & OM_stat)) goto wrapup;

 if(radius < min_len) radius = min_len;
  
 for(jj=0; jj<3; jj++) 
    break_pts[jj] = dim_geom.point[jj];
 for(jj=3; jj<6; jj++) 
    break_pts[jj] = dim_geom.point[jj-3] + 
                        dim_geom.vector[jj-3] * radius * 0.85;
 for(jj=6; jj<9; jj++) 
    break_pts[jj] = break_pts[jj - 3] + 
                     (flip * radius * dim_plane_xaxis[jj - 6]);  
wrapup:
  return(OM_stat);
}

end implementation EMSsfrndbool;
