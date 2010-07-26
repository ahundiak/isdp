/*
  ACmacro_hdri.I
  robert patience
  21_jul_86
*/
class implementation ACmacro_hdr;

#include "ASmacroi.h"

#include "macro.h"

#define AS_DEBUG

from ACcpx_defn import ACintpt_foot; 

/* ========================================================================= */

method ACdrop(struct GRmd_env *md_env)
{
  int			status;

  status = om$send( mode = OM_e_wrt_message,  
		    msg = message NDnode.NDdelete(md_env),
		    targetid = my_id );
  as$status(action = RET_STATUS );
  return ( OM_S_SUCCESS );
}

end implementation ACmacro_hdr;
