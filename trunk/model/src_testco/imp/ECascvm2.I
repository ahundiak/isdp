/* ###################   APOGEE COMPILED   ################## */
class implementation ECascvmd;
/*
ABSTRACT

History
           dfl    created  07/94 
           uwa       "       "   

 */

#ifndef OM_DEFINE_ERRMSG
#define OM_DEFINE_ERRMSG
#endif

#define dflT1 0
#define dflT5 0


#include "memory.h"
#include "EMS.h"
#include "OMerrordef.h"
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grvaluedef.h replacement */
/*#include "grdef.h"*/
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"

/*#include "gotextdef.h"*/
/*#include "coimport.h"*/
#include "griomacros.h" /* co$getevent */
#include "grgsmacros.h"
#include "grmacros.h"
#include "grwireframe.h"
#include "comiscmac.h"
#include "bserr.h"
#include "bsicmpcvoff.h"
#include "bs.h"
#include "bsparameters.h"
#include "math.h"
#include "comisc.h"
#include "nddef.h"
#include "ndmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "lcmacros.h"
#include "cotxmacros.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "dpezmac.h"
#include "coplcmac.h"
#include "OMobjectcomm.h"
#include "exmacros.h"		/* ex$putqueue() */
#include "fontdef.h"
#include "dp.h"
#include "fontmacros.h"
#include "gotext.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_I.h"
#include "dpdef.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "nddef.h"
#include "exdef.h"
#include "ECascvmd.h"



/*vvvvv*/
#if defined ( NT )
#if 0 /* because opp cannot handle it */
#include <windows.h>
#endif
#endif

#ifdef X11
#include <X11/Xlib.h>
#unclude <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0 /* because opp cannot handle it */
#if defined ( X11 )
#include <XFIproto_pub.h>
#elif defined ( ENV5 )
#include <FIproto_pub.h>
#elif defined ( NT )
#include <shampub.h>
#endif
#else
#include <FI.h>
#endif
#else
#include <FI.h>
#endif
/*^^^^^*/



extern IGRboolean BSnorvec();
extern IGRboolean BScumdist();
extern IGRdouble 	BSdotp();
extern void BScveval();
extern IGRdouble      fabs(IGRdouble);
/*extern IGRint strlen();*/
IGRint dist_process_form ();
IGRint cvra_process_form ();
IGRint spol_process_form ();
IGRint sknt_process_form ();
IGRint tool, wool;

extern OMuword 			OPP_EMScomposite_class_id;
extern OMuword 			OPP_GR3dlineseg_class_id;
extern OMuword 			OPP_GR3dlinestr_class_id;
extern OMuword 			OPP_GA3dlinestr_class_id;
extern OMuword 			OPP_GRbspline_class_id;
extern OMuword 			OPP_GRcurve_class_id;
extern OMuword 			OPP_EMSdatpln_class_id;
extern OMuword 			OPP_EMSplane_class_id;
extern OMuword 			OPP_EMSsurface_class_id;
extern OMuword 			OPP_EMSsubbs_class_id;
extern OMuword 			OPP_GRbcsubbc_class_id;
extern OMuword                  OPP_GRlinear_class_id;
extern OMuword                  OPP_GAbspline_class_id;
extern void TWlsqweccv0();


from GRgraphics import 	GRlnproject, GRdisplay, GRgetrang, GRdelete, 
                       	GRgetobjinfo, GRptproject;
from GRvg import 	GRgetattr, GRpostabsg, GRgeomprops, GRgetgeom,
                        GRgetprops, GRdetplane, 
                 	GRgetsize, GRconstruct, GRprojpt, EMptatpr;
from EMSsubbs import EMtoggle_polygon;
from GR3dlinestr import GRgetpolyline, GRputpolyline;
from GRlinear import    GRvtadjseg, GRdelvertex;
from GRcurve import 	EMcvoffset, GRgenabsg, GRmidpoint, GRinsvertex;
from EMSassoc import    EMget_info, EMput_info;
from NDnode   import    NDget_objects;
from ASnode   import    NDchange_connect;
from GRfm     import    GRfm_retdata;






void Quick_project (struct IGRbsp_curve *crv,
                    IGRint           num_pts,
                    IGRdouble     *input_pts,
                    IGRdouble    *output_pts,
                    IGRint            *max_i,
                    IGRdouble      *max_dist,
                    IGRlong             *ret)

/* 
 
  Abstract:     Quick_project projects a number of points normally onto a curve.

     Input:     crv                - pointer to curve
                num_pts            - number of points to project
                input_pts          - array of 3D points 
                                    (input_pts[0]  - x component of first point,
                                              [1]  - y component of first point)
            
    Output:     output_pts         - array of 3D points on the curve which
                                     are the projection points
                max_i              - point number where distance is maximum
                max_dist           - maximum distance
                ret                - return code (ret = 0  - failure,  
                                                        1  - success)

  Assumptions:  This routine has been written to serve as a fast projection
                routine within this EMS function. The following is assumed:
                1)  The curve has been created using the points, that is the
                    points are reasonably close to the curve and are dense.
                2)  The points are ordered, that is the first point is in the
                    vicinity of the start of the curve, the last point at the
                    end of the curve. The projected points have increasing
                    parameters.
                3)  The curve has order > 2.

  History:      08/01/94    Created    THW.
*/

{
   IGRdouble    *i_pts=NULL;
   IGRdouble    *o_pts=NULL;
   IGRdouble    pt[3];
   IGRdouble    u=0.0, u_next=0.0;
   IGRint       num_deriv = 2;
   IGRpoint     eval[3];
   IGRdouble    *eval_p=NULL;
   IGRdouble    ptcv[3];
   IGRdouble    ptcv_sq=0.0;
   IGRdouble    tan[3];
   IGRdouble    tan_sq=0.0;
   IGRdouble    func=0.0, dfunc=0.0;
   IGRdouble    afunc_sq=0.0;
   IGRdouble    dist=0.0;
   IGRint       n_iter=0;
   IGRdouble    step=0.0, step_old=0.0;

   IGRdouble    start=0.0;
   IGRdouble    ende=0.0;

   IGRint       i=0,j=0;
   BSrc         rc;

   IGRdouble    chrdht_tol=0.0;
   IGRdouble    same_angle_tol_sq=0.0;
   IGRint       max_iter=0;
 
   IGRdouble    mach_eps=0.0;
   IGRdouble    eps_root=0.0;


#define abs(a)   ((a)<0?(-a):(a))

/****************************************************************************
 *
 *     Start of executable code
 *
 *************************************************************************** */

/* check input */
   start = 0.0;
   ende = 1.0;
   max_iter = 20;
   *ret = 0; 

   if ((crv == NULL) | (num_pts < 1)) goto wrapup;
   if (crv->order < 3)                goto wrapup;

/* set up data */

   BSEXTRACTPAR (&rc,BSTOLCHRDHT,chrdht_tol);
   same_angle_tol_sq = chrdht_tol*chrdht_tol;

   mach_eps = 1.0e-5;

   do
     {
      mach_eps = 0.5*mach_eps;
      u        = mach_eps + 1.0;
     }
      while (u > 1.0);

   mach_eps   *= 2.0;
   eps_root    = sqrt(mach_eps);

   i_pts   = input_pts;
   o_pts   = output_pts;

/* loop thru all points */


   for (i=0; i<num_pts; i++)
      {
       *(pt)   = *(i_pts++);
       *(pt+1)   = *(i_pts++);
       *(pt+2)   = *(i_pts++);
       afunc_sq= 10.0*same_angle_tol_sq;
       n_iter  = 0;

       if (i == 0)
         u_next=start;
       if (i == num_pts-1)
         u_next=ende;


       while ((afunc_sq > same_angle_tol_sq) && (n_iter < max_iter))
             {
              u     = u_next;

              BScveval (crv, u, num_deriv, &eval[0], &rc);

              if (rc != BSSUCC)
                goto wrapup;

              func  = 0.0;
              dfunc = 0.0;

              eval_p = (IGRdouble *) &eval[0];
              for (j=0; j<3; j++) 
                 {          
                  *(ptcv+j)   = *(pt+j)- *(eval_p+j);
                  func     += *(ptcv+j)* *(eval_p+3+j);
                  *(tan+j)    = *(eval_p+3+j)* *(eval_p+3+j);
                  dfunc    += - *(tan+j) + *(ptcv+j)* *(eval_p+6+j); 
                 }

              if (abs(dfunc) < eps_root)
                dfunc    = eps_root;
             
              step       = func/dfunc;

              if (n_iter == 0)
                 step_old= step;
              else
                 if (abs(step) > abs(step_old))
                   step = step_old;
              step_old = step;
              u_next     = u - step;

              if (u_next < 0.0) 
                u_next = 0.0;

              if (u_next > 1.0)
                u_next = 1.0;

               ptcv_sq  = *(ptcv)* *(ptcv) + *(ptcv+1)* *(ptcv+1) + *(ptcv+2)* *(ptcv+2);
               dist     = ptcv_sq;
               if (ptcv_sq < eps_root)
                 ptcv_sq= eps_root;
                /*tan_sq   = *(tan)* *(tan) + *(tan+1) * *(tan+1) + *(tan+2) * *(tan+2);*/
                tan_sq   = *(tan) +  *(tan+1) +  *(tan+2);
                afunc_sq = (func*func)/((ptcv_sq)*(tan_sq));
                n_iter++;
	    }




       for (j=0; j<3; j++)
          *(o_pts++) = *(eval_p+j);

       u_next=  u;

       dist  = sqrt(dist);

       if (i == 0)
         {
          *max_dist = dist;
          *max_i    = 0;
         }
       else
         {
          if (*max_dist < dist)
            {
              *max_dist = dist;
              *max_i    = i;
            }
         }  
     }

   *ret = 1L;  


/*  wrapup */

wrapup:
   return;
}



IGRdouble	 bf_nr(ord,num,anz,knot,u)
IGRint      ord,num,anz;
IGRdouble   *knot,u;
{
	IGRint    i=0, j=0;
	IGRdouble a1=0.0, a2=0.0, b=0.0, *ba=NULL, *bn=NULL;

	ba = (IGRdouble *) stackalloc ((ord+anz) * sizeof ( IGRdouble ) );
        if(!ba)
          goto function_end;
	bn = (IGRdouble *) stackalloc ((ord+anz) * sizeof ( IGRdouble ) );
        if(!bn)
          goto function_end;
	for ( i=0 ; i<ord+anz ; i++)
	 *(bn+i) = 0;
	for ( i=0 ; i<anz ; i++)
	{
	 if ( *(knot+i)-EPS < u 
	      &&        u < *(knot+i+1)+EPS 
	      &&      EPS < *(knot+i+1)- *(knot+i) )
	 {
	  *(bn+i) = 1;
	  i     = anz;
	 }
	}
	for ( j=2 ; j<ord+1 ; j++)
	{
	 for ( i=num ; i<num+ord-j+2 ; i++ )
	  *(ba+i) = *(bn+i);
    	 for ( i=num ; i<num+ord-j+1 ; i++ ) {
	  if ( *(knot+i+j-1)- *(knot+i)<EPS && *(ba+i)<EPS )
	   a1 = 0;
	  else 
	  a1 = *(ba+i)*(u-*(knot+i))/(*(knot+i+j-1)- *(knot+i));
	  if ( *(knot+i+j)- *(knot+i+1)<EPS && *(ba+i+1)<EPS )
	   a2 = 0;
	  else
	  a2 = *(ba+i+1)*(*(knot+i+j)-u)/(*(knot+i+j)- *(knot+i+1));
	  *(bn+i) = a1+a2;
	 }
	}
	b = *(bn+i-1);

      function_end:
	return(b);
}

