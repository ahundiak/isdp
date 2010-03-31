class implementation Root;

#include "EMS.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "exmacros.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "emsgetgeom.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsconic.h"
#include "EMSmsgdef.h"
#include "mabcendpts.h"
#include "bsparameters.h"
#include "bsdistptpts.h"
#include "bscveval.h"
#include "bsalloccv.h"
#include "bscv_copy.h"
#include "bsrev_cv.h"
#include "bsfreecv.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/mx.h"
#include "PWapi/cvgeom.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

#define START  0
#define STOP   1

#define NUM_INTERNAL_SAMPLES 3

#ifndef IDRAW
extern GRclassid OPP_EMSboundary_class_id;
extern GRclassid OPP_EMSedge_class_id;
extern GRclassid OPP_EMSpartedge_class_id;
#endif IDRAW

extern GRclassid OPP_GRpoint_class_id;

from GRgraphics  import GRdelete;
from GRvg        import GRgetsize, GRgetgeom, EMptatpr;
from GRcurve     import GRendpts;

#ifndef IDRAW
from EMSedge import EMset_props, EMget_props, EMget_props_type,EMget_bcxyz_geom;
from EMSedge import EMendpts, EMptatpr, EMgetpygeom, EMgetbounds;
from EMSedge import EMsplityourself;
from EMSloop import EMset_props, EMmodify_edge;
#endif IDRAW

/*****************************************************************************/
/*                                                                           */
/*     PLEASE PUT HISTORY INFORMATION ABOVE RESPECTIVE FUNCTIONS AND NOT     */
/*                          ALWAYS AT THE TOP OF THE FILE                    */
/*                                                                           */
/*****************************************************************************/


/*
   ABSTRACT:

    This function obtains a given number of points lying at the ends of
    the input data. This is a higer level function that handles both UV data 
    and XYZ data. If data is UV it calls the lower level function 
    "EMgetendpts_uv", else if data is XYZ, it calls "EMgetendpts_xyz". The user
    has to set the input parameter "xyz_data" to TRUE or FALSE depending on the 
    type of data being passed in.

    INPUT/OUTPUT:

I   msg          : Return code.
  
I   mattyp       : Matrix type. 
                   XYZ: non-NULL
                   UV : NULL

I   mat          : Matrix. 
                   XYZ: non-NULL
                   UV : NULL

I   indata       : Incoming dataselect.
                   XYZ: poly3d, curve3d or GRcurve object.
                   UV:  poly2d, curve3d or EMSedge object.

I   indata_rev   : Whether indata should be reversed for logical flow. The 
                   end points returned are ALWAYS with respect to the logical
                   direction of the dataselect.

I   num_pts      : Number of points each desired at start and stop.

O   start_pts    : Output. "num_pts" points at the start of dataselect.
                   NOTE: Memory is expected to be allocated by caller.
                   XYZ: Array of 3D points.
                   UV:  Array of 2D points.

O   stop_pts     : Output. "num_pts" points at the stop of dataselect.
                   NOTE: Memory is expected to be allocated by caller.
                   XYZ: Array of 3D points.
                   UV:  Array of 2D points.

I   xyz_data     : Boolean flag.
                   XYZ: TRUE
                   UV:  FALSE

   HISTORY:

   12/21/93  : NP  : Creation.

*/


IGRint EMgetendpts (msg, mattyp, mat, indata, indata_rev, 
                        numpts, start_pts, stop_pts, xyz_data)
IGRlong *msg;
IGRshort *mattyp;
IGRmatrix mat;
struct EMSdataselect *indata;
IGRboolean indata_rev, xyz_data;
IGRint numpts;
IGRdouble *start_pts, *stop_pts;
{
     IGRlong sts, msg_loc;
     extern IGRint EMgetendpts_xyz ();
     extern IGRint EMgetendpts_uv ();

   sts = OM_S_SUCCESS;

   if (xyz_data)
   {
     sts = EMgetendpts_xyz (&msg_loc, mattyp, mat, indata, indata_rev,
                              numpts, start_pts, stop_pts);
     EMerr_hndlr (!(1&sts&msg_loc), *msg, msg_loc, ret_end);
   }
   else
   {
     sts = EMgetendpts_uv (&msg_loc, indata, indata_rev, 
                              numpts, start_pts, stop_pts);
     EMerr_hndlr (!(1&sts&msg_loc), *msg, msg_loc, ret_end);
   }

  ret_end:

  EMWRAPUP (*msg, sts, "EMgetendpts");
  return (sts);
}


/*
   ABSTRACT:
    
    This function obtains a given number of points lying at the ends of
    the input intersection data. The input data could be a polyline-structure,
    curve buffer or an surface-edge object. The data is 2-dimensional and the
    edge is assumed to be of EMSedge type.

   HISTORY:

   ???????? ??   Creation.
   06/06/93 NP   Moved from EMintsupp.I to here.
*/

IGRint EMgetendpts_uv (msg, indata, indata_rev, numpts, start_pts, stop_pts)
IGRlong *msg;
struct EMSdataselect *indata;
IGRboolean indata_rev;
IGRint numpts;
IGRdouble *start_pts, *stop_pts;
{
  IGRint in_numpts, blksize, stat_OM, i, j;
  IGRlong msg_loc;
  IGRdouble *in_pts, *start_loc, *stop_loc;
  struct IGRbsp_curve *cv;
  struct IGRpolyline poly;
  struct EMSedgebound startpar, stoppar;
  void EMrevpyline();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (indata_rev)
    {
    start_loc = stop_pts;
    stop_loc = start_pts;
    }
  else
    {
    start_loc = start_pts;
    stop_loc = stop_pts;
    }

  if (numpts == 1)
    {
    switch (indata->datatype)
      {
#     ifndef IDRAW
      case EMSdata_object:
        stat_OM = om$send (msg = message EMSedge.EMendpts (&msg_loc,
                   start_loc, stop_loc, &startpar, &stoppar, NULL), 
                   targetid = indata->data.object->objid,
                   targetos = indata->data.object->osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_OMerror, ret_end);
        break;
#     endif
      case EMSdata_poly2d:
        in_numpts = indata->data.poly->num_points;
        in_pts = indata->data.poly->points;
        blksize = 2 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (in_pts, start_loc, blksize);
        OM_BLOCK_MOVE (&in_pts[(in_numpts-1)*2], stop_loc, blksize);
        break;
      case EMSdata_curve3d:
        cv = indata->data.curve;
        in_numpts = indata->data.curve->num_poles;
        in_pts = indata->data.curve->poles;
        blksize = 2 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (in_pts, start_loc, blksize);
        OM_BLOCK_MOVE (&in_pts[(in_numpts-1)*3], stop_loc, blksize);
        if (cv->rational)
          for (i=0; i<2; i++)
            {
            start_loc[i] /= cv->weights[0];
            stop_loc[i] /= cv->weights[in_numpts-1];
            }
        break;
      default:
        *msg = EMS_E_InvalidArg;
      }
    }
  else
    {
    switch (indata->datatype) 
      {
#     ifndef IDRAW
      case EMSdata_object:
        poly.num_points = numpts;
        poly.points = start_loc;
        stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&msg_loc,
                   0, numpts-1, FALSE, NULL, &poly, NULL, NULL), 
                   targetid = indata->data.object->objid,
                   targetos = indata->data.object->osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_EdgeError, ret_end);

        poly.points = stop_loc;
        stat_OM = om$send (msg = message EMSedge.EMgetpygeom (&msg_loc,
                   0, numpts-1, TRUE, NULL, &poly, NULL, NULL), 
                   targetid = indata->data.object->objid,
                   targetos = indata->data.object->osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMis_error (msg_loc), *msg, EMS_E_EdgeError, ret_end);
        break;
#     endif
      case EMSdata_poly2d:
        in_numpts = indata->data.poly->num_points;
        in_pts = indata->data.poly->points;
        blksize = numpts * 2 * sizeof (IGRdouble);
        OM_BLOCK_MOVE (in_pts, start_loc, blksize);
        OM_BLOCK_MOVE (&in_pts[(in_numpts-numpts)*2], stop_loc, blksize);
        poly.num_points = numpts;
        poly.points = stop_loc;
        EMrevpyline (&msg_loc, &poly, 2, MAXINT);
        break;
      case EMSdata_curve3d:
        cv = indata->data.curve;
        in_numpts = indata->data.curve->num_poles;
        in_pts = indata->data.curve->poles;
        blksize = 2 * sizeof (IGRdouble);
        for (i=0; i<numpts; i++)
          {
          OM_BLOCK_MOVE (&in_pts[i*3], &start_loc[i*2], 
           blksize);
          OM_BLOCK_MOVE (&in_pts[(in_numpts-numpts+i)*3], &stop_loc[i*2],
           blksize);
          if (cv->rational)
            for (j=0; j<2; j++)
              {
              start_loc[i*2+j] /= cv->weights[i];
              stop_loc[i*2+j] /= cv->weights[in_numpts-numpts+i];
              }
          }
        poly.num_points = numpts;
        poly.points = stop_loc;
        EMrevpyline (&msg_loc, &poly, 2, MAXINT);
        break;
      default:
        *msg = EMS_E_InvalidArg;
      }
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetendpts_uv");
  return (stat_OM);
}


