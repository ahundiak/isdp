class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grerr.h>
#include <gocmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>

#include <assemdef.h>
#include <assem.h>
#include <assemmacros.h>
#include <assempriv.h>

from GRreffile import GRgetenvironment;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMadd_memb                                                      |
 |                                                                           |
 | This method adds a member on the instance by name or index.               |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/18/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMadd_memb  (IGRlong *  msg;
                    EMmemb  *  memb)
{
    IGRlong om_msg;
    
    /*
     * Add the member to the directory.
     */
    om_msg = om$send (msg = message EMdescribe.EMadd_memb (msg, memb),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * If the member is a graphic object or a handle add it to
     * the instance as a component.
     */
    if (memb->type & (EM_HANDLE | EM_GRAPHIC))
    {
        struct GRid my_grid;
        IGRlong     maxndx = OM_K_MAXINT;
        
        my_grid.objid = my_id;
        my_grid.osnum = OM_Gw_current_OS;
        
        om_msg = om$send (msg = message GRconnector.GRrigidconn (msg,
                                                                 &my_grid,
                                                                 &maxndx),
                          targetid = memb->id.objid,
                          targetos = memb->id.osnum);

        if (!(om_msg & *msg & 1))
        {
            IGRlong ok;
            
            om$send (msg = message EMdescribe.EMrem_memb (&ok,
                                                          memb->name,
                                                          EM_INSTANCE,
                                                          -1),
                     mode = OM_e_wrt_message,
                     targetid = my_id);
                                                          
            goto quit;
        }
    }
    
 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMrem_memb                                                      |
 |                                                                           |
 | This method removes a member from the part by name or index.              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMrem_memb    (IGRlong *  msg;
                      IGRchar *  name;
                      IGRint     type;
                      IGRint     index)
{
    IGRlong         om_msg;
    OM_S_CHANSELECT chansel;
    EMmemb          memb;

    /*
     * Get the member id.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                           name,
                                                           type,
                                                           index,
                                                           &memb),
                      targetid = my_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * Remove the member from the directory.
     */
    om_msg = om$send (msg = message EMdescribe.EMrem_memb (msg, 
                                                           name,
                                                           type,
                                                           index),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    GRget_to_comp_chansel (&chansel);
    
    /*
     * If the member is owned ...
     */
    if (om$is_objid_on_channel (objid_c = my_id,
                                p_chanselect = &chansel,
                                objid = memb.id.objid) == OM_S_SUCCESS)
    {
        struct GRid my_grid;
        
        my_grid.objid = my_id;
        my_grid.osnum = OM_Gw_current_OS;
        
        /*
         * Disconnect it.
         */
        om_msg = om$send (msg = message GRconnector.GRdisconn (msg, &my_grid),
                          targetid = memb.id.objid,
                          targetos = memb.id.osnum);
    }
    
 quit:
    
    return om_msg;
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMlegal_memb_op                                                 |
 |                                                                           |
 | This method returns success or failure depending on whether the requested |
 | operation is legal or not.                                                |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMlegal_memb_op (IGRlong * msg;
                        IGRint    operation;
                        EMmemb  * memb)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = ASM_S_SUCCESS;

    switch (operation)
    {
    case EM_ADD:
        if (!(memb->type & (EM_INSTANCE_ATTR | EM_HANDLE |
                            EM_LINK_ATTR | EM_GRAPHIC)))
        {
            *msg = ASM_E_ILLEGALOP;
        }
        break;
        
    case EM_MOD:
        if (memb->type & EM_LINK_ATTR)
        {
            *msg = ASM_E_ILLEGALOP;
        }
        break;
    }

    if (*msg & 1)
    {
        om_msg = om$send (msg = message EMdescribe.EMlegal_memb_op (msg,
                                                                    operation,
                                                                    memb),
                          mode = OM_e_wrt_message,
                          targetid = my_id);
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMget_memb_type                                                 |
 |                                                                           |
 | This method returns the member type of this object.                       |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_memb_type   (IGRlong *  msg;
                          IGRint  *  type)
{
    *msg = MSSUCC;
    *type = EM_INSTANCE;
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMdefault_memb_type                                             |
 |                                                                           |
 | This method returns a default type for a object.                          |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMdefault_memb_type (IGRlong     * msg;
                            struct GRid * memb_id;
                            IGRint      * type)
{
    IGRlong om_msg;
    
    om_msg = om$send (msg = message EMdescribe.EMdefault_memb_type (msg,
                                                                    memb_id,
                                                                    type),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

    if ((om_msg & *msg & 1) && (*type == EM_ATTRIBUTE))
    {
        *type = EM_INSTANCE_ATTR;
    }
    
    return om_msg;
}

end implementation EMinstance;

