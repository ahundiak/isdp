/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>

/*
 * Method :
 *
 *      GRcopy
 *
 * Abstract :
 *
 *      This method copies a part to the object space described 
 *      in the structure new_dsenv.
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
method GRcopy ( IGRlong *msg; 
                struct GRmd_env *obj_dsenv;
                struct GRmd_env *new_dsenv; 
                GRobjid * newobjid )
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRid         part, new_part, new_go, comp;
    OM_S_CHANSELECT     comp_chan;
    IGRint              i, count;
    IGRchar             attr[MAX_ATTR];

    *msg = MSSUCC;

    part.objid = my_id;
    part.osnum = OM_Gw_current_OS;
    
    /*
     * If this isn't a dynamic copy ...
     */
    if (new_dsenv->md_id.objid != NULL_OBJID)
    {
        /*
         * Make sure it's ok with PDM to copy the part.
         */
        if (!PDMpre_copy (&part, obj_dsenv, new_dsenv))
        {
            *msg = MSFAIL;
            om_msg = OM_E_ABORT;
            *newobjid = NULL_OBJID;
            goto quit;
        }
    }
    
    GRget_to_comp_info ( &comp_chan, OM_Gw_current_OS, my_id, &count );

    /*
     * Copy the owner and link the attributes to the new part.
     */
    om_msg = om$send ( msg = message GRowner.GRcopy_owner ( msg,
                                                            obj_dsenv,
                                                            new_dsenv,
                                                            newobjid ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        new_part.objid = *newobjid;
        new_part.osnum = new_dsenv->md_id.osnum;
        
        /*
         * Copy the graphic objects.
         */
        for (i=0; i<count; ++i)
        {
            /*
             * Get the component.
             */
            om$get_objid_at_index ( objid = my_id,
                                    p_chanselect = &comp_chan,
                                    index = i,
                                    objidaddr = &comp.objid,
                                    osnumaddr = &comp.osnum );
            /*
             * If this object is not an attribute ...
             */
            om$send ( msg = message ACdiowner.ACgive_path (msg, &comp, attr),
                      targetid = my_id );

            if (!(*msg & 1))
            {                 
                /*
                 * Copy the graphic object.
                 */
                om_msg = om$send ( msg = message GRgraphics.GRcopy 
                                                          ( msg,
                                                            obj_dsenv,
                                                            new_dsenv,
                                                            &new_go.objid ),
                                   targetid = comp.objid,
                                   targetos = comp.osnum );
                /*
                 * If everything is ok connect the object to the new owner.
                 */
                if (om_msg & *msg & 1)
                {
                    new_go.osnum = new_dsenv->md_id.osnum;

                    om_msg = om$send ( msg = message ACdiowner.ACadd_component
                                                           ( msg, &new_go ),
                                       targetid = new_part.objid,
                                       targetos = new_part.osnum );
                }
            }
            else *msg = MSSUCC;
        }
    }

    if ( om_msg & *msg & 1 )
    {
        /*
         * Have the new part add itself to the active owner.
         */
        om$send ( msg = message GRowner.GRadd_to_active_owner ( msg,
                                                                new_dsenv ),
                  targetid = *newobjid,
                  targetos = new_dsenv->md_id.osnum );
    }
 
    if (om_msg & *msg & 1)
    {
        /*
         * If this isn't a dynamic copy ...
         */
        if (new_dsenv->md_id.objid != NULL_OBJID)
        {
            /*
             * Notify EDM that the part has been copied.
             */
            PDMpost_copy (&part, &new_part, obj_dsenv, new_dsenv);
        }
    }
    
 quit:
    
    return (om_msg);
}

/*
 * Method :
 *
 *      GRcptform
 *
 * Abstract :
 *
 *      This method copies and transforms a part to the object space described 
 *      in the structure new_dsenv.
 *
 * Arguments :
 *
 *      msg         IGRlong       completion code
 *      *obj_dsenv  GRmd_env      struct describing object's environment
 *      *new_dsenv  GRmd_env      struct describing copy's environment
 *      matrix      IGRmatrix     transformation matrix
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
method GRcptform(IGRlong         * msg; 
                 struct GRmd_env * obj_dsenv;
                 IGRmatrix         matrix; 
                 struct GRmd_env * new_dsenv;
                 GRobjid         * newobjid)
{
    IGRlong om_msg;
    struct GRid part, new_part;
    
    *msg = MSSUCC;
    
    part.objid = my_id;
    part.osnum = OM_Gw_current_OS;
    
    /*
     * Make sure it's ok with PDM to copy the part.
     */
    if (!PDMpre_copy (&part, obj_dsenv, new_dsenv))
    {
        *msg = MSFAIL;
        om_msg = OM_E_ABORT;
        *newobjid = NULL_OBJID;
        goto quit;
    }
        
    /*
     * Do the copy.
     */
    om_msg = om$send (msg = message GRgraphics.GRcptform (msg,
                                                          obj_dsenv,
                                                          matrix,
                                                          new_dsenv,
                                                          newobjid),
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    new_part.objid = *newobjid;
    new_part.osnum = new_dsenv->md_id.osnum;
        
    /*
     * Notify EDM that the part has been copied.
     */
    PDMpost_copy (&part, &new_part, obj_dsenv, new_dsenv);

 quit:
    
    return om_msg;
}

end implementation GRpart;