/* 
   DESCRIPTION: This function finds all intersection points between two 
                input dataselects. It returns the intersection information in
                the form of two EMSpypoint linked lists. The pypoint nodes 
                on the two dataselects that correspond to each other point to 
                each other through the "info" pointer.

   IMPORTANT:   

   1.    The function will ALWAYS return the span-index/param values
         at the intersection points w.r.t the NATURAL geometry of the 
         input DATASELECTS (the NATURAL geometry could be  different 
         from the LOGICAL geometry ONLY for EMSedge objects).
         However, the location of the intersection points will ALWAYS
         be w.r.t. the LOGICAL direction of the dataselect, taking into
         account the input "reverse" flags. It is VERY important that
         the span-inx/param for edges be w.r.t. the natural geometry of
         the edges as per convention.
   2.    This function currently can handle ONLY UV data. This is because we use
         EMSsfintedpar structures in performing the intersection, which can hold
         ONLY 2d  points. 
          
    
   MAIN STEPS IN ALGORITHM:
   
   1. If input dataselects are objects, get their polyline or bspline geometry.

   2. If both the geometries are polylines, 
          use "EM2dpycutint" to get the intersection data, 
      else 
          convert one of the geometries if need be into bspline format and 
          use "EMtrim_bspline_against_bspline" to get the intersection data.
           
   3. Since the above functions return one set of intersections as a linked
      list of EMSpypoints and the other set as a linked list of EMSsfintedpars,
      we convert the EMSsfintedpars into EMSpypoints for output.

   4. While performing the intersections, the dataselects are so arranged that 
      the intersections on "intdata1" are always returned as EMSsfintedpars 
      and the intersections on "intdata2" as EMSpypoints.

   5. Since the function originally did not have the "intdata2_reversed" 
      parameter, the intersection routines in 2 above take into accout the 
      "intdata1_reversed" parameter ONLY.

   6. While converting the EMSsfintedpars of "intdata1" into EMSpypoints, 
      the "intdata2_reversed" parameter is applied to the EMSpypoints 
      corresponding to "intdata2" so that they are consistent with the logical
      direction of "intdata2".

   7. Finally, the EMSpypoint nodes corresponding to each other across the two
      linked lists "intinfo1" and "intinfo2" are made to point to each other 
      through the "info" pointer field.

   8. Adjust the span-inx/param for the geometry in case of partedges. This may
      require some explanation. In this function, for edges, we always extract 
      the NATURAL geometry. If it is a part-edge, we extract that part of the 
      NATURAL geometry that is within the bounds of the part edge. Obviously, 
      the intersections returned by the lower level routines are with respect to
      this part geometry, for part edges (i.e. an intersection on span 1 of the 
      PART geometry might be actually on span 6 of the NATURAL geomerty of the
      FULL EDGE). In such cases, we will need to convert the span-inx/param with
      respect to the NATURAL geomerty of the FULL EDGE as per convention.

   PARAMETERS:  
  
   msg          *IGRlong    (Output) Return code.
 
   uvtol        IGRdouble   (Input)  Tolerance for intersection of
                                     input dataselects. MUST be given.
                                     IMPORTANT: It is the callers responsibility
                                     ---------  to pass in the parametric tol
                                     if inputs pertain to UV space or else to 
                                     pass in XYZ tolerance if input dataselects
                                     pertain to model space.

   mattyp       *IGRshort   (Input)  Matrix type. Can be NULL if none of the
                                     input dataselects are objects.

   mat          IGRmatrix   (Input)  Matrix. Can be NULL if none of the
                                     input dataselects are objects.

   intdata1     *struct     (Input)  First dataselect.
                EMSdataselect

   intdata1_reversed     
               IGRboolean   (Input)  If TRUE, it means that "intdata1" is to 
                                     be reversed for logical flow.
                                     
   intdata2     *struct     (Input)  Second dataselect.
                EMSdataselect

   intdata2_reversed     
               IGRboolean   (Input)  If TRUE, it means that "intdata2" is to
                                     be reversed for logical flow.
  
   num_inters   *IGRint     (Output) Number of intersections between dataselects

   intinfo1     *struct     (Output) The "pypoint" linked list (corresponding to
                EMSpypoint           the first dataselect) of the points of
                                     intersection between the two dataselects.
                                     The properties in the pypoint node are with
                                     respect to the logical direction of flow of
                                     the dataselect (i.e. it takes the 
                                     "intdata1_reversed" parameter into account)
              
   intinfo2     *struct     (Output) The "pypoint" linked list (corresponding to
                EMSpypoint           the second dataselect) of the points of
                                     intersection between the two dataselects.
                                     The properties in the pypoint node are with
                                     respect to the logical direction of flow of
                                     the dataselect (i.e. it takes the 
                                     "intdata2_reversed" parameter into account)

   HISTORY:
  
   06/06/93  NP   Originally written by Ashok/Siki. Moved this function 
                  (EMget_intersection_points()) to this file from its earlier 
                  residence EMintsupp.I. I need to update this function to add
                  a "intdata2_reversed" parameter for consistency.
   06/07/93  NP   Replaced "EMget_intersection_points" with the function
                  "EFget_intersection_points" from EMintsupp.I. The latter was
                  an enhancement to "EMget_intersection_points" made by Nirmal 
                  to handle objects. Also, I have added a new parameter 
                  "intdata2_reversed" to the function to make it consistent.
                  Added PARAMETERS  and MAIN STEPS IN ALGORITHM.
   06/10/93  NP   Found a bug where pypoint properties were being set. 
                  "EMScvint_end" was not being handled. Made check exhaustive.
   06/11/93 ashok Added a temporary block to take care of zero interscections
		  incorrectly returned by EM2dpycutint() sometimes. This
		  kludge to be removed soon.
   09/22/93  NP   Function EMgeteddata is renamed to EMgetedgeom due to addition
                  of "options" argument.
   09/24/93  NP   Added "IMPORTANT" above. Function computes span-inx/param 
                  w.r.t. the natural direction of dataselect and the properties
                  such as "ATSTART/ATSTOP" etc. are w.r.t. the final logical 
                  direction (after applying input reverse flags) of dataselect.
   12/16/93  NP   Added notes on converting span-inx/param on part-edge w.r.t. 
                  the full edge. Also, stop returning POSUNKNOWN as a property. 
                  If it is not at either end, it must be ATMIDDLE. Finally & 
                  most importantly, added option "EMS_INTER_CUTTING" before 
                  calling the intersection routines, so that only one out of a 
                  pair of duplicate intersection points on a dataselect remains.
   12/23/93  NP   Getting around the problem of 2dpycutint NOT returning the 
                  endpts of the W-poly, if they were lying in the MIDDLE of the
                  C-poly (W-poly & C-poly are intdata1 and intdata2 respectively
                  in this function). I now ALWAYS project the endpts of intdata1
                  onto intdata2 if it has not already been returned as an intr.
                  With this fix, we dont need the kludge of 6/11/93 anymore.
  06/16/94 ashok  Copied "mlk" fixes from EMS 4 version.
  12/26/94 Sanjay Fixed a problem in posting the start and stop intersection 
                  points. See the Description below under FIX.
                 
 */


void EFget_intersection_points (msg, uvtol,  mattyp, mat,
                         intdata1, intdata1_reversed,
                         intdata2, intdata2_reversed,
                         num_inters, intinfo1, intinfo2)
IGRlong *msg;
IGRdouble uvtol;
IGRshort *mattyp;
IGRmatrix mat;
struct EMSdataselect *intdata1, *intdata2;
IGRboolean intdata1_reversed, intdata2_reversed;
IGRint *num_inters;
struct EMSpypoint **intinfo1, **intinfo2;
{
  IGRushort ed_props, data1_props, options;
  IGRlong msg_loc, stat_func, stat_OM;
  IGRpoint start_pt, stop_pt, test_pt;

  struct EMSpypoint *p_pypt, *loc_pypt, *loc_pypt2, *temp_ptr;
  struct EMSsfintedpar *p_epar, *p_epar_loc, *new_epar;
  struct IGRbsp_curve bs_crv;
  IGRboolean partedge1=FALSE, partedge2=FALSE;
  IGRboolean reverse, dataselect1_rev, dataselect2_rev, found;
  struct EMSpypoint *projpt1, *projpt2;
  struct EMSdataselect *intdata1_loc, *intdata2_loc;
  struct EMSedgebound bound1[2], bound2[2], inpar, outpar;
  IGRpoint intdata1_startpt, intdata1_stoppt, intdata1_endpt;
  struct EMSdataselect simpledata1, simpledata2;
  IGRdouble mindist1, mindist2;
  GRclassid objclass;
  IGRlong  i;

  extern struct EMSpypoint *EMpypoint_malloc();
  extern struct EMSsfintedpar *EMsfintedpar_malloc ();
  void  EMsfintedpar_free ();
  void  EMdataselect_data_free ();
  extern void EMpypoint_free();
  extern IGRint EMgetendpts_uv ();
  extern IGRlong EMinternalpt ();
  extern IGRint EMgetendpts ();
  extern IGRlong EMprojectpt ();
  extern IGRboolean EMcnvtpybsn();

  simpledata1.datatype = EMSdata_null;
  simpledata1.data.curve =  NULL;
  simpledata2.datatype = EMSdata_null;
  simpledata2.data.curve = NULL;

  *msg = EMS_S_Success;
  stat_OM = stat_func = TRUE;

  new_epar = NULL;
  p_epar = NULL;
  loc_pypt = loc_pypt2 = NULL;
  bs_crv.poles = NULL;
  bs_crv.knots = NULL;
  bs_crv.weights = NULL;

  intdata1_loc = intdata1;
  intdata2_loc = intdata2;
 
  /* "partedge1/2 & dataselect1/2_rev"  are used for EMSedge dataselects only */
  partedge1 = FALSE;
  partedge2 = FALSE;
  dataselect1_rev = FALSE;
  dataselect2_rev = FALSE;
  found = FALSE;

