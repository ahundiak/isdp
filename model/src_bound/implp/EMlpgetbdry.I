/*
  DESCRIPTION

    This method returns the loop (and it's children, as specified by
    'depth') in the form of an array of closed polylines (the beginning and
    ending point are repeated). Each of the loops has been packaged as a
    linestring. This geometry is available in xyz and/or uv. In addition,
    the loops' stored uv-range, it's properties and it's object-id may
    be obtained (whenever the corresponding argument is non-NULL).

    This method will not return those inner loops as boundaries that have
    a degenerate or undefined (as in open-loops) area and are at the same
    time standalone (they do not have any topological connection with
    any other edge). This behaviour, though, can be overridden by specifying
    EMS_GETB_INCLUDEDEGEN. A finer control on including certain types of
    degenerate loops can be achieved by specifying EMS_GETB_INCLUDETOPODEGEN.
    By specifying this option those loops that have any topological connection
    with other edges get included, regardless.

    When the EMS_GETB_COMPATIBLEXYZ option is used, this method will return
    the xyz data solely from the non-subordinate edges out of the pair of
    common edges. Under this option the xyz end-points of all the edges
    terminating at a vertex will be consistent (identically exact).
    This has the effect of consistent geometry being returned from adjacent
    surfaces.

    The option EMS_GETB_COMPATIBLEUV option, will return uv data that contains
    the same number of points as the non-subordinate, stroked edge will
    have. This ensures one to one correspondence between points in uv-space
    and xyz-space, even across surfaces. The option to EMS_GETB_STROKEISO,
    can be used to force the iso-edge to be stroked even if the compatibility
    option is not used.

    The first call to this method must initialize the output arguments
    to NULLS. All memory is allocated inside the call to this method.

  HISTORY

    SS  :  06/14/90  :  Creation. Initial stuff from EMlppack
*/

class implementation EMSloop;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSedge import EMgetstrkpy;

