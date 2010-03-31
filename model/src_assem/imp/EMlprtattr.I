class implementation EMlocalpart;

#include <grimport.h>
#include <DIprims.h>
#include <grerr.h>
#include <gocmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>

#include <assemdef.h>
#include <assem.h>
#include <assempriv.h>

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMmod_attr                                                      |
 |                                                                           |
 | This method notifies the BOM form if either the part number of revision   |
 | changes.                                                                  |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/18/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMmod_attr    (IGRlong *  msg;
                      IGRchar *  name;
                      IGRint     type;
                      IGRint     index;
                      EMattr  *  attr)
{
    IGRlong     om_msg;

    /*
     * Modify the attribute.
     */
    om_msg = om$send (msg = message EMdescribe.EMmod_attr(msg,
                                                          name,
                                                          type,
                                                          index,
                                                          attr),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

    if (om_msg & *msg & 1)
    {
        EMattr loc_attr;
        
        /*
         * If this was modified by index get the name of the attr.
         */
        if (name == NULL)
        {
            om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                                   name,
                                                                   type,
                                                                   index,
                                                                   &loc_attr),
                              targetid = my_id);
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            name = loc_attr.info.name;
        }
        
        /*
         * If the attribute is either the part number or description
         * update the BOM.
         */
        if (!strcmp(name, "number") || !strcmp(name, "revision"))
        {
            /*
             * Update my name.
             */
            om_msg = om$send (msg = message EMdescribe.EMupdate (msg),
                              targetid = my_id);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            EMbom_update(BOM_MOD_ENTRY, my_id, OM_Gw_current_OS, NULL);
        }
    }
                                                               
 quit:

    return (om_msg);
}

end implementation EMlocalpart;





