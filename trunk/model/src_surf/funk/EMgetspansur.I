/*
 DESCRIPTION
    This function takes in a curve in the dataselect format (however currently
  only the object option is supported) and a surface (simple or composite)
  and returns the id's of the surfaces the curve is spanning through. The
  function assumes that the curve is lying on the surface. Variable "spancount"
  returns the number of surfaces. 

  LIMITATION
     This function in its present state fails to give the result when the
  curve happens to be the "common" between two adjacent surfaces which may
  be part of composite surface. 

 HISTORY
 
  Rustagi : ???? : Creation

 */

class implementation Root;

#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
%safe
#include <math.h>
#include "bsprepcirc.h"
#include "bsparameters.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bscvarrevt.h"
#include "bsbxint.h"
#include "bsbx2.h"
%endsafe

#define EDGE_DISTINCT_VALUE 5.0 /* This value is decided on the basis that
                                   for a non-degenerate surface, the non-
                                   intersecting edges should atleast differ 
                                   by 10 times the chord hight tolerance
                                   value. */

/* externs */

extern GRclassid OPP_GRcompcurve_class_id;
extern GRclassid OPP_EMScompsurf_class_id;

/* imports */

from EMSsubbs import EMpartolbasis, GRptproject;
from EMSsurface import EMcrvsrfint;
from GRcurve import GRendpts;
from GRvg import GRgetrang, GRgetsize, GRgetgeom, EMptatpr;
from EMSloopset import EMpt_location;

struct GRid *EMoutput_spanned_surfaces(msg,
                                  cv_geom,
                                  cv_in,
                                  modenv_cv,
                                  opts,
                                  surf_in,
                                  modenv_sf,
                                  spancount)
