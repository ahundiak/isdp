/*
  DESCRIPTION 

    The following functions are used to support the process of outputting 
    surface-surface intersection data. Raw intersection polylines (or curves
    or objects) are input along with any trimming boundary (if any). The
    output is an EMSdataselect structure that can be used directly in the
    intersection output linked-list (of EMSintobj structures).

  ARGUMENTS

    msg 		- Output: The return code.

    data		- Input: Surface intersection raw data. These can
    (pydata, cvdata	  be polylines (or B-spline curves or objects) in
     or object)           3D (model-space) or 2D (parametric space).

    cvtype		- Input: The type of the curve that is being
                          given as input (eg: linestring, circle, ellipse).
    cvprop		- Input: Some more information about the curve.
                          Currently, only whether this is an iso-curve or not.
    world		- Input: A flag indicating whther the input data is
                          in the world space or parametric space. This
                          flag is not redundant in the case where parametric
                          data is input as 3D with the implicit rule to
                          ignore the 3rd dimension. If world data is input
                          as 2D then a zero is added for the 3rd dimension.

    bdry		- Input: The linked list of two nodes that contains
			  the start and the stop point of the trimming
			  boundary, respectively. Should be NULL if no
			  trimming is to be done.

    const_args		- Input: When the output has to be processed into
			  an OM-object, this construction list is required.
			  If the OM-object has already been constructed
			  then this may be NULL. If the object being 
                          constructed is a UV-object, then only the
                          const_args->env_info field is looked at;
                          the other fields may not be initialized.

    const_obj		- Input: A flag that tells the function whether to
 			  construct an object or not as output. If TRUE,
			  an EMSlinedge/EMSbsedge is constructed for
                          param-data and a GR3dlinestr/GRbcsubbc object for
                          world-data. If the flag is FALSE, 2D-polylines
                          or 3D-curves are generated for paramteric data and
			  3D-polylines or 3D-curves are generated for world-
                          data.

    degntol		- Input: A tolerance may be specified which will be
                          used to mesaure zero length. It will also be used 
                          to detect if the input data is closed on itself.
                          If NULL then for model-space data, zero-length
                          tolerance is extracted and for paramteric space data
                          the defined constant EMS_HIGH_UVLENTOL is used.

    buffer		- Input: If this argument is non-NULL, the buffer
			  is used in the output when a non-OM-object output
                          has been requested. If an object has been asked for,
                          this question does not arise. Further, the buffer may
			  be used to hold the trimmed output even if an
			  object has to be constructed. This way the user
			  can save a malloc call in this function for 
                          temporarily holding trimmed results.

    intdata		- Output: The output is returned in this
			  structure.

  RETURN VALUE

    The function value returned is an OM-status word. If all went well
    the value is OM_S_SUCCESS, else the appropriate code is returned.

    The msg argument can have one of the following values:
      - EMS_S_Success
         If all went well.
      - EMS_I_Degenerate
         If the input data was degenerate w.r.t. to the tolerance.

      - EMS_E_NoDynamicMemory
         If no dynamic memory was returned by the system when
         requested.
      - EMS_E_OMerror
         When some error occurred when requesting OM-services.

  HISTORY

    SS  :  09/24/87  :  Creation
    SS  :  11/01/87  :  Added limited support for B-spline raw
                        intersection data and curve-types.
    SS  :  11/01/88  :  B-spline curve data fully supported
    NP  :  12/12/91  :  Enhanced EMmkobintdata function so that it can now
			make objects out of the partial geometry of the input
			objects (i.e. make use of "bdry"). Earlier, the function
			could only return the input object back.This enhancement
			was needed for fixing "slivers".
			(See files EMsfintpost.I, EFsplitInts.I)
    Sudha  07/06/93  :  Modified for BSprototypes ansification
    NP  :  12/20/93  :  Fixed a very basic problem. In function EMmkobintdata, 
                        geomerty being passed down to EMmkcvintdata or
                        EMmkpyintdata in case of a part-edge was its own natural
                        geometry and not the natural geometry of the full-edge 
                        as it should be.
*/