  if(intdata1->datatype == EMSdata_object)
  {
#ifndef IDRAW
     om$get_classid (objid = intdata1->data.object->objid,
                        osnum = intdata1->data.object->osnum,
                        p_classid = &objclass);
     if (om$is_ancestry_valid (subclassid = objclass,
          superclassid = OPP_EMSedge_class_id) == OM_S_SUCCESS)
     {
        /* get NATURAL & PART (for part-edges) geometry */
        stat_OM=EMgetedgeom(&msg_loc,NULL,intdata1->data.object, &simpledata1);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
         
        /* we need to check bounds for part-edges only*/
        if (om$is_ancestry_valid (
                 subclassid   = objclass,
                 superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
        {
           stat_OM = om$send (msg = message EMSedge.EMgetbounds(&msg_loc,
                                 bound1), 
                   senderid = NULL_OBJID,
                   targetid = intdata1->data.object->objid,
                   targetos = intdata1->data.object->osnum);
            EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
            partedge1 = TRUE;
        }
        stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                                       &ed_props),
                    targetid = intdata1->data.object->objid, 
                    targetos = intdata1->data.object->osnum,
                    senderid = NULL_OBJID);
        EMerr_hndlr(EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        
        if (ed_props & EMED_REVERSED)
          dataselect1_rev = TRUE;

        intdata1_loc = &simpledata1;
     }
     else
#endif IDRAW
     {
        /* We dont support XYZ data in this function */
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

     }
  }

  if(intdata2->datatype == EMSdata_object)
  {

#ifndef IDRAW
     om$get_classid (objid     = intdata2->data.object->objid,
                       osnum     = intdata2->data.object->osnum,
                       p_classid = &objclass);
     if (om$is_ancestry_valid (subclassid = objclass,
          superclassid = OPP_EMSedge_class_id) == OM_S_SUCCESS)
     {
        /* get NATURAL & PART (for part-edges) geometry */
        stat_OM=EMgetedgeom(&msg_loc,NULL,intdata2->data.object, &simpledata2);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
 
        /* we need to check bounds for part-edges only*/
        if (om$is_ancestry_valid (
                       subclassid   = objclass,
                       superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
        {
           stat_OM = om$send (msg = message EMSedge.EMgetbounds(&msg_loc,
                                    bound2),
                   senderid = NULL_OBJID,
                   targetid = intdata2->data.object->objid,
                   targetos = intdata2->data.object->osnum);
           EMerr_hndlr(EMSerror(stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
           partedge2 = TRUE;
        }
        stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                                       &ed_props),
                    targetid = intdata2->data.object->objid, 
                    targetos = intdata2->data.object->osnum,
                    senderid = NULL_OBJID);
        EMerr_hndlr(EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        
        if (ed_props & EMED_REVERSED)
           dataselect2_rev = TRUE;

        intdata2_loc = &simpledata2;
     }
     else 
#endif IDRAW
     {
        /* We dont support XYZ data in this function */
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
     }

  }

    if(intinfo2 && *intinfo2)
    {
      loc_pypt2 = *intinfo2;
      while(loc_pypt2->next)
        loc_pypt2 = loc_pypt2->next;
    }

  data1_props = EMED_OPEN;

  /************************
   WORK ON THE NATURAL GEOMETRY OF THE DATASELECT, SO THAT SPAN-INX/PARAM ARE
   WITH RESPECT TO IT. HOWEVER, WE DO TAKE NOTE OF THE REVERSE FLAG LATER.
  if (intdata1_reversed)
    data1_props |= EMED_REVERSED;
  ************************/


  /* Since we dont particularly care about HOLE/AREA transition here and we
   * dont want duplicte intersection points on either dataselect (can happen
   * within EM2dpycutint, if intersection happens to be at an end of a span, in 
   * which case, there is also an intersection returned at the start of the next
   * span), we set the "EMS_INTER_CUTTING" option and "EMS_INTER_ONEOFTWO",
   * which removes one out of a pair of duplicates. 
   *
   * The intersection routines below assume 2d points, since the EMSsfintedpar
   * structure has space for 2d points only. Someday, this will have to change
   * if we are to support XYZ data too.
   */

  
  options = EMS_INTER_STOPPT | EMS_INTER_STARTPT | EMS_INTER_CUTTING |
             EMS_INTER_ONEOFTWO;

  *num_inters = 0;

  if(intdata1_loc->datatype == EMSdata_poly2d &&
     intdata2_loc->datatype == EMSdata_poly2d)
  {
     EM2dpycutint (&msg_loc, 
       intdata1_loc->data.poly->num_points, intdata1_loc->data.poly->points,
       data1_props, NULL,
       intdata2_loc->data.poly->num_points, intdata2_loc->data.poly->points,
       NULL, options, uvtol, NULL, NULL, NULL_OBJID, NULL,
       num_inters, &p_epar, intinfo2);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  }
  else if(intdata1_loc->datatype == EMSdata_poly2d)
  {
     stat_func = EMcnvtpybsn(&msg_loc, 2, intdata1_loc->data.poly, 
                             &bs_crv);
     EMerr_hndlr ((!stat_func || EMSerror (msg_loc)), *msg, EMS_E_Fail, 
		      ret_end);
     EMtrim_bspline_against_bspline(&msg_loc, options, 
                 intdata2_loc->data.curve, &bs_crv, uvtol, NULL, NULL, TRUE, 
                 data1_props, NULL, NULL, num_inters, &p_epar, intinfo2);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  else if(intdata2_loc->datatype == EMSdata_poly2d)
  {
     stat_func = EMcnvtpybsn(&msg_loc, 2, intdata2_loc->data.poly, 
                             &bs_crv);
     EMerr_hndlr ((!stat_func || EMSerror (msg_loc)), *msg, EMS_E_Fail, 
		     ret_end);
     EMtrim_bspline_against_bspline(&msg_loc, options, 
            &bs_crv, intdata1_loc->data.curve, uvtol, NULL, NULL, FALSE, 
            data1_props, NULL, NULL, num_inters, &p_epar, intinfo2);
     EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  else  /* both curves in b-spline format */
  {
        EMtrim_bspline_against_bspline(&msg_loc, options, 
            intdata2_loc->data.curve, intdata1_loc->data.curve, uvtol, NULL, 
            NULL, FALSE, data1_props, NULL, NULL, num_inters, &p_epar,intinfo2);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }


 /* Due to the unique nature of the 2dpycutint code (which was basically 
  * developed to trim intersections against boundaries) we also have to project
  * the endpts of intdata1 onto intdata2 to see if they do lie on it, since 
  * these endpt intersections may not be returned. The other way round is okay,
  * though (i.e. if intdata2 endpts lie on intdata1, they will definitely be
  * returned as intersections, due to the INTER_STARTPT, INTER_STOPPT options).
  * Get the start point of "intdata1". Check if it has alaready been returned as
  * an intersection between the two. If not, project it onto "intdata2". If it
  * lies on "intdata2", add this as in intersection point between the two
  * datadelects.
  */
  stat_func = EMgetendpts (&msg_loc, mattyp, mat, intdata1_loc, 
                      intdata1_reversed, 1, intdata1_startpt, intdata1_stoppt, 
                      FALSE);
  EMerr_hndlr (!(1&msg_loc&stat_func), *msg, EMS_E_Fail, ret_end);
  intdata1_startpt[2] =  0.0; /* uv point */
  intdata1_stoppt[2]  =  0.0; /* uv point */

 for (i=0; i<2; i++)
 {
   if (i==0)
      OM_BLOCK_MOVE (intdata1_startpt, intdata1_endpt, sizeof(IGRpoint));
   else
      OM_BLOCK_MOVE (intdata1_stoppt, intdata1_endpt, sizeof(IGRpoint));

   /* make sure this point has not already been returned above. */
   found = FALSE;
   if (p_epar)
   { p_epar_loc = p_epar;
     while (p_epar_loc)
     {
        OM_BLOCK_MOVE (p_epar_loc->point, test_pt, 2 * sizeof(IGRdouble) );
        test_pt[2]=0.0; /* 'cos UV data */ 
        if (BSdistptpts(&msg_loc, intdata1_endpt, test_pt) <= (uvtol*uvtol)) 
        {  found = TRUE;
           break;
        }
        p_epar_loc = p_epar_loc->next;
     }
   }
  
   new_epar = NULL;
   projpt1 = NULL;
   projpt2 = NULL;

   if (!found)
   {
    

    /* project this endpt of intdata1 onto itself, to get the span-inx and
     * param for endpts, which we need to store in the sfintedpar structure.
     */
    if (i==1)
    {
       /* Dont need to do this for startpt, which is span-inx=0, param=0.0 */
       projpt1 = EMpypoint_malloc (&msg_loc, 1);
       EMerr_hndlr (!projpt1, *msg, EMS_E_NoDynamicMemory, ret_end);
       EMprojectpt(&msg_loc, mattyp, mat, intdata2_loc, 1, intdata1_endpt, 
                    uvtol, projpt1, &mindist1);
       EMerr_hndlr (!(1&msg_loc), *msg, msg_loc, ret_end);
       projpt1->point[2]=0.0; /* VERY IMPORTANT */
    }

    /* project this endpt of intdata1 onto intdata2 */
    projpt2 = EMpypoint_malloc (&msg_loc, 1);
    EMerr_hndlr (!projpt2, *msg, EMS_E_NoDynamicMemory, ret_end);
    EMprojectpt(&msg_loc, mattyp, mat, intdata2_loc, 1, intdata1_endpt, uvtol,
                 projpt2, &mindist2);
    EMerr_hndlr (!(1&msg_loc), *msg, msg_loc, ret_end);
    projpt2->point[2]=0.0; /* VERY IMPORTANT */
  
  
    if (mindist2 <= uvtol) /*introduce this point*/
    {
      new_epar = EMsfintedpar_malloc (&msg_loc, 1);
      EMerr_hndlr (!new_epar, *msg, EMS_E_NoDynamicMemory, ret_end);
  
      /* function supposedly supports re-entrant behaviour for intinfo2????*/
      if (intinfo2)
      {  if (*intinfo2)
         {  temp_ptr = *intinfo2;
            while (temp_ptr->next)
               temp_ptr = temp_ptr->next; 
            temp_ptr->next = projpt2;
         }
         else
           *intinfo2 = projpt2;

         projpt2->next = NULL;
      }
      /* Although the output finally is pypoints, at this stage we must add the
       * new point into the sfintedpar for the first dataselect.
       *
       * FIX : In the following block p_epar->next = new_par was used instead 
       *       of p_epar_loc->next = new_par, because of which any thing can
       *       happen. Fixed the problem - Sanjay
       */
      if (p_epar)
      {
       p_epar_loc = p_epar;
       while (p_epar_loc->next)
         p_epar_loc = p_epar_loc->next;
       p_epar_loc->next = new_epar;
      }
      else
        p_epar = new_epar;
    
      new_epar->intloc = (i==0? EMScvint_lfend : EMScvint_rtend);
      new_epar->edgeid = NULL_OBJID;
      new_epar->edgepar.span_inx = (i==0 ? 0    : projpt1->span_inx); 
      new_epar->edgepar.param    = (i==0 ? 0.0  : projpt1->param); 
      OM_BLOCK_MOVE (intdata1_endpt, new_epar->point, 2 * sizeof(IGRdouble));
      new_epar->next = NULL;
     
    
      /* update the intersection count */
      (*num_inters)++;
    
      new_epar = NULL;
    } /* if (mindist <= uvtol) */
    else
       if(projpt2)
       {
	  EMpypoint_free(projpt2, MAXINT);
       }

    if(i == 1 && projpt1) EMpypoint_free(projpt1, MAXINT);

    projpt1 = NULL;
    projpt2 = NULL;
   }/*if (!found) */

 }/*for*/



 if(intinfo2 && *intinfo2)
   if (*num_inters && intinfo1)
   {
    /* 
     * The intersection info returned for the first data is in
     * EMSsfintedpar format. Convert it into EMSpypoint format for
     * output.
     */
    p_pypt = EMpypoint_malloc (&msg_loc, *num_inters);
    EMerr_hndlr (!p_pypt, *msg, EMS_E_NoDynamicMemory, ret_end);

    if(*intinfo1)
    {
      loc_pypt = *intinfo1;
      while(loc_pypt->next)
        loc_pypt = loc_pypt->next;

      loc_pypt->next = p_pypt;
    }
    else
      *intinfo1 = p_pypt;

    if(loc_pypt2)
       loc_pypt2 = loc_pypt2->next;
    else
       loc_pypt2 = (intinfo2 ? *intinfo2 : NULL);

    p_epar_loc = p_epar;
    while(p_epar && p_pypt)
    {
      OM_BLOCK_MOVE (p_epar->point, p_pypt->point, 2 * sizeof (IGRdouble));
      p_pypt->span_inx = p_epar->edgepar.span_inx;
      p_pypt->param = p_epar->edgepar.param;

      /* Associate the corresponding PYPTs via the 'info' field. */
      p_pypt->info = (loc_pypt2 ? (IGRchar *)loc_pypt2 : NULL);
      if(loc_pypt2)
      {
	loc_pypt2->info = (IGRchar *) p_pypt;
        
        /* The "loc_pypt2" linked list pertains to "intdata2".
         * Since the pypoint list for "intdata2" was obtained without applying
         * the "intdata2_reversed" parameter (since we are working on the 
         * natural geometry of the dataselect), we update the properties here. 
         * (i.e. ATSTART becomes ATSTOP and vice versa.Other props dont change).
         * NOTE: The fancy "if" condition is necessary because the properties 
         * ----  are w.r.t. the NATURAL direction of dataselect and we want to
         *       check if the naturl direction is also the final LOGICAL dir.
         *       after all the reverse flags are applied.
         */
        if (dataselect2_rev? !intdata2_reversed : intdata2_reversed)
        {
           if (loc_pypt2->props&EMS_PYPT_ATSTART)
           { loc_pypt2->props |=  EMS_PYPT_ATSTOP;
             loc_pypt2->props &= ~EMS_PYPT_ATSTART;
           } 
           if (loc_pypt2->props&EMS_PYPT_ATSTOP)
           { loc_pypt2->props |=  EMS_PYPT_ATSTART;
             loc_pypt2->props &= ~EMS_PYPT_ATSTOP;
           } 
        }
      }

      /* "p_epar->intloc" has NOT taken the "intdata1_reversed"  bit into 
       * account yet, since we have worked on the natural geometry of the 
       * dataselects so far. Check if the logical direction is opposite of the
       * natural direction.
       */

       reverse = dataselect1_rev ? !intdata1_reversed : intdata1_reversed;

      if (p_epar->intloc == EMScvint_middle)
        p_pypt->props |= EMS_PYPT_ATMIDDLE;
      else if ((p_epar->intloc == EMScvint_rtend)       || 
               (p_epar->intloc == EMScvint_rtendcoll))
        p_pypt->props |= (reverse?(EMS_PYPT_ATEND | EMS_PYPT_ATSTART):
                                  (EMS_PYPT_ATEND | EMS_PYPT_ATSTOP));
      else if ((p_epar->intloc == EMScvint_lfend)       || 
               (p_epar->intloc == EMScvint_lfendcoll))
        p_pypt->props |=(reverse?(EMS_PYPT_ATEND | EMS_PYPT_ATSTOP):
                                 (EMS_PYPT_ATEND | EMS_PYPT_ATSTART));
      else  /* Trap ALL other cases */
      {  
         /* make sure "Z" co-ordinate is set to zero before making the math 
          * call.
          */
         OM_BLOCK_MOVE(p_pypt->point, test_pt, sizeof(IGRdouble) * 2);
         test_pt[2]  = 0.0;/* 'cos "p_pypt->point" is a UV pt */

         /* Get the LOGICAL endpts of the dataselect keeping in mind that the
          * pypoint props are always w.r.t. the LOGICAL direction of dataselect.
          * Note that the "dataselect1_rev" flag (which makes sense for 
          * EMSedge objects ONLY) is taken care of by the function internally. 
          */
         stat_func = EMgetendpts_uv (&msg_loc, intdata1, intdata1_reversed, 
                          1, start_pt, stop_pt);
         EMerr_hndlr (!(1&stat_func&msg_loc), *msg, EMS_E_Fail, ret_end);
         start_pt[2] = 0.0;/* 'cos this is a UV point */
         stop_pt [2] = 0.0;/* 'cos this is a UV point */
  
         
         if (BSdistptpts(&msg_loc, test_pt, start_pt) < (uvtol*uvtol)) 
            p_pypt->props |= EMS_PYPT_ATEND | EMS_PYPT_ATSTART;
         else if (BSdistptpts(&msg_loc, test_pt, stop_pt) < (uvtol*uvtol))
            p_pypt->props |= EMS_PYPT_ATEND | EMS_PYPT_ATSTOP;
         else
            p_pypt->props |= EMS_PYPT_ATMIDDLE;
      }
     
      /* if necessary, convert the span-inx/param on both the dataselects (if
       * they were part-edges) so that they are now w.r.t. the natural
       * geometry of the full-edge.
       */ 


      if (partedge1 && p_pypt)
      {
        inpar.span_inx = p_pypt->span_inx;
        inpar.param = p_pypt->param;

        EMcnvtedpar(&msg_loc,&bound1[0],&bound1[1],&inpar, &outpar);
        EMerr_hndlr(!(1&msg_loc),*msg,EMS_E_Fail,ret_end);

        p_pypt->span_inx = outpar.span_inx; 
        p_pypt->param = outpar.param; 
      }


      if (partedge2 && loc_pypt2)
      {
        inpar.span_inx = loc_pypt2->span_inx;
        inpar.param = loc_pypt2->param;

        EMcnvtedpar(&msg_loc,&bound2[0],&bound2[1],&inpar, &outpar);
        EMerr_hndlr(!(1&msg_loc),*msg,EMS_E_Fail,ret_end);

        loc_pypt2->span_inx = outpar.span_inx; 
        loc_pypt2->param = outpar.param; 
      }

      p_epar = p_epar->next;
      p_pypt = p_pypt->next;
      loc_pypt2 = loc_pypt2->next;
    
    } /* while(p_epar) */
    p_epar = p_epar_loc;

  } /* if(*num_inters) */

ret_end:

  EMdataselect_data_free (&msg_loc, &simpledata1, 1);
  EMdataselect_data_free (&msg_loc, &simpledata2, 1);

  if (p_epar)
    EMsfintedpar_free (p_epar, MAXINT);

  if (bs_crv.poles) om$dealloc(ptr = bs_crv.poles);
  if (bs_crv.knots) om$dealloc(ptr = bs_crv.knots);
  if (bs_crv.weights) om$dealloc(ptr = bs_crv.weights);

  EMWRAPUP (*msg, stat_func, "EFget_intersection_pts");
  return;
}

/* 
   DESCRIPTION

     Following function deallocates the memory in the 'dataselect'
     structure. The function frees an array of 'num' structures starting at 
     the input address.

   HISTORY

     10-Oct-87  SM  Creation
     17-Jul-89  SM  Do not delete model space curve objects if they are owned
		    rigidly or flexibly. The check is required because the
		    GRgraphics.GRdelete method deletes the objects regardless
		    of the senderid being ownerid.
*/

void EMdataselect_data_free (msg, dataselect, num)
IGRlong *msg;
struct EMSdataselect *dataselect;
IGRint num;
{
  IGRboolean data_dealloced;
  OMuint numowners;
  IGRint stat_OM, i;
  IGRlong msg_loc;
  struct GRmd_env loc_mdenv;
  GRspacenum osnum;
  GRobjid objid;
  union EMSdata data;
  enum EMSdatatype datatype;
  OMuword obj_classid;
  OM_S_CHANSELECT to_owners;
  void EMidmatrix();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  for(i=0; i<num; i++)
    {
    if (dataselect)
      {
      datatype = dataselect->datatype;
      data = dataselect->data;
      data_dealloced = FALSE;
      if (datatype == EMSdata_object)
        {
        osnum = data.object->osnum;
        objid = data.object->objid;
	stat_OM = om$is_objid_valid(objid = objid, osnum = osnum);

	if (stat_OM == OM_S_SUCCESS)
          {
          stat_OM = om$get_classid(osnum = osnum, objid = objid, 
                     p_classid = &obj_classid);
          EMomerr_exit (stat_OM, ret_end);
	
          stat_OM = OM_I_INVANCESTRY;
#         ifndef IDRAW
	  stat_OM = om$is_ancestry_valid (subclassid = obj_classid, 
                     superclassid = OPP_EMSboundary_class_id);
          EMomerr_exit (stat_OM, ret_end);
#	  endif

          if (stat_OM == OM_S_SUCCESS)
            {
            stat_OM = om$send (msg = message Root.delete (TRUE),
                       targetid = objid, targetos = osnum, 
                       senderid = NULL_OBJID);
            EMomerr_exit (stat_OM, ret_end);
            }
          else
            {
            stat_OM = EMmake_chanselect (GRconnector_to_owners, &to_owners);
            EMomerr_exit (stat_OM, ret_end);

            stat_OM = om$get_channel_count(objid = objid, osnum = osnum, 
				p_chanselect = &to_owners, count = &numowners);
            EMomerr_exit (stat_OM, ret_end);				

	    if (!numowners)
              {
              stat_OM = ex$get_modid (mod_osnum = osnum, 
                         mod_id = &loc_mdenv.md_id.objid);
              EMomerr_exit (stat_OM, ret_end);
              loc_mdenv.md_id.osnum = osnum;

              EMidmatrix (&msg_loc, &loc_mdenv.md_env.matrix_type, 
               loc_mdenv.md_env.matrix);

              stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc,
                         &loc_mdenv), targetid = objid, targetos = osnum,
                         senderid = NULL_OBJID);
              if(!(1&stat_OM&msg_loc))
               {
	        loc_mdenv.md_id.objid = NULL_OBJID;
	
                stat_OM = om$send (msg = message GRgraphics.GRdelete (&msg_loc,
                         &loc_mdenv), targetid = objid, targetos = osnum,
                         senderid = NULL_OBJID);
               }

              EMomerr_exit (stat_OM, ret_end); 
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
              }
            }
          }
	else 
          stat_OM = OM_S_SUCCESS;

        om$dealloc (ptr = data.object);
        data_dealloced = TRUE;
        }
      else if (datatype == EMSdata_poly2d || datatype == EMSdata_poly3d)
        {
        if (data.poly->points)
          om$dealloc (ptr = data.poly->points);
        om$dealloc (ptr = data.poly);
        data_dealloced = TRUE;
        }
      else if (datatype == EMSdata_curve3d || datatype == EMSdata_curve2d)
        {
        if (data.curve->poles)
          om$dealloc (ptr = data.curve->poles);
        if (data.curve->knots)
          om$dealloc (ptr = data.curve->knots);
        if (data.curve->rational && data.curve->weights)
          om$dealloc (ptr = data.curve->weights);
        om$dealloc (ptr = data.curve);
        data_dealloced = TRUE;
        }
      else if (datatype != EMSdata_null)
        {
        *msg = EMS_E_Fail;
        goto ret_end;
        }

      if (data_dealloced)
        dataselect->datatype = EMSdata_null;
      }
    dataselect++;
    }

ret_end:;
  EMWRAPUP (*msg, stat_OM, "EMdataselect_data_free");
  if (EMSerror (stat_OM))
    *msg = EMS_E_OMerror;
}


/*
  DESCRIPTION

    This function may be used to detect degeneracy in a given
    EMSdataselect.

  HISTORY

    SS  :  11/23/88  :  Creation
*/

IGRboolean EMdegenerate_data (data, xyz, tol)
struct EMSdataselect *data;
IGRboolean xyz;
IGRdouble *tol;
{
  IGRboolean degenerate;
  IGRushort props;
  IGRshort dim;
  IGRint i, j, k, inxlim, blksize, num_points;
  IGRlong msg_loc, stat_OM;
  IGRdouble cumdistsq, lentol, lentolsq;
  IGRdouble *points, *weights, point1[3], point2[3];
  GRspacenum osnum;
  GRobjid objid;
  GRclassid obj_classid;
  struct IGRbsp_curve *crv;
  enum EMSdatatype dattyp;

  if (tol)
    lentol = *tol;
  else
    {
    if (xyz)
      BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
    else
      lentol = EMS_HIGH_UVLENTOL;
    }
  lentolsq = lentol * lentol;

  degenerate = TRUE;
  dattyp = data->datatype;
  switch (dattyp)
    {
    case EMSdata_poly2d:
    case EMSdata_poly3d:
      dim = dattyp == EMSdata_poly2d ? 2 : 3;
      num_points = data->data.poly->num_points;
      points = data->data.poly->points;
      inxlim = (num_points - 1) * dim;
      cumdistsq = 0.0;
      degenerate = TRUE;
      for (i=0; i<inxlim; i+=dim)
        {
        cumdistsq += dim == 2 ? 
                      (EM2ddistptpts (&points[i], &points[i+2])) :
                      BSdistptpts (&msg_loc, &points[i], &points[i+3]);
        if (cumdistsq > lentolsq)
          {
          degenerate = FALSE;
          break;
          }
        }
      break;

    case EMSdata_curve2d:
    case EMSdata_curve3d:
      dim = dattyp == EMSdata_curve2d ? 2 : 3;
      crv = data->data.curve;
      num_points = crv->num_poles;
      points = crv->poles;
      if (crv->rational)
        weights = crv->weights;
      else
        weights = NULL;
      inxlim = (num_points - 1) * dim;
      cumdistsq = 0.0;
      blksize = dim * sizeof (IGRdouble);
      for (i=0, j=0; i<inxlim; i+=dim, j++)
        {
        OM_BLOCK_MOVE (&points[i], point1, blksize);
        OM_BLOCK_MOVE (&points[i+dim], point2, blksize);
        if (weights)
          for (k=0; k<dim; k++)
            {
            point1[k] /= weights[j];
            point2[k] /= weights[j];
            }

        cumdistsq += dim == 2 ? 
                      (EM2ddistptpts (point1, point2)) :
                      BSdistptpts (&msg_loc, point1, point2);
        if (cumdistsq > lentolsq)
          {
          degenerate = FALSE;
          break;
          }
        }
      break;

    case EMSdata_object:
      osnum = data->data.object->osnum;
      objid = data->data.object->objid;

      stat_OM = om$get_classid(osnum = osnum, objid = objid, 
                 p_classid = &obj_classid);
      EMomerr_exit (stat_OM, ret_end);
	
      stat_OM = OM_I_INVANCESTRY;
#     ifndef IDRAW
      stat_OM = om$is_ancestry_valid (subclassid = obj_classid, 
                 superclassid = OPP_EMSedge_class_id);
      EMomerr_exit (stat_OM, ret_end);
#     endif

      if (stat_OM == OM_S_SUCCESS)
        {
#       ifndef IDRAW
        stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc,
                   &props), targetid = objid, targetos = osnum, 
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, ret_end);

        if (! (props & EMED_DEGENERATE))
          degenerate = FALSE;
#       endif
        }
      else
        {
        stat_OM = om$is_ancestry_valid (subclassid = obj_classid, 
                   superclassid = OPP_GRpoint_class_id);
        EMomerr_exit (stat_OM, ret_end);

        if (stat_OM != OM_S_SUCCESS)
          degenerate = FALSE;
        }
      break;

    default:
      degenerate = FALSE;
    }

ret_end:
  return (degenerate);
}



/*
  DESCRIPTION

    This funcntion is used to split a given EMSdataselect structure into
    two, using split point information. The fields inside the split_data
    are malloced by this routine.

 NOTE: The splitting of edges can also be done using the method EMsplityourself.
       To explore replacing some of the code below with this method. The method
       can work on a single edge or a pair (common edge). We want it work on a 
       single edge here. Although the method updates the loop containing the 
       split edge with the two new edges, the loop properties have to be updated
       in the function below as it is currently done.

 HISTORY:
 
 NP : 03/22/93 :  When an EMSedge is split and it belongs to an existing ACTIVE
                  loop, replace it in the loop with the new split edges. Also
                  turn OFF the EMLP_MSCEXISTS and EMLP_NATURAL property of 
                  the loop.
                   

*/

IGRboolean EMsplit_data (msg, mdenv_info, data, span_inx, param, world,
                         split_pt, split_data1, split_data2)
IGRlong *msg;
struct GRmdenv_info *mdenv_info;
struct EMSdataselect *data;
IGRint span_inx;
IGRdouble param;
IGRboolean world;
IGRpoint split_pt;
struct EMSdataselect *split_data1, *split_data2;
{
  IGRlong msg_loc, stat_OM;
  IGRint i, num_pts, dim, blksize;
  IGRdouble *pts;
  IGRpoint midpt, pts2[2];
  IGRlong EMeval_data();
  struct EMSpypoint *pypt, *pybdry, pypts_mem[2];
  struct IGRpolyline *py;
  struct IGRbsp_curve *cv;
  struct EMSdataselect *split_datas[2];

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMeval_data (&msg_loc, mdenv_info, data, span_inx, param, world, midpt);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
  if (split_pt)
    OM_BLOCK_MOVE (midpt, split_pt, sizeof (IGRpoint));

  split_datas[START] = split_data1;
  split_datas[STOP] = split_data2;

  switch (data->datatype )
    {
    case EMSdata_poly2d:
    case EMSdata_poly3d:
    case EMSdata_curve3d:
      dim = data->datatype == EMSdata_poly2d ? 2 : 3;
      blksize = dim * sizeof (IGRdouble);

      pybdry = &pypts_mem[FIRST];
      pypt = pybdry->next = &pypts_mem[SECOND];

      OM_BLOCK_MOVE (midpt, pypt->point, blksize);
      pypt->param = param;
      pypt->span_inx = span_inx;
      pypt->props = EMS_PYPT_ATMIDDLE;

      if (data->datatype == EMSdata_curve3d)
        {
        MAbcendpts (&msg_loc, data->data.curve, pts2[START], pts2[STOP]);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, wrapup);
        num_pts = 2;
        pts = (IGRdouble *) pts2;
        }
      else
        {
        num_pts = data->data.poly->num_points;
        pts = data->data.poly->points;
        }

      for (i=START; i<=STOP; i++)
        {
        if (i == START)
          {
          OM_BLOCK_MOVE (pts, pybdry->point, blksize);
          pybdry->param = 0.0;
          pybdry->span_inx = 0;
          pybdry->props = EMS_PYPT_ATSTART;
          }
        else
          {
          OM_BLOCK_MOVE (&pts[(num_pts-1)*dim], pybdry->point, blksize);
          pybdry->param = 1.0;
          pybdry->span_inx = num_pts-2;
          pybdry->props = EMS_PYPT_ATSTOP;
          }

        if (data->datatype == EMSdata_curve3d)
          {
          cv = (struct IGRbsp_curve *) om$malloc (size = 
                sizeof (struct IGRbsp_curve));
          EMerr_hndlr (!cv, *msg, EMS_E_NoDynamicMemory, wrapup);
          cv->poles = NULL;
          cv->knots = NULL;
          cv->weights = NULL;

          split_datas[i]->data.curve = cv;
          }
        else
          {
          py = (struct IGRpolyline *) om$malloc (size = 
                sizeof (struct IGRpolyline));
          EMerr_hndlr (!py, *msg, EMS_E_NoDynamicMemory, wrapup);
          py->points = NULL;

          split_datas[i]->data.poly = py;
          }

        EMgetactgm (&msg_loc, data, pybdry, split_datas[i]);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
        *msg = msg_loc;
        }
      break;

    case EMSdata_object:

		  /* The algorithm is as follows:
		   * 1. Get the bounds of the input object.
		   * 2. Make two objects out of the input object,by calling the
		   *	"EMmkintdata" function for the two parts of the input
		   * 	object that we are interested in.
		   * 3. Return the two objects.
		   *
		   * NOTE:
		   *  *	The only object types that are assumed to come into
		   *	this function are "EMSedge" and "GRcurve".
		   */
		  {
		  IGRdouble			start_pt[3],end_pt[3];
		  IGRushort	 		props, cv_prop;
		  IGRuchar	 		cv_type;
		  struct EMSedgebound		start_param, end_param;
		  struct IGRdisplay 		disp_attr;
		  struct GRmd_env		mdenv;
		  struct GRvg_construct 	cnstr_list;
		  struct EMSpypoint		bdry[2];
		  OM_S_OBJID			objid;
                  GRobjid                       split_edges[2], original_edge;


		  /* Create the construction list for the OM-objects about to 
		   * be constructed. Create the "GRmd_env" struct from the 
		   * "GRmdenv_info" struct that is passed in. This is required
		   * for the EMinitvgcnstr & EMgetvgcnstr calls below.
		   */
		   mdenv.md_env = *mdenv_info; /* passed into this fn.*/

/******************Don't understand why is this?****************************

		   stat_OM = om$osnum_to_oso_objid ( 
				osnum=data->data.object->osnum,
				p_objid= &objid);
       		   EMerr_hndlr( !(stat_OM & 1), *msg, EMS_E_OMerror,wrapup);

*******************27/05/94 - Vadi*******************************************/

                   stat_OM = ex$get_modid(mod_osnum = data->data.object->osnum,
                                          mod_id =  &objid);
                   EMerr_hndlr( !(stat_OM & 1), *msg, EMS_E_OMerror,wrapup);

		   mdenv.md_id.objid    = objid; 
		   mdenv.md_id.osnum    = data->data.object->osnum; 

		   EMinitvgcnstr (&msg_loc, &mdenv, &disp_attr, NULL, 
				&cnstr_list);
    		   EMgetvgcnstr  (NULL, NULL, &mdenv, DEFAULT_GR_LEVEL,
                    		NULL, NULL, NULL, &cnstr_list);

		  /* Get the bounds of the intobj so that we can split it into
		   * two parts at the split point. Note that this method returns
		   * the LOGICAL bounds (also, bounds[0]==START & bounds[1]=END)
		   * Also get the end-point values.The bounds is an EMSedgebound
		   * while the end-point values are IGRpoint structures.
		   */

		  if (world) /* GRcurve object */
		  { 	
			/* get the end-points */
			stat_OM=EMgetendpts_xyz(&msg_loc, &(mdenv_info->matrix_type),
						mdenv_info->matrix, data,
						FALSE, 1, start_pt, end_pt);
		  	EMerr_hndlr (!(stat_OM&msg_loc&1), *msg, EMS_E_Fail, wrapup);

			/* fill in the end parameters for the GRcurve */
			start_param.param    = 0.0;
			start_param.span_inx = 0.0;
			end_param.param      = 1.0;
			end_param.span_inx   = 0.0;
			
			/* for want of better information */
			cv_type = EMfreeform_curve;	
			cv_prop = NULL;
		  }
		  else /* EMSedge object */
		  {
			/* get both the end-points and the end-parameters */
			stat_OM = om$send (msg = message EMSedge.EMendpts (&msg_loc,
                   				start_pt, end_pt, 
						&start_param, &end_param, NULL),
                   			targetid = data->data.object->objid,
                   			targetos = data->data.object->osnum,
                   			senderid = NULL_OBJID);
		  	EMerr_hndlr (!(stat_OM&msg_loc&1), *msg, EMS_E_Fail, wrapup);

		    	/* get the properties of the edge object */
		    	stat_OM = om$send(msg=message EMSedge.EMget_props_type
						(&msg_loc, &props, &cv_type),
					targetid = data->data.object->objid,
					targetos = data->data.object->osnum,
					senderid = NULL_OBJID);
		    	EMerr_hndlr (!(stat_OM&msg_loc&1), *msg, EMS_E_Fail, wrapup);

		    	/* Currently, EMmkintdata only wants to know if the 
			 * curve is an iso-curve or not.
			 * Note that an edge is an iso-edge if EITHER it is
			 * explicitly set to "EMED_ISO" OR else we know that it
			 * is a NATURAL edge, which by necessity is ISO
		   	 */
		    	cv_prop = ((props & EMED_ISO) || (props & EMED_NATURAL))
				         ?  EMSintdata_isoedge : NULL;


		  }

		  /* To create two new objects out of the input object, we call
		   * the EMmkintdata function twice. To specify the boundary of 
		   * the object that we are interested in, an EMSpypoint 
		   * linked list structure is passed in. The linked list is 
		   * initialized for each call depending on the part of the 
		   * boundary that we are interested in.
		   */

		  bdry[0].next = &(bdry[1]); /* form the linked list */

		  /* Fill the EMSpypoint linked list for the first part, 
		   * i.e. from start to split point
		   */
		  bdry[0].point[0] = start_pt[0];
		  bdry[0].point[1] = start_pt[1];
		  bdry[0].point[2] = start_pt[2];
		  bdry[0].param    = start_param.param;
		  bdry[0].span_inx = start_param.span_inx;

		  bdry[1].point[0] = midpt[0];
		  bdry[1].point[1] = midpt[1];
		  bdry[1].point[2] = midpt[2];
		  bdry[1].param    = param;
		  bdry[1].span_inx = span_inx;
			
		  /* We now call EMmkintdata to create the edge object */
		  /* First part */
		  stat_OM = EMmkintdata (&msg_loc, data, cv_type, cv_prop,
					world, bdry, &cnstr_list,
					TRUE, NULL, NULL, split_data1);
		  EMerr_hndlr (!(stat_OM&msg_loc&1), *msg, EMS_E_Fail, wrapup);

		  /* Fill the EMSpypoint linked list for the second part, 
		   * i.e. from split point to end
		   */
		  bdry[0].point[0] = midpt[0];
		  bdry[0].point[1] = midpt[1];
		  bdry[0].point[2] = midpt[2];
		  bdry[0].param    = param;
		  bdry[0].span_inx = span_inx;

		  bdry[1].point[0] = end_pt[0];
		  bdry[1].point[1] = end_pt[1];
		  bdry[1].point[2] = end_pt[2];
		  bdry[1].param    = end_param.param;
		  bdry[1].span_inx = end_param.span_inx;
			
		  /* We now call EMmkintdata to create the second edge object */
		  /* Second part */
		  stat_OM = EMmkintdata (&msg_loc, data, cv_type, cv_prop,
						world, bdry, &cnstr_list,
						TRUE, NULL, NULL, split_data2);
		  EMerr_hndlr (!(stat_OM&msg_loc&1), *msg, EMS_E_Fail, wrapup);



                  /* if  original unsplit object was an edge, check if it 
                   * belonged to any ACTIVE loop. If so, replace the edge in the
                   * active loop by the two new edge ids.
                   */

                   if(!IF_NULL_OBJID(split_data1->data.object->objid) && 
                      !IF_NULL_OBJID(split_data2->data.object->objid) && !world)
                   {
                     original_edge  = data->data.object->objid; 
                     split_edges[0] = split_data1->data.object->objid;
                     split_edges[1] = split_data2->data.object->objid;

                     /* If the edge is not connected to any loops, this message
                      * will come back with OM_I_CHAN_EMPTY. Else it will send
                      * the "EMSloop.EMmodify_edge" to the ACTIVE loop.
                      */
                     stat_OM = EMsend_loops(msg,
                                 message EMSloop.EMmodify_edge
                                   (&msg_loc, EMS_INS_REPLACE, 2, original_edge,
                                   split_edges, FALSE),
                                 original_edge, 0, MAXINT, EMLP_ACTIVE, NULL, 
                                 NULL);
		     EMerr_hndlr(!(stat_OM&msg_loc&1),*msg,EMS_E_Fail,wrapup);

                 
                     /* update the properties of the active loop. The 
                      * "original_edge" is NOT connected to it anymore.If 
                      * the "split_edges[0]" edge is also not connected to any 
                      * loop, (for e.g. when the original edge itself is not 
                      * connected to any loop,) this message will just return.
                      */
                     stat_OM = EMsend_loops(msg,
                                 message EMSloop.EMset_props
                                   (&msg_loc, EMLP_MSCEXISTS|EMLP_NATURAL,
                                    EMS_O_OFF),
                                 split_edges[0], 0, MAXINT, EMLP_ACTIVE, NULL,
                                 NULL);
                     EMerr_hndlr(!(stat_OM&msg_loc&1),*msg,EMS_E_Fail,wrapup);

                   }
 
		  }

                  break;
       default :
                  *msg = EMS_E_InvalidArg;
                   goto wrapup;
     }

wrapup:
    EMWRAPUP (stat_OM, *msg, "EMsplit_data");
    return (!EMSerror (stat_OM & *msg));
}



IGRlong EMeval_data (msg, mdenv_info, data, span_inx, param, world,
                     point)
IGRlong *msg;
struct GRmdenv_info *mdenv_info;
struct EMSdataselect *data;
IGRint span_inx;
IGRdouble param;
IGRboolean world;
IGRpoint point;
{
  IGRlong msg_loc, stat_OM;
  IGRint i, inx, blksize, dim;
  IGRdouble *pts;
  struct EMSedgebound edgebound;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  switch (data->datatype )
    {
    case EMSdata_poly2d:
    case EMSdata_poly3d:
      dim = data->datatype == EMSdata_poly2d ? 2 : 3;
      blksize = dim * sizeof (IGRdouble);
      pts = data->data.poly->points;
      inx = span_inx * dim;
      if (param == 0.0)
        OM_BLOCK_MOVE (&pts[inx], point, blksize);
      else if (param == 1.0)
        OM_BLOCK_MOVE (&pts[inx+dim], point, blksize);
      else 
        for (i=0; i<dim; i++)
          point[i] = pts[inx+i] + param * (pts[inx+i+dim] - pts[inx+i]);
      break;

    case EMSdata_curve2d:
    case EMSdata_curve3d:
      BScveval (data->data.curve, param, 0, (IGRpoint *)point, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
      break;

    case EMSdata_object:
      if (world)
        stat_OM = om$send (msg = message GRvg.EMptatpr (&msg_loc, 
         &mdenv_info->matrix_type, mdenv_info->matrix, &param, 1, point),
         targetid = data->data.object->objid,
         targetos = data->data.object->osnum,
         senderid = NULL_OBJID);
      else
        {
        edgebound.param = param;
        edgebound.span_inx = span_inx;
        stat_OM = om$send (msg = message EMSedge.EMptatpr (&msg_loc, 1,
                   &edgebound, NULL, point),
         targetid = data->data.object->objid,
         targetos = data->data.object->osnum,
         senderid = NULL_OBJID);
        }
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      break;

    default:
      *msg = EMS_E_InvalidArg;
    }

ret_end:
  EMWRAPUP (stat_OM, *msg, "EMeval_data");
  return (stat_OM);
}

#argsused

IGRlong EMend_modify_data (msg, mdenv_info, data, at_start, new_endpt)
IGRlong *msg;
struct GRmdenv_info *mdenv_info;
struct EMSdataselect *data;
IGRboolean at_start;
IGRpoint new_endpt;
{
  IGRlong stat_OM;
  IGRint i, inx, dim;
  struct IGRpolyline *py;
  struct IGRbsp_curve *cv;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  switch (data->datatype )
    {
    case EMSdata_poly2d:
    case EMSdata_poly3d:
      dim = data->datatype == EMSdata_poly2d ? 2 : 3;
      py = data->data.poly;
      if (at_start)
        inx = 0;
      else
        inx = dim * (py->num_points-1);
      OM_BLOCK_MOVE (new_endpt, &py->points[inx], dim * sizeof (IGRdouble));
      break;

    case EMSdata_curve3d:
      cv = data->data.curve;
      if (at_start)
        inx = 0;
      else
        inx = 3 * (cv->num_poles-1);
      OM_BLOCK_MOVE (new_endpt, &cv->poles[inx], sizeof (IGRpoint));
      if (cv->rational && cv->weights)
        for (i=X; i<=Z; i++)
          cv->poles[inx+i] *= cv->weights[at_start ? FIRST : cv->num_poles-1];
      break;

    default:
      *msg = EMS_E_InvalidArg;
    }

/***
ret_end:
       COMPILER COMPLAINS IF NOBODY REFERS TO LABEL. REMOVE LATER IF REFERENCED.
*****/


  EMWRAPUP (stat_OM, *msg, "EMend_modify_data");
  return (stat_OM);
}

IGRboolean EMis_same_dataselect (data1, data2)
struct EMSdataselect *data1, *data2;
{
  if (data1->datatype == data2->datatype &&
      data1->data.curve == data2->data.curve)
    return (TRUE);
  else
    return (FALSE);
}


/* DESCRIPTION:
   
   The dataselect #1 is projected onto dataselect #2 to find out if the whole 
   dataselect lies completely WITHIN dataselect #2. This DOES NOT guarantee that
   whole of the dataselect #2 will similarly overlap with dataselect #1. To 
   check if the dataselects match EXACTLY, this function has to be called twice,
   with the dataselect operands switched the second time. All that this function
   can determine is whether dataselect #1 is a SUBSET of dataselect #2.

   NOTE: At some point of time, the function can be enhanced to internally 
         switch operands and check for exact match. However, then we have to 
         return 3 different codes, one for exact match, one for 1 being subset 
         2 and one for 2 being subset of 1. Instead of having so many return
         codes, it was felt that the caller can determine this easily by making 
         successive calls with switched operands.
  
   INPUT/OUTPUT:
 
   O  EFmsg          : Return code
   I  data1          : Input dataselect # 1  
   I  data2          : Input dataselect # 2  
   I  bastol         : basis tolerance. Can be NULL.
                       If NULL, then calculated internally.
   I  chttol         : XYZ tolerance for checking match. Can be NULL. 
                       If NULL, then twice cht is the default 
   I  num_samplepts  : Number of sample points to check for match. Can be NULL.
                       If NULL, then defaults to 3, right now.
   I  md_env         : Environment info. If the both dataselects are NOT
                       objects, this is NOT required and can be NULL.

   HISTORY:

   12/11/93 :  NP    : Creation, for better or for worse.

 */

IGRboolean EFis_xyz_overlap(EFmsg, data1, data2, bastol, chttol, num_sample_pts,
                            md_env)
IGRlong *EFmsg;
struct EMSdataselect *data1, *data2;
IGRdouble *bastol, *chttol;
IGRint *num_sample_pts;
struct GRmd_env *md_env;
{

   IGRlong i, msg_loc, sts;
   IGRint loc_num_sample_pts;
   IGRdouble loc_bastol, loc_chttol;
   struct EMSdataselect **data, *loc_data, loc_data1, loc_data2;
   IGRboolean match;
   struct IGRbsp_curve curve1, curve2, *curve;
   IGRdouble *internal_pts, *mindist;
   struct EMSpypoint *projected_pts;
   IGRdouble *mat;
   IGRshort mat_type;

   extern IGRboolean EFisAncestryValid();
   extern IGRlong EMinternalpt(), EMprojectpt();
   extern struct EMSpypoint *EMpypoint_malloc ();
   extern void EMpypoint_free ();

   *EFmsg = EMS_S_Success;
   sts    = OM_S_SUCCESS;

   /* INITIALZATIONS */
    
   internal_pts  = NULL;
   projected_pts = NULL;
   mindist       = NULL;
   curve         = NULL;
   match         = FALSE;

   for (i=0; i<2; i++)
   { curve = (i==0? &curve1 : &curve2);
     curve->poles   = NULL;
     curve->knots   = NULL;
     curve->weights = NULL;
   }

   if (bastol)
     loc_bastol = *bastol;
   else
   {
     BSEXTRACTPAR (&msg_loc, BSTOLBASIS, loc_bastol);
   }      

   if (chttol)
     loc_chttol = *chttol;
   else
   {
     BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, loc_chttol);
     loc_chttol *= 2.0;
   }      

   if (!num_sample_pts)
     loc_num_sample_pts = NUM_INTERNAL_SAMPLES;
   else
     loc_num_sample_pts = *num_sample_pts;

   if (md_env)
   {
     mat      = md_env->md_env.matrix;
     mat_type = md_env->md_env.matrix_type;
   }


   /* If the input data is an EMSedge object, then we have to create a local 
    * dataselect with XYZ geometry (curve3d). Right now, we simply assume that 
    * the input data is being directly used for both dataselects in the calls
    * of functions EMinternalpt and EMprojectpt.
    */
   OM_BLOCK_MOVE (data1, &loc_data1, sizeof (struct EMSdataselect));
   OM_BLOCK_MOVE (data2, &loc_data2, sizeof (struct EMSdataselect));

   /* Make sure that input data is valid */
   for (i=0; i<2; i++)
   {  
      data      = (i==0? &data1 : &data2);
      loc_data  = (i==0? &loc_data1 : &loc_data2);
      curve     = (i==0? &curve1 : &curve1);

      switch ((*data)->datatype)
      {
         case EMSdata_poly3d:
         case EMSdata_curve3d:
            break;
         case EMSdata_object:
            /* if this an object, then it better be a GRcurve object or an 
             * EMSedge object. ALL other object types are invalid.
             */


            /* since this is an object, module info  better be input */
            EMerr_hndlr(!md_env, *EFmsg, EMS_E_Fail, wrapup);

            if ( EFisAncestryValid(&msg_loc, 
                                   (*data)->data.object->objid, 
                                   (*data)->data.object->osnum,
                                   OPP_GRcurve_class_id, FALSE) )
            {
               break; /* no problem here */
            }
#ifndef IDRAW
            else if ( EFisAncestryValid(&msg_loc, 
                                   (*data)->data.object->objid, 
                                   (*data)->data.object->osnum,
                                   OPP_EMSedge_class_id, FALSE))
            {

                /* get XYZ geometry of the edge */
                sts = om$send (msg = message EMSedge.EMget_bcxyz_geom (&msg_loc,
                                       &(md_env->md_env), NULL, NULL, 0, MAXINT,
                                       FALSE, NULL, curve),
                                      senderid = NULL_OBJID,
                                      targetid = (*data)->data.object->objid,
                                      targetos = (*data)->data.object->osnum);

                EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);

                loc_data->datatype = EMSdata_curve3d;
                loc_data->data.curve = curve;
            }
#endif
            else
            { 
              EMerr_hndlr(TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);
            }
            
            break;

         default:
            EMerr_hndlr(TRUE, *EFmsg, EMS_E_InvalidArg, wrapup);
      }
   }


