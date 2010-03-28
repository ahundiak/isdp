/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <DIprims.h>
#include <DImacros.h>

/*  
 * Method :
 *
 *      ACrem_attribute
 *
 * Abstract :
 *
 *      This method removes attributes for a part.
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *
 */
method ACrem_attribute ( IGRlong * msg; IGRchar * name )
{
    IGRint          om_msg = OM_S_SUCCESS;
    DIgrid          part_id;
    IGRint          i, count, type;
    IGRchar         regexp[DI_PATH_MAX];
    
    *msg = MSFAIL;
    
    /*
     * Get the attribute's type.
     */
    om_msg = om$send ( msg = message GRpart.GRget_attribute ( msg,
                                                              name,
                                                              NULL,
                                                              NULL,
                                                              &type ),
                       targetid = my_id );
                       
    /*
     * If this attribute is not the part number or description...
     */
    if (om_msg & *msg & 1)
    {
        if ( strcmp(name, &me->attr_name[me->attr_def[0].name]) &&
             strcmp(name, &me->attr_name[me->attr_def[1].name]) )
        {
            om_msg = om$send ( msg = message ACdiowner.ACrem_attribute ( msg,
                                                                         name ),
                               mode = OM_e_wrt_message,
                               targetid = my_id );

            if ((type & GR_COMMON_ATTR) && (om_msg & *msg & 1))
            {
                /*
                 * Get a regular expression for all the parts in my 
                 * parts directory.
                 */
                di$untranslate ( objid = my_id, objname = regexp );
                *((IGRchar *)strrchr(regexp,':')) = '\0';
                di$strcat (to = regexp, from = "*");

                /*
                 * For all the parts in my parts directory, except for myself,
                 * remove the attribute.
                 */        
                di$start_dump ( regexp = regexp, ptr = &count );
        
                for (i=0; i<count; ++i)
                {
                    di$fetch_dump ( index = i, p_grid = &part_id );
            
                    if (part_id.objid != my_id)
                    {
                        om_msg = om$send ( msg = message ACdiowner.ACrem_attribute 
                                                                ( msg, name ),
                                           mode = OM_e_wrt_message,
                                           targetid = part_id.objid );
                    }
                }
            }
        }
        else *msg = MSFAIL;
    }

    
    return(om_msg);
}
    
/*  
 * Method :
 *
 *      ACrem_att_at_index
 *
 * Abstract :
 *
 *      This method adjust the part's instance data on removal of an
 *      attribute.
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *
 */
method ACrem_att_at_index ( IGRlong * msg; IGRint index )
{
    IGRint  om_msg = OM_S_SUCCESS;
    IGRint  i;
    
    om_msg = om$send ( msg = message ACdiowner.ACrem_att_at_index (msg, index),
                       mode = OM_e_wrt_message,
                       targetid = my_id );
                       
    if (om_msg & *msg & 1)
    {
        for (i=index; i<me->nb_attr; ++i)
        {
            me->attr_type[i] = me->attr_type[i+1];
        }
    }
    
    return ( om_msg );
}

end implementation GRpart;