class implementation Root;

%safe
#include <math.h>
%endsafe
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "gr.h"
#include "go.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emssfintdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "emsedgedef.h"
#include "emsgetgeom.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsrev_cv.h"
#include "bsdistptpt.h"

#define U 0
#define V 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSptedge_class_id;
extern GRclassid OPP_EMSlinedge_class_id;
extern GRclassid OPP_EMSbsedge_class_id;
extern GRclassid OPP_GR3dpoint_class_id, OPP_GRbcsubbc_class_id;

from EMSedge import EMreverse, EMget_props, EMgetgeom;
from EMSptedge import EMpteinit;
from EMSlinedge import EMleinit;
from EMSbsedge import EMbsinit;
from GRvg import GRconstruct;

IGRint EMmkintdata (msg, data, cvtype, cvprop, world, bdry, const_args, 
                    const_obj, degntol, buffer, intdata)
IGRlong *msg;
struct EMSdataselect *data;
IGRuchar cvtype;
IGRushort cvprop;
IGRboolean world;
struct EMSpypoint *bdry;
struct GRvg_construct *const_args;
IGRboolean const_obj;
IGRdouble *degntol;
IGRdouble *buffer;
struct EMSdataselect *intdata;
{
  enum EMSdatatype datatype;

  datatype = data->datatype;
  if (datatype == EMSdata_poly2d || datatype == EMSdata_poly3d)
    return (EMmkpyintdata (msg, data, cvtype, cvprop, world, bdry, const_args, 
            const_obj, degntol, buffer, intdata));
  else if (datatype == EMSdata_curve3d || datatype == EMSdata_curve2d)
    return (EMmkcvintdata (msg, data, cvtype, cvprop, world, bdry, const_args,
            const_obj, degntol, buffer, intdata));
  else if (datatype == EMSdata_object) /*removed "&& const_obj"*/
    return (EMmkobintdata (msg, data, cvtype, cvprop, world, bdry, const_args,
            const_obj, degntol, buffer, intdata));
  else
    {
    *msg = EMS_E_InvalidArg;
    return (OM_E_ABORT);
    }
}





#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
IGRint EMmkpyintdata (msg, pydata, cvtype, cvprop, world, bdry, const_args, 
                      const_obj, degntol, buffer, intdata)
IGRlong *msg;
struct EMSdataselect *pydata;
IGRuchar cvtype;
IGRushort cvprop;
IGRboolean world;
struct EMSpypoint *bdry;
struct GRvg_construct *const_args;
IGRboolean const_obj;
IGRdouble *degntol;
IGRdouble *buffer;
struct EMSdataselect *intdata;
{
  IGRboolean stat_func, mem_malloced, degenerate;
  IGRushort props_mask, leinit_options;
  IGRshort pt_dimension;
  IGRint i, lastptinx;
  IGRlong msg_loc, stat_OM;
  IGRdouble *points, cumdist, lentol, isopts[4];
  GRspacenum construct_os;
  struct EMSpartolbasis partolb;
  struct GRid *new_obj=NULL;
  struct IGRpolyline act_pts, curr_pts, *new_pts, isopy, *final_py;
  union EMSdata data_loc;
  enum EMSdatatype datatype_loc;
  extern IGRlong EFget_clipped_edge_type();

  /*
   * Initialize some local variables and
   * the return code.
   */

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  act_pts.points = NULL;
  mem_malloced = FALSE;

