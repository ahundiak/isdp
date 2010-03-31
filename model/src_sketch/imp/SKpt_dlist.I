class implementation SKpoint;

#include "msdef.h"
#include "DPdlist.h"

/*
NAME
   SKpoint.GRadd_to_display_list

DESCRIPTION
   This is the SKpoint implementation of the GRadd_to_display_list
   message.  It adds a place-holder for SKpoint in the display 
   list so we can handle the hiliting behavior of its parent
   circle/arc.


HISTORY
   07/22/93 Shridar Subramanian
      Creation Date
*/

method GRadd_to_display_list( IGRlong *msg; IGRboolean is_hidden_line )
{
   int sts;
   unsigned int ele_flags = DP_DLIST_ELE_DISPLAYABLE;

   sts = DPdlist_add_skpoint( my_id, OM_Gw_current_OS,
                              ele_flags, 1, 0, 1, me->level );

   if ( 1 & sts )
   {
      *msg = MSSUCC;
      return( OM_S_SUCCESS );
   }
   else
   {
      *msg = MSFAIL;
      return( OM_E_ERROR );
   }

}

end implementation SKpoint;


