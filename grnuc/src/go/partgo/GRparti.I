/* #######################    APOGEE COMPILED   ######################## */
class implementation GRpart;

#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <grownmacros.h>
#include <gocmacros.h>
#include <partdef.h>
#include <msmacros.h>
#include <OMmacros.h>
#include <OMprimitives.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

extern OMuword OPP_GRundo_class_id;

/*
 * Method :
 *
 *      debug
 *
 * Abstract :
 *
 *      This method prints out the contents of a GRpart.
 *
 */
method debug ()
{
    IGRint  i;
    
    printf("me->nb_attr = %d\n", me->nb_attr);
    
    for (i=0; i<me->nb_attr; ++i)
    {
        printf("me->attr_def[%d].index  = %d\n", i, me->attr_def[i].index);
        printf("me->attr_def[%d].name   = %d\n", i, me->attr_def[i].name);
        printf("me->attr_name[%d].name  = %s\n", i, &me->attr_name[me->attr_def[i].name]);
        printf("me->attr_type[%d]       = %d\n\n", i, me->attr_type[i]);
    }

    return(OM_S_SUCCESS);
}
        
/*
 * Method : 
 *
 *      GRgetobjinfo
 *
 * Abstract :
 *
 *	This routine reports the part description.
 *
 * Arguments :
 *
 *      *msg    IGRlong     Completion code.
 *      *info   GRobj_info  Structure for information about 
 *                          the object
 * Return Values :
 *
 *      MSSUCC - successful completion
 *
 *
 */
method GRgetobjinfo (IGRlong *msg; struct GRobj_info *info)
{
    IGRint  om_msg = OM_S_SUCCESS;
    IGRchar name[MAX_VALUE], msgbuff[50];
    IGRint  index;

    /*
     * Get the part description. 
     *
     * 1/30/92: This is one place we depend on the order of attributes.
     *          Parts and Partslists have different intrinsic attribute
     *          names, so we must use indices.  SRH
     */ 
    index = 1; 
    om_msg = om$send ( msg = message GRpart.GRget_attribute ( msg,
                                                              NULL,
                                                              &index,
                                                              name,
                                                              NULL ),
                       targetid = my_id );
                       
    /*
     * If that fails ...
     */
    if (!(om_msg & *msg & 1))
    {
        /*
         * Get the part number ...
         */
        index = 0; 
        om_msg = om$send ( msg = message GRpart.GRget_attribute ( msg,
                                                                  NULL,
                                                                  &index,
                                                                  name,
                                                                  NULL ),
                           targetid = my_id );

    }

    if (om_msg & *msg & 1)
    {
        strncpy(info->type, name, 29);
        info->type[29] = '\0';
    }
    else
    {
	/*  info->type is only 30 bytes long! */
        ex$message(msgnumb = GR_I_UndefinedPart,
                   buff = msgbuff);
        strcpy(info->type, msgbuff);
    }

    *msg = MSSUCC;
                        
    return (OM_S_SUCCESS);
}

/*
 * Method : 
 *
 *      ACcreate
 *
 * Abstract :
 *
 *	This routine initialize a part's group protection and
 *      then sends a ACdiowner.ACcreate wrt message.
 *
 * Arguments :
 *
 *      *msg    IGRlong     Completion code.
 *
 * Return Values :
 *
 *      MSSUCC - successful completion
 *
 *
 */
method ACcreate ( IGRlong * msg; IGRchar * name )
{
    IGRlong om_msg = OM_S_SUCCESS;
    
    /*
     * Initialize the group protection.
     */
    om_msg = om$send ( msg = message GRoups.init((int *)msg),
                       targetid = my_id );
                       
    if (om_msg & *msg & 1)
    {
        /*
         * Create the directory.
         */
        om_msg = om$send ( msg = message ACdiowner.ACcreate(msg, name),
                           mode = OM_e_wrt_message,
                           targetid = my_id );

        /*
         * Set the number of attributes to 0.
         */
        me->nb_attr = 0;

        /*
         * Reset all the vlas since this could be a copy.
         */
        om$vla_set_dimension (varray = me->attr_def, size = 0);
        om$vla_set_dimension (varray = me->attr_name, size = 0);
        om$vla_set_dimension (varray = me->attr_type, size = 0);
    }
   
    return(om_msg);
}