   /* Get internal XYZ sample points from the first dataselect.*/

   internal_pts = (IGRdouble *)alloca (sizeof(IGRpoint) * loc_num_sample_pts);

   sts = EMinternalpt (&msg_loc, &mat_type, mat,
                 &loc_data1, EMScvint_middle, loc_num_sample_pts,
                 internal_pts);
   EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);


   mindist = (IGRdouble *)alloca (sizeof(IGRdouble) * loc_num_sample_pts);
   
   projected_pts = EMpypoint_malloc (&msg_loc, loc_num_sample_pts);
   EMerr_hndlr(!(1&msg_loc), *EFmsg, msg_loc, wrapup);

   /* project the XYZ sample pts onto the second dataselect */

   sts = EMprojectpt (&msg_loc, &mat_type, mat,
                   &loc_data2, loc_num_sample_pts, internal_pts,
                   loc_bastol, projected_pts, mindist);
   EMerr_hndlr(!(1&sts&msg_loc), *EFmsg, EMS_E_Fail, wrapup);


   match = TRUE; /* assume */
   for (i=0; i<loc_num_sample_pts; i++)
   {
     if (mindist[i] > loc_chttol)
     {
       match = FALSE;
       break;
     }
   }
 
   wrapup:
 
   if (internal_pts)
     {stackfree (internal_pts);}
   if (mindist)
     {stackfree (mindist);}
   if (projected_pts)
     {(void)EMpypoint_free (projected_pts, MAXINT);}

   for (i=0; i<2; i++)
   { curve = (i==0? &curve1 : &curve2);
     if (curve->poles) 
       {om$dealloc (ptr=curve->poles);}
     if (curve->knots) 
       {om$dealloc (ptr=curve->knots);}
     if (curve->weights) 
       {om$dealloc (ptr=curve->weights);}
   }

   return (match);
}


