/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxscompsf;

%safe
#include <math.h>
%endsafe

#include "EMS.h"

/*
  DESCRIPTION

	  This method returns the active and inactive surfaces of
      a composite cross section surface.

  HISTORRY

      RC    11/01/88     Creation Date

*/

method EMget_active_inactive_sfs (IGRlong *EMmsg; 
       GRobjid       **active_sf_ids;
       IGRint        *num_active_sfs;
       IGRint        *active_sf_arrsz;
       GRobjid       **inactive_sf_ids;
       IGRint        *num_inactive_sfs;
       IGRint        *inactive_sf_arrsz)
{
  OM_S_CHANSELECT  to_cmpnt_chan;
  IGRlong          OM_stat, rc;
  OMuint           num_cmpnts;
  IGRint           i;
  GRspacenum       dum_os;
  extern void      EFmemory_allocation();

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*
   * o All of the component surafces are active surfaces.
   */

 OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 OM_stat = om$get_channel_count (object = me,
              p_chanselect = &to_cmpnt_chan, count = &num_cmpnts);
 EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 EFmemory_allocation (&rc, (IGRchar **) active_sf_ids,
                      *num_active_sfs+num_cmpnts, active_sf_arrsz,
                      sizeof(GRobjid), num_cmpnts, 0);
 EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, wrapup);

 for (i = 0; i < num_cmpnts; i++, (*num_active_sfs)++ )
 {
   OM_stat = om$get_objid_at_index (object = me, 
                p_chanselect = &to_cmpnt_chan, index = i, 
                objidaddr = &(*active_sf_ids)[*num_active_sfs],
                osnumaddr = &dum_os);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

 }/* for (i = 0; i < num_cmpnts; i++) */

 wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMScompsurf.EMperform_xsection_update");

  return (OM_stat);

}
end implementation EMSxscompsf;
