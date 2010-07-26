/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRclip

Description
    This routine clips the an owner object.

    *msg         IGRlong             completition code
    *mod_env     struct GRmd_env     The originial module environment.
    *target_env  struct GRmd_env     The target environment.
    *prism       IGRchar             The right prism to clip against.
    *inside_id   struct GRid         The object id of the inside owner.
    *outside_id  struct GRid         The object id of the outside owner.
    *overlap_id  struct GRid         The object id of the overlapping owner.
    *clip_flag   IGRlong             The flag describing the type of clip.

Return Values
    MSSUCC  -- successful completion
    MSFAIL  -- failure

History
    Gray Winn       10/28/87    Creation date.
    jay wallingford 04/27/89    Optimized method of getting to_components chansel
    scott walters   06/23/92    Added static ANSI C prototypes
\*/

class implementation GRowner;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"
#include "godef.h"
#include "grownerdef.h"
#include "grerr.h"
#include "gocmacros.h"

extern IGRint	GRget_to_comp_chansel();
extern IGRint   GRclip_function();

%safe
static IGRint GRcopy_and_connect_owner ();
%endsafe

method GRclip ( IGRlong *msg; 
                struct GRmd_env *mod_env; 
                struct GRmd_env *target_env; 
                IGRchar *prism; 
                struct GRid *inside_id; 
                struct GRid *outside_id;
                struct GRid *overlap_id; 
                IGRlong *clip_flag)
{
    IGRlong              om_msg;
    IGRlong              ret_msg;
    IGRlong              relationship;
    IGRshort             prism_type;
    IGRint               i;
    OMuint               count;
    IGRint               index;
    IGRint               rigid_connect;       /* Flag for channel connect   */
    IGRint               override_connect;    /* Flag for channel connect   */
    IGRint               type;
    IGRint               conn_type;
    IGRint               inside_keep;
    IGRint               outside_keep;   
    IGRint               overlap_keep;
    IGRint               copy_flag;
    IGRlong              local_clip_flag;
    OM_S_CHANSELECT      own_chansel;
    struct GRid          outside_own_id;
    struct GRid          inside_own_id;
    struct GRid          overlap_own_id;
    struct GRid          *p_outside_own_id;
    struct GRid          *p_inside_own_id;
    struct GRid          *p_overlap_own_id;
    struct GRmd_env      local_mod_env;
    struct GRmd_env      local_target_env;
    struct GRclip_args      clip_args;
    struct GRfunction_info  function_info;

    om_msg = OM_S_SUCCESS;
    *msg = MSSUCC;
    index = OM_K_MAXINT;

    GRget_to_comp_chansel ( &own_chansel );

    if (!(*clip_flag & GR_CLIP_NORGCK)) 
    {
        prism_type = (*clip_flag & GR_CLIP_RTPRISM) ?  0 : 1;

        /*
         *  Is the owner within the prism.
         */
        om_msg = om$send ( msg = message GRgraphics.GRprismrel (
                                            &ret_msg,
                                            &mod_env->md_env.matrix_type, 
                                            mod_env->md_env.matrix, 
                                            NULL, 
                                            &prism_type, 
                                            prism, 
                                            &relationship), 
                           targetid = my_id);

        if (om_msg & ret_msg & 1) 
        {
            if (relationship == 1) 
            {
                /*
                 *  The owner is inside the right prism;
                 */
                *msg = GR_I_OBJINSIDE;
                goto FINISH;
            }
            else if (relationship == 0) 
            {
                /* 
                 *  The owner is outside of the right prism.
                 */
                *msg = GR_I_OBJOUTSIDE;
                goto FINISH;
            }
        }
        else 
        {
            *msg = MSFAIL;
            om_msg = OM_S_SUCCESS;
            goto FINISH;
        }
    }

    /*
     *  The owner is overlapping the right prism.
     *
     *  Do not delete the components of this owner.
     *  Clear the no range check flag.
     */
    local_clip_flag = *clip_flag | GR_CLIP_NODEL;
    local_clip_flag &= (0xffffffff ^ GR_CLIP_NORGCK);

    /*
     *  Get the type of channel.
     */
    om_msg = om$send (msg = message GRowner.GRget_channel_type (msg,
                                                                &type, 
                                                                &conn_type), 
                      targetid = my_id);

    if (type == GR_RIGID) 
    {
        local_clip_flag |= GR_CLIP_RIGID;
        local_clip_flag &= (0xffffffff ^ GR_CLIP_FLEXCONN);
    }
    else if (conn_type == GR_OVERRIDE) 
    {
        local_clip_flag |= GR_CLIP_FLEXCONN;
        local_clip_flag &= (0xffffffff ^ GR_CLIP_RIGID);
    }
    else 
    {
        local_clip_flag &= (0xffffffff ^ (GR_CLIP_RIGID | GR_CLIP_FLEXCONN));
    }

    /*
     *  Set up the internal flags.
     */
    p_inside_own_id = NULL;
    p_outside_own_id = NULL;
    p_overlap_own_id = NULL;
    copy_flag = (*clip_flag & GR_CLIP_NODEL) ? TRUE : FALSE;
    rigid_connect = (*clip_flag & GR_CLIP_RIGID) ? GR_RIGID : GR_FLEXIBLE;
    override_connect = (*clip_flag & GR_CLIP_FLEXCONN) ? GR_OVERRIDE : GR_NO_OVERRIDE;

    if (*clip_flag & GR_CLIP_CONSTR_ALL_PIECES) 
    {
        inside_keep =  TRUE;
        outside_keep = TRUE;
        overlap_keep = TRUE;
    }
    else 
    {
        inside_keep = (inside_id) ? TRUE : FALSE;
        outside_keep = (outside_id) ? TRUE : FALSE;
        overlap_keep = (overlap_id) ? TRUE : FALSE;
    }

    overlap_keep = ((*clip_flag & GR_CLIP_OVL_IN) || 
                    (*clip_flag & GR_CLIP_OVL_OUT)) ?  FALSE : overlap_keep;

    if (inside_keep) 
    {
        om_msg = GRcopy_and_connect_owner (&ret_msg, 
                                           OM_Gw_current_OS, 
                                           my_id,
                                           mod_env, 
                                           target_env, 
                                           inside_id, 
                                           rigid_connect, 
                                           override_connect, 
                                           &inside_own_id);
        p_inside_own_id = &inside_own_id;
    }

    if (outside_keep) 
    {
        om_msg = GRcopy_and_connect_owner (&ret_msg, 
                                           OM_Gw_current_OS, 
                                           my_id,
                                           mod_env, 
                                           target_env, 
                                           outside_id, 
                                           rigid_connect, 
                                           override_connect, 
                                           &outside_own_id);
        p_outside_own_id = &outside_own_id;
    }

    if (overlap_keep) 
    {
        om_msg = GRcopy_and_connect_owner (&ret_msg, 
                                           OM_Gw_current_OS, 
                                           my_id,
                                           mod_env, 
                                           target_env, 
                                           overlap_id, 
                                           rigid_connect,
                                           override_connect, 
                                           &overlap_own_id);

         p_overlap_own_id = &overlap_own_id;
    }

    om_msg = om$send (msg = message GRowner.GRget_context(&ret_msg, 
                                                          target_env,
                                                          &local_target_env), 
                      targetid = my_id);

    om_msg = om$send (msg = message GRowner.GRget_context (&ret_msg, 
                                                           mod_env,
                                                           &local_mod_env), 
                      targetid = my_id);

    /*
     *  Get the channel count.
     */
    om_msg = om$get_channel_count(osnum = OM_Gw_current_OS,
                                  objid = my_id, 
                                  p_chanselect = &own_chansel, 
                                  count = &count);
    if (om_msg & 1) 
    {
        clip_args.msg = &ret_msg;
        clip_args.mod_env = &local_mod_env;
        clip_args.target_env = &local_target_env;
        clip_args.prism = prism;
        clip_args.inside_id = p_inside_own_id;
        clip_args.outside_id = p_outside_own_id;
        clip_args.overlap_id = p_overlap_own_id;
        clip_args.clip_flag = &local_clip_flag;

        function_info.md_env = &local_mod_env;
        function_info.pass_to_other_spaces = 0;
        function_info.info = (char *)&clip_args;

        /*
         *  Loop for each component.
         */
        for (i=0; (om_msg & ret_msg & 1) && (i < count); ++i)
        {
            /*
             *  Clip the object placing the inside objects
             *  on the inside owner and the outside objects
             *  on the outside owner and the overlapping objects
             *  on the overlapping owner based on clip flags.
             */
            om_msg = om$send ( msg = message GRgraphics.GRfunction 
                                            (&ret_msg,
                                             GRclip_function, 
                                             (char *)&function_info),
                               p_chanselect = &own_chansel, 
                               from = i, 
                               to = i); 
        }  /* End of for loop   */
            
        if ((om_msg & ret_msg & 1) && (!copy_flag)) 
        {
            om_msg = om$send ( msg = message GRgraphics.GRdelete 
                                                    (msg, &local_mod_env),
                               targetid = my_id);
        }

        if (inside_keep) 
        {
            om$send (msg = message GRowner.GRpost_clip_owner (msg, 
                                                              mod_env,
                                                              target_env, 
                                                              prism, 
                                                              inside_id, 
                                                              outside_id, 
                                                              overlap_id, 
                                                              clip_flag), 
                     targetid = inside_own_id.objid,
                     targetos = inside_own_id.osnum);
        }

        if (outside_keep) 
        {
            om$send (msg = message GRowner.GRpost_clip_owner (msg, 
                                                              mod_env,
                                                              target_env, 
                                                              prism, 
                                                              inside_id, 
                                                              outside_id, 
                                                              overlap_id, 
                                                              clip_flag), 
                     targetid = outside_own_id.objid,
                     targetos = outside_own_id.osnum);
        }

        if (overlap_keep) 
        {
            om$send (msg = message GRowner.GRpost_clip_owner (msg, 
                                                              mod_env,
                                                              target_env, 
                                                              prism, 
                                                              inside_id, 
                                                              outside_id, 
                                                              overlap_id, 
                                                              clip_flag), 
                     targetid = overlap_own_id.objid,
                     targetos = overlap_own_id.osnum);
        }
    }
FINISH:
    GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CLIPPED);
    return (om_msg);
}