  datatype_loc = pydata->datatype;
  data_loc = pydata->data;
  if (datatype_loc == EMSdata_poly2d || datatype_loc == EMSdata_poly3d)
    {
    pt_dimension = datatype_loc == EMSdata_poly2d ? 2 : 3;
    curr_pts = *data_loc.poly;
    }
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);


  /*
   * Make space for the carrier structure (GRid or
   * IGRpolyline) in the output dataselect.
   */

  if (const_obj)
    {
    construct_os = const_args->env_info->md_id.osnum;
    new_obj = (struct GRid *) om$malloc (size = sizeof (struct GRid));
    EMerr_hndlr (!new_obj, *msg, EMS_E_NoDynamicMemory, ret_end);
    new_obj->osnum = construct_os;
    intdata->datatype = EMSdata_object;
    intdata->data.object = new_obj;
    new_pts = &act_pts;
    }
  else
    {
    new_pts = (struct IGRpolyline *) om$malloc (size = 
               sizeof (struct IGRpolyline));
    EMerr_hndlr (!new_pts, *msg, EMS_E_NoDynamicMemory, ret_end);
    intdata->datatype = datatype_loc;
    intdata->data.poly = new_pts;
    new_pts->points = NULL;
    }


  /*
   * If the input geometry has to be trimmed before output,
   * call the appropriate function to do it. The memory for the
   * final output geometry is either malloced here or passed in
   * by the user. If no trimming is to be done, prepare the
   * output geometry (mallocing if necessary, just like in the 
   * trimming case).
   */

  if (bdry)
    {
    if (buffer)
      new_pts->points = buffer;
    else
      mem_malloced = TRUE;

    EMgetactpy (&msg_loc, &curr_pts, pt_dimension, bdry, new_pts);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    if (msg_loc == EMS_I_Clipped)
      EFget_clipped_edge_type (&msg_loc, cvtype, &cvtype);
    }
  else
    {
    if (const_obj)
      *new_pts = curr_pts;
    else
      {
      if (buffer)
        new_pts->points = buffer;
      else
        {
        new_pts->points = (IGRdouble *) om$malloc (size = curr_pts.num_points *
                          pt_dimension * sizeof (IGRdouble));
        EMerr_hndlr (!new_pts->points, *msg, EMS_E_NoDynamicMemory, ret_end);
        }
      new_pts->num_points = curr_pts.num_points;
      OM_BLOCK_MOVE (curr_pts.points, new_pts->points, curr_pts.num_points *
       pt_dimension * sizeof (IGRdouble));
      }
    }

  /*
   * First check if the data to be finally output is degenerate. If so,
   * set the return code.
   */

  if (degntol)
    lentol = *degntol;
  else
    {
    if (world)
      BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    else
      lentol = EMS_HIGH_UVLENTOL;
    }

   points = new_pts->points;
   lastptinx = (new_pts->num_points - 1) * pt_dimension;
   cumdist = 0.0;
   degenerate = TRUE;
   for (i=0; i<lastptinx; i+=pt_dimension)
     {
     cumdist += pt_dimension == 2 ? 
                 sqrt (EM2ddistptpts (&points[i], &points[i+2])) :
                 BSdistptpt (&msg_loc, &points[i], &points[i+3]);
     if (cumdist > lentol)
       {
       degenerate = FALSE;
       break;
       }
     }
  if (degenerate)
    *msg = EMS_I_Degenerate;

  /*
   * Using the final output geometry that has been prepared in the previous
   * stage, format the output (making OM-objects if necessary). Actually, if
   * no objects are to be constructed, the output has already been formatted.
   * So, in the latter case, nothing is done.
   */

  if (const_obj)
    {
    if (! world)
      {
      if (degenerate)
        {
        stat_OM = om$construct (classid = OPP_EMSptedge_class_id, 
                   osnum = construct_os, p_objid = &new_obj->objid, 
                   msg = message EMSptedge.EMpteinit (&msg_loc, 
                   EMED_DEGENERATE, points));
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_OMerror, ret_end);
        }
      else
        {
        partolb.tol = lentol;
        partolb.is_valid = TRUE;
        if (cvprop & EMSintdata_isoedge)
          {
          leinit_options = EMSleinit_NoIsoCheck;
          isopts[U] = points[U];
          isopts[V] = points[V];
          isopts[2+U] = points[lastptinx+U];
          isopts[2+V] = points[lastptinx+V];
          isopy.num_points = 2;
          isopy.points = isopts;
          final_py = &isopy;
          }
        else
          {
          leinit_options = NULL;
          final_py = new_pts;
          }

        props_mask = (cvprop & EMSintdata_isoedge ? EMED_ISO : NULL) |
                     (cvprop & EMSintdata_xyzdegen ? EMED_DEGENERATE : NULL);
        stat_OM = om$construct (classid = OPP_EMSlinedge_class_id, 
                   osnum = construct_os, p_objid = &new_obj->objid, 
                   msg = message EMSlinedge.EMleinit (&msg_loc, props_mask,
                   cvtype, final_py, &partolb, leinit_options, NULL_OBJID));
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_OMerror, ret_end);
        }
      }
    else
      {
      stat_func = EFplace_line_string (NULL_OBJID, const_args, 
                   degenerate ? 1 : new_pts->num_points, new_pts->points,
                   &new_obj->objid, &msg_loc);
      EMerr_hndlr (EMSerror (msg_loc) || !stat_func, *msg, EMS_E_Fail, 
       ret_end);
      }
    }

