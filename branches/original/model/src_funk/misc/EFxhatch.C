/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include <stdio.h>

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

# include "emserr.h"
# include "gocmacros.h"     /* EMSalign_bdry        */
# include "OMmacros.h"
# include "EMSlogic.h"      /* EMSmsgReport         */
# include "EMStypedef.h"    /* EMSmsgReport         */
# include "EMSommacros.h"   /* ems$get_memory       */
# include "bserr.h"
# include "igrdef.h"        /* IGRQS		    */
# include "emsdef.h"
# include "msdef.h"
# include "madef.h"
# include "maerr.h"                      /* MA error return codes */
# include "bserr.h"
# include "exdef.h"
# include "exmacros.h"
# include "EMSchatch.h"
# include "EMSmsgdef.h"
 
#include "matypemx.h"
#include "matrnmx.h"
#include "maoptsxfo.h"
#include "mamulmx.h"
#include "maidmx.h"
#include "magrotmx.h"
#include "bssfarrevn.h"
#include "bssf_copy.h"
#include "bsnorvec.h"
#include "bsfreesf.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "bsallocsf.h"

static void EFid_matrix();

# define PADDING 20
# define U_RULES 0
# define V_RULES 1

/*
 History	RC    08/27/87   Creation date
                rlw   03/17/89   Modified get definition routine to
                                 find the config directory in a different
                                 manner.
	        Sudha 07/08/93   Modified for BSprototypes ansification

 DESCRIPTION
     This routine will transform a set of (uv) pts with a matrix
     and put the transformed pts back in the same incoming array(pts)

*/


IGRboolean EFgetxh_tr_pts (
	EFmsg,
	num_pts,
	pts,
	matrix)

  IGRlong	*EFmsg;
  IGRlong	num_pts;
  IGRdouble	*pts;
  IGRdouble     matrix[16];

{
   IGRdouble	u, v;
   IGRlong	i;

   *EFmsg = EMS_S_Success;

   for (i = 0; i < num_pts; i++)
   {
	u = matrix[0] * pts[i*2] + matrix[1] * pts[i*2+1] + matrix[3];
	v = matrix[4] * pts[i*2] + matrix[5] * pts[i*2+1] + matrix[7];
	pts[2*i] = u;
        pts[2*i+1] = v;
   }

   return (TRUE);
}

/*
DESCRIPTION
   
   Given the surface geometry, cross-hatch origin(xyz), cross-hatch
   spacing, this routine calculates the rule lines to be used
   for cross hatching.

RETURN VALUES
   
   EFmsg	EMS_S_Success if successful,
		EMS_E_BSerror if error in BS function call.
		EMS_E_Fail    if error other than a BS call.

HISTORY
    RC      09/03/87        Creation Date
    RC      12/04/87        Modified the arguments and code to
                            cross hatching in both directions.
*/

IGRboolean EFget_xh_rulelines ( EFmsg, sf_geom, xh_info, sf_esbs,
           buffer, buffer_size)

IGRlong                 *EFmsg;
struct IGRbsp_surface   *sf_geom;
struct EMSxh_info       *xh_info;
struct IGResqbs         **sf_esbs;
IGRchar                 *buffer;
IGRint                  buffer_size;

