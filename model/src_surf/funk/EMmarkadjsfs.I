class  implementation EMSsubbs;

#include "EMS.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_S.h"
#include "msmacros.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsgeteddef.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "ECcmd.h"
#include "ECmsg.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include  <values.h>
#include  <math.h>

#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsaddraft.h"
#include "emsgeteddef.h"
 

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMSloopset_class_id;

from EMSedge import EMget_sf_edges, EMchkconvex;
from EMSedge import  EMgetsurface_info;
from EMSloop import  EMnext_edge, EMget_props;
from EMSloopset import  EMget_loops;



IGRint   EMmark_adj_surfs(EMmsg,
                    md_env,
                    const_list,
                    hinges,
                    num_affect_sfs,
                    adj_surfs_info_list,
                    min_angle)

   IGRlong *EMmsg;
   struct GRmd_env *md_env;
   struct GRvg_construct *const_list;
   GRobjid *hinges;
   IGRint *num_affect_sfs ;
   struct EMSadj_surf_info ***adj_surfs_info_list;
   IGRdouble *min_angle;
   {
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint  ii, jj, index;
    struct EMSadj_surf_info **adj_sf_info_list= NULL;
    IGRdouble angle,  angle_measure2, nutral_angle_tol, value1, value2;
    IGRboolean   index_found,ed_is_convex, ed_is_nutral;
    IGRushort convex_opts;
    struct IGRbsp_surface *this_srf=NULL, *adj_srf=NULL;
    OM_S_CHANSELECT  to_loops, to_owner, to_common;

    stat_OM = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
    stat_OM = EMmake_chanselect (EMSedge_to_owner, &to_owner);
    stat_OM = EMmake_chanselect(EMSedge_to_common_edge, &to_common);
    EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

    adj_sf_info_list =  *adj_surfs_info_list;
        
        *min_angle = 1000.0;
        for(ii=0; ii< *num_affect_sfs; ii++)
         {
          adj_sf_info_list[ii]->extend = 1;
          adj_sf_info_list[ii]->affect |= EM_ADDRFT_EXTND;
          for(jj=0; jj< adj_sf_info_list[ii]->num_adjacent; jj++)
            {
              if(hinges && adj_sf_info_list[ii]->myself.objid == *hinges)
                  {
                  adj_sf_info_list[ii]->comedge_cncv[jj] = 2;
                  continue;
                  }
              if(adj_sf_info_list[ii]->comedge_cncv[jj] >2)
                   continue;
              angle_measure2= 0;
              ed_is_convex = FALSE;
              ed_is_nutral = FALSE;
              convex_opts = NULL;
              convex_opts |= EMSchkconvex_nextgeomsf ;
              nutral_angle_tol = EMS_ZEROANGLE_DEG;
              stat_OM = om$send (msg = message EMSedge.EMchkconvex
                   ( &msg_loc,
                     convex_opts,
                     &md_env->md_env.matrix_type,
                     md_env->md_env.matrix,
                     nutral_angle_tol,
                     &ed_is_convex,
                     &ed_is_nutral,
                     &angle_measure2),
                targetid = adj_sf_info_list[ii]->commedges[jj],
                targetos = adj_sf_info_list[ii]->myself.osnum,
                senderid = NULL_OBJID);
             EMerr_hndlr(!(stat_OM&msg_loc&1), *EMmsg, EMS_E_EdgeError, wrapup);

             if(fabs(angle_measure2-2.0) > .1)
              {
               adj_sf_info_list[ii]->comedge_cncv[jj] =
                                         angle_measure2 < 2.0 ? 1 : 0;
                if(adj_sf_info_list[ii]->affect&EM_ADDRFT_DRAFT_SRF) 
                    {
                    value1 = fabs(angle_measure2 - 1.0);
                    value2 = fabs(angle_measure2 - 3.0);
                    value1 = value1 < value2 ? value1 : value2 ;
                    angle = acos(value1);
                    *min_angle = angle < *min_angle ? angle : *min_angle;
                     }
             }
             else
             {
                adj_sf_info_list[ii]->comedge_cncv[jj] = 2;
/***************
                EFget_surf_geom(&msg_loc, md_env,
                       adj_sf_info_list[ii]->myself.objid,
                            adj_sf_info_list[ii]->myself.osnum, &this_srf);
                if(adj_sf_info_list[ii]->affect&EM_ADDRFT_DRAFT_SRF &&
                     this_srf->planar)
                    {
                     index_found = EMget_inx_w_sf(&msg_loc, *num_affect_sfs,
                        adj_sf_info_list, &adj_sf_info_list[ii]->adj_surfs[jj],
                          &index);
                     if(!index_found   ||
                      ( index_found && 
                       !(adj_sf_info_list[index]->affect&EM_ADDRFT_DRAFT_SRF)))
                       {
                        EFget_surf_geom(&msg_loc, md_env,
                          adj_sf_info_list[index]->myself.objid,
                            adj_sf_info_list[index]->myself.osnum, &adj_srf);
                            if(adj_srf->planar)
                              {
                               ex$message(msgnumb = EMS_F_AdjSurfTan);
                               EMerr_hndlr(TRUE,*EMmsg, EMS_E_EdgeError,wrapup);
                              }
                            if(adj_srf){om$dealloc(ptr=adj_srf); adj_srf=NULL;}
                       }
                     }
******************/
              }
            if(this_srf){om$dealloc(ptr=adj_srf); this_srf=NULL;}
           }
        }
   wrapup:
        if(adj_srf){om$dealloc(ptr=adj_srf); adj_srf=NULL;}
        if(this_srf){om$dealloc(ptr=adj_srf); this_srf=NULL;}
        EMWRAPUP( *EMmsg, stat_OM, "EMmark_adj_sfs");
        return (stat_OM);
    }

 
IGRint   EMput_range_adj_sfs(EMmsg,
                    md_env,
                    num_affect_sfs,
                    adj_sfs_info_list,
                    cp_sfs_info_list)

   IGRlong *EMmsg;
   struct GRmd_env *md_env;
   IGRint *num_affect_sfs ;
   struct EMSadj_surf_info **cp_sfs_info_list;
   struct EMSadj_surf_info **adj_sfs_info_list;

   {
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    IGRint ii;
    IGRushort surf_change;
    struct IGRbsp_surface  *new_geom;

    for(ii=0; ii< *num_affect_sfs; ii++)
      {
      if((ii>0) && (cp_sfs_info_list[ii]->myself.objid == 
                   cp_sfs_info_list[ii-1]->myself.objid))
           continue;

       EFget_surf_geom(&msg_loc, md_env,
                        cp_sfs_info_list[ii]->myself.objid,
                        cp_sfs_info_list[ii]->myself.osnum, &new_geom);
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

        surf_change = GEOMETRICAL;
        stat_OM = om$send(msg = message EMSsubbs.EMput_range_in_rtree(
                     &msg_loc, new_geom, NULL, NULL,
                     surf_change, &md_env->md_id),
                        senderid = NULL_OBJID,
                        targetid = cp_sfs_info_list[ii]->myself.objid,
                        targetos = cp_sfs_info_list[ii]->myself.osnum);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);


        if(new_geom) om$dealloc(ptr=new_geom);
           new_geom=NULL;
        }

   wrapup:
    return(stat_OM);
  }

end  implementation EMSsubbs;



