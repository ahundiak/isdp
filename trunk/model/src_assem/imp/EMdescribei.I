class implementation EMdescribe;

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
#include "assempriv.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: debug                                                           |
 |                                                                           |
 | This method prints out the contents of a EMdescribe.                      |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method debug ()
{
    IGRlong om_msg;
    IGRchar name[DI_PATH_MAX];
    IGRint  i, count;
    DIint   status = DIR_S_SUCCESS;
    DIobjid objid;
    
    count = om$dimension_of (varray = me->info);
    

    for (i=0; i<count; ++i)
    {
        om_msg = om$send (msg = message IGRdir.translate (&status,
                                                          NULL,
                                                          i,
                                                          name,
                                                          &objid),
                          targetid = my_id);

        if ((om_msg & status & 1) && (status != DIR_W_NAME_NOT_FOUND))
        {
#ifdef DEBUG
            printf ("name[%d]               = %s\n", i, name);
#endif
        }
        else
        {
#ifdef DEBUG
            printf ("name[%d]               = NOT FOUND\n", i);
#endif
        }
    }

    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: delete                                                          |
 |                                                                           |
 | This method deletes the EMdescribe object.                                |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method delete (int f_defer_flag)
{
    IGRlong    om_msg, ok;
    IGRboolean old_system_mode;

    /*
     * Turn on the system mode. This allows subclasses of EMdescribe
     * to ignore system checks when removing objects.
     */
    old_system_mode = EMdesc_set_system_mode (TRUE);

    /*
     * Disconnect the described graphic.
     */
    om$send (msg = message EMdescribe.EMrem_notify (&ok),
             targetid = my_id);

    /*
     * Delete myself.
     */
    om_msg = om$send (msg = message DIrectory.delete (f_defer_flag),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    if (!(om_msg & 1))
    {
        goto quit;
    }
    
quit:

    EMdesc_set_system_mode (old_system_mode);
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMdelete                                                         |
 |                                                                           |
 | This message deletes a EMdescribe object.                                 |
 |                                                                           |
 | Output:  IGRlong    * msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMdelete (IGRlong * msg)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    IGRchar     name[DI_PATH_MAX];
    IGRint      i, count;
    IGRboolean  old_system_mode;
    
    /*
     * Turn on system mode.
     */
    old_system_mode = EMdesc_set_system_mode(TRUE);
    
    /*
     * Delete my contents.
     */
    om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                            EM_MEMBER_TYPES,
                                                            &count),
                      targetid = my_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    for (i=count-1; i>=0; i--)
    {
        om_msg = om$send (msg = message EMdescribe.EMrem_memb (msg,
                                                               NULL,
                                                               EM_MEMBER_TYPES,
                                                               i),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
    
    /*
     * Get my name.
     */
    if (di$untranslate (objid = my_id,
                        osnum = OM_Gw_current_OS,
                        objname = name) == DIR_S_SUCCESS)
    {
        /*  
         * Make sure I'm not the active describe object.
         */
        om_msg = om$send (msg = message EMdescribe.EMset_active (msg, FALSE),
                          targetid = my_id);

        /*  
         * Remove the directory.
         */
        om_msg = di$rmdir (dirname = name, synpath = TRUE);
    }
    else
    {
        /*
         * Delete the uninitialized directory.
         */
        om_msg = om$send (msg = message EMdescribe.delete (0),
                          mode = OM_e_wrt_message,
                          targetid = my_id);
    }

 quit:
     
    /*
     * Restore system mode.
     */
    EMdesc_set_system_mode(old_system_mode);
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Methode: EMpass                                                           |
 |                                                                           |
 | This method will call a function on itself and the propogate the pass     |
 | message to each describe object inside the receiving describe object. The |
 | user may also provide a selection function that further narrows the scope |
 | of the pass.                                                              |
 |                                                                           |
 | Input:   struct GRmd_env * mod_env           Module environment.          |
 |          IGRint            depth             Initial depth, 0.            |
 |          IGRlong           (*pass_func)()    Function to call.            |
 |          IGRchar         * pass_func_info    Function information.        |
 |          IGRboolean        (*pass_select)()  Function to select pass objs |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code                              |
 |                                                                           |
 | Prototype: IGRlong      (*pass_func)(IGRlong         * msg,               |
 |                                      struct GRmd_env * mod_env,           |
 |                                      IGRint            depth              |
 |                                      IGRchar         * pass_func_info,    |
 |                                      struct GRid     * desc_id)           |
 |                                                                           |
 |            IGRboolean   (*pass_select)(struct GRid * desc_id)             |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMpass (IGRlong         * msg;
               struct GRmd_env * mod_env;
               IGRint            depth; 
               IGRlong           (*pass_func)();
               IGRchar         * pass_func_info;
               IGRboolean        (*pass_select)())
{
    IGRlong       om_msg = OM_S_SUCCESS;
    IGRint        count = 0, i;
    struct GRid   my_grid;
    EMmemb        memb;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    *msg = ASM_S_SUCCESS;
    
    /*
     * Call the function on the myself.
     */
    om_msg = (*pass_func)(msg, 
                          mod_env, 
                          depth++,
                          pass_func_info, 
                          &my_grid);

    if ((om_msg == OM_I_STOP_SENDING) || !(om_msg & *msg & 1))
    {
        *msg = ASM_S_SUCCESS;
        goto quit;
    }

    /*
     * Get all the describe types that are members.
     */
    om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg, 
                                                            EM_DESCRIBE_TYPES,
                                                            &count),
                      targetid = my_id);
    

    if (!(om_msg & *msg & 1))
    {   
        goto quit;
    }
       
    /*
     * For each describe object propogate the message if it passes
     * selection.
     */
    for (i=0; i<count; ++i)
    {
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_DESCRIBE_TYPES,
                                                               i,
                                                               &memb),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * Allow user to further narrow selection.  
         */
        if ((pass_select) ? (*pass_select)(mod_env,
                                           depth,
                                           pass_func_info,
                                           &(memb.id)) : TRUE)
        {
            om_msg = om$send (msg = message EMdescribe.EMpass 
                                                         (msg,
                                                          mod_env,
                                                          depth,
                                                          pass_func,
                                                          pass_func_info,
                                                          pass_select),
                              targetid = memb.id.objid,
                              targetos = memb.id.osnum);

            if (om_msg == OM_I_STOP_SENDING)
            {
                om_msg = OM_S_SUCCESS;
                break;
            }
        }
    }                        
    
 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMupdate                                                         |
 |                                                                           |
 | This method will update the describe object according to it's new context.|
 |                                                                           |
 | Output:  IGRlong *   msg         Return code.                             |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMupdate (IGRlong *msg)
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    *msg = ASM_S_SUCCESS;
    
    return om_msg;
}

end implementation EMdescribe;




