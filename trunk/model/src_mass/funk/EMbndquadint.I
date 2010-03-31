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
#include "maptpypro.h"
#include "bsptnorpch.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bsavgpts.h"

#define OUT_TRIANGLE 0

%safe
static IGRlong    EMinternal_quad_match();
%endsafe

EMboundary_quadint (EMmsg, patch_inx, quad_points, fct_data, patch_data, num_tply,
                    tpl_data, toln, option, surface, loop_int)

IGRlong                *EMmsg;
IGRint                 *patch_inx;
IGRdouble              *quad_points;
struct EMfacet_data    *fct_data;
struct BNpatch         *patch_data;
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

  IGRlong            stat_OM, msg;
  IGRlong            blk_size, seg_inx0, seg_inx1;
  IGRint             i, j, k, num_in_copy;
  IGRint             num_pts_saved;
  IGRint             wt_cnt, pnt_inx0, pnt_inx1;
  IGRint             num_found, num_loop_points;
  IGRint             first_index, last_index;
  IGRint             inx_a, inx_b;
  IGRint             alloc_num, tpl_inx, ptr_inx, incr_num;
  IGRint             num_entries, index, num_ary[4];
  IGRint             sac_index[4];
  IGRboolean         sacked[4];
  IGRboolean         corner_index[5], status;
  IGRboolean         first_valid, last_valid;
  IGRboolean         match_found, py_sacked[4];
  IGRboolean         nat_bdry[4];
  IGRboolean         prev_sacked, next_sacked;
  extern IGRdouble   sqrt(), fabs();
  IGRdouble          tria_pnts[12];
  IGRdouble          dot_tol, cht_tol, bas_tol;
  IGRdouble          t1_par, t2_par;
  IGRdouble	         pnt[3], cross[3], u_vector[3], value, h_func,
                     V12[3], V13[3], V23[3],
                     ref_vec[3], dir_vec[3], dotpr,
                     quad_int[NUMB_PROPS], loc_loop_int[NUMB_PROPS],
                     cross_norm, delta_area;
  IGRdouble          avg_uv[2], u_par, v_par, dist, dist1, dist2;
  IGRdouble          *loop_points, *loop_copy;
  IGRdouble          proj_pt0[3], proj_pt1[3];
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

