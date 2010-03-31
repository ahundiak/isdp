class implementation EMlocalpart;

#include <grimport.h>
#include <DIprims.h>
#include <OMmacros.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"
#include "assempriv.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_active_local_part                                           |
 |                                                                           |
 | This method returns the active local part.                                |
 |                                                                           |
 | Output:  IGRlong         * msg          Return code.                      |
 |          struct GRid     * part_id      Active part.                      |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_active_local_part (IGRlong     * msg;
                                struct GRid * part_id)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    IGRboolean  active;
    struct GRid loc_part_id;
    
    *msg = ASM_S_SUCCESS;
    
    if (!part_id)
    {
        part_id = &loc_part_id;
    }
    
    if (EM_IS_FILE_PART(me->props))
    {
        IGRint i, count;
        EMmemb memb;

        if (EM_IS_DESCRIBE_ACTIVE(me->props))
        {
            part_id->objid = my_id;
            part_id->osnum = OM_Gw_current_OS;
        }
        else
        {
            om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                                    EM_PART,
                                                                    &count),
                              targetid = my_id);
        
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            for (i=0; i<count; ++i)
            {
                om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                                       NULL,
                                                                       EM_PART,
                                                                       i,
                                                                       &memb),
                                  targetid = my_id);
                
                if (!(om_msg & *msg & 1))
                {
                    goto quit;
                }
            
                om_msg = om$send (msg = message EMdescribe.EMget_active (msg,
                                                                         &active),
                                  targetid = memb.id.objid,
                                  targetos = memb.id.osnum);
            
                if (!(om_msg & *msg & 1))
                {
                    goto quit;
                }
            
                if (active)
                {
                    part_id->objid = memb.id.objid;
                    part_id->osnum = memb.id.osnum;
                    break;
                }
            }

            if (i == count)
            {
                part_id->objid = NULL_OBJID;
            }
        }
    }
    else
    {
        struct GRid file_part_id;
        
        if (EM_IS_DESCRIBE_ACTIVE (me->props))
        {
            part_id->objid = my_id;
            part_id->osnum = OM_Gw_current_OS;
        }
        else
        {
            om_msg = asm$get_file_part (msg = msg,
                                        part_id = &file_part_id);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            om_msg = om$send (msg = message EMlocalpart.EMget_active_local_part 
                                                   (msg, part_id),
                              targetid = file_part_id.objid,
                              targetos = file_part_id.osnum);
        }
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_active                                                      |
 |                                                                           |
 | This method returns whether the part is active or not.                    |
 |                                                                           |
 | Output:  IGRlong    * msg         Return code.                            |
 |          IGRboolean * active      Part active?                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_active (IGRlong * msg; IGRboolean * active)
{
    *msg = ASM_S_SUCCESS;

    *active = EM_IS_DESCRIBE_ACTIVE(me->props);
    
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_active                                                      |
 |                                                                           |
 | This method sets whether the part is active or not.                       |
 |                                                                           |
 | Input:   IGRboolean   active      Make part active?                       |
 |                                                                           |
 | Output:  IGRlong    * msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_active (IGRlong * msg; IGRboolean active)
{
    IGRlong     om_msg;
    IGRboolean  switch_active = FALSE;
    struct GRid old_active_id;
    IGRshort    active_layer;
    
    /*
     * If the part is being made active ...
     */
    if (active)
    {
        /*
         * Get the active part.
         */
        om_msg = om$send (msg = message EMlocalpart.EMget_active_local_part 
                                                       (msg,
                                                        &old_active_id),
                          targetid = my_id);
        
        if (om_msg & *msg & 1)
        {
            /*
             * If the active part is myself ...
             */
            if ((old_active_id.objid == my_id) &&
                (old_active_id.osnum == OM_Gw_current_OS))
            {
                /*
                 * If the active part already knows it's the active
                 * part.
                 */
                if (EM_IS_DESCRIBE_ACTIVE(me->props))
                {
                    goto quit;
                }
            }
            else
            {
                /*
                 * Deactivate the existing active part.
                 */
                om_msg = om$send (msg = message EMdescribe.EMset_active
                                                       (msg, FALSE),
                                  targetid = old_active_id.objid,
                                  targetos = old_active_id.osnum);
            }
        }
        
        /*
         * Make this part the working directory.
         */
        om_msg = om$send (msg = message EMdescribe.EMset_active (msg, TRUE),
                          mode = OM_e_wrt_message,
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        switch_active = TRUE;

        /*
         * Switch to the active layer.
         */
        active_layer = me->active_layer;
        gr$put_active_layer (buffer = (IGRchar *)&active_layer);
        
        /*
         * Update the active element/layer display.
         *
         * Note, the module environment defaults to the
         * master file's module environment. This should be ok 
         * since only master file local parts can be made active.
         */
        om_msg = om$send (msg = message EMdescribe.EMset_display 
                                           (msg,
                                            NULL,
                                            (IGRint *)(&me->active_display),
                                            me->active_on,
                                            TRUE),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
    else /* Deactivation */
    {
        /*
         * Deactivate the part.
         */
        om_msg = om$send (msg = message EMdescribe.EMset_active (msg, FALSE),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        switch_active = TRUE;
        
        /*
         * Save the last active layer.
         */
        gr$get_active_layer (buffer = &active_layer);

        if (EMlayer_in_layers((IGRint)active_layer, me->layers))
        {
            me->active_layer = active_layer;
        }

        /*
         * Update the nonactive element/layer display.
         *
         * Note, the module environment defaults to the
         * master file's module environment. This should be ok 
         * since only master file local parts can be made active.
         */
        om_msg = om$send (msg = message EMdescribe.EMset_display 
                                               (msg,
                                                NULL,
                                                (IGRint *)(&me->props),
                                                me->nonactive_on,
                                                TRUE),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
    }
    
 quit:

    if (!(om_msg & *msg & 1) && switch_active)
    {
        IGRlong ok;

        if (EM_IS_DESCRIBE_ACTIVE(me->props))
        {
            /*
             * Deactivate the part.
             */
            om$send (msg = message EMdescribe.EMset_active (&ok, FALSE),
                     mode = OM_e_wrt_message,
                     targetid = my_id);
        }
        else
        {
            /*
             * Activate the part.
             */
            om$send (msg = message EMdescribe.EMset_active (&ok, TRUE),
                     mode = OM_e_wrt_message,
                     targetid = my_id);
        }
    }
        
    return OM_S_SUCCESS;
}

end implementation EMlocalpart;




