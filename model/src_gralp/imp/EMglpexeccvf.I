/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/* history:
    29-MAY-91  SCW   Genesis
    29-JUL-91  SCW   Added check for no_display flag
*/   

class implementation EMSgraloop;

#include "EMSfrtdef.h"     /* EMGL_NO_DISPLAY */

method EMShelper.EMexecuteCurveFunction(
                             IGRlong               *EMmsg; 
                             struct IGRbsp_surface *surf;
                             IGRshort              *mx_type; 
                             IGRmatrix              mx;
                             GRobjid                surf_id; 
                             IGRint               (*f)();
                             IGRchar               *args;
			     IGRushort      eligible_edge_type )
{
  IGRlong  sts, loc_msg;

  sts = OM_S_SUCCESS;

  if( ME.EMShelper->props & EMGL_NO_DISPLAY ) goto wrapup;

  sts = om$send( msg = message EMSloop.EMexecuteCurveFunction(
                                                 &loc_msg,
                                                 surf, 
                                                 mx_type,
                                                 mx, 
                                                 surf_id, 
                                                 f,
                                                 args,
                                                 eligible_edge_type ), 
                 targetid = my_id );

wrapup:

  EMSmsgReport( sts, "EMSgraloop.EMexecuteCurveFunction", FALSE );
  if EMSmsgReport( sts, "EMSgraloop.EMexecuteCurveFunction", FALSE )  
           sts = OM_E_ABORT;
  return( sts );
}

end implementation EMSgraloop;