/*------------------------------------------------------------------*/

  stat_OM = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  BSEXTRACTPAR(&msg, BSTOLCHRDHT, cht_tol); 
  BSEXTRACTPAR(&msg, BSTOLCOLLINVEC, dot_tol);
  BSEXTRACTPAR(&msg, BSTOLLENVEC, bas_tol);

  for(i=0; i<NUMB_PROPS; i++) loc_loop_int[i] = 0.0;

  for (i=0; i<5; i++) corner_index[i] = FALSE;

  for (i=0; i<4; i++)
   {
    py_sacked[i] = sacked[i] = nat_bdry[i] = FALSE;
    num_ary[i] = 0;
   }

  first_valid = last_valid = FALSE;
  inx_a = 0; inx_b = 1;
  loop_points = NULL;
  loop_copy = NULL;
  num_entries = 0;
  alloc_num = 0;
  index = 0;
  
  for (i=0; i<num_tply; i++)
   {
    if (tpl_data[i].poly->num_points > alloc_num)
        alloc_num = tpl_data[i].poly->num_points;
   }

  if (alloc_num <= 10) alloc_num = 20; /* if all are 2 nd order */

  loop_points = (IGRdouble *) om$malloc (size = 3 * 5 * alloc_num *
                                                sizeof (IGRdouble));
 
  blk_size = 3 * fct_data->num_in_points * sizeof (IGRdouble);
  num_loop_points = fct_data->num_in_points;
  if (num_loop_points)
   {
    OM_BLOCK_MOVE (&quad_points[3 * fct_data->points_inx],
                   &loop_points[0], blk_size);
    inx_a = fct_data->points_inx + num_loop_points - 1;
    if (inx_a == 4) inx_a = 0; 
    inx_b = inx_a + 1;
   }

  blk_size = 3 * sizeof (IGRdouble);

  for (i=0; i<(2 * fct_data->num_int_bdry); i++)
   {
    for (j=0; j<(2 * fct_data->num_bdrys); j++)
     {
      if ((fct_data->bdry_inx[j] == fct_data->int_bdry_inx[i]) ||
         (fct_data->bdry_inx[j] == 0 && fct_data->int_bdry_inx[i] == 4) ||
         (fct_data->bdry_inx[j] == 4 && fct_data->int_bdry_inx[i] == 0))
          corner_index[fct_data->bdry_inx[j]] = TRUE;
     }
   }

  if (corner_index[0]) corner_index[4] = TRUE;
  else
  if (corner_index[4]) corner_index[0] = TRUE;

  index = 4;

  while (index)
   {
    for (i=0; i<fct_data->num_int_bdry; i++)
     {
      if ((fct_data->int_bdry_inx[i*2] == inx_a) &&
          (fct_data->int_bdry_inx[i*2 + 1] == inx_b))
       {
        first_valid = (corner_index[fct_data->int_bdry_inx[i*2]]) ?
                                                            TRUE : FALSE;
        last_valid = (corner_index[fct_data->int_bdry_inx[i*2 + 1]]) ?
                                                           TRUE : FALSE;
        num_pts_saved = num_loop_points;

         {

          EMinternal_quad_match (&msg, num_tply, tpl_data, quad_points,
                               fct_data->u_dir[i], 
                               fct_data->param[i],
                               fct_data->int_bdry_inx[i*2],
                               fct_data->int_bdry_inx[i*2 + 1],
                               first_valid, last_valid, toln,
                               &num_loop_points, loop_points,
                               &py_sacked[num_entries],
                               bas_tol);
          if (! (1 & msg)) goto wrapup;
         }
        sac_index[num_entries] = inx_a;
        sacked[inx_a] = py_sacked[num_entries];
        num_ary[num_entries++] = num_loop_points - num_pts_saved; 
        break;
       }
     }

    for (i=0; i<fct_data->num_bdrys; i++)
     {
      if ((fct_data->bdry_inx[i*2] == inx_a) &&
          (fct_data->bdry_inx[i*2 + 1] == inx_b))
       {
        first_index = fct_data->bdry_inx[i*2];
        last_index = fct_data->bdry_inx[i*2 + 1];

        match_found = FALSE;
        num_pts_saved = num_loop_points;
        py_sacked[num_entries] = FALSE;
        nat_bdry[num_entries] = TRUE;
        sac_index[num_entries] = inx_a;
    
        first_valid = (corner_index[first_index]) ? TRUE : FALSE;
        last_valid =  (corner_index[last_index])  ? TRUE : FALSE;

        for (j=0; j<num_tply; j++)
         {
          if ((tpl_data[j].poly->points) && (tpl_data[j].boundary_poly))
           {
            MAptpyproj (&msg, &quad_points[first_index*3],
                        tpl_data[j].poly, proj_pt0, &t1_par, &seg_inx0);
            EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

            dist1 = BSdistptpt(&msg,&quad_points[first_index*3],proj_pt0);
            if (dist1 <= 2*cht_tol)
             {
              MAptpyproj(&msg, &quad_points[last_index*3],
                         tpl_data[j].poly, proj_pt1, &t2_par, &seg_inx1);
              EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

              dist2 =BSdistptpt(&msg,&quad_points[last_index*3],proj_pt1);
              if (dist2 <= 2*cht_tol)
               {
                tpl_inx = j;
                match_found = TRUE;
                break;
               }
             }
           }
         }

        if ((! match_found) || (tpl_data[tpl_inx].poly->num_points == 2))
         {
          for (j=first_index; j<=last_index; j++)
           {
            OM_BLOCK_MOVE (&quad_points[j*3],
                           &loop_points[num_loop_points * 3], blk_size);
            num_loop_points++;
           }
         }
        else
         {
          pnt_inx0 = (t1_par <= 0.5) ? seg_inx0-1 : seg_inx0;
          pnt_inx1 = (t2_par <= 0.5) ? seg_inx1-1 : seg_inx1;

          if (first_valid)
           {
            OM_BLOCK_MOVE (&quad_points[first_index*3],
                           &loop_points[num_loop_points * 3], blk_size);
            num_loop_points++;
           }

          if (EFadjust_index (&pnt_inx0, &pnt_inx1, t1_par, t2_par,
                            first_valid,last_valid,tpl_data[tpl_inx].poly,
                              bas_tol))
           {
            EMinsert_points (pnt_inx0, pnt_inx1, tpl_data[tpl_inx].poly,
                             &num_loop_points, loop_points, bas_tol);
           }

          if (last_valid)
           {
            OM_BLOCK_MOVE (&quad_points[last_index*3],
                           &loop_points[num_loop_points * 3], blk_size);
            num_loop_points++;
           }
         }
 
        num_ary[num_entries++] = num_loop_points - num_pts_saved; 
        break;
       }
     }
    inx_a++;
    if (inx_a == 4) inx_a = 0;
    inx_b = inx_a + 1;
    index--;
   }

  for (i=0; i<num_entries; i++)
   {
    if (py_sacked[i])
     {
      ptr_inx = 0;
      num_in_copy = 0;
      loop_copy = (IGRdouble *) om$malloc(size = 3*(num_loop_points + 1) *
                                                   sizeof (IGRdouble));

      if (fct_data->num_in_points)
       {
        blk_size = 3 * fct_data->num_in_points * sizeof (IGRdouble);
        OM_BLOCK_MOVE (&quad_points[3 * fct_data->points_inx],
                       &loop_copy[0], blk_size);
        ptr_inx = 3 * fct_data->num_in_points;
        num_in_copy = fct_data->num_in_points;
       }

      for (j=0; j<num_entries; j++)
       {
        if (j) ptr_inx += 3 * num_ary[j-1];

        if (((py_sacked[j]) || (nat_bdry[j])) && (num_ary[j]))
         {
          blk_size = num_ary[j] * 3 * sizeof (IGRdouble);
          OM_BLOCK_MOVE (&loop_points[ptr_inx],
                         &loop_copy[num_in_copy * 3], blk_size);
          num_in_copy += num_ary[j];
         }
        else if (num_ary[j] >= 2)
         {
          switch (sac_index[j])
           {
            case 0:
                   prev_sacked = sacked[3];
                   next_sacked = sacked[1];
                   break;
            case 1:
                   prev_sacked = sacked[0];
                   next_sacked = sacked[2];
                   break;
            case 2:
                   prev_sacked = sacked[1];
                   next_sacked = sacked[3];
                   break;
            case 3:
                   prev_sacked = sacked[2];
                   next_sacked = sacked[0];
                   break;
            default:
                   prev_sacked = FALSE;
                   next_sacked = FALSE;
                   break;
           }

          if ((prev_sacked) && (next_sacked))
           {
            ptr_inx += 3;
            incr_num = num_ary[j]-2;
           }
          else if (prev_sacked)
           {
            ptr_inx += 3;
            incr_num = num_ary[j]-1;
           }
          else if (next_sacked)
           {
            incr_num = num_ary[j]-1;
           }
          else
           {
            incr_num = num_ary[j];
           }
          blk_size = incr_num * 3 * sizeof (IGRdouble);

          if (incr_num)
              OM_BLOCK_MOVE (&loop_points[ptr_inx],
                             &loop_copy[num_in_copy * 3], blk_size);
          num_in_copy += incr_num;

          if (prev_sacked) ptr_inx -= 3;

         }
       }

      if (loop_points) om$dealloc (ptr = loop_points);

      loop_points = loop_copy;
      num_loop_points = num_in_copy;

      break;
     }
   }
 
  /* Add the very first point to close off the loop */

  blk_size = 3 * sizeof (IGRdouble);

  OM_BLOCK_MOVE (&loop_points[0], &loop_points[num_loop_points * 3],
                 blk_size);
  num_loop_points++;

  status = BSavgpts(&msg, num_loop_points, loop_points,NULL, avg_point);
  EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  avg_uv[0] = (patch_data->us + patch_data->ud) / 2;
  avg_uv[1] = (patch_data->vs + patch_data->vd) / 2;

  if (! patch_data->plannar)
   {
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

/*******************************
 rem_this[0] = 1622.85470129;
 rem_this[1] = 29.92410819;
 rem_this[2] = -112.49523255;

 if (BSdistptpt(&msg, rem_this, start_point) <= cht_tol)
     printf("0 - bad points ---- patch_inx , %d\n",
             *patch_inx);

********************************/

  /* compute the best reference vector */

  for (i=0; i<(num_loop_points-1); i++)
   {
    for (j=0; j<3; j++)
     {
      temp_V12[j] = loop_points[(3 * i) + j] - start_point[j];
      temp_V13[j] = loop_points[(i+1) * 3 + j] - start_point[j];
     }
    if (BSdistptpt(&msg, &loop_points[3*i], &loop_points[3*(i+1)]) >
        dot_tol) break;
   }

  CROSS_PR(temp_V12, temp_V13, ref_vec);    

  BSnorvec(&msg, ref_vec);

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
 
    return(stat_OM);
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

wrapup:

 EMWRAPUP (*EMmsg, stat_OM, "GRvg.EMboundary_quadint");

 if (loop_points) om$dealloc (ptr = loop_points);
 return (stat_OM);
}

