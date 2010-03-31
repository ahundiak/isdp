/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
History

    AIC  04 Oct 1990 Genesis
    AIC  09 Oct 1990 Added support for cusps
    Jack 25 Apr 1991 Modified for 2.0.1 Horizon Loop implementation 
    NP   26 Aug 1992 Modified for ANSI compliance. Added typecasts.
*/

#include "gocmacros.h"
#include "msdef.h"

#define BUFSIZE 100

from EMScusp import EMinit_cusp;

/*
No longer a message

from EMShelper import EMdel_hrz_cusp;
*/

method EMinit_display(IGRlong          *EMmsg;
                      struct GRmd_env  *md_env)

{
  long      sts;

  /* 
  OM_S_CHANSELECT to_helpers;

   * First, clean up any existing Horizon edges or Cusps.
   *
   * "EMdel_hrz_cusp" is no longer a message. Since "EMinit_display" is
   * not in use, I have just commented out the call. I believe that it
   * is no longer needed, even if this message were used, because the
   * code that places horizon loops does not place them unless they do
   * not already exist. Cusps may still be a problem. AIC
   *
 to_helpers.type = OM_e_addr;
 to_helpers.u_sel.addr = &ME.EMSrequester->to_helpers;

 sts = om$send(msg = message EMShelper.EMdel_hrz_cusp( EMmsg ),
               p_chanselect = &to_helpers);               
 if(! (1 & sts)) goto wrapup;
   */

  /*
   * Place horizon edges
   */
  {
    IGRdouble    v[12];
    IGRint    num_vectors;
    
    v[0] = 0.; v[1] = 0.; v[2] = 1.;
    v[3] = 0.; v[4] = 1.; v[5] = 0.;
    v[6] = 1.; v[7] = 0.; v[8] = 0.;
    v[9] = 1.;  v[10] = -1.; v[11] = 1.;

    num_vectors = 4;

    sts = om$send(msg = message EMSsubbs.EMprofile(
                                         EMmsg, 
                                         md_env, 
                                         NULL, 
                                         num_vectors, 
                                         (IGRvector *)v,
                                         EMSplaceProfileFeatures, 
                                         NULL, 
                                         NULL),
                  targetid = my_id);
    if(! (1 & sts)) goto wrapup;
  }

  /*
   * Place rule lines
   */
  {
    OM_S_OBJID              cuspid;
    struct IGRbsp_surface   *surface;

    sts = om$construct(classid = OPP_EMScusp_class_id,
                       p_objid = &cuspid);
    if(! (1 & sts)) goto wrapup;

    GRgetabsg(EMmsg, 
             &md_env->md_env.matrix_type, 
             md_env->md_env.matrix,
             (IGRchar **)&surface, 
             0);
    if(! (1 & *EMmsg)) goto wrapup;

    sts = om$send(msg = message EMScusp.EMinit_cusp(
                                        surface, 
                                        my_id,
                                       &md_env->md_env.matrix_type, 
                                        md_env->md_env.matrix),
                  targetid = cuspid);
  }

wrapup:
  EMWRAPUP(sts, *EMmsg, "EMSsubbs.EMinit_display")
  return sts;
}
end implementation EMSsubbs;
