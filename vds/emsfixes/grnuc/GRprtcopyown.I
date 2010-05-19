/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <DIprims.h>

#include <msdef.h>
#include <msmacros.h>
#include <partdef.h>

/*
 * Method :
 *
 *      GRcopy_owner
 *
 * Abstract :
 *
 *      This method copies a part and part attributes but not the graphics
 *      to the object space described in the structure new_dsenv. 
 *
 * Arguments :
 *
 *      *obj_dsenv  GRmd_env      struct describing object's environment
 *      *new_dsenv  GRmd_env      struct describing copy's environment
 *      msg         IGRlong       completion code
 *      *newobjid   GRobjid       objid of the copied object
 *
 * Return Values :
 * 
 *  	MSSUCC if successful
 *	MSFAIL (severe) if failure
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *
 */
method GRcopy_owner ( IGRlong *msg; 
                      struct GRmd_env *obj_dsenv;
                      struct GRmd_env *new_dsenv; 
                      GRobjid *newobjid )
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRid         part, new_part, * template = NULL, grid;
    IGRchar             partdir[DI_PATH_MAX], partname[DI_PATH_MAX]; 
    IGRint              types;

    *msg = MSSUCC;

    part.objid = my_id;
    part.osnum = OM_Gw_current_OS;

    /*
     * Copy myself.
     */
    om_msg = om$send ( msg = message GRowner.GRcopy_owner ( msg,
                                                            obj_dsenv,
                                                            new_dsenv,
                                                            newobjid ),
                       mode = OM_e_wrt_message,
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        new_part.osnum = new_dsenv->md_id.osnum;
        new_part.objid = *newobjid;

        /*
         * Get my name.
         */
        om_msg = di$untranslate ( objid = my_id,
                                  objname = partdir );
                       
        if ( om_msg == DIR_S_SUCCESS )
        {
            /*
             * Get my part directory.
             */
            *((IGRchar *)strrchr(partdir,':')) = '\0';
        } 
        else *msg = MSFAIL;

        if ( om_msg & *msg & 1 )
        {
            /*
             * If the new part is in a different object space construct
             * an appropriate part directory for the new object space.
             */
            if ( obj_dsenv->md_id.osnum != new_dsenv->md_id.osnum )
            {
                IGRchar buffer[DI_PATH_MAX];

                /*
                 * Create a part directory in the other object
                 * space if it doesn't exist.
                 */
                strcpy(buffer, partdir);
                GRpart_copy_partdir ( obj_dsenv->md_id.osnum, 
                                      buffer,
                                      new_dsenv->md_id.osnum,
                                      partdir );

                /*
                 * Try to find a template to use
                 */
                *msg = ( di$index ( dirname = partdir,
                                    index = 0,
                                    p_objid = &grid.objid,
                                    p_osnum = &grid.osnum )
                         == DIR_S_SUCCESS );

                if (*msg & 1)
                {
                    template = &grid;
                }
                else *msg = MSSUCC;
            }
            else template = &part;

            /*
             * If everything is ok ...
             */
            if (om_msg & *msg & 1)
            {
                /*  
                 * Get a unique name for the new part.
                 */
                GRpart_get_partname ( partdir, partname );

                /*
                 * Initialize the new part.
                 */
                om_msg = om$send ( msg = message ACdiowner.ACcreate 
                                                    ( msg, partname ),
                                   targetid = new_part.objid,
                                   targetos = new_part.osnum);

                /*
                 * If there is a template ...
                 */
                if (template && (om_msg & *msg & 1))
                {
                    types = (template == &part) ? 
                            (GR_COMMON_ATTR | GR_DYNAMIC_ATTR) : GR_COMMON_ATTR;
                            
                    /*
                     * Add all template's attributes to the new part.
                     */
                    om_msg = om$send ( msg = message GRpart.GRcopy_attributes 
                                                                  ( msg, 
                                                                    template,
                                                                    types ),
                                       targetid = new_part.objid,
                                       targetos = new_part.osnum );
                }
                    
                /*
                 * If the copy is in a different object space ...
                 */
                if ( (new_part.osnum != OM_Gw_current_OS) &&
                     (om_msg & *msg & 1) )
                {
                    /*
                     * Update the new part's attributes with my attributes,
                     * and add any attributes that do not exist on the 
                     * new part.
                     */
                    om_msg = om$send ( msg = message GRpart.GRcopy_attributes
                                          ( msg, 
                                            &part,
                                            GR_COMMON_ATTR | GR_DYNAMIC_ATTR ),
                                       targetid = new_part.objid,
                                       targetos = new_part.osnum );
                }
            }
        }
        
        /*
         * If something failed delete the new part.
         */
        if ( !(om_msg & *msg & 1) )
        {
            om$send ( msg = message GRgraphics.GRdelete (msg, new_dsenv),
                      targetid = *newobjid,
                      targetos = new_dsenv->md_id.osnum );
        }
    }

    return (om_msg);
}

