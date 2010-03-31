class implementation EMScompsurf;

# include <stdio.h>
# include "igrtypedef.h"
# include "igr.h"
# include "gocmacros.h"
# include "OMmacros.h"
# include "msdef.h"

# include "emsdef.h"
# include "emserr.h"

method GRaddwrng (IGRlong *msg; struct GRmd_env *md_info)
{
  OM_S_CHANNUM   channum;
  OM_S_CHANSELECT to_components;
  IGRboolean passdown = TRUE;
  IGRlong status = OM_S_SUCCESS;
  IGRboolean active_state, active_path;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;

  status = om$get_channel_number (channame = "GRconnector.to_owners",
                                  p_channum = &channum);
  EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);

  if (channum.classid == in_channel.classid &&
      channum.number == in_channel.number)
   passdown = TRUE;
  else
  if (sender_id == my_id)
   passdown = TRUE;
  else /* See if I am active. If so send on down */
  {
   status = om$send (msg = message EMSsurface.EMisactive( msg, &active_state,
                           &active_path),
            targetid = my_id);
   EMerr_hndlr(!(1&status&*msg), *msg, MSFAIL, wrapup);

   if (active_state) passdown = TRUE;
   else
    passdown = FALSE;
  }
  
  if (passdown)
  {
   to_components.type 	   = OM_e_addr;
   to_components.u_sel.addr = &ME.GRcmpowner->to_components;

   status = om$send( msg = OPPmargs,
                     p_chanselect = &to_components,
                     from = NULL,
                     to   = GRDGNLIMITS_MAX_I);
  }

wrapup:
  return(status);
}
end implementation EMScompsurf;

