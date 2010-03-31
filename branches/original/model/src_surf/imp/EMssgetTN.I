/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
HISTORY:

Long Ago:  ??  Creation.
08/26/92:  NP  Modified for ANSI compliance. Added missing typecast in GRgetabsg.

*/


#include "EMS.h"
#include "msdef.h"
#include "bserr.h"
#include "emserr.h"
#include "emsmacros.h"
#include "gocmacros.h" /* GRgetabsg */

method EMtangent_normal (IGRlong         *EMmsg;
                         struct GRmd_env *my_env;
                         IGRdouble       parms[],
                                         dis_fac;
                         IGRvector       *vec_TN)
{
  IGRlong stat_OM, msg;
  IGRint i, j;
  IGRdouble pts[12];
  struct IGRbsp_surface *surf;
  extern   void BSsfarrevnt();

/*-------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  GRgetabsg (&msg, &my_env->md_env.matrix_type, my_env->md_env.matrix,
             (IGRchar **)&surf, i);
  EMerr_hndlr (EMis_error (msg), *EMmsg, msg, wrapup);

  for (i=0;i<2;i++)
   if (parms[i] < 0.0)
     parms[i] = 0.0;
   else if (parms[i] > 1.0)
     parms[i] = 1.0;

  BSsfarrevnt(surf, 1, &parms[0], 1, &parms[1], dis_fac, NULL, pts, &msg);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   
  for (i=0; i<3; i++)
   {
    for (j=0; j<3; j++)
     {
      vec_TN[i][j] = pts[(3*(i+1)+j)] - pts[j];
     }
   }

  for (i=0; i<3; i++)
       vec_TN[3][i] = vec_TN[2][i];

  if (! surf->pos_orient)
   {
    vec_TN[2][0] = -vec_TN[2][0];
    vec_TN[2][1] = -vec_TN[2][1];
    vec_TN[2][2] = -vec_TN[2][2];
   }

wrapup:
  EMWRAPUP (*EMmsg, stat_OM, "EMSsubbs.EMtangent_normal");
  return (stat_OM);
}

end implementation EMSsubbs;
