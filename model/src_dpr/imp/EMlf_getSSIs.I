/* ###################   APOGEE COMPILED   ################## */
class implementation EMSlift;

#include "EMS.h"
#include "EMSmsgdef.h"
#include "OMmacros.h"

/*
   History
               RC     11/01/87      Creation Date
               RC     03/14/88      Rewrote for 1.2.0
               RC     05/24/88      Added code for single sf lift.
*/

method EMgetSSIsize(IGRlong *EMmsg; union EMSssiSizeData *size)
{
  IGRlong                   OM_stat;
  IGRint                    i, in_out_idx, dim = 0;
  struct EMSlftssi_size  *my_size;

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  my_size = &size->lft_info;
  
  in_out_idx = 0;

  dim = om$dimension_of(varray = me->in_out);

  my_size->num_composites = dim ? (IGRint) me->in_out[in_out_idx++] : 0;

  my_size->num_surfaces_out = 0;
  for (i = 0; i < my_size->num_composites; i++, in_out_idx++)
    my_size->num_surfaces_out += (IGRint) me->in_out[in_out_idx];

  in_out_idx += my_size->num_surfaces_out;
  my_size->num_sf_lifted = dim ? (IGRint) me->in_out[in_out_idx++] : 0;
  my_size->num_sf_affected = dim ? (IGRint) me->in_out[in_out_idx++] : 0;

  my_size->num_regions_in = 0;
  for (i = 0; i < my_size->num_sf_affected; i++, in_out_idx++)
    my_size->num_regions_in += (IGRint) me->in_out[in_out_idx];

  my_size->num_regions_out = 0;
  for (i = 0; i < my_size->num_sf_affected; i++, in_out_idx++)
    my_size->num_regions_out += (IGRint) me->in_out[in_out_idx];

  my_size->num_eds_rplcd = dim ? (IGRint) me->in_out[in_out_idx++] : 0;
  
  my_size->num_eds_in = 0;
  for (i = 0; i < my_size->num_eds_rplcd; i++, in_out_idx++)
    my_size->num_eds_in += (IGRint) me->in_out[in_out_idx];

  my_size->num_eds_wcm_md = dim ? (IGRint) me->in_out[in_out_idx++] : 0;

  my_size->num_ed_wmv_cm = dim ? (IGRint) me->in_out[in_out_idx++] : 0;
  
  my_size->num_eds_wcm_eds = dim ? (IGRint) me->in_out[in_out_idx] : 0;

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "EMSlift.EMgetSSIsize");
  return(OM_S_SUCCESS);
}

end implementation EMSlift;
