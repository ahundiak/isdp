/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRget_components

Description
    This method is used to retreive all components.

    *msg           IGRlong              return code 
    *mod_env       struct GRmd_env      The current module environment
    *objects[]     struct GRid          The list of objects.
    number_objects IGRint               The maximum number of objects that
                                        the objects list can contain.
    *count         IGRint               The number of objects returned.
    from_obj      IGRint                The base index
    to_obj        IGRint                The high index

Return Values
    MSSUCC   -  if successful.
    MSFAIL   -  if failure.

History
    Gray Winn       09/15/87    Creation Date
    jay wallingford 04/29/89    Optimized the making of the chansel
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"

extern IGRint   GRget_to_comp_info();

method GRget_components (IGRlong *msg; 
                         struct GRmd_env *mod_env;
                         struct GRid objects[]; 
                         IGRint number_objects;
                         IGRint *count; 
                         IGRint from_obj; 
                         IGRint to_obj)
{
    IGRlong           om_msg;
    IGRint            i, j;
    IGRint            count1;
    OM_S_CHANSELECT   chansel;
    IGRint            buffer_size;
    IGRchar           *buffer;
    IGRint            current_number_objects;

    *msg = MSSUCC;
    *count = 0;
    buffer = (IGRchar *)NULL;
    current_number_objects = number_objects;

    om_msg = GRget_to_comp_info( & chansel,
                                 OM_Gw_current_OS,
                                 my_id,
                                 &count1 );
    count1--;

    /* 
     *  Validation 
     */
    if ( (from_obj > count1) || (from_obj < 0) ||
         (to_obj < 0) || (!number_objects) )
    {
        *count = 0;
        *msg = MSFAIL;
    }
    else 
    {
        if (to_obj >= count1) to_obj = count1;

        buffer_size = sizeof(OM_S_OBJECT_LINKAGE) * (count1 + 1);

        if (buffer = om$malloc (size = buffer_size) ) 
        {
            om_msg = om$get_channel_objects (object = me, 
                                             p_chanselect = &chansel, 
                                             list = (OM_S_OBJECT_LINKAGE *)buffer, 
                                             size = buffer_size, 
                                             count = (OMuint *)&count1);
            current_number_objects--;
            for (i = from_obj, j = 0; (i <= to_obj) && 
                (current_number_objects >= 0); ++i, ++j)
            {
                objects[j].objid = ((OM_S_OBJECT_LINKAGE *)buffer)[i].S_objid;
                objects[j].osnum = ((OM_S_OBJECT_LINKAGE *)buffer)[i].osnum;
                current_number_objects--;
                (*count)++;
            }
        }
    }

    if (buffer) om$dealloc (ptr = buffer);

    return (OM_S_SUCCESS);
}
end implementation GRowner;

