/* ###################   APOGEE COMPILED   ################## */
class implementation SKifimplicit;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 OM_S_CHANSELECT  to_mem_cnstrs;
 IGRlong   OM_stat;

 *msg = MSSUCC;
 OM_stat = OM_S_SUCCESS;

 OM_stat = om$make_chanselect (channame = "SKinterface.to_member_constrs",
                               p_chanselect = &to_mem_cnstrs);
 EMerr_hndlr (!(1&OM_stat), *msg, MSFAIL, wrapup);

 OM_stat = om$send (msg = message GRgraphics.GRgetobjinfo (msg, info),
                     p_chanselect = &to_mem_cnstrs, from = NULL, to = NULL);
 EMerr_hndlr (!(1&OM_stat&*msg), *msg, MSFAIL, wrapup);

 wrapup:

 EMWRAPUP (*msg, OM_stat, "SKifimplicit.GRgetobjinfo");

 return(OM_stat);
}

end implementation SKifimplicit;