IGRdouble   bf_ra(ord,num,anz,knot,weight,u)
int	 ord, num, anz;
IGRdouble	 *knot, *weight, u;
{
	int    i=0;
	double bz=0.0, bn=0.0, ra=0.0;
	bz = weight[num] * bf_nr(ord,num,anz,knot,u);
	bn = 0;
	for ( i=0 ; i<anz ; i++ )
	{
	 ra = bf_nr(ord,i,anz,knot,u);
	 bn = bn + *(weight+i) * ra;
	}
	ra = bz/bn;
	return(ra);
}

IGRint Create_curve_dynamics_function(
    struct istruct *infos,
    struct EX_button    *point,
    IGRdouble *matrix,
    struct GRid **objects,
    IGRint *num_objects,
    struct DPele_header **buffers,
    IGRint *num_buffers,
    IGRchar *dummy_in1,
    IGRchar *dummy_in2,
    IGRchar *dummy_in3,
    IGRchar **dummy_out1,
    IGRchar **dummy_out2,
    IGRchar **dummy_out3)
{
 /* 
    ABSTRACT  dynamic function which computes new poles depending on
              cusrsor position;
 */
 BSrc rcn;
 IGRboolean ratio, first, distance, fromto, curvature, hedgehog;
 IGRboolean smooth;
 IGRint *rc,i, ord, pol_anz, knot_anz, i3, p_s,m_p,t_min,t_max,
        p_min,p_max, bed_a, bed_e, n_anf, n_end;
 IGRint j, j_max, buf_i, j3, j6, ND, ev_bound, bound, p_str, p_end;
 IGRdouble rx, ry, rz;
 IGRdouble d, d_l[9], mx, my, mz, max, udel, tmp_a;
 IGRdouble nx[ANZ_NORM],ny[ANZ_NORM],nz[ANZ_NORM],p_x[ANZ_NORM],
           p_y[ANZ_NORM], p_z[ANZ_NORM], rho[ANZ_NORM], *ppt, *distp, 
           smfac;
 struct extents text_extents;
 IGRdouble  *pole,*ugpole, *pol_x,*pol_y,*pol_z,*knot,*weigh,u_par,*p_par,tmp,
            pnt_ist[3],pnt_lot[3],vek_x,vek_y,vek_z,pnt[3],*bf,
            *pols_x, *pols_y, *pols_z,*vec_x, *vec_y,*vec_z,pot_a,pot_e,
            lam_x,lam_y,lam_z, w, l_vek;
 IGRdouble  point_t[3], dist_max;
 IGRpoint   cursp, r;
 IGRvector  nvec;
 struct IGRbsp_curve *crv;
 struct IGRdisplay default_display, help_display;  

 gr$get_active_display( buffer = &default_display );
 help_display = default_display;
 help_display.style = (IGRuchar) 2;
 help_display.color = (short unsigned) 4;
 help_display.weight = (IGRuchar) 0;

 *num_buffers = 0;

 fromto = infos->fromto;
 
 crv = infos->dyn_elements[0].geometry.bspcurve;
 ord      = crv->order;
 n_anf = *infos->n_anf;
 n_end = *infos->n_end;
 knot_anz = crv->num_knots;
 pol_anz  = crv->num_poles;
 ratio = crv->rational;
 bed_a = *infos->bed_a;
 bed_e = *infos->bed_e;
 smfac = *infos->smfac;
 smooth = *infos->smooth;
 first = *infos->first;
 knot = infos->knot;
 pols_x = infos->pols_x;
 pols_y = infos->pols_y;
 pols_z = infos->pols_z;
 pol_x = infos->pol_x;
 pol_y = infos->pol_y;
 pol_z = infos->pol_z;
 vec_x = infos->vec_x;
 vec_y = infos->vec_y;
 vec_z = infos->vec_z;
 weigh = infos->weigh;
 bf = infos->bf;
 p_par = infos->p_par;
 pole = infos->pole;
 ugpole = infos->ugpole;
 curvature = infos->curvature;
 hedgehog = infos->hedgehog;
 distance = infos->distance;
 d = *infos->d;

   point_t[X] = infos->point_t[X];
   point_t[Y] = infos->point_t[Y];
   point_t[Z] = infos->point_t[Z];
   rx = point->x - point_t[X];
   ry = point->y - point_t[Y];
   rz = point->z - point_t[Z];
   if(rx < 0)
     rx = -1;
   else 
     rx = 1;
   if(ry < 0)
     ry = -1;
   else 
     ry = 1;
   if(rz < 0)
     rz = -1;
   else 
     rz = 1;
   infos->point_t[X] = point->x;
   infos->point_t[Y] = point->y;
   infos->point_t[Z] = point->z;


 *infos->mark_px = point->x;
 *infos->mark_py = point->y;
 *infos->mark_pz = point->z;

 if(*infos->ex_cmd_pressed || *infos->ex_pocket_pressed) {
   point->x = infos->plocp[X];
   point->y = infos->plocp[Y];
   point->z = infos->plocp[Z];
 }
 
  /* cursor sensitivity */
 if(*infos->cms != CURSOR_SENS1) {
   lam_x = fabs(point->x - *infos->px_old);
   lam_y = fabs(point->y - *infos->py_old);
   lam_z = fabs(point->z - *infos->pz_old);

   point->x = *infos->px_old + rx*lam_x/ (IGRdouble)*infos->cms;
   point->y = *infos->py_old + ry*lam_y/ (IGRdouble)*infos->cms;
   point->z = *infos->pz_old + rz*lam_z/ (IGRdouble)*infos->cms;
 }

  if(*infos->keep_planar) {
    cursp[X] = point->x;  
    cursp[Y] = point->y;  
    cursp[Z] = point->z;  
    BSproj1(&rcn, cursp, &infos->plane->normal[0], &infos->plane->point[0], r);
    /*TEST_MATH_ERROR(rc,"BSproj1",function_end);*/
    point->x = r[X];
    point->y = r[Y];
    point->z = r[Z];
  }

  if(!fromto) {   
      pnt_ist[X] = point->x;
      pnt_ist[Y] = point->y;
      pnt_ist[Z] = point->z;

      BSmdstptcv(infos->ocrv,pnt_ist,&u_par,pnt_lot,&tmp,&rc);
      vek_x = point->x - pnt_lot[X];
      vek_y = point->y - pnt_lot[Y];
      vek_z = point->z - pnt_lot[Z];
      if(*infos->common_dist) {
        nvec[X] = vek_x;
        nvec[Y] = vek_y;
        nvec[Z] = vek_z;
        BSnorvec(&rc, nvec);
        vek_x = nvec[X] * *infos->prodist;
        vek_y = nvec[Y] * *infos->prodist;
        vek_z = nvec[Z] * *infos->prodist;
      }
      l_vek = sqrt((vek_x * vek_x) + (vek_y * vek_y) + (vek_z * vek_z));
      *infos->l_vek = l_vek;
  } else {
      u_par = *infos->u_par;
      vek_x = point->x - infos->pnt_lot[X];
      vek_y = point->y - infos->pnt_lot[Y];
      vek_z = point->z - infos->pnt_lot[Z];
  }

 if(!first) {
   *infos->first = TRUE;
   for ( i=0 ; i<knot_anz ; i++ )
     *(knot+i) = *(crv->knots+i);
   switch (ratio) {
    case (NON_RATIONAL):
      for ( i=0 ; i<pol_anz ; i++ ) {
        i3 = 3*i;
        *(pols_x+i) = *(crv->poles+i3++)  ;
        *(pols_y+i) = *(crv->poles+i3++);
        *(pols_z+i) = *(crv->poles+i3);
        *(weigh+i)  = 1.0;
      }
   break;

   case RATIONAL:
   default:
    for ( i=0 ; i<pol_anz ; i++ ) { 
      i3 = 3*i;
      *(weigh+i)  = *(crv->weights+i);
      w = 1/ *(weigh+i);
      *(pols_x+i) = *(crv->poles+i3++)  * w;
      *(pols_y+i) = *(crv->poles+i3++) * w;
      *(pols_z+i) = *(crv->poles+i3) * w;
    }
  break;
  }

 p_par[0] = 0.0;
 for ( i=1 ; i<pol_anz-1 ; i++) {
   pnt[X] = *(pols_x+i);
   pnt[Y] = *(pols_y+i);
   pnt[Z] = *(pols_z+i);
   BSmdstptcv(crv,pnt,&*(p_par+i),pnt_lot,&tmp,&rc);
 }
 *(p_par+pol_anz-1) = 1.0;  
 }
 /* p_s is the smallest i, with p_par[i]<=u_par and u_par<p_par[i+1]
    if ( m_p==1 ) the line K(u_par) goal-point passes the pole p_s 
    m_p is the minimum number of poles which has to be moved         */
 if((!first && fromto) || (!fromto)) {
   m_p = 0;
   if ( u_par<DEL*p_par[1] ) {
   /*the modification point is equal with the pole 0*/
     m_p = 1;
     p_s = 0;
   } else {
     if ( 1.0-DEL*(1.0-p_par[pol_anz-2])<u_par ) {
     /*the modification point is equal with the pole pol_anz-1*/
       m_p = 1;
       p_s = pol_anz-1;
     } else {
       m_p = 2;
       for ( j=1 ; j<pol_anz ; j++ ) {
         if ( u_par<p_par[j] ) {
           p_s = j-1;
           j   = pol_anz;
         }
       }
       j = p_s;
       if ( p_s==0 )
        j = p_s+1; 
       for ( i=j ; i<j+2 && i<pol_anz ; i++ ) {
        tmp = fabs(p_par[i]-u_par );
        if ( tmp<DEL*(p_par[i]-p_par[i-1]) 
        && tmp<DEL*(p_par[i+1]-p_par[i]) ) {
         p_s = i;
         m_p = 1;
        }
       }
     }
   }
 p_min = 0;
 switch ( ratio ) {
  case ( NON_RATIONAL ):

    for ( i=p_s ; -1<i ; i--) {
      *(bf+i) = bf_nr(ord,i,pol_anz,knot,u_par);
      if ( *(bf+i)<MMIN )
        i     = 0;
      else
        p_min = i;
    }
    for ( i=p_s ; i<pol_anz ; i++) {
      *(bf+i) = bf_nr(ord,i,pol_anz,knot,u_par);
      if ( *(bf+i)<MMIN )
        i   = pol_anz;
      else
        p_max = i;
    }
    break;

  default:
  case RATIONAL:
   for ( i=p_s ; -1<i ; i-- ) {
     *(bf+i) = bf_ra(ord,i,pol_anz,knot,weigh,u_par);
     if ( *(bf+i)<MMIN )
       i     = 0;
     else
       p_min = i;
   }
   for ( i=p_s ; i<pol_anz ; i++ ) {
     *(bf+i) = bf_ra(ord,i,pol_anz,knot,weigh,u_par);
     if ( bf[i]<MMIN )
       i   = pol_anz;
     else
       p_max = i;
   }
  break;
  }    
  if( 0<bed_a  && u_par<p_par[bed_a-1]                  || 
      1==bed_a && u_par <  DEL*p_par[1]                ||  
      0<bed_e  && p_par[pol_anz-bed_e] < u_par          ||
      1==bed_e && 1.0-DEL*(1.0-p_par[pol_anz-2]) < u_par  )
  {
/* bug fix ,report from vdo, no 2.7.2, 8/10/97 */
/* do not report this error */
/*   fprintf(stderr,"\n***************        ");
   fprintf(stderr," Modification failed !  ");
   fprintf(stderr,"          **************");
*/

/* bug fix ,report from vdo, no 2.7.1, 8/10/97 */
   goto Buffers_end;
  }
  if ( p_s-n_anf-bed_a < 0 )
  {
   t_min = bed_a;
   n_anf = p_s-bed_a;
  }
  if ( pol_anz-bed_e-p_s<2 )
   m_p = 1;
  if(pol_anz<p_s+m_p+n_end-bed_e)
   t_max = pol_anz-bed_e-1;

  *infos->p_s = p_s;
  *infos->m_p = m_p;
  *infos->p_min = p_min;
  *infos->p_max = p_max;
  *infos->t_min = t_min;
  *infos->t_max = t_max;
 } else {
  p_s = *infos->p_s;
  m_p = *infos->m_p;
  p_min = *infos->p_min;
  p_max = *infos->p_max;
  t_min = *infos->t_min;
  t_max = *infos->t_max;
 }

 pot_a = 50. - *infos->shape_amount_left;
 pot_e = 50. - *infos->shape_amount_right;
 pot_a /= 12.5;
 pot_e /= 12.5;
 pot_a = (pow(2.0,pot_a) - 1.0)/3.0;
 pot_e = (pow(2.0,pot_e) - 1.0)/3.0;
 

  n_anf = n_anf+1;
  n_end = n_end+1;
  /* *infos->p_s = p_s;
  *infos->m_p = m_p;
  *infos->p_min = p_min;
  *infos->p_max = p_max;
  *infos->t_min = t_min;
  *infos->t_max = t_max; */

  /* p_min is the smallest number of the pole which influences the Mod. Pnt.
     If pol[p_min] can notbe moved, becuse of boundary conditions, then t_min
     takes the place of p_min. The value p_min has to be stored, because the
     boundary condition can change in the next modification step. Same for 
     p_max and t_max.
             */ 
 if ( p_min<p_s-n_anf+1 )
   t_min = p_s-n_anf+1;
 else
   t_min = p_min;
 if ( pol_anz-bed_e<p_max )
  t_max = pol_anz-bed_e-1;
 else
  t_max = p_max; 

 if ( 3<n_end+n_anf+m_p ) {
   if ( bed_a==0 && p_s-n_anf<0 ) 
    pot_a = 0.0;
   if ( bed_e==0 && pol_anz<p_s+n_end+m_p ) 
      pot_e = 0.0;
 }

 if ( t_min<bed_a )
  t_min = bed_a;

  /* Set all vectors to 0 and catch the origin poles to start into the next
     modification step with the origin curve.              */

  for ( i=0 ; i<pol_anz ; i++ ) {
   *(vec_x+i) = 0.0;
   *(vec_y+i) = 0.0;
   *(vec_z+i) = 0.0;
   *(pol_x+i) = *(pols_x+i);
   *(pol_y+i) = *(pols_y+i);
   *(pol_z+i) = *(pols_z+i);
  }
   p_str = p_s-n_anf+1;
   if ( p_str<bed_a )
    p_str=bed_a;
   p_end = p_s+n_end+m_p-2;
   if ( pol_anz-bed_e-1<p_end )
    p_end = pol_anz-bed_e-1;


  /* 3<n_end+n_anf+m_p means there is more than one pole to move */ 

   if ( 0<smfac && smooth ) 
   {
    extern    BSmdstptcv();
    BSrc      rc;
    IGRint    n_beg=0, n_fin=0, nom_pol=0;
    IGRlong   cknn=0, nom_pts=0;
    IGRshort  *pfix=NULL, cord=0, num_fix=0,
              opt_sm=0;
    IGRdouble *pts=NULL, *ckn=NULL, *cpa=NULL, *ppol=NULL, 
              tmp1=0.0, tmp2=0.0, pnt_pro[3];
    struct    IGRbsp_curve *bsp_crv = NULL;
    bsp_crv = (struct IGRbsp_curve *)
                   om$malloc(size = (sizeof(struct IGRbsp_curve)));
    if(!bsp_crv)
     goto smooth_end;
    if ( smfac<0.0 )
     smfac = 0.0;
    if ( 1.0<smfac )
     smfac = 1.0;
    n_beg = p_str-1;   
    if ( n_beg<0 )
     n_beg = 0;
    n_fin = p_end+1;
     if ( pol_anz-1<n_fin )
    n_fin = pol_anz-1;
    nom_pts = 1 + n_fin - n_beg;
    cord      = 4;
    num_fix   = 2;
    opt_sm    = 1;
    nom_pol   = (IGRint)((IGRdouble)(4-nom_pts)*smfac) + nom_pts;
    if ( nom_pol<4 )
     nom_pol=4;
    ppol = (IGRdouble *) stackalloc ( 3 * nom_pol * sizeof ( IGRdouble ) );
    if(!ppol)
     goto smooth_end;
    for ( i=0 ; i<3*nom_pol ; i++ )
     ppol[i] = (IGRdouble)(i);
    cknn    = cord + nom_pol;
    pfix = (IGRshort *) stackalloc ( num_fix * sizeof ( IGRshort ) );
     if(!pfix)
      goto smooth_end;
    pfix[0] = 1;
    pfix[1] = nom_pts;
    pts = (IGRdouble *) stackalloc ( 3 * nom_pts * sizeof ( IGRdouble ) );
     if(!pts)
      goto smooth_end;
    ckn = (IGRdouble *) stackalloc ( (cord+nom_pol) * sizeof ( IGRdouble ) );
     if(!ckn)
      goto smooth_end;
    cpa = (IGRdouble *) stackalloc ( nom_pts * sizeof ( IGRdouble ) );
     if(!cpa)
      goto smooth_end;
    for ( i=0 ; i<cord ; i++ )
    {
     ckn[i] = 0.0;
     ckn[nom_pol+i] = 1.0;
    }
    for ( i=cord ; i<nom_pol ; i++ )
     ckn[i] = ckn[i-1] + 1.0/(IGRdouble)(nom_pol+cord-1);
    for ( i=0 ; i<nom_pts ; i++ )
     cpa[i] = (IGRdouble)(i)/(IGRdouble)(nom_pts-1); 
    for ( i=0 ; i<nom_pts ; i++ )
    {
     *(pts+3*i)   = *(pol_x+n_beg+i);
     *(pts+3*i+1) = *(pol_y+n_beg+i);
     *(pts+3*i+2) = *(pol_z+n_beg+i);
    }
    bsp_crv->order          = cord;
    bsp_crv->num_poles      = nom_pol;
    bsp_crv->poles          = ppol; 
    bsp_crv->periodic       = FALSE;
    bsp_crv->num_knots      = cknn;
    bsp_crv->rational       = FALSE;
    bsp_crv->non_uniform    = TRUE;
    bsp_crv->weights        = NULL;
    bsp_crv->planar         = FALSE;
    bsp_crv->phy_closed     = FALSE;
    bsp_crv->num_boundaries = 0;
    bsp_crv->knots          = ckn;
    bsp_crv->bdrys          = NULL;
    TWlsqweccv0(nom_pts,         3,  pts, cord, 
                   cknn,       ckn,    0,  cpa,
                num_fix,      pfix,    0, NULL, 
                   NULL,         0,    0, NULL,
                      0,      NULL, NULL, 
                      0,    opt_sm,  
                  smfac,   bsp_crv,  &rc);
    for ( i=0 ; i<nom_pts-2 ; i++ )
    {
     BSmdstptcv(bsp_crv, &*(pts+3*i+3), &tmp1, pnt_pro, &tmp2 , &rc);
     pol_x[n_beg+1+i] = pnt_pro[0];
     pol_y[n_beg+1+i] = pnt_pro[1];
     pol_z[n_beg+1+i] = pnt_pro[2]; 
    } 
   }


   smooth_end:
   if ( MMIN<pot_a ) {
    for ( i=t_min ; i<p_s+1 ; i++ ) {
     tmp = (p_par[i]-p_par[p_s-n_anf])/(u_par-p_par[p_s-n_anf]);
     vec_x[i] = vek_x*pow(tmp,pot_a); 
     vec_y[i] = vek_y*pow(tmp,pot_a); 
     vec_z[i] = vek_z*pow(tmp,pot_a); 
    }
   } else {
    for ( i=t_min ; i<p_s+1 ; i++ ) {
     vec_x[i] = vek_x;
     vec_y[i] = vek_y;
     vec_z[i] = vek_z;
    }  
   }
   if ( MMIN<pot_e ) { 
    for ( i=p_s+1; i<t_max+1 ; i++ ) {
     tmp = (p_par[p_end+1] - p_par[i])/(p_par[p_end+1] - u_par);
     vec_x[i] = vek_x*pow(tmp,pot_e);
     vec_y[i] = vek_y*pow(tmp,pot_e);
     vec_z[i] = vek_z*pow(tmp,pot_e);
    }
   } else {
    for ( i=p_s+1; i<t_max+1 ; i++ ) {
     vec_x[i] = vek_x;
     vec_y[i] = vek_y;
     vec_z[i] = vek_z;
    }
   }
   switch ( ratio ) {
    case ( NON_RATIONAL ):
     for ( i=t_min ; i<t_max+1&&i<pol_anz ; i++ )
      bf[i] = bf_nr(ord,i,pol_anz,knot,u_par);
    break;

    default:
    case (RATIONAL):
     for ( i=t_min ; i<t_max+1&&i<pol_anz ; i++ )
      bf[i] = bf_ra(ord,i,pol_anz,knot,weigh,u_par);
     break;
   }

   lam_x = 0.0;
   lam_y = 0.0;
   lam_z = 0.0;

   for ( i=t_min ; i<t_max+1 ; i++ ) { 
    lam_x = lam_x + vec_x[i]*bf[i];
    lam_y = lam_y + vec_y[i]*bf[i];
    lam_z = lam_z + vec_z[i]*bf[i];
   }

   if ( fabs(vek_x)<MMIN )
    lam_x = 0;
   else
    lam_x = vek_x/lam_x;
   if ( fabs(vek_y)<MMIN )
    lam_y = 0;
   else 
    lam_y = vek_y/lam_y;
   if ( fabs(vek_z)<MMIN )
    lam_z = 0;  
   else
    lam_z = vek_z/lam_z;

   for ( i=0 ; i<pol_anz ; i++ ) {
    vec_x[i] = 0.0;
    vec_y[i] = 0.0;
    vec_z[i] = 0.0;
   }

   p_str = p_s-n_anf+1;
   if ( p_str<bed_a )
    p_str=bed_a;
   p_end = p_s+n_end+m_p-2;
   if ( pol_anz-bed_e-1<p_end )
    p_end = pol_anz-bed_e-1;
   if ( MMIN<pot_a ) {
    for ( i=p_str ; i<p_s+1 && i<p_end+1 ; i++ )  {
     tmp = (p_par[i]-p_par[p_s-n_anf])/(u_par-p_par[p_s-n_anf]);
     vec_x[i] = lam_x*vek_x*pow(tmp,pot_a);
     vec_y[i] = lam_y*vek_y*pow(tmp,pot_a);
     vec_z[i] = lam_z*vek_z*pow(tmp,pot_a);
    }
   } else {
    for ( i=p_str ; i<p_s+1 ; i++ ) {
     vec_x[i] = lam_x*vek_x;
     vec_y[i] = lam_y*vek_y;
     vec_z[i] = lam_z*vek_z;
    }  
   }

   if ( MMIN<pot_e ) {
    for ( i=p_s+1 ; i<p_end+1 ; i++ ) {
     tmp = (p_par[p_end+1] - p_par[i])/(p_par[p_end+1] - u_par);
     vec_x[i] = lam_x*vek_x*pow(tmp,pot_e);
     vec_y[i] = lam_y*vek_y*pow(tmp,pot_e);
     vec_z[i] = lam_z*vek_z*pow(tmp,pot_e);
    }
   } else {
    for ( i=p_s+1 ; i<p_end+1 ; i=i+1 ) {
     vec_x[i] = lam_x*vek_x;
     vec_y[i] = lam_y*vek_y;
     vec_z[i] = lam_z*vek_z;
    }
   }

  switch ( ratio ) {

     case ( NON_RATIONAL ): 
    for ( i=0 ; i<pol_anz ; i++ ) {
     *(pole+3*i)   = *(pol_x+i) + *(vec_x+i);
     *(pole+3*i+1) = *(pol_y+i) + *(vec_y+i);
     *(pole+3*i+2) = *(pol_z+i) + *(vec_z+i);
    }
   break;

   default:
   case ( RATIONAL ):
    for ( i=0 ; i<pol_anz ; i++ ) {
     *(ugpole+3*i)   = *(pol_x+i) + *(vec_x+i);
     *(ugpole+3*i+1) = *(pol_y+i) + *(vec_y+i);
     *(ugpole+3*i+2) = *(pol_z+i) + *(vec_z+i);
     *(pole+3*i)   = *(ugpole+3*i) * *(weigh+i);
     *(pole+3*i+1) = *(ugpole+3*i+1) * *(weigh+i);
     *(pole+3*i+2) = *(ugpole+3*i+2) * *(weigh+i);
    }

   break;
  }

 Build_buffers:

    *num_buffers = 1;
    buf_i = 0;
    crv->poles = pole;
    infos->dyn_elements[buf_i].dis_att = &default_display;
    infos->dyn_elements[buf_i].geometry.bspcurve = crv;
    buffers[buf_i] = &infos->dyn_elements[buf_i];
    buf_i++;
/* bug fix ,report from vdo, no 2.7.1, 8/10/97 */
/* position of influence boundaries for rational curves is weigh dependent */
    if(ratio == NON_RATIONAL) {
      infos->bpoints[0] = pole[3*(p_str-1)];
      infos->bpoints[1] = pole[3*(p_str-1)+1];
      infos->bpoints[2] = pole[3*(p_str-1)+2];
      infos->bpoints[3] = pole[3*(p_end+1)];
      infos->bpoints[4] = pole[3*(p_end+1)+1];
      infos->bpoints[5] = pole[3*(p_end+1)+2];
      } else {
      infos->bpoints[0] = pole[3*(p_str-1)] / weigh[p_str-1];
      infos->bpoints[1] = pole[3*(p_str-1)+1] / weigh[p_str-1];
      infos->bpoints[2] = pole[3*(p_str-1)+2] / weigh[p_str-1];
      infos->bpoints[3] = pole[3*(p_end+1)] / weigh[p_end+1];
      infos->bpoints[4] = pole[3*(p_end+1)+1] / weigh[p_end+1];
      infos->bpoints[5] = pole[3*(p_end+1)+2] / weigh[p_end+1];
    }
    /*infos->dyn_elements[buf_i].geometry.point_set->num_points = 2;    
    infos->dyn_elements[buf_i].geometry.point_set->points = &bpole[0];*/
    buffers[buf_i] = &infos->dyn_elements[buf_i];
    *num_buffers += 1;


   if(infos->polygon) {
     buf_i++;
     infos->dyn_elements[buf_i].geometry.point_set->num_points = crv->num_poles;    
     if(ratio)
       infos->dyn_elements[buf_i].geometry.point_set->points = ugpole;
     else
       infos->dyn_elements[buf_i].geometry.point_set->points = pole;
     *num_buffers += 1;
   
   }
    

   if(hedgehog ) {
     buf_i++;
     infos->dyn_elements[buf_i].geometry.polyline->num_points = 2 * ANZ_NORM;
     /*pline.num_points = 2*ANZ_NORM;
     pline.points = &ppt[0];*/

     udel = 1.0 / (IGRdouble)(ANZ_NORM-1);
     ND = 2;
     max = 0;
     tmp_a = ev_bound = bound = 0;

     /* hedgehog active */
     for ( j=0 ; j<ANZ_NORM ; j++ ) {
      tmp_a = (double)(j)*udel;
      BScveval(crv,tmp_a,ND,&d_l[0],&rc);

      mx = *(d_l+3)* *(d_l+3) + *(d_l+4) * *(d_l+4) + *(d_l+5) * *(d_l+5);
      my = *(d_l+6)* *(d_l+6) + *(d_l+7) * *(d_l+7) + *(d_l+8) * *(d_l+8);
      mz = *(d_l+3)* *(d_l+6) + *(d_l+4) * *(d_l+7) + *(d_l+5) * *(d_l+8);

      *(rho+j) = sqrt(fabs( mx*my - mz*mz ) / ( mx*mx*mx ));
      if ( max < *(rho+j) )
       max = *(rho+j);

      mx = *(d_l+4) * *(d_l+8) - *(d_l+5) * *(d_l+7);
      my = *(d_l+5) * *(d_l+6) - *(d_l+3) * *(d_l+8);
      mz = *(d_l+3) * *(d_l+7) - *(d_l+4) * *(d_l+6);

      *(nx+j) = my* *(d_l+5)-mz* *(d_l+4);
      *(ny+j) = mz* *(d_l+3)-mx* *(d_l+5);
      *(nz+j) = mx* *(d_l+4)-my* *(d_l+3);

      *(p_x+j) = *(d_l+0);
      *(p_y+j) = *(d_l+1);
      *(p_z+j) = *(d_l+2);
    }
   /* hedgehog is active */
   ppt =  infos->dyn_elements[buf_i].geometry.polyline->points;
   for ( j=0 ; j < ANZ_NORM ; j++ ) {
    tmp_a = sqrt(*(nx+j)* *(nx+j)+ *(ny+j)* *(ny+j)+ *(nz+j)* *(nz+j));
    j6 = 6 * j;
    *(ppt+j6) = *(p_x+j);
    *(ppt+j6+1) = *(p_y+j);
    *(ppt+j6+2) = *(p_z+j);
    /*printf("rho[j]/max =  %f  nx[j]/tmp_a = %f\n", rho[j]/max, nx[j]/tmp_a);
    printf("rho[j]/max =  %f  ny[j]/tmp_a = %f\n", rho[j]/max, ny[j]/tmp_a);
    printf("rho[j]/max =  %f  nz[j]/tmp_a = %f\n", rho[j]/max, nz[j]/tmp_a);*/
    *(ppt+j6+3) = *(ppt+j6) - d * rho[j]/max * nx[j]/tmp_a;
    *(ppt+j6+4) = *(ppt+j6+1) - d * rho[j]/max * ny[j]/tmp_a;
    *(ppt+j6+5) = *(ppt+j6+2) - d * rho[j]/max * nz[j]/tmp_a;
   }
    *num_buffers += 1;
    infos->dyn_elements[buf_i].dis_att = &default_display;
    buffers[buf_i] = &infos->dyn_elements[buf_i];
   }

   else if(curvature ) {
     buf_i++;
     infos->dyn_elements[buf_i].geometry.polyline->num_points = ANZ_NORM;
     /*pline.num_points = ANZ_NORM;
     pline.points = &ppt[0];*/

     udel = 1.0 / (IGRdouble)(ANZ_NORM-1);
     ND = 2;
     max=0;
     tmp_a = ev_bound = bound = 0;

     /* Curvature active */
     for ( j=0 ; j<ANZ_NORM ; j++ ) {
      tmp_a = (double)(j)*udel;
      BScveval(crv,tmp_a,ND,&d_l[0],&rc);

      mx = *(d_l+3)* *(d_l+3) + *(d_l+4) * *(d_l+4) + *(d_l+5) * *(d_l+5);
      my = *(d_l+6)* *(d_l+6) + *(d_l+7) * *(d_l+7) + *(d_l+8) * *(d_l+8);
      mz = *(d_l+3)* *(d_l+6) + *(d_l+4) * *(d_l+7) + *(d_l+5) * *(d_l+8);

      *(rho+j) = sqrt(fabs( mx*my - mz*mz ) / ( mx*mx*mx ));
      if ( max < *(rho+j) )
       max = *(rho+j);

      mx = *(d_l+4) * *(d_l+8) - *(d_l+5) * *(d_l+7);
      my = *(d_l+5) * *(d_l+6) - *(d_l+3) * *(d_l+8);
      mz = *(d_l+3) * *(d_l+7) - *(d_l+4) * *(d_l+6);

      *(nx+j) = my* *(d_l+5)-mz* *(d_l+4);
      *(ny+j) = mz* *(d_l+3)-mx* *(d_l+5);
      *(nz+j) = mx* *(d_l+4)-my* *(d_l+3);

      *(p_x+j) = *(d_l+0);
      *(p_y+j) = *(d_l+1);
      *(p_z+j) = *(d_l+2);
    }
   /* curvature is active */
   ppt =  infos->dyn_elements[buf_i].geometry.polyline->points;
   for ( j=0 ; j < ANZ_NORM ; j++ ) {
    tmp_a = sqrt(*(nx+j)* *(nx+j)+ *(ny+j)* *(ny+j)+ *(nz+j)* *(nz+j));
    j6 = 3 * j;
    *(ppt+j6) =  *(p_x+j) - d * rho[j]/max * nx[j]/tmp_a;
    *(ppt+j6+1) = *(p_y+j) - d * rho[j]/max * ny[j]/tmp_a;
    *(ppt+j6+2) = *(p_z+j) - d * rho[j]/max * nz[j]/tmp_a;
   }
    *num_buffers += 1;
    infos->dyn_elements[buf_i].dis_att = &help_display;
    buffers[buf_i] = &infos->dyn_elements[buf_i];
 }

 if(distance && infos->ls_found) {
  buf_i++;
  dist_max = 0.0;
  distp =  infos->dyn_elements[buf_i].geometry.polyline->points;


  Quick_project(crv, *infos->nvx, infos->vx, infos->cv_pts, &j_max, &dist_max, (IGRlong *) &rc);

  /* Only the normal at global max is wanted */ 

  
    if(dist_max != 0.0) {

      j3 = 3*j_max;
      mx = *(infos->cv_pts+j3+X) - *(infos->vx+j3+X);
      my = *(infos->cv_pts+j3+Y) - *(infos->vx+j3+Y);
      mz = *(infos->cv_pts+j3+Z) - *(infos->vx+j3+Z);
    
      *(distp+X) = *(infos->cv_pts+j3+X);
      *(distp+Y) = *(infos->cv_pts+j3+Y);
      *(distp+Z) = *(infos->cv_pts+j3+Z);
      *(distp+X2) =  *(infos->cv_pts+j3+X) + -d*3 /(dist_max*2) * mx;
      *(distp+Y2) =  *(infos->cv_pts+j3+Y) + -d*3 /(dist_max*2) * my;
      *(distp+Z2) =  *(infos->cv_pts+j3+Z) + -d*3 /(dist_max*2) * mz; 
      *num_buffers += 1;
      infos->dyn_elements[buf_i].dis_att = &help_display;
      buffers[buf_i] = &infos->dyn_elements[buf_i];
      *num_buffers += 1; 
      buf_i += 1; 

      sprintf(infos->dyn_elements[buf_i].ele_spec_att.text->text_string,
              "d= %1.3f", dist_max);

      pnt[X] = *(distp+X) + -d*3 /(dist_max*4) * mx;
      pnt[Y] = *(distp+Y) + -d*3 /(dist_max*4) * my;
      pnt[Z] = *(distp+Z) + -d*3 /(dist_max*4) * mz;

      infos->dyn_elements[buf_i].geometry.lbsys->matrix[3] = pnt[X];
      infos->dyn_elements[buf_i].geometry.lbsys->matrix[7] = pnt[Y];
      infos->dyn_elements[buf_i].geometry.lbsys->matrix[11] = pnt[Z];

      infos->dyn_elements[buf_i].dis_att = &default_display;
      buffers[buf_i] = &infos->dyn_elements[buf_i]; 
      
    }
  
  }
 if(distance && (!infos->ls_found))
  ex$message(msgnumb = EMS_I_NoLs);
 
/* bug fix ,report from vdo, no 2.7.1, 8/10/97 */
Buffers_end:

    *infos->px_old = point->x;
    *infos->py_old = point->y;
    *infos->pz_old = point->z;

    if(*infos->ex_cmd_pressed || *infos->ex_pocket_pressed ||
       *infos->idls_req) {
      return(DP_EXIT_DYNAMICS);
    } else
      return(TRUE);
}



