/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "msdef.h"
#include "bserr.h"     /* for BSERROR */
#include "bsparameters.h" /* for BSTOLCOLLINVEC ...*/
#include "gocmacros.h" /* For GRgetabsg ... */
#include "EMSconstruct.h" /* for EMS_S_SOLID_HOLE ... */
#define MAX_LOCAL_TOL 0.001

method EMclassify_ray (IGRlong *EMmsg;
                       struct GRmd_env *env;
                       struct IGRline *ray;
                       IGRboolean reverse;
                       IGRdouble *uvpt;
                       IGRpoint int_point;
                       IGRboolean *classification)

/* **************************************************************************

Description
  This method tries to determine the direction of ray relative to the surface
  at the intersection point. It takes into account the natural normal of
  the surface and the pos orient bit of the surface to determine the
  material direction of the surface.  The intersection point if known, is
  passed in through the uvpt field or int_point field. 

  Input
   env - environment information of the surface
   ray - the ray which needs to be classified as to whether it is penetrating
         or coming out of the surface at int_point.
   reverse - if set to FALSE, the reverse direction of the ray is considered
             for classification
   uvpt - the uvpoint of the intersection point between the ray and the
          surface if known, or else set this to null.
   int_point - the intersection point between the ray and the surface if known,
          or else set this to null.

  Output
   EMmsg - completion status
   classification - The classification of the ray which will be one of
           the following.
           EMS_S_SOLID_HOLE - if the ray proceeds from the solid side
                              of the surface to the hole
           EMS_S_HOLE_SOLID - if the ray proceeds from the hole side
                              of thes surface to the solid side.
           EMS_S_UNKNOWN - if the classification is unknown.

Notes
  Upon exit the completion code will be one of the followin:
   EMS_S_Success : if successful
   EMS_E_InvalidArg - if not supported as yet
   EMS_E_BSerror - if there is a math error
   EMS_E_SurfaceError - if there is error retrieving the geometry of
                   the surface
   EMS_E_Fail - general failure

History
  NP : 08/25/92 Modified for ANSI compliance. 
  PP : 01/27/88 Changed the call of computation of normal, to computation
                of average normal to handle cusps.
  PP : 12/14/87 Creation

********************************************************************** */


{
 IGRint i;
 IGRlong status,msg_loc;
 IGRpoint surf_point;
 IGRvector normal,dir_vec;
 BSrc rc;
 struct IGRbsp_surface *surf;
 IGRdouble dotp, dottol;
  extern  IGRboolean BSmkvec ();
  extern  IGRboolean BSnorvec ();

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 surf = NULL;
 *classification = 0;

 BSEXTRACTPAR (&rc,BSTOLCOLLINVEC,dottol);
 if (dottol < MAX_LOCAL_TOL)
   dottol = MAX_LOCAL_TOL;

 GRgetabsg (&msg_loc, &env->md_env.matrix_type, env->md_env.matrix,
            (IGRchar **)&surf,i);
 EMerr_hndlr (EMis_error (msg_loc), *EMmsg, EMS_E_SurfaceError, wrapup);

 status = BSmkvec (&rc, dir_vec, ray->point1, ray->point2);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
 
 status = BSnorvec (&rc, dir_vec);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 if (reverse)
  for (i=0;i<3;i++) dir_vec[i] = -dir_vec[i]; 
 
 if (uvpt)
 {
  EMavgsfnorm (&msg_loc, surf, uvpt[0], uvpt[1], surf_point,
               normal);
  if (msg_loc == EMS_I_NoSolution)
  {
   msg_loc = EMS_S_Success;
   *classification = EMS_S_UNKNOWN;
   goto wrapup;
  }
  EMerr_hndlr (!(1&msg_loc), *EMmsg, EMS_E_BSerror, wrapup);
 } 
 else 
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 if (!surf->pos_orient)
  for (i=0;i<3;i++) normal[i] = -normal[i];

 status = BSnorvec (&rc, normal);
 EMerr_hndlr (!status, *EMmsg, EMS_E_BSerror, wrapup);
 
 dotp = dir_vec[0]*normal[0] + dir_vec[1]*normal[1] + dir_vec[2]*normal[2];

 if (dotp > dottol)
  *classification = EMS_S_HOLE_SOLID;
 else if (dotp < -dottol)
  *classification = EMS_S_SOLID_HOLE;
 else
  *classification = EMS_S_UNKNOWN;

wrapup:
 EMWRAPUP (*EMmsg, status, "In EMSsubbs:EMclassify_ray error");
 return (status);

}

end implementation EMSsubbs;