/*
 * Method :
 *
 *      GRflexconn
 *
 * Abstract :
 *
 *      This method will allow for this part to be nested within
 *      other parts if the flag is GR_OVERRIDE.
 *
 * Arguments :
 *
 *      *msg              IGRlong           Return code
 *      *flag             IGRlong           Flag 
 *      *owners_id        struct GRid       The owners objid, osnum
 *      *owners_index     IGRlong           The index on the flexible
 *                                          owners channel
 *      *graphics_index   IGRlong           The index on the graphics
 *                                          object channel
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 */
method GRflexconn ( IGRlong *msg; 
                    IGRlong *flag; 
                    struct GRid *owners_id; 
                    IGRlong *owners_index; 
                    IGRlong *graphics_index )
{
    IGRlong           om_msg = OM_S_SUCCESS;
    OM_S_CHANSELECT   comp_chan;
    struct GRid       part, comp;
    IGRchar           name[DI_PATH_MAX];
    IGRint            i, count;
    OMuword           classid;
    
    part.objid = my_id;
    part.osnum = OM_Gw_current_OS;
    
    if (om$get_classid (objid = owners_id->objid,
                        osnum = owners_id->osnum,
                        p_classid = &classid) & 1)
    {
        /*
         * If this is being done for a delete undo, don't allow it ...
         */
        if (om$is_ancestry_valid (superclassid = OPP_GRundo_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            *msg = MSFAIL;
            goto quit;
        }
    }
    
    GRget_to_comp_info (&comp_chan, part.osnum, part.objid, &count );

    /*
     * If this will create a loop only connect my graphic components.
     */
    if (GRis_a_loop (owners_id, &part, &comp_chan))
    {
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
             * Try to get this component's attribute name.
             */           
            om_msg = om$send ( msg = message ACdiowner.ACgive_path ( msg,
                                                                     &comp,
                                                                     name ),
                               targetid = my_id );
                               
            /*
             * If there wasn't an attribute name.
             */
            if (!(om_msg & *msg & 1))
            {
                /*
                 * Connect the graphic object to the owner.
                 */
                om_msg = om$send ( msg = message GRconnector.GRflexconn 
                                                        ( msg, 
                                                          flag, 
                                                          owners_id,
                                                          owners_index, 
                                                          graphics_index ),
                                   targetid = comp.objid,
                                   targetos = comp.osnum );
                
                if (!(om_msg & *msg & 1)) break;
            }
        }

        if (om_msg & *msg & 1) *msg = GR_I_CPXFLATTEN;
    }
    else /* Connect myself */
    {
        om_msg = om$send ( msg = message GRconnector.GRflexconn 
                                                        ( msg, 
                                                          flag, 
                                                          owners_id,
                                                          owners_index, 
                                                          graphics_index ),
                           mode = OM_e_wrt_message,
                           targetid = my_id);
    }

 quit:
    
    return(om_msg);
}

/*
 * Method :
 *
 *      GRadd_to_active_owner
 *
 * Abstract :
 *
 *      This method adds the parts graphics to the active owner.
 *
 * Arguments :
 *
 *      *msg              IGRlong           Return code
 *      *mod              struct GRmd_env   Module Enviromentn
 *
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 */
method GRadd_to_active_owner (IGRlong *msg; struct GRmd_env *mod)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRid         comp;
    OM_S_CHANSELECT     comp_chan;
    IGRint              i, count;
    IGRchar             attr[MAX_ATTR];
    struct GRid         active_owner;

    *msg = MSSUCC;

    /*
     * If an active owner exists.
     */

    om_msg = gr$get_active_owner ( msg = msg,
                                   mod_id = &mod->md_id,
                                   active_owner = &active_owner );
    if (om_msg & *msg & 1)
    {
        /*
         * Get the number of components.
         */
        GRget_to_comp_info ( &comp_chan, OM_Gw_current_OS, my_id, &count );


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
                 * Add the components to the owner.
                 */
                gr$add_to_active_owner ( msg = msg,
                                         mod_env = mod,
                                         objid = comp.objid,
                                         osnum = comp.osnum);
            }
        }
    }
    else
    {
        /* 
         * No active owner.
         */
        om_msg = OM_S_SUCCESS;
        *msg = MSSUCC;
    }
    
    return (om_msg);
}

/*
 * Method :
 *
 *      GRgetsymb
 *
 * Abstract :
 *
 *      This method gets the symbology for the first graphics object
 *      on the channel.
 *
 * Arguments :
 *
 *      *msg              IGRlong            Return code.
 *      *symb             struct GRsymbology Symbology.
 *
 * Return Values :
 *
 *      MSSUCC  - successful
 *      MSFAIL  - failure
 */