method create_curve_dynamics_buffer(IGRlong *msg; IGRint *response2)

{
  
 /* 
    ABSTRACT  dynamic setup function to setup the DPele_header
              for a dynamic bsp curve shape  depending on the 
               cursors position; the cursor position is
              identical with the vectors to-position

 */
    IGRlong stat_OM, msg_loc, ret_stat, stat_func;

    IGRlong 		event_size;
    IGRint          buf_size;
    IGRlong         nbytes_in_buffer;
    IGRlong         nbytes_transferred;
    IGRboolean first;
    enum GRdpmode dpmode;
    IGRint j, k;
    IGRint response, fin_old, beg_old;
    IGRchar 		loc_prompt[54],
                        acc_prompt[54]; 
    IGRchar		ksl;
    short unsigned color;
    IGRuchar weight;
    IGRmatrix rot_matrix;
    enum font_type {seven,eight,sixteen}active_font_type, cur_font_type;
    IGRint dyn_flags = DP_AUTO_DYN; 

    struct DPele_header dcrv_element;   /* display buffer dyn curve */
    struct DPele_header ocrv_element;   /* display buffer orig curve */
    struct DPele_header iline_element;   /* display buffer curvature */
    struct DPele_header dline_element;   /* display buffer distance */
    struct DPele_header ftoln_element;   /* display buffer from-to line */
    struct DPele_header dtext_element;   /* display buffer distance text */
    struct DPele_header poles_element;   /* display buffer pole points */
    struct DPele_header border_element;   /* display buffer border points */
    struct IGRpolyline iline;   /* curvature line geometry */
    struct IGRpolyline dline;   /* distance line geometry */
    struct IGRpolyline ftoln;   /* distance from-to line  geometry */
    struct IGRpointset poles, border; 
    struct IGResps     con_flag;
    IGRdouble ipoints[6*ANZ_NORM];       /* coordinates of line buffer */
    IGRdouble dpoints[6];       /* coordinates of distance line buffer */
    IGRdouble fpoints[6];       /* coordinates of distance from-to line buffer */
    IGRdouble bpoints[6];       /* 2 border points */
    GRobjid               newid;
    struct GRpost_info    pinfo;
    IGRdouble pnt[3], p[3];
    IGRdouble active_angle=0.0;
    /*struct IGRbsp_curve ocrv;*/
    IGRint 		point_size=0;
    IGRdouble 		vwvolume[6];
    IGRdouble           vwmatrix[16];
    IGRdouble		r[6];
    IGRdouble d=0.0;
    struct var_list 	var_list_of[2];
    struct IGRbsp_curve dcrv;
    struct IGRlbsys dtxt_lbsys;
    struct IGResintx text_attr;
    struct IGRestx   dtxt_estx;
    struct IGResbc dcrv_spec_att;
    OM_S_OBJID cur_mod_id;
    GRspacenum cur_mod_osnum;
    struct GRid fontmgr_obj;
    struct vfont_entry  font_info, cur_font_info;
    struct GRdpb_text_symb text_symb;
    struct GRcc_info cc_info;
    struct extents text_extents;
    IGRshort font_id=0, current_font=0, prev_font=0, elem_type=0;
    int sts;

    struct istruct infos;
    struct GRsymbology s;

    /* Active color, style, weight, etc */
    struct IGRdisplay default_display, help_display, point_display, vertex_display, border_display;  

    stat_OM = msg_loc = OM_S_SUCCESS;
    infos.ex_cmd_pressed = &me->ex_cmd_pressed;
    infos.ex_pocket_pressed = &me->ex_pocket_pressed;
    infos.plocp = &me->plocp[0];
     if(me->esc_pressed) {
       me->esc_pressed = FALSE;
       pnt[X] = me->actcurp[X];
       pnt[Y] = me->actcurp[Y];
       pnt[Z] = me->actcurp[Z];
     } else if(me->ex_cmd_pressed || me->ex_pocket_pressed) {
        buf_size = sizeof(struct EX_button);          
         stat_func = ex$getque(
                         msg = &msg_loc,
                         response = &response,
                         byte = &buf_size,
                         buffer = (char *) &me->dyaccev.event.button);
         me->plocp[X] = me->dyaccev.event.button.x;
         me->plocp[Y] = me->dyaccev.event.button.y;
         me->plocp[Z] = me->dyaccev.event.button.z;
     } else {
        pnt[X] = me->accev.event.button.x;
        pnt[Y] = me->accev.event.button.y;
        pnt[Z] = me->accev.event.button.z;
     }

    sts = gr$get_active_display( buffer = &default_display );
    default_display.color = (short unsigned) color;
    default_display.weight = (IGRuchar) weight;
    
    gr$get_active_display( buffer = &help_display );
    help_display.color = (short unsigned)  YELLOW;
    help_display.weight = (IGRuchar) SMALLEST;
    help_display.style = (IGRuchar) DASHED;

    gr$get_active_display( buffer = &point_display );
    point_display.color = (short unsigned) RED;
    if(me->crv->num_poles < WEIGHT_LIMIT)
       point_display.weight = (IGRuchar) (POLE_WEIGHT1 * 2);
    else
       point_display.weight = (IGRuchar) POLE_WEIGHT1;
    point_display.style = (IGRuchar) FULL;
    gr$get_active_display( buffer = &border_display );
    border_display.color = (short unsigned) RED;
    if(me->crv->num_poles < WEIGHT_LIMIT)
       border_display.weight = (IGRuchar) (POLE_WEIGHT1 * 4);
    else
       border_display.weight = (IGRuchar) (POLE_WEIGHT1 * 2);
    point_display.style = (IGRuchar) FULL;


    me->infos = &infos;
    
    iline.points = &ipoints[0];
    iline.num_points = 2*ANZ_NORM;

    dline.points = &dpoints[0];
    dline.num_points = 2;

    ftoln.points = &fpoints[0];
    ftoln.num_points = 2;

    border.points = &bpoints[0];
    border.num_points = 2;


    if(me->cursor_sensitivity)
      me->cms = CURSOR_SENS1;
    else 
      me->cms = CURSOR_SENS0;
    first = FALSE;


    /* fill info structure */
    infos.bpoints = bpoints;
    infos.md_env = &me->md_env;
    infos.my_id = my_id; 
    fin_old = beg_old = -1;
    infos.fin_old = &fin_old;
    infos.beg_old = &beg_old;
    infos.common_dist = &me->common_dist;
    infos.idls_req = &me->idls_req;
    infos.prodist = &me->prodist;
    infos.first = &first;
    infos.point_t = &me->point_t[0];
    infos.mark_px = &me->mark_px;
    infos.mark_py = &me->mark_py;
    infos.mark_pz = &me->mark_pz;
    infos.keep_planar = &me->keep_planar;
    infos.plane = &me->plane;
    infos.ls_found = me->ls_found;
    infos.polygon = me->show_poles;
    infos.n_anf = &me->n_anf;
    infos.n_end = &me->n_end;
    infos.bed_a = &me->bed_a;
    infos.bed_e = &me->bed_e;
    infos.range_mode = &me->range_mode;
    infos.shape_mode = &me->shape_mode;
    if(me->symetric) {
      me->range = SYMETRIC;
      me->shape = SYMETRIC;
      infos.range = &me->range;
      infos.shape = &me->shape;
    } else if(me->left) {
      me->range = ANFANG;
      me->shape = ANFANG;
      infos.range = &me->range;
      infos.shape = &me->shape;
    } else if(me->right) {
      me->shape = ENDE;
      me->range = ENDE;
      infos.range = &me->range;
      infos.shape = &me->shape;
    }
    infos.shape_amount_left = &me->shape_amount_left;
    infos.shape_amount_right = &me->shape_amount_right;
    infos.cms = &me->cms;
    infos.px_old = &me->px_old;
    infos.py_old = &me->py_old;
    infos.pz_old = &me->pz_old;
    
    infos.fromto = me->fromto;
    infos.distance = me->show_distance;
    infos.curvature = me->show_curvature;
    infos.hedgehog = me->show_hedgehog;
    infos.knot = me->knot;
    infos.smfac = &me->smfac;
    infos.smooth = &me->smooth;
    infos.pols_x = me->pols_x;
    infos.pols_y = me->pols_y;
    infos.pols_z = me->pols_z;
    infos.pol_x = me->pol_x;
    infos.pol_y = me->pol_y;
    infos.pol_z = me->pol_z;
    infos.vec_x = me->vec_x;
    infos.vec_y = me->vec_y;
    infos.vec_z = me->vec_z;
    infos.l_vek = &me->l_vek;
    infos.bf    = me->bf;
    infos.p_par = me->p_par;
    infos.weigh = me->weigh;
    infos.pole  = me->pole;
    infos.ugpole  = me->ugpole;
    infos.pnt_lot[X] = me->accev.event.button.x;
    infos.pnt_lot[Y] = me->accev.event.button.y;
    infos.pnt_lot[Z] = me->accev.event.button.z;
    me->point_t[X] = me->accev.event.button.x;
    me->point_t[Y] = me->accev.event.button.y;
    me->point_t[Z] = me->accev.event.button.z;
    me->px_old = me->pnt_lot[X];
    me->py_old = me->pnt_lot[Y];
    me->pz_old = me->pnt_lot[Z];
    infos.p_s = &me->p_s;
    infos.m_p = &me->m_p;
    infos.p_min = &me->p_min;
    infos.p_max = &me->p_max;
    infos.t_min = &me->t_min;
    infos.t_max = &me->t_max;
    infos.u_par = &me->u_par;
    infos.nvx = &me->nvx;
    infos.vx  = me->vx;
    infos.par_vec = me->par_vec;
    infos.cv_pts = me->cv_pts;
    infos.dists = me->dists;
    infos.ocrv = me->crv;
    k=0;
    infos.opole = me->opole;
    dcrv = *me->crv;
    infos.dyn_elements[k++].geometry.bspcurve = &dcrv;
    

    /*
       * get default display symbology from Default Parameter Block (DPB)
       * and then go on to next command state
    */
    /*if(me->show_distance) {*/
      /* get the necessary information to display text in dynamics */

      ex$get_cur_mod(osnum = &cur_mod_osnum,
                   id    = &cur_mod_id);

      ex$get_super(mod_id = cur_mod_id,
                 mod_osnum = cur_mod_osnum,
                 super_name = FONTMGR_NO_NAME,
                 create = TRUE,
                 super_class = "GRfm",
                 super_id = &fontmgr_obj.objid,
                 super_osnum = &fontmgr_obj.osnum);

      nbytes_in_buffer = sizeof(text_symb);
      gr$get_text_symb(msg = &msg_loc,
                        sizbuf = &nbytes_in_buffer,
                        buffer = &text_symb,
                        nret = &nbytes_transferred);
      stat_OM = om$send(msg = message GRfm.GRfm_retdata(
                            &msg_loc,
                            &text_symb.Active_font,
                            &font_info),
                      targetid = fontmgr_obj.objid,
                      targetos = fontmgr_obj.osnum);

     if (font_info.flags & SIXTEEN_BIT) 
       active_font_type = sixteen;
     else if (font_info.flags & EIGHT_BIT) 
       active_font_type = eight;
     else 
       active_font_type = seven;
     


     cur_font_info = font_info;
     prev_font = -1;                 /* no previous font */
     current_font = text_symb.Active_font;

     elem_type = IGRLB;
     text_attr.estx = &dtxt_estx;
     text_attr.font_id = cur_mod_osnum;
     text_attr.flags = 0;
     text_attr.prev_font = text_symb.Active_font;
     text_attr.estx->font = text_symb.Active_font;
     text_attr.estx->just = text_symb.Active_just;
     text_attr.estx->width = text_symb.Active_width;
     text_attr.estx->height = text_symb.Active_height;
     text_attr.estx->flag = text_symb.Active_flags;
     text_attr.estx->num_char = 0;
     text_attr.estx->line_spac = text_symb.Active_linespac;
     text_attr.estx->char_spac = text_symb.Active_charspac;
     text_attr.estx->text_length = 8;
     text_attr.text_string = (IGRchar *) me->text_string;

     /*
     * initialize the structure that contains the current char information;
     * find info at the end of the text string
     */

     sprintf( me->text_string,"d= 0.0   ");

     nbytes_in_buffer = sizeof(active_angle);
     gr$get_active_angle(msg = &msg_loc,
                        sizbuf = &nbytes_in_buffer,
                        buffer = &active_angle,
                        nret = &nbytes_transferred);
     for(j=0;j<16;j++)
       rot_matrix[j] = 0;
     rot_matrix[0] = rot_matrix[5] = rot_matrix[10] = rot_matrix[15] = 1;

     /* determine view matrix */

     var_list_of[0].var = WLD_TO_VIEW;
     var_list_of[0].var_ptr =  (IGRchar *) vwmatrix;
     var_list_of[0].num_bytes = sizeof (IGRdouble) * 16;
     var_list_of[0].bytes_returned = (IGRlong *) &ret_stat;
     var_list_of[1].var = END_PARAM;


     stat_OM = dp$inq_set_gragad (msg = &msg_loc,
                                 gragad_objid = me->locate_stack.window.objid,
                                 osnum = me->locate_stack.window.osnum,
                                 which_error = &ret_stat,
                                 var_list = var_list_of);
     TEST_ERROR(stat_OM,msg_loc,"inq_set_gragad", function_end);

     vwmatrix[3] = vwmatrix[7] = 0;
     GRcreate_lbs(&msg_loc,
                  &active_angle,
                  vwmatrix,
                  &pnt[X],
                  &text_extents,
                  &dtxt_lbsys);

 /* }*/


     /* determine range box */

     var_list_of[0].var = VW_VOLUME;
     var_list_of[0].var_ptr =  (IGRchar *) vwvolume;
     var_list_of[0].num_bytes = sizeof (IGRdouble) * 6;
     var_list_of[0].bytes_returned = (IGRlong *) &ret_stat;
     var_list_of[1].var = END_PARAM;

     /* get view volume  */
     stat_OM = dp$inq_set_gragad (msg = &msg_loc,
                                 gragad_objid = me->locate_stack.window.objid,
                                 osnum = me->locate_stack.window.osnum,
                                 which_error = &ret_stat,
                                 var_list = var_list_of);
     TEST_ERROR(stat_OM,msg_loc,"inq_set_gragad", function_end);

     point_size = sizeof(IGRpoint);

     OM_BLOCK_MOVE(&vwvolume[X], &r[X], point_size);
     OM_BLOCK_MOVE(&vwvolume[X2], &r[X2], point_size);
        
     /* Compute range */
     /* the arrow length should be 1/10 of the window diagonal
     function EFdraw_vector_on_screen already takes 1/4 of 
     diagonal, so multiply upper corner by RANGE_DIV */

     /*r[X2] = r[X] + ((r[X2] - r[X]) * RANGE_DIV); 
     r[Y2] = r[Y] + ((r[Y2] - r[Y]) * RANGE_DIV);
     r[Z] = r[Z2] = 0.0; 
     r[Z2] = r[Z] + ((r[Z2] - r[Z]) * RANGE_DIV); */

     d = sqrt(((r[X2]-r[X])*(r[X2]-r[X]))+((r[Y2]-r[Y])*(r[Y2]-r[Y])));
     d = d/10;
   
     infos.d = &d;

     text_attr.estx->width = d/6;
     text_attr.estx->height = d/6;

  L1:    
/* switch curve display on, polygon display on */
    if(me->show_poles)
      dcrv_spec_att.is_polydis = TRUE;
    else
      dcrv_spec_att.is_polydis = FALSE;
    dcrv_spec_att.is_curvedis = TRUE;
    dpmode  = GRbd;
    stat_OM = om$send(mode = OM_e_wrt_object,
                    msg = message GRgraphics.GRdisplay (
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode, 
                          &me->md_env.md_id),
                    senderid = my_id,
                    targetid = me->cv_info.located_obj.objid,
                    targetos = me->cv_info.located_obj.osnum);

    /* Put together our display buffer for the dyn curve */
    k=0;
    dp$build_dis_buffer(
        buffer = (&infos.dyn_elements[k]),
        display_att = &default_display,
        geometry = &dcrv,
        ele_spec_att = &dcrv_spec_att,
        type = IGRBC);
    /* put together ther border points of the active range */
       k++;
       infos.dyn_elements[k].geometry.point_set = &border;
       con_flag.is_connected = FALSE;
       dp$build_dis_buffer(
          buffer = (&infos.dyn_elements[k]),
          display_att = &border_display,
          geometry = &border,
          ele_spec_att = &con_flag,
          type = IGRPS);
       
    /* Put together our display buffer for polygone points */
     if(me->show_poles) {
       k++;
       poles.num_points = me->crv->num_poles;
       if(me->crv->rational)
         poles.points = me->ugpole;
       else
         poles.points = me->pole;
       infos.dyn_elements[k].geometry.point_set = &poles;
       con_flag.is_connected = FALSE;
       dp$build_dis_buffer(
          buffer = (&infos.dyn_elements[k]),
          display_att = &point_display,
          geometry = &poles,
          ele_spec_att = &con_flag,
          type = IGRPS);
     }

    /* Put together our display buffer for the curvature ls */
    if(me->show_hedgehog || me->show_curvature) {
     k++;
     infos.dyn_elements[k].geometry.polyline = &iline;
     dp$build_dis_buffer(
        buffer = (&infos.dyn_elements[k]),
        display_att = &help_display,
        geometry = &iline,
        type = IGRPY);
    }
    /* Put together our display buffer for the distance ls */
    if(me->show_distance) {
     k++;
     infos.dyn_elements[k].geometry.polyline = &dline;
     dp$build_dis_buffer(
        buffer = (&infos.dyn_elements[k]),
        display_att = &help_display,
        geometry = &dline,
        type = IGRPY);


    /* Put together our display buffer for the distance text */
     k++;
     infos.dyn_elements[k].geometry.lbsys = &dtxt_lbsys;
     dp$build_dis_buffer(
        buffer = (&infos.dyn_elements[k]),
        display_att = &default_display,
        geometry = &dtxt_lbsys,
        ele_spec_att = &text_attr,
        type = IGRLB);
    }
    /* Start the dynamics display */
    me->dynamic = TRUE;
    dp$dynamics(dyn_fun = Create_curve_dynamics_function,
                information = &infos);

    strcpy(loc_prompt," ");
    strcpy(acc_prompt," ");
    if(me->idls_req) {
      me->idls_req = FALSE;
      ME.super_cmd->state = GET_LINESTRING;
      if(me->optform_requested)
         FIg_set_state_on(me->optform, S_IDLS_B);
      me->old_command = MAIN_PROCESS;
      goto function_end;
    }
    if(me->ex_cmd_pressed) {
      me->ex_cmd_pressed = FALSE;    
      event_size = sizeof(struct EX_button);          
      response = EX_DATA;
      stat_func = ex$putque(
                    msg = &msg_loc,
                    pos = FRONT,
                    response = &response,
                    byte = &event_size,
                    buffer = (char *) &me->dyaccev.event.button);
    }
    if(me->ex_pocket_pressed) {
      me->ex_pocket_pressed = FALSE;
      event_size = sizeof(struct EX_button);          
      response = EX_DATA;
      stat_func = ex$putque(
                    msg = &msg_loc,
                    pos = FRONT,
                    response = &response,
                    byte = &event_size,
                    buffer = (char *) &me->dyaccev.event.button);
    }

    stat_func = co$getevent(
                  msg = &msg_loc,
                  mode = EX_ALL_CHAR_MODE | EX_LINE_MODE,
                  event_mask = (/*GRm_CHAR | */
                                GRm_STRING |
                                GRm_DATA | 
                                GRm_RJT_MOVEON | 
                                GRm_BACK_UP),
                  prompt = loc_prompt,
                  response = me->response,
                  response_data = me->response_data,
                  event = &me->dyaccev);
    me->XXXXX = 9080;
    /*switch(me->dyaccev.response) {*/
    switch(*me->response) {

    case EX_DATA:
#if dflT1
  printf("in EX_DATA\n");
#endif
       dpmode  = GRbe;
       stat_OM = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRdisplay (
                               &msg_loc,
                               &me->md_env.md_env.matrix_type,
                               me->md_env.md_env.matrix,
                               &dpmode, 
                               &me->md_env.md_id),
                         senderid = my_id,
                         targetid = me->cv_info.located_obj.objid,
                         targetos = me->cv_info.located_obj.osnum);

       for(j=0;j<me->crv->num_poles*3;j++)
         me->crv->poles[j] = me->pole[j];
       GRabsg_del_all();
       stat_OM = om$send(msg = message GRvg.GRpostabsg(&msg_loc,
                               &me->cv_info.module_info, &pinfo,
                               (IGRchar *) me->crv, &newid),
                         senderid = NULL_OBJID,
                         targetid = me->cv_info.located_obj.objid,
                         targetos = me->cv_info.located_obj.osnum);
       TEST_ERROR(stat_OM,msg_loc,"GRpostabsg",function_end);
              
       dpmode  = GRbd;
       stat_OM = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRdisplay (
                               &msg_loc,
                               &me->md_env.md_env.matrix_type,
                               me->md_env.md_env.matrix,
                               &dpmode, 
                               &me->md_env.md_id),
                         senderid = my_id,
                         targetid = me->cv_info.located_obj.objid,
                         targetos = me->cv_info.located_obj.osnum);
       me->dynamic = FALSE;
       if(!me->fromto)
          me->command = ME.super_cmd->state = GET_TO_POINT;
       else
          me->command = ME.super_cmd->state = GET_FROM_POINT;

       goto function_end;


    case EX_RJT_MOVEON:
