/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# define RT_PRISM        0
# define CV_PRISM        1

# include "emsmacros.h"
# include "emsdef.h"
# include "EMSbnddef.h"
# include "EMSreleased.h"   /* RELEASED         */
# include "EMSlcdef.h"      /* relation codes   */
# include "EMSfrtdef.h"     /* RLT_BUFFER_SIZE  */
# include "EMSlogic.h"      /* EMSmsgReport     */
# include "EMStypedef.h"    /* EMSmsgReport     */
# include "EMScmacros.h"    /* EMSmsgReport     */
# include "igrtypedef.h"    /* for gocmacros.h  */
# include "gocmacros.h"     /* GRgetabsg macro  */
# include "igr.h"           /* IGRrt_prism      */
# include "madef.h"
# include "bserr.h"
# include "msdef.h"
# include "OMprimitives.h"
# include "dpmacros.h"
# include <stdio.h>
# include "OMmacros.h"
# include "grgsdef.h"

extern IGRchar  EMSrltBuffer[RLT_BUFFER_SIZE];

from EMSboundary    import  EMbdrylocate;
from EMSgradata     import  EMlocate;

method GRprismrel(IGRlong *EMmsg; IGRshort *mx_type; IGRmatrix matrix;
                  IGRlong *prism_rel; IGRshort *prism_type;
                  IGRchar *prism; IGRlong *relation)
{
/*
 Abstract

    This method defines the surface's relationship to a prism.

 Arguements

    mx_type, matrix - input
        Matrix and amtrix type.

    prism_type, prism - input
        Prism and prism type.

    relation - output
        Relationship of the surface to the prism.

 Algorithm

 Return Status

 Bugs

 Notes

    Curve prisms are not yet supported.

 Examples

 History

    ADZ     07-Sep-95	    When the GRprismrel is inside an event asked twice
		 	    for the identical object, the GRgetabsg function
			    check allways reutrs possitive even when previous
			    calls got invalid output.

    GVK     18-Mar-94       If the prism_rel is NULL treat it as true
			    relationship.

    NP      25-Aug-92 	    Modified for ANSI compliance. "mx_type", which comes in
			    as a pointer to IGRshort, is cast as pointer to IGRint,
			    when passed to EMgetRuleLineTable. Also "rlt" is
			    correctly typecast. Other typecasts.
    Jack    06-Feb-92       sizeof(matrix) was returning 4 since OPP
                            replaces IGRmatrix matrix with
                            long float *matrix.
    Jack    21-Aug-91       Initialized the cvl structure with the
                            matrix and matrix type passed in.
    AIC     20-July-91      Make rule lines on/off window-specific.
    Jack    05-June-91      Only deal with rule lines if rule lines are
                            on.  2.0.1 Horizon Loops.
    AIC     17 Apr 89       Handle new EMSsubbs.EMgetRuleLineTable
                            nat_edges argument.
    RC      13 Mar 89       Fixed bugs and return realtive relationship
                            if asked for.
    AIC     06 Apr 88       Do not return OM_I_STOP_SENDING
    AIC     15 Jul 87       Use rule line tables (Complete rewrite)
    RC      06/17/87        Creation Date
*/
  IGRlong                   sts;
  struct IGRbsp_surface     *surface;
  struct IGResqs            *rlt;
  struct GRlc_cvl           cvl;
  struct IGResbs            attr;
  OM_S_CHANSELECT           to_helpers;
  IGRboolean                inside, outside, overlap, was_located;
  IGRlong 		    prismrel;
  extern IGRlong            GRcheckrel();
  extern IGRint             EFrule_lines_on_off();
  extern void               EMSsubbs_get_locate_window();

  IGRint     tmp=0;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  surface = NULL;
  rlt = (struct IGResqs *)EMSrltBuffer;
  inside = outside = overlap = was_located = FALSE;
  EMmake_chanselect(EMSrequester_to_helpers, &to_helpers);

  /*
   * Get my geometry
   * 		ADZ - OLD VERSION -- (09/07/95)
   * GRgetabsg(EMmsg, mx_type, matrix, (IGRchar **) &surface, i);
   * if(! (1 & *EMmsg)) goto wrapup;
   *
   *		ADZ - ELD OLD VERSION --
   */
  sts =
  om$send(	mode = OM_e_wrt_object,
		msg = message GRvg.GRgenabsg(	EMmsg,
						mx_type,
						matrix,
						(IGRchar **) &surface ),
		targetid = my_id );
  if(! (1 & sts & *EMmsg)) goto wrapup;

  /*
   * Construct a bogus cvl (just enough info to do the right prism locate)
   */

  cvl.module.md_env.matrix_type = *mx_type;
  OM_BLOCK_MOVE(matrix,cvl.module.md_env.matrix,(sizeof(IGRdouble) * 16));

  switch(*prism_type)
  {
    case RT_PRISM:
      cvl.attributes.type = GR_rp_loc;
      {
        struct IGRrt_prism  *rt_prism;

        rt_prism = (struct IGRrt_prism *) prism;
        cvl.attributes.acc_rt_prism = *rt_prism;

      }
      break;

    case CV_PRISM:
      cvl.attributes.type = GR_cv_loc;
      {
        struct IGRcv_prism  *cv_prism;

        cv_prism = (struct IGRcv_prism *) prism;
        cvl.attributes.acc_cv_prism = *cv_prism;
      }
      break;

    default:
      *EMmsg = EMS_E_InvalidArg;
      goto wrapup;
  }

  /*
   * * If the prism_rel is null treat it as true relationship.
   *   Sending NULL down will cause core dumps -gvk 3/18/94
   */
  prismrel = (prism_rel ? *prism_rel : TRUE_REL);

  /* KLUGE */
  EMSsubbs_get_locate_window(&cvl.button.objid, &cvl.button.objid);

  /*
   * If the prism is on, classify the prism.
   */
  sts = om$send(msg = message EMSsubbs.GRgetattr(EMmsg,
                (IGRchar *) &attr), targetid = my_id);
  if(! (1 & *EMmsg & sts)) goto wrapup;

  if(attr.is_polydis)
  {
    void      EFpolygonLocate();

    EFpolygonLocate(EMmsg, surface, NULL, &cvl, &prismrel, &inside,
                    &outside, &overlap, &was_located);
    if(! (1 & *EMmsg)) goto wrapup;
  }

  if(! was_located)
  {
    OM_S_CHANSELECT     to_loopset;
    struct GRid         window_id;
    struct EMSlcinput   lcin;
    struct EMSlcoutput  lcout;
    struct EMSsfinfo    sfinfo;
    void                EMSsubbs_get_locate_window();

    /*
     * Try the boundaries.
     */
    EMSsubbs_get_locate_window(&window_id.objid, &window_id.osnum);

    EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);

    sfinfo.geom = surface;
    sfinfo.props = ME.GRgraphics->properties;
    sfinfo.symb.display_attr = ME.GRvg->display_attr;
    sfinfo.symb.level = me->level;

    lcin.options = EMSlcopt_hitormiss | EMSlcopt_rangechk;
    lcin.eligfunc = NULL;
    lcin.eligfunc_args = NULL;
    lcin.more_info = NULL;

    lcout.props = NULL;

    sts = om$send(msg = message EMSboundary.EMbdrylocate(
                    EMmsg,
                    &sfinfo,
                    &lcin,
                    &cvl,
                    NULL, /* range_key */
                    &lcout),
                  p_chanselect = &to_loopset);
    if(sts IS OM_I_STOP_SENDING) sts = OM_S_SUCCESS;
    if(! ( 1 & sts)) goto wrapup;

    was_located = (lcout.props & EMSlcoutput_located) ? TRUE : FALSE;
    inside = (lcout.props & EMSlcoutput_inside) ? TRUE : FALSE;
    outside = (lcout.props & EMSlcoutput_outside) ? TRUE : FALSE;
    overlap = (lcout.props & EMSlcoutput_overlap) ? TRUE : FALSE;

    if(! was_located)
    {
      /*
       * Attempt to use graphics data objects
       */
      *EMmsg = EMS_I_NoResponse;
      sts = om$send(msg = message EMSgradata.EMlocate(
                        EMmsg,
                        surface,
                        NULL,
                        &cvl,
                        &prismrel,
                        &inside,
                        &outside,
                        &overlap,
                        &was_located,
                        &window_id),
                    p_chanselect = &to_helpers);
      if(sts IS OM_W_UNKNOWN_MSG) sts = OM_S_SUCCESS;
      if(! (1 & *EMmsg & sts)) goto wrapup;

      if(*EMmsg IS EMS_I_NoResponse &&
         EFrule_lines_on_off(cvl.button.objid, cvl.button.osnum))
      {
        void    EFlocateRLT();
        IGRuint  ls_count;

        /*
         * No reponse from graphics data objects -- use my rule line table
         */
        om$get_channel_count(object = me,
                             p_chanselect = &to_loopset,
                             count = &ls_count);

        sts = om$send(msg = message EMSsubbs.EMgetRuleLineTable(
                        EMmsg,
                        ls_count ? FALSE : TRUE,
                        NULL,
                        NULL,
                        surface,
                        (IGRint *)mx_type,
                        matrix,
                        EMSrltBuffer,
                        RLT_BUFFER_SIZE,
                        (struct IGResqbs **)&rlt),
                      targetid = my_id);
        if(! (1 & *EMmsg & sts)) goto wrapup;

        EFlocateRLT(EMmsg, rlt, surface, NULL, &cvl, &prismrel, &inside,
                    &outside, &overlap, &was_located);
      }
    }
  }

  /*
   * Determine relationship
   */

  *relation = overlap ? OVERLAP : (inside ? INSIDE : OUTSIDE);

  /*
   * Convert true relationship into relative relationship, if asked for
   */

  sts = GRcheckrel (EMmsg, &prismrel, relation);

wrapup:
  if(rlt ISNT (struct IGResqs *)EMSrltBuffer) om$dealloc(ptr = rlt);
/*
  EMSmsgReport(sts, " in EMSsubbs.GRprismrel", FALSE);
  if EMSmsgReport(*EMmsg, " in EMSsubbs.GRprismrel", FALSE)
    sts = OM_E_ABORT;
*/
  return(sts);
}

end implementation EMSsubbs;
