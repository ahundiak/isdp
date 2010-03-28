/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

from NDnode     import NDgive_structure;

/*
 * Method : 
 *
 *      GRnum_attributes
 *
 * Abstract :
 *
 *	This routine returns the number of attributes for a part.
 *
 * Arguments :
 *
 *      *msg            IGRlong         Completion code.
 *      *num            IGRint          Number of attributes.
 *
 * Return Values :
 *
 *      MSSUCC - successful.
 *      MSFAIL - failure.
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation data.
 */
method GRnum_attributes ( IGRlong * msg; IGRint * num )
{
    *msg = MSSUCC;

    *num = me->nb_attr;

    return(OM_S_SUCCESS);   
}

/*
 * Method : 
 *
 *      GRget_attribute
 *
 * Abstract :
 *
 *	This routine returns the attribute name and value if an index is
 *      supplied or the index and value if the name is supplied. The type
 *      is also returned if a buffer is specified.
 *
 * Arguments :
 *
 *      *msg            IGRlong         Completion code.
 *      *index          IGRint          Attribute index.
 *      *attr           IGRchar         Attribute name.
 *      *value          IGRchar         Attribute value.
 *      *type           IGRint          Attribute type.
 *
 * Return Values :
 *
 *      MSSUCC - successful.
 *      MSFAIL - failure.
 *
 * History :
 *
 *      Jay Wallingford     3/9/90  Creation date.
 */
method GRget_attribute ( IGRlong * msg; 
                         IGRchar * attr;
                         IGRint  * index;
                         IGRchar * value;
                         IGRint  * type )
{
    IGRint              om_msg = OM_S_SUCCESS;
    OM_S_CHANSELECT     comp_chan;
    struct ret_struct   data;
    IGRint              nret, buffersize, ndx = 0, i;
    struct GRmd_env     mod_env;

    *msg = MSSUCC;

    /*
     * If an attribute name is supplied and it is not a buffer for output.
     */
    if ( attr && (*attr != '\0') )
    {
        /*
         * Find the attribute index for this attribute name.
         */ 
        for (i=0; i<me->nb_attr; ++i)
        {
            if (!strcmp(attr, &(me->attr_name[me->attr_def[i].name]))) break;
        }
        
        if (i == me->nb_attr)  /* Didn't find it */
        {
            *msg = MSFAIL;
        }
        else /* Set the index if it was specified. */
        {
            ndx = i;
            if ( index ) *index = ndx;
        }
    }
    /*
     * Else if an index buffer was specified and the index is in range.
     */
    else if ( index && (*index >= 0) && (*index < me->nb_attr) ) 
    {
        ndx = *index;
       
        /*
         * Get the attribute if a buffer was provided.
         */ 
        if ( attr )
        {
            strcpy(attr, &me->attr_name[me->attr_def[ndx].name]);
        }
    }
    else *msg = MSFAIL;
        
    /*
     * If the attribute value is requested ...
     */
    if (value && (*msg & 1))
    {
        /*
         * Kludge together a module enviroment.
         */
        buffersize = sizeof(struct GRmd_env);
        gr$get_module_env ( msg = msg,
                            sizbuf = &buffersize,
                            buffer = &mod_env,
                            nret = &nret );

        mod_env.md_id.osnum = OM_Gw_current_OS;

    
        GRget_to_comp_chansel (&comp_chan);

        /*
         * Get the value from the expression object.
         */ 
        om_msg = om$send ( msg = message NDnode.NDgive_structure
                                             (msg, &data, &mod_env),
                           p_chanselect = &comp_chan,
                           from = me->attr_def[ndx].index,
                           to = me->attr_def[ndx].index );
 
        if ( om_msg & *msg & 1 )
        {
            switch ( data.type )
            {
                case text_type:
                    strcpy(value, data.var.text_st.text_string);
                    break;
 
                case double_type:
                    sprintf(value, "%f", data.var.root_pm_st.value);
                    break;
 
                default:
                    *msg = MSFAIL;
                    break;
           }
        }
    }

    /*
     * If the type was requested ...
     */
    if (type && (om_msg & *msg & 1))
    {
        *type = me->attr_type[ndx];
    }
            
    return(om_msg);
}

end implementation GRpart;
