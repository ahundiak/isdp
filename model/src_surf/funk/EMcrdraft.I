class  implementation EMSsubbs;
/*
  HISTORY

         Nirmal  02/93      Creation

         Hari    04/95      Allocating proper memory space for res_crvs_e
                            & res_crvs in EMcreate_draft_sf_geom(). Fix
                            for ABW. 
      
         Hari    05/95      Accounting for the offset distance between the
                            replace surface and the replacement surface in
                            EFget_big_man()

         Hari    07/95      Added check for self-intersection for the 
                            extended surface. If so then the extension
                            distance is reduced and the process is 
                            continued. This founds necessary at this stage 
                            as exact extension distance is not available
                            in EFget_big_man() 

         Hari    08/95      Get the transformation matrix directly using
                            MAgrotmx() This math routine gets the transf
                            ormation  matrix for the rotation with respect
                            to an arbitrary (position) axis. This solves the
                            general problems like angle change && volume
                            change as mentioned in TR119423784.
      
         Hari    09/95      Deextension is done only for self-intersecing
                            surfaces. The revised extension value is modified
                            (made 70% of previous value). The maximum 
                            iteration is restricted to 2. 

         Hari    10/95      Replaced the old code by a new one in getting 
                            single/double draft. This code makes use of the 
                            bounding/non-bounding face concept of the hinge
                            plane wrt the draft surface vertices, in deciding
                            single/double draft.

         Hari    10/95      Dir point is computed based on the partial surface
                            range of the draft surface, instead of considering
                            the range of the natural surface. This becomes
                            important to get the draft vector in proper direc.

         Hari    10/95      New code added to get the exact draft height; the
                            length of the drafted surface, based on the trigno
                            metry concept.

         Hari    11/95      The allowable distance for the draft height was
                            not considering the direction of offset. Added
                            code to achieve the desired results. Fix for
                            TR#119527618

         Hari    11/95      As the draft surface is calculated as small as
                            possible, the hinge curve points which is used
                            for rotating the draft plane is not the projection
                            point on the draft surface, but the point on the
                            hinge curve itself. Commented the unwanted code. 

*/

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
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
#include "bsvalues.h"
#include <math.h>
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsaddraft.h"
#include "bssfarrevt.h"
#include "bssfarrevn.h"
#include "bsrev_cv.h"
#include "bspolyxtdst.h"
#include "bsplptnorrg.h"
#include "bsnorvec.h"
#include "bsmdistptsf.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscvnormal.h"
#include "bscveval.h"
#include "bscvarrevt.h"
#include "bscrossp.h"
#include "bsconstprcv.h"
#include "bsbxint.h"
#include "bsbx2.h"
#include "bscylprop.h"
#include "bspcylprop.h"
#include "bsconprop.h"
#include "bspconprop.h"
#include "bsgeom_cvsf.h"
#include "magrotmx.h"

#define PLANE 1
#define HINGE_EDGE 2
#define HINGE_CURVE 3
#define SINGLE_DRAFT 1
#define DOUBLE_DRAFT 2

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSdatpln_class_id;
extern OMuword OPP_EMSsurface_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMScone_class_id;
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMAcone_class_id;
extern OMuword OPP_EMApcone_class_id;
extern OMuword OPP_EMAcylindr_class_id;
extern OMuword OPP_EMApcylindr_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMAgenbs_class_id;
extern OMuword OPP_EMSdatpln_class_id;
extern OMuword OPP_EMAsphere_class_id;
extern OMuword OPP_EMSsphere_class_id;
extern OMuword OPP_EMApsphere_class_id;
extern OMuword OPP_EMSpsphere_class_id;
extern OMuword OPP_EMAproject_class_id;
extern OMuword OPP_EMSproject_class_id;

from EMSdatpln import give_plane, EMget_pln_info;
from EMSedge import EMget_sf_edges, EMget_bcxyz_geom, EMxyz_endpt;
from EMSedge import  EMgetsurface_info, EMendpts;
from EMSloop import EMnext_edge;
from EMSloopset import  EMpt_location;

extern IGRint EFget_hindge_curve_new(IGRlong *,struct GRmd_env *,GRobjid *,
                struct GRid *,GRobjid *, struct GRvg_construct *,
                struct GRid *,IGRboolean *);

extern IGRint D_get_hingegeom(IGRlong *,struct GRmd_env *,
       struct EMSadj_surf_info *,GRobjid *,IGRdouble *,
       struct IGRbsp_surface **);

extern IGRint D_SinDou_Draft(IGRlong *,struct GRmd_env *,
       struct EMSadj_surf_info *, struct IGRbsp_surface **,IGRint *);
 
EMcreate_draft_sf(EMmsg,
  		          md_env,
                  adj_sf_info,
		          plane,       //pivot surf 
		          hinge_edge,
		          ang_rev,
		          draft_angle,
                  min_angle,
        	      draft_surf_grid,
		          const_list)

