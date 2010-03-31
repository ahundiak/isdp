/*
  ALGORITHM

    This implementation makes use of special knowledge of the way this
    composite surface got created (SSI-table) to implement the option -
    EMS_O_Increment more efficiently. It scans only those surfaces that
    have been modified by this node for slivers and ignores the rest.
    When this particular option is not set, it reverts to the default
    implementation.
*/
    
class implementation EMSsfboolean;

#include "EMSssi.h"

method EMchksliver (IGRlong *msg; IGRushort options;
                    IGRshort *mattyp; IGRmatrix mat;
                    IGRdouble xyztol;
                    IGRint num_samplepts_edge;
                    IGRint *num_slivers;
                    GRobjid (**sliver_edges)[2])
{
  IGRint i, num_sfsmod;
  IGRlong msg_loc, stat_OM;
  GRobjid *sfsmod;
  struct EMSboolssi_table *bool_info;
  union EMSssi_table *ssi;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ssi = NULL;

  if (options & EMS_O_Incremental)
    {  
    om$send (msg = message EMSdpr.EMgetSSI (&msg_loc, &ssi),
     targetid = my_id);
    EMerr_hndlr (!ssi, *msg, EMS_E_Fail, ret_end);  

    bool_info = &ssi->bool_info;
    num_sfsmod = bool_info->num_surfaces;
    sfsmod = bool_info->surface_ids;
    for (i=0; i<num_sfsmod; i++)
      om$send (msg = message EMSsurface.EMchksliver (&msg_loc, options,
       mattyp, mat, xyztol, num_samplepts_edge, num_slivers, sliver_edges),
       targetid = sfsmod[i]);
    }
  else
    {
    stat_OM = om$send (mode = OM_e_wrt_parent, 
               msg = message EMSsfboolean.EMchksliver (&msg_loc, options, 
               mattyp, mat, xyztol, num_samplepts_edge, 
               num_slivers, sliver_edges), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  if (ssi)
    om$dealloc (ptr = ssi);

  EMWRAPUP (*msg, stat_OM, "sfb.chkslvr");
  return (stat_OM);
}

end implementation EMSsfboolean;