#if dflT1
  printf("in EX_RJT_MOVEON\n");
#endif
       dpmode  = GRbd;
       stat_OM = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRdisplay (
                               &msg_loc,
                               &me->md_env.md_env.matrix_type,
                               me->md_env.md_env.matrix,
                               &dpmode, 
                               &me->md_env.md_id),
                         senderid = my_id,
                         targetid = me->cv_info.located_obj.objid,
                         targetos = me->cv_info.located_obj.osnum);
       me->dynamic = FALSE;
       if(!me->fromto)
          me->command = ME.super_cmd->state = GET_TO_POINT;
       else
          me->command = ME.super_cmd->state = GET_FROM_POINT;
       goto function_end;

    case EX_BACK_UP:
              
       dpmode  = GRbd;
       stat_OM = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRdisplay (
                               &msg_loc,
                               &me->md_env.md_env.matrix_type,
                               me->md_env.md_env.matrix,
                               &dpmode, 
                               &me->md_env.md_id),
                         senderid = my_id,
                         targetid = me->cv_info.located_obj.objid,
                         targetos = me->cv_info.located_obj.osnum);
       me->dynamic = FALSE;
       me->command = ME.super_cmd->state = GET_CURVE;
       goto function_end;

    
    case EX_CHAR:
            ksl = me->response_data[0];
            me->dyaccev.event.keyin[0] = '\0';
            me->dyaccev.event.keyin[1] = '\013';
            GRput_keybuff(me->dyaccev.event.keyin);
            if(ksl == ESC) {
#if dflT1
  printf("in ESC\n");
#endif
                me->accev.event.keyin[0] = '\033';
                me->accev.event.keyin[1] = '\0';
                GRput_keybuff(me->accev.event.keyin);
                ex$message(field=KEYIN_FIELD,msgnumb=EMS_I_escape);
              /* save infos */

                me->actcurp[X] = me->dyaccev.event.button.x;
                me->actcurp[Y] = me->dyaccev.event.button.y;
                me->actcurp[Z] = me->dyaccev.event.button.z;
                me->esc_pressed = TRUE;
                me->old_command = MAIN_PROCESS;
                ME.super_cmd->state = me->command = EXECUTE_COMMAND;
                goto function_end;
             }

            switch(ksl) {

            case PRODIST:
                if(me->optform_requested) 
                  FIg_set_state_on(me->optform, S_PRODIST_B); 
                stat_func = get_projection_dist(
                             &msg_loc, &me->common_dist, &me->prodist);
                if(me->optform_requested) {
                 FIg_set_value(me->optform, S_PRODIST_F, me->prodist); 
                 FIg_set_state_off(me->optform, S_PRODIST_B); 
	        }

                break;

            case SMOOTH:
              if(me->smooth) {
                me->smooth = FALSE;
                if(me->optform_requested)
                  FIg_set_state_off(me->optform, S_SMOOTH_B);
              } else {
                me->smooth = TRUE;
                if(me->optform_requested)
                   FIg_set_state_on(me->optform, S_SMOOTH_B);
              }
              break;

            case LESS:
              if(me->smooth) {
                if(me->smfac > 0)
                 me->smfac -= 0.01;
                 if(me->optform_requested)
                    FIg_set_value(me->optform,S_SMFAC_F,(IGRdouble)
                              me->smfac);
              }
              break;
                
            case GREAT:
              if(me->smooth) {
                 me->smfac += 0.01;
                 if(me->optform_requested)
                    FIg_set_value(me->optform,S_SMFAC_F,(IGRdouble)
                              me->smfac);
              }
              break;
                
            case MARK:
              if(me->mark_point_id.objid) {
                 gr$delete_object(msg = &msg_loc,
                    md_env = NULL,
                    object_id = &me->mark_point_id);
              }
              p[X] = me->mark_px;
              p[Y] = me->mark_py;
              p[Z] = me->mark_pz;
              gr$place_linear_object(msg = &msg_loc,
                        md_env = NULL,
                        num_points = 1,
                        points = p,
                        object_id = &me->mark_point_id,
                        name = NULL,
                        display_flag = 0);
              gr$get_symbology (object_id = &me->mark_point_id,
                   symb = &s);
              s.display_attr.weight = (IGRuchar) 3;
              gr$put_symbology (object_id = &me->mark_point_id,
                   symb = &s);
              gr$display_object (object_id = &me->mark_point_id,
                    md_env = NULL,
                    mode = GRbd);

              break;

            case OPTIONS:
              if(me->optform_requested) {
                me->optform_requested = FALSE;
                FIf_get_location(me->optform,&me->fxpos, &me->fypos);
                ret_stat = FIf_erase(me->optform);
              } else {
                stat_OM = om$send(msg = message ECascvmd.status_disp(),
                                  targetid = my_id);
              }
              goto L1;


            case STPT:
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_STARTPT_B);
                  FIg_set_state_off(me->optform, S_ENDPT_B);
                }
                me->set_stpt = TRUE;
                me->set_ept = FALSE;

              goto L1;

            case EPT:
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_ENDPT_B);
                  FIg_set_state_off(me->optform, S_STARTPT_B);
                }
                me->set_ept = TRUE;
                me->set_stpt = FALSE;

              goto L1;

            case FIX:
              if(me->set_stpt) {
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_SFIX_B);
                  FIg_set_state_off(me->optform, S_STARTPT_B);
                }
                me->stfix = TRUE;
                me->stfree = FALSE;
                me->stta = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 1;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_EFIX_B);
                  FIg_set_state_off(me->optform, S_ENDPT_B);
                }
                me->efix = TRUE;
                me->efree = FALSE;
                me->ecrv = FALSE;
                me->eta = FALSE;
                me->bed_e = 1;
              }
              goto L1;

            case FREE:
              if(me->set_stpt) {
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_SFREE_B);
                  FIg_set_state_off(me->optform, S_STARTPT_B);
                }
                me->stfree = TRUE;
                me->stfix = FALSE;
                me->stta = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 0;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_EFREE_B);
                  FIg_set_state_off(me->optform, S_ENDPT_B);
                }
                me->efree = TRUE;
                me->efix = FALSE;
                me->ecrv = FALSE;
                me->eta = FALSE;
                me->bed_e = 0;
              }
              goto L1;

            case TANGENT:
              if(me->set_stpt) {
                if(me->optform_requested) {
                  FIg_set_state_on(me->optform, S_STA_B);
                  FIg_set_state_off(me->optform, S_STARTPT_B);
                }
                me->stta = TRUE;
                me->stfree = FALSE;
                me->stfix = FALSE;
                me->stcrv = FALSE;
                me->bed_a = 2;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                  FIg_set_state_off(me->optform, S_ENDPT_B);
                  FIg_set_state_on(me->optform, S_ETA_B);
                }
                me->eta = TRUE;
                me->efree = FALSE;
                me->efix = FALSE;
                me->ecrv = FALSE;
                me->bed_e = 2;
              }
              goto L1;

            case CURVA:
              if(me->set_stpt) {
                if(me->optform_requested) {
                  FIg_set_state_off(me->optform, S_STARTPT_B);
                  FIg_set_state_on(me->optform, S_SCURV_B);
                }
                me->stcrv = TRUE;
                me->stfree = FALSE;
                me->stfix = FALSE;
                me->stta = FALSE;
                me->bed_a = 3;
              } else if(me->set_ept) {
                if(me->optform_requested) {
                  FIg_set_state_off(me->optform, S_ENDPT_B);
                  FIg_set_state_on(me->optform, S_ECURV_B);
                }
                me->ecrv = TRUE;
                me->efree = FALSE;
                me->efix = FALSE;
                me->eta = FALSE;
                me->bed_e = 3;
              }
              goto L1; 


            case FINIS:
              me->dynamic = FALSE;
              ME.super_cmd->state = FINISH;
              goto function_end;

            case SHAPE:
                 me->XXXXX= 1333;
                 me->shape_mode = TRUE;
                 me->range_mode = FALSE;
                 me->shape = me->range;
                 if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_SHAPE_B);
                   FIg_set_state_off(me->optform, S_RANGE_B);
                 }
                 goto L1;
 

            case RANGE:
                 me->XXXXX= 1444;
                 me->range_mode = TRUE;
                 me->shape_mode = FALSE;
                 me->range = me->shape;
                 if(me->optform_requested) {
                   FIg_set_state_on(me->optform, S_RANGE_B);
                   FIg_set_state_off(me->optform, S_SHAPE_B);
                 }
                 goto L1;

	    case SYMETRIC:
               if(me->shape_mode) 
                 me->shape = SYMETRIC;
               
               if(me->range_mode) 
                 me->range = SYMETRIC;

               me->symetric = TRUE;
               if(me->optform_requested) 
               FIg_set_state(me->optform, S_SYM_B,TRUE);
	       
               goto L1;

	    case ANFANG:
               if(me->shape_mode) 
                 me->shape = ANFANG;

               if(me->range_mode) 
                 me->range = ANFANG;

               me->left = TRUE;
               if(me->optform_requested) 
                 FIg_set_state(me->optform, S_LEFT_B,TRUE);
               
               goto L1;

	    case ENDE:
               if(me->shape_mode) 
                  me->shape = ENDE;
               if(me->range_mode) 
                  me->range = ENDE;
               

               me->right = TRUE;
               if(me->optform_requested) 
                 FIg_set_state(me->optform, S_RIGHT_B,TRUE);
               
               goto L1;

	    case MINUS:
               if(me->shape_mode) {
                 if(me->shape == SYMETRIC
                 && me->shape_amount_left > SHAPE_MIN) {
                        me->shape_amount_left -= 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
                              me->shape_amount_left);
		 }
                 if(me->shape == SYMETRIC
                      &&me->shape_amount_right > SHAPE_MIN) {
                        me->shape_amount_right -= 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
                              me->shape_amount_right);
		 }
                 if(me->shape == ANFANG 
                      &&  me->shape_amount_left > SHAPE_MIN) {
                        me->shape_amount_left -= 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
                              me->shape_amount_left);
		 }
                 else if(me->shape == ENDE  
                      &&me->shape_amount_right > SHAPE_MIN) {
                        me->shape_amount_right -= 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
                              me->shape_amount_right);
		 }
               }
               else if(me->range_mode) {
                 if(me->range == SYMETRIC
                 && me->n_anf > 0) {
                        me->n_anf -= 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
                              me->n_anf);
		 }
                 if(me->range == SYMETRIC 
                      && me->n_end > 0) {
                        me->n_end -= 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
                              me->n_end);
		 }
                 if(me->range == ANFANG 
                      &&  me->n_anf > 0) {
                        me->n_anf -= 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
                              me->n_anf);
		 }
                 else if(me->range == ENDE  
                      && me->n_end > 0) {
                        me->n_end -= 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
                              me->n_end);
		 }
               }

               goto L1;

	    case PLUS:
               if(me->range_mode) {
                 if(me->range == SYMETRIC
                 && me->n_anf < (me->p_s - me->bed_a)) {
                        me->n_anf += 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
                              me->n_anf);
                 }
                 if(me->range == SYMETRIC
                 && me->n_end < (me->crv->num_poles - me->p_s - me->bed_e 
                                                              - me->m_p)) {
                        me->n_end += 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
                              me->n_end);
		 }
                 if(me->range == ANFANG 
                 && me->n_anf < (me->p_s - me->bed_a)) {
                        me->n_anf += 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_LRANGE_F,(IGRdouble)
                              me->n_anf);
		 }
                 else if(me->range == ENDE  
                 && me->n_end < (me->crv->num_poles - me->p_s - me->bed_e 
                                                              - me->m_p)) {
                        me->n_end += 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_RRANGE_F,(IGRdouble)
                              me->n_end);
		 }
               }
               else if(me->shape_mode) {
                 if(me->shape == SYMETRIC
                 && me->shape_amount_left < SHAPE_MAX) {
                        me->shape_amount_left += 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
                              me->shape_amount_left);
		 }
                 if(me->shape == SYMETRIC
                      && me->shape_amount_right < SHAPE_MAX) {
                        me->shape_amount_right += 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
                              me->shape_amount_right);
		 }
                 if(me->shape == ANFANG 
                      && me->shape_amount_left < SHAPE_MAX) {
                        me->shape_amount_left += 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_LSHAPE_F,(IGRdouble)
                              me->shape_amount_left);
		 }
                 else if(me->shape == ENDE  
                      && me->shape_amount_right < SHAPE_MAX) {
                        me->shape_amount_right += 1;
                        if(me->optform_requested) 
                          FIg_set_value(me->optform,S_RSHAPE_F,(IGRdouble)
                              me->shape_amount_right);
		 }
               }

               goto L1;

 
	    case DISTANCE:

               if(me->show_distance) {
                 me->show_distance = FALSE;
                 infos.distance = FALSE;
                 pnt[X] = me->dyaccev.event.button.x;
                 pnt[Y] = me->dyaccev.event.button.y;
                 pnt[Z] = me->dyaccev.event.button.z;
                 if(me->optform_requested) 
                   FIg_set_state_off(me->optform, S_SHDI_B);
                 goto L1;
	       } else if(!me->show_distance && me->ls_found){
                 me->show_distance = TRUE;
                 infos.distance = TRUE;
                 pnt[X] = me->dyaccev.event.button.x;
                 pnt[Y] = me->dyaccev.event.button.y;
                 pnt[Z] = me->dyaccev.event.button.z;
                 if(me->optform_requested) 
                   FIg_set_state_on(me->optform, S_SHDI_B);
                 goto L1;
               }

            case VERTICES:
               if(!me->show_vertices) {
                 if(!me->ls_found) {
                   ex$message(msgnumb = EMS_I_NoLs);
                   goto L1;
                 }
                 me->show_vertices = TRUE;
                 if(me->optform_requested) 
                   FIg_set_state_on(me->optform, S_SHVE_B);
                 gr$get_active_display( buffer = &vertex_display );
                 vertex_display.style = (IGRuchar) 0;
                 vertex_display.color = (short unsigned) 2;
                 vertex_display.weight = (IGRuchar) 5;
                 k=1;
                 for(j=0;j<me->nvx*3;j=j+3) {
                   stat_OM = ECdisplayPointSetByBuffer(
                    &msg_loc,
                    vertex_display,
                    me->md_env,
                    my_id,
                    k,
                    &me->vx[j],
                    TRUE);
                 }
                } else {
                    if(!me->ls_found) {
                      ex$message(msgnumb = EMS_I_NoLs);
                      goto L1;
                    }
                    me->show_vertices = FALSE;
                    if(me->optform_requested) 
                      FIg_set_state_off(me->optform, S_SHVE_B);
                    vertex_display.color = (short unsigned) 0;
                    k=1;
                    for(j=0;j<me->nvx*3;j=j+3) {
                      stat_OM = ECdisplayPointSetByBuffer(
                        &msg_loc,
                        vertex_display,
                        me->md_env,
                        my_id,
                        k,
                        &me->vx[j],
                        TRUE);
                    }
		  }
	       


               goto L1;
  

       
	    case POLYGON:

               if(me->show_poles) {
                 me->show_poles = FALSE;
                 infos.polygon = FALSE;
                 dcrv_spec_att.is_polydis = FALSE;
                 if(me->optform_requested) 
                   FIg_set_state_off(me->optform, S_SHPO_B);
               } else {
                 me->show_poles = TRUE;
                 infos.polygon = TRUE;
                 infos.my_id = my_id;
                 infos.md_env = &me->md_env;
                 dcrv_spec_att.is_polydis = FALSE;
                 if(me->optform_requested) 
                   FIg_set_state_on(me->optform, S_SHPO_B);
               }
               goto L1;


	    case CURVATURE:
               if(me->show_hedgehog) {
                 me->show_hedgehog = FALSE;
                 infos.hedgehog = FALSE;
                 me->show_curvature = TRUE;
                 infos.curvature = TRUE;
                 pnt[X] = me->dyaccev.event.button.x;
                 pnt[Y] = me->dyaccev.event.button.y;
                 pnt[Z] = me->dyaccev.event.button.z;
                 goto L1;
               }
               if(me->show_curvature) {
                 me->show_curvature = FALSE;
                 infos.curvature = FALSE;
                 pnt[X] = me->dyaccev.event.button.x;
                 pnt[Y] = me->dyaccev.event.button.y;
                 pnt[Z] = me->dyaccev.event.button.z;
                 if(me->optform_requested) 
                   FIg_set_state_off(me->optform, S_SHCU_B);
                 goto L1;
	       } else {
                 me->show_curvature = TRUE;
                 infos.curvature = TRUE;
                 pnt[X] = me->dyaccev.event.button.x;
                 pnt[Y] = me->dyaccev.event.button.y;
                 pnt[Z] = me->dyaccev.event.button.z;
                 if(me->optform_requested) 
                   FIg_set_state_on(me->optform, S_SHCU_B);
                 goto L1;
               }
       
            case HEDGEHOG:

               if(me->show_curvature) {
                 me->show_curvature = FALSE;
                 infos.curvature = FALSE;
                 me->show_hedgehog = TRUE;
                 infos.hedgehog = TRUE;
                 pnt[X] = me->dyaccev.event.button.x;
                 pnt[Y] = me->dyaccev.event.button.y;
                 pnt[Z] = me->dyaccev.event.button.z;
                 goto L1;
               }
               if(me->show_hedgehog) {
                 me->show_hedgehog = FALSE;
                 infos.hedgehog = FALSE;
                 pnt[X] = me->dyaccev.event.button.x;
                 pnt[Y] = me->dyaccev.event.button.y;
                 pnt[Z] = me->dyaccev.event.button.z;
                 if(me->optform_requested) 
                   FIg_set_state_off(me->optform, S_SHCU_B);
                 goto L1;
	       } else {
                 me->show_hedgehog = TRUE;
                 infos.hedgehog = TRUE;
                 pnt[X] = me->dyaccev.event.button.x;
                 pnt[Y] = me->dyaccev.event.button.y;
                 pnt[Z] = me->dyaccev.event.button.z;
                 if(me->optform_requested) 
                   FIg_set_state_on(me->optform, S_SHCU_B);
                 goto L1;
               }
               /* break; */


	     case IDLS:
               if(me->ls_found) {
                  ex$message(msgnumb = EMS_I_LsAI);
                  goto L1;
	       }
               me->accev = me->dyaccev;
               ex$message(msgnumb = EMS_M_SeLs, buff = loc_prompt);
               ex$message(msgnumb = EMS_P_SeLs);
               ME.super_cmd->state = GET_LINESTRING;
               if(me->optform_requested)
                  FIg_set_state_on(me->optform, S_IDLS_B);
               me->old_command = MAIN_PROCESS;
               goto function_end;
               


	     case '1':
               me->cursor_sensitivity = 1;
               me->cms = CURSOR_SENS1;
               if(me->optform_requested) 
                 FIg_set_state(me->optform, S_CURSOR_S,TRUE);
               goto L1;

	     case '0':
               me->cursor_sensitivity = 0;
               me->cms = CURSOR_SENS0;
               if(me->optform_requested) 
                 FIg_set_state(me->optform, S_CURSOR_S,FALSE);
               goto L1;

             default:
               goto L1;
	}

        case EX_CMD_KEY:              
              me->old_command = MAIN_PROCESS;
              if(!strcmp(me->response_data,TENTATIVE_KEY))
                 me->ex_cmd_pressed = TRUE;
              ME.super_cmd->state = me->command = MAIN_PROCESS;
              goto function_end;

        case EX_POCKET:
              me->ex_pocket_pressed = TRUE;
              me->old_command = MAIN_PROCESS;
              ME.super_cmd->state = me->command = EXECUTE_COMMAND;
              goto function_end;
         

        default:
         goto function_end;

     }