{
  IGRdouble           wl_mat[4][4], org[2], sf_len,first_rl[2],last_rl[2],
                      rl_value, ptrn_width[2], elem_spacing,
                      xyz_uv_factor[2], sgrp_gap;
extern IGRdouble fabs() ;
  IGRlong             rc, up_left, low_right;
  IGRint              rl_typ, *num_rls, num_sgrps, num_rls_p_ptrn, i,
                      sgrp_inx, elem_inx, j;

  struct IGResqbs     *rlt;
  struct EMSxh_sgrp_info   *sgrp_info;

  IGRboolean          status;
  IGRboolean          EFlwl_mat_for_planes();

   /* ************************************************************ */

   *EFmsg = EMS_S_Success;

   /*
    * Transform the cross-hatch origin to the surface's 
    * parametric space.
    */

   status = EFlwl_mat_for_planes (&rc, sf_geom, FALSE, wl_mat);
   EMerr_hndlr (!status || !(1&rc),*EFmsg, EMS_E_Fail,wrapup);


   for (rl_typ = 0; rl_typ < 2; rl_typ++)
   {
     
     if (rl_typ == U_RULES)
     {
       num_sgrps = xh_info->num_u_sgrps;
       num_rls = &xh_info->num_u_rls;

       if (num_sgrps)
       {
        sgrp_info = xh_info->u_sgrp_info;
        low_right = (sf_geom->u_num_poles - 1) * 3;

        sf_len = BSdistptpt (&rc, sf_geom->poles, 
                             &sf_geom->poles[low_right]);
        EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
        xyz_uv_factor[rl_typ] = 1.0/sf_len;

       }
    
     } /* if (rl_typ == U_RULES) */
     else
     {
       num_sgrps = xh_info->num_v_sgrps;
       num_rls = &xh_info->num_v_rls;
    
       if (num_sgrps)
       {
        sgrp_info = xh_info->v_sgrp_info;
        up_left = sf_geom->u_num_poles  * (sf_geom->v_num_poles - 1) * 3;

        sf_len = BSdistptpt (&rc, sf_geom->poles, 
                             &sf_geom->poles[up_left]);
        EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);
        xyz_uv_factor[rl_typ] = 1.0/sf_len;
       }
       
     } /* else for if (rl_typ == U_RULES) */

     *num_rls = 0;

     if (num_sgrps)
     {
       org[rl_typ] = wl_mat[rl_typ][0] * xh_info->origin[0] + 
                     wl_mat[rl_typ][1] * xh_info->origin[1] +
                     wl_mat[rl_typ][2] * xh_info->origin[2] + 
                     wl_mat[rl_typ][3];

       ptrn_width[rl_typ] = 0;
       num_rls_p_ptrn = 0;

       for (i = 0; i < num_sgrps; i++)
       {
          ptrn_width[rl_typ] += ( ( sgrp_info[i].num_rls_p_sgrp - 1 ) *
                                     sgrp_info[i].sgrp_rls_spacing  +
                                     sgrp_info[i].ptrn_sgrp_spacing ); 
          num_rls_p_ptrn += sgrp_info[i].num_rls_p_sgrp;

       } /* for (i = 0; i < num_sgrps; i++) */

       ptrn_width[rl_typ] *= xyz_uv_factor[rl_typ];

       first_rl[rl_typ] = fabs(org[rl_typ]) / ptrn_width[rl_typ];
       first_rl[rl_typ] = (first_rl[rl_typ] - (int) first_rl[rl_typ]) *
                          ptrn_width[rl_typ];

       first_rl[rl_typ] = (org[rl_typ] < 0.) ? 
                          (ptrn_width[rl_typ] - first_rl[rl_typ]) : 
                          first_rl[rl_typ];

       last_rl[rl_typ] = 1.0;
       rl_value = first_rl[rl_typ];

       while (rl_value < 1.0)
       {
          rl_value += ptrn_width[rl_typ];
          if ( rl_value < 1.0)  (*num_rls)++;
          else  last_rl[rl_typ] = rl_value - ptrn_width[rl_typ];
       } 

        (*num_rls) *= num_rls_p_ptrn;
 
        /*
         * Calculate the number of rule lines in partial patterns
         * one at beginning and the other at the end.
         */

        if (first_rl[rl_typ] > 0.) 
        {
          rl_value = first_rl[rl_typ];
          sgrp_inx = num_sgrps - 1;
          while (rl_value > 0. && sgrp_inx >= 0)
          {
           rl_value -= (sgrp_info[sgrp_inx].ptrn_sgrp_spacing *
                        xyz_uv_factor[rl_typ]);
           if (rl_value > 0.)
           {
            if (rl_value < 1.0) (*num_rls)++;
            elem_inx = 0;
	        while (rl_value > 0. && 
                   elem_inx < (sgrp_info[sgrp_inx].num_rls_p_sgrp - 1) )
            {
              rl_value -= (sgrp_info[sgrp_inx].sgrp_rls_spacing *
                           xyz_uv_factor[rl_typ]);
              if (rl_value > 0.)
              { 
               elem_inx++;
               if (rl_value < 1.0) (*num_rls)++;
              }
             }
	
             sgrp_inx--;
	
           } /* if (rl_value > 0.) */

          } /* while (rl_value > 0. && sgrp_inx >= 0) */
         
        } /* if (first_rl[rl_typ] > 0.)  */

        if (last_rl[rl_typ] < 1.) 
        {
         rl_value = last_rl[rl_typ];
         sgrp_inx = 0;
         while (rl_value < 1. && sgrp_inx < num_sgrps)
         {
          (*num_rls)++;
          elem_inx = 0;
  	      while (rl_value < 1. && 
                 elem_inx < (sgrp_info[sgrp_inx].num_rls_p_sgrp - 1) )
          {
             rl_value += (sgrp_info[sgrp_inx].sgrp_rls_spacing *
                          xyz_uv_factor[rl_typ]);
             if (rl_value < 1.)
             { 
               elem_inx++;
               (*num_rls)++;
             }
           }
           rl_value += (sgrp_info[sgrp_inx].ptrn_sgrp_spacing *
                        xyz_uv_factor[rl_typ]);
	       sgrp_inx++;
	
         } /* while (rl_value < 1. && sgrp_inx < num_sgrps) */
         
        } /* if (last_rl[rl_typ] < 1.)  */

     } /* if (num_sgrps) */

   } /* for (rl_typ = 0; rl_typ < 2; rl_typ++) */

   /*
    * Fill the rule lines information.
    */

   if (sf_esbs)
   {
       IGRint	  num_bytes;
       IGRdouble  *rls_ptr;
 
       num_bytes = sizeof(struct IGResqbs);
       num_bytes += (xh_info->num_u_rls + xh_info->num_v_rls) * 
                    sizeof(IGRdouble);
       num_bytes += PADDING;

       ems$get_memory(rc = &rc, num_elements = num_bytes,
		    buffer = buffer, buffer_size = buffer_size,
		    clear = TRUE, ptr = (IGRchar **) sf_esbs);
       EMerr_hndlr(!(1&rc), *EFmsg, EMS_E_Fail, wrapup);

       rlt = *sf_esbs;
       rls_ptr = (IGRdouble *)EMSalign_bdry(sizeof(IGRdouble), rlt + 1);

       for (rl_typ = 0; rl_typ < 2; rl_typ++)
       {
        if (rl_typ == U_RULES)
        {
          rlt->u_rules = 0;
          rlt->u_rule_values = rls_ptr;
          if (!xh_info->num_u_rls) continue;
          num_rls = (IGRint *)&rlt->u_rules;
          num_sgrps = xh_info->num_u_sgrps;
          sgrp_info = xh_info->u_sgrp_info;
           
        } /* if (rl_typ == U_RULES) */
        else
        {
         rlt->v_rules = 0;
         rlt->v_rule_values = rls_ptr;
         if (!xh_info->num_v_rls) continue;
         num_rls = (IGRint *)&rlt->v_rules;
         num_sgrps = xh_info->num_v_sgrps;
         sgrp_info = xh_info->v_sgrp_info;
        }

        for (sgrp_inx = 0; sgrp_inx < num_sgrps; sgrp_inx++)
        {

         sgrp_info[sgrp_inx].num_rls_this_style = 0;
         sgrp_gap = ptrn_width[rl_typ] - 
                    ( (sgrp_info[sgrp_inx].num_rls_p_sgrp - 1) *
                      sgrp_info[sgrp_inx].sgrp_rls_spacing *
                      xyz_uv_factor[rl_typ] );
         /*
          * Check if there will be any rule lines in the patch
          * in between start point and the first rule line pt.
          */

         rl_value = first_rl[rl_typ] - ptrn_width[rl_typ];
         elem_spacing = sgrp_info[sgrp_inx].sgrp_rls_spacing *
                         xyz_uv_factor[rl_typ];

         for (j = 0; j < sgrp_info[sgrp_inx].num_rls_p_sgrp; j++)
         {
           if (rl_value > 0.)
           {
            rls_ptr[(*num_rls)++] = rl_value;           
            sgrp_info[sgrp_inx].num_rls_this_style++;
           } /* if (rl_value > 0.) */

           rl_value += elem_spacing;
 
         } /* for (j = 0; j < sgrp_info[sgrp_inx].num_rls_p_sgrp; j++) */

         rl_value = first_rl[rl_typ];

         while (rl_value < 1.0)
         {
           rls_ptr[(*num_rls)++] = rl_value;
           sgrp_info[sgrp_inx].num_rls_this_style++;
 
           for (i = 0; i < sgrp_info[sgrp_inx].num_rls_p_sgrp-1; i++)
           {
            rl_value += elem_spacing;
            if (rl_value > 1.0) break;
            rls_ptr[(*num_rls)++] = rl_value;
            sgrp_info[sgrp_inx].num_rls_this_style++;

           } /* for (i = 0;i<sgrp_info[sgrp_inx].num_rls_p_sgrp;i++) */

           if (rl_value < 1.0) rl_value += sgrp_gap;

         } /* while (rl_value < 1.0) */

         first_rl[rl_typ] += ((sgrp_info[sgrp_inx].num_rls_p_sgrp - 1) *
                              sgrp_info[sgrp_inx].sgrp_rls_spacing +
                             sgrp_info[sgrp_inx].ptrn_sgrp_spacing) *
                             xyz_uv_factor[rl_typ];

        } /* for (sgrp_inx = 0; sgrp_inx < num_sgrps; sgrp_inx++) */

        rls_ptr += *num_rls;

       } /* for (rl_typ  = 0; rl_typ < 2; rl_typ++) */

       rlt->is_polydis = FALSE;
       rlt->is_surfdis = TRUE;
       rlt->is_slowdis = FALSE;
       rlt->type = IGRQS;
       rlt->rules_specified = TRUE;
       rlt->u_num_bound = NULL;
       rlt->v_num_bound = NULL;
       rlt->u_bdrys = NULL;
       rlt->v_bdrys = NULL;

   } /* if (sf_esbs) */

