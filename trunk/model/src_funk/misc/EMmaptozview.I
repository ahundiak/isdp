/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "msdef.h"
#include "mamulmx.h"
#include "mainvmx.h"

from IGEgragad  import DPinrot;

IGRlong EMmap_button_to_z_view(msg, pole, button)
IGRlong    *msg;
IGRpoint   pole;
struct EX_button   *button;

/*
Abstract
    This function takes the pole on the curve and a button struct
    representing the new pole desired and maps the button to the
    z view coordinate.

Notes
    button is taken in as input and returned as output.

Files
    EMmaptozview.C

History

    Sudha  07/09/93    Modified for BSprototypes anisfication
    DLB    10/29/91    pass *short to MAinvmx - SUN PORT.
    dhm    11/11/88    creation date.
*/

{
  IGRlong    msg_loc, status;
  IGRshort   index = 4;  /*Changed to short - SUN - DLB 10/29/91*/
  IGRboolean sts;
  IGRchar    errmsg[EMMAXERRMSG_LEN];
  IGRshort   r1 = 4, c1 = 4, c2 = 1;
  IGRmatrix  view_matrix, world_matrix;
  IGRdouble  pole_pnt[4], button_pnt[4], vw_pole_pnt[4], vw_button_pnt[4];
  IGRdouble  vw_pnt[4], new_pnt[4];
 
  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg, "EMmap_button_to_z_view error\n");

  /* 
   * Get the view matrix for converting button point and pole from
   * world to view.
   */

  status = om$send(msg = message IGEgragad.DPinrot(&msg_loc, view_matrix),
                   senderid = NULL_OBJID,
                   targetid = button->objid,
                   targetos = button->osnum);
  EMomerr_hndlr(status, ret_end, errmsg);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Mapping the pole to the view system.
   */

  pole_pnt[0] = pole[0];
  pole_pnt[1] = pole[1];
  pole_pnt[2] = pole[2];
  pole_pnt[3] = 1.0;

  sts = MAmulmx(&msg_loc, &r1, &c1, &c2, view_matrix, pole_pnt,
                vw_pole_pnt);
  EMerr_hndlr(!sts || EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /* 
   * Mapping the button to the view system.
   */

  button_pnt[0] = button->x;
  button_pnt[1] = button->y;
  button_pnt[2] = button->z;
  button_pnt[3] = 1.0;

  sts = MAmulmx(&msg_loc, &r1, &c1, &c2, view_matrix, button_pnt,
                vw_button_pnt);
  EMerr_hndlr(!sts || EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Get the view(local) to world matrix for converting the newpoint back
   * to world.
   */

  status = MAinvmx(&msg_loc, &index, view_matrix, world_matrix);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  /*
   * Set the new view point to be the button point mapped to the z view.
   * Then map this new point back to world.
   */

  vw_pnt[0] = vw_button_pnt[0];
  vw_pnt[1] = vw_button_pnt[1];
  vw_pnt[2] = vw_pole_pnt[2];
  vw_pnt[3] = 1.0;

  sts = MAmulmx(&msg_loc, &r1, &c1, &c2, world_matrix, vw_pnt, new_pnt);
  EMerr_hndlr(!sts || EMis_error(msg_loc), *msg, MSFAIL, ret_end);

  button->x = new_pnt[0];
  button->y = new_pnt[1];
  button->z = new_pnt[2];


  ret_end:
    return(status);

}

end implementation Root;
