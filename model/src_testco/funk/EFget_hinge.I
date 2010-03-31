class implementation EMSsubbs;

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
#include "emssfintdef.h"
#include "psdinc.h"
#include "bssfxttpt.h"
#include "bssfarrevt.h"
#include "bssfarrevn.h"
#include "bsplptnorrg.h"
#include "bsplane3pt.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsgeom_cvsf.h"

/*
  HISTORY

        Nirmal :    /01/93  :  genesis
	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
        Sanjay :  04/28/95  :  Add Draft does not handle surfaces which are 
                               linear in either of the directions i.e. U/V.
                               So, error out when such a surface is located.
                               Fix for TR# 119525508
        Hari   :  07/07/95  :  num_inters was not initialised, resulting in
                               problems in EMintersect_surfaces() .
                               Fix for UMR TR#119525966. 
*/

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMSdatpln_class_id;
extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMScone_class_id;
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMAgenbs_class_id;

from EMSdatpln import give_plane, EMget_pln_info;

   EFget_intersection(EMmsg,
                    md_env,
                    plane,
                    surf,
                    surf_to_draft,
                    draft_surf_geom_out,
                    const_list,
                    not_extend,
                    int_grid,
                    red_neck)
    IGRlong *EMmsg;
    struct GRmd_env *md_env;
    GRobjid *plane;
    struct IGRbsp_surface **draft_surf_geom_out;
    struct GRvg_construct *const_list;
    struct GRid *int_grid , *surf;
    IGRboolean not_extend;
    GRobjid *surf_to_draft;
    IGRboolean *red_neck;
   {
   IGRlong stat_OM= OM_S_SUCCESS, msg_loc = EMS_S_Success;
   BSrc rc = BSSUCC;
   IGRlong buf_size;
   IGRpoint orientation_point;
   IGRshort pos_orient;
   struct IGRbsp_surface *plane_geom=NULL;
   IGRint jj, ii, j, i;
   IGRdouble dist_out, plane_range[6], draft_surf_range[6], ext_dist, param[2];
   IGRboolean world, in_range, pos_orient_bit;
   IGRpoint plane_pt1, plane_pt0, plane_pt2, pt_1, pt_2 ;
   IGRdouble dotp, dist, par, u_par[1], v_par[1];
   IGRvector normalo, nrml1[1][1], nrml[1][1], nrml2[1][1];
   IGRpoint pnts1[1][1], pnts[1][1];
   struct GRid  my_GRid,greed;
   struct EMSinters *my_inters=NULL, *other_inters=NULL;
   struct EMSdataselect other_data;
   struct GRmdenv_info *other_datenv=NULL;
   IGRushort inters_opt, out_world=NULL, out_param = NULL;
   struct GRid SAVE_mdid;

   /* fix for UMR TR#119525966 . Hari */

   IGRint num_inters = 0;

   OMuword class_id;
   GRobjid datum_plane=NULL_OBJID;
   IGRdouble matrix[15];
   struct IGRbsp_surface *draft_surf_geom=NULL;
   IGRshort opt;
   IGRboolean tst_plan;
   struct IGRbsp_surface *surf_geom=NULL;
   struct IGRbsp_curve draft_srf_iso_crv;
   struct BSgeom_bsp_surf gmsf, xgmsf;
   IGRushort sf_type;
   IGRint option=1;
   IGRdouble x_dist, xx_dist, tolerance;
   extern void EFget_surf_geom();
   extern  void  BSxgmsfdst();
   extern void getsftype();
   extern void EFget_surf_extent();

    gmsf.bspsf=NULL;
    xgmsf.bspsf=NULL;
    getsftype(surf->objid, surf->osnum, &sf_type);
   *red_neck= FALSE;

   BSEXTRACTPAR(&rc,BSTOLLENVEC,tolerance);

    stat_OM = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                                  &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix,
                                  &buf_size),
                      senderid = NULL_OBJID,
                      targetid = surf->objid,
                      targetos = surf->osnum);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

    draft_surf_geom = NULL;
    draft_surf_geom = (struct IGRbsp_surface *) om$malloc(size= buf_size);
    EMerr_hndlr (!draft_surf_geom, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

    stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                                  &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix,
                         (IGRchar *) draft_surf_geom),
                      senderid = NULL_OBJID,
                      targetid = surf->objid,
                      targetos = surf->osnum);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

    stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                  &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix,
                                  &world,
                                  draft_surf_range),
                      senderid = NULL_OBJID,
                      targetid = surf->objid,
                      targetos = surf->osnum);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

     pos_orient_bit = draft_surf_geom->pos_orient;
     u_par[0] = v_par[0] = 0.5;
     BSsfarrevn(&rc, draft_surf_geom, 1, u_par, 1, v_par, 
                                     (IGRdouble *)pnts1, (IGRdouble *)nrml1); 
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, nrml1[0][0]);

    for(ii=0;ii<3;ii++)
     orientation_point[ii] = (draft_surf_range[3+ii]+draft_surf_range[ii])/2.0;

    for(ii = 0; ii<3; ii++)
       pt_2[ii] = (draft_surf_range[3+ii] + draft_surf_range[ii])/2.0;
       
    SAVE_mdid = const_list->env_info->md_id;

     if(EFisAncestryValid(&msg_loc,
          *plane, surf->osnum, OPP_EMSdatpln_class_id, FALSE))
       {
        plane_geom = (struct IGRbsp_surface *) alloca( buf_size);
        EMerr_hndlr (!plane_geom, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
        stat_OM = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                                  &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix,
                         (IGRchar *) plane_geom),
                      senderid = NULL_OBJID,
                      targetid = surf->objid,
                      targetos = surf->osnum);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);


        stat_OM = om$send (msg = message EMSdatpln.EMget_pln_info(
                      &msg_loc, NULL, md_env,
                      &matrix[0], &matrix[4], &matrix[8], &matrix[12], NULL),
                      senderid = NULL_OBJID,
                      targetid = *plane,
                      targetos = surf->osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

       for(ii = 0; ii<3; ii++)
          pt_1[ii] = matrix[ii+12];

       ext_dist = BSdistptpt(&rc, pt_1, pt_2);
       if( ext_dist <= 1.0)
          ext_dist =  BSdistptpt(&rc,
                   &draft_surf_range[0], &draft_surf_range[3]);
 
       in_range = TRUE;
       for(ii = 0; ii<3; ii++)
           {
           plane_pt1[ii] = matrix[ii+12]+
                    100.0 * (matrix[ii]*ext_dist -  matrix[ii+4]*ext_dist);
           plane_pt2[ii] = matrix[ii+12]+
                    100.0 * (matrix[ii+4]*ext_dist - matrix[ii]*ext_dist);
           plane_pt0[ii] = matrix[ii+12]-
                    100.0 * (matrix[ii+4]*ext_dist + matrix[ii]*ext_dist);
           }
       BSplane3pt(&rc, plane_pt0, plane_pt1, plane_pt2, plane_geom);
       EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

     u_par[0] = v_par[0] = 0.5;
     BSsfarrevn(&rc, plane_geom, 1, u_par, 1, v_par,
                                   (IGRdouble *)pnts, (IGRdouble *)nrml);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, nrml[0][0]);

      }
    else
      {
      EFget_surf_geom(&msg_loc, md_env, *plane, surf->osnum, &plane_geom);

     stat_OM = om$send(msg = message GRvg.GRgetrang(&msg_loc,
                                  &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix,
                                  &world,
                                  plane_range),
                      senderid = NULL_OBJID,
                      targetid = *plane,
                      targetos = surf->osnum);
     EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

     u_par[0] = v_par[0] = 0.5;
     BSsfarrevn(&rc, plane_geom, 1, u_par, 1, v_par, (IGRdouble *)pnts, (IGRdouble *)nrml);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     BSnorvec(&rc, nrml[0][0]);

     for(ii = 0; ii<3; ii++)
       pt_1[ii] = (plane_range[3+ii] + plane_range[ii])/2.0;
     ext_dist = BSdistptpt(&rc, pt_1, pt_2);

     in_range = TRUE;
     dist = 1000 *  ext_dist /
           BSdistptpt(&rc, &plane_range[0], &plane_range[3]);
     BSplptnorrg( &plane_range[0], &plane_range[3],
            pnts[0][0], nrml[0][0], dist, &in_range, plane_geom, &rc);
     EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
    }

      const_list->geometry = (IGRchar *)plane_geom;
      const_list->env_info->md_id.objid = NULL_OBJID;

      stat_OM = om$construct(osnum = surf->osnum,
         p_objid = &datum_plane, classid = OPP_EMSplane_class_id,
              msg = message GRgraphics.GRconstruct(const_list));

      stat_OM = om$send(msg = message EMSsubbs.EMalgnnrml(&msg_loc,
                  EMS_GET_POS_ORIENT, &pos_orient, orientation_point, md_env),
                        senderid = NULL_OBJID,
                        targetid = datum_plane,
                        targetos = surf->osnum);
       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

      dist = BSdistptpt(&rc, pt_1, pt_2);


      if(draft_surf_geom->planar != 1)
       {
      surf_geom = draft_surf_geom;
      gmsf.bspsf = surf_geom ;
      gmsf.sfgen_cv = NULL ;
      xgmsf.bspsf =  NULL;
      xgmsf.sfgen_cv = NULL ;

      gmsf.geom_prop=FALSE;
      gmsf.type=sf_type;
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
       for(jj=0;jj<2;jj++)
        {
         if(jj == 0 && surf_geom->v_phy_closed)
            continue;
         else if (jj == 1 && surf_geom->u_phy_closed)
            continue;

       ext_dist = dist;
         if(not_extend)
           {
           if(jj == 0 && surf_geom->v_order != 2)
              continue;
           if(jj == 1 && surf_geom->u_order != 2)
              continue;
           }
         else
           if(jj == 0 && surf_geom->v_order != 2)
              if(surf_geom->u_order == 2)
                ext_dist/=5.0;
              else 
                ext_dist/=10.0;

           if(jj == 1 && surf_geom->u_order != 2)
              if(surf_geom->v_order == 2)
                ext_dist/=5.0;
              else 
                ext_dist/=10.0;

       x_dist = ext_dist;
       xx_dist = ext_dist;
       if ((jj == 0 && surf_geom->v_order == 2) ||
           (jj == 1 && surf_geom->u_order == 2))
          {
          if(class_id ==OPP_EMAgenbs_class_id ||
             class_id == OPP_EMSgenbs_class_id )
             dist *= 5.0;
          EFget_surf_extent(&msg_loc, surf_geom, &x_dist, &xx_dist,  NULL);
          if(x_dist > ext_dist ||  x_dist < 0.0)
             x_dist = ext_dist;
          }
       else if ((jj == 1 && surf_geom->v_order == 2) ||
                (jj == 0 && surf_geom->u_order == 2))
          {
            EFget_surf_extent(&msg_loc, surf_geom, NULL, NULL, &x_dist);
          x_dist*=.45;
          if(x_dist > ext_dist ||  x_dist < 0.0)
             x_dist = ext_dist;
          }
          else
          {
           if(not_extend)
             x_dist = ext_dist/15.0;
          }

        option=1;
        if(jj==0)
          {
          gmsf.type=sf_type;
          if(x_dist > 0.0)
          BSxgmsfdst (&gmsf, x_dist, option, FALSE, FALSE, TRUE, TRUE,
                      &xgmsf, &dist_out, &rc);
          }
        else if(jj==1)
          {
          gmsf.type=sf_type;
          if(x_dist > 0.0)
          BSxgmsfdst (&gmsf, x_dist, option, TRUE, TRUE, FALSE, FALSE,
                      &xgmsf, &dist_out, &rc);
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

         if (xgmsf.bspsf)
           surf_geom = xgmsf.bspsf;
         if(gmsf.bspsf && (xgmsf.bspsf != gmsf.bspsf) && 
            (gmsf.bspsf != draft_surf_geom)) 
                   {om$dealloc(ptr= gmsf.bspsf); gmsf.bspsf=NULL;}

         class_id = OPP_EMSgenbs_class_id;

         draft_surf_geom = surf_geom;
         BSmdistptsf(&rc, draft_surf_geom, &pt_1[0], &u_par[0], &v_par[0],
               &plane_pt2[0], &dist);
         EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

         if( draft_surf_geom->u_order == 2)
          {
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
          {
          stat_OM = EMS_E_Fail;
          EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail, wrapup);
          }

          tst_plan = FALSE;
          BSconstprcv(&rc,draft_surf_geom,&opt,
                                     &par,&tst_plan, &draft_srf_iso_crv);
          EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

          BStst_plan(draft_srf_iso_crv.num_poles,
                draft_srf_iso_crv.poles,
                   draft_srf_iso_crv.weights, &tst_plan, normalo, &rc);

         dotp=BSdotp(&rc, normalo, nrml[0][0]); 
         dotp= fabs(dotp);
         dotp -= 1.0;
         *red_neck= FALSE;
         if(fabs(dotp) <= tolerance)
            *red_neck= FALSE;
         else
            *red_neck = TRUE;
      }
      else /*  planar surf to draft  **/
      {
         *red_neck= TRUE;
         in_range = TRUE;
         dist = 100.0 * ext_dist /
                BSdistptpt(&rc, &draft_surf_range[0], &draft_surf_range[3]);
         BSplptnorrg( &draft_surf_range[0], &draft_surf_range[3],
              pnts1[0][0], nrml1[0][0], dist, &in_range, draft_surf_geom, &rc);
         EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
         class_id = OPP_EMSplane_class_id;
      }


      u_par[0] = v_par[0] = 0.5;
      BSsfarrevn(&rc, draft_surf_geom, 1, u_par, 1, v_par,
                                 (IGRdouble *)pnts, (IGRdouble *)nrml2); 
      EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
      BSnorvec(&rc, nrml2[0][0]);
      dotp = BSdotp(&rc, nrml1[0][0], nrml2[0][0]);
      if(
        (dotp < 0.0 && ( pos_orient_bit == draft_surf_geom->pos_orient))
                                     ||
        (dotp > 0.0 && ( pos_orient_bit != draft_surf_geom->pos_orient))
        )
        draft_surf_geom->pos_orient = !draft_surf_geom->pos_orient;


      const_list->geometry = (IGRchar *)draft_surf_geom;
      const_list->env_info->md_id.objid = NULL_OBJID;
      const_list->env_info->md_id.objid = SAVE_mdid.objid;

      stat_OM = om$construct(osnum = surf->osnum,
           p_objid = surf_to_draft, classid = class_id,
              msg = message GRgraphics.GRconstruct(const_list));
      if(!(1&msg_loc&stat_OM)) goto wrapup;

      other_datenv = &md_env->md_env;
      other_data.datatype = EMSdata_object;

      greed.objid = *surf_to_draft;
      greed.osnum = surf->osnum;
      other_data.data.object = &greed;

      out_world |= EMSINT_OUTPUT_WORLD ;
      out_param = NULL;
      out_param |=  EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT;
      out_param |= EMSINT_ORIENT_OUTPUT; 

      inters_opt = EMS_SFINT_MUSTINTERSECT;

      my_GRid.objid = datum_plane;
      my_GRid.osnum = surf->osnum;

      if(int_grid)
            int_grid->osnum =  surf->osnum;

      const_list->env_info->md_id.objid = SAVE_mdid.objid;
      stat_OM = EMintersect_surfaces(EMmsg, &my_GRid, &md_env->md_env, 1,
      &other_data, &const_list->env_info->md_env, NULL, out_world,
      out_param, NULL, const_list, &num_inters, &my_inters,
      &other_inters, NULL, NULL, (int_grid ? &int_grid->objid : NULL),
      NULL, NULL);

      if(!(1&msg_loc&stat_OM) || int_grid->objid == NULL_OBJID)
         {
         ex$message(msgnumb = EMS_F_SurfTanSurf);
         stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdelete (&msg_loc, md_env),
                        senderid = NULL_OBJID,
                        targetid = *surf_to_draft,
                        targetos = surf->osnum);
         }

      if(draft_surf_geom_out) *draft_surf_geom_out = draft_surf_geom;

   wrapup:

      if (datum_plane != NULL_OBJID)
      { 
        SAVE_mdid = md_env->md_id;
        md_env->md_id.objid = NULL_OBJID;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdelete (&msg_loc, md_env),
                        senderid = NULL_OBJID,
                        targetid = datum_plane,
                        targetos = surf->osnum);
        md_env->md_id = SAVE_mdid;
      }

      EMinters_data_free(&msg_loc, my_inters, 0, NULL, NULL);
      EMinters_data_free(&msg_loc, other_inters, 0, NULL, NULL);
      EMinters_free(my_inters, 0);
      EMinters_free(other_inters, 0);
      return(stat_OM);
   }

end implementation EMSsubbs;

      