function_end:
    return(stat_OM);
}

method det_crv_plane(IGRlong *msg)
{
 IGRlong stat_OM, msg_loc;
 struct GRprops 	geom_props;
 IGRpoint 		plane_point;
 IGRvector 		plane_normal;
 struct IGRplane 	plane;

 stat_OM = msg_loc = OM_S_SUCCESS;
 me->XXXXX = 1469;
 stat_OM = om$send(msg = message GRvg.GRgeomprops(
                         &msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &geom_props),
                   targetid = me->cv_info.located_obj.objid,
                   targetos = me->cv_info.located_obj.osnum);
 TEST_ERROR(stat_OM,msg_loc,"GRvg.GRgeomprops",function_end);

 if(!geom_props.planar) {
  me->planar = FALSE;
  goto function_end;
 } else
  me->planar = TRUE;


 me->plane.point = (IGRdouble *) &me->plane_point[0];
 me->plane.normal = (IGRdouble *) &me->plane_normal[0];

 stat_OM = om$send(msg = message GRvg.GRdetplane(
                         &msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &me->plane),
                   targetid = me->cv_info.located_obj.objid,
                   targetos = me->cv_info.located_obj.osnum);
 TEST_ERROR(stat_OM,msg_loc,"GRvg.GRdetplane",function_end);



function_end:
    *msg = msg_loc;
    return(stat_OM);
}

