/*

  ALGORITHM :

	Given a set of curves and a composite surface, this function finds out
	the longest curve.  If the longest curve turns out to be a composite
	curve, then it picks up its longest and next longest components.
        It determines the component surfaces on which the longest curve, or the
        longest component curves, lies.  Based on the orientation component
        surfaces, it orients the longest curve and prompts the user for the
	area side.  Based on the user's choice, it returns a flag stating
	whether the curve is to be reversed or not denoting as to which side
	of the curve is going to be retained as area.

  ARGUMENTS :

	IGRlong *EMmsg                Error message returned.

	struct GRlc_info *surface     Locate info for the surface to be
                                      imposed.

	struct GRlc_info **curves     Locate info for the curves to be
                                      imposed.

        IGRlong num_curves            Number of curves to be imposed.

	struct GRid *win_grid         GRid of the window in which the
                                      last curve was located.

	IGRlong *response,
        IGRchar *response_data        Passed on from the command object
                                      execute method.

        GRobjid my_id                 The objid of the object whose method
	                              is calling this function.

	IGRint *crv_index             The index of the largest curve in the
                                      array of curves to be imposed.  The 
                                      return value.

        GRobjid *lrgst_cmpid          The largest curve objid. The return
                                      value. 
  HISTORY :

	M.R. Vadiraj  :  01/07/93  :  Creation	
 */
class implementation ECmkcompsf;

#include "EMS.h"
#if DEBUG
#include <stdio.h>
#endif
# ifndef griodef_include
# include "griodef.h"
# endif
# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
# ifndef dpstruct_include
# include "dpstruct.h"
# endif
#include "igrdef.h"                    
# ifndef griodef_include
# include "griodef.h"
# endif

#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "ECdlb.h"     /* To be found in testco-include */
#include "exdef.h"
#include "local_dsp.h"  
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"   
#include "msmacros.h"   
#include "maerr.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "EMSmsgdef.h"
#include "EMSasmacros.h"
#include "EMSdpb.h"
#include "emserr.h"
#include "EMSasopts.h"
#include "emsdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsmacros.h"

extern OMuword OPP_GRcompcurve_class_id;

from GRgraphics import GRgetrang;
from GRowner import GRget_number_components;
from GRvg import GRgetsize, GRgetgeom, EMptatpr, EMpratpt;
from EMScompsurf import GRptproject;
from GRcurve import     EMcvtanorm;
from EMSsubbs import    EMsftanorm;
from GRcompcurve import GRtotlength;

IGRlong EMorntcvonsf(IGRlong *EMmsg,
                     struct GRlc_info *surface,
                     struct GRlc_info **curves,
                     IGRlong num_curves,
                     struct GRid *win_grid,
                     IGRlong *response,
                     IGRchar *response_data,
                     GRobjid my_id,
                     IGRint *crv_index,
                     GRobjid *lrgst_cmpid)

