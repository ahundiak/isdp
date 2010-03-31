class implementation EMdescribe;

#include <grimport.h>
#include <DIprims.h>
#include <OMmacros.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <grownerdef.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"

from GRgraphics import GRdelete;

extern OMuword OPP_expression_class_id;
extern OMuword OPP_EMdescribe_class_id;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMnum_membs                                                       |
 |                                                                           |
 | This method returns the total number of members.                          |
 | The type determines which types of members should be considered.          |
 |                                                                           |
 | Input:   IGRint      type        Member types to consider.                |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |          IGRint  *   num_membs   Number of members of that type.          |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 | jhw              6/17/93     modified to work with new describe class.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMnum_membs  ( IGRlong *  msg;
                      IGRint     type;
                      IGRint  *  num_membs )
{
    IGRint i, count = 0;

    *msg = ASM_S_SUCCESS;

    *num_membs = 0;

    count = om$dimension_of (varray = me->info);
    
    for (i=0; i<count; ++i)
    {
        if (type & me->info[i].type)
        {
            (*num_membs)++;
        }
    }

    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_memb                                                        |
 |                                                                           |
 | This method gets an member by index or name.                              |
 | The type determines which types of members should be considered.          |
 |                                                                           |
 | Input:   IGRchar * name            Name of member, NULL if by index.      |
 |          IGRint    type            Types to consider, not used with name. |
 |          IGRint    index           Index of the member.                   |
 |                                                                           |
 | Output:  IGRlong * msg             Return code                            |
 |          EMmemb  * memb            Member.                                |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_memb   ( IGRlong *  msg;
                      IGRchar *  name;
                      IGRint     type;
                      IGRint     index;
                      EMmemb  *  memb )
{
    IGRlong             om_msg = OM_S_SUCCESS;
    DIint               status = DIR_S_SUCCESS;
    EMmemb              loc_memb;
    
    *msg = ASM_S_SUCCESS;

    /*
     * Allow method to be called without memb arg.
     */
    if (!memb)
    {
        memb = &loc_memb;
    }

    memb->id.osnum = OM_Gw_current_OS;
    
    if (name)
    {
        /*
         * Get the member's id.
         */
        om_msg = om$send (msg = message IGRdir.translate (&status,
                                                          name,
                                                          -1,
                                                          NULL,
                                                          &(memb->id.objid)),
                          targetid = my_id);
        

        if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
        {
            *msg = ASM_E_MEMBNOTFOUND;
            goto quit;
        }

        /*
         * If the member information was requested ...
         */
        if (&loc_memb != memb)
        {
            /*
             * Get the member's index.
             */
            om_msg = om$send (msg = message IGRdir.unindex (&status,
                                                            &(memb->index),
                                                            name,
                                                            memb->id.objid),
                              targetid = my_id);

            if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
            {
                *msg = ASM_E_ABORT;
                goto quit;
            }
            
            /*
             * Set the member's type, name and description.
             */
            memb->type = me->info[memb->index].type;
            strncpy (memb->name, 
                     name, 
                     MAX_NAME);
            strncpy (memb->desc, 
                     &me->descs[me->info[memb->index].desc_index],
                     MAX_DESC);
        }
    }
    else
    {
        IGRint loc_index = 0, count, i;
        
        /*
         * Determine the number of member info entries.
         */
        count = om$dimension_of (varray = me->info);

        /*
         * Find the object at the specified index.
         */
        for (i=0; i<count; ++i)
        {
            if (me->info[i].type & type)
            {
                if (loc_index == index)
                {
                    break;
                }

                loc_index++;
            }
        }

        /*
         * If we found the member ...
         */
        if (i < count)
        {
            /*
             * And if the member info was requested, give it
             * to them ...
             */
            if (memb != &loc_memb)
            {
                /*
                 * Store the type.
                 */
                memb->type = me->info[i].type;

                /*
                 * Store the name and id.
                 */
                om_msg = om$send (msg = message IGRdir.translate 
                                                          (&status,
                                                           NULL,
                                                           i,
                                                           memb->name,
                                                           &(memb->id.objid)),
                                  targetid = my_id);
                
                if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
                {
                    *msg = ASM_E_ABORT;
                    goto quit;
                }

                /*
                 * Store the description.
                 */
                strncpy (memb->desc, 
                         &me->descs[me->info[i].desc_index],
                         MAX_DESC);

                /*
                 * Store the index.
                 */
                memb->index = i;
            }
        }
        else /* Bad index. */
        {
            *msg = ASM_E_INVINDEX;
        }
    }
    
 quit:
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_membs                                                       |
 |                                                                           |
 | This method gets members of the specified type.                           |
 | The type determines which types of members should be considered.          |
 |                                                                           |
 | Input:   IGRint    type        Member types to consider.                  |
 |          IGRint    num_membs   Size of membs buffer.                      |
 |                                                                           |
 | Output:  IGRlong * msg         Return code                                |
 |          EMmemb  * membs       Members.                                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_membs  ( IGRlong *  msg;
                      IGRint     type;
                      IGRint     num_membs;
                      EMmemb  *  membs )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          i, num;

    *msg = ASM_S_SUCCESS;
    
    om_msg = om$send (msg = message EMdescribe.EMnum_membs( msg, 
                                                            type, 
                                                            &num ),
                      targetid = my_id );

    if (om_msg & *msg & 1)
    {
        if (num_membs < num)
        {
            *msg = ASM_E_BUFFTOOSMALL;    
        }
        else
        {
            for (i=0; i<num; ++i)
            {
                om_msg = om$send ( msg = message EMdescribe.EMget_memb
                                                                ( msg,
                                                                  NULL,
                                                                  type,
                                                                  i,
                                                                  &membs[i] ),
                                   targetid = my_id );

                if (!(om_msg & *msg & 1))
                {
                    break;
                }
            }
        }
    }

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMadd_memb                                                        |
 |                                                                           |
 | This method adds an member.                                               |
 |                                                                           |
 | Input:   EMmemb  *   memb    Member to add.                               |
 |                                                                           |
 | Output:  IGRlong *   msg     Return code                                  |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMadd_memb   ( IGRlong *  msg;
                      EMmemb  *  memb )
{
    IGRlong om_msg = OM_S_SUCCESS;

    *msg = ASM_S_SUCCESS;
    
    /*
     * See if this object alread exists.
     */
    om_msg = om$send(msg = message EMdescribe.EMget_memb (msg, 
                                                          memb->name, 
                                                          EM_MEMBER_TYPES,
                                                          0,
                                                          NULL),
                     targetid = my_id);
    
    /*
     * If object by that name already exists return an error.
     */
    if (om_msg & *msg & 1)
    {
        *msg = ASM_E_MEMBEXISTS;
    }
    else
    {
        DIint  status = DIR_S_SUCCESS;
        IGRint count = om$dimension_of (varray = me->info);
        
        *msg = ASM_S_SUCCESS;
        om_msg = OM_S_SUCCESS;
        
        /*
         * Add a new info structure for this member.
         */
        om_msg = om$send (msg = message EMdescribe.EMadd_memb_info(msg, memb),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*  
         * Add the object.
         */
        om_msg = om$send (msg = message IGRdir.add (&status,
                                                    memb->name,
                                                    memb->id.objid,
                                                    &(memb->index)),
                          targetid = my_id);
        
        if (!(om_msg & status & 1))
        {
            /*
             * Remove the added info entry.
             */
            om$vla_set_dimension (varray = me->info,
                                  size = count);
            *msg = ASM_E_DIRADD;
            goto quit;
        }

        /*
         * Do a sanity check.
         */
        if (memb->index != count)
        {
            *msg = ASM_E_ABORT;
#ifdef DEBUG
            printf ("ERROR: EMdescribe.EMadd_memb: Name index out of sync with description index\n");
#endif
            goto quit;
        }
    }

quit:
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMmod_memb                                                        |
 |                                                                           |
 | This method modifies an member.                                           |
 |                                                                           |
 | Input:   IGRchar  *   name       Name of member to modify.                |
 |          IGRint   *   type       Type of member to modify.                |
 |          IGRint   *   index      Index of member to modify.               |
 |          EMmemb   *   memb       Member info to modify.                   |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMmod_memb   ( IGRlong *  msg;
                      IGRchar *  name;
                      IGRint     type;
                      IGRint     index;
                      EMmemb  *  memb )
{
    IGRint          om_msg = OM_S_SUCCESS;
    EMmemb          loc_memb;
    
    *msg = ASM_S_SUCCESS;
    
    /*
     * Get the old member info ...
     */
    om_msg = om$send ( msg = message EMdescribe.EMget_memb (msg,
                                                            name,
                                                            type,
                                                            index,
                                                            &loc_memb),
                       targetid = my_id );

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * If the name has changed ...
     */
    if ( strcmp(memb->name, loc_memb.name))
    {
        IGRchar     my_name[DI_PATH_MAX];
        IGRchar     old_name[DI_PATH_MAX], new_name[DI_PATH_MAX];
        IGRboolean  old_system_mode;
        
        /*
         * Make sure it's ok to rename this member.
         */
        om_msg = om$send (msg = message EMdescribe.EMlegal_memb_op (msg,
                                                                    EM_RNM,
                                                                    &loc_memb),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    
        /*
         * Attempt to get an object by the new name.
         */
        om_msg = om$send(msg = message EMdescribe.EMget_memb (msg, 
                                                              memb->name,
                                                              EM_MEMBER_TYPES,
                                                              0,
                                                              NULL),
                         targetid = my_id);
    
        /*
         * If object by that name already exists return an error.
         */
        if (om_msg & *msg & 1)
        {
            *msg = ASM_E_MEMBEXISTS;
            goto quit;
        }

        /*
         * Reset the return codes.
         */
        *msg = ASM_S_SUCCESS;
        om_msg = OM_S_SUCCESS;
            
        /*
         * Change the name.
         */
        di$untranslate (objid = my_id,
                        osnum = OM_Gw_current_OS,
                        objname = my_name);
        
        sprintf (old_name, "%s:%s", my_name, loc_memb.name);
        sprintf (new_name, "%s:%s", my_name, memb->name);

        old_system_mode = EMdesc_set_system_mode(TRUE);
        di$rename (oldname = old_name, newname = new_name);
        EMdesc_set_system_mode(old_system_mode);
    }    

    /*
     * If the description or type has changed ...
     */
    if (strcmp(memb->desc, loc_memb.desc) || (memb->type != loc_memb.type))
    {
        memb->index = loc_memb.index;
        
        /*
         * Update up the type/description.
         */
        om_msg = om$send (msg = message EMdescribe.EMmod_memb_info (msg, memb),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }

    /*
     * Return the id and index.
     */
    memb->id.objid = loc_memb.id.objid;
    memb->id.osnum = loc_memb.id.osnum;
    memb->index    = loc_memb.index;


quit:

    return (om_msg);    
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMrem_memb                                                        |
 |                                                                           |
 | This method removes a member by name or index.                            |
 |                                                                           |
 | Input:   IGRchar     * name        Name of member, NULL if by index.      |
 |          IGRint        type        Types to consider, not used with name. |
 |          IGRint        index       Index of the member.                   | 
 |                                                                           |
 | Output:  IGRlong *     msg         Return code                            |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           | 
 +---------------------------------------------------------------------------*/
method EMrem_memb  ( IGRlong *  msg;
                     IGRchar *  name;
                     IGRint     type;
                     IGRint     index )
{
    IGRlong         om_msg = OM_S_SUCCESS, ok;
    DIint           status = DIR_S_SUCCESS;
    EMmemb          memb;

    /*
     * Get the member.
     */
    om_msg = om$send(msg = message EMdescribe.EMget_memb (msg,
                                                          name,
                                                          type,
                                                          index,
                                                          &memb),
                     targetid = my_id );

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * Remove it from directory.
     */
    om_msg = om$send (msg = message IGRdir.remove (&status, 
                                                   NULL, 
                                                   memb.index),
                      targetid = my_id);        
        
    if (!(om_msg & status & 1) || (status == DIR_W_NAME_NOT_FOUND))
    {
        *msg = ASM_E_ABORT;
    }


    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*  
     * If the member was an attribute delete it.
     */
    if (memb.type & EM_ATTRIBUTE_MEMBERS)
    {
        struct GRmd_env mod_env;
            
        gr$get_module_env (buffer = &mod_env);

        mod_env.md_id.osnum = OM_Gw_current_OS;

        /*
         * Delete the expression object.
         */
        om$send(msg = message GRgraphics.GRdelete (&ok, &mod_env),
                targetid = memb.id.objid,
                targetos = memb.id.osnum);
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMget_unique_name                                                |
 |                                                                           |
 | This method returns a unique name for an object being added.              |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |          IGRchar *   basename    Base name for the instance.              |
 |          IGRchar *   name        Name for the instance.                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_unique_name (IGRlong *msg; IGRchar* basename; IGRchar *name)
{
    IGRlong om_msg;
    IGRint  i;
    IGRchar * bnp;
    
    *msg = ASM_S_SUCCESS;
    
    if (!basename)
    {
        bnp = "obj";
    }
    else
    {
        bnp = basename;
    }

    for (i=1; i<10000; ++i)
    {
        sprintf (name, "%s%d", bnp, i);
        
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg,
                                                               name,
                                                               EM_MEMBER_TYPES,
                                                               0,
                                                               NULL),
                          targetid = my_id);

        if (!(om_msg & *msg & 1))
        {
            om_msg = OM_S_SUCCESS;
            *msg = ASM_S_SUCCESS;
            break;
        }
    }

    if (i == 10000)
    {
        *msg = ASM_E_ABORT;
    }

    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Method: EMadd_memb_info                                           |
 |                                                                           |
 | This method add member info.                                              |
 |                                                                           |
 | Input:   EMmemb  * memb   Member info to add.                             |
 |                                                                           |
 | Output:  IGRlong * msg    Return code                                     |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           | 
 +---------------------------------------------------------------------------*/
method EMadd_memb_info (IGRlong * msg;
                        EMmemb  * memb)
{
    IGRlong om_msg;
    IGRint  count = om$dimension_of (varray = me->info);
    IGRint  buffer_size, size;

    *msg = ASM_S_SUCCESS;

    /*
     * Make sure it's ok to add this member.
     */
    om_msg = om$send (msg = message EMdescribe.EMlegal_memb_op (msg,
                                                                EM_ADD,
                                                                memb),
                      targetid = my_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * Add an empty entry in the info array.
     */
    om_msg = om$vla_set_dimension (varray = me->info, size = count + 1);
        
    if (!(om_msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    me->info[count].type = memb->type;

    size = strlen (memb->desc) + 1;
    buffer_size = om$dimension_of(varray = me->descs);

    om_msg = om$vla_set_dimension(varray = me->descs,
                                  size = buffer_size + size);
        
    if (!(om_msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
        
    OM_BLOCK_MOVE (memb->desc, &(me->descs[buffer_size]), size);
    me->info[count].desc_index = buffer_size;

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Method: EMmod_memb_info                                           |
 |                                                                           |
 | This method modifies member info by absolute index.                       |
 |                                                                           |
 | Input:   EMmemb  * memb   Member to modify.                               |
 |                                                                           |
 | Output:  IGRlong * msg    Return code                                     |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           | 
 +---------------------------------------------------------------------------*/
method EMmod_memb_info (IGRlong * msg;
                        EMmemb  * memb)
{
    IGRlong   om_msg = OM_S_SUCCESS;
    IGRint    count = om$dimension_of (varray = me->info);
    IGRint    size, new_len, len, diff, i;
    IGRchar * old_desc;
    
    *msg = ASM_S_SUCCESS;
    
    /*
     * Make sure it's ok to modify this member.
     */
    om_msg = om$send (msg = message EMdescribe.EMlegal_memb_op (msg,
                                                                EM_MOD,
                                                                memb),
                      targetid = my_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    if ((memb->index < 0) || (memb->index >= count))
    {
        *msg = ASM_E_INVINDEX;
        goto quit;
    }

    /*
     * If the description has changed ...
     */
    if (strcmp(memb->desc, 
               old_desc = &(me->descs[me->info[memb->index].desc_index])))
    {
        /*
         * Update up the description.
         */
        new_len = strlen(memb->desc) + 1;
        len = strlen(old_desc) + 1;
        diff = new_len - len;
        size = om$dimension_of (varray = me->descs);

        /*
         * If the array is getting bigger increase the
         * size now ...
         */
        if (diff > 0)
        {
            om_msg = om$vla_set_dimension (varray = me->descs,
                                           size = size + diff);
            
            if (!(om_msg & 1))
            {
                *msg = ASM_E_ABORT;
                goto quit;
            }
        }
                    
        OM_BLOCK_MOVE (&me->descs[me->info[memb->index].desc_index + len],
                       &me->descs[me->info[memb->index].desc_index + len + diff],
                       size - me->info[memb->index].desc_index - len);
        
        strcpy (&me->descs[me->info[memb->index].desc_index], memb->desc);
                     
        /*
         * If the array is getting smaller decrease the
         * size now ...
         */
        if (diff < 0)
        {
            om_msg = om$vla_set_dimension (varray = me->descs,
                                           size = size + diff);
            if (!(om_msg & 1))
            {
                *msg = ASM_E_ABORT;
                goto quit;
            }
        }
                    
        /*
         * Fix up the desc index array ...
         */
        for (i = memb->index + 1; i < count; ++i)
        {
            me->info[i].desc_index += diff;
        }
    }    

    /*
     * If the type has changed ..
     */
    if (memb->type != me->info[memb->index].type)
    {
        /*
         * Everything ok ... change the type.
         */
        me->info[memb->index].type = memb->type;
    }

 quit:
    
    return om_msg;
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Method: EMrem_memb_info                                           |
 |                                                                           |
 | This method removes member info by absolute index.                        |
 |                                                                           |
 | Input:   EMmemb  *     memb        Member to remove.                      |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code                            |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           | 
 +---------------------------------------------------------------------------*/
method EMrem_memb_info (IGRlong *  msg;
                        EMmemb  *  memb)
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          count = om$dimension_of (varray = me->info);
    IGRint          i, buffer_size;
    IGRint          desc_index, desc_size;

    *msg = ASM_S_SUCCESS;
    
    if ((memb->index < 0) || (memb->index >= count))
    {
        *msg = ASM_E_INVINDEX;
        goto quit;
    }
    
    /*
     * Fix up the member type array ...
     */
    for (i = memb->index; i < count - 1; ++i)
    {
        me->info[i].type = me->info[i+1].type;
    }

    desc_index  = me->info[memb->index].desc_index;
    desc_size = strlen(&(me->descs[desc_index])) + 1;
    buffer_size = om$dimension_of(varray = me->descs);

    /*
     * If this isn't the last entry in the describe list ...
     */
    if (memb->index < count - 1)
    {
        IGRlong amount;
        
        /*
         * Fix up the member description array ...
         */
        if ((amount = buffer_size - desc_index - desc_size) > 0)
        {
            OM_BLOCK_MOVE (&me->descs[desc_index + desc_size],
                           &me->descs[desc_index],
                           amount);
        }
    }
        
    /*
     * Reduce the size of the descriptions buffer.
     */
    om_msg = om$vla_set_dimension (varray = me->descs,
                                   size = buffer_size - desc_size );

    if (!(om_msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Fix up the attribute description index info ...
     */
    for (i = memb->index; i < count - 1; ++i)
    {
        me->info[i].desc_index = me->info[i+1].desc_index - desc_size;
    }

    /*
     * Reduce the size of the info vla.
     */ 
    om_msg = om$vla_set_dimension (varray = me->info, 
                                   size = count - 1);
    
    if (!(om_msg & 1))
    {
        *msg = ASM_E_ABORT;
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMget_memb_type                                                  |
 |                                                                           |
 | This method returns the type of member that this object will be.          |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |          IGRint  *   type        Type of member.                          |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_memb_type (IGRlong *msg; IGRint * type)
{
    *msg = ASM_S_SUCCESS;
    *type = EM_DESCRIBE;
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMdefault_memb_type                                              |
 |                                                                           |
 | This message returns a default type for the input member id.              |
 |                                                                           |
 | Input:   struct GRid * memb_id  Id of member.                             |
 |                                                                           |
 | Output:  IGRlong     * msg      Return code                               |
 |          IGRint      * type     Type of member.                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMdefault_memb_type (IGRlong     * msg; 
                            struct GRid * memb_id; 
                            IGRint      * type)
{
    IGRlong om_msg = OM_S_SUCCESS;
    OMuword classid = 0;

    *msg = ASM_S_SUCCESS;
    
    om_msg = om$get_classid (objid = memb_id->objid,
                             osnum = memb_id->osnum,
                             p_classid = &classid);
    if (!(om_msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    if (om$is_ancestry_valid (superclassid = OPP_expression_class_id,   
                              subclassid = classid) == OM_S_SUCCESS)
    {
        *type = EM_ATTRIBUTE;
    }
    else if (om$is_ancestry_valid (superclassid = OPP_EMdescribe_class_id,   
                                   subclassid = classid) == OM_S_SUCCESS)
    {   
        om_msg = om$send (msg = message EMdescribe.EMget_memb_type (msg, type),
                          targetid = memb_id->objid,
                          targetos = memb_id->osnum);
    }
    else if (om$is_ancestry_valid (superclassid = OPP_GRgraphics_class_id,
                                   subclassid = classid) == OM_S_SUCCESS)
    {
        *type = EM_GRAPHIC;
    }
    else /* Not a valid member. */
    {
        *msg = ASM_E_ABORT;
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMlegal_memb_op                                                  |
 |                                                                           |
 | This method determines whether it's legal to perform the specified        |
 | operation on the member.                                                  |
 |                                                                           |
 | Input:   IGRint      operation   EM_ADD, EM_MOD, or EM_REM.               |
 |          EMmemb      memb        Member.                                  |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved attribute.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMlegal_memb_op (IGRlong *msg; IGRint operation; EMmemb * memb)
{
    *msg = ASM_S_SUCCESS;
    return OM_S_SUCCESS;
}

end implementation EMdescribe;