/**********************************************************************
   This is a helper function that performs a construct and connect
   of an owner header.
***********************************************************************/


static IGRint GRcopy_and_connect_owner (msg, 
                                        osnum, 
                                        objid, 
                                        mod_env, 
                                        target_env, 
                                        target_id, 
                                        rigid_connect, 
                                        override_connect,
                                        new_id)
    IGRlong           *msg;
    GRspacenum        osnum;
    GRobjid           objid;
    struct GRmd_env   *mod_env;
    struct GRmd_env   *target_env;
    struct GRid       *target_id;
    IGRint            rigid_connect;
    IGRint            override_connect;
    struct GRid       *new_id;
{
    IGRlong           om_msg;
    IGRint            index;

    *msg = MSSUCC;
    index = OM_K_MAXINT;

    /*
     *  Construct a copy of the object.
     */
    new_id->osnum = target_env->md_id.osnum;
    om_msg = om$send (msg = message GRowner.GRcopy_owner ( msg, 
                                                           mod_env, 
                                                           target_env, 
                                                           &new_id->objid),
                      senderid = objid, 
                      targetos = osnum,  
                      targetid = objid);

    if (target_id) 
    {
        om_msg = GRconnect_object (msg, 
                                   new_id->osnum, 
                                   new_id->objid, 
                                   target_id, 
                                   rigid_connect, 
                                   override_connect, 
                                   OM_K_MAXINT, 
                                   OM_K_MAXINT);
    }

    return(om_msg);
}
end implementation GRowner;
