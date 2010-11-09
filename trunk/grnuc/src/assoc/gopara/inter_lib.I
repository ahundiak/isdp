/*-------------------------------
  lib_gr_par.c :

  It contains a variety of usefull function or little things
    boring to write again & again 

  S.Frezefond 27-Mar-86 (revised 23-Apr-86)
  C.H.        AUgust_87 : revised

 unit_vect
 cmp_intersection_line_circle(p0, p1,circle_st,ch_pt,pt_ptr,orient)
 cmp_intersection_circle_circle(circle_st1,circle_st2,ch_pt,pt_ptr,orient)
 pr_point(string,point)
--------------------------------*/

class implementation Root;

#define PREC 1.e-10
#define NULL 0
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "ASmatrix.h"
#include "parametric.h"
#include "madef.h"
#include "AS_status.h"

#define AS_DEBUG 1

IGRdouble fabs();
IGRboolean mat4_3();
IGRdouble acos();
IGRdouble cos(), sin(), atan2();


/*
----------------------------------------------------------------------------
   print of a point
----------------------------------------------------------------------------
*/
void pr_point(str,pt)
IGRchar *str;
IGRpoint pt;
{
  printf("point %s  x: %lf y: %lf z: %lf\n",str,pt[0],pt[1],pt[2]);
  return;
}
/*
----------------------------------------------------------------------------
   print of a matrice 
----------------------------------------------------------------------------
*/
void pr_mat(str, nb_lgn, nb_col, mat)
IGRchar *str;
IGRshort nb_lgn, nb_col;
IGRdouble *mat;
{
  IGRint l, c, index;

  printf("mat %s  \n",str);
  for( l = 0; l < nb_lgn; l++ )
  {
   printf(" --> ( ");
   for( c = 0; c < nb_col; c++ ) 
   {
    index = 4 * l + c;
    printf("%lf",mat[index] );
    if( c != nb_col - 1 ) printf(", ");
   }
   printf(" )\n");
  }
  return;
}


/* -----------------------------------------------------------------------

     mes_angle:

  This routine calculates the 2 angles and their difference.

--------------------------------------------------------------------------- */
IGRint mes_angle( radius, start_p, end_p, flag, teta1, teta2, dif )
IGRdouble radius;
IGRpoint start_p, end_p;
short flag;
IGRdouble *teta1, *teta2, *dif;

/*.mes_angle.Root*/
 {
  /*"radius: %lf\n", radius*/
  /*^pr_point("start_p", start_p); */
  /*^pr_point("end_p", end_p); */
  if( radius == 0. )
    {
     *teta1 = 0.;
     *teta2 = 0.;
     *dif = 0.;  
     return(1);
    }
  if( flag == 1 ) { *teta1 = 0; *teta2 = PI + PI; *dif = PI + PI; }
  else
   {
    *teta1 = atan2(start_p[1], start_p[0]);
    if(*teta1 < 0. ) *teta1 = PI + PI + *teta1;

    *teta2 = atan2(end_p[1], end_p[0]);
    if(*teta2 < 0. ) *teta2 = PI + PI + *teta2;

    *dif = *teta2 - *teta1;
    modulo(dif, 2*PI);
   }

  /*"teta1: %lf, teta2: %lf, dif: %lf\n", *teta1, *teta2, *dif */

  return(1);
 }


/*     point_on_circle
-----------------------------------------------------------------------------

    This routine accepts a circle ( it is defined  by its center 'cent' its
 radius 'rad' and its matrix 'mat(3,3)'). This routine returns the nearest
 point on the circle of 3D point 'pt'. The returned point is defined on the
 local coordonates.
-----------------------------------------------------------------------------
*/                  

IGRint point_on_circle( cent, rad, mat, pt, p_circle )
 IGRpoint cent;          /*  center of the circle in world coord.       */
 IGRdouble rad;          /*  radius of the circle                       */
 IGRdouble *mat;         /*  matrix of the circle (3,3)                 */
 IGRdouble *pt;          /*  3D point in world coord.                   */
 IGRdouble *p_circle;    /*  result point in locale coord.              */

