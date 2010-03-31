/* ###################   APOGEE COMPILED   ################## */
class implementation GRcurve;

/*
  HISTORY

        Sudha   07/08/93        Modified for BSprototypes ansification
*/

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsdistptpt.h"

/*
 * This function determines whether or not the input point, pnt, is 
 * close (within basis tol) to the start point or the end point of
 * the object identified by objid.  It takes in the senderid, my_id,
 * and the environment, md_env.  If pnt is on the start of the curve
 * then start_flag = TRUE.  If pnt is on the end of the curve, then
 * end_flag = TRUE; else they're FALSE.    dhm 10/22/87.
 */

IGRlong EFclose_endpnt(msg, my_id, md_env, objid, pnt, start_flag,
                       end_flag)
  IGRlong	*msg;
  GRobjid	my_id;
  struct GRmd_env	*md_env;
  GRobjid	objid;
  IGRpoint	pnt;
  IGRboolean		*start_flag, *end_flag;
{
  IGRlong		msg_loc, status;
  IGRdouble		tol, dist_start, dist_end;
  IGRpoint		startpnt, endpt;
  IGRchar		errmsg[EMMAXERRMSG_LEN];

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"EFclose_endpnt error\n");
  *start_flag = FALSE;
  *end_flag = FALSE;

  status = BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, tol);

  status = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                         &md_env->md_env.matrix_type,
                         md_env->md_env.matrix, startpnt, endpt),
                   senderid = my_id,
                   targetid = objid,
                   targetos = md_env->md_id.osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  dist_start = BSdistptpt(&msg_loc, pnt, startpnt);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  dist_end = BSdistptpt(&msg_loc, pnt, endpt);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  if (dist_start < tol)
     *start_flag = TRUE;
  else if (dist_end < tol)
     *end_flag = TRUE;

  ret_end:
    return(status);

}

end implementation GRcurve;
