class implementation EMSsfdpr;

/* 
History

 Ashok	19-Jan-93	Forced to do composite surface offset.
*/

#include "msdef.h"

#define FIRST 0

method EMoffset (IGRlong *msg; IGRushort options;
                 IGRshort *mattyp; IGRmatrix mat;
                 struct GRvg_construct *const_args;
                 IGRboolean offset_inward;
                 IGRdouble thickness;
                 IGRint num_spec_thick;
                 IGRdouble *val_spec_thick;
                 struct GRobjid_set *spec_thick_sf_sets;
                 IGRint num_nooffsetsfs; GRobjid *nooffsetsfs;
                 IGRchar status_str[];
                 GRobjid *offsetobj;
                 struct EMSerror_help *errkey_list)
{

#ifdef USE_SMART_OFFSET

  OM_S_CHANSELECT chan_to_comps;

  /*
   * Obtain the offset objects of the first operand only and return that.
   */
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  return (om$send (msg = message EMSsurface.EMoffset (msg, options,
           mattyp, mat, const_args, offset_inward, thickness,
           num_spec_thick, val_spec_thick, spec_thick_sf_sets,
           num_nooffsetsfs, nooffsetsfs, status_str, offsetobj,
	   errkey_list),
           p_chanselect = &chan_to_comps, from = FIRST, to = FIRST));

#endif

  return (om$send (msg = message EMScompsurf.EMoffset (msg, options,
           mattyp, mat, const_args, offset_inward, thickness,
           num_spec_thick, val_spec_thick, spec_thick_sf_sets,
           num_nooffsetsfs, nooffsetsfs, status_str, offsetobj,
	   errkey_list),
           mode = OM_e_wrt_message, targetid = my_id));
}

end implementation EMSsfdpr;