IGRuchar EMcurve_typing ( uvdata, xyzdata )
struct EMSdataselect *uvdata,
		     *xyzdata;
{
  IGRuchar cvtype;
  IGRshort is_arc;
  IGRint i, j, k, l;
  IGRlong msg_loc;
  IGRdouble *pypts, *cvpts, *cvwts, arc_rad;
  IGRpoint arc_centre;
  struct IGRbsp_curve *cv;
  struct IGRpolyline *py;
  enum EMSdatatype datatype;

  cvtype = EMfreeform_curve;

  datatype = uvdata->datatype;
  if (datatype == EMSdata_curve3d)
    cv = uvdata->data.curve;
  else 
    cv = NULL;

  if (cv && cv->order == 2)
    {
    py = (struct IGRpolyline *) om$malloc (size = sizeof (struct IGRpolyline));
    pypts = py->points = (IGRdouble *) om$malloc (size = cv->num_poles * 2 * 
                          sizeof(IGRdouble));
    if (!py || !py->points)
      goto ret_end;

    cvpts = cv->poles;
    cvwts = cv->rational ? cv->weights : NULL;
    for (i=0, j=0, k=0; k<cv->num_poles; i+=3, j+=2, k++)
      {
      OM_BLOCK_MOVE (&cvpts[i], &pypts[j], 2 * sizeof (IGRdouble));
      if (cvwts)
        for (l=0; l<2; l++)
          cvpts[i+l] /= cvwts[k];
      }
    py->num_points = cv->num_poles;

    uvdata->datatype = EMSdata_poly2d;
    uvdata->data.poly = py;
    om$dealloc (ptr = cv);
    }

  if (datatype == EMSdata_poly2d)
    {
    if (uvdata->data.poly->num_points > 2)
      cvtype = EMlinestring;
    else
      cvtype = EMlinesegment;
    }
  else if (uvdata->datatype == EMSdata_curve3d &&
           (xyzdata) &&
           xyzdata->datatype == EMSdata_curve3d)
    {
    BStstcvcarc (xyzdata->data.curve, &is_arc, arc_centre, &arc_rad,
     &msg_loc);
    if (msg_loc == BSSUCC && is_arc)
      cvtype = is_arc == 2 ? EMcircle : EMcircular_arc;
    }

ret_end:  
  return (cvtype);
}

