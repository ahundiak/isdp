/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI   COMPILED   ################## */
class implementation EMSdpr;

#include "emsdef.h"     
#include "EMSdpr.h"
#include "EMSopt.h"
#include "OMmacros.h"

#if DEBUG
#include "stdio.h"
#endif


IGRlong EFwork_the_display(EMmsg, dis_options, objid, display_ids,
                           display_count, dont_have_it)
IGRlong           *EMmsg;
IGRushort dis_options;
GRobjid           objid;
GRobjid           **display_ids;
IGRint            *display_count;
IGRboolean        *dont_have_it;
{
  IGRlong OM_stat=OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if (dont_have_it) *dont_have_it = FALSE;

  if (dis_options & EMS_DO_DISPLAY)
  {
    IGRint ii;

    if (dis_options & EMS_DONT_REDRAW)
    {
      if (dont_have_it)
      {
        /*See if this surf is already in the list.*/
        for(ii=0; ii<*display_count; ii++)
        {
          if ((*display_ids)[ii] == objid)  break;
        }         
      }
      else ii = *display_count;
         
      if (ii == *display_count)
      {
        /*Dont already have this one.*/
        EFrealloc_if_needed(EMmsg, display_ids, *display_count,
                            DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
        if (!(1&*EMmsg)) goto wrapup;
    
        (*display_ids)[*display_count] = objid;
        (*display_count)++;
       
        if (dont_have_it) *dont_have_it = TRUE;
      }
    }
    else if (dont_have_it) *dont_have_it = TRUE;
  }
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFwork_the_display")
  return(OM_stat);
}
end implementation EMSdpr;
