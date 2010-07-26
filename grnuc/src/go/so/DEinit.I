class implementation DEso;

#include <stdio.h>
#include <memory.h>
#include <sys/types.h>
#include <tools.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "exmacros.h"
#include "gr.h"
#include "godef.h"
#include "DEso.h"
#include "DEsomacros.h"
#include "DEglob.h"


DEget_soo ( p_objid, p_osnum, osnum )
            OM_S_OBJID    *p_objid /* objid of the soo              OUT */;
            GRspacenum *p_osnum /* osnum of the soo                 OUT */;
            GRspacenum osnum     /* osnum the soo is relative to    IN  */;
/*
   This function returns the soo of an object space.
*/
{
  GRspacenum oosnum;
  IGRlong msg;
  *p_objid = NULL_OBJID;
  ex$get_cur_mod ( osnum = &oosnum );
  if (p_osnum) *p_osnum = oosnum;
  if (DEsos)
  {
      /* the soos are in the module */
    *p_objid = DEsos [osnum];

  }
  else *p_objid = NULL_OBJID;
  
  return OM_S_SUCCESS;
}


_DEinit ()
/*
   Misc. initialization for so.
*/
{
  int i;

  if (DEsos)
    /* we've already been initialized */
    return OM_S_SUCCESS;

  /* make the chanel selectors */
  IGEgragad_winsup_chanselect.type = OM_e_num;
  om$get_channel_number ( channame = "IGEgragad.winsup",
                          p_channum = &IGEgragad_winsup_chanselect.u_sel.number );
  DEso_to_windows_chanselect.type = OM_e_num;
  om$get_channel_number ( channame = "DEso.to_windows",
                          p_channum = &DEso_to_windows_chanselect.u_sel.number ); 
  DEso_to_contexts_chanselect.type = OM_e_num;
  om$get_channel_number ( channame = "DEso.to_contexts",
                          p_channum = &DEso_to_contexts_chanselect.u_sel.number ); 
  GRcontext_to_misc_chanselect.type = OM_e_num;
  om$get_channel_number ( channame = "GRcontext.to_misc",
                          p_channum = &GRcontext_to_misc_chanselect.u_sel.number ); 
  
  DEsos = (OM_S_OBJID *)malloc ( OM_Gw_maxOS * sizeof ( OM_S_OBJID ) );
  if (!DEsos)
    return OM_E_NODYNMEM;

  for (i = 0; (OMuword)i < OM_Gw_maxOS; i++)
    DEsos [i] = NULL_OBJID;
  
  for (i = 0; i < MAX_WINDOW; i++)
    DElocked_views [i] = NULL_OBJID;
    
  return OM_S_SUCCESS;
}

end implementation DEso;
