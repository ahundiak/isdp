/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRput_drawsheet_description

Description
    This method puts a description into the drawing sheet.

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

method GRput_drawsheet_description (IGRlong *msg; IGRchar *desc)
{
    om$vla_set_dimension(varray = me->desc, size = strlen(desc) + 1);
 
    strcpy (me->desc, desc);
 
    return (OM_S_SUCCESS);
}
end implementation GRdsborder;
