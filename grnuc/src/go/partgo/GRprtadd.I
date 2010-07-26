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
static  IGRboolean  GRpart_add_pass = TRUE;
%endsafe

/*
 * Method :
 *
 *      GRadd_attribute
 *
 * Abstract :
 *
 *      This routine adds part attributes and values.
 *  
 * Arguments :
 *
 *      *msg    IGRlong     Completion code.
 *      *attr   IGRchar     Attribute name to add.
 *      *value  IGRchar     Attribute value to add.
 *       type   IGRint      Type of attribute.
 *      
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *      Jamal Shakra        08/24/91 Modification date.
 */
method GRadd_attribute ( IGRlong *   msg;
                         IGRchar *   attr;
                         IGRchar *   value;
                         IGRint      type )
{
    IGRlong             om_msg = OM_S_SUCCESS;
    DIgrid              part_id;
    IGRint              i, count, prt_type;
    IGRchar             regexp[DI_PATH_MAX];
    IGRboolean          is_unique_attr = FALSE;

    *msg = MSSUCC;
    is_unique_attr = _is_unique_attr( attr);

    /*
     * If this is a uniqueness attribute make sure it doesn't have a ':' in it.
     */

    if (!me->nb_attr && is_unique_attr)
    {
        if (strchr(value,':'))
        {
            *msg = MSFAIL;
        }
    }
    else if (strlen(value) >= EXP_MAX_LEN)
    {
        *msg = MSFAIL;
    }
    
    if (*msg & 1)
    {
        /*
         * Add the attribute to myself.
	 */
        if ( is_unique_attr )
        {
            prt_type = AC_ATTRIB_TEXT;
            type = GR_STATIC_ATTR;
        }
	else prt_type = AC_ATTRIB_TYPE_NOT_DEF;

        om_msg = om$send ( msg = message ACdiowner.ACadd_attribute_by_type(
								     msg, 
								     prt_type,
                                                                     attr, 
                                                                     value ),
                           targetid = my_id );
    
        /*
         * Set the part type.
         */
        me->attr_type[me->nb_attr-1] = type;

        /*
         * If everything is ok, this is not the part number, description
         * catalog, revision or usage attribute.....
         */
        if ((om_msg & *msg & 1)     && 
            (!is_unique_attr)       && 
            (type & GR_COMMON_ATTR) &&
            (GRpart_add_pass == TRUE))
        {
            /*
             * Get a regular expression for all the parts in my parts directory.
             */
            di$untranslate ( objid = my_id, objname = regexp );
            *((IGRchar *)strrchr(regexp,':')) = '\0';
            di$strcat (to = regexp, from = "*");

            /*
             * For all the parts in my parts directory, except for my self,
             * add the attribute.
             */        
            di$start_dump ( regexp = regexp, ptr = &count );

            GRpart_add_pass = FALSE;        
        
            for (i=0; i<count; ++i)
            {
                di$fetch_dump ( index = i, p_grid = &part_id );
        
                if (part_id.objid != my_id)
                {
                    om_msg = om$send ( msg = message GRpart.GRadd_attribute 
                                                                   ( msg, 
                                                                     attr, 
                                                                     value,
                                                                     type ),
                                       targetid = part_id.objid,
                                       targetos = part_id.osnum );
                }
            }

            GRpart_add_pass = TRUE;
        }
    }

    return (om_msg);
}

/*
 * Method :
 *
 *      ACadd_attribute_by_type
 *
 * Abstract :
 *
 *      This routine adds part attributes and values.
 *  
 * Arguments :
 *
 *      *msg    IGRlong     Completion code.
 *      *name   IGRchar     Attribute name to add.
 *      *text   IGRchar     Attribute value to add.
 *      
 *
 * Return values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *      Sudha               1/29/91 Modified to fix TR 2209
 *
 */
method ACadd_attribute_by_type ( IGRlong *   msg;
				 IGRint      type;
                         	 IGRchar *   name;
                         	 IGRchar *   text )
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    om_msg = om$send ( msg = message ACdiowner.ACadd_attribute_by_type (
								 msg, 
								 type,
                                                                 name, 
                                                                 text ),
                       mode = OM_e_wrt_message,
                       targetid = my_id );
                       
    if ( om_msg & *msg & 1 )
    {
        om$vla_set_dimension ( varray = me->attr_type,
                               size = me->nb_attr );

        me->attr_type[me->nb_attr - 1] = GR_DYNAMIC_ATTR;
    }
    
    return ( om_msg );
}

/*
 * Method : 
 *
 *      ACadd_component
 *
 * Abstract :
 *
 *	This routine adds a graphic object to a part. If the graphic
 *      object is an owner a check is made for loops. If no loop is
 *      encountered the owner is added without flattening.
 *
 * Arguments :
 *
 *      *msg        IGRlong     Completion code.
 *      *component  struct GRid Graphic object to add.
 *
 * Return Values :
 *
 *      MSSUCC - successful completion
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 *
 */
method ACadd_component (IGRlong * msg; struct GRid * component)
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRlong         flag, maxi = OM_K_MAXINT;
    OM_S_CHANSELECT comp_chan;
    struct GRid     part;

    *msg = MSSUCC;
    
    GRget_to_comp_chansel (&comp_chan);

    part.objid = my_id;
    part.osnum = OM_Gw_current_OS;
    
    /*
     * If this is a PDM part do a rigid connection.
     */
    if (PDMpart_check(&part))
    {
        om_msg = om$send (msg = message GRconnector.GRrigidconn (msg,
                                                                 &part,
                                                                 &maxi),
                          targetid = component->objid,
                          targetos = component->osnum);
    }
    else /* Normal, flexible GRpart. */
    {
        /*
         * If there isn't a loop connect the object with override,
         * this will allow for the nesting of owners.
         */
        flag = (GRis_a_loop (&part, component, &comp_chan)) ? 0 : GR_OVERRIDE;

        /*
         * Connect the component.
         */
        om_msg = om$send ( msg = message GRconnector.GRflexconn ( msg,
                                                                 &flag,
                                                                 &part,
                                                                 &maxi,
                                                                 &maxi ),
                          targetid = component->objid,
                          targetos = component->osnum );
    }

    return(om_msg);
}

IGRint GRis_a_loop (owner, component, comp_chan)
    struct GRid     * owner, * component;
    OM_S_CHANSELECT * comp_chan;
{
    IGRint      i; 
    OMuint      count = 0;
    struct GRid comp;
    
    /*
     * If the owner and the component are the same
     * there is a loop.
     */
    if (owner->objid == component->objid) return(1);

    /*
     * Get the number of components on the component's
     * to_comp channel. This will only succeed if the
     * component is an owner.
     */
    if ( om$get_channel_count ( osnum = component->osnum,
                                objid = component->objid,
                                p_chanselect = comp_chan,
                                count = &count ) == OM_S_SUCCESS )
    {
        /*
         * For each component of the component ...
         */
        for (i=0; i<count; ++i)
        {
            /*
             * Get it's the id ...
             */
            om$get_objid_at_index ( osnum = component->osnum,
                                    objid = component->objid,
                                    p_chanselect = comp_chan,
                                    index = i,
                                    objidaddr = &comp.objid,
                                    osnumaddr = &comp.osnum );

            /*
             * And test for a loop.
             */
            if (GRis_a_loop(owner, &comp, comp_chan)) return(1);
        }
    }
    
    return (0);
}

end implementation GRpart;
