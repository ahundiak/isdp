/*
Name
    unknown
    
Description
    This method will send the unknown message to the graphics object or
    if the unknown message was from the graphics object to the owners
    of this object.

Return Values
    The OM return code will be set in the graphics object.
*/

class implementation GRowner;

#include "grimport.h"
#include "igrtypedef.h"
#include "OMerrordef.h"
#include "msdef.h"

extern int   GRget_to_comp_chansel ();
extern int   GRget_to_owner_chansel ();

method unknown ( OM_p_MESSAGE msg )
{
  long            om_msg = OM_W_UNKNOWN_MSG;
  OM_S_CHANSELECT chansel, owner_chansel;

  if (GRget_to_comp_chansel ( &chansel ) && GRget_to_owner_chansel( &owner_chansel ))
  {
    /*
     *  Is the unknown message from the graphics object?
     *  Assumes the chanselect is by number!
     */
    if (!memcmp ( (char *)&chansel.u_sel.number, (char *)&in_channel,
            sizeof ( OM_S_CHANNUM )))
    {
      if (me->to_owners)
      {
        /* 
         *  Send the unknown message to my owners.
         */
        om_msg = om$send ( msg = msg, p_chanselect = &owner_chansel );
      }
    }
    else 
    {
      /*
       * Send the unknown message to the graphics object.
       */
      if (me->to_components)
      {
        om_msg = om$send ( msg = msg, p_chanselect = &chansel );
      }
    }
  }

  return om_msg;
}

end implementation GRowner;
