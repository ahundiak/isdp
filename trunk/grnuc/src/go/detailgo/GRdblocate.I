/* #######################    APOGEE COMPILED   ######################## */
class implementation GRdsborder;

#include "grimport.h"
#include "msdef.h"
#include "lcdef.h"
#include "grownerdef.h"
#include "OMerrordef.h"
#include "godef.h"
#include "grerr.h"
#include "lcmacros.h"
#include "grgsdef.h"
#include "gocmacros.h"
#include "detaildef.h"

#define OUTSIDE   0
#define INSIDE    1
#define OVERLAP   2

extern IGRint GRget_to_owner_chansel();

/*\
Name
    GRlocate_owner

Description
    This method performs the locate operation for owners.  This method
    is responsible for locating the owner and the component that sent 
    this message.

    *msg           IGRlong              completion code
    *cvl           struct GRlc_cvl      Module and action handler info
    *path          struct GRlc_path     The locate path of objects
    *path_position  IGRint              Position of calling object in
                                        the path structure.

Notes
    The msg should be initialized to GR_I_NO_RESPONSE.  Only
    legitimate owners can change the message setting.

Return Values
    MSSUCC            -  if successful completion 
    MSFAIL            -  if error occurred
    GR_I_NO_RESPONSE  -  If no legitimate owners.
\*/

method GRlocate_owner ( IGRlong *msg; 
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path; 
                        IGRint *path_position )
{
    IGRlong           om_msg;
    IGRint            owner_eligible;
    IGRint            component_eligible;
    IGRint            i;
    GRclassid         classid;
    GRclassid         polygon_classid;
    OM_S_CHANSELECT   chansel;

   *msg = MSSUCC;

    GRget_to_owner_chansel(&chansel);

    om$get_classid ( osnum = path[*path_position].lc_info.located_obj.osnum,
                     objid = path[*path_position].lc_info.located_obj.objid,
                     p_classid = &classid);

    om$get_classid ( classname = "GR3dorthpoly",
                     p_classid = &polygon_classid);

    if (classid == polygon_classid) 
    {
        om_msg = om$send ( mode = OM_e_wrt_message,
                           msg = message GRowner.GRlocate_owner ( msg, 
                                                                  cvl, 
                                                                  path,
                                                                  path_position ),
                           targetid = my_id);
    }
    else 
    {
        /*
         *  Add myself to the path.
         */
        GRlc_add_path(path, path_position, my_id, OM_Gw_current_OS);
        path[*path_position].lc_info.module_info = cvl->module;

        owner_eligible = FALSE;       /* Since I do not have an owner */
        component_eligible = 
            (cvl->attributes.obj_attr.owner_action & LC_OBJ_W_OWNER) ? 2 : 1;

        om_msg = om$send ( msg = message GRgraphics.GRlocate_processing 
                                                                ( msg,
                                                                  cvl, 
                                                                  path, 
                                                                  path_position, 
                                                                  &owner_eligible,
                                                                  &component_eligible ),
                           targetid = my_id);

        if (om_msg & *msg & 1) 
        {
            if (path[*path_position].call_action_handler) 
            {
                om_msg = (*cvl->action_handler)( cvl->act_parms, 
                                                 &path[*path_position].lc_info, 
                                                 cvl->locate_args,
                                                 &path[*path_position].action );
            }
        }

        GRlc_remove_path ( path, path_position );

        if (om_msg == OM_I_STOP_SENDING) 
        {
            for (i=0; i <= *path_position; ++i) path[i].call_action_handler = FALSE;
        }
        else 
        {
            om_msg = GRsend_to_next_sibling 
                            ( path[*path_position].lc_info.located_obj.osnum,
                              path[*path_position].lc_info.located_obj.objid,
                              OM_Gw_current_OS,
                              my_id, 
                              message GRcmpowner.GRlocate_owner ( msg, 
                                                                  cvl,
                                                                  path, 
                                                                  path_position) );
        }
    }

    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_LOCATED);

    return (om_msg);
}

/*\
Name
    GRlocate_processing

Description
    This method performs the locate processing for an owner.

    *msg                 IGRlong           completion code
    *cvl                 struct GRlc_cvl   Module and action handler info
    *path                struct GRlc_path  The locate path of objects
    *path_position       IGRint            Position of calling object in
                                           the path structure.
    *owner_eligible      IGRint            If 1 owner is eligible
                                           If 0 owner is not eligible
    *component_eligible  IGRint            If 0 no components are eligible
                                           If 1 all components are eligible
                                           If 2 all but immediate component
                                           are eligible

Return Values
    MSSUCC   -  if successful completion 
    MSFAIL   -  if error occurred
\*/

method GRlocate_processing ( IGRlong *msg;
                             struct GRlc_cvl *cvl;
                             struct GRlc_path *path;
                             IGRint *path_position;
                             IGRint *owner_eligible; 
                             IGRint *component_eligible )
{
    IGRlong              om_msg;
    IGRint               properties;
    GRclassid            classid;
    GRclassid            polygon_classid;

    *msg = MSSUCC;

    /*
     *  Get the components type.
     */
    om$get_classid ( osnum = path[*path_position - 1].lc_info.located_obj.osnum,
                     objid = path[*path_position - 1].lc_info.located_obj.objid,
                     p_classid = &classid);

    om$get_classid ( classname = "GR3dorthpoly",
                     p_classid = &polygon_classid);

    /*
     *  Define the locate properties based upon this type.
     */
    if (classid == polygon_classid) 
    {
        properties = GR_LC_OWN_READ        |
                     GR_LC_OWN_WRITE       |
                     GR_LC_OWN_PRM_READ    |
                     GR_LC_OWN_PRM_WRITE   |
                     GR_LC_FLEXIBLE;
    }
    else 
    {
        properties = GR_LC_CMP_READ        |
                     GR_LC_CMP_WRITE       |
                     GR_LC_OWN_PRM_READ    |
                     GR_LC_OWN_PRM_WRITE   |
                     GR_LC_FLEXIBLE;
    }

    om_msg = GRowner_locate_processing ( msg,
                                         cvl,
                                         path,
                                         path_position, 
                                         owner_eligible,
                                         component_eligible,
                                         my_id,
                                         OM_Gw_current_OS,
                                         properties );

    return(om_msg);
}
end implementation GRdsborder;
