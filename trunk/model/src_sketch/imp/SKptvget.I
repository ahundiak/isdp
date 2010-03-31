class implementation SKptvar;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "madef.h"
#include "SKdef.h"
#include "maoptsxfo.h"

from SKmgr import SKget_xymat;

method SKgetvar (IGRlong *EMmsg; IGRushort opts;
                 IGRshort *mattyp; IGRdouble *matrix;
                 IGRdouble *point)
{
 IGRlong status;
 IGRlong   one = 1;
 IGRdouble *xy_mat;
 OM_S_CHANSELECT to_mgr;
 IGRmatrix xy_mat_store;
 short xy_mattyp;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 point[0] = ME.SKptvar->pt[0];
 point[1] = ME.SKptvar->pt[1];
 point[2] = 0.0;

 if (mattyp && matrix)
 {
   if (! (opts & SK_OPT_FULL_TRANSFORM))
   {
     status = om$make_chanselect(channame = "SKvariable.to_mgr",
                                 p_chanselect = &to_mgr);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);
                                
     xy_mat = xy_mat_store;
     status = om$send (msg = message SKmgr.SKget_xymat(EMmsg,
                             SK_OPT_GET_XY_TO_XYZ,mattyp, matrix,
                             &xy_mattyp,xy_mat),
                       p_chanselect = &to_mgr);
     EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
   else
   {
     xy_mattyp = *mattyp;
     xy_mat = matrix;
   }

   if (xy_mattyp != MAIDMX)
     MAoptsxform(EMmsg, &one, &xy_mattyp, xy_mat, point, point);
 }

wrapup:
 return (status);
}
end implementation SKptvar;
