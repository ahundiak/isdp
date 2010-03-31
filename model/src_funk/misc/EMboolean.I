/*
Algorithm : Take two lc_info's as input. If they are composites, get
            the geometry of individual curves as well as the merged
            geometry of the composite. The merged geometry of the 
            composite is used for clockwise / counterclockwise
            classification of the curve. call math ---- The resultant
            loops are stored as follows.

            num        -- number of sets of contiguous loops formed
            orta, ortb -- clockwise / counter_clockwise classification
                          of the input curves
            loops      -- structure BSloop containing information about
                          the output loops
            loops[i][0].num -- number of loops in loop set (num) i
            loops[i][0].lpind[0][0] -- indicating resultant loop is from
                                       curve set 1 or curve set 2
            loops[i][0].lpind[0][1] -- indicating the index of the input 
                                       curve in the curve set stack
            loop[i][0].par[0][0] -- begin parameter of the loop
            loop[i][0].par[0][1] -- end parameter of the loop
  
         For each loop set, a composite is made and returned to the
         caller. This function handles disjointness.

Note :   As of now, for composite curves, the individual curves geometry
         is being fetched twice. Once here and again while extracting
         the geometry of the composite. This has to be avoided.

History : 02/01/88 : Creation date
          02/22/88 : the curves are transformed to x-y plane before 
                     processing
          06/09/89 : Modified to copy input construct list and to set the
                     display field to NULL such that part_of_cv will keep
                     the original color, level, etc..
          04/18/93 : Rajiv Agrawal : Fixed a NULL pointer dereferencing problem in 
                     the wrapup part.  (TR119305073)
          07/08/93 : Sudha : Modified for BSprototypes ansification

*/
class implementation GRbspline;

#include "EMS.h"
#include "EMSlogic.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSmsgdef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "grerr.h"
#include "msdef.h"
#include "bsiboolcvlp.h"
#include "emsdef.h"
#include "marptsxfo.h"
#include "maoptsxfo.h"
#include "maidmx.h"
#include "bstst_plan.h"
#include "bsdotp.h"
#include "bsboolcvlps.h"

#define PLA_TOL .00001

extern OMuword OPP_GRcompcurve_class_id, OPP_SKcompcurve_class_id,
               OPP_GAcompcurve_class_id;

from GRcompcurve import EMmakecomp;

IGRlong	EMcvcvboolean(EMmsg,
                      curve_set1,
                      curve_set2,
                      code, 
                      const_args,
                      num,
                      comp_crv_ids)

IGRlong 		        *EMmsg; 
struct GRlc_info        *curve_set1,
                        *curve_set2;
IGRint                  code;
struct GRvg_construct 	*const_args;
IGRint                  *num;
GRobjid                 **comp_crv_ids;