wrapup:
   return (TRUE);

}

/*
History  RC  09/11/87  Creation Date
*/

IGRboolean EFget_xh_sf_geom (
			EFmsg,
			rot_angle,
			u_scale,
			v_scale,
			sf_geom,
			tr_sf_geom)

IGRlong			*EFmsg;
IGRdouble		rot_angle, *u_scale, *v_scale;
struct IGRbsp_surface   *sf_geom, *tr_sf_geom;
{
  IGRlong	mthd_stat;
  IGRlong      rc, num_poles;
  IGRshort	l , m, n, mat_type;
  IGRboolean	status;

  IGRdouble 	lw_mat[4][4], sc_mat[4][4], rot_mat[4][4],
		trans_mat[4][4], temp_mat1[4][4], temp_mat2[4][4];
  IGRdouble	rot_org[3], rot_axis[3], u, v, scale_u, scale_v;

  extern  IGRboolean	EFlwl_mat_for_planes (), EFgetxh_uv_scale ();

  extern  IGRdouble  cos();
  extern  IGRdouble  sin();

  *EFmsg = EMS_S_Success;
  l = m = n = 4;

  /*
   * get the scaling factors if not sent in.
   */

  if (!u_scale || !v_scale)
  {

    status = EFgetxh_uv_scale (&mthd_stat, rot_angle, sf_geom, &scale_u,
                               &scale_v);
    EMerr_hndlr (!status || (!1&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);
  }
  else
  {
    scale_u = *u_scale;
    scale_v = *v_scale;
  }

  u = v = 0.5;
  BSsfarrevn (&rc, sf_geom, 1, &u, 1, &v, rot_org, rot_axis);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  status = MAgrotmx (&mthd_stat, rot_axis, rot_org, &rot_angle, (IGRdouble *)rot_mat);
  EMerr_hndlr (!status || !(1&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  status = EFlwl_mat_for_planes (&rc, sf_geom, TRUE, lw_mat);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

  status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)rot_mat, (IGRdouble *)lw_mat, (IGRdouble *)temp_mat1);

  status = MAidmx (&rc, (IGRdouble *)trans_mat);
  trans_mat[0][3] = trans_mat[1][3] = 0.5;
  status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)temp_mat1, (IGRdouble *)trans_mat, (IGRdouble *)temp_mat2);

  status = MAidmx (&rc, (IGRdouble *)sc_mat);
  sc_mat[0][0] = scale_u;
  sc_mat[1][1] = scale_v;
  status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)temp_mat2, (IGRdouble *)sc_mat, (IGRdouble *)temp_mat1);
    
  trans_mat[0][3] = trans_mat[1][3] = -0.5;
  status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)temp_mat1, (IGRdouble *)trans_mat, (IGRdouble *)temp_mat2);
    
  status = EFlwl_mat_for_planes (&rc, sf_geom, FALSE, lw_mat);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
  status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)temp_mat2, (IGRdouble *)lw_mat, (IGRdouble *)temp_mat1);
  
  status = BSsf_copy (&rc, sf_geom, tr_sf_geom);
  EMerr_hndlr (!status || rc != BSSUCC,*EFmsg,EMS_E_BSerror,wrapup);

  num_poles = sf_geom->u_num_poles * sf_geom->v_num_poles;

  status = MAtypemx(&rc, (IGRdouble *)temp_mat1, &mat_type);
  EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

  status = MAoptsxform (&mthd_stat, &num_poles, 
	   &mat_type, (IGRdouble *)temp_mat1, sf_geom->poles, tr_sf_geom->poles);
  EMerr_hndlr (!status || !(1&mthd_stat),*EFmsg,EMS_E_Fail,wrapup);

  wrapup:
     return (TRUE);

} 

