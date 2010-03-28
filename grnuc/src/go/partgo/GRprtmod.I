/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <OMmacros.h>
#include <DIprims.h>
#include <DImacros.h>
#include <grownerdef.h>
#include <partdef.h>
#include <expression.h>

%safe
static IGRboolean   GRpart_mod_pass = TRUE;
%endsafe

/*
 * Method :
 *
 *      GRmod_attribute
 *
 * Abstract :
 *
 *      This routine modifies part attribute values and types.
 *  
 * Arguments :
 *
 *      *msg    IGRlong     Completion code.
 *      *attr   IGRchar     Attribute to modify.
 *      *value  IGRchar     New attribute value.
 *      type    IGRint      New attribute type.
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      jay wallingford     3/9/90  Creation data.
 */
method GRmod_attribute ( IGRlong * msg;
                         IGRchar * attr;
                         IGRchar * value;
                         IGRint  * type )
{
    IGRint      om_msg = OM_S_SUCCESS;
    IGRint      index, old_type, attr_type, count, i;
    IGRchar     old_value[MAX_VALUE], partdir[DI_PATH_MAX];
    IGRchar *   catalog=NULL;
    IGRchar *   number=NULL;
    IGRchar *   revision=NULL;
    IGRboolean  is_unique_attr = FALSE;
    DIgrid      part_id;
   
    /*
     * If the new value is longer the the maximum expression syntax
     * length error out.
     */
    if (value && (strlen(value) >= EXP_MAX_LEN))
    {
        *msg = MSFAIL;
    }
    else
    {
        /* 
         * Set attribute uniqueness flag.
         */
        is_unique_attr = _is_unique_attr(attr);

        /*
         * Get the index, value and type of the attribute that is being modified.
         */
        index = -1;
        om_msg = om$send ( msg = message GRpart.GRget_attribute ( msg,
                                                                 attr,
                                                                 &index,
                                                                 old_value,
                                                                 &old_type ),
                          targetid = my_id );
    }

    /*
     * If everything is ok ...
     */
    if (om_msg & *msg & 1)
    {
        /*
         * If this is any of the unique attributes, make sure it doesn't
         * have a ':' in it.
         */
        if (is_unique_attr)
        {
            if (strchr(value,':'))
            {
                *msg = MSFAIL;
            }
        }

        if (*msg & 1)
        {
            /*
             * Get my part directory.
             */
            di$untranslate ( objid = my_id, objname = partdir );
            *((IGRchar *)strrchr(partdir,':')) = '\0';

            if (type && (*type != old_type) && is_unique_attr)
            {
                *msg = MSFAIL;
            }
            else
            {
                /*
                 * Change the type.
                 */
                if (type) me->attr_type[index] = *type;

                /*
                 * If the value has changed ...
                 */
                if ( value && strcmp(value, old_value))
                {
                    /*
                     * If the attribute is a uniqueness attribute... 
                     */
                    if ( !strcmp(attr, CATALOG_NAME) ||
                         !strcmp(attr, NUMBER_NAME)  ||
                         !strcmp(attr, REVISION_NAME) ) 
                    {
                        /*
                         * If attribute is CATALOG_NAME
                         * Get the index, value and type of the number attribute
                         */
                        if ( !strcmp(attr, CATALOG_NAME) )
                        {
                            index = -1;
                            om_msg = om$send ( msg = message GRpart.GRget_attribute 
                                                            ( msg,
                                                              NUMBER_NAME,
                                                              &index,
                                                              number,
                                                              &attr_type ),
                                     targetid = my_id );

                            /*
                             * Get the index, value and type of the revision
                             * attribute
                             */
                            index = -1;
                            om_msg = om$send ( msg = message 
                                     GRpart.GRget_attribute ( msg,
                                                              REVISION_NAME,
                                                              &index,
                                                              revision,
                                                              &attr_type ),
                                     targetid = my_id );

                            /*
                             * Change to the new part type.
                             */
                            om_msg = om$send ( msg = message GRpart.GRchg_part 
                                                            ( msg, 
                                                              value,
                                                              number,
                                                              revision ),
                                               targetid = my_id );
                        }

                        /*
                         * If attribute is NUMBER_NAME
                         * Get the index, value and type of the catalog
                         * attribute
                         */
                        if ( !strcmp(attr, NUMBER_NAME) )
                        {
                            index = -1;
                            om_msg = om$send ( msg = message 
                                     GRpart.GRget_attribute ( msg,
                                                              CATALOG_NAME,
                                                              &index,
                                                              catalog,
                                                              &attr_type ),
                                     targetid = my_id );

                            /*
                             * Get the index, value and type of the revision
                             * attribute
                             */
                            index = -1;
                            om_msg = om$send ( msg = message 
                                     GRpart.GRget_attribute ( msg,
                                                              REVISION_NAME,
                                                              &index,
                                                              revision,
                                                              &attr_type ),
                                     targetid = my_id );

                            /*
                             * Change to the new part type.
                             */
                            om_msg = om$send ( msg = message GRpart.GRchg_part 
                                                            ( msg, 
                                                              catalog,
                                                              value,
                                                              revision ),
                                               targetid = my_id );
                        }

                        /*
                         * If attribute is REVISION_NAME
                         * Get the index, value and type of the catalog
                         * attribute
                         */
                        if ( !strcmp(attr, REVISION_NAME) )
                        {
                            index = -1;
                            om_msg = om$send ( msg = message 
                                     GRpart.GRget_attribute ( msg,
                                                              CATALOG_NAME,
                                                              &index,
                                                              catalog,
                                                              &attr_type ),
                                     targetid = my_id );

                            /*
                             * Get the index, value and type of the number 
                             * attribute
                             */
                            index = -1;
                            om_msg = om$send ( msg = message 
                                     GRpart.GRget_attribute ( msg,
                                                              NUMBER_NAME,
                                                              &index,
                                                              number,
                                                              &attr_type ),
                                     targetid = my_id );

                            /*
                             * Change to the new part type.
                             */
                            om_msg = om$send ( msg = message GRpart.GRchg_part 
                                                            ( msg, 
                                                              catalog,
                                                              number,
                                                              value ),
                                           targetid = my_id );
                        }
                    }
                    else
                    {
                        /*
                         * Modify the attribute.
                         */
                        om_msg = om$send ( msg = message ACdiowner.ACmod_attribute 
                                                                        ( msg, 
                                                                          attr, 
                                                                          value ),
                                           mode = OM_e_wrt_message,
                                           targetid = my_id );
                    }
                }

                /*
                 * If the attribute is static update the other parts of this type.
                 */
                if ( (GRpart_mod_pass == TRUE)                && 
                     (me->attr_type[index] & GR_COMMON_ATTR)  && 
                     (om_msg & *msg & 1) )
                {
                    /*
                     * Get the regular expression for the pass.
                     */
                    di$strcat (to = partdir, from = "*");
                
                    /*
                     * For all the parts in my parts directory, except for my self,
                     * modify the attribute.
                     */        
                    count = 0;
                    GRpart_mod_pass = FALSE;

                    di$start_dump ( regexp = partdir, ptr = &count );
            
                    for (i=0; i<count; ++i)
                    {
                        di$fetch_dump ( index = i, p_grid = &part_id );
               
                        if (part_id.objid != my_id)
                        {
                            om_msg = om$send ( msg = message GRpart.GRmod_attribute 
                                                                       ( msg, 
                                                                         attr, 
                                                                         value,
                                                                         type ),
                                               targetid = part_id.objid );
                        }
                    }

                    GRpart_mod_pass = TRUE;
                }
            }
     
            /*
             * If something went wrong and a new type was specified ...
             */   
            if (!(om_msg & *msg & 1) && type) 
            {
                /*
                 * Change the type back to what it was.
                 */
                me->attr_type[index] = old_type;
            }
        }
    }

    return (om_msg);    
}

