/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */

#include "EMS.h"

/*
 Description
     Given a planar surface's geometry, draft angle and the draft
     vector, this function returns the geometry of a plane which
     will encompass the geomtery of the drafted version of the
     original surface.

History
     RC   04/03/88     Creation Date
     Sudha 7/08/93     Modified for BSprototypes ansification

Algorithm
     o Check if the surface is a special plane.
     o If not construct a plane encompassing the geomtery of
       the incoming surface. If the plane created has its
       normal reversed to that of the incoming surface,
       reverse its normal.
     o else, copy the incoming sf_geomtery.
     o Rotate the plane such that plane's normal through
       uv(0.5,0.5) lies along the z_axis.
     o Scale the plane with scaling factors evaluated using
       draft_angle and draft_vec.
     o Transform the plane back to world coordinate system.
*/
     
#include <math.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "ma.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "maptsxfor.h"
#include "maoptsxfo.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "maidmx.h"
#include "bssfarrevn.h"
#include "bspl_of_pts.h"
#include "bslocalcord.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsallocsf.h"

void  EFget_drafted_sf_geom (
      EFmsg,
      sf_geom,
      is_sf_sp_plane,
      draft_vec,
      draft_angle,
      dsf_geom)

IGRlong                 *EFmsg;
struct IGRbsp_surface   *sf_geom;
IGRboolean              is_sf_sp_plane;
IGRvector               draft_vec;
IGRdouble               draft_angle;
struct IGRbsp_surface   **dsf_geom;
{
  IGRdouble     u, v, dvec_len, u_len, v_len, off_len, snrml_dot_dsnrml,
                sf_pt[3], sf_nrml[3], dsf_nrml[3], sw_poles[3],
                trans_mat[4][4], w_lc_mat[3][3], rot_mat[4][4],
                invrot_mat[4][4], trans2_mat[4][4], scale_mat[4][4],
                temp_mat1[4][4], temp_mat2[4][4], sc_tr_mat[4][4],
                u_axis[3], v_axis[3], sf_tr_pt[3], from_pt[3],
                
                *xform_mat, *temp_poles, *temp_u_knots, *temp_v_knots,
                *u0v0, *u1v0, *u0v1;

  IGRlong       rc, numpts;

  IGRint        i, low_left, low_right, up_left, up_right;

  IGRshort      xform_mattype, l = 4, m = 4, n = 4;

  IGRboolean    right_hand = TRUE, status;

  
  *EFmsg = EMS_S_Success;
  rc = OM_S_SUCCESS;

  BSallocsf (2, 2, 2, 2, FALSE, 0, dsf_geom, &rc);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  low_left = 0;
  low_right = (sf_geom->u_num_poles - 1) * 3;
  up_left = (sf_geom->u_num_poles * (sf_geom->v_num_poles-1)) * 3;
  up_right = up_left + low_right;
   
  u = v = 0.5;
  BSsfarrevn (&rc, sf_geom, 1, &u, 1, &v, sf_pt, sf_nrml);
  EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);

  if (is_sf_sp_plane)
  {
    temp_poles = (*dsf_geom)->poles;
    temp_u_knots = (*dsf_geom)->u_knots;
    temp_v_knots = (*dsf_geom)->v_knots;

    *(*dsf_geom) = *sf_geom;
    (*dsf_geom)->poles = temp_poles;
    (*dsf_geom)->u_knots = temp_u_knots;
    (*dsf_geom)->v_knots = temp_v_knots;

    (*dsf_geom)->u_num_poles = (*dsf_geom)->v_num_poles = 2;
    (*dsf_geom)->u_num_knots = (*dsf_geom)->v_num_knots = 4;

    OM_BLOCK_MOVE (&sf_geom->poles[low_left], &(*dsf_geom)->poles[0],
                   sizeof(IGRpoint) );
    OM_BLOCK_MOVE (&sf_geom->poles[low_right], &(*dsf_geom)->poles[3],
                   sizeof(IGRpoint) );
    OM_BLOCK_MOVE (&sf_geom->poles[up_left], &(*dsf_geom)->poles[6],
                   sizeof(IGRpoint) );
    OM_BLOCK_MOVE (&sf_geom->poles[up_right], &(*dsf_geom)->poles[9],
                   sizeof(IGRpoint) );

    for (i = 0; i < 2; i++)
      (*dsf_geom)->u_knots[i] = (*dsf_geom)->v_knots[i] = 0.;
    for (i = 2; i < 4; i++)
      (*dsf_geom)->u_knots[i] = (*dsf_geom)->v_knots[i] = 1.;

  } /* if (is_sf_sp_plane) */
  else
  {
    
    BSpl_of_pts ( (sf_geom->u_num_poles * sf_geom->v_num_poles),
                  sf_geom->poles, sf_geom->weights, *dsf_geom,
                  &rc);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
    
    /*
     * If the dsf_geom's normal is opposite to that of
     * sf_geom. Reverse the paramaterization to allign the
     * normals.
     */

    BSsfarrevn (&rc, *dsf_geom, 1, &u, 1, &v, sf_pt, dsf_nrml);
    EMerr_hndlr (BSERROR(rc), *EFmsg, EMS_E_BSerror, wrapup);

    snrml_dot_dsnrml = BSdotp (&rc, sf_nrml, dsf_nrml);
    EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

    if (snrml_dot_dsnrml < 0)
    {
      OM_BLOCK_MOVE ((*dsf_geom)->poles, sw_poles, sizeof(IGRpoint));
      OM_BLOCK_MOVE (&(*dsf_geom)->poles[9], 
                      (*dsf_geom)->poles, sizeof(IGRpoint));
      OM_BLOCK_MOVE (sw_poles, &(*dsf_geom)->poles[9], sizeof(IGRpoint));
    }

    (*dsf_geom)->pos_orient = sf_geom->pos_orient;

  } /* else for if (is_sf_sp_plane) */