method GRgetsymb ( IGRlong * msg; struct GRsymbology * symb )
{
    IGRint          om_msg = OM_S_SUCCESS;
    OM_S_CHANSELECT comp_chan;
    IGRchar         attr[MAX_ATTR];
    IGRint          count, i;
    struct GRid     comp;
        
    *msg = MSSUCC;
    
    GRget_to_comp_info ( &comp_chan, OM_Gw_current_OS, my_id, &count );
    
    /*
     * Get the symbology from the first object on the channel that
     * can respond to the GRvg.GRgetsymb message.
     */
    for (i=2; i<count; ++i)
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
             * Get the symbology of this object.
             */
            om_msg = om$send ( msg = message GRvg.GRgetsymb ( msg, symb ),
                               targetid = comp.objid,
                               targetos = comp.osnum );
                               
            if (om_msg & *msg & 1)
            {
                *msg = MSSUCC;
                break;
            }
        }
    }

    if (i == count) *msg = MSFAIL;
    
    return (om_msg);
}

method GRcomponent_disconnecting ( IGRlong *msg; 
                                   struct GRmd_env *mod_env;
                                   struct GRid *comp_id )
{
    IGRint              om_msg = OM_S_SUCCESS;
    IGRint              count, i;
    OMuint              index;
    OM_S_CHANSELECT     comp_chan;
    struct GRid         my_grid;
    
    GRget_to_comp_info ( &comp_chan, OM_Gw_current_OS, my_id, &count );

    /* 
     * Get the index of the component that is disconnecting.
     */
    om_msg = om$get_index ( p_chanselect = &comp_chan,
                            objid_c = my_id,
                            objid = comp_id->objid,
                            indexaddr = &index );

    if (om_msg & 1)
    {
        for ( i=0; i<me->nb_attr; ++i) 
        {
            if ( me->attr_def[i].index >= index ) break;
        }

        /*
         * If the element was an attribute ...
         */                                   
        if ( (i < me->nb_attr) && ( me->attr_def[i].index == index ) )
        {
            /*
             * Remove it.
             */

            om_msg = om$send ( msg = message ACdiowner.ACrem_att_at_index 
                                                ( msg, i ),
                               targetid = my_id );

        }
        else /* Element was not an attribute. */
        {
            /*
             * Update the index for each of the remaining attributes.
             */
            for (;i<me->nb_attr; ++i ) 
            {
                me->attr_def[i].index -= 1;
            }
        }
                     
        /* 
         * If this is the last graphic component disconnect the component
         * and delete myself.
         */
        if( (me->nb_attr == 0) || (count == me->nb_attr + 1) )
        {
            my_grid.objid = my_id;
            my_grid.osnum = OM_Gw_current_OS;

            /*
             * Disconnect the component.
             */
            om_msg = om$send ( msg = message GRconnector.GRdisconn ( msg,
                                                                     &my_grid ),
                               targetid = comp_id->objid,
                               targetos = comp_id->osnum );
            /*
             * Delete the myself.
             */
            om_msg = om$send ( msg = message GRgraphics.GRdelete ( msg, 
                                                                   mod_env ),
                               targetid = my_id );
        }
        
        GR_NOTIFY_LISTENERS ( msg, &om_msg, GR_CHANNEL_USED );
    }


    return(om_msg);
}        

/*
 *
 * Override: GRget_channel_type                                            
 *
 * This method determines the type of owner the object is. Normally GRparts
 * are flexible owners like graphic groups, but if the part is a PDU part
 * it will be considered rigid.
 *
 * History:
 *
 * jay wallingford  3/25/93     creation
 *
 */
method GRget_channel_type (IGRlong *msg; IGRint *type; IGRint *conn_type)
{
    struct GRid part_id;
    
    *msg = MSSUCC;

    part_id.objid = my_id;
    part_id.osnum = OM_Gw_current_OS;
    
    *conn_type = GR_NO_OVERRIDE;
    
    if (PDMpart_check(&part_id))
    {
        *type = GR_RIGID;
    }
    else
    {
        *type = GR_FLEXIBLE;
    }
    
    return(OM_S_SUCCESS);
}

/*
 *
 * Override: GRget_locate_properties                                     
 *                                                                       
 * This method determines the locate props of the owner. If the part is a PDM
 * part then it will be located as a rigid owner.
 *
 * History:
 *          
 * jay wallingford  3/25/93     creation                         
 *                                                               
 */
method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
    struct GRid part_id;
    
    *msg = MSSUCC;

    part_id.objid = my_id;
    part_id.osnum = OM_Gw_current_OS;

    if (PDMpart_check(&part_id))
    {
        *properties = GR_LC_CMP_READ     | GR_LC_CMP_WRITE     |
                      GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
                      GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE |
                      GR_LC_NO_PRM_COMP  | GR_LC_RIGID;
    }
    else
    {
        *properties = GR_LC_CMP_READ     | GR_LC_CMP_WRITE     |
                      GR_LC_OWN_READ     | GR_LC_OWN_WRITE     |
                      GR_LC_CMP_PRM_READ | GR_LC_CMP_PRM_WRITE |
                      GR_LC_FLEXIBLE;
    }
    
    return(OM_S_SUCCESS);
}

