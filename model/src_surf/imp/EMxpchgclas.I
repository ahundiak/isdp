/* ###################   APOGEE COMPILED   ################## */
class implementation EMSxsplane;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "EMSprop.h"
# include "EMSopt.h"
# include "gocmacros.h"
# include "EMSobjmgrdef.h"
# include "EMSobjmgr.h"

/*
 DESCRIPTION
   This method changes the class of this object from EMSxsplane to
   EMSplane.
 
 HISTORY     

        RC     12/09/88      Creation Date
        NP     08/26/92      Modified for ANSI compliance.

*/

extern OMuword OPP_EMSplane_class_id;

method EMchange_class (
       IGRlong           *EMmsg;
       struct  GRmd_env  *md_env;
       GRobjid           *newobjid)

{
  OM_S_CHANSELECT       to_owners_chan, notification_chan, sf_ls_chan,
                        sf_gd_chan;
  struct IGRbsp_surface *my_gm;
  struct GRsymbology    symb;
  struct IGResbs        esbs;
  struct GRvg_construct arglist;
  IGRlong               OM_stat, mthd_stat;
  IGRchar               *cache_ptr = NULL;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  OM_stat = EMmake_chanselect (GRconnector_to_owners, &to_owners_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = EMmake_chanselect (GRnotify_notification, &notification_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = EMmake_chanselect (EMSrequester_to_helpers, &sf_gd_chan);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send(msg = message GRvg.GRgetsymb(&mthd_stat, &symb),
                    targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  arglist.level = symb.level;
  arglist.properties = ME.GRgraphics->properties;
  arglist.name = 0;
  arglist.display = &(symb.display_attr);

  OM_stat = om$send(msg = message GRvg.GRgetattr (&mthd_stat, 
                     (IGRchar *) &esbs),
                    targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  arglist.class_attr = (IGRchar *) &esbs;
  arglist.newflag = FALSE;
  arglist.msg = &mthd_stat;
  arglist.env_info = md_env;

  GRgetabsg (&mthd_stat, &md_env->md_env.matrix_type, 
             md_env->md_env.matrix, (IGRchar **) &cache_ptr, i);
  EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

  my_gm = (struct IGRbsp_surface *) cache_ptr;
  arglist.geometry = (IGRchar *)my_gm;

  OM_stat = om$construct(classid = OPP_EMSplane_class_id,
                         msg = message GRgraphics.GRconstruct(&arglist),
                         p_objid = newobjid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * Move channels
   */

  OM_stat = om$send (msg = message Root.move_chan( to_owners_chan, 
                      my_id, OM_Gw_current_OS, to_owners_chan),
                     targetid = *newobjid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = message Root.move_chan (notification_chan,
                      my_id, OM_Gw_current_OS, notification_chan),
                     targetid = *newobjid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = message Root.move_chan (sf_ls_chan, my_id,
                      OM_Gw_current_OS, sf_ls_chan),
                     targetid = *newobjid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  OM_stat = om$send (msg = message Root.move_chan (sf_gd_chan, my_id,
                      OM_Gw_current_OS, sf_gd_chan),
                     targetid = *newobjid);
  EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

  /*
   * Turn off my GR_RIGID_RELATIONSHIP property as it may 
   * create problems.
   */

  ME.GRgraphics->properties &= ~GR_RIGID_RELATIONSHIP;

  OM_stat = om$send(mode = OM_e_wrt_parent,
                    msg = message EMSxsplane.GRdelete(&mthd_stat, md_env),
                    targetid = my_id);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

  wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMSxsplane.EMchange_class");
   if (cache_ptr) GRabsg_del(cache_ptr);
   return (OM_stat);
}

end implementation EMSxsplane;