/*.pt_on_cir.Root*/
{
 IGRlong msg;
 IGRdouble norme, v[3], lc_pt[3], t_mat[9];
 IGRint i;
 IGRshort un = 1, trois = 3;

 /*^pr_point("cent", cent); */
 /*"rad: %lf\n", rad */
 /*^pr_mat("cir", 3, 3, mat); */

 /*  translate the point from world to local coord  */
 MAsubvc( &msg, pt, cent, v );
 MArtrnmx( &msg, &trois, &trois, mat, t_mat );
 MAmulmx( &msg, &trois, &trois, &un, t_mat, v, lc_pt );

 if( rad < 0 ) rad = -rad;
 if( rad < 1.e-10 ) for( i = 0; i < 3 ; i++ ) p_circle[i] = 0;

 norme = sqrt( lc_pt[0] * lc_pt[0] + lc_pt[1] * lc_pt[1] );
 if(norme > 1.e-10)
    {
     p_circle[0] = lc_pt[0] / norme;
     p_circle[1] = lc_pt[1] / norme;

     p_circle[0] =  rad * p_circle[0];
     p_circle[1] =  rad * p_circle[1];
     p_circle[2] = 0;
    }
 else    /* the point lc_pt is on the center -> any point of the circle can be
            return   */
    {
     p_circle[0] =  rad ;
     p_circle[1] =  0;
     p_circle[2] =  0;
    }

 /*^pr_point("p_circle",p_circle); */
 return(1);
}


/*   
-----------------------------------------------------------------------------
    point_on_line


    This routine accepts a line ( defined by a point pa and a vector va )
  and a point p. This routine returns a point ps on the line which is the
  nearest point of p. The vector va is assumed to be a unit vector.
-----------------------------------------------------------------------------

*/
   
IGRint point_on_line( pa, va, p , onlnpt )

IGRpoint pa, p, va, onlnpt;
/*.pt_on_line.Root*/
 {
  IGRpoint v1;
  IGRdouble scal;
  IGRdouble un = 1.;

  v_sub(p, pa, v1);
  scal = v_dot(va, v1);
  v_comb(un,pa,scal,va,onlnpt);
  return( 1 );
 }

/*
  line_prox_line

       This routine accepts two segments each described by a starting point
  and a vector.  This routine returns two parameters that identify the points
  at which the two lines represented by these segments come closest to each
  other.  The closest points can be calculated by multiplying the returned
  parameters by the input vectors and adding the starting points.
       The function return value will be non zero for a normal completion,
  zero to indicate that the two lines are parallel and that the returned
  parameters are not valid.
*/

int line_prox_line(pa,va,pb,vb,ta,tb)
 IGRpoint pa,va,pb,vb;
 IGRdouble *ta,*tb;
 {
  IGRdouble aa,ab,ac,bb,bc;
  IGRpoint vc;
  IGRdouble det,da,db;

  vc[0]=pa[0]-pb[0]; vc[1]=pa[1]-pb[1]; vc[2]=pa[2]-pb[2];

  aa=(va[0]*va[0])+(va[1]*va[1])+(va[2]*va[2]);
  ab=(va[0]*vb[0])+(va[1]*vb[1])+(va[2]*vb[2]);
  ac=(va[0]*vc[0])+(va[1]*vc[1])+(va[2]*vc[2]);
  bb=(vb[0]*vb[0])+(vb[1]*vb[1])+(vb[2]*vb[2]);
  bc=(vb[0]*vc[0])+(vb[1]*vc[1])+(vb[2]*vc[2]);

  /*
    The distance between two points, one on each line is given by:

    | pa+va(ta) - pb+vb(tb) |

    or the distance squared (after multiplying everything out): 

    f(ta,tb)=aa(ta)(ta)-2(ab)(ta)(tb)+2(ac)(ta)+bb(tb)(tb)-2(bc)(tb)+cc

    The closest points are determined by solving the two equations df/dta=0
    and df/dtb=0. 

    df/dta=2(aa)(ta)-2(ab)(tb)+2(ac)

    df/dtb=-2(ab)(ta)+2(bb)(tb)-2(bc)
  */

  det=(aa*bb)-(ab*ab);


/*
    if(det == 0)  modify jla 18-Aug-89 --> pb in intersection line lbs when
    the line and the lbs are horizontal
*/
  if(det < 1.e-12 * aa)
   {
    *ta=0; *tb=0;
    return(0);
   }

  da=(-ac*bb)-(-ab*bc);
  db=(aa*bc)-(ac*ab);

  *ta=da/det;
  *tb=db/det;

  return(1);
 }/* line_prox_line */

