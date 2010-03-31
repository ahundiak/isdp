/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
#include "OMmacros.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */

#include "OMerrordef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include <math.h>
#include "emsmacros_c.h"
#include "EMSbstrim.h"
#include "bsparameters.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bsendpoint.h"
#include "bsbzoverlap.h"

#define TANGENCY_TOL 0.03

EMdecideint (msg_loc, check_overlap,
             csoption,ts, cs, int_point, csi, tsi, classification)
IGRlong *msg_loc;
IGRboolean check_overlap;
IGRshort csoption;
IGRpoint int_point; /* *cutint point */
struct IGRbsp_curve *ts; /* curve against which the classification is to be
                               done */
struct IGRbsp_curve *cs;
struct EMint_info *csi, /* cutting span intersection infor */
                  *tsi; /* test span intersection info */
IGRushort *classification; /* information as to whether the
                                     portion of cutting span being
                                     examined is to the right, left or on
                                     the test span */

{
/*
 * This function decides if there is a cutting intersection or not based
 * on whether end_point is lying on the right or left of the curve. 
 * It expects the following input:
 * either cs vector or int_point and end_point. It first looks at cs vector
 * and sees if it is valid. If not then it expects to find the *cutint
 * point and end_point. 
 * Also the curve against which the classification is to be done needs to
 * be inputted.
 * History:
 *  PP : Creation : 06/01/87
 *  PP : Modified the code to return an intersection of type unknown when
 *       there is a possibility of a tangency.
 *  Sudha   07/08/93        Modified for BSprototypes ansification
 *  SCW     13-Feb-1997     included emsmacros_c.h rather than emsmacros.h
 */

 IGRint 	cpsign;
 IGRboolean     bssts;
 IGRdouble	colintol;
 IGRdouble      cross_prod_value;
 BSrc           rc;

 void		EMget_tangent(); /* Function declarations */
 IGRint		EMcross_prod();
 IGRint		EMdot_prod ();

 *msg_loc = EMS_S_Success;
 *classification = 0;

/*
 * If the two vectors are seperated by an angle less than tangency tol
 * then the intersection type is classified to be unknown
 * so that a higher level routine can handle the classification in a
 * non ambiguous manner.
 */
 
 colintol = TANGENCY_TOL;

 if (!(csi->is_valid & EMIS_TANGENT_VALID))
 {
   if (csi->is_valid & EMIS_PARAMETER_VALID)
   {
   if (cs->order == 2) /* if the order of the cutting span is 2 the tangent
                           vector can be obtained more trivially */
   {
     IGRshort end,
              begin;

     if (csoption == LEFT)
     {
       end = 0;
       begin = 1;
     }
     else if (csoption == RIGHT)
     {
       end = 1;
       begin = 0;
     }
      csi->is_valid |= EMIS_TANGENT_VALID;
      csi->tangent[X] = cs->poles[3*end + X] - cs->poles[3*begin + X];
      csi->tangent[Y] = cs->poles[3*end + Y] - cs->poles[3*begin + Y];
      csi->tangent[Z] = 0.0;
      bssts = BSnorvec (&rc, csi->tangent);
      EMerr_hndlr (!bssts, *msg_loc, EMS_E_Fail, wrapup);
    } 
    else
    {
      IGRboolean reverse;

      reverse = ((csoption == RIGHT) ? 0 : 1); 
           
      EMget_tangent ( msg_loc, cs, &csi->parameter, reverse, csi->tangent);
      EMerr_hndlr (EMis_error(*msg_loc), *msg_loc, EMS_E_Fail, wrapup);
      csi->is_valid |= EMIS_TANGENT_VALID;
     }
    }
   else *msg_loc = EMS_E_InvalidArg;
   }

 if (!(tsi->is_valid & EMIS_TANGENT_VALID))
 {
   if (tsi->is_valid & EMIS_PARAMETER_VALID)
   {
     EMget_tangent (msg_loc, ts, &tsi->parameter, FALSE, tsi->tangent);
     EMerr_hndlr (EMis_error (*msg_loc), *msg_loc, EMS_E_Fail, wrapup);
   }
   else
    *msg_loc = EMS_E_InvalidCase;
   tsi->is_valid |= EMIS_TANGENT_VALID;
 }

/*
 * If the angle between two tangents is less than 0.01 radians then
 * it is considered to be a tangency case, and the intersection if flagged
 * as unknown, so that the same may be treated at a higher level.
 */

 cpsign = EMcross_prod (&colintol, csi->tangent, tsi->tangent, 
                        &cross_prod_value);
 if (cpsign == POSITIVE)
  *classification = EMS_INT_RIGHT;
 else if (cpsign == NEGATIVE)
  *classification = EMS_INT_LEFT;
 else
  { 
    IGRboolean overlap = FALSE;

    IGRdouble end1[4],
              end2[4];

    IGRint    num_end;
    IGRpoint end_pts[4];

    if (check_overlap)
    {
/*
 * Determine if the test span overlaps with the cutting span and 
 * if it does then there is no cutting intersection
 */

    bssts = BSendpoint (&rc, ts, cs, &num_end, end_pts, end1, end2);
    EMerr_hndlr (!bssts, *msg_loc, EMS_E_BSerror, wrapup);

    if (num_end == 2)
    {
     (void) BSbzoverlap (ts, cs, end1, end2, &overlap, &rc);
     EMerr_hndlr (BSERROR(rc), *msg_loc, EMS_E_BSerror,wrapup);
    }
   }

    if (overlap)
     *classification = EMS_INT_BOUNDARY;
    else
     *classification = EMS_INT_UNKNOWN;

} /* end if cpsign == 0) */

wrapup:
 return;
}

