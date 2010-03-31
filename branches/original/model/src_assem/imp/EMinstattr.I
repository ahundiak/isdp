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
#include <assempriv.h>

from EMpart import EMget_instancename;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMchange_part                                                     |
 |                                                                           |
 | This method will change the instance of a part to another part type.      |
 |                                                                           |
 | Input:   struct GRid * new_part      New Part Definition.                 |
 |          struct GRid * new_graphic   New Graphic Definition. Optional.    |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 | Note:                                                                     |
 |                                                                           |
 | There is a restriction that a instance can only be change between part    |
 | types which are in the same object space.                                 |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  4/6/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMchange_part (IGRlong         * msg;
                      struct GRmd_env * mod_env;
                      struct GRid     * new_part;
                      struct GRid     * new_graphic)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    struct GRid my_part;
    IGRint      i, count, index;
    IGRboolean  old_system_mode;
    DIint       status = DIR_S_SUCCESS;
    IGRchar     old_name[DI_PATH_MAX], new_name[DI_PATH_MAX];
    EMmemb      memb;
        
    
    /*
     * Turn on the system mode.
     */
    old_system_mode = EMdesc_set_system_mode (TRUE);
    
    /*
     * Make sure new_part is specified.
     */
    if (new_part)
    {
        /*
         * Get my current part definition object.
         */
        om_msg = om$send (msg = message EMinstance.EMget_part (msg, &my_part),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * Get my index from the part.
         */
        om_msg = om$send (msg = message IGRdir.unindex (&status,
                                                        &index,
                                                        NULL,
                                                        my_id),
                          targetid = my_part.objid,
                          targetos = my_part.osnum);
        
        if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }

        /*  
         * Get my information from the part.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               NULL,
                                                               EM_MEMBER_TYPES,
                                                               index,
                                                               &memb),
                          targetid = my_part.objid,
                          targetos = my_part.osnum);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Get my name.
         */
        if (di$untranslate (objid = my_id,
                            osnum = OM_Gw_current_OS,
                            objname = old_name) != DIR_S_SUCCESS)
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }
                
        /*
         * Get an instance name for myself from the new part.
         */
        om_msg = om$send (msg = message EMpart.EMget_instancename
                                                    (msg,
                                                     NULL,
                                                     memb.name),
                          targetid = new_part->objid,
                          targetos = new_part->osnum);
                
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Get the name of the new directory.
         */
        if (di$untranslate (objid = new_part->objid,
                            osnum = new_part->osnum,
                            objname = new_name) != DIR_S_SUCCESS)
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }
        
        /*
         * Construct my new name.
         */
        strcat (new_name, ":");
        strcat (new_name, memb.name);
        
        /*
         * Rename myself.
         */
        om_msg = di$rename (oldname = old_name,
                            newname = new_name);
        
        if (!(om_msg & 1) || (om_msg == DIR_W_NAME_NOT_FOUND))
        {
            goto quit;
        }
        
        /*
         * Update my information in the new part.
         */
        om_msg = om$send (msg = message EMdescribe.EMmod_memb (msg, 
                                                               NULL,
                                                               EM_MEMBER_TYPES,
                                                               index,
                                                               &memb),
                          targetid = new_part->objid,
                          targetos = new_part->osnum);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * Get the number of link attributes on me.
         */
        om_msg = om$send (msg = message EMdescribe.EMnum_attrs
                                                      (msg,
                                                       EM_LINK_ATTR,
                                                       &count),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * For all link attributes ...
         *
         * NOTE: Go in reverse order because the count is aquired by
         * type and the type of the attribute may change.
         */
        for (i=count; i>=0; --i)
        {
            /*
             * Relink the attribute to the cooresponding attribute
             * on the new part definition.
             */
            om_msg = om$send (msg = message EMinstance.EMrelink_part_attr
                                                          (msg, 
                                                           NULL,
                                                           i,
                                                           NULL),
                              targetid = my_id);
        }
    }
    else
    {
        *msg = MSFAIL;
    }

 quit:
    
    /*
     * Restore the system mode.
     */
    EMdesc_set_system_mode (old_system_mode);
    
    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMlink_part_attr                                                  |
 |                                                                           |
 | This method will create an attribute on the instance object which is a    |
 | "link" to an attribute on that instance's part object.                    |
 |                                                                           |
 | Input:   IGRchar     * name      Name of the attribute to link.           |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          EMattr      * attr      Attribute constructed.                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  4/6/93     creation                                      |
 |                                                                           |
 | Note: At present an expression object is created which has the part's     |
 |       attribute as a parent. In the future an ACdyn_col may be created    |
 |       and maintained to store the "links" instead of creating a number    |
 |       of expression objects, if this happens the id returned in the       |
 |       EMattr structure will be an ACpretend object's id instead of        |
 |       expression id.                                                      |
 |                                                                           |
 |       The EMget_attr message on EMinstance will return link attributes if |
 |       the EM_LINK_ATTR type is specified.                                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMlink_part_attr (IGRlong     *  msg; 
                         IGRchar     *  name;
                         EMattr      *  attr)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    EMattr      attr;

    attr.info.type = EM_LINK_ATTR;
    strcpy (attr.info.name, name);
    attr.info.desc[0] = '\0';
    attr.value.type = EM_STRING;
    strcpy (attr.value.syntax, "Attribute Link Failed");

    /*
     * Add a dummy link attribute.
     */
    om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, &attr),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    if (om_msg & *msg & 1)
    {
        /*
         * Relink it.
         */
        om_msg = om$send (msg = message EMinstance.EMrelink_part_attr 
                                                    (msg,
                                                     name,
                                                     0,
                                                     NULL),
                          targetid = my_id);
    }
    
    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMrelink_part_attr                                                |
 |                                                                           |
 | This method will relink an attribute on the instance object which has     |
 | been linked with EMlink_part_attr to the cooresponding attribute on       |
 | the instance's new part. This will be used after an instance is changed   |
 | from one part type to another or any time an instance which has a linked  |
 | attribute needs to rebind to it's part's attribute.                       |
 |                                                                           |
 | Input:   IGRchar     * name      Name of the attribute to relink.         |
 |          IGRint        index     Index of attribute to relink.            |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          EMattr      * attr      Modified attribute.                      |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  4/6/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMrelink_part_attr (IGRlong     *  msg;
                           IGRchar     *  name;
                           IGRint         index;
                           EMattr      *  attr)
{
    IGRlong     om_msg;
    struct GRid my_part;
    EMattr      link_attr, part_attr;
    
    if (attr == NULL)
    {
        attr = &link_attr;
    }
    
    /*
     * Get the current part definition. This is the definition we will
     * try to relink to.
     */
    om_msg = om$send (msg = message EMinstance.EMget_part (msg, &my_part),
                      targetid = my_id);

    if (om_msg & *msg & 1)
    {
        /*
         * Get the link attribute on myself.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                               name,
                                                               EM_LINK_ATTR,
                                                               0,
                                                               attr),
                          targetid = my_id);
        
        if (om_msg & *msg & 1)
        {
            /*
             * Get the attribute on the part definition.
             */
            om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                                   name,
                                                                   EM_LINK_ATTR,
                                                                   0,
                                                                   &part_attr),
                              targetid = my_part.objid,
                              targetos = my_part.osnum);
            

            if (om_msg & *msg & 1)
            {
                /*
                 * Get the name for the part's attribute and make
                 * this the syntax. This causes the part's attribute
                 * to become our attribute's parent.
                 */
                if (di$untranslate (objid = attr->info.id.objid,
                                    osnum = attr->info.id.osnum,
                                    objname = attr->value.syntax) != DIR_S_SUCCESS)
                {
                    *msg = ASM_E_ABORT;
                }
            }

            /*
             * If anything failed ...
             */
            if (!(om_msg & *msg & 1))
            {
                /*
                 * Change the atttribute on myself to a dynamic attribute 
                 * and make it's value constant. This could happen during 
                 * a change part where the new part definition doesn't 
                 * have the same attribute set defined as the old part
                 * definition.
                 */
                attr->info.type = EM_INSTANCE_ATTR;

                if (attr->value.type == EM_STRING)
                {
                    strcpy (attr->value.syntax, part_attr.value.data.s);
                }
                else if (attr->value.type == EM_DOUBLE)
                {
                    sprintf (attr->value.syntax, "%lf", part_attr.value.data.d);
                }
                else
                {
                    sprintf (attr->value.syntax, "%d", part_attr.value.data.i);
                }
            }

            /*
             * Change the attribute on myself.
             */
            om_msg = om$send (msg = message EMdescribe.EMmod_attr
                                                    (msg,
                                                     name,
                                                     EM_LINK_ATTR,
                                                     0,
                                                     attr),
                              mode = OM_e_wrt_message,
                              targetid = my_id);
        }
    }

    return om_msg;
}

end implementation EMinstance;