ret_end:
  if (mem_malloced && const_obj && act_pts.points)
    om$dealloc (ptr = act_pts.points);

  EMWRAPUP (*msg, stat_OM, "EMmkpyintdata");
  return (stat_OM);
}





#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
IGRint EMmkcvintdata (msg, cvdata, cvtype, cvprop, world, bdry, const_args, 
                      const_obj, degntol, buffer, intdata)
IGRlong *msg;
struct EMSdataselect *cvdata;
IGRuchar cvtype;
IGRushort cvprop;
IGRboolean world;
struct EMSpypoint *bdry;
struct GRvg_construct *const_args;
IGRboolean const_obj;
IGRdouble *degntol;
IGRdouble *buffer;
struct EMSdataselect *intdata;
{
  IGRboolean mem_malloced, degenerate;
  IGRushort props_mask;
  IGRshort cv_dimension;
  IGRint i, j, k, blksize, inxlim;
  IGRlong msg_loc, stat_OM;
  IGRdouble *points, *weights, point1[3], point2[3];
  IGRdouble cumdist, lentol;
  GRspacenum construct_os;
  GRclassid cvclass;
  struct EMSpartolbasis partolb;
  struct GRid *new_obj=NULL;
  struct IGRbsp_curve act_crv, curr_crv, *new_crv, *cvptr;
  struct EMSdataselect tmpdata;
  struct IGRdisplay loc_display, *store_display_ptr=NULL;
  union EMSdata data_loc;
  enum EMSdatatype datatype_loc;
  extern IGRlong EFget_classid_for_an_edge_type();
  extern IGRlong EFget_clipped_edge_type();

  /*
   * Initialize some local variables and
   * the return code.
   */

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  act_crv.poles = NULL;
  act_crv.weights = NULL;
  act_crv.knots = NULL;
  mem_malloced = FALSE;