IGRlong *EMmsg;
struct GRmd_env *md_env; 
struct GRid    *draft_surf_grid;
struct EMSadj_surf_info *adj_sf_info;
IGRboolean       ang_rev;
GRobjid          *plane, *hinge_edge;
struct GRvg_construct  *const_list;
IGRdouble draft_angle, min_angle;
{
   BSrc rc = BSSUCC;
   IGRlong  msg_loc = EMS_S_Success, stat_OM = OM_S_SUCCESS;
   struct IGRbsp_surface  *draft_surf_geom=NULL, *drafted_surf_geom;
   IGRdouble *range_point_arr = NULL,draft_surf_range[6];
   IGRdouble draft_surf_rng[6];
   IGRdouble dist,  draft_vec[6];
   IGRint     this_is = 1, jj, ii, kk ;
   IGRlong    num_edges =0, buf_size;
   struct GRid *edges = NULL;
   GRobjid *adj_surf_list = NULL;
   IGRboolean  tst_plan,  world=TRUE;
   IGRboolean draft_type_1 = FALSE, draft_type_2 = FALSE;
   IGRdouble vectol,tol,u_par[2], v_par[2],dotp, draft_surf_tan[3];
   struct IGRbsp_curve draft_srf_iso_crv;
   struct GRid     *surf=NULL;
   IGRpoint points[3];
   IGRvector  temp_vec, hinge_curve_tan;
   IGRshort  opt;
   IGRint draft_type;
   IGRdouble  max_dist, point[6], proj_point[3], par;
   IGRdouble sign = 1.0, u_p, v_p;
   struct GRparms proj_params;
   struct EMSpartolbasis ptolbassis;
   struct EMSptloc_info location;
   GRrange hinge_crv_range;
   IGRdouble dir_pt[3];
   GRobjid surf_to_draft;
   struct GRid int_grid;
   IGRdouble draft_ang;
   IGRboolean is_red_neck=TRUE;
   IGRvector nrml1[1][1],nrml[1][1];
   IGRdouble iso_crv_nrml[3], exist_sf_angle;
   IGRpoint pnts[1][1];
   IGRdouble tem_part_range[4];
   struct IGRbsp_curve *hinge_curve_geom=NULL;
   IGRboolean do_not_extend, will_self_intersect = TRUE;
   IGRboolean EFare_surfs_tan();
   OM_S_CHANSELECT   to_common;
   GRclassid class_id;
   void  EFextend_edge_curve();

   stat_OM = EMmake_chanselect(EMSedge_to_common_edge, &to_common);
   EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

   if(plane && !hinge_edge)  this_is = PLANE;
   else if(hinge_edge)       this_is = HINGE_EDGE;
   else if(hinge_curve_geom) this_is = HINGE_CURVE;

   /*
    * Get the surface geometry
    */
   surf = &adj_sf_info->myself;
   EFget_surf_geom(&msg_loc, md_env, surf->objid,
                   surf->osnum, &draft_surf_geom);
   EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

   /*
    * Get the surface range
    */
   stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
				    &md_env->md_env.matrix_type,
				    md_env->md_env.matrix,
				    &world,
				    draft_surf_range),
		senderid = NULL_OBJID,
		targetid = surf->objid,
		targetos = surf->osnum);
   EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

   /*
    * Get the uv range of the draft surface
    */

   stat_OM = om$send(msg = message EMSsubbs.EMgetuvrange(&msg_loc,
                           tem_part_range),
                senderid = NULL_OBJID,
                targetid = surf->objid,
                targetos = surf->osnum);
   EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
 

   /*
    * Get the surface class
    */
   stat_OM = om$get_classid(objid = surf->objid,
		            osnum = surf->osnum,
                            p_classid = &class_id);
   EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

   /*
    * Get the hindge curve 
    */
   switch( this_is)
   {
      case PLANE:
      {
        do_not_extend=FALSE;
        hinge_curve_geom=NULL;
        int_grid.objid = surf->objid;
        surf_to_draft = NULL_OBJID;

        /*
         * New function that gets the hinge curve
        EFget_hindge_curve_new(&msg_loc, md_env,  plane, surf, &surf_to_draft,
                               const_list, &int_grid,&is_red_neck);
        ********/
        EFget_intersection(&msg_loc, md_env,plane, surf,&surf_to_draft,
                            NULL, const_list, do_not_extend, &int_grid,
                            &is_red_neck);
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);
       
        EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

        {
          stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &buf_size),
                        senderid = NULL_OBJID,
                        targetid = int_grid.objid,
                        targetos = surf->osnum);
          EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

          hinge_curve_geom = (struct IGRbsp_curve *) om$malloc(size= buf_size);
          EMerr_hndlr (!hinge_curve_geom, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

          stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                           (IGRchar *) hinge_curve_geom),
                        senderid = NULL_OBJID,
                        targetid = int_grid.objid,
                        targetos = surf->osnum);
          EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

          stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                    md_env),
                        senderid = NULL_OBJID,
                        targetid = int_grid.objid,
                        targetos = surf->osnum);
          EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
        }

        if(surf_to_draft != NULL_OBJID)
        {
          stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                    md_env),
                        senderid = NULL_OBJID,
                        targetid = surf_to_draft,
                        targetos = surf->osnum);
          EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
        }

      }
      break;

      case HINGE_CURVE:
      {
       break;
      }
      case HINGE_EDGE:
      {
        hinge_curve_geom = (struct IGRbsp_curve *)
                          om$malloc(size=sizeof(struct IGRbsp_curve));
        hinge_curve_geom->poles = NULL;
        hinge_curve_geom->knots = NULL;
        hinge_curve_geom->weights = NULL;
        stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
                                        &md_env->md_env,
                                        surf,
                                        draft_surf_geom,
                                        0, MAXINT, FALSE, NULL,
                                        hinge_curve_geom),
                        senderid = NULL_OBJID,
                        targetid = *hinge_edge,
                        targetos = surf->osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

       if(!draft_surf_geom->planar)
       {
         //hinge_curve_geom = NULL;
         EFextend_edge_curve( &msg_loc, &hinge_curve_geom);
       }

     }
     break;

   } /* end switch */

 /*
  * Replaced old code with a new one in deciding whether the drafting
  * for single/double draft.
  */ 

 { 
    struct IGRbsp_surface *hinge_plane_geom = NULL;
    IGRdouble slrange[6];
    struct  GRid active_solid;
   
    //get the base solid id
    stat_OM = om$send(msg = message EMSsurface.EMgetactiveid(&msg_loc,
                            &active_solid, NULL),
               senderid = NULL_OBJID,
               targetid = adj_sf_info->myself.objid,
               targetos = adj_sf_info->myself.osnum);
    EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 

    //get the solid range
    stat_OM = om$send(msg = message GRgraphics.GRgetrang(&msg_loc,
                            &md_env->md_env.matrix_type,
                            md_env->md_env.matrix, &world,slrange),
               senderid = NULL_OBJID,
               targetid = active_solid.objid,
               targetos = active_solid.osnum );
    EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    stat_OM = D_get_hingegeom(&msg_loc,md_env,adj_sf_info,plane,
                              slrange,&hinge_plane_geom); 
    EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup); 

    stat_OM = D_SinDou_Draft(&msg_loc,md_env,adj_sf_info,&hinge_plane_geom,
                             &draft_type);
    EMerr_hndlr(!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

    if(hinge_plane_geom){om$dealloc(ptr=hinge_plane_geom); 
                         hinge_plane_geom=NULL;}

 }

    /*
     * Process for non planar draft surface
     */
    if( ! draft_surf_geom->planar)
    {

     /*
      * Get the direction point, a point in the range box of the 
      * partial surface
      */
     {
     IGRdouble mid_u,mid_v;

     mid_u = (tem_part_range[0]+tem_part_range[2])/2;
     mid_v = (tem_part_range[1]+tem_part_range[3])/2;
     BSsfeval(draft_surf_geom,mid_u,mid_v,0,&dir_pt[0],&rc );
     }

     /*
      * Get the hindge curve tangent
      */
     par=0.555555;
     BScveval( hinge_curve_geom, par, 1, (IGRpoint *)point, &rc);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     sign =  1.0;
     for(ii=0;ii<3;ii++)
          hinge_curve_tan[ii]  = sign * point[3+ii] ;
     BSnorvec(&rc, hinge_curve_tan);

     /*
      * get the draft vector (normal to the curve plane)
      */
     BScvnormal(&rc, hinge_curve_geom, draft_vec);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, draft_vec);

     //BScrossp(&rc, nrml, hinge_curve_tan, temp_vec);

     for(ii=0;ii<3;ii++)
         temp_vec[ii] = dir_pt[ii] -  point[ii];
     BSnorvec(&rc, temp_vec);

     if(BSdotp(&rc, temp_vec, draft_vec) < 0.0 )
       for(kk=0;kk<3;kk++)
           draft_vec[kk] = -1.0 * draft_vec[kk];
        

     BSmdistptsf(&rc, draft_surf_geom, &point[0], &u_par[0], &v_par[0],
               &point[3], &dist);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     BSsfarrevt(draft_surf_geom, 1, u_par, 1, v_par, 1.0, points[0], &rc);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     /*
      * Assign memory for the iso curve
      */
     if( draft_surf_geom->u_order == 2)
     {
          for(jj=0;jj<3;jj++)
            draft_surf_tan[jj] = points[1][jj]- points[0][jj];
          opt =1;
          par = u_par[0];
          draft_srf_iso_crv.poles = (IGRdouble *)
              alloca(draft_surf_geom->v_num_poles *3 * sizeof(IGRdouble));
          EMerr_hndlr (! draft_srf_iso_crv.poles,
                           *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          draft_srf_iso_crv.knots = (IGRdouble *)
              alloca(draft_surf_geom->v_num_knots *3 * sizeof(IGRdouble));
          EMerr_hndlr (! draft_srf_iso_crv.knots,
                           *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          draft_srf_iso_crv.weights = (IGRdouble *)
              alloca(draft_surf_geom->v_num_poles  * sizeof(IGRdouble));
          EMerr_hndlr (! draft_srf_iso_crv.weights,
                           *EMmsg, EMS_E_NoDynamicMemory,wrapup);
      }
      else if( draft_surf_geom->v_order == 2)
      {
          for(jj=0;jj<3;jj++)
            draft_surf_tan[jj] = points[2][jj] - points[0][jj];
          opt = 2;
          par=v_par[0];
          draft_srf_iso_crv.poles = (IGRdouble *)
              alloca(draft_surf_geom->u_num_poles *3 * sizeof(IGRdouble));
          EMerr_hndlr (! draft_srf_iso_crv.poles,
                           *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          draft_srf_iso_crv.knots = (IGRdouble *)
              alloca(draft_surf_geom->u_num_knots *3 * sizeof(IGRdouble));
          EMerr_hndlr (! draft_srf_iso_crv.knots,
                           *EMmsg, EMS_E_NoDynamicMemory,wrapup);
          draft_srf_iso_crv.weights = (IGRdouble *)
              alloca(draft_surf_geom->u_num_poles  * sizeof(IGRdouble));
          EMerr_hndlr (! draft_srf_iso_crv.weights,
                           *EMmsg, EMS_E_NoDynamicMemory,wrapup);
      }
      else 
          EMerr_hndlr( NULL, *EMmsg, EMS_E_Fail, wrapup);
 
      /*
       * get the draft_surf_normal in the order two direction normal
       */
      BSnorvec(&rc, draft_surf_tan);
      if( BSdotp(&rc, draft_surf_tan , draft_vec) <=0.0)
       for(kk=0;kk<3;kk++)
          draft_surf_tan[kk] *= -1.0;
  
      /*
       * get the iso_curve normal 
       */
      tst_plan = FALSE;
      BSconstprcv(&rc, draft_surf_geom, &opt, &par, &tst_plan,
                                            &draft_srf_iso_crv);
      EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      BScvnormal(&rc, &draft_srf_iso_crv, iso_crv_nrml);
      EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      if( BSdotp(&rc, iso_crv_nrml , draft_vec) <=0.0)
       for(kk=0;kk<3;kk++)
         iso_crv_nrml[kk] *= -1.0;

      /*
       * get the existing angle of the surface 
       */
      dotp = BSdotp(&rc, iso_crv_nrml, draft_surf_tan);
      exist_sf_angle =  fabs(acos( dotp));


      BScrossp(&rc, hinge_curve_tan, draft_surf_tan, temp_vec);
      if( BSdotp(&rc, temp_vec , draft_vec) <=0.0)
      {
          draft_angle += exist_sf_angle;
          will_self_intersect = FALSE;
      }
      else
      {
          will_self_intersect = TRUE;
          draft_angle -= exist_sf_angle;
      }
    }
    else
    {
        /**** planar surface : DO NOTHING *******/
    }

    /*
     * Get the draft surface height                  
     */ 
    {
      IGRint tt2;
      IGRdouble uvpar[4],pp[12],dis[4];
      IGRint num_dis = 0;
      BSrc rc;
      IGRdouble new_dist;
      IGRlong msg,stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
      IGRint umin=0,umax=2,vmin=1,vmax=3;

      BSsfeval(draft_surf_geom,tem_part_range[umin],tem_part_range[vmin],
               0, &pp[0], &rc);
      BSsfeval(draft_surf_geom,tem_part_range[umin],tem_part_range[vmax],
               0, &pp[3], &rc);
      BSsfeval(draft_surf_geom,tem_part_range[umax],tem_part_range[vmin],
               0, &pp[6], &rc);
      BSsfeval(draft_surf_geom,tem_part_range[umax],tem_part_range[vmax],
               0, &pp[9], &rc);
	
      /*
       * Considering the exact surface (partial surface) get the 
       * iso edge distances in xyz space
       */
      if(draft_surf_geom->u_order == 2)
      {
        dis[num_dis++] = fabs(BSdistptpt(&rc,&pp[0],&pp[6]));
        dis[num_dis++] = fabs(BSdistptpt(&rc,&pp[3],&pp[9]));
      }
      if(draft_surf_geom->v_order == 2)
      {
        dis[num_dis++] = fabs(BSdistptpt(&rc,&pp[0],&pp[3]));
        dis[num_dis++] = fabs(BSdistptpt(&rc,&pp[6],&pp[9]));
      }

      /*
       * Get the maximum of all the computed distance, which will be
       * the reference distance for the draft height
       */
      
      new_dist = fabs(dis[0]);
      for(tt2=1;tt2<num_dis;++tt2)
      {
        if(fabs(dis[tt2]) >new_dist) new_dist=fabs(dis[tt2]); 
      }

      /*
       * Let us have the draft height to be 20% larger, to be in the 
       * safer side
       */
      max_dist = fabs(new_dist/cos(draft_angle)) * 1.2; 

      /*
       * For planar surface, let the max_dist referes to the extension
       * value
       */
      if(draft_surf_geom->planar ) max_dist = max_dist - new_dist;

     }

     /*
      * Get the limiting draft height, considering the minimum radius of
      * curvature of the hinge curve.
      */
     if(!draft_surf_geom->planar)
     {
      IGRdouble radius=0.0, t, l_curvature=0.0, r_curvature, l_radius, 
                r_radius, allow_len;
      IGRint num_points, ii;
      IGRpoint l_center, r_center;
      IGRdouble center[3], tem_point[6];
      IGRdouble tem_u;
      IGRboolean  boundary;
      IGRdouble vec1[3],vec2[3],vec3[3],vec4[3];
      IGRint kkk;
      BSrc  rc;

      /*
       * Get the minimum radius of curvature and the corresponding
       * parameter value and center point
       */
      num_points = 10;
      if(hinge_curve_geom->rational)
        num_points = 1;

      t=0.0;
      for(ii=0; ii<num_points; ii++)
      {
         BSrdcencrcv(&rc, hinge_curve_geom, &t, &boundary, &l_curvature,
          &r_curvature, &l_radius, &r_radius, l_center, r_center);

         if(l_radius < r_radius)
         {
             radius = l_radius;
             for(kkk = 0; kkk<3; ++kkk) center[kkk] = l_center[kkk];
             tem_u  = t;
          }
         else 
         {
             radius = r_radius;
             for(kkk = 0; kkk<3; ++kkk) center[kkk] = r_center[kkk];
             tem_u  = t;
          }
         t += 0.10;
      }

      /*
       * Get the vector between the point and the center [vec1]
       * Get the vector which is cross product of tangent vector
       * and the normal vector at that point [vec4]
       */
      BScveval(hinge_curve_geom, tem_u, 0,(IGRpoint *)tem_point,&rc);
      BSmkvec (&rc, vec1, tem_point, center); 
      BSnorvec(&rc, vec1);

      BScveval(hinge_curve_geom, tem_u, 1, (IGRpoint *)tem_point, &rc);
      for(ii=0;ii<3;++ii) vec2[ii] = tem_point[ii + 3];
      BSnorvec(&rc, vec2);

      for(ii=0;ii<3;++ii) vec3[ii] = draft_vec[ii];
      BSnorvec(&rc, vec3);

      if(draft_angle < 0.0)
      for(ii=0;ii<3;++ii) vec3[ii] *= -1;

      BScrossp(&rc, vec2,vec3,vec4);
      BSnorvec(&rc, vec4);

      /* If the vectors vec1 and vec4 are in the same direction
       * or drafting in both the directions then we have to consider
       * the allowable distance into consideration. 
       * else not required.
       */
      if(BSdotp(&rc, vec1,vec4) >= 0.0 || draft_type == DOUBLE_DRAFT)
      {
        allow_len = fabs(radius/tan(draft_angle));
        if(max_dist  > allow_len) max_dist = allow_len/1.05;
      }
     }

     /*
      * Construct a vector of exact size
      */
     for(ii=0;ii<3;ii++)
     {
          draft_vec[ii] = draft_vec[ii]* max_dist;
          draft_vec[3+ii] = -1.0 * draft_vec[ii];
     }

     if(draft_surf_geom->planar)
     {
          IGRpoint plane_pt1, plane_pt2, plane_pt3;
          IGRdouble point_1[3],point_2[3],point_3[3];
          IGRvector vec_1, vec_2;

          BSsfeval(draft_surf_geom, tem_part_range[0],tem_part_range[1],
                   0,point_1, &rc); 
          BSsfeval(draft_surf_geom, tem_part_range[2],tem_part_range[1],
                   0,point_2, &rc);
          BSsfeval(draft_surf_geom, tem_part_range[0],tem_part_range[3],
                   0,point_3, &rc);
         
          for(ii = 0; ii<3; ii++)
          {
             vec_1[ii] = point_2[ii] - point_1[ii];
             vec_2[ii] = point_3[ii] - point_1[ii];
          }
          BSnorvec(&rc, vec_1);
          BSnorvec(&rc, vec_2);

          dist = max_dist;

          for(ii = 0; ii<3; ii++)
          {
            plane_pt1[ii] = point_1[ii] - dist * vec_1[ii] - dist * vec_2[ii];
            plane_pt2[ii] = point_2[ii] + dist * vec_1[ii] - dist * vec_2[ii];
            plane_pt3[ii] = point_3[ii] - dist * vec_1[ii] + dist * vec_2[ii];
          }
          BSplane3pt(&rc, plane_pt1, plane_pt2, plane_pt3, draft_surf_geom);
          EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     }

     draft_ang = draft_angle;

     /* 
      * create drafted surface 
      */
     EMcreate_draft_sf_geom(&msg_loc,
                         md_env,
                         surf, /*surf to be drafted */
                         draft_surf_geom,
                         class_id,
                         hinge_curve_geom,
                         &draft_type,
                         &draft_ang,
                         draft_vec,
                         draft_surf_grid,
                         const_list, is_red_neck);
     EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);


     /*** ORIENT THE DRAFTED SURFACE APPROPRIATELY ***/

     EFget_surf_geom(&msg_loc, md_env,
           draft_surf_grid->objid, draft_surf_grid->osnum, &drafted_surf_geom);
     EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

     EFget_surf_geom(&msg_loc, md_env,
           surf->objid, draft_surf_grid->osnum, &draft_surf_geom);
     EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

     u_p = v_p = 0.5;
     BSsfarrevn(&rc, drafted_surf_geom, 1, &u_p, 1, &v_p, 
          (IGRdouble *)pnts, (IGRdouble *)nrml);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, nrml[0][0]);

     BSmdistptsf(&rc, draft_surf_geom, pnts[0][0], &u_p, &v_p,
               &point[3], &dist);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     BSsfarrevn(&rc, draft_surf_geom, 1, &u_p, 1, &v_p,
                (IGRdouble *)pnts, (IGRdouble *)nrml1);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, nrml1[0][0]);

     dotp = BSdotp(&rc, nrml[0][0], nrml1[0][0]);

     if(( (dotp > 0.0) &&
          (drafted_surf_geom->pos_orient != draft_surf_geom->pos_orient) )
                            || 
          ( (dotp < 0.0) &&
            (drafted_surf_geom->pos_orient == draft_surf_geom->pos_orient))  )
     {
         stat_OM = om$send (msg = message EMSsurface.EMrevorient(EMmsg),
                        senderid = NULL_OBJID,
                   targetid = draft_surf_grid->objid,
                   targetos = OM_Gw_current_OS);
         EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
     }


     wrapup:
        if(edges)
         om$dealloc (ptr = edges);
        if(range_point_arr)
         om$dealloc (ptr = range_point_arr);
        if( adj_surf_list)
         om$dealloc (ptr = adj_surf_list);
        if( draft_surf_geom)
         om$dealloc (ptr = draft_surf_geom);

        if(this_is != HINGE_EDGE)
          if(hinge_curve_geom)
            om$dealloc (ptr = hinge_curve_geom);

        EMWRAPUP( *EMmsg, stat_OM, "EMcreate_draft_surf");
        return (stat_OM);
}



        EMcreate_draft_sf_geom(EMmsg,
                               md_env,
                               surf,     //surf to be drafted 
                               surf_to_draft_geom,
                               class_id,
                               hinge_curve_geom,
                               draft_type,
                               draft_angle,
                               draft_vec,
                               draft_surf_grid,
                               const_list,
                               is_red_neck)