void EMdata_reverse (data)
struct EMSdataselect *data;
{
  IGRlong msg_loc;
  void EMrevpyline();

  switch (data->datatype)
    {
    case EMSdata_poly2d:
    case EMSdata_poly3d:
      EMrevpyline (&msg_loc, data->data.poly, 
       data->datatype == EMSdata_poly2d ? 2 : 3, MAXINT);
      break;

    case EMSdata_curve3d:
      BSrev_cv (&msg_loc, data->data.curve);
      break;

    default:
      fprintf (stderr, "Not Supported\n");
    }
  return;
}


/*
  DESCRIPTION

  This function takes in two EMSdataselect structures that are end-point
  connected and returns a single one that could take their place. The
  EMSdataselects need to be ordered, and there must be atleast one end-point
  shared between the two. 

  The resultant EMSdataselect is returned in the output structure passed in.
  Every field of this output structure is set by the function. The caller may 
  then replace this resultant structure in place of the existing set.


  NOTES

  o If replacing, use EMdataselect_data_free to delete the existing structures.
  o The dataselects can output into one CLOSED dataselect, too.
  o It is assumed that the caller is passing dataselects which hold data of
    the same dimension ie both xyz or both uv.
  o The mat and mattyp arguments have been retained so that in the future
    this function can be enhanced to match the endpts, reverse the dataselects
    and merge them.

  HISTORY
  16/11/95 :  Aditya    : Creation.
  
*/