/*
 History    RC   08/26/87  Creation date
*/

IGRboolean	EFsrf1uv_to_srf2uv ( srf1,
				     srf2,
				     matrix,
				     EFmsg)

struct IGRbsp_surface	*srf1;
struct IGRbsp_surface	*srf2;
IGRdouble		matrix[4][4];
IGRlong			*EFmsg;

{
   IGRshort	l, m, n;
   IGRlong	rc;
   IGRdouble	lw_mat[4][4], wl_mat[4][4];
   IGRboolean	status;
IGRboolean   EFlwl_mat_for_planes();

   *EFmsg = EMS_S_Success;

   l = m = n = 4;
   
   status = EFlwl_mat_for_planes (&rc, srf2, FALSE, wl_mat);
   EMerr_hndlr(!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

   status = EFlwl_mat_for_planes (&rc, srf1, TRUE, lw_mat);
   EMerr_hndlr(!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
      
   status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)wl_mat, (IGRdouble *)lw_mat, (IGRdouble *)matrix);
   EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

wrapup:
	return(1);

} /* end of EFsrf1uv_to_srf2uv */

/*
History   RC  08/25/87   Creation date
*/

IGRboolean EFlwl_mat_for_planes (EFmsg,
		       		  srf,
				  local_to_world,
		       		  matrix)

