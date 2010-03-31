class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>

#include <assemdef.h>
#include <assem.h>
#include <assempriv.h>

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRgetname                                                       |
 |                                                                           |
 | This method returns the object's name.                                    |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRgetname(IGRlong *msg; IGRchar *name)
{
    IGRlong           om_msg;
    IGRint            status = DIR_S_SUCCESS;
    struct GRid       part_id;
    EMmemb            memb;
    IGRint            index;

    /*
     * Get the part's definition object.
     */
    om_msg = om$send (msg = message EMinstance.EMget_part (msg, &part_id),
                      targetid = my_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Get the index of this object on the part.
     */
    om_msg = om$send (msg = message IGRdir.unindex (&status,
                                                    &index,
                                                    NULL,
                                                    my_id),
                      targetid = part_id.objid,
                      targetos = part_id.osnum);
    
    if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Get the member information.  
     */
    om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                           NULL,
                                                           EM_MEMBER_TYPES,
                                                           index,
                                                           &memb),
                      senderid = NULL_OBJID,
                      targetid = part_id.objid,
                      targetos = part_id.osnum);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    if (name)
    {
        strcpy (name, memb.name);
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRputname                                                       |
 |                                                                           |
 | This method sets the object's name.                                       |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRputname(IGRlong *msg; IGRchar *name)
{
    *msg = MSSUCC;

    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRchgname                                                       |
 |                                                                           |
 | This method changes the object's name.                                    |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRchgname(IGRlong *msg; struct GRmd_env *env; IGRchar *name)
{
    IGRlong           om_msg = OM_S_SUCCESS;
    IGRint            status = DIR_S_SUCCESS;
    struct GRid       part_id;
    EMmemb            memb;
    IGRint            index;

    /*
     * EMinstance doesn't support a delete for undelete.
     */
    if (!strncmp(name, ".deleted_", 9))
    {
        *msg = MSSUCC;
        goto quit;
    }
    
    /*
     * Get the part's definition object.
     */
    om_msg = om$send (msg = message EMinstance.EMget_part (msg, &part_id),
                      targetid = my_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Get the index of this object on the part.
     */
    om_msg = om$send (msg = message IGRdir.unindex (&status,
                                                    &index,
                                                    NULL,
                                                    my_id),
                      targetid = part_id.objid,
                      targetos = part_id.osnum);
    
    if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Get the member information.  
     */
    om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                           NULL,
                                                           EM_MEMBER_TYPES,
                                                           index,
                                                           &memb),
                      targetid = part_id.objid,
                      targetos = part_id.osnum);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * Change the name.
     */
    if (strcmp (name, memb.name))
    {
        strcpy (memb.name, name);

        om_msg = om$send (msg = message EMdescribe.EMmod_memb (msg,
                                                               NULL,
                                                               EM_MEMBER_TYPES,
                                                               index,
                                                               &memb),
                          targetid = part_id.objid,
                          targetos = part_id.osnum);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * Get the handle id.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg, 
                                                               NULL,
                                                               EM_HANDLE,
                                                               0,
                                                               &memb),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            *msg = MSSUCC;
            om_msg = OM_S_SUCCESS;
            goto quit;
        }
        
        /*
         * Change the name of the handle.   
         */
        strcpy (memb.name, name);
        
        om_msg = om$send (msg = message EMdescribe.EMmod_memb (msg,
                                                               NULL,
                                                               EM_HANDLE,
                                                               0,
                                                               &memb),
                          targetid = my_id);
    }

 quit:
    
    return om_msg;
}

end implementation EMinstance;