void EMmergedata (msg, mattyp, mat, data1, data2, out_data)
IGRlong *msg;
IGRshort mattyp;
IGRmatrix mat;
struct EMSdataselect *data1, *data2;
struct EMSdataselect *out_data;
{
  IGRboolean is_poly=TRUE;
  struct IGRpolyline *p_poly = NULL;
  struct IGRbsp_curve **p_curve = NULL, *p_mergecv = NULL;
  IGRint size = 0, tot_num_pts = 0;
  IGRdouble *p_double = NULL, tol;
  IGRint inx=0;
  struct EMSdataselect *p_data = NULL;
  IGRlong msg_loc;
  struct PWpoly py;
  struct PWpoly2d py2d;
  BSrc rc;

  *msg = msg_loc = EMS_S_Success;

  EMerr_hndlr(!data1 || !data2, *msg, EMS_E_InvalidArg, wrapup);

  BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, tol);
  
  if(data1->datatype == EMSdata_curve3d ||
     data2->datatype == EMSdata_curve3d) is_poly = FALSE;
  
  if(is_poly)
  {
    size = (data1->datatype == EMSdata_poly3d)? 3 : 2;

    tot_num_pts = data1->data.poly->num_points + data2->data.poly->num_points;
    tot_num_pts--;
    /* Because there's one end point that is common to the dataselects. */

    p_poly = (struct IGRpolyline *)malloc(sizeof(struct IGRpolyline));
    EMerr_hndlr(!p_poly, *msg, EMS_E_NoDynamicMemory, wrapup);

    p_poly->points = NULL;
    p_poly->points =(IGRdouble *)malloc(tot_num_pts * size * sizeof(IGRdouble));
    EMerr_hndlr(!p_poly->points, *msg, EMS_E_NoDynamicMemory, wrapup);

    memset(p_poly->points, NULL, tot_num_pts * size * sizeof(IGRdouble));

    memcpy(p_poly->points, data1->data.poly->points,
           data1->data.poly->num_points * size * sizeof(IGRdouble));

    p_double = &p_poly->points[ size * (data1->data.poly->num_points - 1)];

    memcpy(p_double, data2->data.poly->points,
          data2->data.poly->num_points * size * sizeof(IGRdouble));

    p_poly->num_points = tot_num_pts;

    out_data->datatype = data1->datatype;
    out_data->data.poly = p_poly;
  }
  else
  {
    p_curve = (struct IGRbsp_curve **)alloca(2*sizeof(struct IGRbsp_curve *));
    EMerr_hndlr(!p_curve, *msg, EMS_E_NoDynamicMemory, wrapup);

    for(inx=0; inx<2; inx++)
    {
       p_data = (inx == 0)? data1 : data2;

       if(p_data->datatype == EMSdata_curve3d)
       {
         p_curve[inx] = p_data->data.curve;
       }
       else
       {
         p_curve[inx] = (struct IGRbsp_curve *)
                    alloca (sizeof (struct IGRbsp_curve));
         PW_AllocBspCvStack (p_data->data.poly->num_points,
                             2, 0, p_curve[inx][0]);

         if (p_data->datatype == EMSdata_curve3d)
         {
           py.num_pts = p_data->data.poly->num_points;
           py.p_pts = (PWpoint *)(p_data->data.poly)->points;

           pwCnvtPyToCv (&py, tol, p_curve[inx]);
         }
         else
         {
           py2d.num_pts = p_data->data.poly->num_points;
           py2d.p_pts = (PWpoint2d *)(p_data->data.poly)->points;

           pwCnvtPy2dToCv (&py2d, tol, p_curve[inx]);
         }
       } //else
    } //for

    BSmergarrcv (2, p_curve, &p_mergecv, &rc);
    EMerr_hndlr (BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

    out_data->data.curve = p_mergecv;
    out_data->datatype = EMSdata_curve3d;
  }

wrapup:
  if(!(1&*msg))
  {
    if(p_poly)
    {
      if(p_poly->points) free(p_poly->points); 
      free(p_poly);
    }
    if(p_mergecv) BSfreecv(&rc, p_mergecv);
  }
  return;
}