method get_bsp_info(IGRlong *msg)
{
 IGRlong stat_OM, msg_loc;
 IGRlong size=0;
 IGRint pol_anz=0, knot_anz=0;
 IGRdouble siz=0;
 struct IGRbsp_curve *crv=NULL;

 stat_OM = msg_loc = OM_S_SUCCESS;


 stat_OM = om$send( msg = message GRvg.GRgetsize(
                          &msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &size ),
                    targetos = me->cv_info.located_obj.osnum,
                    targetid = me->cv_info.located_obj.objid );
 TEST_ERROR(stat_OM,msg_loc,"GRgetsize",function_end);
 crv = (struct IGRbsp_curve *) om$malloc( size = size );
 if(!crv) 
    REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(crv)",function_end);
 
 stat_OM = om$send( msg = message GRvg.GRgetgeom(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  (IGRchar *)crv),
                    targetos = me->cv_info.located_obj.osnum,
                    targetid = me->cv_info.located_obj.objid );

 me->crv = crv;
 pol_anz = crv->num_poles;
 knot_anz = crv->num_knots;
 siz   = sizeof(IGRdouble);
 me->knot  = (IGRdouble *) om$malloc ( size = knot_anz * siz);
 if (!me->knot)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->knot)",function_end);
 siz   = pol_anz*sizeof(IGRdouble); 
 me->pols_x = (IGRdouble *) om$malloc ( size = siz );
 if (!me->pols_x)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->pols_x)",function_end);
 me->pols_y = (IGRdouble *) om$malloc ( size = siz );
 if (!me->pols_y)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->pols_y)",function_end);
 me->pols_z = (IGRdouble *) om$malloc ( size = siz );
 if (!me->pols_z)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->pols_z)",function_end);
 me->pol_x  = (IGRdouble *) om$malloc ( size = siz );
 if (!me->pol_x)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->pol_x)",function_end);
 me->pol_y  = (IGRdouble *) om$malloc ( size = siz );
 if (!me->pol_y)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->pol_y)",function_end);
 me->pol_z  = (IGRdouble *) om$malloc ( size = siz );
 if (!me->pol_z)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->pol_z)",function_end);
 me->vec_x  = (IGRdouble *) om$malloc ( size = siz );
 if (!me->vec_x)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->vec_x)",function_end);
 me->vec_y  = (IGRdouble *) om$malloc ( size = siz );
 if (!me->vec_y)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->vec_y)",function_end);
 me->vec_z  = (IGRdouble *) om$malloc ( size = siz );
 if (!me->vec_z)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->vec_z)",function_end);
 me->weigh  = (IGRdouble *) om$malloc ( size = siz );
 if (!me->weigh)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->weigh)",function_end);
 me->bf     = (IGRdouble *) om$malloc ( size = siz );
 if (!me->bf)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->bf)",function_end);
 me->p_par  = (IGRdouble *) om$malloc ( size = siz );
 if (!me->p_par)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->p_par)",function_end);
 me->pole   = (IGRdouble *) om$malloc ( size = 3 * siz );
 if (!me->pole)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->pole)",function_end);
 me->ugpole   = (IGRdouble *) om$malloc ( size = 3 * siz );
 if (!me->ugpole)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->ugpole)",function_end);
 me->opole   = (IGRdouble *) om$malloc ( size = 3 * siz );
 if (!me->opole)
  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"om$malloc(me->opole)",function_end);


function_end:

  *msg = msg_loc;
  return(stat_OM);

}

end implementation ECascvmd;