  datatype_loc = cvdata->datatype;
  data_loc = cvdata->data;
  if (datatype_loc == EMSdata_curve2d || datatype_loc == EMSdata_curve3d)
    {
    cv_dimension = datatype_loc == EMSdata_curve2d ? 2 : 3;
    curr_crv = *data_loc.curve;
    }
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);


  /*
   * Make space for the carrier structure (GRid or IGRbsp_curve) in the
   * output dataselect. The new output curve will be formatted in the
   * shell curve-structure - new_crv, regardless of the type of output.
   * The memory for the geomtry is not available at this stage.
   */

  if (const_obj)
    {
    construct_os = const_args->env_info->md_id.osnum;
    new_obj = (struct GRid *) om$malloc (size = sizeof (struct GRid));
    EMerr_hndlr (!new_obj, *msg, EMS_E_NoDynamicMemory, ret_end);
    new_obj->osnum = construct_os;
    intdata->datatype = EMSdata_object;
    intdata->data.object = new_obj;
    new_crv = &act_crv;
    }
  else
    {
    new_crv = (struct IGRbsp_curve *) om$malloc (size = 
               sizeof (struct IGRbsp_curve));
    EMerr_hndlr (!new_crv, *msg, EMS_E_NoDynamicMemory, ret_end);
    intdata->datatype = datatype_loc;
    intdata->data.curve = new_crv;
    new_crv->poles = NULL;
    new_crv->weights = NULL;
    new_crv->knots = NULL;
    }

  /*
   * If the input geometry has to be trimmed before output,
   * call the appropriate function to do it. The memory for the
   * final output geometry is either malloced here or passed in
   * by the user. If no trimming is to be done, prepare the
   * output geometry (mallocing if necessary, just like in the 
   * trimming case). After this stage, the new_crv structure contains
   * the output geometry that is to be directly used.
   */

  if (bdry)
    {
    if (buffer)
      {
      cvptr = (struct IGRbsp_curve *) buffer;
      GRbc_partition (cvptr, curr_crv.order, curr_crv.num_poles,
       curr_crv.rational, NULL);
      new_crv->poles = cvptr->poles;
      new_crv->knots = cvptr->knots;
      new_crv->weights = cvptr->weights;
      }
    else
      mem_malloced = TRUE;

    tmpdata.data.curve = new_crv;
    EMgetactgm (&msg_loc, cvdata, bdry, &tmpdata);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    if (msg_loc == EMS_I_Clipped)
      EFget_clipped_edge_type (&msg_loc, cvtype, &cvtype);

    new_crv = tmpdata.data.curve;
    }
  else
    {
    *new_crv = curr_crv;
    if (!const_obj)
      {
      if (buffer)
        {
        cvptr = (struct IGRbsp_curve *) buffer;
        GRbc_partition (cvptr, curr_crv.order, curr_crv.num_poles,
         curr_crv.rational, NULL);
        new_crv->poles = cvptr->poles;
        new_crv->knots = cvptr->knots;
        new_crv->weights = cvptr->weights;
        }
      else
        {
        new_crv->poles = (IGRdouble *) om$malloc (size = curr_crv.num_poles *
                          cv_dimension * sizeof (IGRdouble));
        new_crv->knots = (IGRdouble *) om$malloc (size = curr_crv.num_knots *
                          sizeof (IGRdouble));
        if (curr_crv.rational)
          new_crv->weights = (IGRdouble *) om$malloc (size = 
                              curr_crv.num_poles * sizeof (IGRdouble));
        EMerr_hndlr (!new_crv->poles || !new_crv->knots, *msg, 
         EMS_E_NoDynamicMemory, ret_end);
        if (curr_crv.rational)
          EMerr_hndlr (!new_crv->weights, *msg, EMS_E_NoDynamicMemory,
            ret_end);
        }
     
      OM_BLOCK_MOVE (curr_crv.poles, new_crv->poles, curr_crv.num_poles *
       cv_dimension * sizeof (IGRdouble));
      OM_BLOCK_MOVE (curr_crv.knots, new_crv->knots, curr_crv.num_knots *
       sizeof (IGRdouble));
      if (curr_crv.rational)
        OM_BLOCK_MOVE (curr_crv.weights, new_crv->weights, curr_crv.num_poles *
         sizeof (IGRdouble));
      }
    }

  /*
   * First check if the data to be finally output is degenerate. If so,
   * set the return code.
   */

  if (degntol)
    lentol = *degntol;
  else
    {
    if (world)
      BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    else
      lentol = EMS_HIGH_UVLENTOL;
    }

   points = new_crv->poles;
   if (new_crv->rational)
     weights = new_crv->weights;
   else
     weights = NULL;
   inxlim = (new_crv->num_poles - 1) * cv_dimension;
   cumdist = 0.0;
   degenerate = TRUE;
   blksize = cv_dimension * sizeof (IGRdouble);
   for (i=0, j=0; i<inxlim; i+=cv_dimension, j++)
     {
     OM_BLOCK_MOVE (&points[i], point1, blksize);
     OM_BLOCK_MOVE (&points[i+cv_dimension], point2, blksize);
     if (weights)
       for (k=0; k<cv_dimension; k++)
         {
         point1[k] /= weights[j];
         point2[k] /= weights[j];
         }

     cumdist += cv_dimension == 2 ? 
                 sqrt (EM2ddistptpts (point1, point2)) :
                 BSdistptpt (&msg_loc, point1, point2);
     if (cumdist > lentol)
       {
       degenerate = FALSE;
       break;
       }
     }
  if (degenerate)
    *msg = EMS_I_Degenerate;

  /*
   * Using the final output geometry that has been prepared in the
   * previous stage, format the output (making OM-objects if
   * necessary). Actually, if no objects are to be constructed, the
   * output has already been formatted. So, in the latter case,
   * nothing is done.
   */

  if (const_obj)
    {
    if (! world)
      {
      if (degenerate)
        {
        stat_OM = om$construct (classid = OPP_EMSptedge_class_id, 
                   osnum = construct_os, p_objid = &new_obj->objid, 
                   msg = message EMSptedge.EMpteinit (&msg_loc, 
                   EMED_DEGENERATE, point1));
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_OMerror, ret_end);
        }
      else
        {
        partolb.tol = lentol;
        partolb.is_valid = TRUE;
        props_mask = (cvprop & EMSintdata_xyzdegen ? EMED_DEGENERATE : NULL);
        stat_OM = om$construct (classid = OPP_EMSbsedge_class_id, 
                   osnum = construct_os, p_objid = &new_obj->objid, 
                   msg = message EMSbsedge.EMbsinit (&msg_loc, props_mask,
                   cvtype, new_crv, &partolb));
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_OMerror, ret_end);
        }
      }
    else
      {
      stat_OM = EFget_classid_for_an_edge_type (&cvclass, cvtype);
      EMomerr_exit (stat_OM, ret_end);

      const_args->geometry = (IGRchar *) new_crv;
      if (degenerate)
        {
        cvclass = OPP_GR3dpoint_class_id;
        loc_display = *const_args->display;
        loc_display.weight += 3;
        store_display_ptr = const_args->display;
        const_args->display = &loc_display;
        }

      stat_OM = om$construct (classid = cvclass, 
                 osnum = construct_os, p_objid = &new_obj->objid, 
                 msg = message GRvg.GRconstruct (const_args));

      if (degenerate)
        const_args->display = store_display_ptr;

      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (*const_args->msg), *msg, EMS_E_CurveError,
       ret_end);
      }
    }

