/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

# include "EMS.h"
# include "emsmacros.h"
# include "EMSmsgdef.h"
# include "EMSbnddef.h"
# include "igrdef.h"
# include "godef.h"
# include "grerr.h"
# include "msdef.h"
# include "emserr.h"
# include "gocmacros.h"     /* GR_NOTIFY_LISTENERS  */
# include "grgsdef.h"       /* GO_...               */

# define RT_PRISM        0
# define CV_PRISM        1
# define OUTSIDE         0
# define INSIDE          1
# define OVERLAP         2

method GRclip(IGRlong *EMmsg; struct GRmd_env *env,*target_env;
              IGRchar *prism; struct GRid *in_id; struct GRid *out_id;
              struct GRid *ovl_id; IGRlong *clip_flags)
/*
History

    NP  21 Aug 1992 Modified for ANSI compliance.
    RC  16 Mar 1989 Fixed a few bugs.
    AIC 13 Oct 1988 Rewrite for EMS 1.2.0
    AIC 06 Jan 1988 Rewrite for EMS 1.1.0
    RC  17 Jun 1987 Creation Date

Description
        This method implements the clipping operations for
    surfaces (including composite surfaces and solids). The
    surface will not be clipped even if it is overlapping the
    fence. An overlapping surface will be treated as a surface
    outside the prism unless the GR_CLIP_OVL_IN flag is set, in
    which case overlapping surfaces will be treated as inside.

        The input pointer to a prism may be either for an
    IGRrt_prism clipping against a polygon or an IGRcv_prism
    for clipping against a closed B-spline curve, depending
    on how the clip_flags argument is set.

Diagnostics
    This method returns the following return codes:
      GR_I_OBJINSIDE - if the object was totally inside the
                       right prism
      GR_I_OBJOUTSIDE - if the object was totally outside the
                        right prism
      EMS_S_Success   - everything successfull
*/
{ struct GRid *clp_id;
  IGRlong     sts;      /* OM return value      */
  IGRlong      in_out;   /* inside/outside flag  */
  GRobjid     new_id;
  GRspacenum  new_os;
  IGRlong     index = OM_K_MAXINT;

  /*
   * Initialize
   */

  *EMmsg = MSSUCC;
  sts = OM_S_SUCCESS;

  if (!(*clip_flags & GR_CLIP_NORGCK))
  {
    IGRlong     prism_rel;
    IGRshort    type_prism;

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

    if(! (1 & *EMmsg & sts)) goto wrapup;

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
       * Construct a copy of the original object
       * and connect it to the input channel
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
       * Make a rigid connection between 
       * the input id and the original object 
       */
      sts = om$send(msg=message GRconnector.GRrigidconn(EMmsg, clp_id,
                    &index), targetid = new_id, targetos = new_os);
  }
  else 
  {
      IGRlong     flexflag;

      /*
       * Make a flexible connection between
       * the input id and the original object
       */
      flexflag = TRUE;
      sts=om$send(msg=message GRconnector.GRflexconn(EMmsg,
                  &flexflag, clp_id, &index, &index),
                  targetid = new_id, targetos = new_os);
   }

wrapup:
  GR_NOTIFY_LISTENERS(EMmsg, &sts, GR_CLIPPED);
  EMWRAPUP(*EMmsg, sts, "EMSsurface.GRclip")
  return(sts);
}

end implementation EMSsurface;