IGRlong *EMmsg;
struct GRmd_env *md_env; 
struct GRid  *surf, *draft_surf_grid;
struct IGRbsp_curve *hinge_curve_geom; 
struct IGRbsp_surface *surf_to_draft_geom;
struct GRvg_construct  *const_list;
IGRdouble *draft_angle;
IGRdouble *draft_vec;
IGRint *draft_type;
GRclassid class_id;
IGRboolean is_red_neck;
{
   IGRlong  msg_loc=EMS_S_Success, stat_OM=OM_S_SUCCESS;
   IGRdouble ang_dis[1];
   IGRint     table[4], res_num_crvs = 0;
   IGRint     ii, off_code;
   void  EFdrafted_pl_geom ();

   IGRboolean right_side, fillet, is_uniform, phy_closed;

   IGRuchar curve_type=0;

   /* Allocating proper memory space for res_crvs_e & res_crvs . Hari */
   struct IGRbsp_curve *crvs[1], *res_crvs_e[3],  *res_crvs[3],  *old_crv;

   struct IGRbsp_surface *drafted_surf_geom;
   void   EFdraftcv();

   if(surf_to_draft_geom && surf_to_draft_geom->planar)
   {
          EFdrafted_pl_geom( &msg_loc,
                             surf_to_draft_geom,
                             hinge_curve_geom,
                             FALSE, 
                             draft_vec,
                             *draft_angle,
                             &drafted_surf_geom);
          EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

          const_list->geometry = (IGRchar *)drafted_surf_geom;

          stat_OM = om$construct(osnum = surf->osnum,
                                 p_objid = &draft_surf_grid->objid,
                                 classid = OPP_EMSplane_class_id,
                      msg = message GRgraphics.GRconstruct(const_list));

          if(!(1&msg_loc&stat_OM)) goto wrapup;
  } 
  else 
  {
         fillet = phy_closed= FALSE;
         phy_closed= hinge_curve_geom->phy_closed;
         ang_dis[0] = *draft_angle ;
         off_code = BSCONSTOFF;

         crvs[0] = hinge_curve_geom;
         right_side = is_uniform = TRUE; 

         /*right_side  = FALSE; */

         EFdraftcv(&msg_loc,
             1,
             crvs,
             right_side, 
             &draft_vec[0],
             is_uniform,
             ang_dis,
             &off_code,
             phy_closed,
             fillet,
             &res_num_crvs,
             res_crvs,
             table);
         if (msg_loc == EMS_I_InvalidArg || msg_loc == EMS_I_BSerror ||
                     msg_loc == EMS_E_BSerror)
         EMerr_hndlr (1, *EMmsg, EMS_E_SurfaceError,wrapup);

         old_crv = hinge_curve_geom;

         if(!(*draft_type == DOUBLE_DRAFT))
           for(ii=0;ii<3;ii++)
             draft_vec[3+ii] = -1.0 * draft_vec[ii]/10.0;

         if((*draft_type == DOUBLE_DRAFT) || 1 )
         {
           ang_dis[0] = *draft_angle ;
           EFdraftcv(&msg_loc,
             1,
             crvs,
             right_side, 
             &draft_vec[3],
             is_uniform,
             ang_dis,
             &off_code,
             phy_closed,
             fillet,
             &res_num_crvs,
             res_crvs_e,
             table);

           if (msg_loc == EMS_I_InvalidArg || msg_loc == EMS_I_BSerror ||
                     msg_loc == EMS_E_BSerror)
           EMerr_hndlr (1, *EMmsg, EMS_E_SurfaceError,wrapup);

           old_crv = res_crvs_e[0];
         }
         msg_loc=EMS_S_Success;

         /* * Construct drafted surfaces and attach it to me * */

         stat_OM = om$construct (classid = OPP_EMSgenbs_class_id,
                       osnum = surf->osnum,
                       p_objid = &draft_surf_grid->objid);
                        
         stat_OM = om$send(msg = message EMSsubbs.EMdrafted_surface (
                           &msg_loc,
                           old_crv,
                           NULL,
                           res_crvs[0], 
                           draft_vec,
                           *draft_angle,
                           right_side,
                           fillet,
                           curve_type,
                           FALSE,
                           &draft_surf_grid->objid,
                           const_list),
                     senderid = NULL_OBJID,
                     targetid = draft_surf_grid->objid,
                     targetos = surf->osnum);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_SurfaceError,wrapup);
  }
  draft_surf_grid->osnum = surf->osnum;

  om$get_classid (objid = surf->objid, osnum = surf->osnum,
                  p_classid = &class_id);

 /**********  change class of the surface if special **************/
 if(!is_red_neck)
    if(class_id ==OPP_EMScylindr_class_id ||
       class_id == OPP_EMSpcylindr_class_id ||
       class_id ==OPP_EMAcylindr_class_id ||
       class_id == OPP_EMApcylindr_class_id )
   {
       struct IGRbsp_surface *drafted_surf_geom;

       EFget_surf_geom(&msg_loc, md_env, 
           draft_surf_grid->objid, draft_surf_grid->osnum, &drafted_surf_geom);
       EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

       stat_OM = om$send( msg = message GRgraphics.GRdelete (&msg_loc,
                         md_env),
                      senderid = NULL_OBJID,
                      targetid = draft_surf_grid->objid,
                      targetos = draft_surf_grid->osnum);
       EMerr_hndlr(!(1&stat_OM&msg_loc),*EMmsg,EMS_E_SurfaceError,wrapup);

       draft_surf_grid->objid = NULL_OBJID;
       const_list->geometry = (IGRchar *)drafted_surf_geom;

       if(class_id == OPP_EMScylindr_class_id)
          class_id = OPP_EMScone_class_id;
       else if(class_id == OPP_EMSpcylindr_class_id)
          class_id = OPP_EMSpcone_class_id;
       else if(class_id == OPP_EMAcylindr_class_id)
          class_id = OPP_EMAcone_class_id;
       else if(class_id == OPP_EMApcylindr_class_id)
          class_id = OPP_EMApcone_class_id;

       stat_OM = om$construct(osnum = draft_surf_grid->osnum,
         p_objid = &draft_surf_grid->objid,
            classid = class_id,
              msg = message GRgraphics.GRconstruct(const_list));
       if(!(1&msg_loc&stat_OM)) goto wrapup;
   }
      
   draft_surf_grid->osnum = surf->osnum;

   wrapup:
      EMWRAPUP( *EMmsg, stat_OM, "EMcreate_draft_sf_geom");
      return (stat_OM);
}