ret_end:
  if (mem_malloced && const_obj)
    {
    if (act_crv.poles)
      om$dealloc (ptr = act_crv.poles);
    if (act_crv.knots)
      om$dealloc (ptr = act_crv.knots);
    if (act_crv.rational && act_crv.weights)
      om$dealloc (ptr = act_crv.weights);
    }

  EMWRAPUP (*msg, stat_OM, "EMmkcvintdata");
  return (stat_OM);
}



#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
IGRint EMmkobintdata (msg, obdata, cvtype, cvprop, world, bdry, const_args, 
                      const_obj, degntol, buffer, intdata)
IGRlong *msg;
struct EMSdataselect *obdata;
IGRuchar cvtype;
IGRushort cvprop;
IGRboolean world;
struct EMSpypoint *bdry;
struct GRvg_construct *const_args;
IGRboolean const_obj;
IGRdouble *degntol;
IGRdouble *buffer;
struct EMSdataselect *intdata;
{
  IGRlong 			msg_loc, stat_OM;
  union EMSdata 		data_loc;
  enum EMSdatatype 		datatype_loc;
  struct EMSdataselect 		objgeom;
  IGRchar			*cv_geometry;
  IGRushort                     ed_props;

  extern IGRboolean 		EMdegenerate_data();
  extern IGRint                 EMgetedgeom ();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /* INTIALIZATION */
  objgeom.datatype   = EMSdata_null; 
  objgeom.data.curve = NULL;
  objgeom.data.poly  = NULL;

