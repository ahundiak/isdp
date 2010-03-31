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
#include <godef.h>
#include <go.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"
#include "assemmacros.h"

from GRvg import GRgetsymb;

extern IGRlong EMlayer_delete_func();

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

    om_msg = om$send (msg = message EMdescribe.debug (),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    return(OM_S_SUCCESS);
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
    IGRint      i, count;

    *msg = ASM_S_SUCCESS;
    
    /*
     * If this is the file part ...
     */
    if (EM_IS_FILE_PART(me->props))
    {
        EMmemb memb;
        
        /*
         * Get the number of local parts.
         */ 
        om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                                EM_PART,
                                                                &count),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        for (i=count-1; i>=0; --i)
        {
            /*
             * Get the local part.
             */
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

            /*
             * Delete the local part.
             */
            om_msg = om$send (msg = message EMdescribe.EMdelete (msg),
                              targetid = memb.id.objid,
                              targetos = memb.id.osnum);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
        }
    }
    else /* Local Part */
    {
        struct GRid part_id;
        
        /*
         * Get the file part.
         */
        om_msg = asm$get_file_part (msg = msg,
                                    part_id = &part_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Have the file part reuse my layers.
         */
        om_msg = om$send (msg = message EMlocalpart.EMreuse_layers 
                                                           (msg,
                                                            me->layers,
                                                            me->active_on,
                                                            me->nonactive_on),
                          targetid = part_id.objid,
                          targetos = part_id.osnum);
    }

    /* Delete  all objects that are fall (or fell) on my layers. */


     om_msg = EMlayer_pass(msg,
                           NULL,
                           me->layers,
                           NULL,
                           NULL,
                           EMlayer_delete_func,
                           NULL);

    /*
     * Now delete myself.
     */
    om_msg = om$send (msg = message EMdescribe.EMdelete (msg),
                      mode = OM_e_wrt_message,
                      targetid = my_id);


    if (om_msg & *msg & 1)
    {
        EMbom_update (BOM_REM_ENTRY, my_id, OM_Gw_current_OS, NULL);
    }

 quit:
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMpass                                                          |
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
 |                                      IGRint            depth,             |
 |                                      IGRchar         * pass_func_info,    |
 |                                      struct GRid     * desc_id)           |
 |                                                                           |
 |            IGRboolean   (*pass_select)(struct GRmd_env * mod_env,         |
 |                                        IGRint            depth            |
 |                                        IGRchar         * pass_func_info,  |
 |                                        struct GRid     * desc_id)         |
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
    IGRlong             om_msg = OM_S_SUCCESS;
    IGRint              part_count = 0, instance_count = 0, i, j;
    struct GRid         part_id, instance_id;
    struct GRsymbology  symb;
    
    /*
     * Call the EMpass on myself at the EMdescribe level, this
     * will take care of calling the function on myself and
     * propagating this message to any member describe objects,
     * including local parts.
     */
    om_msg = om$send (msg = message EMdescribe.EMpass (msg,
                                                       mod_env,
                                                       depth,
                                                       pass_func,
                                                       pass_func_info,
                                                       pass_select), 
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    if (om_msg == OM_I_STOP_SENDING)
    {
        om_msg = OM_S_SUCCESS;
        goto quit;
    }
    else if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Get any instances that fall on my levels.
     */
    om_msg = asm$part_count (msg = msg,
                             mod_env = mod_env,
                             type = EM_CACHED_PART,
                             count = &part_count);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * Increment the depth.
     */
    depth++;
    
    /*
     * For all the parts.
     */
    for (i=0; i<part_count; ++i)
    {
        /*
         * Get the part.
         */
        om_msg = asm$get_part (msg = msg,
                               mod_env = mod_env,
                               type = EM_CACHED_PART,
                               index = i,
                               part_id = &part_id);
        
        if (!(om_msg & *msg & 1))
        {
            continue;
        }
        
        /*
         * Get the instances of this part.
         */
        om_msg = asm$instance_count (msg = msg,
                                     part_id = &part_id,
                                     count = &instance_count);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        for (j=0; j<instance_count; ++j)
        {
            om_msg = asm$get_instance (msg = msg,
                                       part_id = &part_id,
                                       index = j,
                                       instance_id = &instance_id);
            
            if (!(om_msg & *msg & 1))
            {
                continue;
            }
            
            om_msg = om$send (msg = message GRvg.GRgetsymb (msg, &symb),
                              targetid = instance_id.objid,
                              targetos = instance_id.osnum);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            /*
             * If this instance falls on this my layers ...
             */
            if (EMlayer_in_layers (symb.level, me->layers))
            {
                /*
                 * Send the pass message if the instance passes selection.
                 */
                if ((pass_select) ? (*pass_select)(mod_env,
                                                   depth,
                                                   pass_func_info,
                                                   &instance_id) : TRUE)
                {
                    /*
                     * Propagate the EMpass through the instance.
                     */
                    om_msg = om$send (msg = message EMdescribe.EMpass
                                                          (msg,
                                                           mod_env,
                                                           depth,
                                                           pass_func,
                                                           pass_func_info,
                                                           pass_select),
                                      targetid = instance_id.objid,
                                      targetos = instance_id.osnum);
                }
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
 | This method will update the local part's name according to it's part      |
 | number and revision.                                                      |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code.                             |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMupdate (IGRlong *msg)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    IGRchar     new_name[DI_PATH_MAX], old_name[DI_PATH_MAX];
    EMattr      number, revision;
    struct GRid part_id;
    
    *msg = ASM_S_SUCCESS;
    
    part_id.objid = my_id;
    part_id.osnum = OM_Gw_current_OS;
    
    /*
     * Get my name.
     */
    if (di$untranslate (objid = my_id,
                        objname = old_name) != DIR_S_SUCCESS)
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
    
    /*
     * Get my current number and revision.
     */
    om_msg = asm$get_part_identity (msg = msg,
                                    part_id = &part_id,
                                    number = &number,
                                    revision = &revision);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * Construct the new name.
     */
    om_msg = di$give_pathname (osnum = OM_Gw_current_OS,
                               pathname = new_name);

    if (!(om_msg & 1) || (om_msg == DIR_W_NAME_NOT_FOUND))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    if (EM_IS_FILE_PART(me->props))
    {
        sprintf (&new_name[strlen(new_name)], 
             ":definition:%s_%s", 
             number.value.data.s,
             revision.value.data.s);
    }
    else if (EM_IS_LOCAL_PART(me->props))
    {
    struct GRmd_env env;
    struct GRid file_part_id;

        strcat( new_name,":definition" );

        /*
         * get the current module env and the filepart id in it
         */
        gr$get_module_env( buffer = &env );

        om_msg = asm$get_file_part( msg = msg,
                                    mod_env = &env,
                                    part_id = &file_part_id );

        om_msg = di$untranslate (objname = new_name,
                                 objid = file_part_id.objid,
                                 osnum = file_part_id.osnum);

        sprintf (&new_name[strlen(new_name)], 
                     ":%s_%s", 
                         number.value.data.s,
                         revision.value.data.s);

    }

    if (strcmp(new_name, old_name))
    {
        sprintf (new_name, "%s_%s", number.value.data.s, revision.value.data.s);
        
        om_msg = EMrename_directory (msg, &part_id, new_name);
        
        if (!(om_msg & 1))
        {
            goto quit;
        }
    }

quit:    
                      
    return om_msg;
}

end implementation EMlocalpart;