IGRlong			*EFmsg;
struct	IGRbsp_surface	*srf;
IGRboolean		local_to_world;
IGRdouble		matrix[4][4];
{

   IGRdouble	tol, vec1_len, vec2_len;
   IGRdouble	u_scale, v_scale, x_shear;
   IGRdouble	xyz[4][3], uv[4][3], xyz_org[3];
   IGRdouble	trans_mat[4][4], lw_mat[4][4], sc_mat[4][4],
		sh_mat[4][4], temp_mat1[4][4],
		temp_mat2[4][4];

   IGRint	low_left, low_right, up_left, up_right;
   IGRint	i, j , k;

   IGRlong	rc;
   IGRshort	dimension = 4, l = 4, m = 4, n = 4;

   IGRboolean	status;
  extern    IGRdouble	fabs();


   *EFmsg = EMS_S_Success;
			
   tol = 1e-8;

   low_left = 0;
   low_right = (srf->u_num_poles - 1) * 3;
   up_left = (srf->u_num_poles * ( srf->v_num_poles - 1)) * 3;
   up_right = up_left + low_right;

   for (i = 0; i < 3; i++)
   {
      xyz[0][i] = xyz_org[i] = srf->poles[low_left + i];
      xyz[1][i] = srf->poles[low_right + i];
      xyz[2][i] = srf->poles[up_left + i];
      xyz[3][i] = srf->poles[up_right + i];
   }

   vec1_len = vec2_len = 0;

   EFid_matrix (lw_mat);

   for (i = 0; i < 3; i++)
   {
	lw_mat[0][i] = xyz[1][i] - xyz[0][i];
	lw_mat[1][i] = xyz[3][i] - xyz[0][i];
	vec1_len += (lw_mat[0][i] * lw_mat[0][i]);
	vec2_len += (lw_mat[1][i] * lw_mat[1][i]);
    }

    if (fabs(vec1_len) < tol)
    {
	vec1_len = 0;

	for (i = 0; i < 3; i++)
	{
	  lw_mat[0][i] = xyz[2][i] - xyz[0][i];
	  vec1_len += (lw_mat[0][i] * lw_mat[0][i]);
	}

	EMerr_hndlr ((fabs(vec1_len) < tol),*EFmsg,EMS_E_InvalidArg, wrapup);

    } /* if (fabs(vec1_len) < tol) */

    if (fabs(vec2_len) < tol )
    {
	vec2_len = 0;
	
	for (i = 0; i < 3; i++)
	{
	  lw_mat[1][i] = xyz[2][i] - xyz[0][i];
	  vec2_len += (lw_mat[1][i] * lw_mat[1][i]);
	}

	EMerr_hndlr((fabs(vec2_len) < tol),*EFmsg,EMS_E_InvalidArg,wrapup);

    } /* if (fabs(vec2_len) < tol) */


    status = BScrossp (&rc, lw_mat[0], lw_mat[1], lw_mat[2]);
    status = BSnorvec (&rc, lw_mat[2]);
    status = BScrossp (&rc, lw_mat[2], lw_mat[0], lw_mat[1]);
    status = BSnorvec (&rc, lw_mat[0]);
    status = BSnorvec (&rc, lw_mat[1]);

    for (i = 0; i < 3; i++)
	for (j = 0; j < 4; j++)
	    xyz[j][i] -= xyz_org[i];

    for (i = 0; i < 4; i++)
    {
	for (j = 0; j < 3; j++)
	{
	  uv[i][j] = 0;
          
     	  for (k = 0; k < 3; k++)
	    uv[i][j] += (lw_mat[j][k] * xyz[i][k]);
	}
    }

   /*
    * calculate the scaling matrix
    */

    u_scale = uv[1][0];
    v_scale = uv[3][1];

    EFid_matrix(sc_mat);

    sc_mat[0][0] = (local_to_world ? u_scale : (1/u_scale));
    sc_mat[1][1] = (local_to_world ? v_scale : (1/v_scale));

    /*
     * calculate the shear matrix
     */

    x_shear = uv[2][0] / uv[2][1];

    if (!local_to_world) x_shear = -x_shear;

    EFid_matrix(sh_mat);
    sh_mat[0][1] = x_shear;

    /* 
     * matrix to conevert the world coordinate system
     * to the surface's local coordinate system (aligned
     * with its parametric coordinate system)
     */
        
    if (local_to_world)
    {
        status = MAtrnmx (&rc, &dimension, (IGRdouble *)lw_mat, (IGRdouble *)lw_mat);
        EMerr_hndlr (!status || !(1&rc), *EFmsg, EMS_E_Fail, wrapup);
    }

    EFid_matrix (trans_mat);
 
    for (i = 0; i < 3; i++)
    trans_mat[i][3] = srf->poles[low_left+i];
  
    if (!local_to_world)
     for (i = 0; i < 3; i++)
	trans_mat[i][3] = -trans_mat[i][3];

   if (local_to_world)
   {
      status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)trans_mat, (IGRdouble *)lw_mat, (IGRdouble *)temp_mat1);
      EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
      
      status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)temp_mat1, (IGRdouble *)sh_mat, (IGRdouble *)temp_mat2);
      EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);

      status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)temp_mat2, (IGRdouble *)sc_mat, (IGRdouble *)matrix);
      EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
   }   

   else
   {
     status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)sc_mat, (IGRdouble *)sh_mat, (IGRdouble *)temp_mat1);
     EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
      
     status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)temp_mat1, (IGRdouble *)lw_mat, (IGRdouble *)temp_mat2);
     EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
      
     status = MAmulmx (&rc, &l, &m, &n, (IGRdouble *)temp_mat2, (IGRdouble *)trans_mat, (IGRdouble *)matrix);
     EMerr_hndlr (!status || !(1&rc),*EFmsg,EMS_E_Fail,wrapup);
    }  


    wrapup:
         return (TRUE);

} /* end EFget_matrices */

