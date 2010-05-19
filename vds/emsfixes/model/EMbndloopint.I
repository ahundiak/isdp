/* $Id: EMbndloopint.I,v 1.1 2001/03/15 22:49:08 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc/EMbndloopint.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: EMbndloopint.I,v $
 *      Revision 1.1  2001/03/15 22:49:08  ramarao
 *      Fixed TR# 4115 && TR# 4099.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/15/01        Rama Rao        Memory Allocation Problem. 
 *					TR#4099 && TR# 4415.
 * -------------------------------------------------------------------*/

/* ###################   APOGEE COMPILED   ################## */
class implementation GRvg;

#include    "EMS.h"
#include    <stdio.h>
#include    "bserr.h"
#include    "bsparameters.h"
#include    "emsmacros.h"
#include    "emsdef.h"
#include    "emserr.h"
#include    "EMSmsgdef.h"
#include    "emsdattyp.h"
#include    "emsinter.h"
#include    "EMSbnddef.h"
#include    "EMSbnd.h"
#include 	"emsmass.h"
#include	"wanginc.h"
#include    "EMSopt.h"
#include    "OMmacros.h"
#include "ma.h"
#include "maptpypro.h"
#include "maptinpg.h"
#include "maplpytob.h"
#include "bssfeval.h"
#include "bsptnorpch.h"
#include "bsnorvec.h"
#include "bsfreecv.h"
#include "bsdistptpt.h"
#include "bsavgpts.h"
#include "bsalloccv.h"

#define OUT_TRIANGLE 0

%safe
static IGRboolean              EFis_nat_bdry();
static void EMfind_edge_match();
static IGRlong   EMinternal_loop_match();
static void EFend_validity();
%endsafe

EMboundary_loopint(EMmsg, patch_inx, loop_inx,
 loop_planar, loop_data, num_tply, tpl_data,
                   toln, option, surface, loop_int)

IGRlong                *EMmsg;
IGRint                 *patch_inx, *loop_inx;
IGRboolean             loop_planar;
struct Facetloop       *loop_data;
IGRint                 num_tply;
struct EMtopology_info *tpl_data;
IGRdouble              *toln;
IGRlong                option;
struct IGRbsp_surface  *surface;
IGRdouble              *loop_int;