  datatype_loc = obdata->datatype;
  data_loc = obdata->data;
  if (datatype_loc != EMSdata_object)
    {
    *msg = EMS_E_InvalidArg;
    goto ret_end;
    }

  /* ALGORITHM:
   * ---------
   * Assumes that the only objects coming into this function are of type 
   * GRcurve or EMSedge.
   *
   * IF (boundary or !output_is_object_type)
   * {
   *	IF (world)
   *	 	- get geometry of the incoming GRcurve
   *	ELSE 
   *	{	
   *		- get the properties of the incoming EMSedge
   *		- get the geometry of the edge
   *		  (It is important that the ACTUAL and NOT logical geometry
   *		   be passed into this function. If we pass the LOGICAL
   *		   geometry, we might get the wrong segment, for closed edges. 
   *		   This is due to EMgetactpy/EMgetactgm functions in the 
   *		   EMmkpyintdata and EMmkcvintdata functions possibly flipping 
   *		   boundaries to get them in increasing order).
   *	}
   *	  call EMmkpyintdata if geometry is poly-2D or poly-3d
   *	OR
   *	  call EMmkcvintdata if geometry is curve-2D or curve-3d
   *
   *	IF (!world && (incoming edge had its REVERSE bit set))
   *	{	IF (output_datatype == EMSdata_object)
   *	  		- reverse the resulting edge.
   *		ELSE IF (output_datatype == EMSdata_poly2D/3D)
   *			- reverse the resulting 2D/3D polyline
   *		ELSE IF (output_datatype == EMSdata_curve2D/3D)
   *			- reverse the resulting 2D/3D curve
   *	}
   * }
   * else (i.e. if !boundary && output_is_object_type)
   *
   *  	- return the same object back
   *  
   */