static void EFid_matrix (matrix)

IGRdouble	*matrix;
{
   IGRint i;
   
   for (i = 0; i < 16; i++)
	matrix[i] = 0.;
   for (i = 0; i < 16; i += 5)
	matrix[i] = 1.;
}

/*
History   RC  12/07/87   Creation date
*/

IGRboolean EFgetxh_uv_scale (
   EFmsg,
   rot_angle,
   sf_org_geom,
   u_scale,
   v_scale)

IGRlong                     *EFmsg;
IGRdouble                   rot_angle;
struct IGRbsp_surface       *sf_org_geom;
IGRdouble                   *u_scale, *v_scale;

{
  IGRdouble             u, v;
  IGRdouble             u_left, u_right, v_left, v_right;
  IGRdouble             rot_org[3], rot_axis[3],
                        ls_range2[4], ls_pts1[4][4], ls_pts2[4];
  IGRdouble             rot_mat[16], uv_mat[4][4];
  struct IGRbsp_surface *sf_tr_geom;

  IGRshort              l = 4, m = 4, n = 1;
  IGRint                i;
  IGRlong               num_poles;
  IGRshort              mat_type;
  BSrc                  rc;
 

  IGRboolean            status;
 extern   IGRdouble             fabs();


  *EFmsg = EMS_S_Success;
  sf_tr_geom = NULL;

  BSallocsf(sf_org_geom->u_order, sf_org_geom->v_order,
            sf_org_geom->u_num_poles, sf_org_geom->v_num_poles,
            sf_org_geom->rational, 0, &sf_tr_geom,&rc);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  status = BSsf_copy (&rc, sf_org_geom, sf_tr_geom);
  EMerr_hndlr (!status || rc != BSSUCC, *EFmsg, EMS_E_BSerror,wrapup);

  u = v = 0.5;
  BSsfarrevn (&rc, sf_org_geom, 1, &u, 1, &v, rot_org, rot_axis);
  EMerr_hndlr (rc != BSSUCC, *EFmsg, EMS_E_BSerror, wrapup);

  status = MAgrotmx(EFmsg, rot_axis, rot_org, &rot_angle, rot_mat);
  EMerr_hndlr(! (status || (1 & *EFmsg)),*EFmsg,EMS_E_Fail,wrapup);

  num_poles = (sf_org_geom->u_num_poles) * (sf_org_geom->v_num_poles);

  status = MAtypemx(EFmsg, rot_mat, &mat_type);
  EMerr_hndlr (!(status || (1 & *EFmsg)), *EFmsg, EMS_E_Fail, wrapup);

  status = MAoptsxform (EFmsg, &num_poles, &mat_type,
           rot_mat, sf_org_geom->poles, sf_tr_geom->poles);
  EMerr_hndlr (!(status || (1 & *EFmsg)),*EFmsg,EMS_E_Fail,wrapup);

  status = EFsrf1uv_to_srf2uv (sf_org_geom, sf_tr_geom, uv_mat, EFmsg);
  EMerr_hndlr (!(status || (1 & *EFmsg)),*EFmsg,EMS_E_Fail,wrapup);

  ls_pts1[0][0] = ls_pts1[2][0] = 0.;
  ls_pts1[0][1] = ls_pts1[1][1] = 0.;
  ls_pts1[1][0] = ls_pts1[3][0] = 1.;
  ls_pts1[2][1] = ls_pts1[3][1] = 1.;

  ls_range2[0] = ls_range2[1] = MAXFLOAT;
  ls_range2[2] = ls_range2[3] = MINFLOAT;

  for (i = 0; i < 4; i++)
  {
    ls_pts1[i][2] = 0.;
    ls_pts1[i][3] = 1.;

    status = MAmulmx(EFmsg, &l, &m, &n, (IGRdouble *)uv_mat, ls_pts1[i], ls_pts2);
    EMerr_hndlr (!(status || (1 & *EFmsg)),*EFmsg, EMS_E_Fail, wrapup);

    if (ls_pts2[0] < ls_range2[0]) ls_range2[0] = ls_pts2[0];
    if (ls_pts2[0] > ls_range2[2]) ls_range2[2] = ls_pts2[0];
    if (ls_pts2[1] < ls_range2[1]) ls_range2[1] = ls_pts2[1];
    if (ls_pts2[1] > ls_range2[3]) ls_range2[3] = ls_pts2[1];
  }

  if(ls_range2[0] >= 0. && ls_range2[1] >= 0. && ls_range2[2] <= 1.
     && ls_range2[3] <= 1.)
    *u_scale = *v_scale = 1.;
  else
  {
    u_left = ( fabs (ls_range2[0] - 0.5))/ 0.5;
    u_right = ( fabs (ls_range2[2] - 0.5))/ 0.5;
    v_left  = ( fabs (ls_range2[1] - 0.5)) / 0.5;
    v_right = ( fabs (ls_range2[3] - 0.5))/0.5;
 
    *u_scale = (u_left > u_right) ? u_left : u_right;
    *v_scale = (v_left > v_right) ? v_left : v_right;
  }

wrapup:
  if (sf_tr_geom) BSfreesf (&rc, sf_tr_geom);
  return (TRUE);

} /* EFgetxh_uv_scale */