/*
----------------------------------------------------------------------------
   unit_vect
  return code :
    1 : OK
    0 : the two points are the same
----------------------------------------------------------------------------
*/
IGRint unit_vect(p0,p1,vect_ptr)
IGRpoint p0,p1,vect_ptr;
{
  IGRpoint vunit1;
  IGRdouble vl;

  v_sub(p1, p0, vunit1);
  vl = v_len(vunit1);
  if(vl == 0.)return(0);
  vl = 1./vl;
  v_scale(vunit1,vl,vect_ptr);
  return(1);
}

/*
----------------------------------------------------------------------------
   function that compute the intersection point
   between a line and a circle

   when called from a place_CMD orient  
         -1 if there is a track point
         -2 if first call for place_CMD
   in return :
         0 or 1 to discriminate the solutions or
         3 to say it was not discriminable at the choice
----------------------------------------------------------------------------
*/

IGRint cmp_intersection_line_circle(
  double *p0,
  double *p1,
  struct circle_data circle_st,
  double *ch_pt,
  double *pt_ptr,
  IGRint *orient)

/*.int_line_cir.Root */
{
  IGRpoint pa,pb,va,pl,pc,vcp,pin1,pin2,vtrans,v_to_orient1,
  v_to_orient2;
  IGRdouble  circle3mat[9];
  IGRdouble *rad, *cent;
  IGRdouble dist,dist_old,k,ln,linter,dist1,dist2;
  IGRint i;

  rad = &circle_st.rad;
  cent = circle_st.cent_p;

  /*^pr_point("p0",p0); */
  /*^pr_point("cent cir",cent); */
  /*^pr_point("snap pt",ch_pt); */
  
  /*  go to 3 3 matrix   */
  mat4_3(circle_st.mat,circle3mat);

  if( unit_vect(p0, p1, va) == 0) return(0);

/*  /* we compute the normal vector attached to the intersection */
/*  pb[0] = 0.;
/*  pb[1] =0.;
/*  pb[2] =1.;
/*  m_mul_v( circle3mat, pb,normal) ;
/**/

  /* convert from world to local coord of the circle */
  v_sub(ch_pt,cent,ch_pt);
  v_sub(p0,cent,pa);
  mt_mul_v( circle3mat, pa, pa );
  mt_mul_v( circle3mat, va, va );
  mt_mul_v( circle3mat, ch_pt, ch_pt );

  /*
  we use a quickerr metthod if the line and the circle are 
  in the same plane
*/
  if((fabs(pa[2]) <= 0.1) && (fabs(va[2]) <= 0.1))
  {
    /*| same plane */
    v_identity(pb);
    point_on_line( pa, va, pb , pl); 
    ln = v_len(pl);
/*
  The test use to be done on ln*ln - *rad * *rad. The result is that it increase
   the error. For example a 10.e-13 difference between ln and rad can produce
   a 10.e-10 difference in the square values, and a 10-5 value for linter.
   The result is the "well know failure of associative fillet in composite
   curve !!!!
   jla August 91
*/
    if (ln > fabs(*rad) - 1.e-10)
     {
      linter=0.;
     }
    else
     {
      ln = (*rad) * (*rad) - ln * ln;
      linter = sqrt(ln);
     }


    v_scale(va,linter,vtrans);
    v_add(pl,vtrans,pin1);
    v_sub(pl,vtrans,pin2);
    v_sub(pin1,ch_pt,v_to_orient1);
    v_sub(pin2,ch_pt,v_to_orient2);
    dist1 = v_len(v_to_orient1);
    dist2 = v_len(v_to_orient2);

    if(((dist2 > dist1) && ((*orient == -1) || *orient == -2 || *orient ==3)) ||
        *orient == 0)
    {
      m_mul_v( circle3mat,pin1,pin1);
      v_add(cent,pin1,pt_ptr);
      if((*orient!=-1) && (*orient!=3)) *orient = 0;
      return(1);
    }
    else
    {
      m_mul_v( circle3mat,pin2,pin2);
      v_add(cent,pin2,pt_ptr);
      if((*orient!=-1) && (*orient!=3)) *orient = 1;
      return(1);
    }
  }

  /*|  calculate of the begining point of the iterative method  */

  if(*orient==-2) *orient = 3;

  point_on_line( pa, va, ch_pt, pl );
  k = *rad / 10.;
  pl[0] += va[0] * k;
  pl[1] += va[1] * k;
  pl[2] += va[2] * k;
  dist = 0;

  do
  {
    dist_old = dist;
    /*  convert the point to the world coord. */
    m_mul_v( circle3mat, pl, pl );
    v_add(pl,cent,pl);
    point_on_circle(cent,fabs(*rad),circle3mat,pl,pc );
    point_on_line( pa, va, pc , pl);
 
    vcp[0] = pc[0] - pl[0];
    vcp[1] = pc[1] - pl[1];
    dist = sqrt( vcp[0] * vcp[0] + vcp[1] * vcp[1] );
    /*^pr_point("pointl",pl); pr_point("pointc",pc); */

  } while ( ( (dist_old - dist) > 0.5 ) || ( (dist_old - dist) < -0.5 ) );

  /* Convert from local to world coord. and take the midlle point  */
  m_mul_v( circle3mat, pc, pc );
  m_mul_v( circle3mat, pl, pl );

  for(i=0; i<3; i++ ) pt_ptr[i] = 0.5 * (pc[i] + pl[i]) + cent[i];

  return(1);
}   /*   end cmp_intersection line circle   */

