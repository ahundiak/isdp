/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <grownerdef.h>
#include <DIprims.h>
#include <partdef.h>

/*
 * Method :
 *
 *      GRconstruct
 *
 * Abstract : 
 *
 *      This method constructs a part.
 *
 * Arguments :
 *
 *      *arglist     GRvg_construct construct arguments
 * 
 * Return Values :
 *
 *      The return code in the input argument list can have the 
 *      following values:
 *
 *      MSSUCC - successful
 *      MSFAIL - if failure
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation date.
 *      Jamal Shakra        08/13/91  Modification date.
 *
 */
method GRconstruct ( struct GRvg_construct * arglist )
{
    IGRlong                     om_msg = OM_S_SUCCESS;
    struct GRpart_class_attr *  part_attr;
    IGRchar                     partname[DI_PATH_MAX], partdir[DI_PATH_MAX];
    struct GRid                 part, template;
    IGRint                      i;
    IGRlong                     msg = MSSUCC;
    IGRint                      found = FALSE, template_found = FALSE;
    IGRchar                     value[MAX_VALUE];
    IGRchar                     number[MAX_VALUE];
            
    *(arglist->msg) = MSSUCC;
    
    part.objid = my_id;
    part.osnum = OM_Gw_current_OS;

    part_attr = (struct GRpart_class_attr *)arglist->class_attr;
    arglist->class_attr = NULL;

    me->properties = arglist->properties | GRIS_NEW;

    /*
     * Make the part directory.
     */       
    if (part_attr->number)
       {
        strcpy(number,part_attr->number);
       }

    else
       {
        strcpy(number,part_attr->value[0]);
       } 


    if ( GRpart_make_partdir ( arglist->env_info,
                               part_attr->parts_dir,
                               part_attr->catalog,
                               number,
                               part_attr->revision,
                               partdir ) )
    {
        /*
         * Try to find another part of this type to use as
         * a template.
         */
        template_found =  ( di$index ( dirname = partdir,
                                       index = 0,
                                       p_objid = &template.objid,
                                       p_osnum = &template.osnum ) 
                            == DIR_S_SUCCESS );
        /*
         * Get a unique part name in the part directory.
         */
        GRpart_get_partname ( partdir, partname );

        /*
         * Initialize the part.
         */
        om_msg = om$send ( msg = message ACdiowner.ACcreate ( arglist->msg, 
                                                              partname ),
                           targetid = my_id );
        
        if (om_msg & *(arglist->msg) & 1)
        {
            /* 
             * If a catalog was specified, add it.
             */
             if (part_attr->catalog)
                {
                 om_msg = om$send ( msg = message GRpart.GRadd_attribute
                                      ( arglist->msg,
                                        CATALOG_NAME,
                                        part_attr->catalog,
                                        GR_STATIC_ATTR ),
                                        targetid = my_id );
                }

            /* 
             * If a revision was specified, add it.
             */
             if (part_attr->revision)
                {
                 om_msg = om$send ( msg = message GRpart.GRadd_attribute
                                      ( arglist->msg,
                                        REVISION_NAME,
                                        part_attr->revision,
                                        GR_STATIC_ATTR ),
                                        targetid = my_id );
                }

            /* 
             * If a number was specified, add it.
             */
             if (part_attr->number)
                {
                 om_msg = om$send ( msg = message GRpart.GRadd_attribute
                                      ( arglist->msg,
                                        NUMBER_NAME,
                                        part_attr->number,
                                        GR_STATIC_ATTR ),
                                        targetid = my_id );
                }

            /* 
             * If a description was specified, add it.
             */
             if (part_attr->description)
                {
                 om_msg = om$send ( msg = message GRpart.GRadd_attribute
                                      ( arglist->msg,
                                        DESCRIPTION_NAME,
                                        part_attr->description,
                                        GR_STATIC_ATTR ),
                                        targetid = my_id );
                }

            /*
             * If a template was found ...
             */ 
            if ( template_found )
            {
                /*
                 * Copy the template's common attributes to myself.
                 */
                om_msg = om$send ( msg = message GRpart.GRcopy_attributes 
                                                    ( arglist->msg, 
                                                      &template,
                                                      GR_COMMON_ATTR ),
                                   targetid = my_id );
            }

            /*
             * If everything is ok ...
             */
            if (om_msg & *(arglist->msg) & 1)
            {
                /*
                 * Add/update the new attributes ...
                 */
                for (i=0; i<part_attr->num; ++i)
                {
                    value[0] = '\0';
                    
                    /*
                     * If there is a template and this is a common attribute...
                     */
                    if (template_found && (part_attr->type[i] & GR_COMMON_ATTR))
                    {
                        /*
                         * See if the template already had this attribute.  
                         */
                        om_msg = om$send ( msg = message
                                           GRpart.GRget_attribute
                                                    ( arglist->msg,
                                                      part_attr->attr[i],
                                                      NULL,
                                                      value,
                                                      NULL ),
                                           targetid = my_id );

                        found =  (om_msg & *arglist->msg & 1);
                    }
                    else found = FALSE;

                    /*
                     * If the attribute already existed ...
                     */
                    if (found)
                    {
                        /*
                         * And the attribute value has changed ...
                         */
                        if (strcmp(part_attr->value[i], value))
                        {
                            /*
                             * Modify it.
                             */
                            om_msg = om$send ( msg = message ACdiowner.ACmod_attribute
                                                      ( arglist->msg,
                                                        part_attr->attr[i],
                                                        part_attr->value[i] ),
                                               targetid = my_id );

                            if (!(om_msg & *arglist->msg & 1)) break;
                        }
                    }
                    else 
                    {
                        /*
                         * Add it.
                         */
                        om_msg = om$send ( msg = message GRpart.GRadd_attribute
                                                      ( arglist->msg,
                                                        part_attr->attr[i],
                                                        part_attr->value[i],
                                                        part_attr->type[i] ),
                                           targetid = my_id );

                        if (!(om_msg & *arglist->msg & 1)) break;
                    }
                }
            }
        }

        /*
         * If anything failed delete the part.
         */
        if (!(om_msg & *(arglist->msg) & 1))
        {
            om$send ( msg = message GRgraphics.GRdelete ( &msg, 
                                                          arglist->env_info ),
                      targetid = my_id );
        }
        else
        {
            om$send ( msg = message GRowner.GRadd_to_active_owner 
                                                        ( &msg,
                                                          arglist->env_info ),
                      targetid = my_id );

            /*
             * If the part has an alternate name, add it.
             */
            if (arglist->name && (arglist->name[0] != '\0'))
            {
                om_msg = om$send ( msg = message GRvg.GRputname
                                                        ( &msg,   
                                                          arglist->name ),
                                   targetid = my_id );
            }
        }
    }

    return(om_msg);
}

end implementation GRpart;
