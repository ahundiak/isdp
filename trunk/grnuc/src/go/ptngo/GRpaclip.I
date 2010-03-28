/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRpa.GRclip

Description
        Clipping is allowable on a patterned object only for plotting. 
        In other cases the entire pattern (or a copy) is returned. 

History
        mrm     04/25/90    creation
        scw     06/28/92    ANSI conversion
*/

class implementation GRpa;

#include "grimport.h"
#include "grerr.h"
#include "msdef.h"
#include "gocmacros.h"

#define  OVERLAP  2
#define  INSIDE   1
#define  OUTSIDE  0

method GRclip (IGRlong *msg;
               struct GRmd_env *cur_env, *target_env;
               IGRchar *prism; 
               struct GRid *inside_id, *outside_id, *ovl_id;
               IGRlong *clip_flags)
{
    IGRshort        type_prism;
    IGRint          i;
    OMuint          count;
    IGRlong         flex, 
                    rel, 
                    j, 
                    sts = OM_S_SUCCESS;
    struct GRid    *owner_id;
    OMuword         new_os;
    OM_S_OBJID      new_id;
    OM_S_CHANSELECT comp_chan;      /* to master & components */

    flex = 1;
    j = OM_K_MAXINT;

    type_prism = !(*clip_flags & GR_CLIP_RTPRISM);

    GRget_to_comp_chansel (&comp_chan);

    if (*clip_flags & GR_CLIP_OVL_IN)
    {
        owner_id = inside_id;
    }
    else if (*clip_flags & GR_CLIP_OVL_OUT)
    {
        owner_id = outside_id;
    }
    else
    {
        owner_id = ovl_id;
    }

    /*
        send GRprismrel to the patterned object to determine the
        pattern's relationship with the prism
    */

    sts = om$send (msg = message GRvg.GRprismrel
                        (msg, &cur_env->md_env.matrix_type,
                         cur_env->md_env.matrix, NULL, &type_prism,
                         prism, &rel),
                   p_chanselect = &comp_chan,
                   from = 0,
                   to = 0);

    if (sts & *msg & 1)
    {
        switch (rel)     
        {
            case OUTSIDE:   

                *msg = GR_I_OBJOUTSIDE;
                break;

            case INSIDE:

                *msg = GR_I_OBJINSIDE;
                break;

            case OVERLAP:

                if (*clip_flags & GR_CLIP_FORPLOT)
                {
                    om$get_channel_count (objid = my_id,
                                          p_chanselect = &comp_chan,
                                          count = &count);
                    /*
                        since the patterned object is in the rtree and
                        will receive its own plotyourself, start with
                        the first pattern component
                    */

                    for (i = 1; i < count; i++)
                    {
                        /* clip each pattern component */

                        sts = om$send (msg = message GRvg.GRclip
                                            (msg, cur_env, target_env,
                                             prism, inside_id, outside_id,
                                             ovl_id, clip_flags),
                                       p_chanselect = &comp_chan,
                                       from = i, to = i);

                        if ((sts & 1) && (*msg == GR_I_OBJINSIDE))
                        {
                            /*
                                The component is entirely within the
                                prism.  Since GUprocessplot (the calling
                                routine in this case) expects objects
                                either entirely within the prism (which
                                it adds to a list for later processing)
                                or clipped objects on a channel, this
                                component must be copied and added to a
                                channel in order to be sent the plot
                                message.  This assumes that the
                                connection is to be flexible. 
                            */

                            sts = om$send (msg = message GRgraphics.GRcopy
                                                (msg, cur_env,
                                                 target_env, &new_id),
                                           p_chanselect = &comp_chan,
                                           from = i, to = i);

                            if (sts & *msg & 1)
                            {
                                om$send (msg = message GRconnector.GRflexconn
                                              (msg, &flex, owner_id, &j, &j),
                                         targetid = new_id,
                                         targetos = target_env->md_id.osnum);
                            }
                        }
                    }
                }
                else
                {
                    /*
                        The pattern will not truly clip; however, it may
                        be manipulated intact.
                    */

                    if (owner_id)
                    {
                        if (*clip_flags & GR_CLIP_NODEL)
                        {
                            /* copy the pattern */

                            sts = om$send (msg = message GRgraphics.GRcopy
                                                (msg, cur_env,
                                                 target_env, &new_id),
                                           targetid = my_id);

                            if (!(sts & *msg & 1))
                            {
                                goto finish;
                            }
                            new_os = target_env->md_id.osnum;
                        }
                        else
                        {
                            new_id = my_id;
                            new_os = cur_env->md_id.osnum;
                        }

                        if (*clip_flags & GR_CLIP_RIGID)
                        {
                            sts = om$send (msg = message GRconnector.GRrigidconn
                                                (msg, owner_id, &j),
                                           targetid = new_id,
                                           targetos = new_os);
                        }
                        else 
                        {
                            sts = om$send (msg = message GRconnector.GRflexconn
                                                (msg, &flex, owner_id, &j, &j),
                                            targetid = new_id,
                                            targetos = new_os);
                        }
                    }
                }
                break;

            default:

                *msg = MSINARG;
        }
    }

    GR_NOTIFY_LISTENERS (msg, &sts, GR_CLIPPED);

finish:

    return (sts);
}

end implementation GRpa;
