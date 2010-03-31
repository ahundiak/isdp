/*
 * HISTORY
 * 
 * 07/02/92:Rajiv Agrawal:Message system compliance.
 * Jack : 4-Feb-93 : moved BSnorvec call for zdir to after
 *                   the BScrossp that calculates the zdir
 *                   vector. Fixes TR 119301001.
 * 02/18/93:Carlos:Added NDcompute_node.
 * 06/23/93 Sudha    modified for BSprototype ansification
 */

class implementation EMSdatpln;

#include "OMmacros.h"
#include "ndmacros.h" /* For nd$wait_batch */
#include "godef.h"
#include "parametric.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "emsdef.h"
#include "nddef.h"
#include "SKdef.h"
#include "msmacros.h"
#include "msdef.h"
#include "msmacros.h"
#ifndef BASE_EMS
#include "exmacros.h"
#endif
#include "matypemx.h"
#include "maoptsxfo.h"
#include "mainvmx.h"
#include "bserr.h"
#include "bsnorvec.h"
#include "bscrossp.h"

method EMget_pln_info (IGRlong *EMmsg;
                       IGRuint options;
                       struct GRmd_env *md_env;
                       double *xdir;
                       double *ydir;
                       double *zdir;
                       double *origin;
                       IGRuint *props)
{
 BSrc rc;
 IGRint status;
 IGRshort rot_mx_type;
 IGRmatrix rot_mx;
 IGRboolean bsts;

 *EMmsg = MSSUCC;

 if (xdir)
  OM_BLOCK_MOVE(ME.EMSdatpln->x_dir,xdir, sizeof (IGRvector));

 if (ydir)
  OM_BLOCK_MOVE(ME.EMSdatpln->y_dir,ydir, sizeof (IGRvector));

 if (origin)
  OM_BLOCK_MOVE(ME.EMSdatpln->origin,origin, sizeof (IGRvector));

 if (xdir)
  bsts = BSnorvec(&rc,xdir);

 if (ydir)
  bsts = BSnorvec(&rc,ydir);

 if (zdir)
   status = BScrossp(&rc,ME.EMSdatpln->x_dir,
                   ME.EMSdatpln->y_dir,
                   zdir);
 if (zdir)
  bsts = BSnorvec(&rc,zdir);

 if (props)
  *props = ME.EMSdatpln->props;

 if (md_env && (md_env->md_env.matrix_type != MAIDMX))
 {
  IGRdouble *mx;
  IGRshort *mx_type;
  long one = 1;

  mx = md_env->md_env.matrix;
  mx_type = &md_env->md_env.matrix_type;
  OM_BLOCK_MOVE(mx, rot_mx, sizeof (IGRmatrix));

  rot_mx[3] = 0.0;
  rot_mx[7] = 0.0;
  rot_mx[11] = 0.0;
  rot_mx[15] = 1.0;

  MAtypemx(EMmsg,rot_mx, &rot_mx_type);
  if (!(1&*EMmsg)) goto wrapup;
  

  if (xdir)
  {
   MAoptsxform(EMmsg,&one,&rot_mx_type,rot_mx,xdir,
               xdir);
   if (!(1&*EMmsg)) goto wrapup;
  }

  if (ydir)
  {
   MAoptsxform(EMmsg,&one,&rot_mx_type,rot_mx,ydir,
               ydir);
   if (!(1&*EMmsg)) goto wrapup;
  }

  if (zdir)
  {
   MAoptsxform(EMmsg,&one,&rot_mx_type,rot_mx,zdir,
               zdir);
   if (!(1&*EMmsg)) goto wrapup;
  }

  if (origin)
  {
   MAoptsxform(EMmsg,&one,mx_type,mx,origin,
               origin);
   if (!(1&*EMmsg)) goto wrapup;
  }
 }

wrapup:
 if (!(1&*EMmsg)) *EMmsg = MSFAIL;
 return (OM_S_SUCCESS);
}


method GRdetplane(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
        struct IGRplane *plane)
{
 IGRlong status;
 struct GRmd_env env;

 *msg = MSSUCC;
 status = OM_S_SUCCESS;

 env.md_env.matrix_type = *matrix_type;
 OM_BLOCK_MOVE(matrix, env.md_env.matrix, sizeof (IGRmatrix));

 status = om$send (msg = message EMSdatpln.EMget_pln_info((IGRlong *)msg,
                         NULL,&env,
                         NULL,NULL,
                         plane->normal,
                         plane->point,
                         NULL),
                    targetid = my_id);
 if (!(1&status&*msg)) goto wrapup;

wrapup:
 return (status);
}

end implementation EMSdatpln;

