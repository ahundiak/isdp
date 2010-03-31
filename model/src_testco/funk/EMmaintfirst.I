class implementation GRcompcurve;

#include "EMS.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ma.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"

IGRlong EMmaintain_first_component(msg, env, comp_curve, first_obj)

IGRlong    *msg;
struct GRmd_env   *env;
struct GRid       comp_curve;
struct GRid       first_obj;

/*
Abstract
    Check to see if it is closed.  If closed, then make the start curve
    the same as the first one the user identified.

Arguments
     *msg    IGRlong          completion code
     *env    struct GRmd_env  composite's module env
     comp_curve  struct GRid  composte's objid and osnum;
     first_obj   struct GRid  first object's objid and osnum;

Return Values
   - MSSUCC if successful.
   - MSFAIL (severe) if other error.
   - EMS_I_Open  if the composite if open and not closed.

Files
	EMmaintfirst.I

History
	dhm		7/20/88		Creation date.

*/

{

  IGRlong      msg_loc, status, owner_inx;
  OMuint       inx;
  IGRint       i;
  struct GRprops  props;
  struct GRid     tempobj;
  OM_S_CHANSELECT to_components;

  /*
   * Initialize
   */

  *msg = MSSUCC;
  status = OM_S_SUCCESS;

  /*
   * Make the chanselect to use in the processing.
   */

  status = EMmake_chanselect(GRcmpowner_to_components, &to_components);
  EMomerr_hndlr(status, wrapup, "EMmake_chanselect\n");

  /*
   * Get the props to test for closed.
   */

  status = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                         &env->md_env.matrix_type, env->md_env.matrix,
                         &props),
                   senderid = NULL_OBJID,
                   targetid = comp_curve.objid,
                   targetos = comp_curve.osnum);
  EMomerr_hndlr(status, wrapup, "EMmaintfirst : GRgeomprops\n");
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, wrapup);

  if (props.phy_closed)
  {
    status = om$get_index(osnum_c = comp_curve.osnum,
                          objid_c = comp_curve.objid,
                          p_chanselect = &to_components,
                          objid = first_obj.objid,
                          osnum2 = first_obj.osnum,
                          indexaddr = &inx);
    EMomerr_hndlr(status, wrapup, "om$get_index error\n");

    if (inx != 0)
    {
      status = om$get_objid_at_index(objid = comp_curve.objid,
                                     osnum = comp_curve.osnum,
                                     p_chanselect = &to_components,
                                     index = 0,
                                     objidaddr = &tempobj.objid,
                                     osnumaddr = &tempobj.osnum);
      EMomerr_hndlr(status, wrapup, "om$get_objid_at_index\n");

      for (i = 0; i < inx; i++)
      {
        status = om$send(msg = message GRconnector.GRdisconn(&msg_loc,
                               &comp_curve),
                         senderid = NULL_OBJID,
                         targetid = tempobj.objid,
                         targetos = tempobj.osnum);
        EMomerr_hndlr(status, wrapup, "GRdisconn error\n");

        owner_inx = OM_K_MAXINT;
        status = om$send(msg = message GRconnector.GRrigidconn(
                               msg, &comp_curve, &owner_inx),
                         senderid = NULL_OBJID,
                         targetid = tempobj.objid,
                         targetos = tempobj.osnum);
        EMomerr_hndlr(status, wrapup, "GRrigidconn error\n");

        status = om$get_objid_at_index(objid = comp_curve.objid,
                                       osnum = comp_curve.osnum,
                                       p_chanselect = &to_components,
                                       index = 0,
                                       objidaddr = &tempobj.objid,
                                       osnumaddr = &tempobj.osnum);
        EMomerr_hndlr(status, wrapup, "om$get_objid_at_index error\n");

      }  /* end for loop */

    }  /* if inx != 0 */

  }  /* end if closed */
  else
    *msg = EMS_I_Open;


wrapup:
  return(status);
}

end implementation GRcompcurve;