void  EFextend_edge_curve( IGRlong             *EMmsg,
                           struct IGRbsp_curve **curve)
{
    BSrc rc=BSSUCC;
    IGRdouble u_par, dist;
    IGRpoint beg_pt_xyz[1], end_pt_xyz[1];
    struct IGRbsp_curve *curve_geom;
    struct IGRbsp_curve ext_curve;
    struct IGRbsp_curve *ext_curve_1=NULL;
    IGRlong  stat_OM=OM_S_SUCCESS;
    void BScveval();

    curve_geom = *curve;

    u_par = 0.0;
    BScveval(curve_geom, u_par, 0, beg_pt_xyz, &rc);
    EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    u_par = 1.0;
    BScveval(curve_geom, u_par, 0, end_pt_xyz, &rc);
    EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    dist = BSdistptpt(&rc, (IGRdouble *)beg_pt_xyz, (IGRdouble *)end_pt_xyz);
    dist /= 5.;

    ext_curve.poles = NULL;
    ext_curve.knots = NULL;
    ext_curve.poles = (IGRdouble *)alloca((curve_geom->num_poles +
             3 *(2 * curve_geom->order -1)) * 3 * sizeof(IGRdouble));
    EMerr_hndlr (!ext_curve.poles, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
		  
    ext_curve.knots = (IGRdouble *)alloca ((curve_geom->num_poles +
             3 *(2 * curve_geom->order -1)) * 6 * sizeof(IGRdouble));
    EMerr_hndlr (!ext_curve.knots, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

    ext_curve.weights = (IGRdouble *)alloca ((curve_geom->num_poles +
             3 *(2 * curve_geom->order -1)) * 3 * sizeof(IGRdouble));
    EMerr_hndlr (!ext_curve.weights, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

    BSpolyxtdst(curve_geom, (IGRdouble *)beg_pt_xyz, dist, &ext_curve, &rc);
    EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    ext_curve_1 = (struct IGRbsp_curve *)om$malloc(size=sizeof
                       (struct IGRbsp_curve) );
    ext_curve_1->poles = NULL;
    ext_curve_1->knots = NULL;
    ext_curve_1->poles = (IGRdouble *) om$malloc(size = (ext_curve.num_poles +
            3 *(2 * ext_curve.order -1)) * 3 * sizeof(IGRdouble));
    EMerr_hndlr (!ext_curve_1->poles, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

    ext_curve_1->weights = (IGRdouble *) om$malloc( size = (ext_curve.num_poles
        + 3 *(2 * ext_curve.order -1)) * 3 * sizeof(IGRdouble));
    EMerr_hndlr (!ext_curve_1->weights, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

    ext_curve_1->knots = (IGRdouble *) om$malloc(size= (ext_curve.num_poles + 3
          *(2 * ext_curve.order -1)) * 6 * sizeof(IGRdouble));
    EMerr_hndlr (!ext_curve_1->knots, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

    BSpolyxtdst(&ext_curve,(IGRdouble *)end_pt_xyz, dist,ext_curve_1, &rc);
    EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    if(curve_geom)om$dealloc(ptr=curve_geom);
    curve_geom= ext_curve_1;
    *curve = ext_curve_1;

  wrapup:
        EMWRAPUP( *EMmsg, stat_OM, "EFextend_curve");
        return;
}

         
        EFget_big_man(EMmsg,
                      md_env,
                      org_srf,
                      rep_srf,
                      big_rep_srf,
                      const_list,
                      equal_angle)
    IGRlong *EMmsg;
    struct GRmd_env *md_env;
    GRobjid *org_srf;
    struct GRvg_construct *const_list;
    struct GRid *rep_srf;
    GRobjid *big_rep_srf;
    IGRdouble *equal_angle;
{
   IGRlong stat_OM= OM_S_SUCCESS, msg_loc = EMS_S_Success;
   IGRlong buf_size;
   struct IGRbsp_surface *rep_geom = NULL, *org_geom = NULL ;
   IGRint  jj, ii, jjj;
   IGRdouble org_range[6], rep_range[6], ext_dist;
   IGRboolean world, in_range;
   IGRpoint   mid_pt1, mid_pt2;
   IGRdouble dist, u_par[1], v_par[1], opp_side;
   IGRvector nrml1[1][1], nrml[1][1];
   IGRpoint pnts[1][1];
   IGRdouble org_srf_size, rep_srf_size, magnification, dotp;
   OMuword class_id;
   IGRboolean org_srf_pos_orient;
   IGRpoint plane_pt1, plane_pt0, plane_pt2;
   IGRdouble matrix[15];
   struct BSgeom_bsp_surf gmsf, xgmsf;
   IGRdouble dist_out, ex_dist, xx_dist, x_dist;

   IGRdouble factor = 1.0;
   IGRint num_iter = 0;

   IGRint option;
   extern  void  BSxgmsfdst();
   BSrc rc = BSSUCC;
   IGRshort sf_type;
   extern void getsftype();
   extern void EFget_surf_extent();
   extern void BSchkfxsf ();

START:

    ++num_iter;
    getsftype(rep_srf->objid, rep_srf->osnum, &sf_type);

    gmsf.bspsf=NULL;
    xgmsf.bspsf=NULL;
    if(org_geom) { om$dealloc(ptr= org_geom); org_geom = NULL;}
    if(rep_geom) { om$dealloc(ptr= rep_geom); rep_geom = NULL;}

    EFget_surf_geom(&msg_loc, md_env, *org_srf, rep_srf->osnum, &org_geom);
    EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

    stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &world,
                                    org_range),
                        senderid = NULL_OBJID,
                        targetid = *org_srf,
                        targetos = rep_srf->osnum);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

    u_par[0] = v_par[0] = 0.5;
    BSsfarrevn(&rc, org_geom, 1, u_par, 1, v_par, (IGRdouble *)pnts,
           (IGRdouble *)nrml); 
    EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    BSnorvec(&rc, nrml[0][0]);
    org_srf_pos_orient = org_geom->pos_orient;

    if(EFisAncestryValid(&msg_loc,
          rep_srf->objid, rep_srf->osnum, OPP_EMSdatpln_class_id, FALSE))
    {
       buf_size=0;
       stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &buf_size),
                        senderid = NULL_OBJID,
                        targetid = *org_srf,
                        targetos = rep_srf->osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

       rep_geom = (struct IGRbsp_surface *) om$malloc(size= buf_size);
       EMerr_hndlr (!rep_geom, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

       stat_OM = om$send (msg = message EMSdatpln.EMget_pln_info(
                      &msg_loc, NULL, md_env,
                      &matrix[0], &matrix[4], &matrix[8], &matrix[12], NULL),
                      senderid = NULL_OBJID,
                      targetid = rep_srf->objid,
                      targetos = rep_srf->osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

       ext_dist = BSdistptpt(&rc, &org_range[0], &org_range[3]);
       in_range = TRUE;
       for(ii = 0; ii<3; ii++)
       {
           plane_pt1[ii] = matrix[ii+12]+
                    10.0  * (matrix[ii]*ext_dist -  matrix[ii+4]*ext_dist);
           plane_pt2[ii] = matrix[ii+12]+
                    10.0 * (matrix[ii+4]*ext_dist - matrix[ii]*ext_dist);
           plane_pt0[ii] = matrix[ii+12]-
                    10.0 * (matrix[ii+4]*ext_dist + matrix[ii]*ext_dist);
       }
       BSplane3pt(&rc, plane_pt0, plane_pt1, plane_pt2, rep_geom);
       EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       class_id = OPP_EMSplane_class_id;
       u_par[0] = v_par[0] = 0.5;
       BSsfarrevn(&rc, rep_geom, 1, u_par, 1, v_par, 
                  (IGRdouble *)pnts, (IGRdouble *)nrml1); 
       EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       BSnorvec(&rc, nrml1[0][0]);
       *equal_angle = .75;
    }
    else
    {

       EFget_surf_geom(&msg_loc, md_env, rep_srf->objid,
                                              rep_srf->osnum, &rep_geom);
       EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);


       stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                    &md_env->md_env.matrix_type,
                                    md_env->md_env.matrix,
                                    &world,
                                    rep_range),
                        senderid = NULL_OBJID,
                        targetid = rep_srf->objid,
                        targetos = rep_srf->osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

       org_srf_size = BSdistptpt(&rc, &org_range[0], &org_range[3]);
       rep_srf_size = BSdistptpt(&rc, &rep_range[0], &rep_range[3]);
       for(ii=0; ii<3; ii++)
       {
          mid_pt1[ii] = org_range[3+ii] -  org_range[ii];
          mid_pt2[ii] = rep_range[3+ii] -  rep_range[ii];
       }
       opp_side = 2 *BSdistptpt(&rc, mid_pt1, mid_pt2);
       *equal_angle = atan(opp_side/org_srf_size);
       
      magnification = org_srf_size /  rep_srf_size;
      if(magnification < 1.0) magnification = 1.0;
      dist = rep_srf_size *  magnification / 2.0;

      if(rep_geom->planar != 1)
      {
       gmsf.bspsf = rep_geom ;
       gmsf.sfgen_cv=NULL;
       xgmsf.bspsf = rep_geom;
       xgmsf.sfgen_cv=NULL;

       gmsf.geom_prop=FALSE;
       gmsf.type=99;
       gmsf.vrange[0]=0.;
       gmsf.vrange[1]=1.;
       gmsf.urange[0]=0.;
       gmsf.urange[1]=1.;
       gmsf.bounded= TRUE;

       xgmsf.geom_prop=FALSE;
       xgmsf.type=99;
       xgmsf.vrange[0]=0.;
       xgmsf.vrange[1]=1.;
       xgmsf.urange[0]=0.;
       xgmsf.urange[1]=1.;
       xgmsf.bounded= TRUE;

       class_id = OPP_EMSgenbs_class_id;
       om$get_classid (objid = rep_srf->objid ,
              osnum = rep_srf->osnum, p_classid = &class_id);

       for(jj=0;jj<2;jj++)
       {
         if(class_id  == OPP_EMAsphere_class_id ||
            class_id  == OPP_EMSsphere_class_id)
           continue;

         if(jj == 0 && rep_geom->v_phy_closed)
            continue;
         else if (jj == 1 && rep_geom->u_phy_closed)
            continue;

         ext_dist = dist;
         if(jj == 0 && rep_geom->v_order ==2 ) 
             ext_dist*=2.0;
         else if (jj == 1 && rep_geom->u_order == 2)
             ext_dist*=2.0;
         else if (jj == 1 && rep_geom->u_order > 2)
             ext_dist/=4.0;
         else if (jj == 0 && rep_geom->v_order > 2)
             ext_dist/=4.0;

        x_dist = ext_dist;
        xx_dist = ext_dist;

       if ((jj == 0 && rep_geom->v_order == 2) ||
           (jj == 1 && rep_geom->u_order == 2))
       {
          if(! (class_id  == OPP_EMAgenbs_class_id ||
                class_id  == OPP_EMSgenbs_class_id))
          {
              EFget_surf_extent(&msg_loc, rep_geom, &x_dist, &xx_dist,  NULL);
              if(x_dist > dist ||  x_dist < 0.0)
                x_dist = ext_dist;
              if(xx_dist > dist ||  xx_dist < 0.0)
                xx_dist = ext_dist;
           }
       }
       else if ((jj == 1 && rep_geom->v_order == 2) ||
                (jj == 0 && rep_geom->u_order == 2))
       {
          EFget_surf_extent(&msg_loc, rep_geom, NULL, NULL,  &x_dist);
          x_dist *=  0.45;
          if(x_dist > ext_dist ||  x_dist < 0.0)
             x_dist = ext_dist;
             xx_dist = x_dist;
       }
       else
       {
            x_dist = ext_dist/5.0;

            /* If the extension distance calculated as per the
               algorithm is less the difference in length either
               in u or v between the original surface and replace        
               surface, then replace the extension distance with
               1.2 * (difference in length) . Where the magic no.
               1.2 is just a multiplication factor to have a 
               distance more than the difference in length .Hari
             */

            if(x_dist < opp_side ) x_dist = opp_side *1.2;

            xx_dist = x_dist;
       }

       x_dist *=factor;
       xx_dist *=factor;

       for(jjj=0;jjj<2; jjj++)
       {
       ex_dist = (jjj==0 ? x_dist : xx_dist);
       option=1;
       if(jj==0)
       {
         gmsf.type=sf_type;
         if(ex_dist > 0.0)
         BSxgmsfdst (&gmsf, ex_dist, option, FALSE, FALSE,
             (jjj==0 ? TRUE : FALSE), (jjj==0? FALSE :TRUE),
                   &xgmsf, &dist_out, &rc);
       }
       else if(jj==1)
       {
         gmsf.type=sf_type;
         if(ex_dist > 0.0)
         BSxgmsfdst (&gmsf, ex_dist, option,
                (jjj==0? TRUE : FALSE), (jjj==0? FALSE :TRUE),
                 FALSE, FALSE, &xgmsf, &dist_out, &rc);
       }
       if( rc != BSSUCC)
       {
            gmsf.bspsf = gmsf.bspsf;
            xgmsf.bspsf = gmsf.bspsf;
       }
       else
       {
            gmsf.bspsf = xgmsf.bspsf;
       }
       }
     }

     rep_geom = xgmsf.bspsf;
     if( gmsf.bspsf && (gmsf.bspsf != xgmsf.bspsf))
              {om$dealloc(ptr= gmsf.bspsf); gmsf.bspsf=NULL;}

     /* check for self-intersection of the extended surface
        if self-intersecting then reduce the extension value
        and start the above extension procedure. This prevents
        creating invalid-solid ....Hari
              
        The iteration (maximum 2 times) is only for surfaces 
        whose extensions results in self-intersection. This 
        sounds necessary as extact extension is not available.
        ...Hari

      */

     {
      IGRshort out_code = 0;
      BSrc rc;
      struct IGRbsp_surface *outsf = NULL;

      EFget_surf_geom(&msg_loc, md_env, rep_srf->objid,
                             rep_srf->osnum, &outsf);
      EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

      /* If the out_code value is 16 then self-intersection */

      BSchkfxsf (rep_geom,0,outsf, &out_code, &rc);
      EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       
      if(outsf) om$dealloc(ptr = outsf);

      /* 
       * If self-intersecting then proceed with less extension
       * value (the maximum no of iteration is 2)
       */
       
      if(out_code == 16) 
      {
          factor *= 0.7; 
          if(num_iter < 3) goto START;
          EMerr_hndlr( TRUE,  *EMmsg,EMS_E_SurfaceError, wrapup);
       }
      }

           

       u_par[0] = v_par[0] = 0.5;
       BSsfarrevn(&rc, rep_geom, 1, u_par, 1, v_par,
                   (IGRdouble *)pnts, (IGRdouble *)nrml1); 
       EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       BSnorvec(&rc, nrml1[0][0]);

       if(class_id == OPP_EMAgenbs_class_id)
              class_id = OPP_EMSgenbs_class_id;
       else if(class_id == OPP_EMAcone_class_id)
              class_id = OPP_EMScone_class_id;
       else if(class_id == OPP_EMApcone_class_id)
              class_id = OPP_EMSpcone_class_id;
       else if(class_id == OPP_EMAcylindr_class_id)
              class_id = OPP_EMScylindr_class_id;
       else if(class_id == OPP_EMApcylindr_class_id)
              class_id = OPP_EMSpcylindr_class_id;
       else if(class_id == OPP_EMApsphere_class_id)
              class_id = OPP_EMSpsphere_class_id;
       else if(class_id == OPP_EMAsphere_class_id)
              class_id = OPP_EMSsphere_class_id;
       else
              class_id = OPP_EMSgenbs_class_id;


      }
      else /*  planar surf to draft  **/
      {
	 in_range = TRUE;
	 dist = magnification * 5.0;
         u_par[0] = v_par[0] = 0.5;
         BSsfarrevn(&rc, rep_geom, 1, u_par, 1, v_par,
                     (IGRdouble *)pnts, (IGRdouble *)nrml1); 
         EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
         BSnorvec(&rc, nrml1[0][0]);

	 BSplptnorrg( &rep_range[0], &rep_range[3],
	      pnts[0][0], nrml1[0][0], dist, &in_range, rep_geom, &rc);
	 EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         u_par[0] = v_par[0] = 0.5;
         BSsfarrevn(&rc, rep_geom, 1, u_par, 1, v_par,
                     (IGRdouble *)pnts, (IGRdouble *)nrml1); 
         EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
         BSnorvec(&rc, nrml1[0][0]);

         class_id = OPP_EMSplane_class_id;
       }
     }
     dotp =  BSdotp(&rc, nrml1[0][0],  nrml[0][0]);

     if(dotp > 0.0)
            rep_geom->pos_orient = org_srf_pos_orient;
     else
            rep_geom->pos_orient = !org_srf_pos_orient;

     const_list->geometry = (IGRchar *)rep_geom;
     stat_OM = om$construct(osnum = rep_srf->osnum,
         p_objid = big_rep_srf, classid = class_id,
              msg = message GRgraphics.GRconstruct(const_list));
     if(!(1&msg_loc&stat_OM)) goto wrapup;

   wrapup:
      if( gmsf.bspsf) {om$dealloc(ptr= gmsf.bspsf); gmsf.bspsf=NULL;}
   return(stat_OM);
}


void  EFdrafted_pl_geom (EFmsg,
                         sf_geom,
                         hinge_curve_geom,
                         is_sf_sp_plane,
                         draft_vec,
                         draft_angle,
                         dsf_geom)

IGRlong *EFmsg;
struct IGRbsp_surface   *sf_geom;
struct IGRbsp_curve     *hinge_curve_geom;
IGRboolean  is_sf_sp_plane;
IGRvector  draft_vec;
IGRdouble     draft_angle;
struct IGRbsp_surface   **dsf_geom;
{
  IGRdouble     u, v, snrml_dot_dsnrml,sf_pt[3], sf_nrml[3], dsf_nrml[3],
                sc_tr_mat[4][4],*xform_mat=NULL, *temp_poles=NULL,
                *temp_u_knots=NULL,*temp_v_knots=NULL;

  IGRpoint      point, point1, point2;
  IGRdouble     u_par, v_par, dist;
  IGRdouble     vect[3];
  IGRlong       rc, numpts;
  IGRint        i, ii, low_left, low_right, up_left, up_right;
  IGRshort      xform_mattype;
  IGRboolean    status;

  *EFmsg = EMS_S_Success;
  rc = OM_S_SUCCESS;

  BSallocsf (2, 2, 2, 2, FALSE, 0, dsf_geom, &rc);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  low_left = 0;
  low_right = (sf_geom->u_num_poles - 1) * 3;
  up_left = (sf_geom->u_num_poles * (sf_geom->v_num_poles-1)) * 3;
  up_right = up_left + low_right;
   
  u = v = 0.5;
  BSsfarrevn (&rc, sf_geom, 1, &u, 1, &v, sf_pt, sf_nrml);
  EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);

  if (is_sf_sp_plane)
  {
    temp_poles = (*dsf_geom)->poles;
    temp_u_knots = (*dsf_geom)->u_knots;
    temp_v_knots = (*dsf_geom)->v_knots;

    *(*dsf_geom) = *sf_geom;
    (*dsf_geom)->poles = temp_poles;
    (*dsf_geom)->u_knots = temp_u_knots;
    (*dsf_geom)->v_knots = temp_v_knots;

    (*dsf_geom)->u_num_poles = (*dsf_geom)->v_num_poles = 2;
    (*dsf_geom)->u_num_knots = (*dsf_geom)->v_num_knots = 4;

    OM_BLOCK_MOVE (&sf_geom->poles[low_left], &(*dsf_geom)->poles[0],
                   sizeof(IGRpoint) );
    OM_BLOCK_MOVE (&sf_geom->poles[low_right], &(*dsf_geom)->poles[3],
                   sizeof(IGRpoint) );
    OM_BLOCK_MOVE (&sf_geom->poles[up_left], &(*dsf_geom)->poles[6],
                   sizeof(IGRpoint) );
    OM_BLOCK_MOVE (&sf_geom->poles[up_right], &(*dsf_geom)->poles[9],
                   sizeof(IGRpoint) );

    for (i = 0; i < 2; i++)
      (*dsf_geom)->u_knots[i] = (*dsf_geom)->v_knots[i] = 0.;
    for (i = 2; i < 4; i++)
      (*dsf_geom)->u_knots[i] = (*dsf_geom)->v_knots[i] = 1.;

  }
  else
  {
    BSpl_of_pts ( (sf_geom->u_num_poles * sf_geom->v_num_poles),
                  sf_geom->poles, sf_geom->weights, *dsf_geom,
                  &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
    
    /*
     * If the dsf_geom's normal is opposite to that of
     * sf_geom. Reverse the paramaterization to allign the
     * normals.
     */

    BSsfarrevn (&rc, *dsf_geom, 1, &u, 1, &v, sf_pt, dsf_nrml);
    EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);
    snrml_dot_dsnrml = BSdotp (&rc, sf_nrml, dsf_nrml);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
  }

  u_par = 0.4;
  BScveval ( hinge_curve_geom, u_par, 0, (IGRpoint *)point1, &rc);
  EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);

  /*********
  BSmdistptsf(&rc, *dsf_geom, point, &u_par, &v_par, point1, &dist);
  EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);
  **********/

  u_par = 0.6;
  BScveval ( hinge_curve_geom, u_par, 0, (IGRpoint *)point2, &rc);
  EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);

