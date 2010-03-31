class implementation EMdescribe;

#include <grimport.h>
#include <DIprims.h>
#include <grerr.h>
#include <gocmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <godef.h>
#include <grownerdef.h>

#include <assemdef.h>
#include <assem.h>
#include <assempriv.h>

extern OMuword GRgraphics_OPP_GRxform_method_index;
extern OMuword EMSdpr_OPP_EMevaluateOps_method_index;
extern OMuword NDnode_OPP_NDupdate_method_index;

from GRnotify import GRntfyconn, GRntfydisconn;
from GRvg     import GRchgprops;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRnotifylis                                                     |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/24/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRnotifylis (IGRlong         * msg; 
                    IGRlong         * OMmsg;
                    IGRlong         * mask;
                    OM_S_MESSAGE    * graphics_msg)
{
    IGRlong ok = MSSUCC;
    
    switch (*mask)
    {
    case GR_GEOM_XFORMED:
#if defined(__STDC__) || defined(__cplusplus)
        if (graphics_msg->select.FuncIndex == GRgraphics_OPP_GRxform_method_index)
#else
        if (graphics_msg->select.FuncIndex == GRgraphics$GRxform_method_index)
#endif
        {
            struct GRgraphics_GRxform_Msg * xform_msg;
            
            xform_msg = (struct GRgraphics_GRxform_Msg *)
              graphics_msg->p_arglist;
        }
/*
        printf ("EMdescribe.GRnotifylis: GR_GEOM_XFORMED\n");
*/
        break;

    case GR_DISPLAYED:
/*
        printf ("EMdescribe.GRnotifylis: GR_DISPLAYED\n");
*/
        break;
        
    case GR_GEOM_MODIFIED:

#if defined(__STDC__) || defined(__cplusplus)
        if (graphics_msg->select.FuncIndex == EMSdpr_OPP_EMevaluateOps_method_index)
#else
        if (graphics_msg->select.FuncIndex == EMSdpr$EMevaluateOps_method_index)
#endif
        {
/*
            printf ("EMdescribe.GRnotifylis: GR_GEOM_MODIFIED: EMSdpr: EMevaluateOPs\n");
*/
        }
#if defined(__STDC__) || defined(__cplusplus)
        else if (graphics_msg->select.FuncIndex == NDnode_OPP_NDupdate_method_index)
#else
        else if (graphics_msg->select.FuncIndex == NDnode$NDupdate_method_index)
#endif
        {
/*
            printf ("EMdescribe.GRnotifylis: GR_GEOM_MODIFIED: NDnode: NDupdate\n");
*/
        }
        else
        {
/*
            printf ("EMdescribe.GRnotifylis: GR_GEOM_MODIFIED\n");
*/
        }
        break;
        
    case GR_CLIPPED:
/*
        printf ("EMdescribe.GRnotifylis: GR_CLIPPED\n");
*/
        break;
        
    case GR_DELETED:
/*
        printf ("EMdescribe.GRnotifylis: GR_DELETED\n");
*/
        {
            struct GRid my_grid;
            
            my_grid.objid = my_id;
            my_grid.osnum = OM_Gw_current_OS;
            
            /*
             * Delete myself.
             */
            om$send (msg = message EMdescribe.EMdelete (&ok),
                     targetid = my_id);
        }
        
        break;

    case GR_COPIED:
/*
        printf ("EMdescribe.GRnotifylis: GR_COPIED\n");
*/
        break;
        
    case GR_ATTR_MODIFIED:
/*
        printf ("EMdescribe.GRnotifylis: GR_ATTR_MODIFIED\n");
*/
        break;
        
    case GR_GEOM_POSTED:
/*
        printf ("EMdescribe.GRnotifylis: GR_GEOM_POSTED\n");
*/
        break;
        
    case GR_LOCATED:
/*
        printf ("EMdescribe.GRnotifylis: GR_GEOM_LOCATED\n");
*/
        break;
        
    case GR_CHANNEL_USED:
/*
        printf ("EMdescribe.GRnotifylis: GR_CHANNEL_USED\n");
*/
        break;
        
    case GR_RTREE_MANIPULATION:
/*
        printf ("EMdescribe.GRnotifylis: GR_RTREE_MANIPULATION\n");
*/
        break;
        
    case GR_CHANGED:
/*
        printf ("EMdescribe.GRnotifylis: GR_CHANGED\n");
*/
        break;
    }

    return *OMmsg;
}        

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMadd_notify                                                      |
 |                                                                           |
 | This method will add a graphic object that is to be described.            |
 |                                                                           |
 | Input:   struct GRid * notify_id     Notify object's id.                  |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMadd_notify (IGRlong     * msg;
                      struct GRid * notify_id)
{
    IGRlong         om_msg;
    OMuint          count;
    OM_S_CHANSELECT chansel;
    IGRint          index = OM_K_MAXINT;
    struct GRid     my_grid;
    IGRboolean      tagged = FALSE;
    GRspacenum      osnum;
    