method EMlpgetbdry (IGRlong *msg;
                    IGRshort *mattyp; IGRmatrix mat;
                    struct IGRbsp_surface *srfgeom;
                    struct EMSpartolbasis *partolbas;
                    IGRushort options;
                    IGRint depth;
                    IGRint *numbdrys;
                    struct IGRpolyline **xyzbdrys, **uvbdrys;
                    IGRdouble **lpranges; IGRushort **lpprops;
                    GRobjid **lpids)
{
  IGRboolean reversed, is_degen, is_connected;
  IGRushort loc_options;
  IGRint i, j, lastinx, relinx;
  IGRint locnum, numb, num_xyzpts, num_uvpts;
  OMuint count;
  IGRlong msg_loc, stat_OM;
  IGRdouble *uvpts, *xyzpts, (*ptr2)[2], (*ptr3)[3], uvtol;
  struct IGRpolyline *xyzb, *uvb;
  OM_S_CHANSELECT chan_to_edges, chan_to_inner;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  uvpts = NULL;
  xyzpts = NULL;
  numb = *numbdrys;

  if (xyzbdrys)
    {
    if (*xyzbdrys)
      *xyzbdrys = (struct IGRpolyline *) om$realloc (ptr = (char *) *xyzbdrys, 
                   size = (numb + 1) * sizeof (struct IGRpolyline));
    else
      *xyzbdrys = (struct IGRpolyline *) om$malloc (size = 
                   sizeof (struct IGRpolyline));
    EMerr_hndlr (!*xyzbdrys, *msg, EMS_E_NoDynamicMemory, ret_end);
    xyzb = &(*xyzbdrys)[numb];
    xyzb->num_points = 0;
    xyzb->points = NULL;
    }
  else
    xyzb = NULL;

  if (uvbdrys)
    {
    if (*uvbdrys)
      *uvbdrys = (struct IGRpolyline *) om$realloc (ptr = (char *) *uvbdrys, 
                  size = (numb + 1) * sizeof (struct IGRpolyline));
    else
      *uvbdrys = (struct IGRpolyline *) om$malloc (size = 
                  sizeof (struct IGRpolyline));
    EMerr_hndlr (!*uvbdrys, *msg, EMS_E_NoDynamicMemory, ret_end);
    uvb = &(*uvbdrys)[numb];
    uvb->num_points = 0;
    uvb->points = NULL;
    }
  else
    uvb = NULL;

  if (lpranges)
    {
    if (*lpranges)
      *lpranges = (IGRdouble *)om$realloc (ptr = (char *) *lpranges, 
      		size = (numb + 1) * 4 * sizeof (IGRdouble));
    else
      *lpranges = (IGRdouble *)om$malloc (size = 4 * sizeof (IGRdouble));
    EMerr_hndlr (!*lpranges, *msg, EMS_E_NoDynamicMemory, ret_end);
 
    OM_BLOCK_MOVE (ME.EMSloop->range, &(*lpranges)[numb*4],
     4 * sizeof (IGRdouble));
    }

  if (lpprops)
    {
    if (*lpprops)
      *lpprops = (IGRushort *)om$realloc (ptr = (char *)*lpprops, 
                  size = (numb + 1) * sizeof (IGRushort));
    else
      *lpprops = (IGRushort *)om$malloc (size = sizeof (IGRushort));
    EMerr_hndlr (!*lpprops, *msg, EMS_E_NoDynamicMemory, ret_end);
 
    (*lpprops)[numb] = ME.EMSloop->lp_props;
    }

  if (lpids)
    {
    if (*lpids)
      *lpids = (GRobjid *) om$realloc (ptr = (char *)*lpids, 
                size = (numb + 1) * sizeof (GRobjid));
    else
      *lpids = (GRobjid *) om$malloc (size = sizeof (GRobjid));
    EMerr_hndlr (!*lpids, *msg, EMS_E_NoDynamicMemory, ret_end);
 
    (*lpids)[numb] = my_id;
    }

  EMmake_chanselect (EMSbd_owner_to_comps, &chan_to_edges);
  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_edges,
             count = &count);
  EMomerr_exit (stat_OM, ret_end);

  loc_options = NULL;
  if (options & EMS_GETB_COMPATIBLEUV)
    loc_options |= EMS_GETB_COMPATIBLEUV;
  if (options & EMS_GETB_COMPATIBLEXYZ)
    loc_options |= (EMS_GETB_COMPATIBLEXYZ | EMS_GETB_CONSISTLFXYZVTX);
  if (options & EMS_GETB_STROKEISO)
    loc_options |= EMS_GETB_STROKEISO;

  reversed = ME.EMSloop->lp_props & EMLP_REVERSED;
  lastinx = count-1;
  for (i=0, j=count-1; i<count; i++, j--)
    {
    relinx = reversed ? j : i;
    stat_OM = om$send (msg = message EMSedge.EMgetstrkpy (&msg_loc, mattyp,
               mat, srfgeom, partolbas, loc_options, &num_xyzpts, &num_uvpts,
               xyzb ? &xyzpts : NULL, uvb ? &uvpts : NULL),
               p_chanselect = &chan_to_edges, from = relinx, to = relinx);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_EdgeError, ret_end);
    if (xyzb && !num_xyzpts || uvb && !num_uvpts)
      continue;

    if (xyzb)
      {
      locnum = i == lastinx ? num_xyzpts : num_xyzpts-1;
      if (xyzb->points)
        ptr3 = (IGRdouble (*)[3])om$realloc (ptr = (char *)xyzb->points,
                size = (xyzb->num_points + locnum) * sizeof (IGRpoint));
      else
        ptr3 = (IGRdouble (*)[3])om$malloc (size = locnum * sizeof (IGRpoint));
      EMerr_hndlr (!ptr3, *msg, EMS_E_NoDynamicMemory, ret_end);
      xyzb->points = (IGRdouble *)ptr3;
      
      OM_BLOCK_MOVE (xyzpts, ptr3[xyzb->num_points],
       locnum * sizeof (IGRpoint));
      xyzb->num_points += locnum;
      }

    if (uvb)
      {
      locnum = i == lastinx ? num_uvpts : num_uvpts-1;
      if (uvb->points)
        ptr2 = (IGRdouble (*)[2])om$realloc (ptr = (char *)uvb->points,
                size = (uvb->num_points + locnum) * 2 * sizeof (IGRdouble));
      else
        ptr2 = (IGRdouble (*)[2])om$malloc (size = locnum * 2 * 
                sizeof (IGRdouble));
      EMerr_hndlr (!ptr2, *msg, EMS_E_NoDynamicMemory, ret_end);
      uvb->points = (IGRdouble *)ptr2;
      
      OM_BLOCK_MOVE (uvpts, ptr2[uvb->num_points],
       locnum * 2 * sizeof (IGRdouble));
      uvb->num_points += locnum;
      }
    }
  if (xyzb)
    {
    ptr3 = (IGRdouble (*)[3])xyzb->points;
    OM_BLOCK_MOVE (ptr3[0], ptr3[xyzb->num_points-1], sizeof (IGRpoint));
    }
  if (uvb)
    {
    ptr2 = (IGRdouble (*)[2])uvb->points;
    OM_BLOCK_MOVE (ptr2[0], ptr2[uvb->num_points-1], 2 * sizeof (IGRdouble));
    }
  (*numbdrys)++;

  if (depth)
    {
    EMmake_chanselect (EMSloop_to_inner, &chan_to_inner);
    count = 0;
    om$get_channel_count (object = me, p_chanselect = &chan_to_inner,
     count = &count);
    if (count)
      {
      for (i=0; i<count; i++)
        {
        is_degen = FALSE;
        if (! (options & EMS_GETB_INCLUDEDEGEN))
          {
          uvtol = partolbas->is_valid ? partolbas->tol : EMS_HIGH_UVLENTOL;
          stat_OM = om$send (msg = message EMSloop.EMgeomattr (&msg_loc, NULL,
                     uvtol, &is_degen, NULL),
                     p_chanselect = &chan_to_inner, from = i, to = i);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError, 
           ret_end);

          if (is_degen && (options & EMS_GETB_INCLUDETOPODEGEN))
            {
            stat_OM = om$send (msg = message EMSloop.EMtopoattr (&msg_loc,
                       NULL, &is_connected, NULL, NULL, NULL), 
                       p_chanselect = &chan_to_inner, from = i, to = i);
            EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError, 
             ret_end);
            if (is_connected)
              is_degen = FALSE;
            }
          }

        if (!is_degen)
          {
          stat_OM = om$send (msg = message EMSloop.EMlpgetbdry (&msg_loc,
                     mattyp, mat,
                     srfgeom, partolbas, options, depth-1,
                     numbdrys, xyzbdrys, uvbdrys, lpranges, lpprops, lpids),
                     p_chanselect = &chan_to_inner, from = i, to = i);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError, 
           ret_end);
          }
        }
      }
    }

ret_end:
  EMWRAPUP(*msg, stat_OM, "EMSloop.EMlpgetbdry")
  return (stat_OM);
}

end implementation EMSloop;
