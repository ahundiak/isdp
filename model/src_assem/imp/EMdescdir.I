class implementation EMdescribe;

#include <grimport.h>
#include <DIdef.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <grmessage.h>
#include <msdef.h>
#include <OMmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: remove                                                          |
 |                                                                           |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method IGRdir.remove (DIint *status; DIchar *name; DIint index)
{
    IGRlong     om_msg = OM_S_SUCCESS, msg;
    IGRuint     count;
    EMmemb      memb;
    
    /*
     * If removed by name get the object's index before removal.
     */
    if (name)
    {
        strcpy (memb.name, name);
        
        om_msg = om$send (msg = message IGRdir.unindex (status, 
                                                        &memb.index,
                                                        name,
                                                        NULL_OBJID),
                          targetid = my_id);

        if (!(om_msg & *status & 1) || (*status == DIR_W_NAME_NOT_FOUND))
        {
            goto quit;
        }
    }
    else
    {
        memb.index = index;
        
        om_msg = om$send (msg = message IGRdir.translate (status,
                                                          NULL,
                                                          index,
                                                          memb.name,
                                                          NULL),
                          targetid = my_id);
    }

    /*
     * Get the size of the description array.
     */
    count = om$dimension_of (varray = me->info);

    /*
     * Do a sanity check!
     */
    if ((memb.index < 0) || (memb.index >= count))
    {
        *status = DIR_E_ABORT;
#ifdef DEBUG
        printf ("ERROR: EMdescribe.remove: Bad index or description arrary out of sync\n");
#endif
        goto quit;
    }
    
    /*
     * Make sure it's ok to remove this object.
     */
    om_msg = om$send (msg = message EMdescribe.EMlegal_memb_op (&msg,
                                                                EM_REM,
                                                                &memb),
                      targetid = my_id);
    
    if (!(om_msg & msg & 1))
    {
        goto quit;
    }
    
    /*
     * Remove the named object from the directory.
     */
    om_msg = om$send (msg = message DIrectory.remove (status, 
                                                      NULL, 
                                                      memb.index),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    if (!(om_msg & *status & 1) || (*status == DIR_W_NAME_NOT_FOUND))
    {
        goto quit;
    }
    
    /*
     * Remove the member info.
     */
    om_msg = om$send (msg = message EMdescribe.EMrem_memb_info (&msg, &memb),
                      targetid = my_id);

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: add                                                             |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method add ( DIint  *status; DIchar *name; DIobjid objid; int *p_index )
{
    IGRlong     om_msg, msg;
    IGRint      loc_index;
    IGRint      index;
    IGRuint     count;
    IGRboolean  added = FALSE;
    
    /*
     * If the index wasn't requested use a local one.
     */
    if (p_index == NULL)
    {
        p_index = &loc_index;
    }
    
    /*
     * Don't allow synonyms if not in system mode. Synonyms are required
     * during a rename operation.
     */
    if (!EMdesc_get_system_mode())
    {
        om_msg = om$send (msg = message IGRdir.unindex (status,
                                                        &index,
                                                        NULL,
                                                        objid),
                          targetid = my_id);
        
        /*
         * If that object is already named, don't allow it to be added.
         */
        if ((om_msg & *status & 1) && (*status != DIR_W_NAME_NOT_FOUND))
        {
            /*
             * Return DIR_E_NAME_DUP for edit dimension to work.
             */
            *status = DIR_E_NAME_DUP;
            goto quit;
        }
        else
        {
            om_msg = OM_S_SUCCESS;
            *status = DIR_S_SUCCESS;
        }
    }
    
    /*
     * Add the object.
     */
    om_msg = om$send (msg = message DIrectory.add (status,
                                                   name,
                                                   objid,
                                                   p_index),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    if (!(om_msg & *status & 1))
    {
        goto quit;
    }

    added = TRUE;

    /*
     * Get the dimension of the info structure.
     */
    count = om$dimension_of (varray = me->info);
    
    /*
     * Do a sanity check.
     */
    if (*p_index > count)
    {
        *status = DIR_E_ABORT;
#ifdef DEBUG
        printf ("ERROR: EMdescribe.add: Description arrary out of sync\n");
#endif
        goto quit;
    }
    
    /*
     * If the doesn't already have a type/description info
     * entry, add a default. Otherwise assume that the EMadd_memb
     * message send this message and will take care of updating
     * the info structure.
     */
    if (*p_index == count)
    {
        EMmemb      memb;

        strcpy (memb.name, name);
        memb.id.objid = objid;
        memb.id.osnum = OM_Gw_current_OS;
        memb.index = *p_index;
        memb.desc[0] = '\0';
        
        /*
         * Get the default member type.
         */
        om_msg = om$send (msg = message EMdescribe.EMdefault_memb_type 
                                                    (&msg, 
                                                     &memb.id, 
                                                     &memb.type),
                          targetid = my_id);

        if (!(om_msg & msg & 1))
        {
            *status = DIR_E_ABORT;
            goto quit;
        }

        /*
         * Add the member info.
         */
        om_msg = om$send (msg = message EMdescribe.EMadd_memb_info (&msg,
                                                                    &memb),
                          targetid = my_id);

        if (!(om_msg & msg & 1))
        {
            *status = DIR_E_ABORT;
            goto quit;
        }
    }
                      
 quit:
    
    /*
     * If something failed after the object was added ...
     */
    if (!(om_msg & *status & 1) && added)
    {
        DIint ok;
        
        /*
         * Remove it.
         */
        om$send (msg = message IGRdir.remove (&ok, name, -1),
                 mode = OM_e_wrt_message,
                 targetid = my_id);
    }
    
    return om_msg;
}

end implementation EMdescribe;