/*
----------------------------------------------------------------------------
   function that compute the intersection point
   between two circles
----------------------------------------------------------------------------
*/
IGRint cmp_intersection_circle_circle(
  struct circle_data circle_st1,
  struct circle_data circle_st2,
  double *ch_pt,
  double *pt_ptr,
  IGRint *orient)
/*.int_cir_cir.Root */
{
  IGRpoint pa,pc1,pc2,vcp,normal_to_c1_in_c2,v_cent2_cent1;
  IGRpoint zero,v_to_orient1,v_to_orient2,pin1,pin2,vunit_2_to_1;
  IGRpoint vnormal,vtrans, normal, normal2;
  IGRdouble circle3mat1[9], circle3mat2[9];
  IGRdouble *rad1, *rad2, *cent1, *cent2;
  IGRdouble dist,dist_1_to_2,cosse,sc_fact,dist1,dist2;
  IGRdouble tmpfact, k, k1;
  IGRint i;


  rad1 = &circle_st1.rad;
  cent1 = circle_st1.cent_p;
  rad2 = &circle_st2.rad;
  cent2 = circle_st2.cent_p;
  /*^pr_point("c1 cent",cent1);pr_point("c2 cent",cent2);pr_point("snap",ch_pt);*/
  /*
   *  go to 3 3 matrix
   */
   mat4_3(circle_st1.mat,circle3mat1);
   mat4_3(circle_st2.mat,circle3mat2);

  v_identity(zero);
  /*|  we compute the normal vector attached to the intersection */
  normal[0]=circle3mat1[2];
  normal[1]=circle3mat1[5];
  normal[2]=circle3mat1[8];

  /*|  we compute ch_pt in c2 ref */

  normal2[0]=circle3mat2[2];
  normal2[1]=circle3mat2[5];
  normal2[2]=circle3mat2[8];

  v_equal(ch_pt,pc2); /* used with iterative method */
  /* world coord. to local (c2) coord */
  v_sub(ch_pt,cent2,ch_pt);
  mt_mul_v( circle3mat2, ch_pt, ch_pt );

  mt_mul_v(circle3mat2,normal,normal_to_c1_in_c2 );
  v_sub(cent1,cent2,v_cent2_cent1);

  k = 1. - fabs(v_dot( normal, normal2 ));
  k1 = fabs(v_dot(normal2, v_cent2_cent1)); /* must be 0 if same plane */
  /*"k: %lf, k1; %lf\n", k, k1 */
  mt_mul_v( circle3mat2,v_cent2_cent1,v_cent2_cent1);
  
  if( k < 1.E-5 && k1 < (v_len(v_cent2_cent1)*1.E-5))
  {
    /*|  the 2 circles are in the same planar */
    dist_1_to_2 = v_len(v_cent2_cent1);
    /*|  we eliminate the case of disjoint or included or parallel  circles */
    if (
	(dist_1_to_2 > (1 + PREC)*(fabs(*rad1) + fabs(*rad2)))
    ||  ((1+PREC)*(dist_1_to_2+fabs(*rad1)) < fabs(*rad2))
    ||  ((1+PREC)*(dist_1_to_2+fabs(*rad2)) < fabs(*rad1))
    ||  (dist_1_to_2 <= PREC) 
       )
     {
      /*| No intersection we return the midlle point */
      /*"dist 1 to 2: %lf\n",dist_1_to_2 */
      if(fabs(*rad2) > fabs(*rad1))
        {
         point_on_circle(cent2,fabs(*rad2),circle3mat2,cent1,pc2);
         m_mul_v( circle3mat2, pc2, pc2 );
         v_add(pc2,cent2,pc2);
         point_on_circle(cent1,fabs(*rad1),circle3mat1,pc2,pc1);
         m_mul_v( circle3mat1, pc1, pc1 );
         v_add(pc1,cent1,pc1);
        }
      else
        {
         point_on_circle(cent1,fabs(*rad1),circle3mat1,cent2,pc1);
         m_mul_v( circle3mat1, pc1, pc1 );
         v_add(pc1,cent1,pc1);
         point_on_circle(cent2,fabs(*rad2),circle3mat2,pc1,pc2);
         m_mul_v( circle3mat2, pc2, pc2 );
         v_add(pc2,cent2,pc2);
        }
         for(i=0; i<3; i++ ) pt_ptr[i] = 0.5 * (pc1[i] + pc2[i]);
         return(1);
     }
    else
     {
      cosse = -((*rad1) * (*rad1) - dist_1_to_2 * dist_1_to_2 - 
               (*rad2) * (*rad2)) /(2. * fabs(*rad2) * dist_1_to_2);

      /*"dist 1 to 2: %lf cosse : %lf\n",dist_1_to_2,cosse */

      unit_vect(zero,v_cent2_cent1,vunit_2_to_1);
      tmpfact =cosse * fabs(*rad2);
      v_scale(vunit_2_to_1,tmpfact,vtrans);
      v_equal(vtrans,pa) ;

      /*" pa : %lf %lf %lf \n ", pa[0],pa[1],pa[2] */

      v_cross(normal_to_c1_in_c2, vunit_2_to_1, vnormal);
      sc_fact = sqrt (fabs(1. - cosse * cosse));
      tmpfact = sc_fact*fabs(*rad2);
      v_scale(vnormal,tmpfact,vnormal);
      v_add(pa,vnormal,pin1);
      v_sub(pa,vnormal,pin2);
      v_sub(pin1,ch_pt,v_to_orient1);
      v_sub(pin2,ch_pt,v_to_orient2);
      dist1 = v_len(v_to_orient1);
      dist2 = v_len(v_to_orient2);
      if(((dist2 > dist1) && ((*orient == -1) || *orient == -2 || *orient ==3)) ||
          *orient == 0)
      {
        m_mul_v( circle3mat2,pin1,pin1);
      v_add(cent2,pin1,pt_ptr);
        if((*orient!=-1) && (*orient!=3)) *orient = 0;
        return(1);
      }
      else
      {
        m_mul_v( circle3mat2,pin2,pin2);
        v_add(cent2,pin2,pt_ptr);
        if((*orient!=-1) && (*orient!=3)) *orient = 1;
        return(1);
      }
    }
  }
  /*| calculate of the begining point of the iterative method  */

  if(*orient==-2) *orient = 3;
  dist = 0;
  k = fabs(*rad1 + *rad2) / 1.e+5; /* 200 -> 100000, ch 01-Aout-89 */
  i = 0;
  do
  {
/*    dist_old = dist; */
    /* pc1 on the circle 1 */
    point_on_circle(cent1,fabs(*rad1),circle3mat1,pc2,pc1);

    /*  convert the point to the world coord. */
    m_mul_v( circle3mat1, pc1, pc1 );
    v_add(pc1,cent1,pc1);

    /* pc2 on the circle 2 */
    point_on_circle(cent2,fabs(*rad2),circle3mat2,pc1,pc2);

    /*  convert the point to the world coord. */
    m_mul_v( circle3mat2, pc2, pc2 );
    v_add(pc2,cent2,pc2);

    v_sub(pc1,pc2,vcp);
    dist = v_len(vcp);

    /*^pr_point("pointl",pc1);pr_point("pointc",pc2); */

/*  } while (fabs(dist_old - dist) > k ); modif ch 01-Aout-89 */
  } while (dist > k && i++ < 1000);   /* test on i to avoid an infinit loop */

  /*" Number of loops of iterations: %d\n", i */
  /* we take the mid point */
  for(i=0;i<3;i++) pt_ptr[i] = 0.5 * (pc1[i] + pc2[i]);

  return(1);
}   /*   end cmp_intersection circle circle   */