/*
 * calculate the matrix to translate the surface
 * by the draft vector.
 */

status = MAtrlmx (&rc, draft_vec, &trans_mat[0][0]);
EMerr_hndlr (!status || !(1&rc), *EFmsg,EMS_E_Fail,wrapup);

if (draft_angle > 0.)
{
  /*
   * Get a matrix to bring the surface such that
   * x-axis is along u-direction, y-axis is along v-direction
   */

  u0v0 = &(*dsf_geom)->poles[low_left];
  u1v0 = &(*dsf_geom)->poles[low_right];
  u0v1 = &(*dsf_geom)->poles[up_left];

  for (i = 0; i < 3; i++)
  {
    u_axis[i] = sf_pt[i] + u1v0[i] - u0v0[i];
    v_axis[i] = sf_pt[i] + u0v1[i] - u0v0[i];
  }

  right_hand = TRUE;
  status = BSlocalcord (&rc, sf_pt, u_axis, v_axis, &right_hand, 
                        w_lc_mat);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  status = MAidmx (&rc, &rot_mat[0][0]);
  
  for (i = 0; i < 3; i++)
   OM_BLOCK_MOVE (&w_lc_mat[i][0], &rot_mat[i][0], sizeof(IGRpoint));

  status = MAinvmx (&rc, &n, &rot_mat[0][0], &invrot_mat[0][0]);
  EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);
  
  /*
   * Get a matrix to translate the sf(0.5,0.5) to origin.
   */

  status = MAidmx (&rc, &trans2_mat[0][0]);
  numpts = 1;
  status = MAptsxform (&rc, &numpts, &rot_mat[0][0], sf_pt, sf_tr_pt);
  EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);

  for ( i = 0; i < 3; i++)  
     trans2_mat[i][3] = sf_tr_pt[i];

  /*
   * get the matix to scale the planar surface about origin
   * in x and y direction.
   */
  
   for (i = 0; i < 3; i++)
      from_pt[i] = 0;

   dvec_len = BSdistptpt (&rc, from_pt, draft_vec);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   u_len = BSdistptpt (&rc, u0v0, u1v0);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   v_len = BSdistptpt (&rc, u0v0, u0v1);
   EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

   off_len = dvec_len * tan(draft_angle);

   status = MAidmx (&rc, &scale_mat[0][0]);

   scale_mat[0][0] = 1 + 2 * off_len/u_len;
   scale_mat[1][1] = 1 + 2 * off_len/v_len;

  /*
   * The matrix to scale the planar surface is
   * trans_mat * invrot_mat * trans2_mat * scale_mat * -trans2_mat * 
   * rot_mat.
   */

  status = MAmulmx (&rc, &l, &m, &n, &trans_mat[0][0], &invrot_mat[0][0], &temp_mat1[0][0]);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
 
  status = MAmulmx (&rc, &l, &m, &n, &temp_mat1[0][0], &trans2_mat[0][0], &temp_mat2[0][0]);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

  status = MAmulmx (&rc, &l, &m, &n, &temp_mat2[0][0], &scale_mat[0][0], &temp_mat1[0][0]);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

  for (i = 0; i < 3; i++)
    trans2_mat[i][3] = -trans2_mat[i][3];

  status = MAmulmx (&rc, &l, &m, &n, &temp_mat1[0][0], &trans2_mat[0][0], &temp_mat2[0][0]);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

  status = MAmulmx (&rc, &l, &m, &n, &temp_mat2[0][0], &rot_mat[0][0], &sc_tr_mat[0][0]);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
  
} /* if (draft_angle > 0.) */

xform_mat = ( draft_angle > 0. ) ? (double *)sc_tr_mat : (double *)trans_mat;

status = MAtypemx (&rc, xform_mat, &xform_mattype);
EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

numpts = 4;
status = MAoptsxform ( &rc, &numpts, &xform_mattype, xform_mat, 
                       (*dsf_geom)->poles, (*dsf_geom)->poles );
EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);

wrapup:
  EMWRAPUP (*EFmsg, rc, "In EFget_drafted_sf_geom");

  return;

} /* end EFget_drafted_sf_geom() */
