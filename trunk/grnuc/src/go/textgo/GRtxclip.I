/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:       GRtext
     METHOD NAME:       GRclip

     Abstract:   This method implements the clipping operations for
                 text objects. A text object will not be clipped even
                 if it is overlapping the fence.

-----
%SC%    
     GRclip(IGRlong *msg; struct GRmd_env *cur_env; 
            struct GRmd_env *target_env;
            IGRchar  *prism; 
            struct GRid *in_id; 
            struct GRid *out_id;
            struct GRid *ovl_id;
            IGRlong *clip_flags);

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   ------------------------------------
     *cur_env     struct GRmd_env   object's environment
     *target_env  struct GRmd_env   evironment to clip to
     *prism       IGRchar           input prism (right or curve)
     *in_id       struct GRid       id for inside channel
     *out_id      struct GRid       id for outside channel
     *ovl_id      struct GRid       id for overlap channel
     *clip_flags  IGRlong           flags for clipping
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg        IGRlong        completion code
                                    MSSUCC - successful completion
                                    MSFAIL - failure
                                    GR_I_OBJINSIDE - if the object
                                            was totally inside the
                                            right prism
                                    GR_I_OBJOUTSIDE - if the object
                                            was totally outside the
                                            right prism
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
                none.

     Methods:
                none.
-----
%NB%

     NOTES:
                none.
-----
%CH%

     CHANGE HISTORY:
        
        DEK    04/22/87 : Design date.
        WBC    08/16/89 : Added functionality; this was previously
                          a stub method that only returned success.
        SCW    07/22/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
        This method implements the clipping operations for text
objects.  Clipped components fall into three catagories: inside,
outside, and overlap with regard to the input prism.  

    The input object id's, in_id, out_id, ovl_id, will be target ids
to connect the clipped pieces to.  If a particular condition of
clipped pieces is not desired at all, the object id corresponding to
the condition must be NULL.

    The input prism may be either for an IGRrt_prism or an
IGRcv_prism.  The clip_flags indicates which type of prism is sent
used.

    The clip_flags argument is a bit mask indicating several options
for clipping operations.  The following settings are currently
defined:

GR_CLIP_OVL_IN, if set, treat overlap objects as inside
and connect them to the in_id.

GR_CLIP_OVL_OUT, if set, treat overlap objects as outside
and connect them to the out_id.

GR_CLIP_RTPRISM, if set, the prism is right prism, if
clear prism is curve prism

GR_CLIP_NORGCK, should be set only if the user knows the object
overlaps the prism. This prevents unnecessary checking.

GR_CLIP_NODEL, if set, the original object used for 
clipping is preserved;  if clear, it is deleted if and
only if it is clipped.

GR_CLIP_RIGID, if set, call the GRrigidconn method to connect
the clipped pieces to the input id. If clear, call GRflexconn.

GR_CLIP_FLEXCONN, if set, call GRflexconn with the override 
flag set to connect the clipped pieces.

GR_CLIP_CONSTR_ALL_PIECES - if set, all the clipped pieces
will be constructed, but only the pieces that have a valid channel
id will be connected to a channel.  If clear, the only clip pieces
that are constructed are the pieces that have been requested
to be connected to a channel.
----*/
/*EH*/

class implementation GRtext;


#include "grimport.h"
#include "msdef.h"
#include "bs.h"
#include "grerr.h"
#include "gocmacros.h"
#include "OMminimum.h"
#include "godef.h"
#include "grgsdef.h"

/*  USED FOR CLIP INDICATORS  */

#define  OUTSIDE  0
#define  INSIDE   1
#define  OVERLAP  2

method GRclip(IGRlong *msg; struct GRmd_env *cur_env,*target_env;
              IGRchar *prism; struct GRid *in_id, *out_id, *ovl_id;
              IGRlong *clip_flags)
{
    IGRlong       in_out;   /* totally inside/outside flag */
    IGRlong       index;
    IGRlong       OMmsg;    /* OM return value             */
    GRobjid       new_id;
    GRspacenum    new_os;
    struct  GRid  *clp_id;

    /*
     * initialize return codes and working variables
     */

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;
    index = OM_K_MAXINT;

    if (!(*clip_flags & GR_CLIP_NORGCK))
    {
        /*
         * See if the object overlaps the prism. If not, exit.
         */

        IGRlong prism_rel = GO_OVERLAP;
        IGRshort prism_type;

        prism_type = ((*clip_flags & GR_CLIP_RTPRISM) ? GRRIGHT_PRISM : GRCURVE_PRISM);

        om$send(msg = message GRgraphics.GRprismrel
                              (msg,&cur_env->md_env.matrix_type,
                               cur_env->md_env.matrix,
                               &prism_rel,&prism_type,prism,&in_out),
                targetid = my_id);

        if (*msg == GR_E_INV_REQUEST)
        {
            if (in_out == OUTSIDE )
            {
                *msg = GR_I_OBJOUTSIDE;
            }
            else if (in_out == INSIDE)
            {
                *msg = GR_I_OBJINSIDE;
            }
            goto wrapup;
        }
    }    

    if (*clip_flags & GR_CLIP_OVL_IN)
    {
        clp_id = in_id;
    }
    else if (*clip_flags & GR_CLIP_OVL_OUT)
    {
        clp_id = out_id;
    }
    else
    {
        clp_id = ovl_id;
    }

    if (clp_id)
    {
        if (*clip_flags & GR_CLIP_NODEL)
        {
            /*
             * construct a copy of the original object
             * and connect it to the input channel
             */

            OMmsg = om$send(msg = message GRgraphics.GRcopy(msg,cur_env,
                                                            target_env,
                                                            &new_id),
                            targetid = my_id);

            if (!(1 & OMmsg & *msg))
            {
                goto wrapup;
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
            /*
             *  make a rigid connection between 
             *  the input id and the original object 
             */

            OMmsg = om$send(msg = message GRconnector.GRrigidconn(msg,clp_id,
                                                                  &index),
                            targetid = new_id,
                            targetos = new_os);
        }
        else 
        {
            IGRlong     flexflag = TRUE;

            /*
             *  make a flexible connection between
             *  the input id and the original object
             */

            OMmsg = om$send(msg = message GRconnector.GRflexconn(msg,
                                                                 &flexflag,
                                                                 clp_id,
                                                                 &index,
                                                                 &index),
                            targetid = new_id,
                            targetos = new_os);
        }
    }

wrapup:

    GR_NOTIFY_LISTENERS (msg,&OMmsg,GR_CLIPPED);

    return (OMmsg);
}

end implementation GRtext;
