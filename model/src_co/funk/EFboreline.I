/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
#include "OMmacros.h"

%safe
#include <math.h>
%endsafe

/* 
 Description

 This function returns a bore line given an event
 containing a point and view information.

 History

 ??/??/86 : ??? : Create date
 11/04/87 : rlw : Reworked, changed the name from CObrln_mod and
                  modified my_id to be passed by value instead of address.
 09/08/88 : DLB : Removed code to extend first point of boreline to
                  effective infinity.  This allows GRlnproject to return the
                  project point that is closest to the input point given by
                  the user (user has control now since s/he can change the
                  active z depth to allow a better choice).  
                  Supposedly IGRline is meant to be infinite anyway.  Only
                  IGRlineseg is bounded. 
 Sudha   06/02/93        modified to include for BSprototype headers

 */
#include "ems_m_inc.h"      /* Includes everything */
#include "maidmx.h"
#include "bsnorvec.h"
#include "bsmkvec.h"

from IGEgragad import DPinrot;

IGRboolean EFboreline(
 msg,
 my_stupid_id,
 event,
 bore_line) 

IGRlong                 *msg;
GRobjid                 my_stupid_id;
struct  GRevent         *event;         
struct  IGRline         *bore_line;

{
 extern IGRboolean  GRbrlnconstr();
 IGRboolean     status;
 extern IGRboolean  CObrln();
 IGRlong        sts, i, loc_msg;
 IGRpoint       point;
 IGRvector      vector;
 IGRmatrix      view_matrix;
 struct EX_button save_button;


 /* save the button info just in case we need to change it
    and restore it before leaving.
  */
 OM_BLOCK_MOVE(&(event->event.button), &save_button, sizeof(struct EX_button));


 status = CObrln (msg, 
                  NULL, 
                  event, 
                  bore_line);


/*
 * If this failed it is probably because the point
 * in the event did not have an associated view.
 * In this case, try and use the last point input
 * to get the view matrix.
 */
  if (!status)
   {
    IGRlong     stupid, sizbuf;
    struct      EX_button button;

    status = 1;

    sizbuf = sizeof(struct EX_button);
    gr$get_last_point(
      msg = msg,
      sizbuf = &sizbuf,
      buffer = &button,
      nret = &stupid);
     if (! (1 & *msg)) goto wrapup;

    /* put the new button info in the event structure */
    OM_BLOCK_MOVE(&button,&(event->event.button),sizeof(struct EX_button));

    status = CObrln (msg, 
                     NULL, 
                     event, 
                     bore_line);

    /* restore the event button structure */
    OM_BLOCK_MOVE(&save_button,&(event->event.button),sizeof(struct EX_button));

    /*
     * If this point did not have a view matrix
     * just use the top view.
     */
     if (!status)
      {

       status = 1;
       status = MAidmx (msg,
                        view_matrix);

       /*
        * Construct the bore line
        */
        point[0] = event->event.button.x;
        point[1] = event->event.button.y;
        point[2] = event->event.button.z;
        status = GRbrlnconstr(
                           msg,
                           point,
                           view_matrix,
                           bore_line);


       }
   }

/*
 * Make the boreline rather large
 */
 status = BSmkvec(
  &loc_msg,
  vector,
  bore_line->point1,
  bore_line->point2);
 status = BSnorvec(
   &loc_msg,
   vector);
  if (!status)
   {
    *msg = MSFAIL;
    goto wrapup;
   }

 for (i = 0; i < 3; i++)
  {
   vector[i] *= 10e6;
/* bore_line->point1[i] -= vector[i];   Removed 09/08/88 by DLB*/
   bore_line->point2[i] += vector[i];
  }
/*
 * eof 
 */
wrapup:
 if (1 & *msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation Root;
