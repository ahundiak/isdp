/*
  DESCRIPTION:

    This method takes as input a pair of polylines/curves representing
    corresponding data on two surfaces (myself and other_obj) such as would
    be output by surface-surface intersection. It outputs the boundaries on
    the uv-data that represent the area portions w.r.t. to the boundaries
    on the surfaces.

    The memory for the output list is allocated within this method call. No
    memory should be allocated by the user. Associated with each boundary
    element is some information that informs the caller of the geometric
    element of the surface (the edge) that caused this boundary to be created;
    also the exact location on the edge, where the intersection took place.
    If this boundary was caused due to the edge of the other surface but not
    an edge of the surface in question, the edge-id returned is NULL_OBJID.

    The boundaries on either of the polylines/curves is a linked list of 
    EMSpypoint-structures, where two consecutive elements represent solid 
    regions. If the entire uv-data is inside an area, one such pair is 
    output for each data which would represent the entire data as
    the solid portion. The associated information, is output as a linked-list
    of EMSsfintedpar-structures that runs parellel to the bdry linked list.
    To determine the associated information to a particular boundary element,
    pick the corresponding element in the corresponding associated list.

    The other surface object being passed in as an argument is of a general
    type - EMSdataselect, which could contain an OM-object or a surface buffer.
    The method operates on the surface buffer and the infinite plane with the
    same characteristics as if there was no loopset on the other surface.
    In such cases the "interpolate" flag being FALSE will cause an
    invalid-argument error consdition to be returned.

    Note that if the both uv-data are not polylines stroked with the same
    number of points, then the xyzdata args must NOT be NULL. In such
    non-matching case the option EMS_INTER_MOREPRECISE is irrelevant, since
    there is no scope for interpolation.

  RETURN VALUE

    Upon exit the completion code will be one of the following

      - EMS_S_Success 
          if succeeded
      - EMS_E_InvalidArg 
          if the other surface data is neither an OM-object or a
           surface buffer or,
          the 'interpolate' flag is FALSE.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_SurfaceError
          if a failure occurred when a call to a surface method was
          made.
      - EMS_E_LoopsetError
          if a failure occurred when a call to a surface-loopset method was
          made.
      - EMS_E_Fail
          Most probably a failure in a call to a math-function.
          In some cases the reason for failure was not understood in greater
          detail. 
    
  BUGS

    This method requires that none of the potential output arguments be
    NULL.

  HISTORY

    SS  :  11/01/86  :  Creation
    RV  :  04/25/88  :  Modified to support general uv-data (polylines
			or curves), changed arguments to include xyz-data,
			partolbasis and surface geometries.
			Also removed duplicated code to get partolbasis
			for the two surfaces and changed the name from
			EMlspyfulltrim to EMlsfulltrim.
    SS  :  07/17/89  :  In case the number of boundaries on the two surfaces
                        do not match, try again with the option to not
                        output degenerate boundaries.
    NP  :  05/25/92  :  Added "timer" function calls to time this method.
    NP  :  06/04/92  :  Changed variable "uvpoint"  from 2 dimensional to
                        3 dimensional.  This is because "EMinternalpt" function
                        expects a 3D array of points (the "BScvarreval" and
			"BScveval" work on 3D arrays of points). Otherwise, 
			overflow in "BScveval" causes problems.  Changing the
			"uvpoint" variable will not affect any other code in 
			this function.
    NP  :  04/09/93  :  Due to trimming tolerance problems, there may be a 
                        valid boundary on myself, but none on the other 
                        loopset/surf. This case is considered as a 
                        no-intersection case. (see notes)
    SS  :  02/??/95  :  Pathway Modifications.
  Sanjay:  02/??/95  :  Pathway Modifications.
  Sanjay:  05/10/95  :  While merging the trimmed boundaries on this surface 
                        with the trimmed boundaries on the other surface, it
                        is very likely that there could be a tolerance prob-
                        lem while deciding the degenerate regions. So, When-
                        ever there is a tolerance problem the number of bou-
                        ndaries on this surface will not be equal to  number 
                        of boundaries on the other surface. In such  a  case 
                        increase the tolerance by two times to  get  rid  of 
                        such types of problems. TR# 119424156
  Sanjay:  12/05/95  :  Replaced "EMget_intervening_edge" call with "pwGet
                        InterveningEdge". Replaced "pwMinDist..." call with
                        "pwEdPtProject" so that the edge's span index and 
                        parameter will be converted full-edge geometry in 
                        case of part edge. Fix for TR# 119528444.
  Sanjay:  12/20/95  :  Provide the incident information for all the mapped
                        points in the overlap regions. Earlier the code assumed
                        that, a pair of mapped points will point to the same
                        overlap region. But is not true. Added code to the
                        same affect.
  V.Srinivas 12/17/96:  Visiting the nodes based on the number of boundaries
                         is corrected to based on number of nodes. 
                         This fix is made to visit all nodes for checking 
                         overlap. Fix for TR#119602167. 
*/

class implementation EMSloopset;

#include "EMS.h"
%safe
#include <math.h>
%endsafe
#include "OMmacros.h"
#include "msdef.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emssfintdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emssfint.h"
#include "emsinter.h"
#include "timerdef.h"
#include "EMStpmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWattrib.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "PWapi/sfptloc.h"
#include "EMSpwapi.h"
#include "PWapi/ptpargm.h"
#include "PWapi/edgeom.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/edptproj.h"
#include "PWapi/eded.h"

#define U 0
#define V 1
#define BGN 0
#define END 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSsubbs import EMparttrim, EMpartolbasis;

extern IGRboolean _use_timers;
extern IGRboolean _pathway_trim;

method EMlsfulltrim (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                     struct EMSdataselect *my_uvdata; 
                     struct EMSdataselect *my_xyzdata; 
                     struct IGRbsp_surface *my_srf;
                     struct EMSpartolbasis *mypartol_basis;
                     struct EMSdataselect *other_data; 
                     struct GRmdenv_info *other_datenv;
                     struct EMSdataselect *other_uvdata; 
                     struct EMSdataselect *other_xyzdata; 
                     struct IGRbsp_surface *other_srf;
                     struct EMSpartolbasis *otherpartol_basis;
                     IGRdouble *correl_params;
                     IGRushort options;
                     IGRint *num_bdrys; struct EMSpypoint **my_bdrys;
                     struct EMSsfintedpar **my_bdryparms;
                     struct EMSpypoint **other_bdrys;
                     struct EMSsfintedpar **other_bdryparms)
{
  IGRboolean interpolate_loc, in_world, matched_py_spans;
  IGRint stat_OM, i, j, inxlim, num_correl_params = 0, blk2size;
  IGRint my_numbdrys, other_numbdrys, uvspaninx;
  IGRlong msg_loc;
  IGRdouble uvpoint[3], xyzpoint[3], newxyzpoint[3];
  IGRdouble uvtol, wtol, uvparam, dist;
  IGRdouble *my_uvpts = NULL, *other_uvpts = NULL;
  struct EMSpypoint *my_bdrys1, *my_bdrys2, *other_bdrys1, *other_bdrys2;
  struct EMSpypoint *bdry;
  struct EMSpypoint uvpypoint;
  struct EMSsfintedpar *my_bdry_parms, *other_bdry_parms, *bdryp;
  struct PWgeomid my_sfgmid, other_sfgmid;
  enum EMScvinttype loc;
  OM_S_CHANSELECT chan_to_surface;
  extern void BSsfkttol2(), BSsfeval();
  extern void EMsfintedpar_free(), EMwpartol();
  extern void EMmkpylist(), EMmkpybdrys(), EMsfexactpt(), EMintpybdrys();
  extern void EMmap_trim_point();
  extern IGRint EMgetvggeom(), EMinternalpt();
  extern struct EMSpypoint *EMpypoint_malloc();