{
  IGRlong	           OM_stat, size_buff, nbytes_ret, comp_size, mthd_stat,                           reverse = 0, event_mask;
  IGRdouble                length, comp_length,
                           nxt_lrgst_comp_ln = 0.0,lrgst_comp_ln = 0.0,
                           largest_length = 0.0,
                           intpt[3], pt_on_lrgst_comp[3], range[6], diag_dist,
                           pt_on_nxt_lrgst_comp[3], temp_pt[3], surf_pt[3],
                           tmp_poly[6], proj_pt[3], nxt_lrgst_cmpsf_nrm[3],
                           lrgst_compcv_tan[3], nxt_lrgst_cmpcv_tan[3],
                           int_pt1[3], int_pt2[3], pt1_compsf_nrm[3],
                           vector_1[3], vector_2[3], parm_1, parm_2,
                           pt2_compsf_nrm[3], pt1_compcv_tan[3], vwvolume[6],
                           pt2_compcv_tan[3], lrgst_compsf_nrm[3]; 
  struct GRlc_info         *longest_crv = NULL, sf_info;
  struct var_list          list_var[2];
  OMuword 	           class_id;
  OMuint                   obj_count;  
  IGRint                   num_components, num_bytes, i, ret_stat, j,
                           num_parms, nbytes;
  OM_S_CHANSELECT          composite_chan;
  OM_S_OBJECT_LINKAGE      *components = NULL, longest_comp_crv,
                           nxt_longest_comp_crv, significant_comps[2];
  struct IGRbsp_curve      **significant_crvs = NULL;
  struct IGRbsp_surface    *sf_geom = NULL;
  struct EMSdataselect     temp_geom;
  struct GRmd_env          mod_info;
  struct IGRdisplay        local_symbology;
  struct GRparms           tmp_parms, lrgst_compsf_parms, pt1_parms,
                           pt2_parms, nxt_lrgst_cmpsf_prm, proj_parms;
  IGRboolean               reverse1 = FALSE, reverse2 = FALSE,
                           master_posornt = 0, pos_orient = 0;
  struct GRevent           event;

  void                     EFdraw_vector_on_screen();
  extern IGRlong           EMinternalpt();
  extern IGRdouble         BSdistptpt();
  extern IGRlong           EMget_the_geometry();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &composite_chan);
            EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);  
  longest_crv = curves[0];

           /* Getting the active display for displaying the vectors */

              num_bytes = sizeof(struct IGRdisplay);
              gr$get_active_display(msg = &mthd_stat,
                                    sizbuf = &num_bytes,
                                    buffer = &local_symbology,
                                    nret = &nbytes_ret);
      for(i=0;i<num_curves;i++)
         {
      OM_stat = om$send(msg = message GRcompcurve.GRtotlength(&mthd_stat,
                              &curves[i]->module_info.md_env.matrix_type,
                              curves[i]->module_info.md_env.matrix,
                              &length),
                        targetid = curves[i]->located_obj.objid,
                        targetos = curves[i]->located_obj.osnum);
      EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg, EMS_E_CurveError,wrapup);

      if(longest_crv->located_obj.objid == curves[i]->located_obj.objid)
      {
      largest_length = length;
      continue;
      }
      else if(length > largest_length) {
         largest_length = length;
         longest_crv = curves[i];
         *crv_index = i;
        }
     }

  /*
           Getting the range of the window in which the vectors are to be
           displayed
   */

                     size_buff = sizeof(struct GRmd_env);
                     gr$get_module_env(msg = &mthd_stat,
                                     sizbuf = &size_buff,
                                     buffer = &mod_info,
                                     nret = &nbytes_ret);

        list_var[0].var = VW_VOLUME;
        list_var[0].var_ptr = (char *)vwvolume;
        list_var[0].num_bytes = sizeof(IGRdouble) * 6;
        list_var[0].bytes_returned = (IGRlong *)&ret_stat;
        list_var[1].var = END_PARAM;
        list_var[1].var_ptr = NULL;
        list_var[1].num_bytes = 0;
        list_var[1].bytes_returned = NULL;

        OM_stat = dp$inq_set_gragad(msg = &mthd_stat,
                  osnum = win_grid[*crv_index].osnum,
                  gragad_objid = win_grid[*crv_index].objid,
                  which_error = &ret_stat,
                  var_list = list_var);

        OM_BLOCK_MOVE(&vwvolume[0], &range[0], sizeof(IGRpoint));
        OM_BLOCK_MOVE(&vwvolume[3], &range[3], sizeof(IGRpoint));

           diag_dist = BSdistptpt(&mthd_stat, &range[0], &range[3]);
           diag_dist /= 10.0;

            for(i = 0; i < 3; i++)
           {
               range[i] = 0.0;
               range[i+3] = diag_dist;
           }

           /* Getting the active display for displaying the vectors */

              num_bytes = sizeof(struct IGRdisplay);
              gr$get_active_display(msg = &mthd_stat,
                                    sizbuf = &num_bytes,
                                    buffer = &local_symbology,
                                    nret = &nbytes_ret);

     OM_stat = om$get_classid(objid = longest_crv->located_obj.objid,
                           osnum = longest_crv->located_obj.osnum,
                           p_classid = &class_id);
     if (!(1 & OM_stat)) goto wrapup;
  
     if (om$is_ancestry_valid(subclassid = class_id,
         superclassid = OPP_GRcompcurve_class_id) == OM_S_SUCCESS)
   { 
     OM_stat = om$send(msg = message GRowner.GRget_number_components(
                            &mthd_stat, &num_components),
                   targetid = longest_crv->located_obj.objid,
                   targetos = longest_crv->located_obj.osnum,
                   senderid = NULL_OBJID);        
      EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg, EMS_E_CurveError,wrapup);

     components = (OM_S_OBJECT_LINKAGE *) om$malloc(size =
                                        (OMuint)num_components *
                                        sizeof(OM_S_OBJECT_LINKAGE));  
     EMerr_hndlr(! components, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

     OM_stat = om$get_channel_objects(objid = longest_crv->located_obj.objid,
                                     osnum = longest_crv->located_obj.osnum,
                                     p_chanselect = &composite_chan,
                                     list = components,
                                     size = num_components,
                                     count = &obj_count);
     if (!(1 & OM_stat) || (num_components != obj_count)) goto wrapup;
     
     longest_comp_crv.S_objid = components[0].S_objid;
     longest_comp_crv.osnum = components[0].osnum; 

     for(i=0;i<num_components;i++)
     {
      OM_stat = om$send(msg = message GRcurve.GRtotlength(&mthd_stat,
                        &longest_crv->module_info.md_env.matrix_type,
                        longest_crv->module_info.md_env.matrix,
                        &comp_length),
                        targetid = components[i].S_objid,
                        targetos = components[i].osnum,
                        senderid = longest_crv->located_obj.objid);
      EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg, EMS_E_CurveError,wrapup);

      if(longest_comp_crv.S_objid == components[i].S_objid)
      {
      lrgst_comp_ln = comp_length;
      nxt_lrgst_comp_ln = 0.0;
      continue;
      }
      else if(comp_length > lrgst_comp_ln) {
         nxt_lrgst_comp_ln = lrgst_comp_ln;
         nxt_longest_comp_crv.S_objid = longest_comp_crv.S_objid;
         nxt_longest_comp_crv.osnum = longest_comp_crv.osnum;
         lrgst_comp_ln = comp_length;
         longest_comp_crv.S_objid = components[i].S_objid;
         longest_comp_crv.osnum = components[i].osnum;
        }
      else if(comp_length > nxt_lrgst_comp_ln) {
           nxt_lrgst_comp_ln = comp_length;
           nxt_longest_comp_crv.S_objid = components[i].S_objid;
           nxt_longest_comp_crv.osnum = components[i].osnum;
        }
     }

      significant_comps[0].S_objid = longest_comp_crv.S_objid;
      significant_comps[0].osnum = longest_comp_crv.osnum;
      significant_comps[1].S_objid = nxt_longest_comp_crv.S_objid;
      significant_comps[1].osnum = nxt_longest_comp_crv.osnum;   
      if(lrgst_cmpid) *lrgst_cmpid = longest_comp_crv.S_objid;

      significant_crvs = (struct IGRbsp_curve **) om$malloc(size = 2 * sizeof
                                                 (struct IGRbsp_curve *)); 
      
      EMerr_hndlr(! significant_crvs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      for(i=0;i<2;i++) {
      OM_stat = om$send(msg = message GRvg.GRgetsize(&mthd_stat,
                           &longest_crv->module_info.md_env.matrix_type,
                           longest_crv->module_info.md_env.matrix,
                           &comp_size),
                     senderid = NULL_OBJID,
                     targetid = significant_comps[i].S_objid,
                     targetos = significant_comps[i].osnum);
      EMerr_hndlr(! (1 & OM_stat & mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

      significant_crvs[i] = (struct IGRbsp_curve *) om$malloc(size = (OMuint)
                            comp_size);
     EMerr_hndlr(! significant_crvs[i], *EMmsg, EMS_E_NoDynamicMemory, wrapup);

      OM_stat = om$send(msg = message GRvg.GRgetgeom(&mthd_stat,
                           &longest_crv->module_info.md_env.matrix_type,
                           longest_crv->module_info.md_env.matrix,
                           (IGRchar *)significant_crvs[i]),
                     senderid = NULL_OBJID,
                     targetid = significant_comps[i].S_objid,
                     targetos = significant_comps[i].osnum);
      EMerr_hndlr(! (1 & OM_stat & mthd_stat), *EMmsg, EMS_E_Fail, wrapup);  

      temp_geom.datatype = EMSdata_curve3d;
      temp_geom.data.curve = significant_crvs[i];
 
      EMinternalpt(&mthd_stat, NULL, NULL, &temp_geom, EMScvint_middle,
                    1, intpt);
      EMerr_hndlr (EMSerror (mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

      if(significant_comps[i].S_objid == longest_comp_crv.S_objid)
      for(j=0;j<3;j++) pt_on_lrgst_comp[j] = intpt[j];
      else
      for(j=0;j<3;j++) pt_on_nxt_lrgst_comp[j] = intpt[j];
      }

      for(i=0;i<2;i++) {
             if(significant_comps[i].S_objid == longest_comp_crv.S_objid)
             OM_BLOCK_MOVE(pt_on_lrgst_comp, temp_pt, sizeof(IGRpoint)); 
             else
             OM_BLOCK_MOVE(pt_on_nxt_lrgst_comp, temp_pt, sizeof(IGRpoint));

             OM_stat = om$send(msg = message EMScompsurf.GRptproject(&mthd_stat,
                              &surface->module_info.md_env.matrix_type,
                              surface->module_info.md_env.matrix,
                              temp_pt, surf_pt, &tmp_parms),
                        mode = OM_e_wrt_message,
                        senderid = NULL_OBJID,
                        targetid = surface->located_obj.objid,
                        targetos = surface->located_obj.osnum);       
            EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

            if(significant_comps[i].S_objid == longest_comp_crv.S_objid)
                OM_BLOCK_MOVE(&tmp_parms, &lrgst_compsf_parms,
                                sizeof(struct GRparms));
            else 
                OM_BLOCK_MOVE(&tmp_parms, &nxt_lrgst_cmpsf_prm,
                                sizeof(struct GRparms));
            }
             
       /* Normals at the projected points for both the component surfaces */

           for(i=0;i<2;i++) {
              if(significant_comps[i].S_objid == longest_comp_crv.S_objid)
              OM_BLOCK_MOVE(&lrgst_compsf_parms, &tmp_parms,
                                sizeof(struct GRparms));
              else
              OM_BLOCK_MOVE(&nxt_lrgst_cmpsf_prm, &tmp_parms,
                                sizeof(struct GRparms));

             OM_stat = om$send(msg = message GRvg.GRgetsize(
                        &mthd_stat,
                        &surface->module_info.md_env.matrix_type,
                        surface->module_info.md_env.matrix,
                        &size_buff),
                        senderid = NULL_OBJID,
                        targetid = tmp_parms.leaf_id.objid,
                        targetos = tmp_parms.leaf_id.osnum);
             ERROR(OM_stat,mthd_stat,"GRvg.GRgetsize",wrapup);

             sf_geom = (struct IGRbsp_surface *) om$malloc (size = size_buff);
             EMerr_hndlr(!sf_geom, *EMmsg, EMS_E_NoDynamicMemory, wrapup); 
             OM_stat = om$send(msg = message GRvg.GRgetgeom(
                        &mthd_stat,
                        &surface->module_info.md_env.matrix_type,
                        surface->module_info.md_env.matrix,
                        (IGRchar *)sf_geom),
                        senderid = NULL_OBJID,
                        targetid = tmp_parms.leaf_id.objid,
                        targetos = tmp_parms.leaf_id.osnum);
             ERROR(OM_stat,mthd_stat,"GRvg.GRgetgeom",wrapup); 
             if(significant_comps[i].S_objid == longest_comp_crv.S_objid)
                master_posornt = sf_geom->pos_orient;
             else
             pos_orient = sf_geom->pos_orient;  
       
              OM_stat = om$send(msg = message EMSsubbs.EMsftanorm
                         (&mthd_stat, &surface->module_info.md_env.matrix_type,
                          surface->module_info.md_env.matrix,
                          (struct GRvg_construct *)NULL,
                          (IGRlong)1, &tmp_parms.u,
                          (IGRlong)1, &tmp_parms.v,
                          (IGRdouble)1.0, (IGRdouble *)NULL,
                          (IGRboolean)FALSE, (IGRboolean)TRUE, tmp_poly,
                          (OM_S_OBJID *)NULL),
                    targetid = tmp_parms.leaf_id.objid,
                    targetos = tmp_parms.leaf_id.osnum);  
               ERROR(OM_stat,mthd_stat,"GRcurve.EMcvtanorm",wrapup);

              if(significant_comps[i].S_objid == longest_comp_crv.S_objid)
                {
                lrgst_compsf_nrm[0] = tmp_poly[3] - tmp_poly[0];
                lrgst_compsf_nrm[1] = tmp_poly[4] - tmp_poly[1];
                lrgst_compsf_nrm[2] = tmp_poly[5] - tmp_poly[2];  
                }
              else {
                nxt_lrgst_cmpsf_nrm[0] = tmp_poly[3] - tmp_poly[0];
                nxt_lrgst_cmpsf_nrm[1] = tmp_poly[4] - tmp_poly[1];
                nxt_lrgst_cmpsf_nrm[2] = tmp_poly[5] - tmp_poly[2];
                }
           
              loc_wrapup :
                 if(sf_geom) {
                   om$dealloc(ptr = sf_geom);
                   sf_geom = NULL; 
                   }
              }

        /* Tangents at the mid-points of both the significant curves */

              for(i=0;i<2;i++)  {
               if(significant_comps[i].S_objid == longest_comp_crv.S_objid)
               OM_BLOCK_MOVE(pt_on_lrgst_comp, temp_pt, 3*sizeof(IGRdouble));
               else  
              OM_BLOCK_MOVE(pt_on_nxt_lrgst_comp, temp_pt, 3*sizeof(IGRdouble));
               
               OM_stat = om$send(msg = message GRvg.EMpratpt(&mthd_stat,
                         &longest_crv->module_info.md_env.matrix_type,
                          longest_crv->module_info.md_env.matrix,  
                          temp_pt, proj_pt, &num_parms),
                          senderid = NULL_OBJID,
                          targetid = significant_comps[i].S_objid,
                          targetos = significant_comps[i].osnum);
                ERROR(OM_stat,mthd_stat,"GRvg.EMpratpt", wrapup);   

                  proj_parms.u = proj_pt[0];
                  proj_parms.v = proj_pt[1];

                  OM_stat = om$send(msg = message GRcurve.EMcvtanorm
                    (&mthd_stat, &longest_crv->module_info.md_env.matrix_type,
                     longest_crv->module_info.md_env.matrix,
                     (struct GRvg_construct *)NULL,
                     (IGRlong)1, &proj_parms,
                     &proj_parms, &proj_parms,
                     (IGRdouble)1.0, (IGRdouble *)NULL,
                     (IGRboolean)TRUE, (IGRboolean)FALSE, tmp_poly,
                     (OM_S_OBJID *)NULL),
                    senderid = NULL_OBJID,
                    targetid = significant_comps[i].S_objid,
                    targetos = significant_comps[i].osnum);
                  ERROR(OM_stat, mthd_stat, "GRcurve.EMcvtanorm", wrapup);

                if(significant_comps[i].S_objid == longest_comp_crv.S_objid)
                {
                lrgst_compcv_tan[0] = tmp_poly[3] - tmp_poly[0];
                lrgst_compcv_tan[1] = tmp_poly[4] - tmp_poly[1];
                lrgst_compcv_tan[2] = tmp_poly[5] - tmp_poly[2];
                }
              else {
                nxt_lrgst_cmpcv_tan[0] = tmp_poly[3] - tmp_poly[0];
                nxt_lrgst_cmpcv_tan[1] = tmp_poly[4] - tmp_poly[1];
                nxt_lrgst_cmpcv_tan[2] = tmp_poly[5] - tmp_poly[2];
                }                  
               }

        /* Calculating the vectors to be drawn */

      if(master_posornt != 1) {
         for(i = 0; i < 3; i++)
             lrgst_compsf_nrm[i] = (-1) * lrgst_compsf_nrm[i];
                             }
      if(pos_orient != 1) {
         for(i = 0; i < 3; i++)
             nxt_lrgst_cmpsf_nrm[i] = (-1) * nxt_lrgst_cmpsf_nrm[i];
             }
             
      MAcrossvc(&mthd_stat, lrgst_compcv_tan, lrgst_compsf_nrm, vector_1);
      MAcrossvc(&mthd_stat, nxt_lrgst_cmpcv_tan, nxt_lrgst_cmpsf_nrm, vector_2);

          /* Drawing the vectors on the screen */
           
             MAunitvc(&mthd_stat, vector_1, vector_1);
             MAunitvc(&mthd_stat, vector_2, vector_2);

             EFdraw_vector_on_screen(my_id, &local_symbology, &mod_info,
               GRhd, reverse1, pt_on_lrgst_comp, vector_1, range, &mthd_stat);

             EFdraw_vector_on_screen(my_id, &local_symbology, &mod_info,
             GRhd, reverse2, pt_on_nxt_lrgst_comp, vector_2, range, &mthd_stat);

            /* Prompt for the acceptance/rejection of the direction shown */

             ex$message(msgnumb = EMS_P_AccArSiMoRev);

             event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
                OM_stat = ems$getevent(msg = &mthd_stat,
                                event_mask = event_mask,
                                response = (long *)response,
                                response_data = response_data,
                                nbytes = &nbytes,
                                event = &event);

                ex$message(msgnumb=EMS_P_ClearPromptField);
                ex$message(msgnumb=EMS_S_ClearStatusField);

                if(!(1&OM_stat) || mthd_stat == MSFAIL) {
                        OM_stat = EMS_E_Fail;
                        goto wrapup;
                }

            /* Erasing the vectors */

            EFdraw_vector_on_screen(my_id, &local_symbology, &mod_info,
            GRbehe, reverse1, pt_on_lrgst_comp, vector_1, range, &mthd_stat);

            EFdraw_vector_on_screen(my_id, &local_symbology, &mod_info,
            GRbehe, reverse2, pt_on_nxt_lrgst_comp, vector_2, range,&mthd_stat);

          }  

         else {

              /* Case of a single significant curve */

                 parm_1 = 0.25;
                 parm_2 = 0.75;
                 *lrgst_cmpid = NULL_OBJID; 

      OM_stat = om$send(msg = message GRvg.EMptatpr(&mthd_stat,
                &longest_crv->module_info.md_env.matrix_type,
                longest_crv->module_info.md_env.matrix, &parm_1, 1, int_pt1),
               targetid = longest_crv->located_obj.objid,
               targetos = longest_crv->located_obj.osnum);

      OM_stat = om$send(msg = message GRvg.EMptatpr(&mthd_stat,
                &longest_crv->module_info.md_env.matrix_type,
                longest_crv->module_info.md_env.matrix, &parm_2, 1, int_pt2),
               targetid = longest_crv->located_obj.objid,
               targetos = longest_crv->located_obj.osnum ); 
       
      for(i=0;i<2;i++) {
             if(i == 0)
             OM_BLOCK_MOVE(int_pt1, temp_pt, sizeof(IGRpoint));
             else
             OM_BLOCK_MOVE(int_pt2, temp_pt, sizeof(IGRpoint));

             OM_stat = om$send(msg = message EMScompsurf.GRptproject(&mthd_stat,
                              &surface->module_info.md_env.matrix_type,
                              surface->module_info.md_env.matrix,
                              temp_pt, surf_pt, &tmp_parms),
                        senderid = NULL_OBJID,
                        targetid = surface->located_obj.objid,
                        targetos = surface->located_obj.osnum);
            EMerr_hndlr(!(1 & OM_stat & mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

            if(i == 0)
                OM_BLOCK_MOVE(&tmp_parms, &pt1_parms,
                                sizeof(struct GRparms));
            else
                OM_BLOCK_MOVE(&tmp_parms, &pt2_parms,
                                sizeof(struct GRparms));
            }

           OM_BLOCK_MOVE(&surface->module_info, &sf_info.module_info,
                         sizeof(struct GRmd_env));
           for(i=0;i<2;i++) {
               if(i == 0) {
                  sf_info.located_obj.objid = pt1_parms.leaf_id.objid;
                  sf_info.located_obj.osnum = pt1_parms.leaf_id.osnum;
                          }
               else {
                  sf_info.located_obj.objid = pt2_parms.leaf_id.objid;
                  sf_info.located_obj.osnum = pt2_parms.leaf_id.osnum;
                    }

               OM_stat = EMget_the_geometry(&sf_info, TRUE, NULL, FALSE,
                               NULL_OBJID, (IGRchar **)&sf_geom, &mthd_stat);
                         EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg,
                                     mthd_stat, wrapup);
               if(i == 0)
                  master_posornt = sf_geom->pos_orient;
               else
                  pos_orient = sf_geom->pos_orient;
                          }

           for(i=0;i<2;i++) {
              if(i == 0)
              OM_BLOCK_MOVE(&pt1_parms, &tmp_parms,
                                sizeof(struct GRparms));
              else
              OM_BLOCK_MOVE(&pt2_parms, &tmp_parms,
                                sizeof(struct GRparms));

              OM_stat = om$send(msg = message EMSsubbs.EMsftanorm
                         (&mthd_stat, &surface->module_info.md_env.matrix_type,
                          surface->module_info.md_env.matrix,
                          (struct GRvg_construct *)NULL,
                          (IGRlong)1, &tmp_parms.u,
                          (IGRlong)1, &tmp_parms.v,
                          (IGRdouble)1.0, (IGRdouble *)NULL,
                          (IGRboolean)FALSE, (IGRboolean)TRUE, tmp_poly,
                          (OM_S_OBJID *)NULL),
                    targetid = tmp_parms.leaf_id.objid,
                    targetos = tmp_parms.leaf_id.osnum);
               ERROR(OM_stat,mthd_stat,"GRcurve.EMcvtanorm",wrapup);

              if(i == 0)
                {
                pt1_compsf_nrm[0] = tmp_poly[3] - tmp_poly[0];
                pt1_compsf_nrm[1] = tmp_poly[4] - tmp_poly[1];
                pt1_compsf_nrm[2] = tmp_poly[5] - tmp_poly[2];
                }
              else {
                pt2_compsf_nrm[0] = tmp_poly[3] - tmp_poly[0];
                pt2_compsf_nrm[1] = tmp_poly[4] - tmp_poly[1];
                pt2_compsf_nrm[2] = tmp_poly[5] - tmp_poly[2];
                }
              }

             for(i=0;i<2;i++)  {
               if(i == 0)
               OM_BLOCK_MOVE(int_pt1, temp_pt, 3*sizeof(IGRdouble));
               else
               OM_BLOCK_MOVE(int_pt2, temp_pt, 3*sizeof(IGRdouble));

               OM_stat = om$send(msg = message GRvg.EMpratpt(&mthd_stat,
                         &longest_crv->module_info.md_env.matrix_type,
                          longest_crv->module_info.md_env.matrix,
                          temp_pt, proj_pt, &num_parms),
                          senderid = NULL_OBJID,
                          targetid = longest_crv->located_obj.objid,
                          targetos = longest_crv->located_obj.osnum);
                ERROR(OM_stat,mthd_stat,"GRvg.EMpratpt",wrapup);

                  proj_parms.u = proj_pt[0];
                  proj_parms.v = proj_pt[1];
                  OM_stat = om$send(msg = message GRcurve.EMcvtanorm
                    (&mthd_stat, &longest_crv->module_info.md_env.matrix_type,
                     longest_crv->module_info.md_env.matrix,
                     (struct GRvg_construct *)NULL,
                     (IGRlong)1, &proj_parms,
                     &proj_parms, &proj_parms,
                     (IGRdouble)1.0, (IGRdouble *)NULL,
                     (IGRboolean)TRUE, (IGRboolean)FALSE, tmp_poly, 
                     (OM_S_OBJID *)NULL),
                    senderid = NULL_OBJID,
                    targetid = longest_crv->located_obj.objid,
                    targetos = longest_crv->located_obj.osnum);
                  ERROR(OM_stat, mthd_stat, "GRcurve.EMcvtanorm",wrapup);

                if(i == 0)
                {
                pt1_compcv_tan[0] = tmp_poly[3] - tmp_poly[0];
                pt1_compcv_tan[1] = tmp_poly[4] - tmp_poly[1];
                pt1_compcv_tan[2] = tmp_poly[5] - tmp_poly[2];
                }
              else {
                pt2_compcv_tan[0] = tmp_poly[3] - tmp_poly[0];
                pt2_compcv_tan[1] = tmp_poly[4] - tmp_poly[1];
                pt2_compcv_tan[2] = tmp_poly[5] - tmp_poly[2];
                }
               }
              
              /* 
                 Calculating the display vectors for the non-composite
                 significant curve
              */

                if(master_posornt != 1) {
                         for(i = 0; i < 3; i++)
                             pt1_compsf_nrm[i] = (-1) * pt1_compsf_nrm[i];
                                   }
                if(pos_orient != 1) {
                         for(i = 0; i < 3; i++)
                             pt2_compsf_nrm[i] = (-1) * pt2_compsf_nrm[i];
                                   }

                MAcrossvc(&mthd_stat, pt1_compcv_tan, pt1_compsf_nrm, vector_1);
                MAcrossvc(&mthd_stat, pt2_compcv_tan, pt2_compsf_nrm, vector_2);

             /*
                Drawing the vectors on the screen for the non-composite
                significant curve
             */

                MAunitvc(&mthd_stat, vector_1, vector_1);
                MAunitvc(&mthd_stat, vector_2, vector_2);

              reverse = FALSE;

              EFdraw_vector_on_screen(my_id, &local_symbology, &mod_info,
              GRhd, reverse, int_pt1, vector_1, range, &mthd_stat);

              EFdraw_vector_on_screen(my_id, &local_symbology, &mod_info,
              GRhd, reverse, int_pt2, vector_2, range, &mthd_stat);

              /*
                Prompt for the acceptance/rejection of the direction shown
               */
             
             ex$message(msgnumb = EMS_P_AccArSiMoRev);
             event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
             OM_stat = ems$getevent(msg = &mthd_stat,
                        event_mask = event_mask,
                        response = (long *)response,
                        nbytes = &nbytes,
                        response_data = response_data,
                        event = &event);

             ex$message(msgnumb=EMS_P_ClearPromptField);
             ex$message(msgnumb=EMS_S_ClearStatusField);

                if(!(1&OM_stat) || mthd_stat == MSFAIL) {
                        OM_stat = EMS_E_Fail;
                        goto wrapup;
                }  

             /* Erasing the vectors */

            EFdraw_vector_on_screen(my_id, &local_symbology, &mod_info,
             GRbehe, reverse, int_pt1, vector_1, range, &mthd_stat);

            EFdraw_vector_on_screen(my_id, &local_symbology, &mod_info,
            GRbehe, reverse, int_pt2, vector_2, range, &mthd_stat);

           }

 wrapup :

            if (components) om$dealloc(ptr = components);
            if (significant_crvs) om$dealloc(ptr = significant_crvs);

         if(event.response == GR_UNKNOWN_TYPE)
           return(OM_S_SUCCESS);                    /* What to return ? */
         else{
              if (event.response == EX_RJT_MOVEON)
                 reverse = TRUE;
              else if (event.response == EX_DATA)
                   reverse = FALSE;
              else if (event.response == EX_BACK_UP)
                   reverse = EX_BACK_UP;
              }
           return(reverse);
}
end implementation ECmkcompsf;