static IGRlong EMinternal_quad_match(EMmsg, num_tply, tpl_data, quad_pnts,
                                     in_u_dir, param, first_inx, last_inx,
                                     first_valid, last_valid, toln,
                                     num_loop_points, loop_points,
                                     py_sacked, bas_tol)

IGRlong                *EMmsg;
IGRint                 num_tply;
struct EMtopology_info *tpl_data;
IGRdouble              *quad_pnts;
IGRboolean             in_u_dir;
IGRdouble              param;
IGRint                 first_inx, last_inx;
IGRboolean             first_valid, last_valid;
IGRdouble              *toln;
IGRint                 *num_loop_points;
IGRdouble              *loop_points;
IGRboolean             *py_sacked;
IGRdouble              bas_tol;

{
 IGRlong               seg_inx0, seg_inx1,
                       msg;
 IGRlong               blk_size;
 IGRboolean            match_found;
 IGRint                j, match_inx;
 IGRint                pnt_inx0, pnt_inx1;
 IGRdouble             t1_par, t2_par;
 IGRdouble             proj_pt0[3], proj_pt1[3];
 extern IGRdouble      fabs();

/*----------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 match_found = FALSE;
 *py_sacked = FALSE;
 blk_size = 3 * sizeof (IGRdouble);

 for (j=0; j<num_tply; j++)
  {
   if (! tpl_data[j].boundary_poly)
    {
     if (((tpl_data[j].u_dir) && (in_u_dir)) &&
          (fabs(tpl_data[j].param - param) <= *toln))
      {
       match_found = TRUE; match_inx = j; break;
      }      
     else
     if (((! tpl_data[j].u_dir) && (! in_u_dir)) &&
         (fabs(tpl_data[j].param - param) <= *toln))
      {
       match_found = TRUE; match_inx = j; break;
      }      
    }
  }

 if (match_found) *py_sacked = tpl_data[match_inx].pygeom_sacked;

 if (((match_found) && (tpl_data[match_inx].poly->num_points == 2)) ||
     (! match_found))
  {
   OM_BLOCK_MOVE (&quad_pnts[first_inx * 3],
                  &loop_points[(*num_loop_points) * 3], blk_size);
   (*num_loop_points)++;
   OM_BLOCK_MOVE (&quad_pnts[last_inx * 3],
                  &loop_points[(*num_loop_points) * 3], blk_size);
   (*num_loop_points)++;
  }  
 else
  {
   MAptpyproj (&msg, &quad_pnts[first_inx * 3],
               tpl_data[match_inx].poly, proj_pt0, &t1_par, &seg_inx0);
   EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);
   MAptpyproj (&msg, &quad_pnts[last_inx * 3],
               tpl_data[match_inx].poly, proj_pt1, &t2_par, &seg_inx1);
   EMerr_hndlr(! (1 & msg), *EMmsg, EMS_E_MAerror, wrapup);

   pnt_inx0 = (t1_par <= 0.5) ? seg_inx0-1 : seg_inx0;
   pnt_inx1 = (t2_par <= 0.5) ? seg_inx1-1 : seg_inx1;

   if (first_valid)
    {
     OM_BLOCK_MOVE (&quad_pnts[first_inx*3],
                    &loop_points[(*num_loop_points) * 3], blk_size);
     (*num_loop_points)++;
    }

   if (EFadjust_index (&pnt_inx0, &pnt_inx1, t1_par, t2_par,
                       first_valid, last_valid, tpl_data[match_inx].poly,
                       bas_tol))
    {
     EMinsert_points (pnt_inx0, pnt_inx1, tpl_data[match_inx].poly,
                      num_loop_points, loop_points, bas_tol);
    }

   if (last_valid)
    {
     OM_BLOCK_MOVE (&quad_pnts[last_inx*3],
                    &loop_points[(*num_loop_points) * 3], blk_size);
     (*num_loop_points)++;
    }
  }

 wrapup:
 EMWRAPUP (*EMmsg, *EMmsg, "GRvg.EMinternal_quad_match");
 return(OM_S_SUCCESS);
}

end implementation GRvg;