  /*
   * Initialize the output arguments as well as
   * local variables.
   */

  if (_use_timers)
    start_timer (T_EMLSFULLTRIM);

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  EMerr_hndlr (other_data->datatype != EMSdata_object && 
   other_data->datatype != EMSdata_surface, *msg, EMS_E_InvalidArg, ret_end);

  *num_bdrys = 0;
  if (my_bdrys)
    *my_bdrys = NULL;
  if (my_bdryparms)
    *my_bdryparms = NULL;
  if (other_bdrys)
    *other_bdrys = NULL;
  if (other_bdryparms)
    *other_bdryparms = NULL;

  my_bdrys1 = NULL;
  my_bdry_parms = NULL;
  my_bdrys2 = NULL;
  other_bdrys1 = NULL;
  other_bdry_parms = NULL;
  other_bdrys2 = NULL;
  
  if (options & EMS_INTER_MATCHEDINTDAT && 
      my_uvdata->datatype == EMSdata_poly2d)
    {
    matched_py_spans = TRUE;
    my_uvpts = my_uvdata->data.poly->points;
    other_uvpts = other_uvdata->data.poly->points;
    }
  else
    {
    matched_py_spans = FALSE;
    if (my_uvdata->datatype == EMSdata_poly2d)
      num_correl_params = my_uvdata->data.poly->num_points;
    else
      num_correl_params = other_uvdata->data.poly->num_points;
    }

  /*
   * Get the pairs of points on my-uvdata that represent the solid portions
   * with respect to my surface boundaries. The output is a linked list called
   * "my_bdrys1", with consecutive elements forming the pairs.
   * If zero number of boundaries are returned (entire data inside hole),
   * simply exit with num_bdrys = 0. No part of the other data will
   * be within a solid portion either.
   */

  if (_use_timers)
    start_timer (T27_PARTTRIM);

  if (_pathway_trim)
  {
    double chttol, partol;
    PWresult result=PW_K_Success;
    PWrange2d uvrange;
    PWobjid sfid=PW_K_NullObjid;
    struct PWcvdata uvdata, xyzdata;
    struct PWcvregion_list *p_cvregs=NULL;

    om$send (msg = message EMSboundary.EMgetsurface_info (&msg_loc,
     &sfid, NULL), targetid = my_id);
    OnErrorState (sfid == PW_K_NullObjid, result, SetError (PW_K_Trimming,
     PW_K_Internal), loc_ret_end1);
    my_sfgmid.id.objid = sfid;
    my_sfgmid.id.osnum = OS;
    my_sfgmid.mattyp = *mattyp;
    memcpy (my_sfgmid.mat, mat, sizeof (PWmatrix)); 

    pwCnvtEMSCvdata (my_uvdata, &uvdata);
    pwCnvtEMSCvdata (my_xyzdata, &xyzdata);
    pwGetSfUvRng (sfid, OS, uvrange);
    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);

    result = pwTrimAgainstSurface (&my_sfgmid, &uvdata, &xyzdata, 
              uvrange, chttol, &p_cvregs);
    OnErrorCode (result, loc_ret_end1);

    my_numbdrys = pwNumCvregionList (p_cvregs);
    my_bdrys1 = EMpypoint_malloc (&msg_loc, my_numbdrys * 2);
    my_bdry_parms = EMsfintedpar_malloc (&msg_loc, my_numbdrys * 2);
    OnErrorState (!my_bdrys1 || !my_bdry_parms, result, 
     SetError(PW_K_Trimming,PW_K_DynamicMemory), loc_ret_end1);


    if (!mypartol_basis || !mypartol_basis->is_valid)
    {
      BSEXTRACTPAR (&msg_loc, BSTOLPARAM, partol);
    }
    else
    {
      partol = mypartol_basis->tol;
    }

    pwCnvtCvregionEMS (p_cvregs, my_bdrys1, my_bdry_parms, 
     options & EMS_INTER_BDRYISAREA ? TRUE : FALSE, partol);

