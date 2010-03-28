class implementation GRgraphics;

#include "msdef.h"

/*
NAME
   GRgraphics.GRadd_to_display_list

DESCRIPTION
   This is the GRgraphics implementatio of the GRadd_to_display_list
   message.  It does nothing and returns an error.  It's purpose is
   to provide an implementation of this method for all objects that
   are not known to the display list.

HISTORY
   06/29/93 S.P. Rogers
      Creation Date
*/

method GRadd_to_display_list( IGRlong *msg; IGRboolean is_hidden_line )
{
   *msg = MSFAIL;
   return( OM_E_ERROR );
}

end implementation GRgraphics;