/*
 *   modulo
 */
modulo( angle, div )
IGRdouble *angle;
IGRdouble div;
{
 IGRint res;
 res = *angle / div;
 if( *angle < 0 ) res = res - 1;
 *angle = *angle - div * (IGRdouble) res;
 return 1;
}


/*
 *  ASarc_pts: 
 *     Given the returned structure of an arc circle, compute the start and 
 *     sweep point in the world coordinate system.
 *  USED BY DIM
 */

int ASarc_pts(
 int 			  *msg,		/* completion code		*/
 struct ret_struct	*arc_struct,	/* arc structure		*/
 double			*start_pt,	/* start point			*/
 double			*sweep_pt)	/* sweep point			*/
/*.ASarc_pts*/
{
 double *teta, *rad, mat[9], v[3];
 double pt1[3], pt2[3];
 short trois = 3, un = 1;

 /*^
 pr_point("cent pt",arc_struct->var.circle_st.cent_p);
 printf("arc start angle: %lf, sweep angle: %lf\n", 
         arc_struct->var.circle_st.start_angle,arc_struct->var.circle_st.sweep_angle);
 pr_mat("rot_mat",4,4,arc_struct->var.circle_st.mat);
 */

 *msg = 1;

 teta   = &arc_struct->var.circle_st.start_angle;
 rad    = &arc_struct->var.circle_st.rad;
 pt1[0] = *rad * cos(*teta); pt1[1] = *rad * sin(*teta); pt1[2] = 0;
 teta   = &arc_struct->var.circle_st.sweep_angle;    
 pt2[0] = *rad * cos(*teta); pt2[1] = *rad * sin(*teta); pt2[2] = 0;

 mat4_3( arc_struct->var.circle_st.mat, mat );
 MAmulmx( &msg, &trois, &trois, &un, mat, pt1, v );
 MAaddvc( &msg, v, arc_struct->var.circle_st.cent_p, start_pt );  
 MAmulmx( &msg, &trois, &trois, &un, mat, pt2, v );
 MAaddvc( &msg, v, arc_struct->var.circle_st.cent_p, sweep_pt );  

 /*^
 pr_point("start point",start_pt);
 pr_point("sweep point",sweep_pt);
 */

 return(1);
}