/*
 * Method : 
 *
 *      GRcopy_attributes
 *
 * Abstract :
 *
 *      This function copies template attributes to this part.
 *
 * Arguments :
 *
 *      *msg        IGRlong         Completion code.
 *      *part       struct GRid     Part to copy the attributes from.
 *       types      IGRint          Types of attributes to copy.
 *
 * Notes :
 *
 * Return Values :
 *
 *      MSSUCC - success
 *      MSFAIL - failure
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *
 */
method GRcopy_attributes ( IGRlong * msg; struct GRid * part; IGRint types )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          i, count, type, old_type, new_part, modify;
    IGRchar         attr[MAX_ATTR], value[MAX_VALUE];
    IGRchar         old_value[MAX_VALUE];
    IGRshort        state = MS_ON;
    IGRlong	    ok; 

    *msg = MSSUCC;

    /*
     * KLUDGE: Turn off the display of messages during the copy. This
     *         is done to avoid the ugly error messages that the expression
     *         object puts out during the ACadd_attribute method.
     *
     */
    ms$onoff ( msg = &ok, prevstate = &state, type = MS_OFF );

    /*
     * Set a flag if this is an uninitialized part.
     */
    new_part = (me->nb_attr == 0);
    
    /*
     * Get the number of attributes from the part that is being copied to.
     */
    count = 0;
    om_msg = om$send ( msg = message GRpart.GRnum_attributes (msg, &count),
                       targetid = part->objid,
                       targetos = part->osnum );

    /*
     * For all of the the part's attributes ...
     */
    for (i=0; i<count; ++i)
    {
        attr[0] = '\0';
           
        /*
         * Get the attribute information from the part.
         */
        om_msg = om$send ( msg = message GRpart.GRget_attribute ( msg,
                                                                  attr,
                                                                  &i,
                                                                  value,
                                                                  &type ),
                           targetid = part->objid,
                           targetos = part->osnum );
                                  
        if ((om_msg & *msg & 1) && (type & types))
        {
            if (!new_part)
            {
                /*
                 * See if the attribute already exists.
                 */
                om_msg = om$send ( msg = message GRpart.GRget_attribute 
                                                                ( msg,
                                                                  attr,
                                                                  NULL,
                                                                  old_value,
                                                                  &old_type ),
                                   targetid = my_id );
                modify = (om_msg & *msg & 1);
            }
            else modify = 0;

            if (modify)
            {
                /*
                 * If either a static attribute has changed or the type
                 * has changed ...
                 */
                if ((strcmp(value, old_value) && (type & GR_COMMON_ATTR)) || 
                    (old_type != type))
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
/**
                    om_msg = om$send ( msg = message GRpart.GRmod_attribute
                                                                ( msg, 
                                                                  attr, 
                                                                  value,
                                                                  &type ),
                                       targetid = my_id );
 **/
                }
            }
            else 
            {
                /*
                 * Add the attribute to the myself.
                 */
                om_msg = om$send ( msg = message ACdiowner.ACadd_attribute_by_type
                                                    ( msg, 
						      _is_unique_attr(attr)?AC_ATTRIB_TEXT:AC_ATTRIB_TYPE_NOT_DEF,
						      attr, value ),
                                   targetid = my_id );
   
                /*
                 * Update the type.
                 */
                me->attr_type[me->nb_attr - 1] = type;
            }
        }

        if (!(om_msg & *msg & 1)) break;
    }

    /*
     * KLUDGE: Turn off the display of messages during the copy. This
     *         is done to avoid the ugly error messages that the expression
     *         object puts out during the ACadd_attribute method.
     *
     */
    ms$onoff ( msg = &ok, prevstate = &state, type = MS_ON );

    return(om_msg);                                                          
}
end implementation GRpart;
