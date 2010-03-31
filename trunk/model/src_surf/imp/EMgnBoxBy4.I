/* ###################   APOGEE COMPILED   ################## */
/*
 DESCRIPTION

 This method constructs a box given 4 points.
 The first two points define a line, the third point defines the height
 of a rectangle, and the fourth point defines the distance the rectangle
 is projected in space.

 RETURN VALUES

 construct_list->msg    MSSUCC - successfull
                        MSFAIL - if failure
                        MANOMEMORY - if no memory could be allocated
                        MSINARG - bad input data
                        GRSNOINVTRAN - if input matrix is not invertible
                        GRSDGNEXCEED - if range exceeds design limits

 new_objid              object id of the resulting surface

 NOTES

 This object will delete itself if an error occurs.

 HISTORY

 09/21/86 : lst : The beginning
 09/21/87 : rlw : Redocumented and removed code which forced u knot vector
                  to be uniform.
 */

class implementation EMSgenbs;

#include "EMS.h"
#include "bserr.h"
#include "msdef.h"

method EMboxby4(
 struct GRvg_construct *construct_list; 
 double points[4][3]; 
 int *msg)
{
  extern  void           BSbox();
 IGRlong        sts = OM_S_SUCCESS, msg_loc;
 IGRdouble      poles[10][3], u_knots[7], v_knots[4];
 struct         IGRbsp_surface surface;

 *msg = MSSUCC;

/*
 * Get the surface definition
 */
 surface.poles   = (IGRdouble *) &poles[0][0];
 surface.weights = NULL;
 surface.u_knots = (IGRdouble *) &u_knots[0];
 surface.v_knots = (IGRdouble *) &v_knots[0];
 BSbox(
   &points[0][0],
   &points[1][0], 
   &points[2][0],
   &points[3][0], 
   &surface, 
   &msg_loc);
  if (msg_loc != BSSUCC)
   {
    if (msg_loc == BSINARG)
     *msg = MSINARG;
    else
     *msg = MSFAIL;
    goto wrapup;
   }

/*
 * Fill the instance data and such
 */
 construct_list->geometry = (IGRchar *) &surface;
 sts = om$send(msg = message GRgraphics.GRconstruct(construct_list),
               targetid = my_id);
  if (!(1 & sts))
   {
    *msg = *(construct_list->msg);
    goto wrapup;
   }

/*
 * End of routine
 */
wrapup:
 *(construct_list->msg) = *msg;
 if (1 & sts & *msg)
  return(OM_S_SUCCESS);
 else
  {
   sts = om$send(msg = message Root.delete(1),
                 targetid = my_id);
   return(OM_E_ABORT);
  }
}

end implementation EMSgenbs;
