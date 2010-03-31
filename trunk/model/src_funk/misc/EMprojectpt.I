/* ###################   ANSI COMPILED     ################## */
class implementation Root;
/*
  ASSUMPTION

    If an object is input, this is either a GRcurve object or an EMSedge

  NOTE:

  -  All memory for output (projpts, mindist) is assumed pre-allocated. The 
     "projpts" argument is to be a NULL_terminated linked list structure of 
     "num" nodes and the "mindist" argument is an array of "num" IGRdoubles.

  -  The location info of projected points on the dataselect (EMS_PYPT_ATSTART,
     EMS_PYPT_ATSTOP, etc.) is always with respect to the LOGICAL direction,
     for EMSedge objects (for non-EMSedge dataselect there is only ONE 
     direction).

  HISTORY 

    SS  :  10/29/87  :  Creation
  Sudha :  07/08/93  :  Modified for BSprototypes ansification
    NP  :  08/27/93  :  Changed file name from EMproject.C to EMprojectpt.I 
                        due to addition of message send. Previously, when a 
                        point was projected onto a part-edge, the span index
                        and parameter returned were with respect to the geometry
                        of the part edge itself and NOT with respect to the 
                        geometry of the "full_edge", as per convention. (See
                        notes in EMSedge.S for message "EMpratpt")
    NP  :  09/22/93  :  EMgeteddata is renamed to EMgetedgeom due to addition
                        of "options" parameter. Deleted modifications made on
                        08/27/93, since EMgetedgeom takes care of that.
    NP  :  09/23/93  :  Further refined this function by replacing the call to
                        EMgetedgeom by the method EMptproject. Added NOTE above.
 
*/

%safe
#include <math.h>
%endsafe

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emserr.h"
#include "emsgetgeom.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "bsmdistptcv.h"
#include "bscvkttol2.h"
#include "bscveval.h"
#include "bschgdeppar.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#ifndef IDRAW
extern GRclassid OPP_EMSedge_class_id;
extern GRclassid OPP_EMSpartedge_class_id;
from EMSedge import EMptproject;
#endif IDRAW

IGRlong EMprojectpt (msg, mattyp, mat, ingeom, num, inpts, lentol, projpts,
                     mindist)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct EMSdataselect *ingeom;
IGRint num;
IGRdouble *inpts;
IGRdouble lentol;
struct EMSpypoint *projpts;
IGRdouble *mindist;
{
  IGRushort props;
  IGRshort dim;
  IGRint i;
  IGRlong msg_loc, stat_OM;
  GRclassid objclass;
  struct IGRbsp_curve *curve3d;
  struct EMSdataselect simpledata;
  struct EMSpypoint *outpyptr;
  union EMSdata dat;
  enum EMSdatatype dattyp;
  IGRdouble *projected_params, *interval_params, *param;
  IGRdouble knot_tol, basis_tol = .000001, startknot, stopknot;
  IGRshort no_intervals, no_params;
  struct EMSpartolbasis partolbasis;
  struct EMSproj_info *proj_info;

  extern void EMcnvtpypts();
  extern IGRlong EMgetvggeom(), EMgetedgeom();
  void EFcnvt_pj_pypt ();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  projected_params = NULL;
  interval_params = NULL;
  proj_info=NULL;

  /* ONLY used for GRcurve object */
  simpledata.datatype = EMSdata_null;
  simpledata.data.curve = NULL;

  dattyp = ingeom->datatype;
  dat = ingeom->data;
  
  switch (dattyp)
    {
    case EMSdata_poly2d:
    case EMSdata_poly3d:
      dim = (dattyp == EMSdata_poly2d ? 2 : 3);
      EMcnvtpypts (&msg_loc, dat.poly, dim, num, inpts, lentol, 
       projpts, mindist);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      break;

    case EMSdata_curve3d:
      curve3d = dat.curve;
      startknot = curve3d->knots[curve3d->order-1];
      stopknot = curve3d->knots[curve3d->num_poles];

      BSEXTRACTPAR (&msg_loc, BSTOLBASIS, basis_tol);
      if (lentol > stopknot-startknot)
        BSchgdeppar (stopknot-startknot, &msg_loc);
      else
        BSchgdeppar (lentol, &msg_loc);

      BScvkttol2 (curve3d->order, curve3d->knots, curve3d->num_poles,
       curve3d->poles, curve3d->weights, &knot_tol, &msg_loc);
      EMerr_hndlr (BSERROR (msg_loc), *msg, EMS_E_BSerror, ret_end);

      outpyptr = projpts;
      for (i=0; i<num; i++)
        {
        BSmdistptcv (dat.curve, &inpts[3*i], &no_intervals, &no_params,
         &projected_params, &mindist[i], &interval_params, &msg_loc);
        EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);

        /*
         * If the projected parameter is very close to the boundary we snap
         * it to the boundary to prevent curve evaluation from barfing.
         */

        if (no_params)
          param = projected_params;
        else if (no_intervals)
          param = interval_params;
        else
          {
          *msg = EMS_E_InvalidCase;
          goto ret_end;
          }

        if (fabs (*param - startknot) <= knot_tol)
          {
          *param = startknot;
          props = EMS_PYPT_ATSTART;
          }
        else if (fabs (*param - stopknot) <= knot_tol)
          {
          *param = stopknot;
          props = EMS_PYPT_ATSTOP;
          }
        else
          props = EMS_PYPT_ATMIDDLE;

        BScveval (curve3d, *param, 0, (IGRpoint *)outpyptr->point, &msg_loc);
        EMerr_hndlr (BSERROR(msg_loc), *msg, EMS_E_BSerror, ret_end);

        outpyptr->span_inx = 0;
        outpyptr->param = *param;
        outpyptr->info = NULL;
        outpyptr->props = props;
        outpyptr = outpyptr->next;

        if (projected_params) 
          om$dealloc (ptr = projected_params);
        if (interval_params)
          om$dealloc (ptr = interval_params);
        projected_params = NULL;
        interval_params = NULL;
        }
      break;

    case EMSdata_object:

#ifndef IDRAW
      om$get_classid (objid = dat.object->objid, osnum = dat.object->osnum,
       p_classid = &objclass);
      if (om$is_ancestry_valid (subclassid = objclass,
          superclassid = OPP_EMSedge_class_id) == OM_S_SUCCESS)
        {

        proj_info = (struct EMSproj_info *) om$malloc 
                                 (size = num * sizeof (struct EMSproj_info));
        EMerr_hndlr (!proj_info, *msg, EMS_E_NoDynamicMemory, ret_end);

        partolbasis.tol      = lentol;
        partolbasis.is_valid = TRUE;
        partolbasis.in_world = FALSE;
        partolbasis.mattyp   = mattyp;
        partolbasis.mat      = mat;

        /* We project the points onto the edge using EMptproject. The info
         * returned about the location of projected points on the edge is with
         * respect to the logical direction of the edge (i.e. EMScvint_rtend,
         * EMScvint_lfend, etc.).
         */
        stat_OM = om$send (msg=message EMSedge.EMptproject (&msg_loc,
                    inpts, num, proj_info, NULL, &partolbasis),
                           senderid = NULL_OBJID, 
                           targetid = dat.object->objid,
                           targetos = dat.object->osnum);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);

        /* Now we need to convert the "proj_info" into the "pypoint" structures
         * that this function is supposed to output.
         */

        EFcnvt_pj_pypt (num, proj_info, projpts, mindist);
        EMerr_hndlr (!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

        }
      else 
#endif IDRAW
        {

        stat_OM = EMgetvggeom (&msg_loc, mattyp, mat, dat.object, 
                   &simpledata.data.curve, &simpledata.datatype);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        EMerr_hndlr (simpledata.datatype != EMSdata_curve3d, *msg,
         EMS_E_InvalidArg, ret_end);


        EMprojectpt (&msg_loc, mattyp, mat, &simpledata, num, inpts, 
                      lentol, projpts, mindist);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        }
        break;

    default:
      *msg = EMS_E_InvalidArg;
    }