/*
 * Method :
 *
 *      ACmod_attribute
 *
 * Abstract :
 *
 *      This routine modifies part attribute values.
 *  
 * Arguments :
 *
 *      *msg    IGRlong     Completion code.
 *      *name   IGRchar     Part attributes.
 *      *syntax IGRchar     Value for the attribute.
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      jay wallingford     3/9/90  Creation data.
 */
method ACmod_attribute ( IGRlong *   msg;
                         IGRchar *   name;
                         IGRchar *   syntax )
{
    IGRlong             om_msg = OM_S_SUCCESS;
    DIgrid              part_id;
    IGRint              count, i, index, type;
    IGRchar             partdir[DI_PATH_MAX];
    IGRchar             value[MAX_VALUE];
    IGRboolean          is_unique_attr;
    IGRchar             *catalog = NULL, *number = NULL, *revision = NULL;

    *msg = MSSUCC;

    /* 
     * Set attribute uniqueness flag.
     */
    is_unique_attr = _is_unique_attr(name);

    /*
     * Get the index, value and type of the attribute that is being modified.
     */
    index = -1;
    om_msg = om$send ( msg = message GRpart.GRget_attribute ( msg,
                                                              name,
                                                              &index,
                                                              value,
                                                              &type ),
                       targetid = my_id );


    /*
     * If this is any of the uniqueness attributes, make sure it doesn't
     *  have a ':' in it.
     */
    if (is_unique_attr)
    {
        if (strchr(syntax,':'))
        {
            *msg = MSFAIL;
        }
    }

    if (*msg & 1)
    {
        /*
         * If the value is changing and everything is ok ...
         */
        if ((om_msg & *msg & 1) && strcmp(value, syntax))
        {
            /*
             * Get my part directory.
             */
            di$untranslate ( objid = my_id, objname = partdir );
            *((IGRchar *)strrchr(partdir,':')) = '\0';

            /*
             * If the attribute is a uniqueness attribute... 
             */
            if ( !strcmp(name, CATALOG_NAME ) ||
                 !strcmp(name, NUMBER_NAME  ) ||
                 !strcmp(name, REVISION_NAME) ) 
            {
                /*
                 * If the part number has just been modified ...
                 * Get the index, value and type of the catalog
                 * attribute
                 */
                if ( !strcmp(name, NUMBER_NAME) )
                {
                    index = -1;
                    om_msg = om$send ( msg = message 
                                   GRpart.GRget_attribute ( msg,
                                                            CATALOG_NAME,
                                                            &index,
                                                            catalog,
                                                            &type ),
                                   targetid = my_id );

                    /*
                     * Get the index, value and type of the revision
                     * attribute
                     */
                    index = -1;
                    om_msg = om$send ( msg = message 
                               GRpart.GRget_attribute ( msg,
                                                        REVISION_NAME,
                                                         &index,
                                                         revision,
                                                         &type ),
                               targetid = my_id );

                    /*
                     * Change to the new part type.
                     */
                    om_msg = om$send ( msg = message GRpart.GRchg_part 
                                                      ( msg, 
                                                        catalog,
                                                        syntax,
                                                        revision ),
                               targetid = my_id );
                }

                /*
                 * If the part revision has just been modified ...
                 * Get the index, value and type of the catalog
                 * attribute
                 */
                if ( !strcmp(name, REVISION_NAME) )
                {
                    index = -1;
                    om_msg = om$send ( msg = message 
                                   GRpart.GRget_attribute ( msg,
                                                            CATALOG_NAME,
                                                            &index,
                                                            catalog,
                                                            &type ),
                                   targetid = my_id );

                    /*
                     * Get the index, value and type of the number 
                     * attribute
                     */
                    index = -1;
                    om_msg = om$send ( msg = message 
                               GRpart.GRget_attribute ( msg,
                                                        NUMBER_NAME,
                                                         &index,
                                                         number,
                                                         &type ),
                               targetid = my_id );

                    /*
                     * Change to the new part type.
                     */
                    om_msg = om$send ( msg = message GRpart.GRchg_part 
                                                      ( msg, 
                                                        catalog,
                                                        number,
                                                        syntax ),
                               targetid = my_id );
                }

                /*
                 * If the part catalog has just been modified ...
                 * Get the index, value and type of the number 
                 * attribute
                 */
                if ( !strcmp(name, CATALOG_NAME) )
                {
                    index = -1;
                    om_msg = om$send ( msg = message 
                                   GRpart.GRget_attribute ( msg,
                                                            NUMBER_NAME,
                                                            &index,
                                                            number,
                                                            &type ),
                                   targetid = my_id );

                    /*
                     * Get the index, value and type of the revision 
                     * attribute
                     */
                    index = -1;
                    om_msg = om$send ( msg = message 
                               GRpart.GRget_attribute ( msg,
                                                        REVISION_NAME,
                                                       &index,
                                                        revision,
                                                       &type ),
                               targetid = my_id );

                    /*
                     * Change to the new part type.
                     */
                    om_msg = om$send ( msg = message GRpart.GRchg_part 
                                                      ( msg, 
                                                        syntax,
                                                        number,
                                                        revision ),
                               targetid = my_id );
                }
            }
            else
            {
                /*
                 * Modify the attribute.
                 */
                om_msg = om$send ( msg = message ACdiowner.ACmod_attribute 
                                                                   ( msg, 
                                                                     name, 
                                                                     syntax ),
                                   mode = OM_e_wrt_message,
                                   targetid = my_id );
            }

            /*
             * If the attribute is static update the other parts of this type.
             */
            if ( (GRpart_mod_pass == TRUE) && 
                 (type & GR_COMMON_ATTR)   && 
                 (om_msg & *msg & 1) )
            {
                /*
                 * Get the regular expression for the pass.
                 */
                di$strcat (to = partdir, from = "*");
            
                /*
                 * For all the parts in my parts directory, except for my self,
                 * modify the attribute.
                 */        
                count = 0;
                GRpart_mod_pass = FALSE;
            
                di$start_dump ( regexp = partdir, ptr = &count );
            
                for (i=0; i<count; ++i)
                {
                    di$fetch_dump ( index = i, p_grid = &part_id );
                    
                    if (part_id.objid != my_id)
                    {
                        om_msg = om$send ( msg = message ACdiowner.ACmod_attribute 
                                                                   ( msg, 
                                                                     name, 
                                                                     syntax ),
                                           targetid = part_id.objid );
                    }
                }

                GRpart_mod_pass = TRUE;
            }
        }
    }

    return (om_msg);
}

end implementation GRpart;

