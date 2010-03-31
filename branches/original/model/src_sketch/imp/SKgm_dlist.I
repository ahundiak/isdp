class implementation SKgmhndlpt;

#include "msdef.h"

/*
NAME
   SKgmhndlpt.GRadd_to_display_list

DESCRIPTION
   This is the SKgmhndlpt implementation of the GRadd_to_display_list
   message.  It does nothing and returns an error.  It's purpose is
   to avoid SKgmhndlpt being added to the display list.

HISTORY
   07/22/93 Shridar Subramanian
      Creation Date
*/

method GRadd_to_display_list( IGRlong *msg; IGRboolean is_hidden_line )
{
   *msg = MSFAIL;
   return( OM_E_ERROR );
}

end implementation SKgmhndlpt;