/*
 * Given the cross hatch spacing, cross hatch angle , cross hatch
 * origin and the
 * material type, the following functions returns parameter 
 * definition of the material cross hatch.
 */

void EFget_xh_definition (EFmsg, angle, origin, u_spacing, 
                          v_spacing, material, xh_info)
 IGRlong           *EFmsg;
 IGRdouble         angle, u_spacing, v_spacing, origin[3];
 IGRchar           material[];
 struct EMSxh_info *xh_info;

{
  struct EMSxh_sgrp_info      *sgrp_info;
  FILE                        *file_ptr;
  IGRchar                     file_name[200];
  IGRint                      str_len, i, style;
  IGRboolean                  status;
  void                        EFreadln();

  *EFmsg = EMS_S_Success;
  xh_info->u_sgrp_info = xh_info->v_sgrp_info = NULL;

  /*
   * Convert the incoming material to lower case.
   */

  str_len = strlen (material);
  
  for (i = 0; i < str_len; i++)
    material[i] = tolower(material[i]);

 /*
  * Find the material pattern file
  */
  {
   extern	int access();
   IGRlong	path_found, i, file_absent = TRUE, not_done = TRUE;

   for (i = 0; (i < 20) && not_done; i++)
    {
     path_found = ex$get_path(
       index = i,
       path = file_name,
       len = sizeof(file_name),
       type = EX_CONFIG_PATH);
      if (path_found)
       {
        strcat (file_name, "/config/matpat/");
        strcat (file_name, material);
        file_absent = access(file_name, 0);
        if (! file_absent) not_done = FALSE;
       }
      else
       not_done = FALSE;
    } /* for (i = 0; (i < 20) && not_done; i++) */
   if (file_absent)
    {
     fprintf(stderr, "\nCross hatch config file not found\n");
     *EFmsg = EMS_E_InvalidArg;
     goto wrapup;
    } /* if (file_absent) */
  }

  file_ptr = fopen (file_name, "r");
   if (! file_ptr)
    {
     *EFmsg = EMS_E_InvalidArg;
     goto wrapup;
    }
  /*
   * Read u_sgrps info. It is stored in the following way,
   *  o num_u_sgrps.
   *  o For each subgroup
   *    o num_rls_p_sgrp
   *    o sgrp_rls_spacing_factor
   *    o ptrn_sgrp_spacing_factor
   */

  status = 1 == fscanf (file_ptr, "num_u_sgrps %hd  \n", 
                        &xh_info->num_u_sgrps);
  EMerr_hndlr (!status, *EFmsg, EMS_E_Fail,wrapup);  