ret_end:
  if (dattyp == EMSdata_curve3d)
    BSchgdeppar (basis_tol, &msg_loc);
  if (projected_params) 
    om$dealloc (ptr = projected_params);
  if (interval_params)
    om$dealloc (ptr = interval_params);
  if (simpledata.data.curve) 
    om$dealloc (ptr = simpledata.data.curve);
  if (proj_info)
    om$dealloc (ptr = proj_info);

  EMWRAPUP (*msg, stat_OM, "EMprojectpt");
  return (stat_OM);
}


  /* This routine converts the output of the EMSedge.EMptproject method to the
   * output of the EMprojectpt function. All memory is assumed to be 
   * pre-allocated & nothing is malloced in here.
   */


  void  EFcnvt_pj_pypt (num_pts, proj_info, pypt, mindist)
  IGRint              num_pts;
  struct EMSproj_info *proj_info;
  struct EMSpypoint   *pypt;
  IGRdouble           *mindist;
  {
    IGRlong i;
    struct EMSpypoint   *loc_pypt;


      for (i=0, loc_pypt=pypt; i<num_pts; i++, loc_pypt=loc_pypt->next)
      {
         loc_pypt->point[0]  = proj_info[i].proj_pt[0]; 
         loc_pypt->point[1]  = proj_info[i].proj_pt[1]; 
         loc_pypt->point[2]  = 0.0; /* because we are talking about an edge */
         loc_pypt->param     = proj_info[i].param.param;
         loc_pypt->span_inx  = proj_info[i].param.span_inx;
         loc_pypt->info      = NULL; /* for want of better info */
         loc_pypt->props     = NULL;
         switch (proj_info[i].location)
         {
            case EMScvint_middle:   
                   loc_pypt->props |= EMS_PYPT_ATMIDDLE;
                   break;
            case EMScvint_rtend:     
            case EMScvint_rtendcoll: 
                   loc_pypt->props |= EMS_PYPT_ATSTOP;
                   break;
            case EMScvint_lfend:     
            case EMScvint_lfendcoll: 
                   loc_pypt->props |= EMS_PYPT_ATSTART;
                   break;
            case EMScvint_unknown :  
                   loc_pypt->props |= EMS_PYPT_POSUNKNOWN;
                   break;
            default:
                   loc_pypt->props |= EMS_PYPT_POSUNKNOWN;
         }

         mindist[i] = proj_info[i].dist;
      }
  }
end implementation Root;
