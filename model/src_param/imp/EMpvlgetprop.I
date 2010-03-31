/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRgetprops

Description
    This method returns the properties of the EMSparamvl object.

    *msg           IGRlong              return code 
    *props         IGRshort             object's properties word

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Carlos M. Diaz      7/29/93          Creation Date
\*/

class implementation EMSparamvl;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

extern IGRint   GRget_to_comp_info();

method GRgetprops (IGRlong *msg; IGRshort *props)
{
  IGRlong           om_msg;
  IGRint            i;
  IGRint            count;
  IGRint            locate;
  IGRint            display;
  IGRshort          t;
  OM_S_CHANSELECT   chansel;

  *msg = MSSUCC;

  if ( om_msg = GRget_to_comp_info( &chansel,
      OM_Gw_current_OS,
      my_id,
      &count ) )
  {
    if (count != 0)
    {
      locate = FALSE;
      display = FALSE;

      for (i=0; (i < count) && (! (locate && display)); ++i)
      {
        om_msg = om$send  (msg = message GRgraphics.GRgetprops (msg, &t),
            p_chanselect = &chansel, 
            to = i, 
            from = i);

        if (t & GRIS_LOCATABLE) locate = TRUE;
        if (t & GRIS_DISPLAYABLE) display = TRUE;
      }
    }
    else 
    {
      locate = TRUE;
      display = TRUE;
    }
    *props = me->properties;
    if (locate)
      *props |= GRIS_LOCATABLE;
    else
      *props &= ~GRIS_LOCATABLE;
    if (display)
      *props |= GRIS_DISPLAYABLE;
    else
      *props &= ~GRIS_DISPLAYABLE;
  }

  return (om_msg);
}
end implementation EMSparamvl;
