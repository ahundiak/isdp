/*
  
    Override message declared in GRowner

*/

class implementation ASnode;
#include "grownerdef.h"
#include "asbox.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#define AS_DEBUG

from GRmodule import GRmdaddwrng, GRmdremove;

method GRget_channel_type(IGRlong *msg; IGRint *type; IGRint *conn_type)
{
 *msg = MSSUCC;
 *type = GR_FLEXIBLE;
 *conn_type = GR_NO_OVERRIDE;   /* A VOIR */
 return(OM_S_SUCCESS);
}

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
 *msg = MSSUCC;
 *properties = GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
               GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
               GR_LC_RIGID;
    
 
 return(OM_S_SUCCESS);
}

method GRdrop(IGRlong *msg;struct  GRmd_env *md_env)
 {
  struct GRid src;
  IGRlong status;
  status = om$send(msg = message NDnode.NDmove_to_root(msg,&src,md_env),
		   targetid = my_id);
  as$status();
  return(status);
 }

end implementation ASnode;
