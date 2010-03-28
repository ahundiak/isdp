/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRget_number_components

Description
    This method will return the number of objects on the "to_components"
    channel.

    *msg           IGRlong              return code 
    *count         IGRint               the number of objects 

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn      09/15/87          Creation Date
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

extern IGRint	GRget_to_comp_info();

method GRget_number_components (IGRlong *msg; IGRint  *count)
{
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    GRget_to_comp_info( &chansel,
                        OM_Gw_current_OS,
                        my_id,
                        count );
    return ( OM_S_SUCCESS );
}
end implementation GRowner;
