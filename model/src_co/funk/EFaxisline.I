/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This function is analogous to EFboreline, except that it produces
    the line in the X or the Y (as opposed to the boreline - Z) direction
    of a given view.

  HISTORY

    SS  :  10/27/89  :  Creation
    Sudha   06/02/93        modified to include for BSprototype headers
*/

class implementation Root;

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "maidmx.h"
#include "bsnorvec.h"

#define X 0
#define Y 1
#define Z 2

#define XCOMP1 0
#define XCOMP2 1
#define XCOMP3 2

#define YCOMP1 4
#define YCOMP2 5
#define YCOMP3 6

#define ENLARGE_FACTOR  10e6

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from IGEgragad import DPinrot;

IGRboolean EFaxisline (msg, event, xaxis, axisline)
IGRlong *msg;
struct GRevent *event;         
IGRboolean xaxis;
struct IGRline *axisline;
{
  IGRboolean stat_func;
  IGRint i, dum, buffsize;
  IGRlong stat_OM, msg_loc;
  IGRdouble *pt;
  IGRvector vec;
  IGRmatrix view_matrix;
  struct EX_button button;

  /* 
   * Get the rotation matrix from view. If this fails, it is probably because
   * the point in the event did not have an associated view. In this case, try
   * and use the last point input to get the view matrix. Even if this
   * does not work, use identity matrix (top view).
   */

  stat_OM = om$send(msg = message IGEgragad.DPinrot(&msg_loc, view_matrix),
             targetid = event->event.button.objid,
             targetos = event->event.button.osnum, senderid = NULL_OBJID);
  if (EMSerror (stat_OM & msg_loc))
    {
    buffsize = sizeof (struct EX_button);
    gr$get_last_point(msg = &msg_loc, sizbuf = &buffsize, buffer = &button,
     nret = &dum);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send(msg = message IGEgragad.DPinrot(&msg_loc, view_matrix),
               targetid = button.objid, targetos = button.osnum,
               senderid = NULL_OBJID);
    if (EMSerror (stat_OM & msg_loc))
      MAidmx (&msg_loc, view_matrix);
    }

  /*
   * Construct the line in the direction of the axis
   */

  vec[X] = view_matrix[xaxis ? XCOMP1 : YCOMP1];
  vec[Y] = view_matrix[xaxis ? XCOMP2 : YCOMP2];
  vec[Z] = view_matrix[xaxis ? XCOMP3 : YCOMP3];

  stat_func = BSnorvec (&msg_loc, vec);
  EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

  pt = &event->event.button.x;
  for (i=X; i<=Z; i++)
    {
    axisline->point1[i] = pt[i];
    axisline->point2[i] = pt[i] + (vec[i] * ENLARGE_FACTOR);
    }

ret_end:
  if (EMSerror (*msg))
    return (FALSE);
  else
    return (TRUE);
}

end implementation Root;

