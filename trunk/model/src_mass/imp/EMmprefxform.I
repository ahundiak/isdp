/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

# include "EMS.h"
# include "bserr.h"
# include "bsparameters.h"
# include "ma.h"
# include "madef.h" 
# include "emsdef.h"
# include "emsmacros.h"
# include "gocmacros.h"
# include "emsmass.h"
 
#include "maoptsxfo.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

/*

 History     

        pp        02/17/90      Made modification so that area properties
                                in reference files get computed properly,
                                specifically in reference to orientation
                                and centroid.
        gupta     11/01/89      Creation Date

        Sudha     06/28/93      Modified for BSprototype ansification

*/
 
method EMrefxform (IGRlong         *EMmsg;
                   struct GRmd_env *md_env;
                   IGRshort        *matrix_type;
                   IGRmatrix       matrix;
                   IGRdouble       *refer_point;
                   IGRdouble       *prop;
                   IGRdouble       *in_glo_loc;
                   IGRboolean      *validity)
{
  IGRlong            i, stat_OM, msg;
  IGRint             j;
  IGRdouble          scratch_1, scratch_2;
  IGRdouble          points[4][3], xpoints[4][3];
  IGRdouble          cent_point[3];
  IGRdouble          norm_1, norm_2, norm_3;
  IGRdouble          zero_tol;
  IGRdouble          scaling_2, scaling_3, scaling_4, scaling_5;
  IGRboolean         status;
  static IGRdouble   zero_vect[3] = {0.0,  0.0,  0.0};

  /*-----------------------------------------------------------------*/

  stat_OM = OM_S_SUCCESS;         
  *EMmsg = EMS_S_Success;

  for (i=0; i<NUMB_PROPS; i++) prop[i] = me->mass_props[i];

  if (! me->mp_valid) return(stat_OM);

  if ((matrix[12] != 0) || (matrix[13] != 0) || (matrix[14] != 0) ||
      (matrix[15] != 1))
   {
    me->mp_valid = FALSE;
    *validity = FALSE;
    goto wrapup;
   }

  me->mp_valid = TRUE;
  *validity = TRUE;
  BSEXTRACTPAR (&msg, BSTOLCLOSETOZERO, zero_tol);

  /* check for scaling -- if uniform scaling in all three directions then
     update the computed properties else invalidate the same */

  norm_1 = BSdistptpt(&msg, &matrix[0], zero_vect);
  norm_2 = BSdistptpt(&msg, &matrix[4], zero_vect);
  norm_3 = BSdistptpt(&msg, &matrix[8], zero_vect);

  scratch_1 = (norm_1 >= norm_2) ? (norm_1 - norm_2) : (norm_2 - norm_1);
  scratch_2 = (norm_1 >= norm_3) ? (norm_1 - norm_3) : (norm_3 - norm_1);

  if ((scratch_1 <= zero_tol) && (scratch_2 <= zero_tol))
   {
    scaling_2 = norm_1 * norm_1;
    scaling_3 = scaling_2 * norm_1;
    scaling_4 = scaling_3 * norm_1;
    scaling_5 = scaling_4 * norm_1;

    prop[0]  *=  scaling_3;
    prop[1]  *=  scaling_3;
    prop[11]  *=  scaling_2;
    prop[14]  *=  scaling_4;
    prop[15]  *=  scaling_4;
    prop[16]  *=  scaling_4;

    if (me->operation_type == MASS_PROPERTIES)
     {
      prop[5]  *=  scaling_5;
      prop[6]  *=  scaling_5;
      prop[7]  *=  scaling_5;
      prop[8]  *=  scaling_5;
      prop[9]  *=  scaling_5;
      prop[10]  *=  scaling_5;
     }
    else
     {
/* begin pp */

      IGRdouble temp_axis[3];
      IGRdouble trans_zero_vect[3];

      i = 1;
      status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           zero_vect, trans_zero_vect);
      if (! (1 & status & msg)) goto wrapup;

      status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           &me->mass_props[5], cent_point);
      if (! (1 & status & msg)) goto wrapup;

      status = BSmkvec(&msg,temp_axis,trans_zero_vect,cent_point);
      if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}
      
      status = BSnorvec(&msg, temp_axis);
      if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}

      for (i=0; i<3; i++) prop[5+i] = temp_axis[i];
 
      i = 1;

      status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           &me->mass_props[8], cent_point);
      if (! (1 & status & msg)) goto wrapup;

      status = BSmkvec(&msg,temp_axis,trans_zero_vect,cent_point);
      if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}
      
      status = BSnorvec(&msg, temp_axis);
      if (msg != 0) {msg = EMS_E_BSerror; goto wrapup;}

      for (i=0; i<3; i++) prop[8+i] = temp_axis[i];

/* end pp 02/17/90 */
     }
   }
  else
   {
    me->mp_valid = FALSE;
    *validity = FALSE;
    goto wrapup;
   }

  for (i=0; i<3; i++) points[0][i] = me->refer_pnt[i];

  j = 0;
  for (i=1; i<4; i++)
   {
    points[i][0] = me->my_geometry[j++];
    points[i][1] = me->my_geometry[j++];
    points[i][2] = me->my_geometry[j++];
   }

  i = 4;

  status = MAoptsxform(&msg, &i, matrix_type, matrix, (IGRdouble *)points, (IGRdouble *)xpoints);
  if (! (1 & status & msg)) goto wrapup;

  i = 1;
  status = MAoptsxform(&msg, &i, matrix_type, matrix, &me->mass_props[2],
                       cent_point);
  if (! (1 & status & msg)) goto wrapup;
 
  for (i=0; i<3; i++) prop[2+i] = cent_point[i];

  norm_1 = BSdistptpt(&msg, &xpoints[0][0], &xpoints[1][0]);
  norm_2 = BSdistptpt(&msg, &xpoints[0][0], &xpoints[2][0]);

  for (i=0; i<3; i++)
   {
    in_glo_loc[i] = (xpoints[1][i] - xpoints[0][i])/norm_1;
    in_glo_loc[3+i] = (xpoints[2][i] - xpoints[0][i])/norm_2;
   }

  status = BScrossp(&msg, &in_glo_loc[0], &in_glo_loc[3], &in_glo_loc[6]);

/*
 * If the operation type was area properties, I believe that axes_orient is
 * always 0 and the centroid was always getting returned which is not true
 * in the case of area properties about an arbitrary point. 
 * pp (02/17/90)
 */

/*
  if (me->axes_orient == GENERAL)
*/
  if ((me->axes_orient == GENERAL) || (me->operation_type == AREA_PROPERTIES))
   {
    for (i=0; i<3; i++) refer_point[i] = xpoints[0][i];
   }
  else
   {
    for (i=0; i<3; i++) refer_point[i] = cent_point[i];
   }

  wrapup:

   EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMrefxform");
   return (stat_OM);
}

end implementation EMSmassprop;
