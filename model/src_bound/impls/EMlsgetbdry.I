/*
  DESCRIPTION

    This method returns the loopset in the form of an array of closed
    polylines (the start and the stop points are repeated). Each of
    the loops has been packaged as linestring. This geometry is available in
    xyz and/or uv. In addition, the loops' stored uv-range, it's properties 
    and it's object-id may be obtained (whenever the corresponding argument is
    non-NULL).

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

  HISTORY

    SS  :  06/14/90  :  Creation. Initial stuff from EMlspack
*/

class implementation EMSloopset;

#include "EMS.h"
#include <stdio.h>
#include "EMSmsgdef.h"
#include "emsmacros.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from EMSloop import EMlpgetbdry, EMgeomattr, EMtopoattr;

method EMlsgetbdry (IGRlong *msg;
                    IGRshort *mattyp; IGRmatrix mat;
                    struct IGRbsp_surface *srfgeom;
                    struct EMSpartolbasis *partolbas;
                    IGRushort options;
                    IGRint *numbdrys;
                    struct IGRpolyline **xyzbdrys, **uvbdrys;
                    IGRdouble **lpranges; IGRushort **lpprops;
                    GRobjid **lpids)
{
  IGRboolean srf_alloced, is_degen, is_connected;
  IGRint i;
  OMuint srfexists, count;
  IGRlong msg_loc, stat_OM;
  struct GRid srfid;
  OM_S_CHANSELECT chan_to_loops, chan_to_srf;
  OM_S_OBJECT_LINKAGE objlink;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  srf_alloced = FALSE;

  *numbdrys = 0;
  if (xyzbdrys)
    *xyzbdrys = NULL;
  if (uvbdrys)
    *uvbdrys = NULL;
  if (lpranges)
    *lpranges = NULL;
  if (lpprops)
    *lpprops = NULL;
  if (lpids)
    *lpids = NULL;

  if (!srfgeom)
    {
    EMmake_chanselect (EMSloopset_to_surface, &chan_to_srf);
    stat_OM = om$get_channel_objects (object = me, p_chanselect = &chan_to_srf,
               size = 1, count = &srfexists, list = &objlink);
    EMerr_hndlr (!srfexists || EMSerror (stat_OM), *msg, EMS_E_InvalidCase,
     ret_end);
    srfid.objid = objlink.S_objid;
    srfid.osnum = OM_Gw_current_OS;

    stat_OM = EMgetvggeom (&msg_loc, mattyp, mat, &srfid, &srfgeom, NULL);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    srf_alloced = TRUE;
    }

  if (!partolbas->is_valid)
    {
    stat_OM = EFsspbtol_by_geom (&msg_loc, srfgeom, partolbas);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }


  EMmake_chanselect (EMSloopset_to_loops, &chan_to_loops);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_loops,
   count = &count);
  if (count)
    {
    for (i=0; i<count; i++)
      {
      is_degen = FALSE;
      if (! (options & EMS_GETB_INCLUDEDEGEN))
        {
        stat_OM = om$send (msg = message EMSloop.EMgeomattr (&msg_loc, NULL,
                   partolbas->tol, &is_degen, NULL),
                   p_chanselect = &chan_to_loops, from = i, to = i);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError, 
         ret_end);

        if (is_degen && (options & EMS_GETB_INCLUDETOPODEGEN))
          {
          stat_OM = om$send (msg = message EMSloop.EMtopoattr (&msg_loc,
                     NULL, &is_connected, NULL, NULL, NULL), 
                     p_chanselect = &chan_to_loops, from = i, to = i);
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
                   srfgeom, partolbas, options, MAXINT,
                   numbdrys, xyzbdrys, uvbdrys, lpranges, lpprops, lpids),
                   p_chanselect = &chan_to_loops, from = i, to = i);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_LoopError, 
         ret_end);
        }
      }
    }

ret_end:
  if (srfgeom && srf_alloced)
    om$dealloc (ptr = srfgeom);

  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMlsgetbdry")
  return (stat_OM);
}

end implementation EMSloopset;