  if (xh_info->num_u_sgrps)
  {
   xh_info->u_sgrp_info = (struct EMSxh_sgrp_info *) om$malloc (
   size = xh_info->num_u_sgrps * sizeof(struct EMSxh_sgrp_info));
   EMerr_hndlr(!xh_info->u_sgrp_info,*EFmsg,EMS_E_NoDynamicMemory,wrapup);
              
   for (i = 0; i < xh_info->num_u_sgrps; i++)
   {
     sgrp_info = &xh_info->u_sgrp_info[i];

     EFreadln (file_ptr);               /* u_sgrp # xx */

     status = 1 == fscanf (file_ptr, "style %d \n", &style);
     EMerr_hndlr (!status, *EFmsg, EMS_E_Fail, wrapup);
     sgrp_info->style = (IGRuchar) style;

     status = 1 == fscanf (file_ptr, "num_rls_p_sgrp %hd \n", 
                           &sgrp_info->num_rls_p_sgrp);
     EMerr_hndlr (!status, *EFmsg,EMS_E_Fail,wrapup);

     status = 1 == fscanf (file_ptr, "sgrp_rls_spacing_factor %lf \n", 
                           &sgrp_info->sgrp_rls_spacing);
     EMerr_hndlr (!status, *EFmsg,EMS_E_Fail,wrapup);
     sgrp_info->sgrp_rls_spacing *= u_spacing;

     status = 1 == fscanf (file_ptr, "ptrn_sgrp_spacing_factor %lf \n", 
                           &sgrp_info->ptrn_sgrp_spacing);
     EMerr_hndlr (!status, *EFmsg,EMS_E_Fail,wrapup);
     sgrp_info->ptrn_sgrp_spacing *= u_spacing;

    } /* for (i = 0; i < xh_info->num_u_sgrps; i++) */

  } /* if (xh_info->num_u_sgrps) */
 

  /*
   * Read v_sgrps info. It is stored in the following way,
   *  o num_u_sgrps.
   *  o For each subgroup
   *    o num_rls_p_sgrp
   *    o sgrp_rls_spacing_factor
   *    o ptrn_sgrp_spacing_factor
   */

  status = 1 == fscanf (file_ptr, "num_v_sgrps %hd \n", 
                        &xh_info->num_v_sgrps);
  EMerr_hndlr (!status, *EFmsg, EMS_E_Fail,wrapup);  

  if (xh_info->num_v_sgrps)
  {
   xh_info->v_sgrp_info = (struct EMSxh_sgrp_info *) om$malloc (
   size = xh_info->num_v_sgrps * sizeof(struct EMSxh_sgrp_info));
   EMerr_hndlr(!xh_info->v_sgrp_info,*EFmsg,EMS_E_NoDynamicMemory,wrapup);
              
   for (i = 0; i < xh_info->num_v_sgrps; i++)
   {
     sgrp_info = &xh_info->v_sgrp_info[i];

     EFreadln (file_ptr);               /* v_sgrp # xx */

     status = 1 == fscanf (file_ptr, "style %d \n", &style);
     EMerr_hndlr (!status, *EFmsg, EMS_E_Fail, wrapup);
     sgrp_info->style = (IGRuchar) style;

     status = 1 == fscanf (file_ptr, "num_rls_p_sgrp %hd \n", 
                           &sgrp_info->num_rls_p_sgrp);
     EMerr_hndlr (!status, *EFmsg,EMS_E_Fail,wrapup);

     status = 1 == fscanf (file_ptr, "sgrp_rls_spacing_factor %lf \n", 
                           &sgrp_info->sgrp_rls_spacing);
     EMerr_hndlr (!status, *EFmsg,EMS_E_Fail,wrapup);
     sgrp_info->sgrp_rls_spacing *= v_spacing;

     status = 1 == fscanf (file_ptr, "ptrn_sgrp_spacing_factor %lf \n", 
                           &sgrp_info->ptrn_sgrp_spacing);
     EMerr_hndlr (!status, *EFmsg,EMS_E_Fail,wrapup);
     sgrp_info->ptrn_sgrp_spacing *= v_spacing;

    } /* for (i = 0; i < xh_info->num_u_sgrps; i++) */

  } /* if (xh_info->num_u_sgrps) */
 
  fclose (file_ptr);
  file_ptr = NULL;

  xh_info->angle = angle;
  OM_BLOCK_MOVE (origin, xh_info->origin, sizeof(IGRpoint));
  
wrapup:
  return;
    
} /* EFget_xh_definition () */

static void EFreadln (file_ptr)
 FILE  *file_ptr;
{
  char    c = 'a';
  int i = 0;

  while ( !feof(file_ptr) && c != '\n')
  {
   c = getc(file_ptr);
   i++;
  }
  return;
}