{
/*
 		       C	       D
             -------------
            |             |
            |  7   8   9  |
            |             |
            |  4   5   6  |
            |             | 
            |  1   2   3  |
            |             | 
		    v-------------
            |  A           B
            |
            ---- u
   Let:
   P = B-A      = V12
   Q = C-A      = 0 if C=A
   R = A + D - B - C    = D - B if C = A	= V23

   Then:
   P(u,v) = A + Pu + Qv + Ruv	= A + Pu + Ruv
   dpdu   = P + Rv		= P + Rv
   dpdv   = Q + Ru		= Ru

   cross = dpdu x dpdv

     = (P x Q) + (P x R)u + (R x Q)v

     = (P x R)u

   cross  =   | i    j    k  |  + u | i   j   k  |  + v | i   j   k  |
              | Px   Py   Pz |	    | Px  Py  Pz |	    | Rx  Ry  Rz |
              | Qx   Qy   Qz |	    | Rx  Ry  Rz |	    | Qx  Qy  Qz |
	
	      = V12 x V23 u
History:
    gupta 12/09/88  Creation
    Sudha 06/28/93  Modified for BSprototype ansification

*/

#define MASS_PROPS 0
#define SURF_PROPS 1
#define AREA_ONLY  2

#define X	0
#define Y	1
#define Z	2

#define INSIDE 1
#define ALONG  0
#define OUTSIDE -1

#define VOL	0
#define MAS	1
#define MDX	2
#define MDY	3
#define MDZ	4
#define MX2	5
#define MY2	6
#define MZ2	7
#define MXY	8
#define MYZ	9
#define MZX	10

#define SUR	11
#define SRX	12
#define SRY	13
#define SRZ	14
#define SX2	15
#define SY2	16
#define SXY	17

#define CROSS_PR(A, B, C)       \
 {                              \
  C[X] = A[Y]*B[Z] - B[Y]*A[Z]; \
  C[Y] = A[Z]*B[X] - B[Z]*A[X]; \
  C[Z] = A[X]*B[Y] - B[X]*A[Y]; \
 }

  IGRlong            stat_OM = OM_S_SUCCESS, msg = EMS_S_Success;
  IGRlong            blk_size = 0;
  IGRint             num_in_copy = 0;
  IGRint             i, j, k;
  IGRint             wt_cnt = 0, num0 = 0, num1 = 0, num2 = 0, num3 = 0;
  IGRint             num_found = 0, num_loop_points = 0;
  IGRint             first_index = 0, last_index = 0, store_inx = 0;
  IGRint             callinx = 0, alloc_num = 0, num_pnts = 0, abcd = 0;
  IGRint             point_inx[4], save_inx[4]; 
  IGRshort           relation;
  IGRboolean         previous_match = FALSE, match1_found = FALSE;
  IGRboolean         close_loop = FALSE, match_found = FALSE, status;
  IGRboolean         inx_break = FALSE, first_bndry_inx_stored = FALSE;
  IGRboolean         complex_boundary = FALSE, bnd_indicator = FALSE;
  extern IGRdouble   sqrt(), fabs();
  IGRdouble          lprange[4], uvlentol;
  IGRdouble          tria_pnts[12];
  IGRdouble          cht_tol, dot_tol, bas_tol, k_tol;
  IGRdouble	         pnt[3], cross[3], u_vector[3], value, h_func,
                     V12[3], V13[3], V23[3],
                     ref_vec[3], dir_vec[3], dotpr,
                     quad_int[NUMB_PROPS], loc_loop_int[NUMB_PROPS],
                     cross_norm, delta_area;
  IGRdouble          avg_uv[2], u_par, v_par, dist;
  IGRdouble          *loop_points, *loop_copy;
  IGRdouble          temp_V12[3], temp_V13[3];
  IGRpoint           avg_point, start_point;
  
  /**************************************/

/*  IGRpoint           rem_this; */

  /**************************************/

  
  static IGRdouble
  u[3]  = { 0.1127016653792585, 0.5000000000000000, 0.8872983346207415},

  wt[9] = { 0.3086419753086424, 0.4938271604938275, 0.3086419753086424,
            0.4938271604938275, 0.7901234567901235, 0.4938271604938275,
            0.3086419753086424, 0.4938271604938275, 0.3086419753086424};

  struct IGRpolyline      loop_poly, dummy_poly;
  struct IGRbsp_curve     *pg_curve = NULL;
  struct EMSdataselect    poly_data;
  IGRboolean              EFadjust_index();
  extern IGRboolean       EFextract_par();
  void                    EM2dbx();

/*------------------------------------------------------------------*/

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol); 
  BSEXTRACTPAR(&msg, BSTOLCOLLINVEC, dot_tol);
  BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);
  BSEXTRACTPAR(&msg, BSTOLKNOT, k_tol);


  for(i=0; i<NUMB_PROPS; i++)
      loc_loop_int[i] = 0.0;

  first_bndry_inx_stored = FALSE;
  complex_boundary = FALSE;
  bnd_indicator = FALSE;
  previous_match = TRUE;
  match_found = FALSE;
  close_loop = FALSE;
  inx_break = FALSE; 
  loop_copy = NULL;
  loop_points = NULL;
  pg_curve = NULL;
  loop_poly.points = NULL;
  num_loop_points = 0;
  callinx = 0;
  num_pnts = 0;
  alloc_num = 0;
  blk_size = 3 * sizeof (IGRdouble);

  for (i=0; i<num_tply; i++)
   {
    if (tpl_data[i].poly->num_points > alloc_num)
        alloc_num = tpl_data[i].poly->num_points;
   }

  if (alloc_num <= 10) alloc_num = 20; /* if all are 2 nd order */

  /* 3 is for 3 doubles in point and 5 is with the assumption that 
     there will be at the most 5 sides in the loop */

  /* Increased from 5 to 15 - Rama Rao 03/15/01 */
  loop_points = (IGRdouble *) om$malloc (size = 3 * 15 * alloc_num *
                                                sizeof (IGRdouble));

  for (i=0; i<loop_data->np; i++)
   {
    if (loop_data->b_bit[i] != BOUNDARY_POINT)
     {
      if ((i == loop_data->np-1)&&(loop_data->b_bit[0] != BOUNDARY_POINT))
           break;
      point_inx[num_pnts++] = i;
      if (first_bndry_inx_stored)
       {
        bnd_indicator = TRUE;
        first_bndry_inx_stored = FALSE;
       }
     }
    else
     {
      if (! first_bndry_inx_stored)
       {
        if ((i == loop_data->np-1) && 
            (loop_data->b_bit[0] == BOUNDARY_POINT) &&
            (loop_data->b_bit[1] == BOUNDARY_POINT))
             break;
        if ((bnd_indicator) && (first_index != last_index))
             complex_boundary = TRUE;
        first_bndry_inx_stored = TRUE;
        first_index = i;
       }
      last_index = i;
     }
   }

  if (complex_boundary)
   {
    first_index = last_index = 0;
    first_bndry_inx_stored = FALSE;
    for (i=0; i<loop_data->np; i++)
     {
      if (loop_data->b_bit[i] != BOUNDARY_POINT)
       {
        if (first_index != last_index)
         {
          EMfind_edge_match(&msg, FALSE, num_tply, tpl_data, loop_data,
                            &num_loop_points, loop_points, first_index,
                            last_index, cht_tol, bas_tol, k_tol);
          if (! (1 & msg)) goto wrapup;
         }

        if (EFis_nat_bdry (loop_data, i-1, i, k_tol))
         {
          EMfind_edge_match (&msg, FALSE, num_tply, tpl_data, loop_data,
                             &num_loop_points, loop_points, i-1, i,
                             cht_tol, bas_tol, k_tol);
         }
        else
         {


          EMinternal_loop_match(&msg, num_tply, tpl_data, loop_data,
                                i-1, i, &match_found, toln, &bas_tol,
                                &cht_tol, &num_loop_points, loop_points);

          if (! match_found)
           {
            OM_BLOCK_MOVE (&loop_data->xyz[i * 3],
                           &loop_points[num_loop_points * 3], blk_size);
            num_loop_points++;
           }
         }

        first_index = last_index = 0;
        first_bndry_inx_stored = FALSE;
       }
      else
       {
        if (! first_bndry_inx_stored)
         {
          first_index = i;  
          first_bndry_inx_stored = TRUE;
          if (num_loop_points)
           {
            if (EFis_nat_bdry (loop_data, i-1, i, k_tol))
             {
              EMfind_edge_match (&msg,FALSE, num_tply, tpl_data,loop_data,
                                 &num_loop_points, loop_points, i-1, i,
                                 cht_tol, bas_tol, k_tol);
             }
            else
             {

              EMinternal_loop_match(&msg, num_tply, tpl_data, loop_data,
                                    i-1, i, &match_found, toln, &bas_tol,
                                 &cht_tol, &num_loop_points, loop_points);
             }
           }
         }
        last_index = i;
       }
     }

    if (first_index != last_index)
     {
      if (last_index-first_index > 1)
       {
        EMfind_edge_match(&msg, FALSE, num_tply, tpl_data, loop_data,
                          &num_loop_points, loop_points, first_index,
                          last_index, cht_tol, bas_tol, k_tol);
        if (! (1 & msg)) goto wrapup;
       }
     }

    close_loop = TRUE;
    goto all_points_on_boundary;
   }

  if (! num_pnts)
   {
    for (i=0; i<(loop_data->np - 1); i++)
     {
      first_index = i; last_index = i+1;

      EMfind_edge_match(&msg, FALSE, num_tply, tpl_data, loop_data,
                        &num_loop_points, loop_points, first_index,
                        last_index, cht_tol, bas_tol, k_tol);
      if (! (1 & msg)) goto wrapup;
     }
    goto all_points_on_boundary;
   }
 
  for (i=0; i<num_pnts-1; i++)
   {
    if ((point_inx[i+1] - point_inx[i]) != 1)
     {
      inx_break = TRUE; 
      store_inx = i+1;
      break;
     }
   }

  if (inx_break)
   {
    for (i=0; i<num_pnts; i++)
         save_inx[i] = point_inx[i];
    j = 0;
    for (i=store_inx; i<num_pnts; i++)
         point_inx[j++] = save_inx[i];
    for (i=0; i<store_inx; i++)
         point_inx[j++] = save_inx[i];
   }

  for (i=0; i<num_pnts-1; i++)
   {
    if (EFis_nat_bdry(loop_data, point_inx[i], point_inx[i+1], k_tol))
     {
      previous_match = TRUE;
      EMfind_edge_match (&msg, TRUE, num_tply, tpl_data, loop_data,
                         &num_loop_points, loop_points, point_inx[i],
                         point_inx[i+1], cht_tol, bas_tol, k_tol);
     }
    else
     {

      match_found = FALSE;
      EMinternal_loop_match(&msg, num_tply, tpl_data, loop_data,
                            point_inx[i], point_inx[i+1], &match_found,
                            toln, &bas_tol, &cht_tol, &num_loop_points,
                            loop_points);
      if (! match_found)
       {
        if (i == 0)
         {
          previous_match = FALSE;
          close_loop = TRUE;
         }
        else
         {
          previous_match = FALSE;
          if (close_loop)
           {
            OM_BLOCK_MOVE (&loop_data->xyz[point_inx[1] * 3],
                           &loop_points[num_loop_points * 3], blk_size);
            num_loop_points++;
           }
         }
       }
      else
       previous_match = TRUE;
     }
   }

  num0 = 0;  
  num1 = num_loop_points;

  if (EFis_nat_bdry(loop_data, point_inx[num_pnts-1], first_index, k_tol))
   {
    EMfind_edge_match (&msg, FALSE, num_tply, tpl_data, loop_data,
                       &num_loop_points,loop_points,point_inx[num_pnts-1],
                       first_index, cht_tol, bas_tol, k_tol);
    num0 = num_loop_points - num1;
   }
  else
   {

    match1_found = FALSE;
    EMinternal_loop_match(&msg, num_tply, tpl_data, loop_data,
                         point_inx[num_pnts-1], first_index,&match1_found,
                         toln, &bas_tol, &cht_tol, &num_loop_points,
                         loop_points);
    if (! match1_found)
     {
      if (num_pnts == 1)
       {
        OM_BLOCK_MOVE (&loop_data->xyz[point_inx[0] * 3],
                       &loop_points[num_loop_points * 3], blk_size);
        num_loop_points++;
       }
      else if (! previous_match)
       {
        OM_BLOCK_MOVE (&loop_data->xyz[point_inx[num_pnts-1] * 3],
                       &loop_points[num_loop_points * 3], blk_size);
        num_loop_points++;
       }
     }    
    else 
     {
      num0 = num_loop_points - num1;
     }
   }

  abcd = num_loop_points;
  EMfind_edge_match(&msg, FALSE, num_tply, tpl_data, loop_data,
                    &num_loop_points, loop_points, first_index,
                    last_index, cht_tol, bas_tol, k_tol);
  if (! (1 & msg)) goto wrapup;

  abcd = num_loop_points - abcd;


  match_found = FALSE;
  if (EFis_nat_bdry(loop_data, last_index, point_inx[0], k_tol))
   {
    EMfind_edge_match (&msg, FALSE, num_tply, tpl_data, loop_data,
                       &num_loop_points, loop_points, last_index,
                       point_inx[0], cht_tol, bas_tol, k_tol);
   }
  else
   {

    num2 = 0;
    num3 = num_loop_points;
    EMinternal_loop_match(&msg, num_tply, tpl_data, loop_data,
                          last_index, point_inx[0], &match_found,
                          toln, &bas_tol, &cht_tol, &num_loop_points,
                          loop_points);
    num2 = num_loop_points - num3;

    if ((! match_found) && (close_loop))
     {
      OM_BLOCK_MOVE (&loop_data->xyz[3 * point_inx[0]],
                     &loop_points[num_loop_points * 3], blk_size);
      num_loop_points++;
     }
    else if ((match_found) && (! close_loop))
     {
      if ((num_pnts == 1) && (! match1_found))
       {
        OM_BLOCK_MOVE (&loop_points[(num_loop_points-1) * 3],
                       &loop_points[0], blk_size);
       }
     }
   }

  if ((num_pnts == 1) && (abcd == 1))
   {
    if (match1_found && (! match_found))
     {
      num_loop_points = num0;

      OM_BLOCK_MOVE (&loop_data->xyz[3 * point_inx[0]],
                     &loop_points[num_loop_points * 3], blk_size);
      num_loop_points++;
     }
    else if ((! match1_found) && match_found)
     {
      OM_BLOCK_MOVE (&loop_data->xyz[3 * point_inx[0]],
                     &loop_points[num_loop_points * 3], blk_size);
      num_loop_points++;

      OM_BLOCK_MOVE (&loop_points[3 * (num_loop_points-num2)],
                     &loop_points[0], blk_size);
      num_loop_points = num2;
      match_found = FALSE;
     } 
   }

 all_points_on_boundary:

  if ((! match_found) || (close_loop))
   {
    OM_BLOCK_MOVE (&loop_points[0], &loop_points[num_loop_points * 3],
                   blk_size);
    num_loop_points++;
   }

  status = BSavgpts(&msg, num_loop_points,loop_points, NULL, avg_point);
  EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  if (! loop_planar)
   {
    avg_uv[0] = 0.0;
    avg_uv[1] = 0.0;

    for (i=0; i<loop_data->np; i++)
     {
      for (j=0; j<2; j++)
       {
        avg_uv[j] += loop_data->uv[i*2 + j];      
       }
     }

    for (i=0; i<2; i++)
         avg_uv[i] = avg_uv[i] / loop_data->np;

    BSptnorpch (avg_point, surface, avg_uv, &num_found, &dist, &u_par,
                &v_par, start_point, &msg);
    EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
   }
  else
   {
    num_found = 0;
   }
  
  if (! num_found)
      OM_BLOCK_MOVE (avg_point, start_point, sizeof (IGRpoint));

  loop_copy = (IGRdouble *) om$malloc (size = 3 * num_loop_points *
                                                  sizeof (IGRdouble));
  num_in_copy = 0;
  for (i=0; i<(num_loop_points-1); i++)
   {
    if ((BSdistptpt(&msg, &loop_points[3*i], &loop_points[3*(i+1)]) >
         bas_tol))
     {
      OM_BLOCK_MOVE (&loop_points[i * 3], &loop_copy[num_in_copy * 3],
                     blk_size);
      num_in_copy++;
     }
   }

  OM_BLOCK_MOVE (&loop_points[(num_loop_points-1) * 3], 
                 &loop_copy[num_in_copy * 3], blk_size);
  num_in_copy++;

  if (loop_points) om$dealloc (ptr = loop_points);

  loop_points = loop_copy;
  num_loop_points = num_in_copy;

  if (num_loop_points <= 3) goto wrapup;

  if (surface->planar)
   {
    loop_poly.num_points = num_loop_points;
    loop_poly.points = loop_points;

    BSalloccv(2, num_loop_points, FALSE, 0, &pg_curve, &msg);
    EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    status = MAplpytobc(&msg, &loop_poly, pg_curve);      
    EMerr_hndlr(! status || !(1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

    status = MAptinpg(&msg, start_point, pg_curve, &dot_tol, &relation);
    EMerr_hndlr(! status || !(1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

    if (relation == OUTSIDE)
     {
      dummy_poly.num_points = loop_data->np;
      dummy_poly.points = loop_data->uv;

      poly_data.datatype = EMSdata_poly2d;
      poly_data.data.poly = &dummy_poly;

      EM2dbx(loop_data->np, loop_data->uv, lprange);

      EFextract_par (BSTOLLENVEC, *toln, &uvlentol, &msg);

      EMptsinsidelp (&msg, &poly_data, lprange, 1, avg_uv, NULL, uvlentol,
                     &callinx, NULL);
      callinx++;
      BSsfeval(surface, avg_uv[0], avg_uv[1], 0, (IGRpoint *)start_point, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
     }
   }

  /* compute the best reference vector */
  
  for (j=0; j<3; j++)
   {
    temp_V12[j] = loop_points[j] - start_point[j];
    temp_V13[j] = loop_points[3 + j] - start_point[j];
   }

  CROSS_PR(temp_V12, temp_V13, ref_vec);    

  BSnorvec(&msg, ref_vec);

  retry:

  for (i=0; i<3; i++)
       V12[i] = loop_points[i] - start_point[i];
  
  /* If option is AREA_ONLY then no need to go through the mess */

  if(option == AREA_ONLY)
   {
    for(k=0; k<(num_loop_points - 1); k++)
     {
      for(i=0; i<3; i++)
       {
        V13[i] = loop_points[(k+1) * 3 + i] - start_point[i];
        pnt[i] = start_point[i] + loop_points[(k*3) + i] +
                                  loop_points[(k+1)*3 + i];
       }
 
      CROSS_PR(V12, V13, dir_vec);

      cross_norm = dir_vec[0] * dir_vec[0] + dir_vec[1] * dir_vec[1] +
                   dir_vec[2] * dir_vec[2];

      value = sqrt(cross_norm);

      dotpr = ref_vec[0] * dir_vec[0] + ref_vec[1] * dir_vec[1] +
              ref_vec[2] * dir_vec[2];

      /*
       * ignore contribution if dotpr is almost zero , i.e., the three
       * points define a plane perpendicular to the refernce vector
       * OR are collinear.
       */

      if (fabs (dotpr) < dot_tol)
          delta_area = 0.0;
	  else
          delta_area = (dotpr >= 0.0) ? (value) : ( - value);

      /* there is a bad point in the loop resulting in a negative area.
       * All the points in the loop should be in the same direction. If
       * this has happened i.e. dotpr < 0, throw away the bad point
       */

      loc_loop_int[SUR] += delta_area;
      loc_loop_int[SRX] += (delta_area * pnt[X]);
      loc_loop_int[SRY] += (delta_area * pnt[Y]);
      loc_loop_int[SRZ] += (delta_area * pnt[Z]);

      for (i=0; i<3; i++)
           V12[i] = V13[i];
     }

    if (loc_loop_int[SUR] < 0.0)
     {
      for(i=0; i<NUMB_PROPS; i++)
          loc_loop_int[i] = -loc_loop_int[i];
     }

    for(i=0; i<NUMB_PROPS; i++)
        loop_int[i] += loc_loop_int[i];
 
    return(stat_OM);  /* Changed to return stat_OM - Ashok */
   }	/* AREA_ONLY */


  for(k=0; k<(num_loop_points - 1); k++)
   {
    for (i=0; i<3; i++)
         V13[i] = loop_points[(k+1)*3 + i] - start_point[i];

    CROSS_PR(V12, V13, dir_vec);

    dotpr = ref_vec[0] * dir_vec[0] + ref_vec[1] * dir_vec[1] +
            ref_vec[2] * dir_vec[2];

    /*
     * ignore contribution if dotpr is almost zero , i.e., the three
     * points define a plane perpendicular to the refernce vector
     * OR are collinear.
     */

    if (fabs(dotpr) < dot_tol)
     {
      for (i=0; i<3; i++)
           V12[i] = V13[i];
      continue;
     }

    /* negative area is present, recompute the start point such that it
       lies inside the loop and does not contribute to negativity -- try
       atleast 10 times */

    if ((dotpr < dot_tol) && (callinx < 15))
     {
      for(i=0; i<NUMB_PROPS; i++)
          loc_loop_int[i] = 0.0;

      if (! callinx)
       {
        dummy_poly.num_points = loop_data->np;
        dummy_poly.points = loop_data->uv;

        poly_data.datatype = EMSdata_poly2d;
        poly_data.data.poly = &dummy_poly;
   
        EM2dbx(loop_data->np, loop_data->uv, lprange);
  
        EFextract_par (BSTOLLENVEC, *toln, &uvlentol, &msg);
       }

      EMptsinsidelp (&msg, &poly_data, lprange, 1, avg_uv, NULL,
                     uvlentol, &callinx, NULL);
      callinx++;
      BSsfeval(surface, avg_uv[0], avg_uv[1], 0, (IGRpoint *)start_point, &msg);
      EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      goto retry;
     }

/*
    if (dotpr < dot_tol)
        printf("Still Negative -- %f %f %f\n",start_point[0],
                start_point[1], start_point[2]);
*/
    for (i=0; i<3; i++)
         V23[i] = loop_points[(k+1)*3 + i] - loop_points[(k*3) + i];

    CROSS_PR(V12, V23, u_vector);

    for(i=0; i<NUMB_PROPS; i++)
        quad_int[i] = 0.0;

    wt_cnt = 0;

    for(i = 0; i < 3; i++)	       /* v varies */
     {
      for(j = 0; j < 3; j++)	   /* u varies */
       {
        pnt[X] = start_point[X] + V12[X]*u[j] + V23[X]*u[j]*u[i];
        pnt[Y] = start_point[Y] + V12[Y]*u[j] + V23[Y]*u[j]*u[i];
        pnt[Z] = start_point[Z] + V12[Z]*u[j] + V23[Z]*u[j]*u[i];

        cross[X] = u[j] * u_vector[X];
        cross[Y] = u[j] * u_vector[Y];
        cross[Z] = u[j] * u_vector[Z];
	
        cross_norm = cross[X] * cross[X] + cross[Y] * cross[Y] +
                     cross[Z] * cross[Z];
        cross_norm = sqrt(cross_norm);

        /* No matter what option return surface area */
	
        quad_int[SUR] += cross_norm * wt[wt_cnt];
	
        if (option == MASS_PROPS)
         {
          h_func = pnt[X]*cross[X] + pnt[Y]*cross[Y] + pnt[Z]*cross[Z];

          quad_int[VOL] += h_func * wt[wt_cnt];

          h_func = pnt[X] * pnt[X] * cross[X] * wt[wt_cnt];
          quad_int[MDX] += h_func;
          quad_int[MX2] += h_func * pnt[X];

          h_func = pnt[Y] * pnt[Y] * cross[Y] * wt[wt_cnt];
          quad_int[MDY] += h_func;
          quad_int[MY2] += h_func * pnt[Y];

          h_func = pnt[Z] * pnt[Z] * cross[Z] * wt[wt_cnt];
          quad_int[MDZ] += h_func;
          quad_int[MZ2] += h_func * pnt[Z];

          h_func = pnt[X] * pnt[Y] * pnt[Z];

          quad_int[MXY] += h_func * cross[Z] * wt[wt_cnt];

          quad_int[MYZ] += h_func * cross[X] * wt[wt_cnt];

          quad_int[MZX] += h_func * cross[Y] * wt[wt_cnt];
         }
        else
        if (option == SURF_PROPS)
         {
          /* da X px | (dp/du x dp/dv) |      */   
          /* da X2 px.px. | (dp/du x dp/dv) | */
	
          quad_int[SRX] += cross_norm * pnt[X] * wt[wt_cnt];
          quad_int[SX2] += cross_norm * pnt[X] * pnt[X] * wt[wt_cnt];

          /* da Y py | (dp/du x dp/dv) |      */
          /* da Y2 py.py. | (dp/du x dp/dv) | */
	
          quad_int[SRY] += cross_norm * pnt[Y] * wt[wt_cnt];
          quad_int[SY2] += cross_norm * pnt[Y] * pnt[Y] * wt[wt_cnt];
	
          /* da XY px.py. | (dp/du x dp/dv) | */
	
          quad_int[SXY] += cross_norm * pnt[X] * pnt[Y] * wt[wt_cnt];
         }

        wt_cnt ++;

       }    /* j loop */
     }      /* i loop */

    if(dotpr < 0.0)
       quad_int[SUR] = -quad_int[SUR];

    for(i=0; i<NUMB_PROPS; i++)
        loc_loop_int[i] += quad_int[i];

    for (i=0; i<3; i++)
         V12[i] = V13[i];
   }   /* num_loop_points */

  if (loc_loop_int[SUR] < 0.0)
   {
    loc_loop_int[SUR] = -loc_loop_int[SUR];
   }

  for(i=0; i<NUMB_PROPS; i++)
      loop_int[i] += loc_loop_int[i];
  loop_int[MAS] = loop_int[VOL];

/***********************
 rem_this[0] = 1622.85470129;
 rem_this[1] = 29.92410819;
 rem_this[2] = -112.49523255;

 if (BSdistptpt(&msg, rem_this, start_point) <= cht_tol)
     printf("0 - bad points ---- patch_inx , loop_inx %d %d\n",
             *patch_inx, *loop_inx);
**************************/

#if OUT_TRIANGLE

for (i=0; i<(num_loop_points - 1); i++)
 {
  for (k=0; k<3; k++)
   {
    tria_pnts[k] = start_point[k];
    tria_pnts[k+3] = loop_points[(3*i) + k];
    tria_pnts[k+6] = loop_points[(i+1) * 3 + k];
    tria_pnts[k+9] = start_point[k];
   }
  outtng(tria_pnts);
 }
#endif

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMboundary_loopint");
 if (loop_points) om$dealloc (ptr = loop_points);
 if (loop_copy) om$dealloc (ptr = loop_copy);
 if (pg_curve) BSfreecv(&msg, pg_curve);
 return (stat_OM);
}

static IGRboolean EFis_nat_bdry(l_dat, ix0, ix1, ktol)
struct Facetloop  *l_dat;
IGRint            ix0, ix1;
IGRdouble         ktol;
{
 if (((l_dat->uv[2*ix0]   <=   ktol) && (l_dat->uv[2*ix1]   <=   ktol)) ||
     ((l_dat->uv[2*ix0]   >= 1-ktol) && (l_dat->uv[2*ix1]   >= 1-ktol)) ||
     ((l_dat->uv[2*ix0+1] <=   ktol) && (l_dat->uv[2*ix1+1] <=   ktol)) ||
     ((l_dat->uv[2*ix0+1] >= 1-ktol) && (l_dat->uv[2*ix1+1] >= 1-ktol)))
  return (TRUE);
 else
  return (FALSE);
}

static void EMfind_edge_match (EMmsg, n_bdry, num_tply, tpl_data, loop_data,
                          num_loop_points, loop_points, first_index,
                          last_index, cht_tol, bastol, k_tol)
IGRlong                *EMmsg;
IGRboolean             n_bdry;
IGRint                 num_tply;
struct EMtopology_info *tpl_data;
struct Facetloop       *loop_data;
IGRint                 *num_loop_points;
IGRdouble              *loop_points;
IGRint                 first_index, last_index;
IGRdouble              cht_tol, bastol, k_tol;

{
 IGRlong               msg, seg_inx0 = 0, seg_inx1 = 0, s0 = 0, s1 = 0;
 IGRint                i, j, tpl_inx = 0, tpl_inx1 = 0;
 IGRint                save_inx = 0, store_inx = 0,
                       pnt_inx0 = 0, pnt_inx1 = 0, p0 = 0, p1 = 0;
 IGRint                tag = 0;
 IGRboolean            unique_edge = FALSE, inx_reduced = FALSE;
 IGRboolean            first_valid = FALSE, last_valid = FALSE;
 IGRlong               blk_size = 0;
 IGRdouble             dist1, dist2;
 IGRdouble             t1_par, t2_par, t0, t1;
 IGRdouble             proj_pt0[3], proj_pt1[3];
extern IGRdouble fabs() ;
 IGRboolean              EFadjust_index();
/*----------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 
 unique_edge = FALSE;
 first_valid = last_valid = FALSE;

 blk_size = 3 * sizeof (IGRdouble);

 EFend_validity (num_tply, tpl_data, loop_data, first_index, last_index,
                 &first_valid, &last_valid, bastol);

 for (i=0; i<num_tply; i++)
  {
   if ((tpl_data[i].poly->points) && (tpl_data[i].boundary_poly))
    {
     MAptpyproj (&msg, &loop_data->xyz[first_index * 3],
                 tpl_data[i].poly, proj_pt0, &t1_par, &seg_inx0);
     EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

     dist1 = BSdistptpt(&msg, &loop_data->xyz[first_index *3], proj_pt0);
     if (dist1 <= 5 * cht_tol) /* 12 times cht */
      {
       tpl_inx = i;
       MAptpyproj (&msg, &loop_data->xyz[last_index * 3],
                   tpl_data[i].poly, proj_pt1, &t2_par, &seg_inx1);
       EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

       dist2 = BSdistptpt(&msg, &loop_data->xyz[last_index*3], proj_pt1);
       if (dist2 <= 5 * cht_tol)
        {
         unique_edge = TRUE;
         tpl_inx = i;
         break;
        }
       else
       if (((t1_par <= bastol) && (seg_inx0 == 1)) ||
           ((t1_par >= 1-bastol) &&
           (seg_inx0 == tpl_data[i].poly->num_points-1)))
        {
         MAptpyproj (&msg, &loop_data->xyz[(first_index + 1) * 3],
                     tpl_data[i].poly, proj_pt1, &t2_par, &seg_inx1);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
           
         dist2 = BSdistptpt(&msg, &loop_data->xyz[(first_index + 1) * 3],
                            proj_pt1);
         if (dist2 <= 5 * cht_tol) break; /* 12 * cht */
        }
      }
    }
  }  

 if ((first_valid) && (n_bdry))
  {
   OM_BLOCK_MOVE (&loop_data->xyz[first_index * 3],
                  &loop_points[(*num_loop_points)*3], blk_size);
   (*num_loop_points)++;
  }

 if (! unique_edge)
  {
   inx_reduced = FALSE;

   MAptpyproj (&msg, &loop_data->xyz[first_index * 3],
               tpl_data[tpl_inx].poly, proj_pt0, &t1_par, &seg_inx0);
   EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

   pnt_inx0 = (t1_par <= 0.5) ? seg_inx0-1 : seg_inx0;

   if (((first_index+1) == last_index) ||
       ((first_index == loop_data->np-1) && (last_index == 1)))
    {
     if (first_valid)
       OM_BLOCK_MOVE (&loop_data->xyz[first_index * 3],
                      &loop_points[(*num_loop_points)*3], blk_size);
     else
       OM_BLOCK_MOVE (&tpl_data[tpl_inx].poly->points[pnt_inx0 * 3],
                      &loop_points[(*num_loop_points)*3], blk_size);
     (*num_loop_points)++;
    }
   else
    {
     for (i=first_index+1; i<=last_index; i++)
      {
       MAptpyproj (&msg, &loop_data->xyz[i * 3], tpl_data[tpl_inx].poly,
                   proj_pt1, &t2_par, &seg_inx1);
       EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

       dist2 = BSdistptpt(&msg, &loop_data->xyz[i * 3], proj_pt1);
       if (dist2 <= 5 * cht_tol) continue;
       else
        {
         store_inx = (i == last_index) ? i-1 : i;

         MAptpyproj (&msg, &loop_data->xyz[(i-1) * 3],
                    tpl_data[tpl_inx].poly, proj_pt1, &t2_par, &seg_inx1);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

         pnt_inx1 = (t2_par <= 0.5) ? seg_inx1-1 : seg_inx1;

         if ((pnt_inx1 == 0) ||
             (pnt_inx1 == tpl_data[tpl_inx].poly->num_points-1))
          {
           store_inx = i-1;
           inx_reduced = TRUE;
          }

         EFend_validity (num_tply, tpl_data, loop_data, first_index, i-1,
                         &first_valid, &last_valid, bastol);

         if ((pnt_inx0 == pnt_inx1)&& (! first_valid) && (! last_valid) &&
             (tpl_data[tpl_inx].poly->num_points == 2))
          {
           OM_BLOCK_MOVE (&loop_data->xyz[first_index * 3],
                          &loop_points[(*num_loop_points)*3], blk_size);
           (*num_loop_points)++;
          }

         if (EFadjust_index (&pnt_inx0, &pnt_inx1, t1_par, t2_par,
                             first_valid, last_valid,
                             tpl_data[tpl_inx].poly, bastol))
          {
           EMinsert_points (pnt_inx0, pnt_inx1, tpl_data[tpl_inx].poly,
                            num_loop_points, loop_points, bastol);
          }

         if (last_valid)
          {
           OM_BLOCK_MOVE (&loop_data->xyz[(i-1) * 3],
                          &loop_points[(*num_loop_points)*3], blk_size);
           (*num_loop_points)++;
          }

         break;
        }
      }
    }

   for (i=0; i<num_tply; i++)
    {
     if ((tpl_data[i].poly->points) && (tpl_data[i].boundary_poly))
      {
       MAptpyproj (&msg, &loop_data->xyz[last_index * 3],
                   tpl_data[i].poly, proj_pt0, &t1_par, &seg_inx0);
       EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

       dist1 = BSdistptpt(&msg,&loop_data->xyz[last_index *3], proj_pt0);
       if (dist1 <= 5 * cht_tol)
        {
         if (((first_index+1) == last_index) ||
             ((first_index == loop_data->np-1) && (last_index == 1)))

          {
           if (last_valid)
            {
             OM_BLOCK_MOVE (&loop_data->xyz[last_index *3],
                            &loop_points[(*num_loop_points)*3], blk_size);
            }
           else
            {
             pnt_inx0 = (t1_par <= 0.5) ? seg_inx0-1 : seg_inx0;

             OM_BLOCK_MOVE (&tpl_data[i].poly->points[pnt_inx0 * 3],
                            &loop_points[(*num_loop_points)*3], blk_size);
            }
           (*num_loop_points)++;
           return;
          }

         if (((t1_par <= bastol) && (seg_inx0 == 1)) ||
             ((t1_par >= 1-bastol) &&
              (seg_inx0 == tpl_data[i].poly->num_points-1)))
          {
           MAptpyproj (&msg, &loop_data->xyz[(last_index - 1) * 3],
                       tpl_data[i].poly, proj_pt1, &t2_par, &seg_inx1);
           EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
           
           if ((fabs(t1_par-t2_par) <= k_tol) && (seg_inx0 == seg_inx1))
                continue;
          }
         tpl_inx1 = i;
         break;
        }
      }
    }  

   if (((first_index+1) == last_index) ||
       ((first_index == loop_data->np-1) && (last_index == 1)))
    {

     /* control should not have come here but 'cause of cht it may not
     have hit an edge in which case store_inx is GARBAGE */

     OM_BLOCK_MOVE (&loop_data->xyz[last_index *3],
                    &loop_points[(*num_loop_points)*3], blk_size);
     (*num_loop_points)++;
     return;
    }

   pnt_inx1 = (t1_par <= 0.5) ? seg_inx0-1 : seg_inx0;

   MAptpyproj (&msg, &loop_data->xyz[store_inx * 3],
               tpl_data[tpl_inx1].poly, proj_pt1, &t2_par, &seg_inx1);
   EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

   if ((! inx_reduced) &&  
       (BSdistptpt(&msg,&loop_data->xyz[store_inx * 3],proj_pt1)>cht_tol))
    {
     inx_reduced = TRUE;
     store_inx -= 1;
    }

   more_data:

   if (inx_reduced)
    {
     if (BSdistptpt(&msg,&loop_data->xyz[store_inx * 3],proj_pt1)>cht_tol)
      {
       save_inx = store_inx;
       store_inx += 1;

       MAptpyproj (&msg, &loop_data->xyz[store_inx * 3],
                   tpl_data[tpl_inx1].poly, proj_pt1, &t2_par, &seg_inx1);
       EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

       if (BSdistptpt(&msg,&loop_data->xyz[store_inx * 3],proj_pt1) >
           cht_tol)
        {
         for (i=0; i<num_tply; i++)
          {
           if ((tpl_data[i].poly->points)&&(tpl_data[i].boundary_poly) &&
               (i != tpl_inx) && (i != tpl_inx1))
            {
             MAptpyproj (&msg, &loop_data->xyz[store_inx * 3],
                         tpl_data[i].poly, proj_pt0, &t0, &s0);
             EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

             if (BSdistptpt(&msg,&loop_data->xyz[store_inx * 3], proj_pt0)
                 <= cht_tol)
              {
               if (tpl_data[i].poly->num_points == 2)
                {
                 if (t0 <= 0.5)
                     {p0 = p1 = s0-1;}
                 else
                     {p0 = p1 = s0;}
                 EMinsert_points (p0, p1, tpl_data[i].poly,
                                  num_loop_points, loop_points, bastol);
                }
               else
                {
                 store_inx -= 1;

                 for (j=store_inx+1; j<=last_index; j++)
                  {
                   MAptpyproj (&msg, &loop_data->xyz[j * 3],
                               tpl_data[i].poly, proj_pt0, &t1, &s1);
                   EMerr_hndlr(!(1 & msg),*EMmsg,EMS_E_MAerror, wrapup);

                   dist2=BSdistptpt(&msg,&loop_data->xyz[j*3],proj_pt0);
                  
                   if ((dist2 <= 5 * cht_tol) && (j != last_index))
                        continue;
                   else
                    {
                     store_inx = j;
                     tag = (j == last_index) ? j : j-1;

                     MAptpyproj (&msg, &loop_data->xyz[tag * 3],
                     tpl_data[i].poly, proj_pt1, &t1, &s1);
                     EMerr_hndlr(!(1&msg),*EMmsg,EMS_E_MAerror, wrapup);

                     p0 = (t0 <= 0.5) ? s0 - 1 : s0;
                     p1 = (t1 <= 0.5) ? s1 - 1 : s1;

                     EFend_validity (num_tply, tpl_data, loop_data,
                                     save_inx, j-1, &first_valid,
                                     &last_valid, bastol);

                     if (first_valid)
                      {
                       OM_BLOCK_MOVE (&loop_data->xyz[save_inx * 3],
                           &loop_points[(*num_loop_points)*3], blk_size);
                       (*num_loop_points)++;
                      }

                     if (EFadjust_index (&p0, &p1, t0, t1, first_valid,
                                         last_valid, tpl_data[i].poly,
                                         bastol))
                      {
                       EMinsert_points(p0, p1, tpl_data[i].poly,
                                  num_loop_points, loop_points, bastol);
                      }

                     if (last_valid)
                      {
                       OM_BLOCK_MOVE (&loop_data->xyz[(j-1) * 3],
                            &loop_points[(*num_loop_points)*3], blk_size);
                       (*num_loop_points)++;
                      }

                     MAptpyproj (&msg, &loop_data->xyz[store_inx * 3],
                     tpl_data[tpl_inx1].poly, proj_pt1,&t2_par,&seg_inx1);
                     EMerr_hndlr(!(1 & msg),*EMmsg,EMS_E_MAerror, wrapup);

                     if (BSdistptpt (&msg, &loop_data->xyz[store_inx * 3],
                         proj_pt1) > cht_tol)
                      {
                       tpl_inx = i;
                       goto more_data;
                      }

                     goto interim_process;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }  /* inx_reduced */

 interim_process:

   pnt_inx0 = (t2_par <= 0.5) ? seg_inx1-1 : seg_inx1;

   EFend_validity (num_tply, tpl_data, loop_data, store_inx, last_index,
                   &first_valid, &last_valid, bastol);

   if (first_valid)
    {
     OM_BLOCK_MOVE (&loop_data->xyz[store_inx * 3],
                    &loop_points[(*num_loop_points)*3], blk_size);
     (*num_loop_points)++;
    }

   if (EFadjust_index (&pnt_inx0, &pnt_inx1, t2_par, t1_par, first_valid,
                       last_valid, tpl_data[tpl_inx1].poly, bastol))
    {
     EMinsert_points (pnt_inx0, pnt_inx1, tpl_data[tpl_inx1].poly,
                      num_loop_points, loop_points, bastol);
    }

   if ((pnt_inx0 == pnt_inx1) && (! first_valid) && (! last_valid) &&
       (tpl_data[tpl_inx1].poly->num_points == 2))
    {
     OM_BLOCK_MOVE (&loop_data->xyz[last_index * 3],
                    &loop_points[(*num_loop_points)*3], blk_size);
     (*num_loop_points)++;
    }
  }
 else
  {  
   if (tpl_data[tpl_inx].poly->num_points == 2)
    {
     OM_BLOCK_MOVE (&loop_data->xyz[first_index * 3],
                    &loop_points[(*num_loop_points) * 3], blk_size);
     (*num_loop_points)++;

     OM_BLOCK_MOVE (&loop_data->xyz[last_index * 3],
                    &loop_points[(*num_loop_points) * 3], blk_size);
     (*num_loop_points)++;
    }
   else
    {
     pnt_inx0 = (t1_par <= 0.5) ? seg_inx0-1 : seg_inx0;
     pnt_inx1 = (t2_par <= 0.5) ? seg_inx1-1 : seg_inx1;

     EFend_validity (num_tply, tpl_data, loop_data, first_index,
                     last_index, &first_valid, &last_valid, bastol);

     if (EFadjust_index (&pnt_inx0, &pnt_inx1, t1_par, t2_par,
                         first_valid, last_valid, tpl_data[tpl_inx].poly,
                         bastol))
      {
       EMinsert_points (pnt_inx0, pnt_inx1, tpl_data[tpl_inx].poly,
                        num_loop_points, loop_points, bastol);
      }
    }
  }

 if ((last_valid) && (n_bdry))
  {
   OM_BLOCK_MOVE (&loop_data->xyz[last_index * 3],
                  &loop_points[(*num_loop_points)*3], blk_size);
   (*num_loop_points)++;
  }

wrapup:

 EMWRAPUP (*EMmsg, *EMmsg, "GRvg.EMfind_edge_match");

 return;
}


EMinsert_points (pnt_inx0, pnt_inx1, poly, num_loop_points, loop_points,
                 bas_tol)

IGRint              pnt_inx0, pnt_inx1;
struct IGRpolyline  *poly;
IGRint              *num_loop_points;
IGRdouble           *loop_points;
IGRdouble           bas_tol;
{
 IGRint            i;
 IGRlong           msg, blk_size = 0;
 IGRdouble         dist;

 blk_size = 3 * sizeof (IGRdouble);
 dist = BSdistptpt(&msg, &poly->points[0],
                   &poly->points[3 * (poly->num_points - 1)]);

 if (pnt_inx0 <= pnt_inx1)
  {
   if (((pnt_inx1-pnt_inx0) > (poly->num_points - pnt_inx1 + pnt_inx0)) &&
        (dist <= bas_tol))
    {
     for (i=pnt_inx0; i>=0; i--)
      {
       OM_BLOCK_MOVE (&poly->points[i*3],
                      &loop_points[(*num_loop_points) * 3], blk_size);
       (*num_loop_points)++;
      }
     for (i=poly->num_points-1; i>=pnt_inx1; i--)
      {
       OM_BLOCK_MOVE (&poly->points[i*3],
                      &loop_points[(*num_loop_points) * 3], blk_size);
       (*num_loop_points)++;
      }
    }
   else
    {
     for (i=pnt_inx0; i<=pnt_inx1; i++)
      {
       OM_BLOCK_MOVE (&poly->points[i*3],
                      &loop_points[(*num_loop_points) * 3], blk_size);
       (*num_loop_points)++;
      }
    }
  }
 else
  {
   if (((pnt_inx0-pnt_inx1) > (poly->num_points - pnt_inx0 + pnt_inx1)) &&
        (dist <= bas_tol))
    {
     for (i=pnt_inx0; i<poly->num_points-1; i++)
      {
       OM_BLOCK_MOVE (&poly->points[i*3],
                      &loop_points[(*num_loop_points) * 3], blk_size);
       (*num_loop_points)++;
      }
     for (i=0; i<=pnt_inx1; i++)
      {
       OM_BLOCK_MOVE (&poly->points[i*3],
                      &loop_points[(*num_loop_points) * 3], blk_size);
       (*num_loop_points)++;
      }
    }
   else
    {
     for (i=pnt_inx0; i>=pnt_inx1; i--)
      {
       OM_BLOCK_MOVE (&poly->points[i*3],
                      &loop_points[(*num_loop_points) * 3], blk_size);
       (*num_loop_points)++;
      }
    }
  }
 return(1);
}

static IGRlong EMinternal_loop_match(EMmsg, num_tply, tpl_data, loop_data,
                                     first_inx, last_inx,match_found,toln,
                                     bastol, cht_tol, num_loop_points,
                                     loop_points)

IGRlong                *EMmsg;
IGRint                 num_tply;
struct EMtopology_info *tpl_data;
struct Facetloop       *loop_data;
IGRint                 first_inx, last_inx;
IGRboolean             *match_found;
IGRdouble              *toln, *bastol, *cht_tol;
IGRint                 *num_loop_points;
IGRdouble              *loop_points;

{
 IGRlong               msg;
 IGRlong               seg_inx0 = 0, seg_inx1 = 0, seg = 0, 
                       blk_size = 0;
 IGRboolean            first_valid = FALSE, last_valid = FALSE;
 IGRboolean            first_corner = FALSE, last_corner = FALSE;
 IGRint                i, j, k, match_inx = 0;
 IGRint                pnt_inx0 = 0, pnt_inx1 = 0, pnx = 0;
 IGRdouble             dist, t1_par, t2_par, t;
 IGRdouble             proj_pt0[3], proj_pt1[3], p_pt[3];
 extern IGRdouble      fabs();
 IGRboolean              EFadjust_index();
/*----------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;

 *match_found = FALSE;
 first_corner = FALSE;
 last_corner = FALSE;

 blk_size = 3 * sizeof (IGRdouble);

 for (j=0; j<num_tply; j++)
  {
   if (! tpl_data[j].boundary_poly)
    {
     if (tpl_data[j].u_dir)
      {
       if ((fabs (loop_data->uv[first_inx * 2] -
                  tpl_data[j].param) < *toln) &&
                 (fabs (loop_data->uv[last_inx * 2] -
                  tpl_data[j].param) < *toln))
        {
         for (k=0; k<num_tply; k++)
          {
           if ((! tpl_data[k].u_dir) && (! tpl_data[k].boundary_poly))
            {
             if (fabs (loop_data->uv[first_inx * 2 + 1] -
                 tpl_data[k].param) <= *toln)
                 first_corner = TRUE;
             if (fabs (loop_data->uv[last_inx * 2 + 1] -
                 tpl_data[k].param) <= *toln)
                 last_corner = TRUE;
            }
          }
         *match_found = TRUE;
         match_inx = j;
         break;
        }
      }
     else
      {
       if ((fabs (loop_data->uv[first_inx * 2 + 1] -
                  tpl_data[j].param) < *toln) &&
           (fabs (loop_data->uv[last_inx * 2 + 1] -
                  tpl_data[j].param) < *toln))
        {
         for (k=0; k<num_tply; k++)
          {
           if ((tpl_data[k].u_dir) && (! tpl_data[k].boundary_poly))
            {
             if (fabs (loop_data->uv[first_inx * 2] -
                 tpl_data[k].param) <= *toln)
                 first_corner = TRUE;
             if (fabs (loop_data->uv[last_inx * 2] -
                 tpl_data[k].param) <= *toln)
                 last_corner = TRUE;
            }
          }
         *match_found = TRUE;
         match_inx = j;
         break;
        }
      }
    }
  }

 if ((*match_found) && (tpl_data[match_inx].poly->num_points == 2))
  {
   if (loop_data->b_bit[first_inx] == BOUNDARY_POINT)
    {
     for (i=0; i<num_tply; i++)
      {
       if ((tpl_data[i].poly->points) && (tpl_data[i].boundary_poly))
        {
         MAptpyproj (&msg, &loop_data->xyz[first_inx * 3],
                     tpl_data[i].poly, p_pt, &t, &seg);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
         dist = BSdistptpt(&msg, &loop_data->xyz[first_inx *3], p_pt);
         if (dist <= 2 * (*cht_tol))
          {
           pnx = (t <= 0.5) ? seg - 1 : seg;
           if (tpl_data[i].poly->num_points > 2)
            {
             OM_BLOCK_MOVE (&tpl_data[i].poly->points[pnx * 3],
                            &loop_data->xyz[first_inx * 3], blk_size);
            }
           break;
          }
        }
      }
    }

   if (loop_data->b_bit[last_inx] == BOUNDARY_POINT)
    {
     for (i=0; i<num_tply; i++)
      {
       if ((tpl_data[i].poly->points) && (tpl_data[i].boundary_poly))
        {
         MAptpyproj (&msg, &loop_data->xyz[last_inx * 3],
                     tpl_data[i].poly, p_pt, &t, &seg);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
         dist = BSdistptpt(&msg, &loop_data->xyz[last_inx *3], p_pt);
         if (dist <= 2 * (*cht_tol))
          {
           pnx = (t <= 0.5) ? seg - 1 : seg;
           if (tpl_data[i].poly->num_points > 2)
            {
             OM_BLOCK_MOVE (&tpl_data[i].poly->points[pnx * 3],
                            &loop_data->xyz[last_inx * 3], blk_size);
            }
           break;
          }
        }
      }
    }

   OM_BLOCK_MOVE (&loop_data->xyz[first_inx * 3],
                  &loop_points[(*num_loop_points) * 3], blk_size);
   (*num_loop_points)++;

   OM_BLOCK_MOVE (&loop_data->xyz[last_inx * 3],
                  &loop_points[(*num_loop_points) * 3], blk_size);
   (*num_loop_points)++;
  }
 else if (*match_found)
  {
   MAptpyproj (&msg, &loop_data->xyz[first_inx * 3],
               tpl_data[match_inx].poly, proj_pt0, &t1_par, &seg_inx0);
   EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
   MAptpyproj (&msg, &loop_data->xyz[last_inx * 3],
               tpl_data[match_inx].poly, proj_pt1, &t2_par, &seg_inx1);
   EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

   pnt_inx0 = (t1_par <= 0.5) ? seg_inx0-1 : seg_inx0;
   pnt_inx1 = (t2_par <= 0.5) ? seg_inx1-1 : seg_inx1;

   first_valid = ((first_corner) ||
                  (loop_data->b_bit[first_inx] == BOUNDARY_POINT)) ?
                                                       TRUE : FALSE;
   last_valid = ((last_corner) ||
                   (loop_data->b_bit[last_inx] == BOUNDARY_POINT)) ?
                                                       TRUE : FALSE;

   if (loop_data->b_bit[first_inx] == BOUNDARY_POINT)
    {
     for (i=0; i<num_tply; i++)
      {
       if ((tpl_data[i].poly->points) && (tpl_data[i].boundary_poly))
        {
         MAptpyproj (&msg, &loop_data->xyz[first_inx * 3],
                     tpl_data[i].poly, p_pt, &t, &seg);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
         dist = BSdistptpt(&msg, &loop_data->xyz[first_inx *3], p_pt);
         if (dist <= 2 * (*cht_tol))
          {
           pnx = (t <= 0.5) ? seg - 1 : seg;
           if (tpl_data[i].poly->num_points > 2)
            {
             OM_BLOCK_MOVE (&tpl_data[i].poly->points[pnx * 3],
                            &loop_data->xyz[first_inx * 3], blk_size);
            }
           break;
          }
        }
      }
    }

   if (loop_data->b_bit[last_inx] == BOUNDARY_POINT)
    {
     for (i=0; i<num_tply; i++)
      {
       if ((tpl_data[i].poly->points) && (tpl_data[i].boundary_poly))
        {
         MAptpyproj (&msg, &loop_data->xyz[last_inx * 3],
                     tpl_data[i].poly, p_pt, &t, &seg);
         EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
         dist = BSdistptpt(&msg, &loop_data->xyz[last_inx *3], p_pt);
         if (dist <= 2 * (*cht_tol))
          {
           pnx = (t <= 0.5) ? seg - 1 : seg;
           if (tpl_data[i].poly->num_points > 2)
            {
             OM_BLOCK_MOVE (&tpl_data[i].poly->points[pnx * 3],
                            &loop_data->xyz[last_inx * 3], blk_size);
            }
           break;
          }
        }
      }
    }

   if (first_valid || last_valid)
    {
     if (first_valid)
      {
       OM_BLOCK_MOVE (&loop_data->xyz[first_inx*3],
                      &loop_points[(*num_loop_points) * 3], blk_size);
       (*num_loop_points)++;
      }
     else
      {
       for (j=0; j<(*num_loop_points); j++)
        {
         if (BSdistptpt(&msg, &loop_data->xyz[first_inx*3],
                        &loop_points[j*3]) <= *bastol)
         OM_BLOCK_MOVE (&tpl_data[match_inx].poly->points[pnt_inx0 * 3],
                        &loop_points[j*3], blk_size);
        }
      }

     if (EFadjust_index (&pnt_inx0, &pnt_inx1, t1_par, t2_par,
                         first_valid,last_valid, tpl_data[match_inx].poly,
                         bastol))
      {
       EMinsert_points (pnt_inx0, pnt_inx1, tpl_data[match_inx].poly,
                        num_loop_points, loop_points, *bastol);
      }

     if (last_valid)      
      {
       OM_BLOCK_MOVE (&loop_data->xyz[last_inx*3],
                      &loop_points[(*num_loop_points) * 3], blk_size);
       (*num_loop_points)++;
      }
     else
      {
       for (j=0; j<(*num_loop_points); j++)
        {
         if (BSdistptpt(&msg, &loop_data->xyz[last_inx*3],
                        &loop_points[j*3]) <= *bastol)
         OM_BLOCK_MOVE (&tpl_data[match_inx].poly->points[pnt_inx1 * 3],
                        &loop_points[j*3], blk_size);
        }
      }
    }
   else
    {
     EMinsert_points (pnt_inx0, pnt_inx1, tpl_data[match_inx].poly,
                      num_loop_points, loop_points, *bastol);
    }
  }

 wrapup:
 
 EMWRAPUP (*EMmsg, *EMmsg, "GRvg.EMinternal_loop_match");
 return(1);
}

IGRboolean EFadjust_index (pnx0, pnx1, t1_par, t2_par, first_valid,
                           last_valid, poly, bas_tol)
 IGRint     *pnx0, *pnx1;
 IGRdouble  t1_par, t2_par;
 IGRboolean first_valid, last_valid;
 struct IGRpolyline *poly;
 IGRdouble  bas_tol;
{

 IGRlong          msg;
 IGRdouble        dist;
 extern IGRdouble fabs();

 if ((! first_valid) && (! last_valid)) return (TRUE);

 dist = BSdistptpt(&msg, &poly->points[0],
                   &poly->points[3 * (poly->num_points - 1)]);

 if ((*pnx0 < *pnx1) && (dist <= bas_tol) && 
    ((*pnx1 - *pnx0) > (poly->num_points - *pnx1 + *pnx0)))
  {
   if ((*pnx0 == 0) && (t1_par <= 0.5))
    {if (first_valid) first_valid = FALSE;
     *pnx0 = poly->num_points - 1; t1_par = 1;}
   else
   if ((*pnx1 == poly->num_points - 1) && (t2_par > 0.5))
    {if (last_valid) last_valid = FALSE;
     *pnx1 = 0; t2_par = 0;}
   else
    {
     if (first_valid) (*pnx0)--;
     if (last_valid) (*pnx1)++;
     return (TRUE); 
    }
  }

 if ((*pnx1 < *pnx0) && (dist <= bas_tol) && 
    ((*pnx0 - *pnx1) > (poly->num_points - *pnx0 + *pnx1)))
  {
   if ((*pnx1 == 0) && (t2_par <= 0.5))
    {if (last_valid) last_valid = FALSE;
     *pnx1 = poly->num_points - 1; t2_par = 1;}
   else
   if ((*pnx0 == poly->num_points - 1) && (t1_par > 0.5))
    {if (first_valid) first_valid = FALSE;
     *pnx0 = 0; t1_par = 0;}
   else
    {
     if (first_valid) (*pnx0)++;
     if (last_valid) (*pnx1)--;
     return (TRUE); 
    }
  }

 if ((t1_par > 0.5) && (t2_par <= 0.5))
  {
   if (*pnx1 == *pnx0) return (TRUE);
   else
   if (*pnx1 > *pnx0)
    {
     return(TRUE);
    }
   else if (*pnx0 > *pnx1)
    {
       if (first_valid && last_valid)
        {
           if (*pnx0 - *pnx1 == 1) return (FALSE);
           else
            {
             (*pnx0)--;
             (*pnx1)++;
            }
        }
       else if (first_valid) (*pnx0)--;
       else if (last_valid) (*pnx1)++;
    }
  }
 else
 if ((t1_par > 0.5) && (t2_par > 0.5))
  {
   if (*pnx1 == *pnx0)
    {
     if (first_valid && last_valid) return (FALSE);
     else if ((first_valid) && (t2_par > t1_par)) return (TRUE);
     else if ((last_valid) && (t1_par > t2_par)) return (TRUE);
     else return (FALSE);
    }
   else
   if (*pnx1 > *pnx0)
    {
       if (first_valid && last_valid) (*pnx1)--;
       else if (first_valid) return (TRUE);
       else if (last_valid) (*pnx1)--;
    }
   else if (*pnx0 > *pnx1)
    {
       if (first_valid && last_valid) (*pnx0)--;
       else if (first_valid) (*pnx0)--;
       else if (last_valid) return (TRUE);
    }
  }
 else
 if ((t1_par <= 0.5) && (t2_par > 0.5))
  {
   if (*pnx1 == *pnx0) return (TRUE);
   else
   if (*pnx1 > *pnx0)
    {
       if (first_valid && last_valid)
        {
           if (*pnx1 - *pnx0 == 1) return (FALSE);
           else
            {
             (*pnx0)++;
             (*pnx1)--;
            }
        }
       else if (first_valid) (*pnx0)++;
       else if (last_valid) (*pnx1)--;
    }
   else if (*pnx0 > *pnx1)
    {
     return (TRUE);
    }
  }
 else
 if ((t1_par <= 0.5) && (t2_par <= 0.5))
  {
   if (*pnx1 == *pnx0)
    {
     if (first_valid && last_valid) return (FALSE);
     else if ((first_valid) && (t1_par > t2_par)) return (TRUE);
     else if ((last_valid) && (t2_par > t1_par)) return (TRUE);
     else if ((first_valid || last_valid) &&
              (fabs(t1_par-t2_par) <= bas_tol)) return (TRUE);
     else return (FALSE);
    }
   else
   if (*pnx1 > *pnx0)
    {
       if (first_valid && last_valid) (*pnx0)++;
       else if (first_valid) (*pnx0)++;
       else if (last_valid) return (TRUE);;
    }
   else if (*pnx0 > *pnx1)
    {
       if (first_valid && last_valid) (*pnx1)++;
       else if (first_valid) return (TRUE);
       else if (last_valid) (*pnx1)++;
    }
  }
 return (TRUE);
}

static void EFend_validity (num_tply, tpl_data, loop_data, first_index,
                       last_index, first_valid, last_valid, bastol)
IGRint                 num_tply;
struct EMtopology_info *tpl_data;
struct Facetloop       *loop_data;
IGRint                 first_index, last_index;
IGRboolean             *first_valid, *last_valid;
IGRdouble              bastol;

{
 IGRint j;
 extern IGRdouble fabs();

 *first_valid = FALSE;
 *last_valid = FALSE;

 for (j=0; j<num_tply; j++)
  {
   if (! tpl_data[j].boundary_poly)
    {
     if (tpl_data[j].u_dir)
      {
       if (fabs (loop_data->uv[first_index * 2] -
                 tpl_data[j].param) < bastol)
        {
         *first_valid = TRUE;
        }
       if (fabs (loop_data->uv[last_index * 2] -
                 tpl_data[j].param) < bastol)
        {
         *last_valid = TRUE;
        }
      }
     else
      {
       if (fabs (loop_data->uv[first_index * 2 + 1] -
                 tpl_data[j].param) < bastol)
        {
         *first_valid = TRUE;
        }
       if (fabs (loop_data->uv[last_index * 2 + 1] -
                 tpl_data[j].param) < bastol)
        {
         *last_valid = TRUE;
        }
      }
    }
  }
}

end implementation GRvg;
