/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmacro;

#include "EMS.h"
#include "EMSdpr.h"
#include <stdio.h>


method EMgettreepath(IGRlong *EMmsg; GRobjid **pathlist; 
                     IGRint *pathlist_count; IGRboolean unused)
/*
Description
   This method will return the tree path from the lowermost tree node
   (primitive) to the active dpr state.

Return Values
   EMS_S_Success    if all is well

Notes
   The initial sender of this method MUST set pathlist = NULL and
   pathlist_count = 0 

History
   pp 05/25/90  Creation
*/
{
  IGRlong               OM_stat=OM_S_SUCCESS;
  union EMSssi_table    *ssi;
  IGRboolean            add_sender=TRUE;


  *EMmsg = EMS_S_Success;    

   (*pathlist_count) = (*pathlist_count) - ME.EMSsfmacro->num_states + 1;
   if (*pathlist_count < 0) 
   {
    *pathlist_count = 0;
   }

  /*Get the rest of the path.*/

  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsurface.EMgettreepath(EMmsg,
                          pathlist, pathlist_count, unused),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfmacro.EMgettreepath")
    return(OM_stat);
}
end implementation EMSsfmacro;
