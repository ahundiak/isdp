class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <alloca.h>
#include "nddef.h"

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"
#include "assemconstr.h"
#include "assemmacros.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRdelete                                                        |
 |                                                                           |
 | This method deletes the EMdescribe object.                                |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 | krishna kumar    1/10/94     modified     deleting incident constraints   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRdelete ( IGRlong * msg; struct GRmd_env * mod_env )
{
    IGRlong           om_msg = OM_S_SUCCESS;
    IGRboolean        old_system_mode;
    IGRint            count, i;
    struct GRid       my_grid, comp_id;
    OM_S_CHANSELECT   chansel;
    IGRlong           ok;
    
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    /*
     * Turn on the system mode. This allows subclasses of EMdescribe
     * to ignore system checks when removing objects.
     */
    old_system_mode = EMdesc_set_system_mode (TRUE);
    
    /*
     * Notify any children that one of their parents is being deleted.
     */
    if (me->properties & GRIS_ASSOCIATIVE)
    {
        struct GRid new_grid;
        
        om$make_chanselect (channame = "NDchildren.children",
                            p_chanselect = &chansel);

        om$send (msg = message NDnode.NDparent_deleted (&ok,
                                                       1,
                                                       &my_grid,
                                                       &new_grid,
                                                       mod_env),
                 p_chanselect = &chansel);
    }

    /*
     * Delete the incident constraints and also the outgoing constraints
     */        
    {
        IGRint numcnstr;
        struct GRid list[MAX_INCIDENT_CONSTR];

        om_msg = om$send( msg = message EMinstance.EMget_incident_constr( msg,
                                                                          &numcnstr,
                                                                           list ),
                                targetid = my_id );

        if( om_msg & *msg & 1 )
        {
            for( i = 0; i < numcnstr; i++ )
            {
                om_msg = asm$rem_constraint( msg = msg,
                                            constraint_id = &list[i] );    
            }
        }

        om_msg = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN,
                                        list,MAX_INCIDENT_CONSTR,NULL,0,OM_K_MAXINT,&numcnstr),
                             targetid = my_id);
        if( om_msg & 1 )
        {
            for( i = 0; i < numcnstr; i++ )
            {
                om_msg = asm$rem_constraint( msg = msg,
                                            constraint_id = &list[i] );    
            }
        }
    }

    /*
     * Delete the owned members.
     */
    GRget_to_comp_info (&chansel, OM_Gw_current_OS, my_id, &count);

    for (i=count-1; i>=0; --i)
    {
        om_msg = om$get_objid_at_index (objid = my_id,
                                        osnum = OM_Gw_current_OS,
                                        p_chanselect = &chansel,
                                        index = i,
                                        objidaddr = &comp_id.objid,
                                        osnumaddr = &comp_id.osnum);
        
        if (om_msg & 1)
        {
            /*
             * Delete the member.
             */
            om_msg = om$send (msg = message GRgraphics.GRdelete (msg, 
                                                                 mod_env),
                              targetid = comp_id.objid,
                              targetos = comp_id.osnum);

            if (!(om_msg & *msg & 1))
            {
                verbose(printf ("EMdescribe_GRdelete: Error: Couldn't delete member\n"));
            }
        }
    }

    /*
     * Delete my self, this will take care of disconnecting the
     * owned members while deleting the others.
     */
    om_msg = om$send (msg = message GRowner.GRdelete_owner (msg, mod_env),
                      targetid = my_id );

    /*
     * Restore the system mode.
     */
    EMdesc_set_system_mode (old_system_mode);

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_DELETED);

    if (om_msg & *msg & 1)
    {
        EMbom_update (BOM_REM_ENTRY, my_id, OM_Gw_current_OS, mod_env);
    }
    
    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRdelete_owner                                                  |
 |                                                                           |
 | This method deletes the EMdescribe object only.                           |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRdelete_owner(IGRlong *msg; struct GRmd_env *mod_env)
{
    IGRlong         om_msg;
    struct GRid     my_grid, owner_id, comp_id;
    OM_S_CHANSELECT chansel;
    IGRint          i, count;
    
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    /*
     * Get the to_owner chanel.
     */
    GRget_to_owner_info (&chansel, OM_Gw_current_OS, my_id, &count);
    
    /*
     * Inform my owners that i'm going away.
     */
    om_msg = om$send (msg = message GRcmpowner.GRcomponent_disconnecting
                                                             (msg,
                                                              mod_env,
                                                              &my_grid),
                      p_chanselect = &chansel);

    /*
     * Disconnect myself from my owners.
     */
    for (i=count-1; i>=0; --i)
    {
        om_msg = om$get_objid_at_index (objid = my_id,
                                        osnum = OM_Gw_current_OS,
                                        p_chanselect = &chansel,
                                        index = i,
                                        objidaddr = &owner_id.objid,
                                        osnumaddr = &owner_id.osnum);
        
        if (om_msg & 1)
        {
            om_msg = om$send (msg = message GRconnector.GRdisconn (msg,
                                                                   &owner_id),
                              targetid = my_id);
                
            if (!(om_msg & *msg & 1))
            {
                verbose(printf ("EMdescribe_GRdelete_owner: Error: Couldn't disconnect\n"));
            }
        }
    }

    /*
     * If I'm associative make sure my children know I'm going away.
     */
    if (me->properties & GRIS_ASSOCIATIVE)
    {
        IGRlong         ok;
        OM_S_CHANSELECT children;
        struct GRid     src_grid;

        om$make_chanselect (channame = "NDchildren.children",
                            p_chanselect = &children);
        
        om$send (msg = message NDnode.NDparent_deleted (&ok,
                                                        1,
                                                        &my_grid,
                                                        &src_grid,
                                                        mod_env),
                 p_chanselect = &children);
    }

    /*
     * Disconnect the owned members. This will leave the graphic
     * object's named but these names will be removed in the 
     * EMdelete send below.
     */
    GRget_to_comp_info (&chansel, OM_Gw_current_OS, my_id, &count);

    for (i=count-1; i>=0; --i)
    {
        om_msg = om$get_objid_at_index (objid = my_id,
                                        osnum = OM_Gw_current_OS,
                                        p_chanselect = &chansel,
                                        index = i,
                                        objidaddr = &comp_id.objid,
                                        osnumaddr = &comp_id.osnum);
        
        if (!(om_msg & 1))
        {
            goto quit;
        }
        
        om_msg = om$send (msg = message GRconnector.GRdisconn (msg,
                                                               &my_grid),
                          targetid = comp_id.objid,
                          targetos = comp_id.osnum);    

        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }

    /*
     * Delete myself.
     */
    om_msg = om$send (msg = message EMdescribe.EMdelete (msg),
                      targetid = my_id);

    if (om_msg & *msg & 1)
    {
        EMbom_update (BOM_REM_ENTRY, my_id, OM_Gw_current_OS, mod_env);
    }
    
quit:
    
    return (om_msg);
}

end implementation EMinstance;



