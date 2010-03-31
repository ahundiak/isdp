class implementation EMSsfcapsf;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT; etc.*/
#include "OMmacros.h"

#define INCREMENT 50


/* HISTORY

  11/14/92  :  AMD  :  Creation

*/


method EMgetInInfo(IGRlong *EMmsg; 
                   struct EMSinlist *inlist; 
                   GRobjid uneval_sender_id; 
                   IGRboolean is_kd_on; 
                   IGRushort options)

{
  IGRlong OM_stat = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;

  /*Get in info for this state.*/

  uneval_sender_id = my_id;

  if (!(options & EMget_in_inf_NO_SURFS))
  {
    /* Get all the surfaces I generated */
    EFgetInGeomInfo(EMmsg, my_id, OM_Gw_current_OS, inlist, 
                    uneval_sender_id, is_kd_on, INCREMENT, NULL); 
    if (!(1 & *EMmsg)) goto wrapup;
  }

wrapup:

  EMWRAPUP(*EMmsg, OM_stat, "EMSsfcapsf.getininf")
  return(OM_stat);

}

end implementation EMSsfcapsf;

