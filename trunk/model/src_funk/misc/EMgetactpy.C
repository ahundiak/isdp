/*
  DESCRIPTION

    A linked list of two EMpypoints is input and these represent the 
    boundary on the input polyline. The polyline could be 1D, 2D or 3D 
    depending on "dimension" (=1, =2 or =3). This function then extracts the
    linestring lying in between these two boundaries and returns it as
    outpoly. 
 
    If the points pointer in outpoly was set to NULL, the memory for the
    points is malloced within this function, if not the memory is assumed
    to have been allocated by the calling function.

    The input boundary need not be in increasing order. The part that is
    extracted will always be the region within the bounds specified.

  RETURN VALUE

    EMS_S_Success -
      If all went well and the output was not really clipped
    EMS_I_Clipped - 
      If all went well and the output was really clipped

    On error an EMS_E_InvalidArg or EMS_E_NoDynamicMemory is returned

  HISTORY

    SS  :  Long time :  Creation
    SS  :  02/16/89  :  Added the return code EMS_I_Clipped
*/

#include "EMS.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"

void EMgetactpy (msg, inpoly, dim, pybdry, outpoly)
IGRlong *msg;
struct IGRpolyline *inpoly;
IGRshort dim;
struct EMSpypoint *pybdry;
struct IGRpolyline *outpoly;
{
  IGRint dimsize, size;
  IGRlong num_points, count_inx1, count_inx2;
  IGRlong cp_inx1, cp_inx2;
  struct EMSpypoint *loc_pybdry, loc_pybdry_mem[2];

  *msg = EMS_S_Success;

  /*
   * The input boundary is taken into local variables and made
   * consistent with an increasing order.
   */

  OM_BLOCK_MOVE (pybdry, &loc_pybdry_mem[0], sizeof (struct EMSpypoint));
  OM_BLOCK_MOVE (pybdry->next, &loc_pybdry_mem[1], sizeof (struct EMSpypoint));
  if (pybdry->span_inx + pybdry->param > 
      pybdry->next->span_inx + pybdry->next->param)
    {
    loc_pybdry_mem[1].next = &loc_pybdry_mem[0];
    loc_pybdry_mem[0].next = NULL;
    loc_pybdry = &loc_pybdry_mem[1];
    }
  else
    {
    loc_pybdry_mem[0].next = &loc_pybdry_mem[1];
    loc_pybdry_mem[1].next = NULL;
    loc_pybdry = &loc_pybdry_mem[0];
    }

  /*
   * Compute the number of vertices, and the indices for copying -
   * cp_inx1 and cp_inx2. This, by numbering the boundary indices-to-be,
   * correctly (count_inx1 and count_inx2).
   */

  if (loc_pybdry->param == 1.0)
    {
    count_inx1 = loc_pybdry->span_inx + 1;
    cp_inx1 = count_inx1 + 1;
    *msg = EMS_I_Clipped;
    }
  else
    {
    count_inx1 = loc_pybdry->span_inx;
    cp_inx1 = count_inx1 + 1;
    if (count_inx1 != 0 || loc_pybdry->param != 0.0)
      *msg = EMS_I_Clipped;
    }

  if (loc_pybdry->next->param == 0.0)
    {
    count_inx2 = loc_pybdry->next->span_inx;
    cp_inx2 = count_inx2 - 1;
    *msg = EMS_I_Clipped;
    }
  else
    {
    count_inx2 = loc_pybdry->next->span_inx + 1;
    cp_inx2 = loc_pybdry->next->span_inx;
    if (count_inx2 != inpoly->num_points-1 || loc_pybdry->next->param != 1.0)
      *msg = EMS_I_Clipped;
    }

  /*
   * Compute the number of points to be output. The number should
   * never be less than 2. A degenerate segment consisting of one
   * might be created (p1 = 1.0 and p2 = 0.0) but, the number of points
   * is changed to 2 and the first and last point repeated.
   */

  num_points = count_inx2 - count_inx1 + 1;
  if (num_points == 1)
    {
    num_points = 2;
    *msg = EMS_I_Degenerate;
    }
  EMerr_hndlr (num_points <= 1 || dim < 1 || dim > 3, *msg, EMS_E_InvalidArg,
   ret_end);
  
  
  /*
   * Allocate space for the output,
   * if necessary and copy the points.
   */

  dimsize = dim * sizeof (IGRdouble);
  if (! outpoly->points)
    {
    outpoly->points = (IGRdouble *) om$malloc (size = num_points * dimsize);
    EMerr_hndlr (! outpoly->points, *msg, EMS_E_DynamicMemoryAllocated,
     ret_end);
    }
  outpoly->num_points = num_points;

  OM_BLOCK_MOVE (loc_pybdry->point, &outpoly->points[0], dimsize);
  if (cp_inx2 >= cp_inx1)
    {
    size = dimsize * (cp_inx2 - cp_inx1 + 1);
    OM_BLOCK_MOVE (&inpoly->points[cp_inx1*dim], &outpoly->points[dim], size);
    }
  OM_BLOCK_MOVE (loc_pybdry->next->point, &outpoly->points[(num_points-1)*dim],
   dimsize);

ret_end:;
}

