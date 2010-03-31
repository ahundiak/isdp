/* ###################   APOGEE COMPILED   ################## */
class implementation EMSmassprop;

%safe
#include <math.h>
%endsafe

# include "EMS.h"
# include "bserr.h"
# include "bsparameters.h"
# include "msdef.h" /* MS message codes */
# include "ma.h"
# include "madef.h" 
# include "OMmacros.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "EMcp.h"
# include "gocmacros.h"
# include "emsmass.h"
# include "EMSpromacros.h"
 
#include "maoptsxfo.h"
#include "mainvmx.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

/*

 History     

        gupta     08/02/89      Creation Date
	Sudha	  06/28/93	Modified for BSprototype ansification

*/
 
method EMintxform (IGRlong         *EMmsg;
                   struct GRmd_env *md_env;
                   IGRshort        *matrix_type;
                   IGRmatrix       matrix;
                   GRobjid         *newobjid)
{
  IGRlong            i, stat_OM, msg;
  IGRint             j, k, scratch;
  IGRshort           trans_mat_type = 5, dim=3;
  IGRdouble          scratch_1, scratch_2;
  IGRdouble          delta_angle;
  IGRdouble          zero_tol, collinear_tol;
  IGRdouble          dest_org[3], new_z[3];
  IGRdouble          in_org[3];
  IGRdouble          rect_org[3], rect1_org[3];
  IGRdouble          points[4][3], xpoints[4][3];
  IGRdouble          mass_props[NUMB_PROPS];
  IGRdouble          norm_1, norm_2, norm_3;
  IGRdouble          out_mat[3][3], out_mat_inv[3][3];
  IGRdouble          in_mat[3][3], in_mat_inv[3][3];
  IGRdouble          glo_loc_inv[3][3], pxpoints[3];
  IGRdouble          scaling_2, scaling_3, scaling_4, scaling_5;
  IGRboolean         translation, rotation;
  IGRboolean         status;
  extern IGRdouble   sqrt();
  IGRvector          vec1, vec2;
  OM_S_CHANSELECT    to_comps;
  static IGRdouble   zero_vect[3]       = {0.0,  0.0,  0.0};
  static IGRdouble   identity_matrix[9] = {1.0,  0.0,  0.0, 
                                           0.0,  1.0,  0.0, 
                                           0.0,  0.0,  1.0 };

  static IGRdouble   trans_matrix[16] = {1.0, 0.0, 0.0, 0.0,
                                         1.0, 1.0, 0.0, 0.0,
                                         1.0, 0.0, 1.0, 0.0,
                                         1.0, 0.0, 0.0, 1.0};

  /*-----------------------------------------------------------------*/

  stat_OM = OM_S_SUCCESS;         
  *EMmsg = EMS_S_Success;

  if (! me->mp_valid) return(stat_OM);

  translation = FALSE;
  rotation = FALSE;

  for (i=0; i<NUMB_PROPS; i++) mass_props[i] = 0.0;

  me->mp_valid = FALSE;
  if ((matrix[12] != 0) || (matrix[13] != 0) || (matrix[14] != 0) ||
      (matrix[15] != 1))
   {
    stat_OM = om$send(msg = message GRgraphics.GRdelete (&msg, md_env),
                       targetid = my_id);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

    goto wrapup;
   }

  stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  if (! (1 & stat_OM)) goto wrapup;

  BSEXTRACTPAR (&msg, BSTOLCLOSETOZERO, zero_tol);
  BSEXTRACTPAR (&msg, BSTOLCOLLINVEC, collinear_tol);

  for (i=0; i<3; i++) in_org[i] = me->mass_props[2+i];

  for (i=0; i<3; i++) rect_org[i] = in_org[i];    

  for (i=0; i<3; i++) points[0][i] = me->refer_pnt[i];

  scratch = 0;
  for (i=1; i<4; i++)
   {
    points[i][0] = me->my_geometry[scratch++];
    points[i][1] = me->my_geometry[scratch++];
    points[i][2] = me->my_geometry[scratch++];
   }

  i = 4;

  status = MAoptsxform(&msg, &i, matrix_type, matrix, (IGRdouble *)points, (IGRdouble *)xpoints);
  if (! (1 & status & msg)) goto wrapup;
 
  for (i=0; i<3; i++)
   {
    BSmkvec (&msg, vec1, points[0], &points[i+1][0]);
    BSmkvec (&msg, vec2, xpoints[0], &xpoints[i+1][0]);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    status = BSnorvec(&msg, vec1);
    status = BSnorvec(&msg, vec2);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    delta_angle = BSdotp (&msg, vec1, vec2);
    if (delta_angle < 1-collinear_tol)
     {
      rotation = TRUE;
      break;
     }
   }

  if (BSdistptpt(&msg, points[0], xpoints[0]) > zero_tol)
      translation = TRUE;

  if (translation || rotation)
   {
    if (me->axes_orient != GENERAL)
        for (i=0; i<3; i++) in_org[i] = me->mass_props[2+i];
    else
        for (i=0; i<3; i++) in_org[i] = me->refer_pnt[i];

    for (i=0; i<3; i++) rect_org[i] = in_org[i];    

    scratch = 0;
    for (i=1; i<4; i++)
     {
      me->my_geometry[scratch++] = xpoints[i][0];
      me->my_geometry[scratch++] = xpoints[i][1];
      me->my_geometry[scratch++] = xpoints[i][2];
     }
   }

  i = 1;

  status = MAoptsxform(&msg, &i, matrix_type, matrix, &me->mass_props[2],
                       pxpoints);
  if (! (1 & status & msg)) goto wrapup;

  if (translation)
   {  
    switch (me->axes_orient)
     {  
      case ACTIVE_AT_CENTROID:
      case PRINCIPAL:

        for (i=0; i<NUMB_PROPS; i++) mass_props[i] = me->mass_props[i];

        for (i=0; i<3; i++) mass_props[2+i] = pxpoints[i];
        for (i=0; i<3; i++) me->refer_pnt[i] = mass_props[2+i];

        break;

      case GENERAL:

        for (i=0; i<3; i++) in_org[i] = me->mass_props[2+i];

        for (i=0; i<3; i++) dest_org[i] = in_org[i];    

        for (i=0; i<3; i++) me->mass_props[2+i] = dest_org[i];
/************************************************************************
        MScnvtprop(me->mass_props, rect_org, identity_matrix, mass_props,
                   dest_org, identity_matrix);
************************************************************************/
        ems$cnvtprop(
                in_props = me->mass_props,
                in_origin = rect_org,
                in_global_ornt = identity_matrix,
                out_props = mass_props,
                out_origin = dest_org,
                out_global_ornt = identity_matrix);

        for (i=0; i<3; i++) rect1_org[i] = pxpoints[i];
        for (i=0; i<3; i++) mass_props[2+i] = dest_org[i];
/**************************************************************************
        MScnvtprop(mass_props, dest_org, identity_matrix, mass_props,
                   rect1_org, identity_matrix);
**************************************************************************/
        ems$cnvtprop(
                in_props = mass_props,
                in_origin = dest_org,
                in_global_ornt = identity_matrix,
                out_props = mass_props,
                out_origin = rect1_org,
                out_global_ornt = identity_matrix);
        for (i=0; i<3; i++) mass_props[2+i] = rect1_org[i];
/*************************************************************************
        MScnvtprop(mass_props, rect1_org, identity_matrix, mass_props,
                   rect_org, identity_matrix);
*************************************************************************/
        ems$cnvtprop(
                in_props = mass_props,
                in_origin = rect1_org,
                in_global_ornt = identity_matrix,
                out_props = mass_props,
                out_origin = rect_org,
                out_global_ornt = identity_matrix);
        break;    

      default:
        break;

     } /* switch */  

    for (i=0; i<NUMB_PROPS; i++) me->mass_props[i] = mass_props[i];

    me->mp_valid = TRUE;
   }

  if (rotation)
   {
    /* Are the transformed axes in Right Handed system too? */
    /* If not, flip Z */
    /* Normalize the new axes */

    norm_1 = BSdistptpt(&msg, &xpoints[0][0], &xpoints[1][0]);
    norm_2 = BSdistptpt(&msg, &xpoints[0][0], &xpoints[2][0]);
    norm_3 = BSdistptpt(&msg, &xpoints[0][0], &xpoints[3][0]);

    for (i=0; i<3; i++)
     {
      out_mat[0][i] = (xpoints[1][i] - xpoints[0][i])/norm_1;
      out_mat[1][i] = (xpoints[2][i] - xpoints[0][i])/norm_2;
      new_z[i]   = (xpoints[3][i] - xpoints[0][i])/norm_3;
     }

    status = BScrossp(&msg,&out_mat[0][0],&out_mat[1][0],&out_mat[2][0]);

    norm_1 = new_z[0]*out_mat[2][0] + new_z[1]*out_mat[2][1] +
             new_z[2]*out_mat[2][2];

    if (norm_1 <= 0.0)  /* z axis has been flipped */
     {
      me->mass_props[9] = 0.0 - me->mass_props[9];      /* myz */
      me->mass_props[10] = 0.0 - me->mass_props[10];    /* mzx */
     }  
    
    norm_1 = BSdistptpt(&msg, &points[0][0], &points[1][0]);
    norm_2 = BSdistptpt(&msg, &points[0][0], &points[2][0]);

    for (i=0; i<3; i++)
     {
      in_mat[0][i] = (points[1][i] - points[0][i])/norm_1;
      in_mat[1][i] = (points[2][i] - points[0][i])/norm_2;
     }

    status = BScrossp(&msg, &in_mat[0][0], &in_mat[1][0], &in_mat[2][0]);

    status = MAinvmx(&msg, &dim, (IGRdouble *)out_mat, (IGRdouble *)out_mat_inv);
    if (! (1 & status & msg)) goto wrapup;
    status = MAinvmx(&msg, &dim, (IGRdouble *)in_mat, (IGRdouble *)in_mat_inv);
    if (! (1 & status & msg)) goto wrapup;
  
    if (me->axes_orient != PRINCIPAL)
     {
      /* Rotate properties */

      for (i=0; i<3; i++) mass_props[2+i] = me->mass_props[2+i];
      for (i=0; i<3; i++) me->mass_props[2+i] = rect_org[i];
/***************************************************************************
      MScnvtprop (me->mass_props, rect_org, in_mat_inv, mass_props,
                  rect_org, out_mat_inv);
***************************************************************************/
      ems$cnvtprop(
                in_props = me->mass_props,
                in_origin = rect_org,
                in_global_ornt = (IGRdouble *)in_mat_inv,
                out_props = mass_props,
                out_origin = rect_org,
                out_global_ornt = (IGRdouble *)out_mat_inv);  

      if (me->axes_orient == GENERAL)
       {
        status = MAinvmx(&msg, &dim, me->glo_loc, (IGRdouble *)glo_loc_inv);
        if (! (1 & status & msg)) goto wrapup;
/**************************************************************************
        MScnvtprop (me->mass_props, rect_org, out_mat_inv, mass_props,
                    rect_org, glo_loc_inv);
**************************************************************************/
        ems$cnvtprop(
                in_props = me->mass_props,
                in_origin = rect_org,
                in_global_ornt = (IGRdouble *)out_mat_inv,
                out_props = mass_props,
                out_origin = rect_org,
                out_global_ornt = (IGRdouble *)glo_loc_inv);
       }
      for (i=0; i<3; i++) me->mass_props[2+i] = mass_props[2+i];
     }
    
    if (me->axes_orient == PRINCIPAL)
     {
      k=0;
      for (i=0; i<3; i++)
       {
        for (j=0; j<3; j++)
         {
          me->glo_loc[k++] = out_mat[i][j];
         }
       }
     }

    if (me->axes_orient != PRINCIPAL)
     {
      for (i=0; i<NUMB_PROPS; i++) me->mass_props[i] = mass_props[i];
     }

    me->mp_valid = TRUE;
   }

  /* check for scaling -- if uniform scaling in all three directions then
     update the computed properties else invalidate the same */

  norm_1 = BSdistptpt(&msg, &matrix[0], zero_vect);
  norm_2 = BSdistptpt(&msg, &matrix[4], zero_vect);
  norm_3 = BSdistptpt(&msg, &matrix[8], zero_vect);

  scratch_1 = (norm_1 >= norm_2) ? (norm_1 - norm_2) : (norm_2 - norm_1);
  scratch_2 = (norm_1 >= norm_3) ? (norm_1 - norm_3) : (norm_3 - norm_1);

  if( (scratch_1 <= zero_tol) && (scratch_2 <= zero_tol) )
   {
    scaling_2 = norm_1 * norm_1;
    scaling_3 = scaling_2 * norm_1;
    scaling_4 = scaling_3 * norm_1;
    scaling_5 = scaling_4 * norm_1;

    me->mass_props[0]  *=  scaling_3;
    me->mass_props[1]  *=  scaling_3;
    me->mass_props[11]  *=  scaling_2;
    me->mass_props[14]  *=  scaling_4;
    me->mass_props[15]  *=  scaling_4;
    me->mass_props[16]  *=  scaling_4;

    if (me->operation_type == MASS_PROPERTIES)
     {
      me->mass_props[5]  *=  scaling_5;
      me->mass_props[6]  *=  scaling_5;
      me->mass_props[7]  *=  scaling_5;
      me->mass_props[8]  *=  scaling_5;
      me->mass_props[9]  *=  scaling_5;
      me->mass_props[10]  *=  scaling_5;
     }
    else
     {
      i = 1;
      status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           &me->mass_props[5], pxpoints);
      if (! (1 & status & msg)) goto wrapup;
      for (i=0; i<3; i++) me->mass_props[5+i] = pxpoints[i];

      i = 1;
      status = MAoptsxform(&msg, &i, matrix_type, matrix,
                           &me->mass_props[8], pxpoints);
      if (! (1 & status & msg)) goto wrapup;
      for (i=0; i<3; i++) me->mass_props[8+i] = pxpoints[i];
     }
   }
  else
   {
    me->mp_valid = FALSE;

    stat_OM = om$send(msg = message GRgraphics.GRdelete (&msg, md_env),
                      targetid = my_id);
    EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);

    goto wrapup;
   }

  /* transform for designator appropriately */

  switch (me->axes_orient)
   {
    case ACTIVE_AT_CENTROID:
         
         if (translation)
          {
           trans_matrix[3] =  xpoints[0][0] - points[0][0];
           trans_matrix[7] =  xpoints[0][1] - points[0][1];
           trans_matrix[11] = xpoints[0][2] - points[0][2];

           stat_OM = om$send (msg = message GRvg.GRxform (&msg, md_env,
                                    &trans_mat_type, trans_matrix,
                                    newobjid),
                              p_chanselect = &to_comps);
           EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
          }
         break;

    case PRINCIPAL:

         if (translation || rotation)
          {
           stat_OM = om$send (msg = message GRvg.GRxform (&msg, md_env,
                                    matrix_type, matrix, newobjid),
                              p_chanselect = &to_comps);
           EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
          }
         break;

    case GENERAL:
         break;
    default:
         if (translation || rotation)
          {
           stat_OM = om$send (msg = message GRvg.GRxform (&msg, md_env,
                                    matrix_type, matrix, newobjid),
                              p_chanselect = &to_comps);
           EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_Fail, wrapup);
          }
         break;
   }
     
  wrapup:

   EMWRAPUP (stat_OM, *EMmsg, "In EMSmassprop.EMintxform");
   return (stat_OM);
}

end implementation EMSmassprop;
