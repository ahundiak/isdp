/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This method returns the polyline-boundaries on the input uv-data
    that represent the "solid" portions on it  after clipping or trimming with
    respect to the surfaces boundaries. This uv-data could be in the
    form of 2D polylines or 3D B-spline curve (of which only the first
    two dimensions are significant).

    If there is no loopset on this surface, no trimming is really required
    and the boundaries corresponding to the entire line-string are returned
    as the output.

  ARGUMENTS

    mattyp, mat		- Input: The matrix and matrix-type to be used for this
			  object.
    my_uvdata		- Input: The data containing the parametric line
 			  definition on this surface that has to be trimmed
			  w.r.t. to the surface boundaries.
    options		- Input: This mask dictates the type of trimming to
                          be performed. For now, should be NULL.
    num_bdrys		- Output: The number of boundary pairs that define the
			  portion on the line data that is to be KEPT.
    bdrys 		- Output: Linked lists containing the ordered lists of 
    			  trim points for my_uvdata.
    bdry_parms		- Output: Linked lists containing information on
    			  the surface-edges that generated these trim points.
                          If a specific trim point was not generated explicitly
			  by an edge on this surface (perhaps by because it is 
			  a dangling end-point) the edgeid field in the node
                          would have been set to NULL_OBJID.

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
    
  ALGORITHM
 
    This is basically a 'passon' method which switches the operation to
    the surface-loopset. If there is no loopset on this surface,
    no trimming is really required and the boundaries corresponding to the
    entire line-data are returned as the output.

  SEE ALSO

    The file containing the loopset method - EMlsparttrim.

  HISTORY

    SS  :  11/01/86  :  Creation
    NP  :  08/25/92  :  Modified for ANSI compliance. Changed declarations of 
			"stat_OM" and "num_loopset" to "IGRlong" and "IGRuint"
			respectively. Also, "epptr" had been mistakenly typecast to
			"struct EMsfintedpar *" instead of "struct EMSsfintedpar *"
                                ^^                                  ^^^
*/

class implementation EMSsubbs;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloopset import EMlsparttrim, EMget_props;

method EMparttrim (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                   struct EMSdataselect *my_uvdata; 
                   IGRushort options;
                   IGRint *num_bdrys; struct EMSpypoint **bdrys;
                   struct EMSsfintedpar **bdry_parms)
{
  IGRboolean in_world = TRUE;
  IGRlong stat_OM;
  IGRuint num_loopset;
  IGRlong msg_loc;
  IGRdouble firstpt[2], lastpt[2];
  struct EMSpartolbasis tolbasis;
  struct IGRpolyline *inpoly;
  struct IGRbsp_curve *incrv;
  struct EMSsfintedpar *epptr;
  enum EMSdatatype geomtype;
  OM_S_CHANSELECT chan_to_loopset;
  void EMmkpybdrys();
  struct EMSsfintedpar *EMsfintedpar_malloc();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_bdrys = 0;
  if(bdrys) *bdrys = NULL;
  if(bdry_parms) *bdry_parms = NULL;

  geomtype = my_uvdata->datatype;
  EMerr_hndlr (geomtype != EMSdata_poly2d && geomtype != EMSdata_curve3d,
   *msg, EMS_E_InvalidArg, ret_end);

  chan_to_loopset.type = OM_e_addr;
  chan_to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;

  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_loopset,
             count = &num_loopset);
  EMomerr_exit (stat_OM, ret_end);

  if (num_loopset)
    {
    /* 
     * This surface has a loopset and therefore, the trimming
     * can be taken care of by it.
     */

    stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
               mattyp, mat, &in_world, FALSE, &tolbasis.tol),
               targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
    tolbasis.is_valid = TRUE;

    stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
               my_uvdata, &tolbasis, options, num_bdrys, bdrys, bdry_parms),
               p_chanselect = &chan_to_loopset);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
    }
  else
    {
    /*
     * Since the surface has no boundaries, there is
     * essentially no trimming. Return the boundaries that 
     * represent the  entire line-string.
     */

    if (bdrys || bdry_parms)
      {
      if (bdrys)
        {
        EMmkpybdrys (&msg_loc, my_uvdata, bdrys, num_bdrys, NULL, NULL,
         NULL, NULL);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        }
      if (bdry_parms)
        {                                                
        epptr = (struct EMSsfintedpar *) EMsfintedpar_malloc (&msg_loc, 2);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_NoDynamicMemory, ret_end);
        epptr->edgeid = NULL_OBJID;
        epptr->next->edgeid = NULL_OBJID;
        *bdry_parms = epptr;
        }
      }
    else
      *num_bdrys = 1;
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMparttrim");
  return (stat_OM);
}

end implementation EMSsubbs;
