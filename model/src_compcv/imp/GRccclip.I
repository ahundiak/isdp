class implementation GRcompcurve;

#include "EMScc.h"
# include "emsmacros.h"
# include "EMSmsgdef.h"
# include "EMSbnddef.h"
# include "igrdef.h"
# include "godef.h"
# include "grerr.h"
# include "msdef.h"
# include "emserr.h"
# include "gocmacros.h"     /* GR_NOTIFY_LISTENERS  */
# include "grgsdef.h"

# define RT_PRISM        0
# define CV_PRISM        1
# define OUTSIDE         0
# define INSIDE          1
# define OVERLAP         2
# define ALL3            3

method GRclip(IGRlong *EMmsg; struct GRmd_env *env,*target_env;
              IGRchar *prism; struct GRid *in_id; struct GRid *out_id;
              struct GRid *ovl_id; IGRlong *clip_flags)
/*
History

    AIC     06 January 88   Rewrite for EMS 1.1.0
    RC      06/17/87        Creation Date

Description
        This method implements the clipping operations for
    composite curves. A composite curve will not be clipped even
    if it is overlapping the fence.

        The input pointer to a prism may be either for an
    IGRrt_prism clipping against a polygon or an IGRcv_prism
    for clipping against a closed B-spline curve, depending 
    on how the clip_flags argument is set.
        
    The clip_flags argument is a bit mask indicating several
    options for clipping operations.  The following settings 
    are currently defined:

    GR_CLIP_RTPRISM, if set, the pointer to prism is cast to
    an IGRrt_prism structure and clipping is performed 
    accordingly, otherwise the pointer to prism is cast to
    an IGRcv_prism structure and clipping is performed
    accordingly.

    GR_CLIP_NODEL, if set, the original object used for 
    clipping is preserved, otherwise it is deleted.  

    GR_CLIP_OVL_IN, if set, treat overlap objects as inside
    and connect them to the in_chan, otherwise connect the
    overlap objects to the ovl_chan.

    GR_CLIP_OVL_OUT, if set, treat overlap objects as outside
    and connect them to the out_chan, otherwise connect the
    overlap objects to the ovl_chan.

    GR_CLIP_NORGCK, if set, the step for comparing the object
    range with the prism range is skipped.  If this step is 
    skipped, it is up to the user of this method to insure 
    that an overlap condition exists between the original 
    object and the prism (for clipping to occur).

Diagnostics
    This method returns the following return codes:
      GR_I_OBJINSIDE - if the object was totally inside the
                       right prism
      GR_I_OBJOUTSIDE - if the object was totally outside the
                        right prism
      EMS_S_Success   - everything successfull
*/
{
  IGRlong     prism_rel;
  struct GRid *clp_id;
  IGRlong     index;
  GRobjid     new_id;
  IGRlong     sts;                    /* OM return value              */
  IGRlong     in_out;                 /* totally inside/outside flag  */
  GRspacenum  new_os;
  IGRshort    type_prism;

  /*
   *  initialize return codes and working variables
   */

  *EMmsg = MSSUCC;
  sts = OM_S_SUCCESS;
  index = OM_K_MAXINT;

  if (!(*clip_flags & GR_CLIP_NORGCK))
  {
   prism_rel = GO_OVERLAP;
   type_prism = (*clip_flags & GR_CLIP_RTPRISM) ? RT_PRISM : CV_PRISM;

   sts = om$send(msg = message GRgraphics.GRprismrel(EMmsg,
                 &env->md_env.matrix_type, env->md_env.matrix,
                 &prism_rel, &type_prism, prism, &in_out),
                 targetid = my_id);

   if (*EMmsg == GR_E_INV_REQUEST)
   {
     *EMmsg = (in_out == INSIDE) ? GR_I_OBJINSIDE : GR_I_OBJOUTSIDE;
     goto wrapup;
   } 
   if(! (1 & sts & *EMmsg)) goto wrapup;

  } /* if (!(*clip_flags & GR_CLIP_NORGCK)) */

  if (in_id)
   clp_id = in_id;
  else if (out_id)
   clp_id = out_id;
  else
   clp_id = ovl_id;


  if(*clip_flags & GR_CLIP_NODEL)
  {
      /*
       *  construct a copy of the original object
       *  and connect it to the input channel
       */
      sts = om$send(msg = message GRgraphics.GRcopy(EMmsg, env,
                    target_env, &new_id), targetid = my_id);
      if(! (1 & sts & *EMmsg)) goto wrapup;

      new_os = target_env->md_id.osnum;
  }
  else
  {
      new_id = my_id;
      new_os = env->md_id.osnum;
  }

  if(*clip_flags & GR_CLIP_RIGID)
  {
      /*
       *  make a rigid connection between 
       *  the input id and the original object 
       */
      sts = om$send(msg=message GRconnector.GRrigidconn(EMmsg, clp_id,
                    &index), targetid = new_id, targetos = new_os);
      goto wrapup;
  }
  else 
  {
      IGRlong     flexflag = TRUE;

      /*
       *  make a flexible connection between
       *  the input id and the original object
       */
      sts=om$send(msg=message GRconnector.GRflexconn(EMmsg,
                  &flexflag, clp_id, &index, &index),
                  targetid = new_id, targetos = new_os);
      goto wrapup;
  }

wrapup:
  GR_NOTIFY_LISTENERS(EMmsg, &sts, GR_CLIPPED);
  EMWRAPUP(*EMmsg, sts, "GRcompcurve.GRclip")
  return(sts);
}

end implementation GRcompcurve;
