/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgencompsf;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsdef.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsicmpcvoff.h"
#include "EMSprop.h"
#include "EMSanaltypes.h"
#include "emsedgedef.h"
#include "bsptcvgen.h"
#include "bsfreecv.h"
#include "bsgeom_cvsf.h"
#include <stdio.h>

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMSproject_class_id;

extern void     EFget_analytic_info();
extern IGRboolean WANT_POST220_BEHAVIOR;

from EMSsubbs  import EMdrafted_surface;
from EMSedge   import EMconnect_edges;




method EMproject_with_draft(
       IGRlong                  *EMmsg;
       GRobjid                  crv_id;
       IGRboolean               is_uniform;
       IGRdouble                *ang_dis;
       IGRvector                draft_vec;
       IGRboolean               fillet;
       IGRboolean               right_side;
       IGRint                   *off_code;
       struct GRvg_construct    *const_list)




/*
Description

    This method creates drafted composite surface from a composite
    curve. Each of the components of the composite curve may be
    drafted with a different draft angle (non-uniform draft).

Return values 

    EMS_S_Success 	if all is well.

    EMS_I_InvalidArg 	if invalid non-uniform codes are input.

    EMS_I_BSerror	if math call to offset fails.

Change history:

    RV      12/31/87     Creation
    RC      03/22/88     Modified code and arguments to 
                         accomodate changes in processing flow. 
    RC      01/17/90     Intialized some variables.
    DLB     09/16/91     Put fillet sfs on end of comps chan.
    Jack    21-Jan-93    Modified to call EFget_analytic_info() for analytic
                         surface creation
    Jack    10-Jun-93    Added a condition for doing the above call, namely
                         if !WANT_POST220_BEHAVIOR.
    Sudha   06/21/93     Modified to handle BSprototype ansification
    SM      16-Sept-93   Problem - When a circular arc is part of a comp
                         curve we can't always assume that it would give
                         rise to a partial cone as the drafted surface.
                         In cases where the components of the comp.
                         curve get trimmed after offsetting,  the sweep angles
                         of the 2 circular arcs (original and the offset)
                         may not be the same. In such cases the resulting
                         surface should not be a partial cone.
                         Solution - For lack of information about curve
                         trimming during comp. curve offset,  went for the
                         brute force method of validating the surface geometry
                         for partial cones. If invalid change class.
    Hari    06/21/95     Allocating proper memory space for res_crvs and
                         table, passed as an argument to EFdraftcv().
                         Fix for TR#119525514.
*/
{
 struct IGRbsp_curve **crvs = NULL, **res_crvs = NULL, *old_crv=NULL, pt_crv, *send_crv=NULL;
 struct GRprops      geom_prop;
 struct GRid         my_GRid;
 OM_S_CHANSELECT     to_comps;
 IGRdouble           pt_poles[6], pt_knots[4],
                     draft_angle;
 IGRpoint            junction_pt;
 IGRlong             OM_stat;
IGRlong   mthd_stat;
IGRlong   rc, crv_size, aft_gap=0, bef_gap=0;
 IGRlong             EFget_the_edge_type_for_an_object();
 OMuint              num_crvs = 0;
 IGRint              ix, jx, res_num_crvs = 0, 
                     *table = NULL, dft_inx=0, maxint=OM_K_MAXINT;
 GRobjid             comp_id, dsf_id, dsf_edges[4], save_edge, prev_edge;
 OMuword             comp_os;
 IGRboolean          dft_sf;
 IGRuchar            curve_type;

 void                EFdraftcv();
 OMuword             new_classid=0;
 OM_S_OBJID          new_objid=NULL_OBJID;
 IGRint              info_bits=0;
 IGRboolean          call_EFget_analytic_info = FALSE; 
 IGRboolean          pcone = FALSE;
 IGRboolean          sfofproj = FALSE;
 struct IGRbsp_surface *dsf_gm = NULL;

 OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 OM_stat = om$get_channel_count(objid = crv_id,
                                p_chanselect = &to_comps,
                                count = &num_crvs);
 EMerr_hndlr(!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

 crvs = (struct IGRbsp_curve **) malloc(num_crvs * sizeof(char *));
 EMerr_hndlr(!crvs,*EMmsg,EMS_E_NoDynamicMemory,wrapup);   

 for (ix = 0; ix < num_crvs; ix++)
  crvs[ix] = NULL;

 res_crvs = (struct IGRbsp_curve **) malloc((2*num_crvs +1) * sizeof(char *));
 EMerr_hndlr(!res_crvs,*EMmsg,EMS_E_NoDynamicMemory,wrapup);   

 for (ix = 0; ix < (2 * num_crvs); ix++)
  res_crvs[ix] = NULL;

 table = (IGRint *) malloc(( 2*num_crvs +1) * sizeof(IGRint));
 EMerr_hndlr(!table,*EMmsg,EMS_E_NoDynamicMemory,wrapup);   

 for (ix = 0; ix < num_crvs; ix++)
 {
   OM_stat = om$send (msg = message GRvg.GRgetsize(&mthd_stat,
                       &const_list->env_info->md_env.matrix_type,
                        const_list->env_info->md_env.matrix,
                       &crv_size),
                      senderid = crv_id,
                      p_chanselect = &to_comps, from = ix, to = ix);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

   crvs[ix] = (struct IGRbsp_curve *) om$malloc (size = crv_size);
   EMerr_hndlr (!crvs[ix], *EMmsg, EMS_E_NoDynamicMemory,wrapup);

   OM_stat = om$send(msg = message GRvg.GRgetgeom (&mthd_stat,
                      &const_list->env_info->md_env.matrix_type,
                       const_list->env_info->md_env.matrix,
                       (IGRchar *)crvs[ix]),
                     senderid = crv_id,
                     p_chanselect = &to_comps, from = ix, to = ix);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

 } /* for (ix = 0; ix < num_crvs; ix++) */

 OM_stat = om$send(msg = message GRvg.GRgeomprops(&mthd_stat,
                    &const_list->env_info->md_env.matrix_type,
                     const_list->env_info->md_env.matrix,
                    &geom_prop),
                   targetid = crv_id);				
  EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  /*
   * Draft the composite curve
   */

  EFdraftcv(EMmsg, num_crvs, crvs, right_side, draft_vec, is_uniform, 
             ang_dis, off_code, geom_prop.phy_closed,
             fillet, &res_num_crvs, res_crvs, table);
  if (*EMmsg == EMS_I_InvalidArg || *EMmsg == EMS_I_BSerror)
	 goto wrapup;
  EMerr_hndlr(!(1&*EMmsg) || !res_num_crvs,*EMmsg,EMS_E_Fail,wrapup);

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  /*
   * Construct drafted surfaces and attach it to me
   */

  pt_crv.poles = pt_poles;  
  pt_crv.weights = NULL;  
  pt_crv.knots = pt_knots;  
  pt_crv.bdrys = NULL;

  for(ix = 0; ix < res_num_crvs; ix++)
  {
    sfofproj  = FALSE;
    pcone = FALSE;
    call_EFget_analytic_info = FALSE;
    info_bits = 0;

   /*
    * Since the arrays passed back from EFdraftcv() do not have
    * to be the same size as the passed in arrays, such as ang_dis.
    * The table indices will resolve the differences.  Here, I find
    * the indexes into the original compcv for the previous and next
    * segments.
    */
    aft_gap = (ix+1 == res_num_crvs ? 0 : table[ix+1]);
    bef_gap = (ix == 0 ? table[res_num_crvs-1] : table[ix-1]);


    /*
     * If the resultant curve is result of fillet,
     * create a point curve to construct a surface
     * between the point curve and the resultant curve.
     */
    if (table[ix] < 0)
    {
      EMerr_hndlr (aft_gap < 0 || bef_gap < 0, *EMmsg, EMS_E_Fail, wrapup);

      for (jx = 0; jx < 3; jx++)
      {
        junction_pt[jx] = crvs[aft_gap]->poles[jx];
        if (crvs[aft_gap]->rational) 
           junction_pt[jx] /= crvs[aft_gap]->weights[0];

      } /* for (jx = 0; jx < 3; jx++) */

      BSptcvgen(junction_pt, 2, FALSE, &pt_crv, &rc);
      EMerr_hndlr(rc != BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

      old_crv  = &pt_crv;
      dft_sf   = FALSE;
      /*
       * Construct a partial cone if uniform or,
       * if the previous and next segments are normal
       * drafts with the same draft angle. Don't call
       * EFget_analytic_info().
       */
      if(is_uniform)
         pcone = TRUE;
      else  
       {
        if((off_code[bef_gap] == BSCONSTOFF) && 
           (off_code[aft_gap] == BSCONSTOFF) && 
           (ang_dis[bef_gap] == ang_dis[aft_gap]))
          pcone = TRUE;  
       }          

    } /* if (table[ix] < 0) */
    else
    {
      /* no point curve created */
      old_crv = crvs[table[ix]];
      send_crv = crvs[table[ix]];
      dft_sf = TRUE;    
/*
 * Modified this as for uniform draft, draft angle is only contained in
 * the first array location.
 * This was causing incorrect drafts to occur and resulting in partial
 * cylinder when we ought to be getting partial cones.
 * Ref TR:
 * pp 11/2/93 
 */

      if (is_uniform)
         draft_angle = ang_dis[0];
      else
        draft_angle = ang_dis[table[ix]]; 
                    /* Note: the angles in ang_dis were changed to offsets
                     * in the call to EFdraftcv().  That's ok for us since
                     * we just need to know if it is non-zero.
                     */
      if (is_uniform)
       call_EFget_analytic_info = TRUE;
      else
        /* don't call EFget_anal if prev and next angles are different */
        if((off_code[table[ix]] == BSCONSTOFF ) &&
           (bef_gap >= 0) &&
           (aft_gap >= 0) &&
           (off_code[bef_gap] == BSCONSTOFF) && 
           (off_code[aft_gap] == BSCONSTOFF) && 
           (ang_dis[bef_gap] == ang_dis[aft_gap]))
             call_EFget_analytic_info = TRUE;
        else if(off_code[table[ix]] == BSPRESERVCVSHP)
               {
                if((bef_gap >= 0) &&
                   (aft_gap >= 0) &&
                   (off_code[bef_gap] == BSCONSTOFF) && 
                   (off_code[aft_gap] == BSCONSTOFF) && 
                   (ang_dis[bef_gap] == ang_dis[aft_gap]))
                    { /* math does provide special processing for EMSproject (surface of proj). 
                       * may be able to make more cases EMSproject, for now, just this one. 
                       */
                     sfofproj = TRUE;
                     call_EFget_analytic_info = FALSE;
                    }
                else call_EFget_analytic_info = FALSE; 
               }
             else
                call_EFget_analytic_info = FALSE;

      /*
       * get the edge type for this segment
       */    
      if( call_EFget_analytic_info )
       {
        OM_stat = om$get_objid_at_index (objid = crv_id,
                                         p_chanselect = &to_comps, index = table[ix],
                                         objidaddr = &comp_id,
                                         osnumaddr = &comp_os);
        EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

        rc = EFget_the_edge_type_for_an_object (comp_id, comp_os,
                                                NULL, &curve_type);
        EMerr_hndlr (!(1&rc),*EMmsg, EMS_E_Fail,wrapup);
       }
      

    }


  /*
   * if this is not a post-220 object, we just want
   * to create a general surface, so set flags to make
   * that happen.
   */
  if ( !WANT_POST220_BEHAVIOR )
   {
    call_EFget_analytic_info = 0;
    pcone = 0;
    sfofproj = 0;
   }


  if(call_EFget_analytic_info)
   {
    /*
     * Let's try and found out if any analytic surface will be 
     * created by creating a ruled surface from the input curve.
     * Use the generated res_crv if we are drafting a vertex
     * with filleting which will give a partial cone as long as
     * the draft is ortho.  Obviously can't send the point curve.
     */
    info_bits = 0;  /* no input bits set */
    
    EFget_analytic_info(&mthd_stat,               /* EMmsg */
                         draft_angle,             /* draft_angle */
                         NULL,                    /* curve_id */
                         NULL,                    /* curve_env */ 
                         send_crv,                /* curve_geom */
                         curve_type,              /* curve_type */
                         draft_vec,               /* axis */
                         0.0,                     /* rev_angle */
                         OM_Gw_current_OS,        /* const_os */
                        &new_classid,           /* new_classid */
                        &new_objid,             /* new_obj */
                        &info_bits);            /* info_bits */
    EMerr_hndlr(!(1&mthd_stat),*EMmsg, EMS_E_SurfaceError,wrapup);      
   }
  else new_objid = NULL_OBJID;
  

make_surf:   
    if(new_objid == NULL_OBJID)
     {
      if(pcone)
       {
        OM_stat = om$construct(classid =  OPP_EMSpcone_class_id,
                             p_objid = &dsf_id);
        EMerr_hndlr(!(1&OM_stat),*EMmsg, EMS_E_SurfaceError,wrapup);
       }
      else if(sfofproj)
       { 
        OM_stat = om$construct(classid =  OPP_EMSproject_class_id,
                               p_objid = &dsf_id);
        EMerr_hndlr(!(1&OM_stat),*EMmsg, EMS_E_SurfaceError,wrapup);
       }
      else
       {
        /*
         * Construct and define the general surface if there was
         * no analytic surface possible.
        */
        OM_stat = om$construct(classid =  OPP_EMSgenbs_class_id,
                               p_objid = &dsf_id);
        EMerr_hndlr(!(1&OM_stat),*EMmsg, EMS_E_SurfaceError,wrapup);
       }
     }
    else
      dsf_id = new_objid;

    /*
     * Note: draft_angle is not used if you pass in a both curves that will
     * make up the ruled surface, as we do here.
     */
    OM_stat = om$send ( msg = message EMSsubbs.EMdrafted_surface (
                                                      &mthd_stat, 
                                                       old_crv, 
                                                       NULL, 
                                                       res_crvs[ix], 
                                                       draft_vec, 
                                                       draft_angle, 
                                                       right_side, 
                                                       fillet,
                                                       curve_type, 
                                                       FALSE, 
                                                      &dsf_id, 
                                                       const_list),
                                targetid = dsf_id);

    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_SurfaceError,wrapup);

    /* Partial cone validation.
       SM 16-Sept-93.
    */
    if(WANT_POST220_BEHAVIOR && EFisAncestryValid(&mthd_stat, dsf_id, 
       OM_Gw_current_OS, OPP_EMSpcone_class_id, TRUE))
     {
      struct BSgeom_bsp_surf junk;
      extern void EFinit_geom_surface();
      struct GRid more_junk;
      BSrc   some_more_junk;

      /* Get surface geom.
      */
      if(dsf_gm) om$dealloc(ptr = dsf_gm);
      dsf_gm = NULL;
     
      more_junk.objid = dsf_id;
      more_junk.osnum = OM_Gw_current_OS;
      OM_stat = EMgetvggeom(&mthd_stat, 
                            &const_list->env_info->md_env.matrix_type, 
                            const_list->env_info->md_env.matrix, &more_junk, 
                            &dsf_gm, NULL);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_SurfaceError,wrapup);

      /* Initialize BS geometric structure.
      */
      junk.sfgen_cv = NULL;
      EFinit_geom_surface(&mthd_stat, dsf_gm, dsf_id, OM_Gw_current_OS, &junk);
      EMerr_hndlr(!(1&mthd_stat),*EMmsg, EMS_E_SurfaceError,wrapup);

      (void) BSsftgeomsf(&junk, FALSE, BSPART_CONE, &some_more_junk);
      EMerr_hndlr(some_more_junk!=BSSUCC,*EMmsg, EMS_E_SurfaceError,wrapup);
      if(junk.type != BSPART_CONE)
       {
        OM_stat = om$send(msg = message GRgraphics.GRdelete(&mthd_stat, 
                  const_list->env_info), targetid = dsf_id);
        EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg, EMS_E_SurfaceError,wrapup);
        dsf_id = NULL_OBJID;
        new_objid = NULL_OBJID;
        call_EFget_analytic_info = FALSE;
        pcone = FALSE;
        sfofproj = FALSE;
        goto make_surf;
       }
     }

    OM_stat = om$send(msg = message EMSsurface.EMmk_nat_bdry(&mthd_stat,
                       &const_list->env_info->md_env, dsf_edges),
                      targetid = dsf_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    if (ix == 0)
    {
      save_edge = dsf_edges[0];
      prev_edge = dsf_edges[2];
    }
    else
    {
       OM_stat = om$send(msg = message EMSedge.EMconnect_edges(&mthd_stat,
                          EMED_REVERSE_CONNECT, FALSE, dsf_edges[0],
                          NULL_OBJID, NULL_OBJID, 
                          &const_list->env_info->md_env),
				         targetid = prev_edge);
       EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

       prev_edge = dsf_edges[2];

    } /* else for if (ix == 0) */

    OM_stat = om$send(msg = message GRvg.GRrigidconn(&mthd_stat, 
                       &my_GRid, dft_sf ? (IGRlong *) &dft_inx : 
                       (IGRlong *) &maxint),
                      targetid = dsf_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    if (dft_sf) dft_inx++;

  } /* for(ix = 0; ix < res_num_crvs; ix++) */

  if (geom_prop.phy_closed && res_num_crvs > 1)
  {
	OM_stat = om$send(msg = message EMSedge.EMconnect_edges(&mthd_stat,
                       EMED_REVERSE_CONNECT, FALSE, save_edge,
                       NULL_OBJID, NULL_OBJID, 
                       &const_list->env_info->md_env),
                      targetid = prev_edge);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

  } /* if (closed && *res_num_crvs > 1) */

 wrapup:

  for(ix = 0; ix < num_crvs; ix++)
     if (crvs[ix]) om$dealloc(ptr = crvs[ix]);

  for(ix = 0; ix < res_num_crvs; ix++)
    if (res_crvs[ix]) BSfreecv (&rc, res_crvs[ix]);

  if (table) om$dealloc(ptr = table);
  if (crvs) om$dealloc (ptr = crvs);
  if (res_crvs) om$dealloc (ptr = res_crvs);
  if (dsf_gm) om$dealloc(ptr = dsf_gm);
if (!(1& *EMmsg & OM_stat) || *EMmsg == EMS_I_BSerror ||
			      *EMmsg == EMS_I_InvalidArg)
{
  OM_stat = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRdelete(EMmsg, 
                      const_list->env_info),
               senderid = my_id,
               targetid = my_id);

  *EMmsg = EMS_I_InvalidArg;
 }

  EMWRAPUP(*EMmsg, OM_stat, "In EMSgencompsf.EMproject_with_draft")
  return (OM_stat);

}

end  implementation EMSgencompsf;