/*
  DESCRIPTION
  Copies the EMSdataselect structure. Allocates memory for the copy.
  But it is the callers responsibility to free the memory after use.

  BUGS
  Does not handle the EMSdata_object case.

  Aditya: 11/20/95  : Creation.
*/

void EMdataselect_copy( msg, orig_data, copy_data)
IGRlong *msg;
struct EMSdataselect *orig_data, *copy_data;
{
  struct IGRbsp_curve *p_curve=NULL, *p_origcv=NULL;
  struct IGRpolyline *p_poly=NULL, *p_origpy=NULL;
  BSrc rc;
  IGRboolean sts = TRUE;
  IGRint size = 0;

  *msg = EMS_S_Success;

  EMerr_hndlr(!orig_data, *msg, EMS_E_InvalidArg, wrapup);

  if(orig_data->datatype == EMSdata_curve3d)
  {
    p_origcv = orig_data->data.curve;

    BSalloccv(p_origcv->order, p_origcv->num_poles, p_origcv->rational,
              p_origcv->num_boundaries, &p_curve, &rc);
    EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

    sts = BScv_copy(&rc, p_origcv, p_curve);
    EMerr_hndlr(BSERROR(rc), *msg, EMS_E_BSerror, wrapup);

    (copy_data)->data.curve = p_curve;
    (copy_data)->datatype = EMSdata_curve3d;
  }
  else if(orig_data->datatype == EMSdata_poly2d)
  {
    p_origpy = orig_data->data.poly;
    size = 2 * p_origpy->num_points * sizeof(IGRdouble);

    p_poly = (struct IGRpolyline *)malloc(sizeof(struct IGRpolyline));
    EMerr_hndlr(!p_poly, *msg, EMS_E_NoDynamicMemory, wrapup);

    p_poly->points = (IGRdouble *)malloc(size);
    EMerr_hndlr(!p_poly->points, *msg, EMS_E_NoDynamicMemory, wrapup);

    memcpy(p_poly->points, p_origpy->points, size);
    p_poly->num_points = p_origpy->num_points;

    (copy_data)->data.poly = p_poly;
    (copy_data)->datatype = EMSdata_poly2d;
  }
  else if(orig_data->datatype == EMSdata_poly3d)
  {
    p_origpy = orig_data->data.poly;
    size = 3 * p_origpy->num_points * sizeof(IGRdouble);

    p_poly = (struct IGRpolyline *)malloc(sizeof(struct IGRpolyline));
    EMerr_hndlr(!p_poly, *msg, EMS_E_NoDynamicMemory, wrapup);

    p_poly->points = NULL;
    p_poly->points = (IGRdouble *)malloc(size);
    EMerr_hndlr(!p_poly->points, *msg, EMS_E_NoDynamicMemory, wrapup);

    memcpy(p_poly->points, p_origpy->points, size);
    p_poly->num_points = p_origpy->num_points;

    (copy_data)->data.poly = p_poly;
    (copy_data)->datatype = EMSdata_poly3d;
  }
  else *msg = EMS_E_InvalidArg;

wrapup:
  if(!(1 & *msg))
  {
    if(p_curve) BSfreecv(&rc, p_curve);
    if(p_poly)
    {
      if(p_poly->points) free(p_poly->points);
      free(p_poly);
    }
    if(copy_data)
    {
        free(copy_data);
        copy_data = NULL;
    }
  }
  return;
}


/*
  DESCRIPTION
  Frees the data of the EMSdataselect structure and also frees the
  structure itself. Passes back a NULL pointer.

  NOTES
  Ensure that the EMSdataselect structure being passed in has been 
  allocated on the heap (malloced).

  Aditya: 11/20/95  : Creation.
*/

void EMdataselect_free(msg, data)
IGRlong *msg;
struct EMSdataselect **data;
{
  IGRlong msg_loc;
  void EMdataselect_data_free();

  msg_loc = EMS_S_Success;

  if(!(*data)) return;

  EMdataselect_data_free(&msg_loc, *data, 1);
  EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, wrapup);

  free(*data);
  *data = NULL;

wrapup:
  return;
}


end implementation Root;
