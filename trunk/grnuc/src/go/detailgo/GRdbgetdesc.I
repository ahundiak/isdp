/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRget_drawsheet_description

Description
    This method returns the description of the drawing sheet.

Arguments
    *msg           IGRlong           return code
    *desc          IGRchar           description string

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/
class implementation GRdsborder;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"

method GRget_drawsheet_description (IGRlong *msg; IGRchar *desc)
{

   *msg = MSSUCC;

   if (om$dimension_of(varray = me->desc)) strcpy(desc, me->desc);

   return(OM_S_SUCCESS);
}
end implementation GRdsborder;