    loc_ret_end1:
    pwFreeCvregionList (p_cvregs);
    EMerr_hndlr (IsError (result), *msg, EMS_E_Fail, ret_end);
  }
  else
  {
    stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
               my_uvdata, mypartol_basis, options, &my_numbdrys, &my_bdrys1, 
               &my_bdry_parms), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopsetError, ret_end);
  }

  if (_use_timers)
    stop_timer (T27_PARTTRIM, FALSE, "");

  if (!my_numbdrys)
    goto ret_end;

  /*
   * Get the pairs of points on other_uvdata that represent the solid portions
   * with respect to it's (other surface's) boundaries. The output is a linked 
   * list called "other_bdrys1". If the number of boundaries is zero, simply
   * exit with with num_bdrys set to zero, as no part of the data 
   * either on my_uvdata or on other_uvdata will be in a solid portion.
   */

  if (other_data->datatype == EMSdata_object)
    {
    if (_use_timers)
      start_timer (T27_PARTTRIM);

    if (_pathway_trim)
    {
      double chttol, partol;
      PWresult result=PW_K_Success;
      PWrange2d uvrange;
      struct PWcvdata uvdata, xyzdata;
      struct PWcvregion_list *p_cvregs=NULL;
    
      other_sfgmid.id.objid = other_data->data.object->objid;
      other_sfgmid.id.osnum = other_data->data.object->osnum;
      other_sfgmid.mattyp = other_datenv->matrix_type;
      memcpy (other_sfgmid.mat, other_datenv->matrix, sizeof (PWmatrix)); 

      pwCnvtEMSCvdata (other_uvdata, &uvdata);
      pwCnvtEMSCvdata (other_xyzdata, &xyzdata);
      pwGetSfUvRng (other_data->data.object->objid,
       other_data->data.object->osnum, uvrange);
      BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);

      result = pwTrimAgainstSurface (&other_sfgmid, &uvdata, &xyzdata, 
                uvrange, chttol, &p_cvregs);
      OnErrorCode (result, loc_ret_end2);

      other_numbdrys = pwNumCvregionList (p_cvregs);
      other_bdrys1 = EMpypoint_malloc (&msg_loc, other_numbdrys * 2);
      other_bdry_parms = EMsfintedpar_malloc (&msg_loc, other_numbdrys * 2);
      OnErrorState (!other_bdrys1 || !other_bdry_parms, result, 
       SetError(PW_K_Trimming,PW_K_DynamicMemory), loc_ret_end2);

      if (!otherpartol_basis || !otherpartol_basis->is_valid)
      {
        BSEXTRACTPAR (&msg_loc, BSTOLPARAM, partol);
      }
      else
      {
        partol = otherpartol_basis->tol;
      }

      pwCnvtCvregionEMS (p_cvregs, other_bdrys1, other_bdry_parms, 
       options & EMS_INTER_BDRYISAREA ? TRUE : FALSE, partol);

      loc_ret_end2:
      pwFreeCvregionList (p_cvregs);
      EMerr_hndlr (IsError (result), *msg, EMS_E_Fail, ret_end);
    }
    else
    {
      stat_OM = om$send (msg = message EMSsubbs.EMparttrim (&msg_loc,
                 &other_datenv->matrix_type, other_datenv->matrix,
                 other_uvdata, options, &other_numbdrys, &other_bdrys1, 
                 &other_bdry_parms), targetid = other_data->data.object->objid,
                 targetos = other_data->data.object->osnum);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
    }

    if (_use_timers)
      stop_timer (T27_PARTTRIM, FALSE, "");

    if (!other_numbdrys)
      goto ret_end;
    }
  else
    {
    EMmkpybdrys (&msg_loc, other_uvdata, &other_bdrys1, &other_numbdrys,
     NULL, NULL, NULL, NULL);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    other_bdry_parms = ems$sfintedpar_malloc (msg = &msg_loc, num_nodes = 2);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_NoDynamicMemory, 
     ret_end);
    other_bdry_parms->edgeid = NULL_OBJID;
    other_bdry_parms->next->edgeid = NULL_OBJID;
    }

  /* 
   * Obtain "my_bdrys2" either through straightforward interpolation, if
   * allowed or by iterative refinement, or by mapping through xyzdata. A
   * simple check indicates whether interpolation should be used regardless,
   * if the boundaries lie at cusps.
   */

  if (_use_timers)
    start_timer (T27_MAP_BOUNDARY);

  if (other_data->datatype == EMSdata_object &&
      options & EMS_INTER_MOREPRECISE && matched_py_spans)
    {
    bdry = other_bdrys1;
    interpolate_loc = TRUE;
    for (i=0; i<other_numbdrys*2; i++)
      {
      if (bdry->param != 0.0 && bdry->param != 1.0)
        {
        interpolate_loc = FALSE;
        break;
        }
      bdry = bdry->next;
      }
    }
  else
    interpolate_loc = matched_py_spans;

  blk2size = 2 * sizeof (IGRdouble);
  bdry = other_bdrys1;
  for (i=0; i<other_numbdrys*2; i++)
    {
    uvparam = bdry->param;
    uvspaninx = bdry->span_inx;
    j = uvspaninx * 2;

    if (matched_py_spans && uvparam == 0.0)
      OM_BLOCK_MOVE (&my_uvpts[j], uvpoint, blk2size);
    else if (matched_py_spans && uvparam == 1.0)
      OM_BLOCK_MOVE (&my_uvpts[j+2], uvpoint, blk2size);
    else if (interpolate_loc)
      {
      uvpoint[U] = my_uvpts[j] + uvparam * 
                   (my_uvpts[j+2] - my_uvpts[j]);
      uvpoint[V] = my_uvpts[j+1] + uvparam *
                   (my_uvpts[j+3] - my_uvpts[j+1]);
      }
    else if (bdry->props & EMS_PYPT_ATSTART || bdry->props & EMS_PYPT_ATSTOP)
      {
      loc = bdry->props & EMS_PYPT_ATSTART ? EMScvint_lfend : EMScvint_rtend;
      stat_OM = EMinternalpt (&msg_loc, NULL, NULL, my_uvdata, loc, 1, 
                 uvpoint);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      uvparam = loc == EMScvint_lfend ? 0.0 : 1.0;
      if (my_uvdata->datatype == EMSdata_poly2d)
        uvspaninx = loc == EMScvint_lfend ? 
                     0 : my_uvdata->data.poly->num_points-2;
      else
        uvspaninx = 0;
      }
    else 
      {
      BSsfeval (other_srf, bdry->point[U], bdry->point[V], 0, xyzpoint,
       &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      if (matched_py_spans)
        {
        EMsfexactpt (&msg_loc, my_srf, &my_uvpts[j], xyzpoint,
         &uvparam, uvpoint, newxyzpoint, &dist);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      else	
        {
        EMmap_trim_point (&msg_loc, my_srf, my_xyzdata, my_uvdata, my_bdrys1,
         xyzpoint, &uvpypoint, newxyzpoint, &dist);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        OM_BLOCK_MOVE (uvpypoint.point, uvpoint, blk2size);
        uvparam = uvpypoint.param;
        uvspaninx = uvpypoint.span_inx;
        }
      }

    EMmkpyptlist (&msg_loc, &my_bdrys2, uvspaninx, uvparam, uvpoint,
     EMS_PYPT_RELUNKNOWN | EMS_PYPT_POSUNKNOWN, NULL, 2, FALSE);
    EMerr_hndlr (!my_bdrys2, *msg, EMS_E_NoDynamicMemory, ret_end);
           
    bdry = bdry->next;
    }

  /* 
   * Obtain "other_bdrys2" either through straightforward interpolation, if
   * allowed or by iterative refinement, or by mapping through xyzdata. A
   * simple check indicates whether interpolation should be used regardless,
   * if the boundaries lie at cusps.
   */

  if ((options & EMS_INTER_MOREPRECISE) && matched_py_spans)
    {
    bdry = my_bdrys1;
    interpolate_loc = TRUE;
    for (i=0; i<my_numbdrys*2; i++)
      {
      if (bdry->param != 0.0 && bdry->param != 1.0)
        {
        interpolate_loc = FALSE;
        break;
        }
      bdry = bdry->next;
      }
    }
  else
    interpolate_loc = matched_py_spans;

  blk2size = 2 * sizeof (IGRdouble);
  bdry = my_bdrys1;
  for (i=0; i<my_numbdrys*2; i++)
    {
    uvparam = bdry->param;
    uvspaninx = bdry->span_inx;
    j = uvspaninx * 2;

    if (matched_py_spans && uvparam == 0.0)
      OM_BLOCK_MOVE (&other_uvpts[j], uvpoint, blk2size);
    else if (matched_py_spans && uvparam == 1.0)
      OM_BLOCK_MOVE (&other_uvpts[j+2], uvpoint, blk2size);
    else if (interpolate_loc)
      {
      uvpoint[U] = other_uvpts[j] + uvparam * 
                   (other_uvpts[j+2] - other_uvpts[j]);
      uvpoint[V] = other_uvpts[j+1] + uvparam *
                   (other_uvpts[j+3] - other_uvpts[j+1]);
      }
    else if (bdry->props & EMS_PYPT_ATSTART || bdry->props & EMS_PYPT_ATSTOP)
      { 
      loc = bdry->props & EMS_PYPT_ATSTART ? EMScvint_lfend : EMScvint_rtend;
      stat_OM = EMinternalpt (&msg_loc, NULL, NULL, other_uvdata, loc, 1, 
                 uvpoint);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      uvparam = loc == EMScvint_lfend ? 0.0 : 1.0;
      if (other_uvdata->datatype == EMSdata_poly2d)
        uvspaninx = loc == EMScvint_lfend ? 
                     0 : other_uvdata->data.poly->num_points-2;
      else
        uvspaninx = 0;
      }
    else 
      {
      BSsfeval (my_srf, bdry->point[U], bdry->point[V], 0, xyzpoint,
       &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

      if (matched_py_spans)
        {
        EMsfexactpt (&msg_loc, other_srf, &other_uvpts[j], xyzpoint,
         &uvparam, uvpoint, newxyzpoint, &dist);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        }
      else	
        {
        EMmap_trim_point (&msg_loc, other_srf, other_xyzdata, other_uvdata,
         other_bdrys1, xyzpoint, &uvpypoint, newxyzpoint, &dist);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        OM_BLOCK_MOVE (uvpypoint.point, uvpoint, blk2size);
        uvparam = uvpypoint.param;
        uvspaninx = uvpypoint.span_inx;
        }
      }

    EMmkpyptlist (&msg_loc, &other_bdrys2, uvspaninx, uvparam, uvpoint,
     EMS_PYPT_RELUNKNOWN | EMS_PYPT_POSUNKNOWN, NULL, 2, FALSE);
    EMerr_hndlr (!other_bdrys2, *msg, EMS_E_NoDynamicMemory, ret_end);
           
    bdry = bdry->next;
    }

  if (_use_timers)
    stop_timer (T27_MAP_BOUNDARY, FALSE, "");

  /*
   * Intersect the two sets of solid boundaries for the data my_uvdata and
   * get the one set, my_bdrys, using EMintpybdrys. The output is a part
   * of the final output of this method.
   * To "my_bdrys1" there is an associated linked list - "my_bdry_parms".
   * For the final output - "my_bdrys", a corresponding associated list needs
   * to be maintained which gets output as "my_bdryparms". For each node
   * of "my_bdrys1" there is a node of "my_bdry_parms". The pointer to
   * this node is stored in the "info" field of the "my_bdrys1" node.
   */

  if (! mypartol_basis->is_valid)
    {
    chan_to_surface.type = OM_e_addr;
    chan_to_surface.u_sel.addr = &ME.EMSloopset->to_surface;

    in_world = TRUE;
    stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
               mattyp, mat, &in_world, FALSE, &mypartol_basis->tol),
               p_chanselect = &chan_to_surface);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
    mypartol_basis->is_valid = TRUE;
    }
  EFextract_par (BSTOLLENVEC, mypartol_basis->tol, &uvtol, &msg_loc);
  EMwpartol (&msg_loc, my_uvdata, my_bdrys1->span_inx, uvtol, &wtol);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * SPECIAL PROCESSING OF PARTIAL OVERLAPS:
   * For every overlap region in my_bdrys1, scan the nodes of my_bdrys2. If
   * they lie within the region, generate the incident info for the node. The
   * way this is being done is for every region in my_bdrys1, all the nodes of
   * my_bdrys2 are gone through. If their incident info has been generated,
   * this is marked in a local array. This is a quick fix to the pre-existing
   * code and has to be redone with simpler logic. The pre-existing code
   * tried to process both lists -- my_bdrys1 and my_bdrys2 -- in parallel
   * and ended up missing generating incident info on some nodes of my_bdrys2.
   */

  if (_pathway_trim)
  {
    struct EMSsfintedpar  *p_edpar1=NULL, *p_edpar2=NULL;
    struct EMSpypoint  *p_pypt1=NULL, *p_pypt2=NULL,*t_pypt=NULL;
    double par0, par1, par2;
    GRobjid coinced=NULL_OBJID;
    PWresult result=PW_K_Success;

    int indx=0,count=0;
    IGRboolean *is_visited=NULL;

    struct PWid edid;
    struct PWcvpt edcvpt;
    PWpoint2d edpt;
    
    t_pypt = my_bdrys1;
    while (t_pypt)
    {
     ++count;
     t_pypt = t_pypt->next;
    }
    if(!count) count = 1;
    is_visited = (IGRboolean *) alloca (count * 2 * other_numbdrys * 
                                        sizeof (IGRboolean));
    memset (is_visited, 0, count * 2 * other_numbdrys * sizeof (IGRboolean));

    p_pypt1 = my_bdrys1; 

    while (p_pypt1 && p_pypt1->next)
    { 
      indx = 0;
      p_pypt2 = my_bdrys2; 

      if ( ((p_pypt1->props & EMS_PYPT_START_OVERLAP) && 
           (p_pypt1->next->props & EMS_PYPT_STOP_OVERLAP)) ||
           ((p_pypt1->props & EMS_PYPT_STOP_OVERLAP) &&
           (p_pypt1->next->props & EMS_PYPT_START_OVERLAP)) )
      {
        par1 = p_pypt1->span_inx + p_pypt1->param;
        par2 = p_pypt1->next->span_inx + p_pypt1->next->param;
        p_edpar1 = (struct EMSsfintedpar *) p_pypt1->info;

        if (par1 > par2)
        {
          pwSwapDouble (&par1, &par2);
        }
  
        while (p_pypt2)
        {
          coinced = PW_K_NullObjid;

          /*
           * get the intervening edge
           */
          par0 = p_pypt2->span_inx + p_pypt2->param;
          if (!is_visited[indx] && par0 > (par1 + wtol) && par0 < (par2 - wtol))
          {
            struct PWcvdata  uvdata;
            struct PWcvparam param;
            PWpoint          midpt;
            double           tmppar;

            /*
             * This represents the partial overlap. In which case we need to 
             * add sfintedpar info and also set the PYPT props correctly.
             */
            pwCnvtEMSCvdata (my_uvdata, &uvdata);
            tmppar = (p_pypt1->span_inx + p_pypt1->next->span_inx + 
                      p_pypt1->param + p_pypt1->next->param) / 2.0;
            param.spaninx = (int) tmppar;
            param.spanpar = tmppar - (int) tmppar;

            pwPtAtParCvdata (&uvdata, &param, (double *)midpt);

            coinced = pwGetInterveningEdge (OS, p_edpar1->edgeid,
                                            pwPWCvint (p_edpar1->intloc),
                                            p_edpar1->next->edgeid,
                                            pwPWCvint (p_edpar1->next->intloc),
                                            midpt, uvtol);

            p_edpar2 = ems$sfintedpar_malloc (msg = &msg_loc, num_nodes = 1);
            EMerr_hndlr (!p_edpar2, *msg, msg_loc, ret_end);
            p_edpar2->edgeid = coinced;
            p_edpar2->intloc = EMScvint_middle;
            p_edpar2->point[U] = p_pypt2->point[U];
            p_edpar2->point[V] = p_pypt2->point[V];

            /*
             * This is the time to generate the spaninx and parameter for 
             * this UV point on the coincident edge. So, do a point project
             * on the coincident edge.
             */
            edpt [U] = p_edpar2->point[U];  
            edpt [V] = p_edpar2->point[V];  
            edid.objid = coinced; edid.osnum = OS;

            result = pwEdPtProject (&edid, 1, (PWpoint2d *) &edpt[0], uvtol, 
                                    &edcvpt);
            OnErrorState (IsError (result), *msg, result, ret_end);
 
            p_edpar2->edgepar.span_inx = edcvpt.cvparam.spaninx;
            p_edpar2->edgepar.param = edcvpt.cvparam.spanpar;

            p_edpar2->next = NULL;
            p_edpar2->info = (IGRchar *) p_pypt2;
            p_pypt2->info = (IGRchar *) p_edpar2;

            if (p_pypt2->next)
            {
              par0 = p_pypt2->next->span_inx + p_pypt2->next->param;
              if (fabs (par0 -par1) <= wtol)
              {
                p_pypt2->props = p_pypt1->next->props;
              }
              else if (fabs (par0 - par2) <= wtol)
              {
                p_pypt2->props = p_pypt1->props;
              }
              else 
              {
                p_pypt2->props = p_pypt1->props;
              }
              p_pypt2->props &= ~EMS_PYPT_ATSTART;
              p_pypt2->props &= ~EMS_PYPT_ATSTOP;
              p_pypt2->props |= EMS_PYPT_ATMIDDLE;
            }

            is_visited [indx] = TRUE;
          }

          indx ++;
          if (!p_pypt2->next)
            break;

          par0 = p_pypt2->next->span_inx + p_pypt2->next->param;
          if (!is_visited[indx] && par0 > (par1 + wtol) && par0 < (par2 - wtol))
          {
            /*
             * This represents the partial overlap. In which case we need to add
             * sfintedpar info and also set the PYPT props correctly.
             */
            if (coinced == PW_K_NullObjid)
            {
              struct PWcvdata  uvdata;
              struct PWcvparam param;
              PWpoint          midpt;
              double           tmppar;

              pwCnvtEMSCvdata (my_uvdata, &uvdata);
              tmppar = (p_pypt1->span_inx + p_pypt1->next->span_inx +
                        p_pypt1->param + p_pypt1->next->param) / 2.0;
              param.spaninx = (int) tmppar;
              param.spanpar = tmppar - (int) tmppar;

              pwPtAtParCvdata (&uvdata, &param, (double *)midpt);
              
              coinced = pwGetInterveningEdge (OS, p_edpar1->edgeid,
                                              pwPWCvint (p_edpar1->intloc),
                                              p_edpar1->next->edgeid,
                                             pwPWCvint (p_edpar1->next->intloc),
                                              midpt, uvtol);
            }

            p_edpar2 = ems$sfintedpar_malloc (msg = &msg_loc, num_nodes = 1);
            EMerr_hndlr (!p_edpar2, *msg, msg_loc, ret_end);
            p_edpar2->edgeid = coinced;
            p_edpar2->intloc = EMScvint_middle;
            p_edpar2->point[U] = p_pypt2->next->point[U];
            p_edpar2->point[V] = p_pypt2->next->point[V];

            /*
             * This is the time to generate the spaninx and parameter for
             * this UV point on the coincident edge. So, do a point project
             * on the coincident edge.
             */

            edpt [U] = p_edpar2->point[U];
            edpt [V] = p_edpar2->point[V];
            edid.objid = coinced; edid.osnum = OS;

            result = pwEdPtProject (&edid, 1, (PWpoint2d *) &edpt[0], uvtol, 
                                    &edcvpt);
            OnErrorState (IsError (result), *msg, result, ret_end);
 
            p_edpar2->edgepar.span_inx = edcvpt.cvparam.spaninx;
            p_edpar2->edgepar.param = edcvpt.cvparam.spanpar;

            p_edpar2->next = NULL;
            p_edpar2->info = (IGRchar *) p_pypt2->next;
            p_pypt2->next->info = (IGRchar *) p_edpar2;

            par0 = p_pypt2->span_inx + p_pypt2->param;
            if (fabs (par0 - par1) <= wtol)
            {
              p_pypt2->next->props = p_pypt1->next->props;
            }
            else if (fabs (par0 - par2) <= wtol)
            {
              p_pypt2->next->props = p_pypt1->props;
            }
            else
            {
              p_pypt2->next->props = p_pypt1->next->props;
            }
            p_pypt2->next->props &= ~EMS_PYPT_ATSTART;
            p_pypt2->next->props &= ~EMS_PYPT_ATSTOP;
            p_pypt2->next->props |= EMS_PYPT_ATMIDDLE;

            is_visited[indx] = TRUE;
          }

          indx ++;
          p_pypt2 = p_pypt2->next->next;
        }
      }
      p_pypt1 = p_pypt1->next->next;
    }
  }

  /*
   * There could be a problem with the tolerance. So, increase the tolerance
   * by two times, so that all the degenerate regions  will  gets  processed
   * correctly.
   */
  if (options & EMS_INTER_MINPOINTS)
    wtol *= 2.0; 

  EMintpybdrys (&msg_loc, my_bdrys1, my_bdrys2, wtol, &my_numbdrys, my_bdrys,
   EMsfintedpar_free, options);
  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
  my_bdrys1 = NULL;
  my_bdrys2 = NULL;
  if (!my_numbdrys)
    {
    my_bdry_parms = NULL;
    goto ret_end;
    }

  bdry = *my_bdrys;
  inxlim = my_numbdrys * 2;
  for (i=0; i<inxlim; i++)
    {
    if (!bdry->info)
      {
      bdryp = ems$sfintedpar_malloc (msg = &msg_loc, num_nodes = 1);  
      EMerr_hndlr (!bdryp, *msg, msg_loc, ret_end);
      bdryp->edgeid = NULL_OBJID;
      bdry->info = (IGRchar *) bdryp;
      }
    bdry = bdry->next;
    }
  bdry = *my_bdrys;
  *my_bdryparms = bdryp = (struct EMSsfintedpar *) bdry->info;
  for (i=0; i<inxlim-1; i++)
    {
    bdryp->next = (struct EMSsfintedpar *) bdry->next->info;
    bdry = bdry->next;
    bdryp = bdryp->next;
    }
  bdry->next = NULL;
  bdryp->next = NULL;
  my_bdry_parms = NULL;  

  if (_pathway_trim)
  {
    double *pt=NULL;
    PWboolean supply_missing_info;
    PWresult result=PW_K_Success;
    struct EMSpypoint *prev_bdry=NULL;
    struct EMSsfintedpar *prev_bdryp=NULL, *p_edpar=NULL;
    PWobjid bdryid;
    struct PWcvpt edpt;
    enum PWptloctype ptloc;

    bdry = *my_bdrys;
    bdryp = *my_bdryparms;
    inxlim = my_numbdrys * 2;
    for (i=0; i<inxlim-1; i++)
    {
      supply_missing_info = FALSE;

      if (bdry->props & EMS_PYPT_START_OVERLAP && 
          bdry->next && !(bdry->next->props & EMS_PYPT_STOP_OVERLAP))
      {
        pt = bdry->next->point;
        p_edpar = (struct EMSsfintedpar *) bdry->next->info;
        supply_missing_info = TRUE;

        bdry->next->props |= EMS_PYPT_STOP_OVERLAP;
      }

      else if (bdry->props & EMS_PYPT_STOP_OVERLAP && 
               prev_bdry && !(prev_bdry->props & EMS_PYPT_START_OVERLAP))
      {
        pt = prev_bdry->point;
        p_edpar = (struct EMSsfintedpar *) prev_bdry->info;
        supply_missing_info = TRUE;

        prev_bdry->props |= EMS_PYPT_START_OVERLAP;
      }

      if (supply_missing_info)
      {
        double chttol;

        BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
        result = pwSfPtLocate (&my_sfgmid, NULL, pt, chttol,
                  &ptloc, &bdryid, &edpt);
        OnErrorCode (result, ret_end);
        OnErrorState (ptloc != PWptloc_onedge && ptloc != PWptloc_onstartvtx &&
                       ptloc != PWptloc_onstopvtx, 
         result, SetError (PW_K_Trimming, PW_K_Internal), ret_end);

        pwCnvtCvptEMSsfed (&edpt, p_edpar);
      }

      prev_bdry = bdry;
      bdry = bdry->next;

      prev_bdryp = bdryp;
      bdryp = bdryp->next;
    }
  }

  /*
   * Intersect the two sets of solid boundaries for the data other_uvdata
   * and get the one set, other_bdrys, using EMintpybdrys. The output is a part
   * of the final output of this method. Note that the "num_bdrys" output
   * from the previous call to EMintpybdrys should be the same as the 
   * "num_bdrys" output from this call. This, because in the case of full
   * trim w.r.t. both boundaries, the number of pieces resulting on
   * either of the surfaces will be the same.
   * The associated linked list - "other_bdryparms" needs to be
   * maintatined.
   */

  if (! otherpartol_basis->is_valid)
    {
    if (other_data->datatype == EMSdata_object)
      {
      in_world = TRUE;
      stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                 mattyp, mat, &in_world, FALSE, &otherpartol_basis->tol),
                 targetid = other_data->data.object->objid,
                 targetos = other_data->data.object->osnum);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
      otherpartol_basis->is_valid = TRUE;
      }
    else
      {
      other_srf = other_data->data.surface;
      BSsfkttol2 (other_srf->u_order, other_srf->v_order,
       other_srf->u_knots, other_srf->v_knots, other_srf->u_num_poles,
       other_srf->v_num_poles, other_srf->poles, other_srf->weights,
       &otherpartol_basis->tol, &msg_loc);
      EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
      otherpartol_basis->is_valid = TRUE;
      }
    }
  EFextract_par (BSTOLLENVEC, otherpartol_basis->tol, &uvtol, &msg_loc);
  EMwpartol (&msg_loc, other_uvdata, other_bdrys1->span_inx, uvtol, &wtol);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * SPECIAL PROCESSING OF PARTIAL OVERLAPS
   * For every overlap region in other_bdrys1, scan the nodes of other_bdrys2.
   * If they lie within the region, generate the incident info for the node. 
   * The way this is being done is for every region in other_bdrys1, all the 
   * nodes of other_bdrys2 are gone through. If their incident info has been 
   * generated, this is marked in a local array. This is a quick fix to the 
   * pre-existing code and has to be redone with simpler logic. The 
   * pre-existing code tried to process both lists -- other_bdrys1 and 
   * other_bdrys2 -- in parallel and ended up missing generating incident info
   * on some nodes of other_bdrys2.
   */

  if (_pathway_trim)
  {
    struct EMSsfintedpar  *p_edpar1=NULL, *p_edpar2=NULL;
    struct EMSpypoint  *p_pypt1=NULL, *p_pypt2=NULL,*t_pypt=NULL;
    double par0=0, par1=0, par2=0;
    GRobjid coinced=NULL_OBJID;
    PWresult result=PW_K_Success;

    int indx=0,count=0;
    IGRboolean *is_visited = NULL;

    struct PWid edid;
    PWpoint2d edpt;
    struct PWcvpt edcvpt;

    t_pypt = other_bdrys1;
    while (t_pypt)
    {
     ++count;
     t_pypt = t_pypt->next;
    }
    if(!count) count = 1;
    is_visited = (IGRboolean *) alloca (count * 2 * my_numbdrys *
                                        sizeof (IGRboolean));
    memset (is_visited, 0, count * 2 * my_numbdrys * sizeof (IGRboolean));

    p_pypt1 = other_bdrys1;

    while (p_pypt1 && p_pypt1->next)
    { 
      indx = 0;
      p_pypt2 = other_bdrys2;

      if ( ((p_pypt1->props & EMS_PYPT_START_OVERLAP) && 
           (p_pypt1->next->props & EMS_PYPT_STOP_OVERLAP)) ||
           ((p_pypt1->props & EMS_PYPT_STOP_OVERLAP) &&
           (p_pypt1->next->props & EMS_PYPT_START_OVERLAP)) )
      {
        par1 = p_pypt1->span_inx + p_pypt1->param;
        par2 = p_pypt1->next->span_inx + p_pypt1->next->param;
        p_edpar1 = (struct EMSsfintedpar *) p_pypt1->info;

        if (par1 > par2)
        {
          pwSwapDouble (&par1, &par2);
        }
  
        while (p_pypt2)
        {
          coinced = PW_K_NullObjid;

          /*
           * get the intervening edge
           */
          par0 = p_pypt2->span_inx + p_pypt2->param;
          if (!is_visited[indx] && par0 > (par1 + wtol) && par0 < (par2 - wtol))
          {
            struct PWcvdata  uvdata;
            struct PWcvparam param;
            PWpoint          midpt;
            double           tmppar;

            /*
             * This represents the partial overlap. In which case we need to add
             * sfintedpar info and also set the PYPT props correctly.
             */
            
            pwCnvtEMSCvdata (other_uvdata, &uvdata);
            tmppar = (p_pypt1->span_inx + p_pypt1->next->span_inx +
                      p_pypt1->param + p_pypt1->next->param) / 2.0;
            param.spaninx = (int) tmppar;
            param.spanpar = tmppar - (int) tmppar;

            pwPtAtParCvdata (&uvdata, &param, (double *)midpt);

            coinced = pwGetInterveningEdge (OS, p_edpar1->edgeid,
                                            pwPWCvint (p_edpar1->intloc),
                                            p_edpar1->next->edgeid,
                                            pwPWCvint (p_edpar1->next->intloc),
                                            midpt, uvtol);

            p_edpar2 = ems$sfintedpar_malloc (msg = &msg_loc, num_nodes = 1);
            EMerr_hndlr (!p_edpar2, *msg, msg_loc, ret_end);
            p_edpar2->edgeid = coinced;
            p_edpar2->intloc = EMScvint_middle;
            p_edpar2->point[U] = p_pypt2->point[U];
            p_edpar2->point[V] = p_pypt2->point[V];

            /*
             * This is the time to generate the spaninx and parameter for
             * this UV point on the coincident edge. So, do a point project 
             * on the coincident edge.
             */
            edpt[U] = p_edpar2->point[U];
            edpt[V] = p_edpar2->point[V];
            edid.objid = coinced; edid.osnum = OS;

            result = pwEdPtProject (&edid, 1, (PWpoint2d *) &edpt[0], uvtol, 
                                    &edcvpt);
            OnErrorState (IsError (result), *msg, result, ret_end);
          
            p_edpar2->edgepar.span_inx = edcvpt.cvparam.spaninx;
            p_edpar2->edgepar.param = edcvpt.cvparam.spanpar;

            p_edpar2->next = NULL;
            p_edpar2->info = (IGRchar *) p_pypt2;
            p_pypt2->info = (IGRchar *) p_edpar2;

            if (p_pypt2->next)
            {
              par0 = p_pypt2->next->span_inx + p_pypt2->next->param;
              if (fabs (par0 -par1) <= wtol)
              {
                p_pypt2->props = p_pypt1->next->props;
              }
              else if (fabs (par0 - par2) <= wtol)
              {
                p_pypt2->props = p_pypt1->props;
              }
              else
              {
                p_pypt2->props = p_pypt1->props;
              }

              p_pypt2->props &= ~EMS_PYPT_ATSTART;
              p_pypt2->props &= ~EMS_PYPT_ATSTOP;
              p_pypt2->props |= EMS_PYPT_ATMIDDLE;

              is_visited[indx] = TRUE;
            }
          }

          indx ++;
          if( !p_pypt2->next)
            break;
        
          par0 = p_pypt2->next->span_inx + p_pypt2->next->param;
          if (!is_visited[indx] && par0 > (par1 + wtol) && par0 < (par2 - wtol))
          {
            /*
             * This represents the partial overlap. In which case we need to add
             * sfintedpar info and also set the PYPT props correctly.
             */
            if (coinced == PW_K_NullObjid)
            {
              struct PWcvdata  uvdata;
              struct PWcvparam param;
              PWpoint          midpt;
              double           tmppar;

              pwCnvtEMSCvdata (other_uvdata, &uvdata);
              tmppar = (p_pypt1->span_inx + p_pypt1->next->span_inx +
                        p_pypt1->param + p_pypt1->next->param) / 2.0;
              param.spaninx = (int) tmppar;
              param.spanpar = tmppar - (int) tmppar;

              pwPtAtParCvdata (&uvdata, &param, (double *)midpt);

              coinced = pwGetInterveningEdge (OS, p_edpar1->edgeid,
                                              pwPWCvint (p_edpar1->intloc),
                                              p_edpar1->next->edgeid,
                                             pwPWCvint (p_edpar1->next->intloc),
                                              midpt, uvtol);
            }

            p_edpar2 = ems$sfintedpar_malloc (msg = &msg_loc, num_nodes = 1);
            EMerr_hndlr (!p_edpar2, *msg, msg_loc, ret_end);
            p_edpar2->edgeid = coinced;
            p_edpar2->intloc = EMScvint_middle;
            p_edpar2->point[U] = p_pypt2->next->point[U];
            p_edpar2->point[V] = p_pypt2->next->point[V];

            /*
             * This is the time to generate the spaninx and parameter for
             * this UV point on the coincident edge. So, do a point project 
             * on the coincident edge.
             */

            edpt [U] = p_edpar2->point[U];
            edpt [V] = p_edpar2->point[V];
            edid.objid = coinced; edid.osnum = OS;

            result = pwEdPtProject (&edid, 1, (PWpoint2d *) &edpt[0], uvtol, 
                                    &edcvpt);
            OnErrorState (IsError (result), *msg, result, ret_end);
          
            p_edpar2->edgepar.span_inx = edcvpt.cvparam.spaninx;
            p_edpar2->edgepar.param = edcvpt.cvparam.spanpar;

            p_edpar2->next = NULL;
            p_edpar2->info = (IGRchar *) p_pypt2->next;
            p_pypt2->next->info = (IGRchar *) p_edpar2;
            
            par0 = p_pypt2->span_inx + p_pypt2->param;
            if (fabs (par0 -par1) <= wtol)
            {
              p_pypt2->next->props = p_pypt1->next->props;
            }
            else if (fabs (par0 - par2) <= wtol)
            {
              p_pypt2->next->props = p_pypt1->props;
            }
            else
            {
              p_pypt2->next->props = p_pypt1->next->props;
            }
            p_pypt2->next->props &= ~EMS_PYPT_ATSTART;
            p_pypt2->next->props &= ~EMS_PYPT_ATSTOP;
            p_pypt2->next->props |= EMS_PYPT_ATMIDDLE;

            is_visited[indx] = TRUE;
          }
 
          indx ++;
          p_pypt2 = p_pypt2->next->next;
        }
      }
      p_pypt1 = p_pypt1->next->next;
    }
  }

  /*
   * There could be a problem with the tolerance. So, increase the tolerance
   * by two times, so that all the degenerate regions  will  gets  processed 
   * correctly.
   */
  if (options & EMS_INTER_MINPOINTS)
    wtol *= 2.0; 

  EMintpybdrys (&msg_loc, other_bdrys1, other_bdrys2, wtol, &other_numbdrys,
   other_bdrys, EMsfintedpar_free, options);
  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
  other_bdrys1 = NULL;
  other_bdrys2 = NULL;

  /* 
   * Due to trimming problems, there might be NO boundaries left the other
   * loopset (other_numbdrys == 0), although there are boundaries on myself
   * (my_numbdrys != 0). In this case, dont bother with the recursive call to
   * EMfulltrim (by NOT setting the EMS_E_IntersectTrim error code) and pretend
   * as if there is no intersection between the surfaces. (NP 4/9/93)
   */

  if (!other_numbdrys)
    { 
    other_bdry_parms = NULL;
    *num_bdrys = 0; 
    goto ret_end;
    }
  
  /* 
   * If the boundaries dont match, and since BOTH have non-zero number of
   * boundaries, then there is a trimming problem. (NP 4/9/93)
   */

  if (other_numbdrys != my_numbdrys)
    {
    other_bdry_parms = NULL;
    *msg = EMS_E_IntersectTrim;
    goto ret_end;
    }
  *num_bdrys = other_numbdrys;

  bdry = *other_bdrys;
  inxlim = other_numbdrys * 2;
  for (i=0; i<inxlim; i++)
    {
    if (!bdry->info)
      {
      bdryp = ems$sfintedpar_malloc (msg = &msg_loc, num_nodes = 1);  
      EMerr_hndlr (!bdryp, *msg, msg_loc, ret_end);
      bdryp->edgeid = NULL_OBJID;
      bdry->info = (IGRchar *) bdryp;
      }
    bdry = bdry->next;
    }
  bdry = *other_bdrys;
  *other_bdryparms = bdryp = (struct EMSsfintedpar *) bdry->info;
  for (i=0; i<inxlim-1; i++)
    {
    bdryp->next = (struct EMSsfintedpar *) bdry->next->info;
    bdry = bdry->next;
    bdryp = bdryp->next;
    }
  bdry->next = NULL;
  bdryp->next = NULL;
  other_bdry_parms = NULL;

  if (_pathway_trim)
  {
    double *pt=NULL;
    PWboolean supply_missing_info;
    PWresult result=PW_K_Success;
    struct EMSpypoint *prev_bdry=NULL;
    struct EMSsfintedpar *prev_bdryp=NULL, *p_edpar=NULL;
    PWobjid bdryid;
    struct PWcvpt edpt;
    enum PWptloctype ptloc;

    bdry = *other_bdrys;
    bdryp = *other_bdryparms;
    inxlim = *num_bdrys * 2;
    for (i=0; i<inxlim-1; i++)
    {
      supply_missing_info = FALSE;

      if (bdry->props & EMS_PYPT_START_OVERLAP && 
          bdry->next && !(bdry->next->props & EMS_PYPT_STOP_OVERLAP))
      {
        pt = bdry->next->point;
        p_edpar = (struct EMSsfintedpar *) bdry->next->info;
        supply_missing_info = TRUE;

        bdry->next->props |= EMS_PYPT_STOP_OVERLAP;
      }

      else if (bdry->props & EMS_PYPT_STOP_OVERLAP && 
               prev_bdry && !(prev_bdry->props & EMS_PYPT_START_OVERLAP))
      {
        pt = prev_bdry->point;
        p_edpar = (struct EMSsfintedpar *) prev_bdry->info;
        supply_missing_info = TRUE;

        prev_bdry->props |= EMS_PYPT_START_OVERLAP;
      }

      if (supply_missing_info)
      {
        double chttol;

        BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
        result = pwSfPtLocate (&other_sfgmid, NULL, pt, chttol,
                  &ptloc, &bdryid, &edpt);
        OnErrorCode (result, ret_end);
        OnErrorState (ptloc != PWptloc_onedge && ptloc != PWptloc_onstartvtx &&
                      ptloc != PWptloc_onstopvtx, 
         result, SetError (PW_K_Trimming, PW_K_Internal), ret_end);

        pwCnvtCvptEMSsfed (&edpt, p_edpar);
      }

      prev_bdry = bdry;
      bdry = bdry->next;

      prev_bdryp = bdryp;
      bdryp = bdryp->next;
    }
  }