/*
 *
 * Override: GRrigid_connecting
 *                                                                       
 * This method determines if the graphic object that is being connected
 * to a rigid owner is the last graphic object on this part, if so it 
 * deletes itself.
 *
 * History:
 *          
 * jay wallingford  8/30/93     creation                         
 *                                                               
 */
method GRrigid_connecting ( long *msg; struct GRid *go_id )
{
    IGRint              om_msg = OM_S_SUCCESS;
    IGRint              count, i;
    OMuint              index;
    OM_S_CHANSELECT     comp_chan;
    struct GRid         my_grid;
    struct GRmd_env     mod_env;
    
    gr$get_module_env (buffer = &mod_env);
    mod_env.md_id.osnum = OM_Gw_current_OS;
    
    GRget_to_comp_info ( &comp_chan, OM_Gw_current_OS, my_id, &count );

    /* 
     * Get the index of the component that is disconnecting.
     */
    om_msg = om$get_index ( p_chanselect = &comp_chan,
                            objid_c = my_id,
                            objid = go_id->objid,
                            indexaddr = &index );

    if (om_msg & 1)
    {
        for ( i=0; i<me->nb_attr; ++i) 
        {
            if ( me->attr_def[i].index >= index ) break;
        }

        /*
         * If the element was an attribute ...
         */                                   
        if ( (i < me->nb_attr) && ( me->attr_def[i].index == index ) )
        {
            /*
             * Remove it.
             */

            om_msg = om$send ( msg = message ACdiowner.ACrem_att_at_index 
                                                ( msg, i ),
                               targetid = my_id );

        }
        else /* Element was not an attribute. */
        {
            /*
             * Update the index for each of the remaining attributes.
             */
            for (;i<me->nb_attr; ++i ) 
            {
                me->attr_def[i].index -= 1;
            }

            my_grid.objid = my_id;
            my_grid.osnum = OM_Gw_current_OS;

            /*
             * Disconnect the graphic object.
             */
            om_msg = om$send ( msg = message GRconnector.GRdisconn ( msg,
                                                                     &my_grid ),
                               targetid = go_id->objid,
                               targetos = go_id->osnum );
        }
                     
        /* 
         * If this is the last graphic component disconnect the component
         * and delete myself.
         */
        if( (me->nb_attr == 0) || (count == me->nb_attr + 1) )
        {
            /*
             * Delete the myself.
             */
            om_msg = om$send ( msg = message GRgraphics.GRdelete ( msg, 
                                                                   &mod_env ),
                               targetid = my_id );
        }
        
        GR_NOTIFY_LISTENERS ( msg, &om_msg, GR_CHANNEL_USED );
    }


    return(om_msg);
}

/*
 *
 * Override: unknown
 *                                                                       
 * This override is a KLUDGE for a problem with the unknown override
 * on ACdiowner which return OM_S_SUCCESS instead of OM_W_UNKNOWN_MSG.
 *
 * History:
 *          
 * jay wallingford  8/30/93     creation                         
 *                                                               
 */
method unknown (OM_S_MESSAGE *msg)
{
    return (OM_W_UNKNOWN_MSG);
}

/*
 *
 * Override: IGRdir.remove
 *                                                                       
 * This method makes sure it's legal to remove the attribute then the
 * attribute is removed with the ACrem_attribute method.
 *
 * History:
 *          
 * jay wallingford  8/31/93     creation                         
 *                                                               
 */
method IGRdir.remove (DIint *status; DIchar *name; DIint index)
{
    IGRlong     om_msg = OM_S_SUCCESS, msg = MSSUCC;
    IGRchar     loc_name[MAX_ATTR];

    /*
     * If the name isn't specified get it ...
     */
    if (name == NULL)
    {
        *(name = loc_name) = '\0';
        
        om_msg = om$send (msg = message GRpart.GRget_attribute (&msg,
                                                                name,
                                                                &index,
                                                                NULL,
                                                                NULL),
                          targetid = my_id);

        if (!(om_msg & msg & 1))
        {
            *status = DIR_W_NAME_NOT_FOUND;
            goto quit;
        }
    }

    /*
     * Remove the attribute.
     */
    om_msg = om$send (msg = message ACdiowner.ACrem_attribute (&msg,
                                                               name),
                      targetid = my_id);
    
    if (!(om_msg & msg & 1))
    {
        *status = DIR_E_ABORT;
    }

 quit:
    
    return om_msg;
}

end implementation GRpart;


