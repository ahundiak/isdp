/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "EMSdpr.h"

method EMgettreepath(IGRlong *EMmsg; GRobjid **pathlist; 
                     IGRint *pathlist_count; IGRboolean unused)
/*
Description
   This method will return the tree path from the lowermost tree node
   (primitive) to the active dpr state.

Return Values
   EMS_S_Success if all is well

Notes
   The sender of this method MUST set pathlist = NULL and pathlist_count = 0

History
   DLB 03/25/88  Creation
   DLB 05/02/88  Addition of code to get inactive tree path.
   DLB 06/11/89  Total rewrite.  Override at specific classes.
*/

{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT to_owners;  


  EMmake_chanselect(GRconnector_to_owners, &to_owners);

  /*Send on up.*/
  *EMmsg = EMS_I_NoResponse;
  OM_stat = om$send(msg = OPPmargs, p_chanselect = &to_owners);
  if (!(1 & OM_stat & *EMmsg) && (OM_stat != OM_W_UNKNOWN_MSG)) goto wrapup;

  OM_stat = OM_S_SUCCESS;
  if (*EMmsg == EMS_I_NoResponse)
  {
    /*Since no owner responded to this message, I must add myself.*/
    EFrealloc_if_needed(EMmsg, pathlist, *pathlist_count, TREE_PATH_BUFF_INCR,
                        sizeof(GRobjid)); 
    if (!(1 & *EMmsg)) goto wrapup;

    (*pathlist)[*pathlist_count] = my_id;
    (*pathlist_count)++;
  }

  wrapup:
   EMWRAPUP(*EMmsg, OM_stat, "EMSsurf.EMgettreepath")
   return(OM_stat);
}
end implementation EMSsurface;
