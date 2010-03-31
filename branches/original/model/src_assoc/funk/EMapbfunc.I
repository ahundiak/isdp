/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
/*
  DESCRIPTION

    This file contains all of the functions used to work with the associative
    parameter block

  HISTORY

    SS  :  03/16/91  :  Creation
*/

class implementation EMSapb;

#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "emserr.h"

IGRboolean EMgetapbid (in_os, apb_id, apb_os)
GRspacenum *in_os;
GRobjid *apb_id;
GRspacenum *apb_os;
{
  IGRboolean stat_func;
  IGRlong stat_OM, msg_loc;
  GRobjid mod_id;
  GRspacenum mod_os;

  stat_func = TRUE;

  if (in_os)
    {
    stat_OM = ex$get_modid (mod_osnum = *in_os, mod_id = &mod_id);
    mod_os = *in_os;
    }
  else
    stat_OM = ex$get_cur_mod (id = &mod_id, osnum = &mod_os);
  EMerr_hndlr (EMSerror (stat_OM), stat_func, FALSE, ret_end);

  stat_OM = ex$get_super(mod_id = mod_id, mod_osnum = mod_os,
             super_name = "EMSapb", create = TRUE, super_class = "EMSapb",
             super_id = apb_id, super_osnum = apb_os);
  EMerr_hndlr (EMSerror (stat_OM), stat_func, FALSE, ret_end);

ret_end:
  return (stat_func);
}

end implementation EMSapb;
