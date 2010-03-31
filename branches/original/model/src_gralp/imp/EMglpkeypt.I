/* ###################   APOGEE COMPILED   ################## */
/*                                                            */
/* history:
    15 July 1987   AIC      Creation Date
    13-MAR-91      SCW      Converted from old EMSfeaturelp.
    29-JUL-91      SCW      Added check for no_display flag
*/   

class implementation EMSgraloop;

#include "EMS.h"
#include "emsdef.h"        /* MAXDOUBLE       */
#include "msdef.h"         /* MSSUCC          */
#include "EMSfrtdef.h"     /* EMGL_NO_DISPLAY */

from EMSedge import EMkeypoint;


method EMkeypoint( IGRlong               *EMmsg; 
                   struct IGRbsp_surface *surf;
                   IGRshort              *matrix_type; 
                   IGRmatrix              matrix;
                   struct IGRline        *boreline; 
                   IGRdouble             *dist;
                   IGRpoint               keypoint; 
                   struct GRparms        *key_parm;
                   struct GRid           *window_id )

{
  IGRlong  sts,  
           msg1;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  msg1 = MSSUCC;
 
  if( ME.EMShelper->props & EMGL_NO_DISPLAY ) goto wrapup;

  /*
   * Do the edges
   */
  {
    OM_S_CHANSELECT to_edges;

    to_edges.type = OM_e_addr;
    to_edges.u_sel.addr = &me^^EMSbd_owner.to_comps;

    sts = om$send( msg = message EMSedge.EMkeypoint(&msg1, 
                                                     surf, 
                                                     boreline,
                                                     keypoint, 
                                                     key_parm, 
                                                     dist ), 
                   p_chanselect = &to_edges );
  }

wrapup:

  if( !( 1 & msg1 ))  *EMmsg = msg1;
  EMSmsgReport( sts, "EMSgraloop.EMkeypoint", FALSE );
  if EMSmsgReport( sts, "EMSgraloop.EMkeypoint", FALSE )  sts = OM_E_ABORT;
  return( sts );
}

end implementation EMSgraloop;
