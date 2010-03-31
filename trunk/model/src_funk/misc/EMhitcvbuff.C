/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
  DESCRIPTION

    Given a curve buffer and the locate information as input, this
    function determines if this is a hit (within the locate tolerance
    specified) or not. The return value of this function is TRUE if
    it was a hit and FALSE otherwise. If this was a hit, the function
    will return geometric information in the relevant fields of one of
    the output structures.

  NOTES

    This method is designed to be the super-set of EMisoCurveLocate.
    Ultimately, there should be just this one function in the system.

  HISTORY

    AIC :  26 Apr 89 :  Fixed EFinterpretRelation call.
    SS  :  04/05/88  :  Creation. 
*/

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "bserr.h"
#include "EMSlcdef.h"
#include "EMSlc.h"

IGRboolean EMhitcvbuff (msg, cv, cvtype, cvl, lcin, lcout)
IGRlong *msg;
struct IGRbsp_curve *cv;
IGRuchar cvtype;
struct GRlc_cvl *cvl;
struct EMSlcinput *lcin;
struct EMSlcoutput *lcout;
{
  IGRboolean stat_func, hit;
  IGRboolean inside, outside, overlap;
  IGRushort options;
  IGRshort relation;
  IGRlong msg_loc, *cvlmsg, OM_stat;
  IGRdouble mincvpar;
  enum GRlocate_types lctype;
  void EFisoCurveLocate(), EFinterpretRelation();

  *msg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;
  cvlmsg = &cvl->msg;
  *cvlmsg = MSSUCC;

  options = lcin->options;
  hit = FALSE;

  EFisoCurveLocate (&msg_loc, cv, cvl, &lcout->locobj, 
   options & EMSlcopt_rangechk, &mincvpar, &relation);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  lctype = cvl->attributes.type;
  if (lctype == GR_bl_loc)
    {
    /*
     * This is a bore-line locate. The only relationship possible is a
     * hit or not a hit. If it is a hit, then update the output
     * arguments.
     */

    if (relation == HIT)
      {
      hit = TRUE;
      lcout->locobj.geom_parms.u = mincvpar;
      lcout->locobj.geom_parms.polygon_inx = 0;
      lcout->props = EMSlcoutput_located;
      lcout->locdist = 0.0;
      }
    else
      lcout->props &= ~EMSlcoutput_located;
    }
  else
    {
    IGRdouble t = 0.;

    /*
     * Call the function to interpret the relationship between the user-input
     * and the curve. Update the output accordingly.
     */

    inside = lcout->props & EMSlcoutput_inside;
    outside = lcout->props & EMSlcoutput_outside;
    overlap = lcout->props & EMSlcoutput_overlap;

    EFinterpretRelation(&msg_loc,
                        relation,
                        lctype,
                        0,
                        NULL,
                        t,
                        &lcin->prism_rel,
                        &inside,
                        &outside,
                        &overlap,
                        &hit);

    if (inside)
      lcout->props |= EMSlcoutput_inside;
    else
      lcout->props &= ~EMSlcoutput_inside;

    if (outside)
      lcout->props |= EMSlcoutput_outside;
    else
      lcout->props &= ~EMSlcoutput_outside;

    if (overlap)
      lcout->props |= EMSlcoutput_overlap;
    else
      lcout->props &= ~EMSlcoutput_overlap;

    if (hit)
      lcout->props |= EMSlcoutput_located;
    else
      lcout->props &= ~EMSlcoutput_located;
    }

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, OM_stat, "EMhitcvbuff");
  if (EMSerror (*msg))
    *cvlmsg = MSFAIL;
  return (hit);
}
