/* ###################   APOGEE COMPILED   ################## */
class implementation EMScone;

# include "EMS.h"
# include "msdef.h"         /* MS message codes */
# include "EMSssprops.h"

method GRxform(IGRlong *EMmsg; struct GRmd_env *obj_dsenv; 
               IGRshort *mx_type; IGRmatrix mx; GRobjid *newobjid)
/*
Abstract

    This method transforms a cone.

Arguments

    obj_dsenv - input
        The module environment information.

    mx_type, mx - input
        The matrix (and type) to be applied to the geometry.

    newobjid - output
        The object id after transforming.

History

    31 Mar 88   AIC     Creation Date.
*/
{
  IGRlong   sts = OM_S_SUCCESS;

  /*
   * Initialize.
   */
  *EMmsg = MSSUCC;

  switch(me^^EMSsubbs.ss_props & EMSformat)
  {
    case EMSbsplineFormat:
      sts = om$send(msg = message EMSsubbs.GRxform(EMmsg, obj_dsenv,
                    mx_type, mx, newobjid), mode = OM_e_wrt_message,
                    targetid = my_id);
      break;

    case EMSprojectedFormat:
      sts = om$send(msg = message EMSproject.GRxform(EMmsg, obj_dsenv,
                    mx_type, mx, newobjid), mode = OM_e_wrt_message,
                    targetid = my_id);
      break;

    case EMSrevolvedFormat:
      sts = om$send(msg = message EMSrevol.GRxform(EMmsg, obj_dsenv,
                    mx_type, mx, newobjid), mode = OM_e_wrt_message,
                    targetid = my_id);
      break;

    default:
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMScone.GRxform")
  return (OM_S_SUCCESS);
}

end implementation EMScone;