  /*********
  BSmdistptsf(&rc, *dsf_geom, point, &u_par, &v_par, point2, &dist);
  EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);
  **********/

  /* Get the transformation matrix directly using MAgrotmx() .
     This math routine gets the transformation matrix for the
     rotation with respect to an arbitrary (position) axis. 
     This solves the general problems like angle change &&
     volume change as mentioned in TR119423784. Hari
   */ 

  /* Get the hinge vector and normalize it */
  for(ii=0;ii<3;++ii) vect[ii] = point2[ii] - point1[ii];
  BSnorvec (&rc, vect);

  /* Get the required rotational matrix */
  status = MAgrotmx( &rc,
                   vect,
                   point1,
                   (IGRdouble *) &draft_angle,
                   (IGRdouble *)sc_tr_mat);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

  xform_mat =  &sc_tr_mat[0][0] ; 

  status = MAtypemx (&rc, xform_mat, &xform_mattype);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

  numpts = 4;
  status = MAoptsxform ( &rc, &numpts, &xform_mattype, xform_mat, 
                       (*dsf_geom)->poles, (*dsf_geom)->poles );
  EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);


wrapup:
  EMWRAPUP (*EFmsg, rc, "In EFget_drafted_sf_geom");
  return;
} 

end implementation EMSsubbs;

