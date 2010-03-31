class implementation SKptvar;

/*
  HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "maoptsxfo.h"

from SKmgr import SKget_xymat;

method SKputvar (IGRlong *msg; IGRushort opts;
                 IGRshort *mattyp; IGRdouble *mat;
                 IGRdouble *point)
{
 IGRlong status;
 IGRdouble *xy_mat;
 IGRlong  one = 1;
 IGRpoint dummy_point;
 IGRmatrix xy_mat_store;
 short xy_mattyp;
 OM_S_CHANSELECT to_mgr;

 *msg = EMS_S_Success;
 status = OM_S_SUCCESS;

 dummy_point[0] = point[0];
 dummy_point[1] = point[1];
 dummy_point[2] = point[2];

 if (mat && mattyp)
 {
   if (! (opts & SK_OPT_FULL_TRANSFORM))
   {
     status = om$make_chanselect(channame = "SKvariable.to_mgr",
                                 p_chanselect = &to_mgr);
     EMerr_hndlr(!(1&status), *msg, EMS_E_OMerror, wrapup);
                              
     xy_mat = xy_mat_store;
     status = om$send (msg = message SKmgr.SKget_xymat(msg,
                             SK_OPT_GET_XYZ_TO_XY,mattyp, mat,
                             &xy_mattyp,xy_mat),
                       p_chanselect = &to_mgr);
     EMerr_hndlr(!(1&status&*msg), *msg, EMS_E_Fail, wrapup);
   }
   else
   {
     xy_mattyp = *mattyp;
     xy_mat = mat;
   }

   if (xy_mattyp != MAIDMX)
     MAoptsxform(msg, &one, &xy_mattyp, xy_mat, dummy_point, dummy_point);
 }

 if (! (opts & (SK_OPT_VAR_X | SK_OPT_VAR_Y)))
   opts = SK_OPT_VAR_X | SK_OPT_VAR_Y;
 if (opts & SK_OPT_VAR_X)
   me->pt[0] = dummy_point[0];
 if (opts & SK_OPT_VAR_Y) 
   me->pt[1] = dummy_point[1];

wrapup:
 return (status);
}

end implementation SKptvar;
