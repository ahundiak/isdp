/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRclhdr.GRconstruct

Description
        This routine initializes a cell header object.

Synopsis
        struct GRvg_construct *arglist      standard argument list

Return Values
        MSSUCC    - if successful
        MSFAIL    - if failure

History
        DEM     07/07/86    Design date and Creation date.
        HGW     07/21/86    Added code for properties.
        HGW     08/12/86    Changed terminology
        HGW     11/09/87    Changes for version 1.1
        SCW     07/22/92    Ansi conversion
*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "vardef.h"

method GRconstruct (struct GRvg_construct *arglist)
{
    IGRlong                    sts;
    IGRlong                    temp;
    IGRlong                    size;
    GRobjid                    new_id;
    struct GRpost_info         info;     /* for post method     */
    struct GRcell_class_attr   *class_attr;
    struct GRvar_list          list[4];

    *arglist->msg = MSSUCC;        /* initialize success  */
    sts = OM_S_SUCCESS;

    /*
     *  Initialize the properties word and set the NEW bit.
     */

    me->properties = arglist->properties | GRIS_NEW;

    if (arglist->class_attr)
    {
        class_attr = (struct GRcell_class_attr *)arglist->class_attr;

        size = strlen (class_attr->name_symbol) + 1;
        list[0].var = GR_SYMBOL_NAME;
        list[0].var_ptr = class_attr->name_symbol;
        list[0].num_bytes = size;
        list[0].bytes_returned = &temp;
        size = strlen (class_attr->desc_symbol) + 1;
        list[1].var = GR_SYMBOL_DESC;
        list[1].var_ptr = class_attr->desc_symbol;
        list[1].num_bytes = size;
        list[1].bytes_returned = &temp;
        list[2].var = GR_TIME_STAMP;
        list[2].var_ptr = (IGRchar *)&class_attr->time_stamp;
        list[2].num_bytes = size;
        list[2].bytes_returned = &temp;
        list[3].var = END_PARAM;

        sts = om$send (msg = message GRsymbol.GRset_inq_symbol
                            (arglist->msg, 1, list),
                       targetid = my_id);

        sts = om$send (msg = message GRowner.GRchg_owner_properties
                            (arglist->msg, 2, &class_attr->properties),
                       targetid = my_id);
    }

    if (arglist->name)
    {
        sts = om$send (msg = message GRvg.GRputname
                            (arglist->msg, arglist->name),
                       targetid = my_id);
    }

    /*
     *  The cell does not have display attributes or layers.
     */

    if (sts & *arglist->msg & 1)
    {
        /*
         *  Post the definition of the cell.
         */

        info.construct_flag = TRUE;
        sts = om$send (msg = message GRvg.GRpostabsg
                            (arglist->msg, arglist->env_info,
                             &info, arglist->geometry, &new_id),
                       targetid = my_id);
    }

    /*
     * see if we succeeded, and if not, delete the object.
     */

    if (!(sts & *arglist->msg & 1))
    {
        sts = OM_E_ERROR;
        om$send (msg = message Root.delete (NULL), targetid = my_id);
    }
    else
    {
        om$send (msg = message GRowner.GRadd_to_active_owner
                      (arglist->msg, arglist->env_info),
                 targetid = my_id);
    }
    return (sts);
}
end implementation GRclhdr;
