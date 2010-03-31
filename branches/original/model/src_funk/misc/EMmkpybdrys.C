/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
  DESCRIPTION

    Given a list of sorted points lying on a curve or a linestring, generated
    by intersection with an area, this function converts this list into a
    sorted list of bounds that would represent the portion(s) lying within
    the area. It interprets the information stored in the props field of
    each of the point-structures and processes accordingly. The curve or
    the linestring can be 2D or 3D.

    At the endpoints of the curve/linestring, point-structures may have to be
    added to output the boundaries. Such point-structures allocated within
    this function are also returned on the argument list for user-
    interpretation. 

    If a degenerate (NULL-length) boundary is going to be output at any of
    the endpoints, this functions detects the same and removes such points
    from the list. By removal is simply meant the exclusion from the 
    output list. The addresses of such removed point-structures are returned
    on the argument list. 

    If no point list is given, the entire curve/linestring is determined to
    be in area.

    The boundary list is either NULL-terminated or terminated by a node
    with it's empty property bit set.

  ARGUMENTS

    indata		- Input: The curve or the linestring on which the
                          boundaries are being computed.
    pylist		- Input/Output: The linked list of point-structures
                          that represent the intersections on indata. This
                          list is input sorted in the direction of increasing
                          parameterization. These same points (including
                          the structures) are used for the boundary-pairs.
                          Some might get added or deleted during the course
                          of this function.
    num_bdrys		- Output: The number of boundary pairs that are output.
    addatstart		- Output: If point-structure had to be added at 
                          the beginning, it's address is returned here. Else
                          a NULL address is returned.
    addatstop		- Output: If point-structure had to be added at 
                          the end, it's address is returned here. Else
                          a NULL address is returned.
    rematstart		- Output: If the point-structure at the beginning
                          had to be removed, it's address is returned.
                          Else NULL address.
    rematstop		- Output: If the point-structure at the end
                          had to be removed, it's address is returned.
                          Else NULL address.

  RETURN VALUE

    This is a function returning void. The return code in the msg argument
    could be one of the following:

    EMS_S_Success
      - If all went well

    EMS_E_InvalidArg
      - If the datatype for the curve/linestring is not 2D or 3D polyline
        or 2D or 3D curve.
        If the props field in the input list of point-structures indicates
        an invalid sequence of points.
    EMS_E_NoDynamicMemory
      - Error encountered while allocating dynamic memory.

  HISTORY

    SS  :  10/13/87  :  Creation
*/
# include "OMerrordef.h"
# include "OMminimum.h"
# include "OMmacros.h"
# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "gr.h"
# include "godef.h"
# include "go.h"
# include "EMSbnddef.h"
# include "EMSmsgdef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "EMSbnd.h"
# include "emsdef.h"
# include "emserr.h"

void EMmkpybdrys (msg, indata, pylist, num_bdrys, addatstart, addatstop,
                  rematstart, rematstop)
IGRlong *msg;
struct EMSdataselect *indata;
struct EMSpypoint **pylist;
IGRint *num_bdrys;
struct EMSpypoint **addatstart, **addatstop;
struct EMSpypoint **rematstart, **rematstop;
{
  IGRboolean in_area;
  IGRushort props;
  IGRshort dim;
  IGRint lastspan, lastptinx, stat_func, i;
  IGRlong msg_loc;
  IGRdouble *firstpt, *lastpt, firstpt_mem[3], lastpt_mem[3];
  struct IGRpolyline *inpoly;
  struct IGRbsp_curve *incrv;
  struct EMSpypoint *pyptr, *temp_pyptr;
  union EMSdata data;
  enum EMSdatatype datatype;
  struct EMSpypoint *EMmkpyptlist();

  *msg = EMS_S_Success;
  if (addatstart) *addatstart = NULL;
  if (addatstop) *addatstop = NULL;
  if (rematstart) *rematstart = NULL;
  if (rematstop) *rematstop = NULL;
  *num_bdrys = 0;
  if (!pylist)
    goto ret_end;

  pyptr = NULL;
  temp_pyptr = NULL;
  datatype = indata->datatype;
  data = indata->data;
  if (datatype == EMSdata_poly2d || datatype == EMSdata_poly3d)
    {
    dim = (datatype == EMSdata_poly2d ? 2 : 3);
    inpoly = data.poly;
    firstpt = inpoly->points;
    lastpt = &inpoly->points[(inpoly->num_points-1)*dim];
    lastspan = inpoly->num_points-2;
    }
  else if (datatype == EMSdata_curve2d || datatype == EMSdata_curve3d)
    {
    dim = (datatype == EMSdata_curve2d ? 2 : 3);
    incrv = data.curve;
    lastptinx = incrv->num_poles-1;
    firstpt = incrv->poles;
    lastpt = &incrv->poles[lastptinx*dim];
    if (incrv->rational)
      {
      OM_BLOCK_MOVE (firstpt, firstpt_mem, 3 * sizeof (IGRdouble)); 
      OM_BLOCK_MOVE (lastpt, lastpt_mem, 3 * sizeof (IGRdouble));
      firstpt = firstpt_mem;
      lastpt = lastpt_mem;
      for (i=0; i<dim; i++)
        {
        firstpt[i] /= incrv->weights[0];
        lastpt[i] /= incrv->weights[lastptinx];
        }
      }
    lastspan = 0;
    }
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * If no point-list has been passed in, the entire line-string is
   * treated in area and one boundary corresponding to the line-string
   * is returned.
   */

