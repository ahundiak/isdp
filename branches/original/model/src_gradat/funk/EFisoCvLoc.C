#include "EMS.h"
# include "OMlimits.h"          /* GRlc...          */
# include "OMminimum.h"         /* GRlc...          */
# include "igetypedef.h"        /* GRlc...          */
# include "igrtypedef.h"        /* IGR...           */
# include "igr.h"               /* IGR...           */
# include "gr.h"                /* GRlc...          */
# include "igrdp.h"             /* IGResqbs         */
# include "dp.h"                /* GRlc...          */
# include "madef.h"             /* GRlc...          */
# include "godef.h"             /* GRlc...          */
# include "go.h"                /* GRlc...          */
# include "ex.h"                /* GRlc...          */
# include "griodef.h"           /* GRlc...          */
# include "grio.h"              /* GRlc...          */
# include "lcdef.h"             /* GRlc...          */
# include "lc.h"                /* GRlc...          */
# include "msdef.h"             /* MSSUCC           */
# include "EMSmsgdef.h"         /* EMS error codes  */
# include "EMSlogic.h"          /* EMSmsgReport     */
# include "EMStypedef.h"        /* EMSmsgReport     */
# include "EMScmacros.h"        /* EMSmsgReport     */
# include "bstypes.h"           /* BSrc             */
# include "bserr.h"             /* BS...            */

#include "malncuber.h"
#include "bsmdptcvbx.h"
#include "bscvincvfnc.h"
#include "bscv_in_fnc.h"
#include "bsbx2.h"

/*
  HISTORY

	Sudha   25-Jun-93       Modified for BSprototype ansification
*/

void EFisoCurveLocate(EMmsg, curve, cvl, loc_parms, check_range,
                      intersection_param, relation)

IGRlong                 *EMmsg;
struct IGRbsp_curve     *curve;
struct GRlc_cvl         *cvl;
struct GRlc_info        *loc_parms;
IGRboolean              check_range;
IGRdouble               *intersection_param;
IGRshort                *relation;

{
  GRrange   range;
  IGRlong   sts;
  BSrc      rc;


  /*
   * Initialize
   */
  *EMmsg = MSSUCC;

  switch(cvl->attributes.type)
  {
    case GR_bl_loc:
      if(check_range)
      {
        /*
         * Get the range of the curve
         */
        sts = BSbx2(&rc, &curve->num_poles, (IGRpoint *)curve->poles,
                    curve->weights, range, &range[3]);
        if(! sts || (rc ISNT BSSUCC)){*EMmsg = EMS_E_Fail;goto wrapup;}

        /*
         * See if the locate range overlaps the range of the curve
         */
        MAlncuberel(EMmsg, &cvl->attributes.acc_line, range, &range[3],
                    &cvl->attributes.acc_tolerance, relation);
        if(! (1 & *EMmsg)) goto wrapup;
      }
      else *relation = 1;

      if(*relation IS 1)
      {
        /*
         * Intersect the bore line box with the curve
         */
        BSmdptcvbx(curve, cvl->attributes.acc_line.point1,
                   cvl->attributes.acc_line.point2,
                   cvl->attributes.acc_tolerance, intersection_param,
                   loc_parms->proj_pnt, relation, &rc);
        if(rc ISNT BSSUCC) { *EMmsg = EMS_E_Fail; goto wrapup; }
      }
      break;

    case GR_rp_loc:
    {
      IGRint    ind;
      BSrc      rc;

      /*
       * Intersect the curve and the right prism
       */
      BScv_in_fnc(&cvl->attributes.acc_rt_prism, curve, &ind, &rc);
      if(rc != BSSUCC) { *EMmsg = EMS_E_Fail; goto wrapup; }
      *relation = (IGRshort) ind;
      break;
    }

    case GR_cv_loc:
    {
      IGRint    ind;
      BSrc      rc;

      /*
       * Intersect the curve and the right prism
       */
      BScvincvfnc(&cvl->attributes.acc_cv_prism, curve, &ind, &rc);
      if(rc != BSSUCC) { *EMmsg = EMS_E_Fail; goto wrapup; }
      *relation = (IGRshort) ind;
      break;
    }

    default:
      *EMmsg = EMS_E_InvalidArg;
  }

wrapup:
  if EMSmsgReport(*EMmsg, "EFisoCurveLocate", FALSE)
    *EMmsg = EMS_S_Success;
}