  if (bdry || !const_obj)
  {  if (world)
     {		
	/* get the geometry of the GRcurve */
	stat_OM=EMgetvggeom (&msg_loc,
				&(const_args->env_info->md_env.matrix_type),
				const_args->env_info->md_env.matrix,
				obdata->data.object,
				&cv_geometry,
				NULL);
	EMerr_hndlr (!(stat_OM & msg_loc & 1), *msg, EMS_E_Fail, ret_end);
			
       /* we have to convert the geometry into a dataselect for the
	* mkpyintdata or mkcvintdata calls below
	*/
	objgeom.datatype   = EMSdata_curve3d;
	objgeom.data.curve = (struct IGRbsp_curve *) cv_geometry;
     }
     else
     {  
        /* get properties of the edge */
         stat_OM = om$send (msg=message EMSedge.EMget_props (&msg_loc,
                                                        &ed_props),
                                        targetid = obdata->data.object->objid,
                                        targetos = obdata->data.object->osnum,
                                        senderid = NULL_OBJID);
         EMerr_hndlr (!(stat_OM & msg_loc & 1), *msg, EMS_E_Fail, ret_end);

	/* Get the NATURAL (not LOGICAL) and FULL geometry of the edge. This 
         * needs some explanation. It is important to note that for an edge, the
         * span-inx and param are always with respect to the NATURAL geometry of
         * the edge. If it is a part-edge, however, we need the NATURAL 
         * geometry of the bottommost edge or the FULL edge. Therefore, in case
         * of a part-edge, the span-inx and param are w.r.t. the NATURAL 
         * geometry of this FULL edge. Therefore, we set the right options to 
         * return the NATURAL and FULL geometry.  (NP 12/20/93).
         */
        stat_OM = EMgetedgeom (&msg_loc, EMSedgeom_full, obdata->data.object, 
                               &objgeom);
        EMerr_hndlr(!(1&stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
     }

     /** call py or cv intdata depending upon the type of geometry */

     if (objgeom.datatype == EMSdata_poly2d ||
	 objgeom.datatype == EMSdata_poly3d)
     {
     	stat_OM = EMmkpyintdata (&msg_loc, &objgeom, cvtype, cvprop, 
		    world,bdry, const_args,const_obj,degntol, 
		    buffer, intdata);
	EMerr_hndlr (!(stat_OM & msg_loc & 1), *msg, EMS_E_Fail, ret_end);
     }
     else if (objgeom.datatype == EMSdata_curve3d)
     {
     	stat_OM = EMmkcvintdata (&msg_loc, &objgeom, cvtype, cvprop, 
				world,bdry, const_args,const_obj,degntol, 
				buffer, intdata);
	EMerr_hndlr (!(stat_OM & msg_loc & 1), *msg, EMS_E_Fail, ret_end);
     }
     else
     { /* something is wrong */
        *msg = EMS_E_InvalidCase;
        goto ret_end;
     }

    /* The geometry of a GRcurve does not need to be reversed. However, if
     * the input object was an EMSedge object AND it had the reverse bit 
     * set, then the output (whatever its datatype) needs to be reversed
     */
     if (!world && (ed_props & EMED_REVERSED))
     {  if (intdata->datatype == EMSdata_object)
        {
          /* set the reverse bit for the  new edge */
	   stat_OM = om$send (msg=message EMSedge.EMreverse (&msg_loc), 
					targetid = intdata->data.object->objid,
					targetos = intdata->data.object->osnum,
					senderid = NULL_OBJID);
	   EMerr_hndlr(!(stat_OM & msg_loc & 1),*msg,EMS_E_Fail,ret_end);

	}
	else if (intdata->datatype == EMSdata_poly2d) 
	{
	   /* reverse the geometry of the 2D polyline */
	   EMrevpyline (&msg_loc, intdata->data.poly, 2, NULL);
	   EMerr_hndlr(!(stat_OM & msg_loc & 1),*msg,EMS_E_Fail,ret_end);
	}
	else if (intdata->datatype == EMSdata_poly3d)
	{
           /* reverse the geometry of the 3D polyline */
	   EMrevpyline (&msg_loc, intdata->data.poly, 3, NULL);
	   EMerr_hndlr(!(stat_OM & msg_loc & 1),*msg,EMS_E_Fail,ret_end);
	}
	else if ((intdata->datatype == EMSdata_curve2d) || 
	   	 (intdata->datatype == EMSdata_curve3d))
	{
	   BSrc		rc;
	   IGRboolean	sts;

	   /* reverse the geometry of the curve - math call */
	   sts = BSrev_cv(&rc,intdata->data.curve);
	   EMerr_hndlr((!sts)||(rc != BSSUCC),*msg,EMS_E_BSerror,ret_end);
   	}
	else
	{  *msg = EMS_E_InvalidCase;
	   goto ret_end;
	}
     }

  }/*if, bdry*/
  else
  {
     intdata->data.object = (struct GRid *) om$malloc
                         (size = sizeof (struct GRid));
     EMerr_hndlr(!intdata->data.object,*msg,EMS_E_NoDynamicMemory, ret_end);
     intdata->datatype = EMSdata_object;
     *intdata->data.object = *data_loc.object;
  }/*else*/

  /* common check for any kind of output */

  if (EMdegenerate_data (intdata, world, degntol))
    *msg = EMS_I_Degenerate;
										
ret_end:

  /* Since dataselect is a union, both data.curve and data.poly will point to
   * same memory. Hence free just one of them.
   */
  if (objgeom.data.curve)
    {om$dealloc(ptr=objgeom.data.curve); objgeom.data.curve=NULL;}
  if (objgeom.data.poly)
    {om$dealloc(ptr=objgeom.data.poly);  objgeom.data.poly=NULL;}

  EMWRAPUP (*msg, stat_OM, "EMmkobintdata");
  return (stat_OM);
}

end implementation Root;