IGRlong *msg;
struct IGRbsp_curve *cv_geom;
struct GRid *cv_in;
struct GRmd_env *modenv_cv, *modenv_sf;
IGRlong opts;
struct GRid *surf_in;
IGRint *spancount;
{
 IGRboolean is_compsf, is_compcv, surface_existing, world, is_box_int;
 IGRboolean is_good_sample_pt;
 IGRlong sts, msg_loc, num_bytes, num_pt, pnt_slots;
 GRobjid loopset_id;
 OMuword classid;
 OM_S_CHANSELECT to_children, to_my_loopset;
 GRrange range_sf, range_cv;
 struct GRid  *surf_out;
 OMuint count, numb_sf, numb_cv, sfcount, cvcount;
 IGRpoint point_start, point_stop, point, proj_pt;
 struct GRparms proj_parms;
 IGRint type, num_span_surf, i, j, k, newsize, N;
 IGRvector vector, unit_vec;
 BSrc rc;
 struct EMSpartolbasis partolb;
 struct IGRbsp_curve **geomcv;
 struct GRparms *srf_pnt_inters;
 struct EMSptloc_info location;
 IGRdouble length, par, xyz_chd_ht, check_val, uvpt[2], bastol;
 IGRpoint pts[1][2];
 struct IGRbsp_curve circle;
 OM_S_OBJECT_LINKAGE ownlist, *sflist=NULL, *cvlist=NULL;
 
/*
 * Initialisation
 */
 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 is_compsf = FALSE;
 is_compcv = FALSE;
 num_span_surf = 0;
 world = TRUE;
 geomcv = NULL;
 length = 1.0;
 location.options = EMS_PTLOC_ACTLOOP | EMS_PTLOC_CLOSEST_EDGE;
 num_pt = pnt_slots = 0;
 srf_pnt_inters = NULL;
 surf_out = NULL;

 sts = BSEXTRACTPAR (&rc, BSTOLCHRDHT, xyz_chd_ht);
 sts = BSEXTRACTPAR (&rc, BSTOLBASIS, bastol);
  
 sts = EMmake_chanselect(EMSsubbs_to_loopset, &to_my_loopset);
 if(EMSmsgReport(sts, "EMspansurf: chan select", FALSE)) goto ret_end;
 sts = EMmake_chanselect (GRcmpowner_to_components, &to_children);
 if(EMSmsgReport(sts, "EMspansurf: chan select", FALSE)) goto ret_end;
 /*
  * Processing the surface data.
  */
 sts = om$get_classid(objid = surf_in->objid,
                      osnum = surf_in->osnum,
                      p_classid = &classid);
 EMerr_hndlr(EMSerror(sts), sts, EMS_E_OMerror, ret_end);
 if (om$is_ancestry_valid(subclassid = classid,
               superclassid = OPP_EMScompsurf_class_id) IS OM_S_SUCCESS)
 {
 is_compsf = TRUE;
 sts = om$get_channel_count(objid = surf_in->objid,
                   osnum = surf_in->osnum,
                   p_chanselect = &to_children,
                   count = &numb_sf);
 if(EMSmsgReport(sts, "EMspansurf: chanobjs", FALSE)) goto ret_end;
 sflist = (OM_S_OBJECT_LINKAGE *)  alloca (numb_sf *
                                 sizeof(OM_S_OBJECT_LINKAGE));
 sts = om$get_channel_objects(objid = surf_in->objid,
                              osnum = surf_in->osnum,
                              p_chanselect = &to_children,
                              list = sflist,
                              size = numb_sf,
                              count = &sfcount);
 EMerr_hndlr(!(1&sts) || !sfcount || (numb_sf != sfcount),
                                      *msg, EMS_E_OMerror, ret_end); 
 }
 else
 {
 numb_sf = 1;
 sflist = (OM_S_OBJECT_LINKAGE *)  alloca (
                                   sizeof(OM_S_OBJECT_LINKAGE));
 sflist[0].S_objid = surf_in->objid;
 sflist[0].osnum = surf_in->osnum;
 }
 /*
  * Processing the curve data.
  */ 
 if(!cv_geom)
 {
 sts = om$get_classid(objid = cv_in->objid,
                      osnum = cv_in->osnum,
                      p_classid = &classid);
 EMerr_hndlr(EMSerror(sts), sts, EMS_E_OMerror, ret_end);
 if (om$is_ancestry_valid(subclassid = classid,
                   superclassid = OPP_GRcompcurve_class_id) IS OM_S_SUCCESS)
 {
 is_compcv = TRUE;
 sts = om$get_channel_count(objid = cv_in->objid,
                            osnum = cv_in->osnum,
                            p_chanselect = &to_children,
                            count = &numb_cv);
 if(EMSmsgReport(sts, "EMspansurf: chanobjs", FALSE)) goto ret_end;
 cvlist = (OM_S_OBJECT_LINKAGE *)  alloca (numb_cv *
                                 sizeof(OM_S_OBJECT_LINKAGE));
 sts = om$get_channel_objects(objid = cv_in->objid,
                              osnum = cv_in->osnum,
                              p_chanselect = &to_children,
                              list = cvlist,
                              size = numb_cv,
                              count = &cvcount);
 EMerr_hndlr(!(1&sts) || !cvcount || (numb_cv != cvcount),
                                      *msg, EMS_E_OMerror, ret_end);

 }
 else
 {
 numb_cv = 1;
 cvlist = (OM_S_OBJECT_LINKAGE *)  alloca (
                                        sizeof(OM_S_OBJECT_LINKAGE));
 cvlist[0].S_objid = cv_in->objid;
 cvlist[0].osnum = cv_in->osnum;
 }
/*
 * Allocating the memory for getting the geometry of the component curves
 */
 geomcv = (struct IGRbsp_curve **) om$malloc (size = numb_cv * 
                                           sizeof(struct IGRbsp_curve *));
 EMerr_hndlr(!(geomcv), *msg, EMS_E_NoDynamicMemory, ret_end);
 for(i=0; i<numb_cv; i++)
 {
 geomcv[i] = NULL;
 sts = om$send(msg = message GRvg.GRgetsize(&msg_loc,
                       &(modenv_cv->md_env.matrix_type),
                       modenv_cv->md_env.matrix, &num_bytes),
                   senderid = NULL_OBJID,
                   targetid = cvlist[i].S_objid,
                   targetos = cvlist[i].osnum);
 EMSmsgReport(sts, "EMspansurf :GRvg.GRgetsize", FALSE);
 geomcv[i] = (struct IGRbsp_curve *) om$malloc (size = num_bytes);
 EMerr_hndlr(!(geomcv[i]), *msg, EMS_E_NoDynamicMemory, ret_end);
 sts = om$send(msg = message GRvg.GRgetgeom(&msg_loc,
                       &(modenv_cv->md_env.matrix_type),
                        modenv_cv->md_env.matrix,
                       (IGRchar *)geomcv[i]),
                   senderid = NULL_OBJID,
                   targetid = cvlist[i].S_objid,
                   targetos = cvlist[i].osnum);
 EMSmsgReport(sts, "EMspansurf :GRvg.GRgetgeom", FALSE);
 }
 }
 else
 {
 numb_cv = 1;
 geomcv = (struct IGRbsp_curve **) om$malloc (size = 
                                      sizeof(struct IGRbsp_curve *));
 EMerr_hndlr(!(geomcv), *msg, EMS_E_NoDynamicMemory, ret_end);
 geomcv[0] = (struct IGRbsp_curve *)cv_geom;
 }
 
/*
 * Allocating the memory for the circle.
 */
 num_bytes = BSCIRCLE_NUM_POLES_MAX * sizeof(IGRpoint);
 circle.poles = (IGRdouble *) alloca (num_bytes);
 circle.weights = (IGRdouble *) alloca (num_bytes);
 circle.knots = (IGRdouble *) alloca (BSCIRCLE_NUM_KNOTS_MAX * sizeof(IGRdouble));

 num_span_surf = 0;
 for(i=0; i<numb_sf; i++)
 {
 sts = om$send(msg = message GRvg.GRgetrang(&msg_loc, 
                           &(modenv_sf->md_env.matrix_type),
                           modenv_sf->md_env.matrix, &world, range_sf),
                          senderid = NULL_OBJID,
                          targetid = sflist[i].S_objid,
                          targetos = sflist[i].osnum);
 EMSmsgReport(sts, "EMspansurf:GRvg.GRgetrang", FALSE);
 for(j=0; j<numb_cv; j++)
  {
  par = 0.0;
  while(par <= 1.0)
  { 
  if(geomcv[j]->order IS 2)
   {
   /* Get the end points of the curve */
   N = geomcv[j]->num_poles;
   OM_BLOCK_MOVE(&geomcv[j]->poles[0], point_start, sizeof(IGRpoint));
   OM_BLOCK_MOVE(&geomcv[j]->poles[3 * (N - 1)], point_stop, sizeof(IGRpoint));

/*
   sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                               &(modenv_cv->md_env.matrix_type),
                                modenv_cv->md_env.matrix,
                                point_start, point_stop),
                     senderid = NULL_OBJID,
                     targetid = cvlist[j].S_objid,
                     targetos = cvlist[j].osnum);
   EMSmsgReport(sts, "EMspansurf :GRcurve.GRendpts", FALSE);
*/
   sts = BSmkvec(&rc, vector, point_start, point_stop);
   BSnorvec(&rc, vector);
   }
  else /* the component curve is a higher order curve */
   {
   BScvarrevt(geomcv[j], &par, 1, length, pts, &rc); 
   EMerr_hndlr(rc != BSSUCC, *msg, BSFAIL, ret_end);
   sts = BSmkvec(&rc, vector, &pts[0][0][0], &pts[0][1][0]);
   BSnorvec(&rc, vector);
   }
 /* Constructing a circle at value "par" in a plane whose normal
  * points in the direction of the calculated vector "vector".
  */
  
/*
   sts = om$send(msg = message GRvg.EMptatpr(&msg_loc,
                               &(modenv_cv->md_env.matrix_type), 
                               modenv_cv->md_env.matrix, &par, 1, point),
                     senderid = NULL_OBJID,
                     targetid = cvlist[j].S_objid,
                     targetos = cvlist[j].osnum);
   EMSmsgReport(sts, "EMspansurf : GRvg.EMptatpr", FALSE);
*/
  
   BScveval(geomcv[j], par, (IGRint) 0, (IGRpoint *)point, &rc);
   EMerr_hndlr(rc != BSSUCC, *msg, BSFAIL, ret_end);
   BSprepcirc(&rc, point, &xyz_chd_ht, vector, &circle, unit_vec, &type);
   EMerr_hndlr(rc != BSSUCC, *msg, BSFAIL, ret_end);
 /*
  * Finding the range of the circle.
  */
   BSbx2(&rc, &circle.num_poles, (IGRpoint *)circle.poles,
          !circle.rational ? NULL : circle.weights, &range_cv[0], &range_cv[3]);
   EMerr_hndlr(rc != BSSUCC, *msg, BSFAIL, ret_end);
   is_box_int = BSbxint(&rc, &range_cv[0], &range_cv[3], &range_sf[0],
                            &range_sf[3]);
   if(is_box_int)
    {
    num_pt = pnt_slots = 0;
    surface_existing = FALSE;
    sts = om$send(msg = message EMSsurface.EMcrvsrfint(&msg_loc, NULL,
                              &(modenv_sf->md_env), &circle, NULL,
                              &(modenv_cv->md_env),
                              FALSE, &pnt_slots, &num_pt, NULL,
                              &srf_pnt_inters, NULL, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = sflist[i].S_objid,
                        targetos = sflist[i].osnum);
    EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
  /*
   * If there is intersection, some additional checks needs to be 
   * made to decide that this component surface is one of the candidate
   * among "spanned" surfaces. This check involves projecting the
   * center of the circle to this surface and finding if the distance
   * between the projected point and the point projected lies with
   * basis tolerance of the surface. If "yes" then this surface is the
   * valid candidate else not.
   * Most likely except in the rare cases there are going to be two
   * intersections with the circle and the concerned surface. For
   * example in cases where the circle happens to pass through the
   * vertex of the solid. It is  possible that these intersections are
   * lying on the different surfaces depending on the inclination of
   * the circle w.r.t. surface. In such case, i.e. when they are on the
   * diferent surface go for the next sampling point. The best sampling
   * point is one for which the intersections produced are lying on the
   * same surface and they are in  the area region.
   */
    if(num_pt)
    {
     if(num_pt > 2)
      is_good_sample_pt = FALSE;
     else
     if((num_pt IS 2) && 
       (srf_pnt_inters[0].leaf_id.objid != srf_pnt_inters[1].leaf_id.objid))
      is_good_sample_pt = FALSE;
     else
      is_good_sample_pt = TRUE;
     if(is_good_sample_pt)
     {
      if(surf_out)
      {
       for(k=0; k<num_span_surf; k++)
       {
       if(surf_out[k].objid == srf_pnt_inters[0].leaf_id.objid)
        {
         surface_existing = TRUE;
         break;
        }
       }
      }
      if(!surface_existing)
      {
       sts = om$send (msg = message EMSsubbs.GRptproject(&msg_loc, 
                              &(modenv_sf->md_env.matrix_type),
                              modenv_sf->md_env.matrix, point, proj_pt,
                              &proj_parms),
                           senderid = NULL_OBJID,
                           targetid = srf_pnt_inters[0].leaf_id.objid, 
                           targetos = srf_pnt_inters[0].leaf_id.osnum);
       EMerr_hndlr(!(1&msg_loc&sts), *msg, EMS_E_Fail, ret_end);
       OM_BLOCK_MOVE(&proj_parms.u, &uvpt[0], sizeof(IGRdouble));
       OM_BLOCK_MOVE(&proj_parms.v, &uvpt[1], sizeof(IGRdouble));
       check_val = BSdistptpt(&rc, point, proj_pt);
       if(check_val < bastol)
        {
         sts = om$get_channel_objects(objid = srf_pnt_inters[0].leaf_id.objid,
			     osnum = srf_pnt_inters[0].leaf_id.osnum,
			     p_chanselect = &to_my_loopset,
			     list = &ownlist,
			     size = 1,
			     count = &count);
         EMerr_hndlr(EMSerror(sts), sts, EMS_E_OMerror, ret_end);
         loopset_id = ownlist.S_objid;
        /*
         * getting the uvtol for the surface.
         */
         partolb.in_world = TRUE;
         partolb.mattyp = &(modenv_sf->md_env.matrix_type);
         partolb.mat = modenv_sf->md_env.matrix;
         partolb.is_valid = FALSE;
         sts = om$send(msg = message EMSsubbs.EMpartolbasis(&msg_loc,
                                  &(modenv_sf->md_env.matrix_type),
                                   modenv_sf->md_env.matrix,
                                   &world, TRUE, &partolb.tol),
                              senderid = NULL_OBJID,
                              targetid = srf_pnt_inters[0].leaf_id.objid,
                              targetos = srf_pnt_inters[0].leaf_id.osnum);
         EMerr_hndlr(!(1&sts&msg_loc), *msg, EMS_E_SurfaceError, ret_end);
         partolb.is_valid = TRUE;
         sts = om$send(msg = message EMSloopset.EMpt_location(&msg_loc,
				  uvpt, &location, &partolb),
			       senderid = NULL_OBJID,
                               targetid = loopset_id,
                               targetos = srf_pnt_inters[0].leaf_id.osnum);
         EMerr_hndlr(EMSerror(sts), sts, EMS_E_OMerror, ret_end);
         if(location.location IS EMS_L_INAREA || (num_pt IS 1 &&
                                       location.location IS EMS_L_ONEDGE))
          {
           num_span_surf ++;
           if(!surf_out)
           {
           surf_out = (struct GRid *) om$malloc (size = sizeof(struct GRid));
           surf_out[0].objid = srf_pnt_inters[0].leaf_id.objid;
           surf_out[0].osnum = srf_pnt_inters[0].leaf_id.osnum;
           }
          else
           {
           newsize = num_span_surf * sizeof(struct GRid);
           surf_out = (struct GRid *) om$realloc ( ptr = (IGRchar *) surf_out,
                                                  size = newsize);
           surf_out[num_span_surf - 1].objid = srf_pnt_inters[0].leaf_id.objid;
           surf_out[num_span_surf - 1].osnum = srf_pnt_inters[0].leaf_id.osnum;
           }
          }
         }
       }
      }
     }
     if(srf_pnt_inters) om$dealloc (ptr = srf_pnt_inters);
       srf_pnt_inters = NULL;
    } 
   par = par + EDGE_DISTINCT_VALUE * xyz_chd_ht;
   }
  }
 }
 *spancount = num_span_surf;

ret_end:
 if(!cv_geom)
 {
 for(k=0; k<numb_cv; k++)
  if(geomcv[k]) om$dealloc (ptr = geomcv[k]);
  if(geomcv) om$dealloc (ptr = geomcv);
 }

 return(surf_out);
}
end implementation Root;
