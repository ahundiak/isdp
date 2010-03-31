/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION
 
    Draws out the oriented normal of this surface.

  HISTORY

    PP  :  Unknown  : Creation
    SS  :  08/26/87 : Modified it to accept display_mode and also decide
                      that display length on it's own.
    DLB :  01/28/88 : Added send to EMget_point_on_surface.
    rlw :  07/21/88 : Modified to use a function to display a vector on
                      the screen.  Note that this function is also
                      used for curves (src_co/funk/EFdspvector.I).
    DLB :  05/01/89 : Added IGRstop making this code honor the stop button.
    SS  :  01/30/90 : Added the check to see if any interrupt (button)
                      input was done - if so - STOPSENDING.
    DLB :  11/06/91 : Change ignore_pos_or to be a bit mask.
                        0x0 - display relative to pos_orient
                        0x1 - ignore pos_orient
                        0x2 - show opposite of the regular way.
    DLB :  12/02/91 : Opps.  Bug in previous change where passing 0x0 would
                      IGNORE pos_orient instead of displaying relative to it.
                      The bit mask is the same for ignore_pos_or.  I just
                      fixed the logic.
    NP  :  08/26/92 : Modified for ANSI compliance. Added typecast in GRgenabsg and
		      a fn. declaration for EFget_normals1 in EFget_normals.
*/

class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
# include "gocmacros.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSbnddef.h"
# include "bserr.h"
# include "emsmacros.h"
# include "EMSdef.h"

# define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

/*
 * The paramteric value at which the oriented surface
 * normal is to be drawn. It is off-centre in the hope
 * that the asymmetry will more likely assure a non-cusp
 * point on the surface.
 */

# define DRAW_U 0.48
# define DRAW_V 0.48

method EMshow_normals (IGRlong *msg; struct GRmd_env *mdenv;
                       struct IGRdisplay *active_display;
                       enum GRdpmode display_mode)
{
  IGRlong EFshow_normals1();

  return(EFshow_normals1(msg, mdenv, active_display, display_mode,
         FALSE, NULL, my_id, OM_Gw_current_OS));
}

IGRlong EFshow_normals1(msg, mdenv, active_display, display_mode,
                        ignore_pos_or, n_loc, objid, osnum)
IGRlong           *msg;
struct GRmd_env   *mdenv;
struct IGRdisplay *active_display;
enum GRdpmode     display_mode;
OMuword           ignore_pos_or;
IGRdouble         *n_loc;
GRobjid           objid;
OMuword           osnum;
{
  IGRboolean in_world_system = TRUE;
  IGRlong msg_loc, stat_OM;
  IGRdouble srfpt[3];
  IGRvector norm;
  GRrange range;
  struct IGRbsp_surface *srf;
  struct EMparms params;
  void EMavgsfnorm();
  extern IGRint IGEstop();


  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  srf = NULL;

  /* Obtain a point in area on the surface.*/
  stat_OM = om$send(msg = message EMSsurface.EMget_point_on_surface(
                          &msg_loc, mdenv, 0, 1, NULL, &params),
                    senderid = NULL_OBJID,
                    targetid = objid,
                    targetos = osnum);
  if (! (1 & msg_loc & stat_OM))
  {
    /*If any error continue ...*/
    params.u = DRAW_U;
    params.v = DRAW_V;   
    msg_loc = EMS_S_Success;
    stat_OM = OM_S_SUCCESS;
  }

  if (n_loc)
  {
    n_loc[0] = params.u;
    n_loc[1] = params.v;
  }  

  /*
   * Obtain the surface's oriented average
   * unit normal.
   */
  
  if (! GRabsg_test(&msg_loc, &mdenv->md_env.matrix_type,
                    mdenv->md_env.matrix, &osnum, &objid, &srf))
  {
    msg_loc = MSFAIL;
    om$send(mode = OM_e_wrt_object,
            msg  = message GRvg.GRgenabsg(&msg_loc, &mdenv->md_env.matrix_type,
                   mdenv->md_env.matrix, (IGRchar **)&srf),
            senderid = objid,
            targetid = objid,
            targetos = osnum);
  }

  /******************************
  GRgetabsg (&msg_loc, &mdenv->md_env.matrix_type, mdenv->md_env.matrix,
   &srf, i);
  ******************************/
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  EMavgsfnorm (&msg_loc, srf, params.u, params.v, srfpt, norm);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  if (msg_loc == EMS_I_NoSolution)
    {
    *msg = msg_loc;
    goto ret_end;
    }

  /*
   * Obtain the size of the normal to be drawn
   * as a defined fraction of the length of
   * the largest side of the range box. Phew!.
   */

  stat_OM = om$send(msg = message GRvg.GRgetrang (&msg_loc,
                         &mdenv->md_env.matrix_type, mdenv->md_env.matrix, 
                         &in_world_system, range),
                    senderid = NULL_OBJID,
                    targetid = objid,
                    targetos = osnum);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  /*
   * Draw the vector
   */
   {
    extern void EFdraw_vector_on_screen();
    IGRboolean  reverse_vector=FALSE, toggle=FALSE;

    if (ignore_pos_or & 0x2)
    {
      toggle = TRUE;
      ignore_pos_or &= ~0x2;
    }

    if (!ignore_pos_or) reverse_vector = !srf->pos_orient;

    if (toggle) reverse_vector = !reverse_vector;

    EFdraw_vector_on_screen(
      objid,
      active_display,
      mdenv,
      display_mode,
      reverse_vector,
      srfpt,
      norm,
      range,
      msg);
     if (! (1 & *msg)) stat_OM = OM_E_ABORT;
   }

  if (IGEstop()) stat_OM = OM_I_STOP_SENDING;
  else if (*msg == EMS_I_Interrupt) stat_OM = OM_I_STOP_SENDING;
 
ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EFshow_normals1");
  return (stat_OM);
}
end implementation EMSsubbs;
