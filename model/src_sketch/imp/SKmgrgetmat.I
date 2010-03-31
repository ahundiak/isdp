class implementation SKmgr;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMcp.h"
#include <alloca.h>
#include "msdef.h"
#include "msmacros.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "mamulmx.h"
#include "mainvmx.h"

#define MIN 0
#define MAX 1

#define X 0
#define Y 1

#define FIRST  0
#define SECOND 1


method SKget_xymat(long *EMmsg;unsigned int options;
                    short *in_matrix_type; IGRmatrix in_matrix;
                    short *out_mattyp; IGRmatrix out_matrix)
{
 long status;
 short mattyp;
 IGRmatrix mat,inv_mat;
 double *origin, *zvec, *xvec;
 short four = 4;
 IGRboolean bssts;
 
 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 if (options & SK_OPT_NO_ORIGIN)
   origin = NULL;
 else
   origin = ME.SKmgr->origin;

 if (options & SK_OPT_NO_ROTATION)
   {
   zvec = NULL;
   xvec = NULL;
   }
 else
   {
   zvec = ME.SKmgr->normal;
   xvec = ME.SKmgr->x_axis;
   }

 SKgetmat (EMmsg,origin,zvec,xvec,&mattyp,mat);
 EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 if (options & SK_OPT_GET_XYZ_TO_XY)
 {
   bssts = MAinvmx (EMmsg, &four, in_matrix, inv_mat);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);

   bssts = MAmulmx (EMmsg, &four, &four, &four, mat, inv_mat,
                    out_matrix);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);

   bssts = MAtypemx (EMmsg, out_matrix, out_mattyp);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);
 }
 else if (options & SK_OPT_GET_LXYZ_TO_XY)
 {
   *out_mattyp = mattyp;
   OM_BLOCK_MOVE (mat, out_matrix, sizeof (IGRmatrix));
 }
 else if (options & SK_OPT_GET_XY_TO_XYZ)
 {
   bssts = MAinvmx (EMmsg, &four, mat, inv_mat);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);

   bssts = MAmulmx (EMmsg, &four, &four, &four, in_matrix, inv_mat,
                    out_matrix);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);

   bssts = MAtypemx (EMmsg, out_matrix, out_mattyp);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);
 }
 else if (options & SK_OPT_GET_XY_TO_LXYZ)
 {
   bssts = MAinvmx (EMmsg, &four, mat, out_matrix);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);

   bssts = MAtypemx (EMmsg, out_matrix, out_mattyp);
   EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_MAerror, wrapup);
 }
 else
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

wrapup:
 EMWRAPUP (*EMmsg, status, "In SKmgr:SKget_xymat error");
 return (status);
}

method GRdetplane ( long *msg; short *matrix_type; IGRmatrix matrix; 
                    struct IGRplane *plane )
{
  long msg_loc;

  *msg = MSSUCC;

  om$send (msg = message SKmgr.SKgetornt (&msg_loc, plane->point,
   NULL, plane->normal), targetid = my_id);
  if (EMSerror (msg_loc))
    *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method SKgetornt (long *msg;
                  double *point, *xaxis, *normal)
{
  *msg = EMS_S_Success;
 
  if (point)
    OM_BLOCK_MOVE (ME.SKmgr->origin, point, sizeof(IGRpoint));
 
  if (normal)
    OM_BLOCK_MOVE (ME.SKmgr->normal, normal, sizeof(IGRvector));
 
  if (xaxis)
    OM_BLOCK_MOVE (ME.SKmgr->x_axis, xaxis, sizeof(IGRvector));
 
  return OM_S_SUCCESS;
}
end implementation SKmgr;