    om_msg = om$make_chanselect (channame = "EMdescribe.to_notify",
                                 p_chanselect = &chansel);
        
    if (!(om_msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    om_msg = om$get_channel_count (objid = my_id,
                                   p_chanselect = &chansel,
                                   count = &count);

    if (!(om_msg & 1) || (count != 0))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    osnum = OM_Gw_current_OS;
    
    /*
     * Connect to the listener channel.
     */
    om_msg = om$send (msg = message GRnotify.GRntfyconn (msg,
                                                         &my_grid,
                                                         &chansel,
                                                         &index,
                                                         &tagged,
                                                         &osnum),
                      targetid = notify_id->objid,
                      targetos = notify_id->osnum);

    if (!(om_msg & *msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_notify                                                      |
 |                                                                           |
 | This method will return the graphic object that is being described.       |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |          struct GRid * notify_id     Notify object's id.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_notify (IGRlong     * msg;
                      struct GRid * notify_id)
{
    IGRlong             om_msg;
    OMuint              count;
    OM_S_CHANSELECT     chansel;
    OM_S_OBJECT_LINKAGE object;
    
    om_msg = om$make_chanselect (channame = "EMdescribe.to_notify",
                                 p_chanselect = &chansel);
        
    if (!(om_msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    om_msg = om$get_channel_count (objid = my_id,
                                   p_chanselect = &chansel,
                                   count = &count);

    if (!(om_msg & 1) || (count != 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    om_msg = om$get_channel_objects (objid = my_id,
                                     p_chanselect = &chansel,
                                     list = &object,
                                     size = 1,
                                     count = &count);
    
    if (!(om_msg & 1) || (count != 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    if (notify_id)
    {
        notify_id->objid = object.S_objid;
        notify_id->osnum = object.osnum;
    }
    
 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMrem_notify                                                      |
 |                                                                           |
 | This message will remove the graphic object that is being described.      |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMrem_notify (IGRlong * msg)
{
    IGRlong         om_msg = OM_S_SUCCESS;
    OM_S_CHANSELECT chansel;
    struct GRid     my_grid, notify_id;
    
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    
    om_msg = om$make_chanselect (channame = "EMdescribe.to_notify",
                                 p_chanselect = &chansel);
        
    if (!(om_msg & 1))  
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Get the notify object first.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_notify (msg, &notify_id),
                      targetid = my_id);
    
    if (!(om_msg & 1))  
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

    /*
     * Disconnect it.
     */
    om_msg = om$send (msg = message GRnotify.GRntfydisconn (msg,
                                                            &my_grid,
                                                            &chansel),
                      targetid = notify_id.objid,
                      targetos = notify_id.osnum);
        
    if (!(om_msg & *msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }

 quit:
    
    return om_msg;
}

end implementation EMdescribe;