ret_end:
  /*
   * Deallocate memory that was temporarily allocated
   * within this method call, if the memory hasn't yet
   * been freed. The NULL check is included in the function calls.
   */

  ems$pypoint_free (pypts = my_bdrys1);
  ems$pypoint_free (pypts = my_bdrys2);
  ems$pypoint_free (pypts = other_bdrys1);
  ems$pypoint_free (pypts = other_bdrys2);
                    
  EMsfintedpar_free (my_bdry_parms, NULL);
  EMsfintedpar_free (other_bdry_parms, NULL);

  /*
   * If the error is EMS_E_IntersectTrim (num boundaries mismatch) then
   * try to elliminate degenerate boundaries as a last ditch effort to
   * correct the situation. For this set the option to EMS_INTER_MINPOINTS
   * and recursively call this method. This, if the option is not already
   * set. But clean up the output that would have been, before making the
   * recursive call.
   */

  if (*msg == EMS_E_IntersectTrim && !(options & EMS_INTER_MINPOINTS))
    {
    ems$pypoint_free (pypts = *my_bdrys);
    ems$pypoint_free (pypts = *other_bdrys);  
    EMsfintedpar_free (*my_bdryparms, NULL);
    EMsfintedpar_free (*other_bdryparms, NULL);

    stat_OM = om$send (msg = message EMSloopset.EMlsfulltrim (msg, mattyp, mat,
               my_uvdata, my_xyzdata, my_srf, mypartol_basis,
               other_data, other_datenv, other_uvdata, other_xyzdata,
               other_srf, otherpartol_basis,
               correl_params, options | EMS_INTER_MINPOINTS,
               num_bdrys, my_bdrys, my_bdryparms,
               other_bdrys, other_bdryparms), targetid = my_id);
    }

  /* stop timer for EMlsfulltrim */
  if (_use_timers)
    stop_timer (T_EMLSFULLTRIM, FALSE, "");

  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMlsfulltrim");
  if (other_data->datatype == EMSdata_object)
    PW_WrapupIdId (*msg, "EMlsfulltrim", my_id, 
     other_data->data.object->objid);
  return (stat_OM);
}



end implementation EMSloopset;