{
  IGRlong                  msg, rot_one, stat_OM;
  OMuint                   num_cvsa, num_cvsb;
  IGRboolean               orient, orta, ortb;
  IGRboolean               status, is_planar;
  IGRint                   i, j, list_count, cwccw;
  OMuint                   obj_count;
  IGRdouble                module_mat[4][4], xmat[4][4], invxmat[4][4];
  IGRdouble                bas_tol;
  IGRdouble                t_lpar, t_hpar;
  IGRdouble                pla_norm[3], plb_norm[3];
  IGRdouble                pnt[3];
  IGRdouble                dot_prod;
  extern   IGRdouble       fabs();
  IGRshort                 modmat_type, xmat_type, invxmat_type;
  GRobjid                  *crv_id;
  GRobjid                  pcrv_id;			    
  struct GRvg_construct    *const_list_p, construct_list;
  struct GRparms           lpar, mpar, hpar;        	   
  struct GRid              tcrv_id;
  struct GRlc_info         *list;
  struct GRmd_env          *my_env;
  struct BSloop            **loops = NULL;
  struct IGRbsp_curve      **crvs_a, **crvs_b;
  struct IGRbsp_curve      *cc_crva, *cc_crvb;
  OMuword                  class_id;
  OM_S_CHANSELECT          to_comps;
  OM_S_OBJECT_LINKAGE      *cc_curves_a, *cc_curves_b;

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  list = NULL;
  crv_id = NULL;
  crvs_a = NULL;
  crvs_b = NULL;
  cc_curves_a = NULL;
  cc_curves_b = NULL;
  const_list_p = &construct_list;     /* rlw 06/09/89 */
  construct_list = *const_args;
  construct_list.display = NULL;
  BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);

  stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = om$get_classid(objid = curve_set1->located_obj.objid,
                           osnum = curve_set1->located_obj.osnum,
                           p_classid = &class_id);
  if (! (1 & stat_OM)) goto wrapup;

  if ((class_id == OPP_GRcompcurve_class_id) ||
      (class_id == OPP_GAcompcurve_class_id) ||
      (class_id == OPP_SKcompcurve_class_id))
   {
    stat_OM = om$get_channel_count(objid = curve_set1->located_obj.objid,
                                   osnum = curve_set1->located_obj.osnum,
                                   p_chanselect = &to_comps,
                                   count = &num_cvsa);
    if (! (1 & stat_OM)) goto wrapup;

    cc_curves_a = (OM_S_OBJECT_LINKAGE *) om$malloc(size = num_cvsa *
                                        sizeof(OM_S_OBJECT_LINKAGE));

    crvs_a = (struct IGRbsp_curve **) om$malloc(size = (OMuint) num_cvsa *
                                  sizeof(IGRchar *));

    EMerr_hndlr(! cc_curves_a || ! crvs_a, *EMmsg, EMS_E_NoDynamicMemory,
                wrapup);

    stat_OM = om$get_channel_objects(objid=curve_set1->located_obj.objid,
                                     osnum= curve_set1->located_obj.osnum,
                                     p_chanselect = &to_comps,
                                     list = cc_curves_a,
                                     size = num_cvsa,
                                     count = &obj_count);
    if (! (1 & stat_OM)) goto wrapup;

    status = EFget_composite_info(&msg, num_cvsa, cc_curves_a, curve_set1,
                                  crvs_a, &cc_crva);
    EMerr_hndlr(! status || ! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

    BStst_plan(cc_crva->num_poles, cc_crva->poles, cc_crva->weights,
               &is_planar, pla_norm, &msg);
    EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
    for (j=0; j<3; j++)
     {
      pnt[j] = (! cc_crva->rational) ? cc_crva->poles[j] :
                             cc_crva->poles[j] / cc_crva->weights[0];
     }
   }
  else
   {
    num_cvsa = 1;
    crvs_a = (struct IGRbsp_curve **) om$malloc(size = num_cvsa *
                                  sizeof(struct IGRbsp_curve *));
    stat_OM = EMget_the_geometry(curve_set1,
                                 TRUE,
                                 NULL,
                                 FALSE,
                                 NULL_OBJID,
                                 &crvs_a[0],
                                 &msg);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

    BStst_plan(crvs_a[0]->num_poles, crvs_a[0]->poles, crvs_a[0]->weights,
               &is_planar, pla_norm, &msg);
    EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    for (j=0; j<3; j++)
     {
      pnt[j] = (! crvs_a[0]->rational) ? crvs_a[0]->poles[j] :
                             crvs_a[0]->poles[j] / crvs_a[0]->weights[0];
     }
   }

  stat_OM = om$get_classid(objid = curve_set2->located_obj.objid,
                           osnum = curve_set2->located_obj.osnum,
                           p_classid = &class_id);
  if (! (1 & stat_OM)) goto wrapup;

  if ((class_id == OPP_GRcompcurve_class_id) ||
      (class_id == OPP_GAcompcurve_class_id) ||
      (class_id == OPP_SKcompcurve_class_id))
   {
    stat_OM = om$get_channel_count(objid = curve_set2->located_obj.objid,
                                   osnum = curve_set2->located_obj.osnum,
                                   p_chanselect = &to_comps,
                                   count = &num_cvsb);
    if (! (1 & stat_OM)) goto wrapup;

    cc_curves_b = (OM_S_OBJECT_LINKAGE *) om$malloc(size = num_cvsb *
                                        sizeof(OM_S_OBJECT_LINKAGE));

    crvs_b = (struct IGRbsp_curve **) om$malloc(size = (OMuint) num_cvsb *
                                  sizeof(IGRchar *));

    EMerr_hndlr(! cc_curves_b || ! crvs_b, *EMmsg, EMS_E_NoDynamicMemory,
                wrapup);

    stat_OM = om$get_channel_objects(objid=curve_set2->located_obj.objid,
                                     osnum =curve_set2->located_obj.osnum,
                                     p_chanselect = &to_comps,
                                     list = cc_curves_b,
                                     size = num_cvsb,
                                     count = &obj_count);
    if (! (1 & stat_OM)) goto wrapup;

    status = EFget_composite_info(&msg, num_cvsb, cc_curves_b, curve_set2,
                                  crvs_b, &cc_crvb);
    EMerr_hndlr(! status || ! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);

    BStst_plan(cc_crvb->num_poles, cc_crvb->poles, cc_crvb->weights,
               &is_planar, plb_norm, &msg);
    EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   }
  else
   {
    num_cvsb = 1;
    crvs_b = (struct IGRbsp_curve **) om$malloc(size = num_cvsb *
                                  sizeof(struct IGRbsp_curve *));
    stat_OM = EMget_the_geometry(curve_set2,
                                 TRUE,
                                 NULL,
                                 FALSE,
                                 NULL_OBJID,
                                 &crvs_b[0],
                                 &msg);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

    BStst_plan(crvs_b[0]->num_poles, crvs_b[0]->poles, crvs_b[0]->weights,
               &is_planar, plb_norm, &msg);
    EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   }

  /* Check for co-planarity of the curves */

  dot_prod = BSdotp(&msg, pla_norm, plb_norm);
   
  if ((fabs(dot_prod) < 1-PLA_TOL) || (fabs(dot_prod) > 1+PLA_TOL))
   {
    *EMmsg = EMS_I_CvsNonCoplanar;
    goto wrapup;
   }

  /* Transform the curves to x-y plane before processing */

  status = MAidmx (&msg, (IGRdouble *)module_mat);
  modmat_type = MAIDMX;

  EMtoplnxform (&msg, pnt, pla_norm, &modmat_type, module_mat,
                &xmat_type, xmat, &invxmat_type, invxmat, &bas_tol);
  if (! (1 & msg)) goto wrapup;

  for (i=0; i<num_cvsa; i++)
   {
    if (crvs_a[i]->rational)
     status = MArptsxform(&msg, &crvs_a[i]->num_poles,
                          &crvs_a[i]->rational,
                          crvs_a[i]->weights, (IGRdouble *)xmat, crvs_a[i]->poles,
                          crvs_a[i]->poles);
    else
     status = MAoptsxform(&msg, &crvs_a[i]->num_poles, &xmat_type,
                          (IGRdouble *)xmat, crvs_a[i]->poles, crvs_a[i]->poles);
    EMerr_hndlr(! status || ! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   }

  for (i=0; i<num_cvsb; i++)
   {
    if (crvs_b[i]->rational)
     status = MArptsxform(&msg, &crvs_b[i]->num_poles,
                          &crvs_b[i]->rational,
                          crvs_b[i]->weights, (IGRdouble *)xmat, crvs_b[i]->poles,
                          crvs_b[i]->poles);
    else
     status = MAoptsxform(&msg, &crvs_b[i]->num_poles, &xmat_type,
                          (IGRdouble *)xmat, crvs_b[i]->poles, crvs_b[i]->poles);
    EMerr_hndlr(! status || ! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
   }
 
  if (num_cvsa == 1)
   {
    EFcwccw(&msg, crvs_a[0], &cwccw);
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   }
  else
   {
    if (cc_crva->rational)
     status = MArptsxform(&msg, &cc_crva->num_poles,
                          &cc_crva->rational,
                          cc_crva->weights, (IGRdouble *)xmat, cc_crva->poles,
                          cc_crva->poles);
    else
     status = MAoptsxform(&msg, &cc_crva->num_poles, &xmat_type,
                          (IGRdouble *)xmat, cc_crva->poles, cc_crva->poles);
    EMerr_hndlr(! status || ! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
    EFcwccw(&msg, cc_crva, &cwccw);
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   }
  orta = (cwccw == 1) ? FALSE : TRUE;

  if (num_cvsb == 1)
   {
    EFcwccw(&msg, crvs_b[0], &cwccw);
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   }
  else
   {
    if (cc_crvb->rational)
     status = MArptsxform(&msg, &cc_crvb->num_poles,
                          &cc_crvb->rational,
                          cc_crvb->weights, (IGRdouble *)xmat, cc_crvb->poles,
                          cc_crvb->poles);
    else
     status = MAoptsxform(&msg, &cc_crvb->num_poles, &xmat_type,
                          (IGRdouble *)xmat, cc_crvb->poles, cc_crvb->poles);
    EMerr_hndlr(! status || ! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
    EFcwccw(&msg, cc_crvb, &cwccw);
    EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_Fail, wrapup);
   }
  ortb = (cwccw == 1) ? FALSE : TRUE;

  BSboolcvlps(num_cvsa, crvs_a, orta, num_cvsb, crvs_b,
              ortb, code, num, &loops, &orient, &msg);
  
  if (! (*num))
   {
    *EMmsg = EMS_I_NoIntersection;
    goto wrapup;
   }
  EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  crv_id = (GRobjid *) om$malloc(size = *num * sizeof(GRobjid));
  EMerr_hndlr(! crv_id, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

  *comp_crv_ids = crv_id;
  const_list_p->msg = &msg;
  const_list_p->newflag = FALSE;

  for (i = 0; i < *num ; i++)
     {
      list_count = 0;

      list = (struct GRlc_info *) om$malloc(size = loops[i][0].num *
                                          sizeof(struct GRlc_info));
      EMerr_hndlr(! list, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

      for (j = 0; j < loops[i][0].num; ++j)
       {
        if (loops[i][0].lpind[j][0] == 0)
         {
          my_env = &curve_set1->module_info;
          if (num_cvsa == 1)
           {
            tcrv_id.objid = curve_set1->located_obj.objid;
            tcrv_id.osnum = curve_set1->located_obj.osnum;
           }
          else
           {
            tcrv_id.objid = cc_curves_a[loops[i][0].lpind[j][1]].S_objid;
            tcrv_id.osnum = cc_curves_a[loops[i][0].lpind[j][1]].osnum;
           }
         }
        else
         {
          my_env = &curve_set2->module_info;
          if (num_cvsb == 1)
           {
            tcrv_id.objid = curve_set2->located_obj.objid;
            tcrv_id.osnum = curve_set2->located_obj.osnum;
           }
          else
           {
            tcrv_id.objid = cc_curves_b[loops[i][0].lpind[j][1]].S_objid;
            tcrv_id.osnum = cc_curves_b[loops[i][0].lpind[j][1]].osnum;
           }
         }
  
        if (loops[i][0].par[j][0] <= loops[i][0].par[j][1])
         {
          lpar.u = loops[i][0].par[j][0]; 
          hpar.u = loops[i][0].par[j][1];
         }
        else
         {
          hpar.u = loops[i][0].par[j][0]; 
          lpar.u = loops[i][0].par[j][1];
         }
        mpar.u = lpar.u + (hpar.u - lpar.u)/2.0;
    
        if ((loops[i][0].lpind[j][0] == loops[i][0].lpind[j+1][0]) &&
            (loops[i][0].lpind[j][1] == loops[i][0].lpind[j+1][1]) &&
            (j != loops[i][0].num - 1))
         {
          if (loops[i][0].par[j+1][0] <= loops[i][0].par[j+1][1])
           {
            t_lpar = loops[i][0].par[j+1][0]; 
            t_hpar = loops[i][0].par[j+1][1];
           }
          else
           {
            t_hpar = loops[i][0].par[j+1][0]; 
            t_lpar = loops[i][0].par[j+1][1];
           }
          
          if ((lpar.u == 0) && (t_hpar == 1))
           {
            lpar.u = hpar.u;
            hpar.u = t_lpar;
           }
          else
          if ((hpar.u == 1) && (t_lpar == 0))
           {
            hpar.u = lpar.u;
            lpar.u = t_hpar;
           }
          mpar.u = 1;
          j++;
         }   
        
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRbspline.EMpartofcv(&msg,
                                &my_env->md_env.matrix_type,
		                        my_env->md_env.matrix,
		                        const_list_p,	   	   
		                        &lpar,        		  
		                        &mpar,           
		                        &hpar,			    
		                        &pcrv_id),
	    	              senderid = NULL_OBJID,
		                  targetid = tcrv_id.objid,
		                  targetos = tcrv_id.osnum );
         EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_CurveError,
                      wrapup);

         list[list_count].located_obj.objid = pcrv_id;
         list[list_count].located_obj.osnum =  tcrv_id.osnum;
         list[list_count].module_info = curve_set1->module_info;
         list_count++;
     }

      /* make composite curve out of these segments (parts of curve) */

      /* create composite curve shell */

      stat_OM = om$construct(classid = OPP_GRcompcurve_class_id,
                             osnum = curve_set1->located_obj.osnum,
                             p_objid = &crv_id[i],
                             msg = message GRgraphics.GRconstruct(
                                   const_list_p) );
      EMerr_hndlr(! (1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

      stat_OM = om$send(mode = OM_e_wrt_object,
                        msg = message GRcompcurve.EMmakecomp(
                              &msg,		
	                          &curve_set1->module_info,
	                          list_count,
	                          list,
                              &rot_one),
	                    senderid = NULL_OBJID,
	                    targetid = crv_id[i],
	                    targetos = curve_set1->located_obj.osnum);
      EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_CurveError,
      wrapup);

      if (list) om$dealloc(ptr = list);
  }

wrapup:
    if (crvs_a) 
    {
      for (i=0; i<num_cvsa; i++)
      {
        if (crvs_a[i]) om$dealloc(ptr = crvs_a[i]);
        crvs_a[i] = NULL;
      }
      om$dealloc(ptr = crvs_a);
    }
    if (crvs_b) 
    {
      for (i=0; i<num_cvsb; i++)
      {
        if (crvs_b[i]) om$dealloc(ptr = crvs_b[i]);
        crvs_b[i] = NULL;
      }
      om$dealloc(ptr = crvs_b);
    }
     
    if (cc_curves_a) om$dealloc(ptr = cc_curves_a);
    if (cc_curves_b) om$dealloc(ptr = cc_curves_b);

    return(stat_OM);
}

end implementation GRbspline;