  if (! *pylist)
    {
    temp_pyptr = EMmkpyptlist (&msg_loc, pylist, 0, 0.0, firstpt,
                  EMS_PYPT_ATSTART | EMS_PYPT_AREAAREA, 
                  NULL, dim, FALSE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    if (addatstart)
      *addatstart = temp_pyptr;

    temp_pyptr = EMmkpyptlist (&msg_loc, pylist, lastspan, 1.0, lastpt,
                  EMS_PYPT_ATSTOP | EMS_PYPT_AREAAREA,
                  NULL, dim, FALSE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    if (addatstop)
      *addatstop = temp_pyptr;

    *num_bdrys = 1;
    }
  else
    {
    /*
     * Process the first node in the linked list. At the
     * end of this processing, the current state is either
     * 'in hole' or 'in area'. The next node to be processed
     * is available in 'pyptr'. And the properties of this
     * next node are in 'props'.
     */

    pyptr = *pylist;
    props = pyptr->props;
    if (props & EMS_PYPT_ATSTART)
      {
      if (props & EMS_PYPT_AREAHOLE ||
          props & EMS_PYPT_HOLEHOLE)
        {
        pyptr->props |= EMS_PYPT_EMPTY;
        if (rematstart)
          *rematstart = pyptr;
        *pylist = pyptr->next;
        pyptr = *pylist;
        in_area = FALSE;
        }
      else if (props & EMS_PYPT_HOLEAREA ||
               props & EMS_PYPT_AREAAREA)
        in_area = TRUE;
      else
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
      }
    else if (props & EMS_PYPT_ATMIDDLE)
      {
      if (props & EMS_PYPT_AREAHOLE)
        { 
        temp_pyptr = EMmkpyptlist (&msg_loc, &temp_pyptr, 0, 0.0, firstpt,
                      EMS_PYPT_ATSTART | EMS_PYPT_AREAAREA, NULL, dim, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        if (addatstart)
          *addatstart = temp_pyptr;
        temp_pyptr->next = *pylist;
        *pylist = temp_pyptr;
        (*num_bdrys)++;
        in_area = FALSE;
        }
      else if (props & EMS_PYPT_HOLEAREA)
        in_area = TRUE;
      else
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
      }
    else if (props & EMS_PYPT_ATSTOP)
      {
      if (props & EMS_PYPT_AREAHOLE ||
          props & EMS_PYPT_AREAAREA)
        { 
        temp_pyptr = EMmkpyptlist (&msg_loc, &temp_pyptr, 0, 0.0, firstpt,
                      EMS_PYPT_ATSTART | EMS_PYPT_AREAAREA, NULL, dim, FALSE);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        if (addatstart)
          *addatstart = temp_pyptr;
        temp_pyptr->next = *pylist;
        *pylist = temp_pyptr;
        (*num_bdrys)++;
        EMerr_hndlr (pyptr->next, *msg, EMS_E_InvalidArg, ret_end);
        goto ret_end;
        }
      else if (props & EMS_PYPT_HOLEAREA ||
               props & EMS_PYPT_HOLEHOLE)
        {
        pyptr->props |= EMS_PYPT_EMPTY;
        if (rematstart)
          *rematstart = pyptr;
        *pylist = pyptr->next;
        pyptr = *pylist;
        EMerr_hndlr (pyptr->next, *msg, EMS_E_InvalidArg, ret_end);
        goto ret_end;
        }
      else
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
      }
    else
      EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
    pyptr = pyptr->next;
    if(pyptr)
      props = pyptr->props;

    /*
     * Process all the internal nodes, keeping track of
     * the toggling from hole to area. If these nodes do not
     * toggle right, an error code is returned. At the end of this 
     * processing, state is either 'in hole' or 'in area'. The number
     * of area-boundaries being output is constantly updated as soon as
     * a complete boundary has been traversed. Nodes at end-points have
     * to be treated specially in order to ensure no degeneracy results
     * in the boundaries being output.
     */

    while (pyptr)
      {
      if (in_area && 
          (props & EMS_PYPT_AREAHOLE &&
           !(props & EMS_PYPT_ATSTOP)))
        {
        (*num_bdrys)++;
        in_area = FALSE;
        }
      else if (!in_area && 
               (props & EMS_PYPT_HOLEAREA &&
                !(props & EMS_PYPT_ATSTOP)))
        {
        in_area = TRUE;
        }
      else if (in_area &&
               (props & EMS_PYPT_ATSTOP && 
                (props & EMS_PYPT_AREAHOLE || props & EMS_PYPT_AREAAREA)))
        {
        EMerr_hndlr (pyptr->next, *msg, EMS_E_InvalidArg, ret_end);
        (*num_bdrys)++;
        in_area = FALSE;
        break;
        }
      else if (!in_area &&
               (props & EMS_PYPT_ATSTOP && 
                (props & EMS_PYPT_HOLEAREA || props & EMS_PYPT_HOLEHOLE)))
        {
        EMerr_hndlr (pyptr->next, *msg, EMS_E_InvalidArg, ret_end);        
        pyptr->props |= EMS_PYPT_EMPTY;
        if (rematstop)
          *rematstop = pyptr;
        break;
        }
      else
        EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);
      pyptr = pyptr->next;
      if(pyptr)
        props = pyptr->props;
      }

    /*
     * The termination of this processing is done by looking at the
     * current state. If the state is in hole, no more area-boundaries
     * exist. But if the state is in area then the last point of the 
     * polyline is also in area and forms the stop-point for this last
     * boundary
     */

    if (in_area)
      {
      temp_pyptr = EMmkpyptlist (&msg_loc, pylist, lastspan, 1.0, lastpt,
                    EMS_PYPT_ATSTOP | EMS_PYPT_AREAAREA, 
                    NULL, dim, FALSE);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      if (addatstop)
        *addatstop = temp_pyptr;
      (*num_bdrys)++;
      }
    }

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "EMmkpybdrys");
}
