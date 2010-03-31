class implementation EMcachepart;

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

from GRreffile import GRchgfilename;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMnum_attrs                                                     |
 |                                                                           |
 | This method returns the total number of attributes.                       |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  9/3/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMnum_attrs    ( IGRlong *  msg;
                        IGRint     type;
                        IGRint  *  num_attrs )
{
    IGRlong     om_msg = OM_S_SUCCESS;
 
    *msg = ASM_S_SUCCESS;

    type &= EM_ATTRIBUTE_MEMBERS;

    om_msg = om$send (msg = message EMdescribe.EMnum_attrs (msg, 
                                                            type,
                                                            num_attrs),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    if (EM_IS_REFERENCE_PART(me->props))
    {
        IGRint      count;
        struct GRid fp_id;

        om_msg = om$send (msg = message EMcachepart.EMget_definition (msg,
                                                                      &fp_id),
                          targetid = my_id);

        if (om_msg & *msg & 1)
        {
            om_msg = om$send (msg = message EMdescribe.EMnum_attrs (msg,
                                                                    type,
                                                                    &count),
                              targetid = fp_id.objid,
                              targetos = fp_id.osnum);

            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }

            *num_attrs += count - 2;
        }
        else
        {
            om_msg = OM_S_SUCCESS;
            *msg = ASM_S_SUCCESS;
        }
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMget_attr                                                      |
 |                                                                           |
 | This method returns an attribute on the part by name or index.            |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/18/93     creation                                     |
 | dkk              7/20/94     modified such that the super_class method is |
 |                              used for sys attrs                           |
 +---------------------------------------------------------------------------*/
method EMget_attr     ( IGRlong *  msg;
                        IGRchar *  name;
                        IGRint     type;
                        IGRint     index;
                        EMattr  *  attr )
{
    IGRint      om_msg = OM_S_SUCCESS;
    struct GRid def_id;

    /*
     * If this isn't a reference part ...
     */
    if (!EM_IS_REFERENCE_PART(me->props))
    {

        /*
         * Get the attribute in the normal manner.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                               name,
                                                               type,
                                                               index,
                                                               attr),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

    }
    else /* Reference part. */
    {
        IGRint      count;
	
        /* For system attributes, get from the local cache itself */
	if (name && (!strcmp(name, "itemno") ||
		    !strcmp(name, "number") ||
		    !strcmp(name, "revision") ||
                    !strcmp(name, "filename")))
	{
	    /*
             * Get the attribute in the normal manner.
             */
            om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                               name,
                                                               type,
                                                               index,
                                                               attr),
                          mode = OM_e_wrt_message,
                          targetid = my_id);

            goto quit;
        }        
        /*
         * Get the file part which serves as the part definition.
         */
        om_msg = om$send (msg = message EMcachepart.EMget_definition (msg,
                                                                      &def_id),
                          targetid = my_id);
    
        /*
         * If the file part isn't available ...
         */
        if (!(om_msg & *msg & 1))
        {
            /*
             * Try to get the attribute on myself.
             */
            om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                                   name,
                                                                   type,
                                                                   index,
                                                                   attr),
                              mode = OM_e_wrt_message,
                              targetid = my_id);
        }
        else /* File part found. */
        {
            /*
             * Get the attribute from the file part.
             */
            om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                                   name,
                                                                   type,
                                                                   index,
                                                                   attr),
                              targetid = def_id.objid,
                              targetos = def_id.osnum);
            
            /*
             * If the attribute wasn't on the file part ...
             */
            if (!(om_msg & *msg & 1))
            {
                /*
                 * If an index is being used to locate the attribute ...
                 */
                if (!name)
                {
                    /*
                     * Determine what the relative index is for the 
                     * cached part.
                     */
                    om_msg = om$send (msg = message EMdescribe.EMnum_attrs 
                                                         (msg,
                                                          type,
                                                          &count),
                                      targetid = def_id.objid,
                                      targetos = def_id.osnum);
                    if (!(om_msg & *msg & 1))
                    {
                        goto quit;
                    }

                    /*
                     * Don't include the number and revision which are cached
                     * in slot 0 and 1.
                     */
                    index = index - count + 2;
                }

                /*
                 * Try to get the attribute on myself.
                 */
                om_msg = om$send (msg = message EMdescribe.EMget_attr (msg,
                                                                       name,
                                                                       type,
                                                                       index,
                                                                       attr),
                                  mode = OM_e_wrt_message,
                                  targetid = my_id);
            }
        }
    }

 quit:

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMadd_attr                                                      |
 |                                                                           |
 | This method only allows attributes to be added to reference parts in the  |
 | system mode.                                                              |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMadd_attr     ( IGRlong     *  msg;
                        EMattr      *  attr )
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    /*
     * Don't allow addition of attributes to reference part if
     * not in system mode.
     */
    if (EM_IS_REFERENCE_PART(me->props) && !EMdesc_get_system_mode())
    {
        *msg = ASM_E_ILLEGALOP;
    }
    else
    {
        *msg = ASM_S_SUCCESS;
    
        om_msg = om$send (msg = message EMdescribe.EMadd_attr (msg, attr),
                          mode = OM_e_wrt_message,
                          targetid = my_id);
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMrem_attr                                                      |
 |                                                                           |
 | This method doesn't allow attributes to be removed.                       |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           | 
 +---------------------------------------------------------------------------*/
method EMrem_attr     ( IGRlong *  msg;
                        IGRchar *  name;
                        IGRint     type;
                        IGRint     index )
{
    IGRlong om_msg;
    
    if (EMdesc_get_system_mode())
    {
        om_msg = om$send (msg = message EMdescribe.EMrem_attr(msg,
                                                              name,
                                                              type,
                                                              index),
                          mode = OM_e_wrt_message,
                          targetid = my_id);
    }
    else
    {
        *msg = ASM_E_ILLEGALOP;
    }
    
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMmod_attr                                                      |
 |                                                                           |
 | This method modifies an attribute on the part by name or index.           |
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
    EMattr      loc_attr;
    IGRboolean  rollback = FALSE;

    /*
     * Store the attribute so we can rollback changes if it
     * was unsuccessfull.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_attr(msg,
                                                          name,
                                                          type,
                                                          index,
                                                          &loc_attr),
                      targetid = my_id);
    
    /*
     * If we got the attribute ...
     */
    if (om_msg & *msg & 1)
    {
        /*
         * If this is a graphic part go ahead and modify the
         * attribute.
         */
        if (!EM_IS_REFERENCE_PART(me->props))
        {
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
        }
        else /* Reference part. */
        {
            /* 
             * Only allow common attributes to be modified for now.
             * And do not check for OS - RFA + ASsembly and use the index and
             * the name coming in.
            if (loc_attr.info.id.osnum == OM_Gw_current_OS)
             */
            {
                om_msg = om$send (msg = message EMdescribe.EMmod_attr 
                                                         (msg,
                                                          //loc_attr.info.name,
                                                          name,      
                                                          type,
                                                          //0,
                                                          index,
                                                          attr),
                                  mode = OM_e_wrt_message,
                                  targetid = my_id);
                        
                if (!(om_msg & *msg & 1))
                {
                    rollback = TRUE;
                }
            }
        }

        /*
         * If the modification was successfull do any necessary post
         * processing.
         */
        if (om_msg & *msg & 1)
        {
            /* If the filename has changed have all my instance's 
             * reference files do a change filename. After 
             * a change filename has been done we need to update
             * the cached part.
             */
            if (!strcmp (attr->info.name, "filename"))
            {
                IGRint i, count;
                EMmemb memb;
                
                /*
                 * For all my instances change the reference file
                 * attachment's filename to the new filename.
                 */
                om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg,
                                                                        EM_INSTANCE,
                                                                        &count),
                                  targetid = my_id);
                
                if (!(om_msg & *msg & 1))
                {
                    rollback = TRUE;
                    goto quit;
                }

                for (i=0; i<count; ++i)
                {
                    om_msg = om$send (msg = message EMdescribe.EMget_memb 
                                                          (msg,
                                                           NULL,
                                                           EM_INSTANCE,
                                                           i,
                                                           &memb),
                                      targetid = my_id);
                    
                    if (!(om_msg & *msg & 1) && (i==0))
                    {
                        rollback = TRUE;
                        goto quit;
                    }
                    
                    om_msg = om$send (msg = message EMdescribe.EMget_memb
                                                                (msg,
                                                                 NULL,
                                                                 EM_GRAPHIC,
                                                                 0,
                                                                 &memb),
                                      targetid = memb.id.objid,
                                      targetos = memb.id.osnum);
                    
                    if (!(om_msg & *msg & 1) && (i==0))
                    {
                        rollback = TRUE;
                        goto quit;
                    }
                    
                    om_msg = om$send (msg = message GRreffile.GRchgfilename
                                                             (msg,
                                                              attr->value.syntax,
                                                              ""),
                                      targetid = memb.id.objid,
                                      targetos = memb.id.osnum);
                    
                    if (!(om_msg & *msg & 1) && (i==0))
                    {
                        rollback = TRUE;
                        goto quit;
                    }
                }

                /*
                 * Update myself according to the new reference file 
                 * information. This will propagate to each of the 
                 * instances who will update themselves.
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
    }

 quit:

    /*
     * If anything failed restore the attribute.
     */
    if (!(om_msg & *msg & 1) && (rollback == TRUE))
    {
        IGRlong ok;
        
        if (loc_attr.info.id.osnum == OM_Gw_current_OS)
        {
            om$send (msg = message EMdescribe.EMmod_attr(&ok,
                                                         name,
                                                         type,
                                                         index,
                                                         &loc_attr),
                     mode = OM_e_wrt_message,   
                     targetid = my_id);
        }
    }

    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override:  EMlegal_attr_op                                                |
 |                                                                           |
 | This method determines whether it's legal to perform the specified        |
 | operation on the attribute.                                               |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMlegal_attr_op (IGRlong *msg; IGRint operation; EMattr * attr)
{
    *msg = ASM_S_SUCCESS;

    switch (operation)
    {
    case EM_ADD:
        if (EM_IS_REFERENCE_PART(me->props) && !EMdesc_get_system_mode())
        {
            *msg = ASM_E_ILLEGALOP;
        }
        break;
        
    case EM_MOD:
        if (EM_IS_REFERENCE_PART(me->props) && !EMdesc_get_system_mode())
        {
            if (EM_IS_READONLY(me->props) &&
                strcmp(attr->info.name, "itemno") &&
                strcmp(attr->info.name, "filename"))
            {
                *msg = ASM_E_ILLEGALOP;
            }
        }
        break;
        
    case EM_REM:
        if (EM_IS_REFERENCE_PART(me->props) && !EMdesc_get_system_mode())
        {
            *msg = ASM_E_ILLEGALOP;
        }
        break;
    }

    return OM_S_SUCCESS;
}

end implementation EMcachepart;





