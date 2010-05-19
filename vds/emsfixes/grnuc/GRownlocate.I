/* $Id: GRownlocate.I,v 1.2 2001/01/13 00:23:38 hans Exp $ */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:       vds/emsfixes/grnuc/GRownlocate.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: GRownlocate.I,v $
 *      Revision 1.2  2001/01/13 00:23:38  hans
 *      SP16 modifications
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/21/00        Rama Rao        Added Layer Check.
 * -------------------------------------------------------------------*/

/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRlocate

Description
    This method will check to see if the graphics object passes the
    locate properties check.

    If so, the owner is notified that the graphics has received a locate
    request.  The owner then does the processing to determine if the object
    should be located. If so, the owner calls the action handler.

    If the object has no owner, this method calls the GRlocate_processing.
    If the processing succeeds, this object calls the action handler.

    *cvl        struct GRlc_cvl   structure containing all locate info
    range_key   OM_p_KEY_DESC     pointer to the range key information

Notes
    This method should only be called when a GR_nam_loc is being done.
    This implies that this object is the only object that is being
    searched for and that no other objects are eligible.

Return Values
    MSSUCC   -  If successful
    MSFAIL   -  If failure

History
    Gray Winn	    1/15/87     Creation Date
    jay wallingford 04/29/89    Optimized the making of chansel
    mrm             02/06/91    always return either OM_I_STOP_SENDING or
                                OM_S_SUCCESS to avoid problems with
                                premature termination of the rtree pass
                                during locate
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "dpmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "grerr.h"

extern IGRint       GRget_to_comp_chansel();
extern IGRboolean   GRinit_path();

method GRlocate(struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
    IGRlong           om_msg;
    IGRlong           ret_msg;
    IGRint            path_position;
    IGRint            owner_eligible;
    IGRint            component_eligible;
    IGRint            locate_properties;
    OM_S_CHANSELECT   chansel;
    struct GRlc_path  *path;

    cvl->msg = MSSUCC;
    om_msg = OM_S_SUCCESS;

    if ( om_msg = GRget_to_owner_chansel( &chansel ) )
    {
        /*
         *  Do not check for locatable or displayable.
         */
        locate_properties = (cvl->attributes.obj_attr.properties &
                            (0xffffffff ^ (LC_LC_NONLC | LC_DP_INVIS)));

        ret_msg = GRcheck_props (&cvl->module.md_env.matrix_type,
                                 cvl->module.md_env.matrix,
                                 &my_id,
                                 &me->properties,
                                 &locate_properties);

        if (ret_msg & 1)
        {
            GRinit_path ( &ret_msg,
                          cvl,
                          &my_id,
                          &OM_Gw_current_OS,
                          &path,
                          &path_position);

            if( ret_msg & 1 &&
	         DPlevel_check( me->level, cvl->levels) )
            {
                ret_msg = GR_I_NO_RESPONSE;

                om_msg = om$send(msg = message GRcmpowner.GRlocate_owner
                                                        ( &ret_msg,
                                                          cvl,
                                                          path,
                                                          &path_position),
                                 p_chanselect = &chansel,
                                 from = 0,
                                 to = 0);

                if ( ret_msg == GR_I_NO_RESPONSE)
                {
                    /*
                     *  None of the owners responded to the locate message.
                     */
                    owner_eligible = FALSE;    /* Since I do not have an owner */
                    component_eligible =
                    (cvl->attributes.obj_attr.owner_action & LC_OBJ_W_OWNER) ?
                     0 : 1;

                    om_msg = om$send
                            ( msg = message GRgraphics.GRlocate_processing
                                                      ( &ret_msg,
                                                        cvl, path,
                                                        &path_position,
                                                        &owner_eligible,
                                                        &component_eligible),
                              targetid = my_id);
                }

                if (path[path_position].call_action_handler)
                {
                    om_msg = (*cvl->action_handler)
                                        ( cvl->act_parms,
                                          &path[path_position].lc_info,
                                          cvl->locate_args,
                                          &path[path_position].action);
                }
            }

            GRlc_remove_path(path,&path_position);
        }

        GR_NOTIFY_LISTENERS(&cvl->msg, &om_msg, GR_LOCATED);
    }

    if (om_msg != OM_I_STOP_SENDING) om_msg = OM_S_SUCCESS;

    return(om_msg);
}
end implementation GRowner;