/*------------------------------------------------------------------------

  Find the projection of points or vector on a plan. The direction of the 
  projection is defined by the vz of the plan.

 the arguments are:
    - msg is the returned code, 
    - t is the 4*4 matrix defining the plan, 
    - nb_pts is the number of point to project, 
    - pj_pts 1 if points to project else if vectors,
    - pts_in is the array of points or vectors to project, 
    - pts_out is the array of points or vectors projected on the plan, the 2 
      array may be the same.

 USED BY DIM

--------------------------------------------------------------------------*/

 ASproj( msg, t, pj_pts, nb_pts, pts_in, pts_out )
 IGRlong *msg;
 IGRdouble *t;
 IGRboolean pj_pts;
 IGRint nb_pts;
 IGRdouble *pts_in, *pts_out;
 /*.ASproj.Root*/
 {
  IGRint i, ind;
  IGRdouble kz;
  IGRvector v0, vz, pz;
  IGRpoint p0;

  p0[0] = t[3];   p0[1] = t[7];   p0[2] = t[11];
  vz[0] = t[2];   vz[1] = t[6];   vz[2] = t[10];

  /*^pr_mat("ref", 4, 4, t); */

  for( i = 0; i < nb_pts; i++ )
   {
    ind = 3 * i;
    /*^pr_point("pt_in", &pts_in[ind] ); */
    if(pj_pts) MAsubvc( &msg, &pts_in[ind], p0, v0 );
    else { v0[0] = pts_in[ind]; v0[1] = pts_in[ind+1]; v0[2] = pts_in[ind+2]; }
    kz = v_dot( v0, vz ) ;
    MAscalvc( &msg, &kz, vz, pz );
    MAsubvc( &msg, v0, pz, &pts_out[ind] );
    if(pj_pts) MAaddvc( &msg, p0, &pts_out[ind], &pts_out[ind] );
    /*^pr_point("pt_out", &pts_in[ind] ); */
   }
  return 1;
 }

/* just to have the function BScirc3pts in ci.X */

void zzz()
{
 BScirc3pts();
}

end implementation Root;

