/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/* 
DESCRIPTION
  
   This routine computes the (u,v) values for a series of (x,y,z) values
   for certain planar surfaces.  The surface must by second order in
   u and v and opposite sides must be parallel and have equal length.
   Of course the surface must also be planar.
  
RETURN VALUES
  
   status		TRUE if success, FALSE if failure
   data_within_range	After mapping, was any data outside the parametric
			range of the surface?
   data_on_surface	Was all the input data within twice the input
			tolerance of lying on the surface?
   msg			MSSUCC - success
  			MANOMEMORY - no dynamic memory available
			MSINARG - This surface did not have equal length
			parallel sides or was not planar.
NOTES

 The resulting parametric space points are returned regardless of
 whether the data is within range of, or lies on, the surface.
  
HISTORY
  
   01/22/87 : stw : creation date
   04/12/87 : rlw : Modified such that if off of plane then
                    (u,v) coorindates returned are within then
                    range (us,ud) and (vs,vd).  Fixed bug in
                    one of the checks for off of plane.
   01/05/87 : rlw : renamed routine and added addition arguments such that
                    movement of data to surface edges was made optional

   10/27/87 : RC  : Changed the arguments such that surface buffer
		    accepted instead of poles and knot values. 
   09/22/91   DLB   Changed j local variable to be a short. 
		    BNrot_ele takes *short for num_pts and passing
		    *int will cause problems on the SUN.
   07/09/93  Sudha  Modified for BSprototypes anisfication

 */

#include <stdio.h>
#include "igrtypedef.h"			/* Has IGRboolean, etc. */
#include "igr.h"			/* Has curve and surface */
#include "msdef.h"                      /* MS error return codes */
#include "maerr.h"                      /* MA error return codes */
#include "bsparameters.h"		
#include "bserr.h"
#include "bsnorvec.h"
#include "bscrossp.h"

static IGRboolean   BNrot_ele();

IGRboolean EFmap_xyz_to_uv_for_planes(
 msg,			/* Error return code */
 surface,		/* plane geometry    */
 tol,			/* Model space cht tolerance */
 uv_tol,		/* Parametric space tolerance */
 np,			/* Number of points to be mapped */
 points,		/* Model space points to be mapped */
 data_within_range,	/* Any data outside parametric range of surface? */
 data_on_surface,	/* All data within tolerance of surface? */
 move_data_to_edges,	/* If any of the data is outside the parametric
			   range of the surface to you want this routine
			   to move it to the edges of the surface? */
 uv) 			/* Mapped parametric space points */

 IGRlong			*msg;
 struct  IGRbsp_surface		*surface;
 IGRdouble			tol,uv_tol;
 IGRlong			np;
 IGRpoint			points[];
 IGRboolean			*data_within_range;
 IGRboolean			*data_on_surface;
 IGRboolean			move_data_to_edges;
 IGRdouble			uv[][2];

{
  IGRpoint 	vv[4],*pnt;
  IGRdouble	*q1, *q2, *q3, *q4;
  IGRdouble	us, ud, vs, vd;
  IGRdouble 	rot[3][3],xx,yy,zz,zl,du,dv, tol_sq, dist_tol;
  IGRdouble     *out,*in;
  IGRdouble 	u_ratio,v_ratio,shift_rate;
  IGRint 	i,k,iii;
  IGRint	low_left, low_right, up_left, up_right;
  BSrc		rc;
  IGRshort 	kd,j, short_np;
  IGRboolean 	forward,status;

  extern  IGRdouble sqrt();
  extern  IGRdouble fabs();

  *msg = MSSUCC;
  *data_within_range = TRUE;
  *data_on_surface = TRUE;
  pnt = NULL;

  BSEXTRACTPAR(&rc, BSTOLLENVEC, dist_tol);
  BSEXTRACTPAR(&rc, BSTOLSQLENVEC, tol_sq);

  low_left = 0;
  low_right = (surface->u_num_poles - 1) * 3;
  up_left = (surface->u_num_poles * (surface->v_num_poles-1)) * 3;
  up_right = up_left + low_right;

  q1 = &surface->poles[low_left];
  q2 = &surface->poles[low_right];
  q3 = &surface->poles[up_right];
  q4 = &surface->poles[up_left];
  
  us = surface->u_knots[surface->u_order - 1];
  ud = surface->u_knots[surface->u_num_poles];
  vs = surface->v_knots[surface->v_order - 1];
  vd = surface->v_knots[surface->v_num_poles];

      
/*
   first check the 4 points
                             */
  zl = 0.0;
  zz = 0.0;
  for(k=0;k<3;k++)
  {
     rot[0][k] = q2[k] - q1[k];
     rot[1][k] = q3[k] - q1[k];
     zl += (rot[0][k] * rot[0][k]);
     zz += (rot[1][k] * rot[1][k]);
  }
  if(fabs(zl) < tol_sq)
  {
     zl = 0.0;
     for(k=0;k<3;k++)
     {
        rot[0][k] = q4[k] - q1[k];
        zl += (rot[0][k] * rot[0][k]);
     }
     if(fabs(zl) < tol_sq) 
      {
       *msg = MSINARG;
       goto wrapup;
      }
  }
  if(fabs(zz) < tol_sq)
  {
     zz = 0.0;
     for(k=0;k<3;k++)
     {
        rot[1][k] = q4[k] - q1[k];
        zz += (rot[1][k] * rot[1][k]);
     }
     if(fabs(zz) < tol_sq) 
      {
       *msg = MSINARG;
       goto wrapup;
      }
  }

  status = BScrossp(&rc,rot[0],rot[1],rot[2]);
  status = BSnorvec(&rc,rot[2]);
  status = BScrossp(&rc,rot[2],rot[0],rot[1]);
  status = BSnorvec(&rc,rot[0]);
  status = BSnorvec(&rc,rot[1]);

  for(k=0; k<3; k++)
  {
     vv[0][k] = q1[k];
     vv[1][k] = q2[k];
     vv[2][k] = q4[k];
  }

  pnt = (IGRpoint *) malloc( np * sizeof(IGRpoint) );
  if( ! pnt )
  {
   *msg = MANOMEMORY;
   goto wrapup;
  }
 
  out = (double *)(pnt);
  in = (double *)points;
  for(i=0; i< np; i++)
  {
     for(k=0; k< 3; k++)
     {
        *out++ = *in++;
     }
  }

  forward = TRUE;
  kd = 0;
  j = 3;
  status = BNrot_ele(&rc,&kd,&forward,rot,q1,&j,vv);
  kd = 0;
  short_np= np; /*DLB - 9/22/91*/
  status = BNrot_ele(&rc,&kd,&forward,rot,q1,&short_np,pnt);

  if( (vv[2][1] <= dist_tol) || (vv[1][0] <= dist_tol) )
  {
   *msg = MSINARG;
   goto wrapup;
  }

  du = ud - us;
  dv = vd - vs;
  v_ratio = ( vd - vs ) / vv[2][1];
  u_ratio = ( ud - us ) / vv[1][0];
  shift_rate = vv[2][0] / vv[2][1];

  for(iii=0; iii < np; iii++)
  {
/*
 * Check the distance to the plane
 */
     if( fabs(pnt[iii][2]) > ( 2.0 * tol) ) *data_on_surface = FALSE;
/*
 * Compute the v coordinate
 */
     yy = pnt[iii][1] * v_ratio;
     if( fabs(yy - dv) < uv_tol ) yy = dv;	/* Snap to edge */
     if( fabs(yy) < uv_tol ) yy = 0.0;		/* Snap to edge */
     uv[iii][1] = yy + vs;

     if ( fabs(vs - uv[iii][1])  < dist_tol)	/* Off of plane? */
       uv[iii][1] = vs;
     else if(uv[iii][1] < vs)
      {
       *data_within_range = FALSE;
       if (move_data_to_edges) uv[iii][1] = vs;
      }
     else if( fabs(uv[iii][1] - vd) < dist_tol)
        uv[iii][1] = vd;
     else if (uv[iii][1] > vd)			/* Off of plane? */
      {
       *data_within_range = FALSE;
       if (move_data_to_edges) uv[iii][1] = vd;
      }
/*
 * Compute the u coordinate
 */
     xx = (pnt[iii][0] - shift_rate * pnt[iii][1]) * u_ratio;
     if( fabs(xx - du) < uv_tol ) xx = du;	/* Snap to edge */
     if( fabs(xx) < uv_tol ) xx = 0.0;		/* Snap to edge */
     uv[iii][0] = xx + us;

     if( fabs(uv[iii][0] - us) < dist_tol)
         uv[iii][0] = us;
     else if (uv[iii][0] < us)			/* Off of plane? */
      {
       *data_within_range = FALSE;
       if (move_data_to_edges) uv[iii][0] = us;
      }
     else if( fabs(uv[iii][0] - ud) < dist_tol)
       uv[iii][0] = ud;
     else if (uv[iii][0] > ud)			/* Off of plane? */
      {
       *data_within_range = FALSE;
       if (move_data_to_edges) uv[iii][0] = ud;
      }
  }
/*
 * eof
 */
 wrapup:
  if(pnt) free(pnt);
  if (1 & *msg)
   return(TRUE);
  else
   return(FALSE);  
 }
  
/* 
DESCRIPTION
  
   This routine computes the (x,y,z) values for a series of (u,v) values
   for certain planar surfaces.  The surface must by second order in
   u and v and opposite sides must be parallel and have equal length.
   Of course the surface must also be planar.
  
RETURN VALUES
  
   status		TRUE if success, FALSE if failure
   msg			MSSUCC - success
  			MANOMEMORY - no dynamic memory available
			MSINARG - This surface did not have equal length
			parallel sides or was not planar.
NOTES

 The resulting model space points are returned regardless of
 whether the data is within range of the surface or not.


HISTORY
  	RC	05/25/87	Modified EMmap_xyz_to_uv_for_planes
				to perform transformations in the
				reverse order.
				
   	RC      10/27/87	Changed the arguments such that surface 
				buffer accepted instead of poles and 
				knot values. 
        DLB     09/22/91	Pass *short to BNrot_ele instead of *int
				(SUN problem).
 */

IGRboolean EFmap_uv_to_xyz_for_planes(
 msg,			/* Error return code */
 surface,		/* Surface buffer    */
 tol,			/* Model space tolerance */
 np,			/* Number of points to be mapped */
 uv,			/* parametric  space points to be mapped */
 xyz) 			/* Model space points */

 IGRlong		*msg;
 struct IGRbsp_surface	*surface;
 IGRdouble		tol;
 IGRlong		np;
 IGRdouble		uv[][2];
 IGRpoint		xyz[];

{
  IGRboolean    BNrot_ele();
  IGRpoint 	vv[4];
  IGRdouble	*q1, *q2, *q3, *q4;
  IGRdouble	us, ud, vs, vd;
  IGRdouble 	rot[3][3],zz,zl, tol_sq, dist_tol;
  IGRdouble 	u_ratio,v_ratio,shift_rate;
  IGRint	low_left, low_right, up_left, up_right;
  IGRint 	k,iii;
  BSrc		rc;
  IGRshort 	kd,j, short_np;
  IGRboolean 	forward,status;

  extern  IGRdouble     sqrt();
  extern  IGRdouble 	fabs();

  *msg = MSSUCC;
  BSEXTRACTPAR(&rc, BSTOLLENVEC, dist_tol);
  BSEXTRACTPAR(&rc, BSTOLSQLENVEC, tol_sq);

  low_left = 0;
  low_right = (surface->u_num_poles - 1) * 3;
  up_left = (surface->u_num_poles * (surface->v_num_poles-1)) * 3;
  up_right = up_left + low_right;

  q1 = &surface->poles[low_left];
  q2 = &surface->poles[low_right];
  q3 = &surface->poles[up_right];
  q4 = &surface->poles[up_left];
  
  us = surface->u_knots[surface->u_order - 1];
  ud = surface->u_knots[surface->u_num_poles];
  vs = surface->v_knots[surface->v_order - 1];
  vd = surface->v_knots[surface->v_num_poles];

/*
   first check the 4 points
                             */
  zl = 0.0;
  zz = 0.0;
  for(k=0;k<3;k++)
  {
     rot[0][k] = q2[k] - q1[k];
     rot[1][k] = q3[k] - q1[k];
     zl += (rot[0][k] * rot[0][k]);
     zz += (rot[1][k] * rot[1][k]);
  }
  if(fabs(zl) < tol_sq)
  {
     zl = 0.0;
     for(k=0;k<3;k++)
     {
        rot[0][k] = q4[k] - q1[k];
        zl += (rot[0][k] * rot[0][k]);
     }
     if(fabs(zl) < tol_sq) 
      {
       *msg = MSINARG;
       goto wrapup;
      }
  }
  if(fabs(zz) < tol_sq)
  {
     zz = 0.0;
     for(k=0;k<3;k++)
     {
        rot[1][k] = q4[k] - q1[k];
        zz += (rot[1][k] * rot[1][k]);
     }
     if(fabs(zz) < tol_sq) 
      {
       *msg = MSINARG;
       goto wrapup;
      }
  }

  status = BScrossp(&rc,rot[0],rot[1],rot[2]);
  status = BSnorvec(&rc,rot[2]);
  status = BScrossp(&rc,rot[2],rot[0],rot[1]);
  status = BSnorvec(&rc,rot[0]);
  status = BSnorvec(&rc,rot[1]);

  for(k=0; k<3; k++)
  {
     vv[0][k] = q1[k];
     vv[1][k] = q2[k];
     vv[2][k] = q4[k];
  }

  forward = TRUE;
  kd = 0;
  j = 3;
  status = BNrot_ele(&rc,&kd,&forward,rot,q1,&j,vv);

  if( (vv[2][1] <= dist_tol) || (vv[1][0] <= dist_tol) )
  {
   *msg = MSINARG;
   goto wrapup;
  }

  v_ratio = vv[2][1]  / (vd - vs);
  u_ratio = vv[1][0]/ ( ud - us );
  shift_rate = vv[2][0] / vv[2][1];

  for(iii=0; iii < np; iii++)
  {
    /*
     * perform (u,v) space translation and scaling for y coordinate
     */

     xyz[iii][1] = (uv[iii][1] - vs) * v_ratio;  

    /*
     * perform (u,v) space translation, scaling and shearing for
     * x coordinate.
     */

    xyz[iii][0] = (uv[iii][0] - us) * u_ratio + xyz[iii][1] * shift_rate;
    xyz[iii][2] = 0.;

  }

  /*
   * Rotate  and translate to bring it into model space.
   */

  forward = FALSE;
  short_np = np;
  status = BNrot_ele(&rc,&kd,&forward,rot,q1,&short_np,xyz);

/*
 * eof
 */
 wrapup:
  if (1 & *msg)
   return(TRUE);
  else
   return(FALSE);  
 }
  



/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME   BNrot_ele
 
     Abstract:
              This function accepts a point,curve or surface and 
              transforms it from an old coordinate system to a new
              one, or the backward.
-----
%SC%

     status = BNrot_ele(rc,ele_typ,forward,q,pzero,np,ptr)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        -----------------------------------
     *ele_typ      IGRshort	      0 for points
				      1 for curve
                                      2 for surface
     *forward      IGRboolean	      TRUE - if old to new
				      FALSE - if new to old
     q[3][3]      IGRdouble           rotation matrix for transformation
     pzero        IGRpoint            translation vector to old system
     *np	  IGRshort            number of points (if ele_typ = 0)
     ptr          IGRint

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        -----------------------------------
     ptr
     rc           BSrc               return code message
     status(boolean) = true           - if successful
                     = false          - if an error occurred

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:  
                 This function expects weighted poles on curve and on
            surface

-----
%CH%
     CHANGE HISTORY:
        
        DLB  04/25/91  : Removed strange union structure and just used
                         double ptr.  Apogee didn't like the d[][3] in the
                         union.
        STW  06/08/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

         This function transforms a point set, a curve or a surface
         in the old system by transforming each of its poles.

----*/
/*EH*/

static IGRboolean BNrot_ele(rc,ele_typ,forward,q,pzero,np,ptr)

IGRshort *ele_typ,*np;
IGRint ptr;
IGRboolean *forward;
IGRpoint pzero;
IGRdouble q[3][3];
IGRlong   *rc;                /* OUTPUT- COMPLETION CODE                     */
    {
     IGRboolean status,rat;
     struct IGRbsp_curve *curve;
     struct IGRbsp_surface *surf;
     IGRint i,j,k,num;
     IGRpoint xyz;
     IGRdouble *p1,*p2,*pol,*wet;

#if TALK_TO_DLB_BEFORE_BEING_BRAVE_ENOUGH_TO_DO_THIS_STRANGE_STUFF
     union
     {
       IGRdouble *s;
       IGRdouble d[][3];
     } *pt;
#else
     IGRdouble *d;
#endif

     status=TRUE;        /* initialize status and return codes   */
     *rc=MSSUCC;

     if( *ele_typ == 0 )
     {
        pol = (IGRdouble *) ptr;
        num = *np;
        rat = FALSE;
     }
     if( *ele_typ == 1 )
     {
        curve = (struct  IGRbsp_curve *) ptr;
        num = curve->num_poles;
        rat = curve->rational;
        pol = curve->poles;
        wet = curve->weights;
     }
     if( *ele_typ == 2 )
     {
        surf = (struct IGRbsp_surface *) ptr;
        num = surf->u_num_poles * surf->v_num_poles;
        rat = surf->rational;
        pol = surf->poles;
        wet = surf->weights;
     }
#if TALK_TO_DLB_BEFORE_BEING_BRAVE_ENOUGH_TO_DO_THIS_STRANGE_STUFF
     pt = pol;
#else
     d = pol;
#endif

     if( rat )
     {
         p1 = pol;
         p2 = wet;
         for(i=0; i < num; i++)
         {
            *p1++ /= *p2;
            *p1++ /= *p2;
            *p1++ /= *p2;
            p2++;
         }
     }

     if( *forward )
     {
         for(i=0; i < num; i++)
         {
            for(k=0; k<3; k++)
            {
#if TALK_TO_DLB_BEFORE_BEING_BRAVE_ENOUGH_TO_DO_THIS_STRANGE_STUFF
               pt->d[i][k] -= pzero[k];
#else
               d[i*3 + k] -= pzero[k];
#endif               
            }
         }
         for(i=0; i < num; i++)
         {
            for(j=0;j < 3; j++)
            {
               xyz[j] = 0.0;
               for(k=0; k<3; k++)
               {
#if TALK_TO_DLB_BEFORE_BEING_BRAVE_ENOUGH_TO_DO_THIS_STRANGE_STUFF
                  xyz[j] += (pt->d[i][k] * q[j][k]);
#else
                  xyz[j] += (d[i*3 + k] * q[j][k]);
#endif
               }
            }
            for(j=0;j < 3; j++)
            {
#if TALK_TO_DLB_BEFORE_BEING_BRAVE_ENOUGH_TO_DO_THIS_STRANGE_STUFF
               pt->d[i][j] = xyz[j]; 
#else
               d[3*i + j] = xyz[j];
#endif
            }
         }
     }

     else
     {
         for(i=0; i < num; i++)
         {
            for(j=0;j < 3; j++)
            {
               xyz[j] = 0.0;
               for(k=0; k<3; k++)
               {
#if TALK_TO_DLB_BEFORE_BEING_BRAVE_ENOUGH_TO_DO_THIS_STRANGE_STUFF
                  xyz[j] += (pt->d[i][k] * q[k][j]);
#else                  
                  xyz[j] += (d[3*i + k] * q[k][j]);
#endif
               }
            }
            for(j=0;j < 3; j++)
            {
#if TALK_TO_DLB_BEFORE_BEING_BRAVE_ENOUGH_TO_DO_THIS_STRANGE_STUFF
               pt->d[i][j] = xyz[j];
#else
               d[3*i + j] = xyz[j];
#endif
            }
         }
         for(i=0; i < num; i++)
         {
            for(k=0; k<3; k++)
            {
#if TALK_TO_DLB_BEFORE_BEING_BRAVE_ENOUGH_TO_DO_THIS_STRANGE_STUFF
               pt->d[i][k] += pzero[k];
#else
               d[3*i + k] += pzero[k];
#endif
            }
         }
     }

     if( rat )
     {
         p1 = pol;
         p2 = wet;
         for(i=0; i < num; i++)
         {
            *p1++ *= *p2;
            *p1++ *= *p2;
            *p1++ *= *p2;
            p2++;
         }
     }
     return(status);
    }

/*
DESCRIPTION

  Given a surface, this function decides if linear mapping
  is possible or not.
  The following steps are taken in deciding whether a curve
  can be linearly mapped on to a surface or not.

  1. u as well as v order is 2.
  2. surface is planar.
  3. surface is non rational.
  4. if num of u_poles and the number of v_poles are 2:
       o length of opposite sides of the polygon are equal.

     else ( u_num_poles > 2 || v_num_poles > 2)

       o the polygons are collinear in u as well as in v direction.
       o the opposite segments lengths are equal in u as well as in
         v direction.
       o knots are uniformally distributed.

RETURN VALUES
	linear_map_ok	TRUE	linear mapping is possible
			FALSE	surface does not satisfy
				linear mapping criterion.

HISTORY
	RC	05/29/87	Creation Date
*/

IGRboolean EFis_linear_map_ok (
msg,				/* return code */
surface,			/* surface geometry */
linear_map_ok			/* return code stating if linear mapping
				   is o.k. or not */
)
IGRlong			*msg;
struct IGRbsp_surface	*surface;
IGRboolean		*linear_map_ok;

{
  IGRdouble	*poles, *u_knots, *v_knots, dot_product, cum_vec_length;
  IGRdouble	u_poly_length, test_vec[3], cum_vec[3], nor_cum_vec[3];
  IGRdouble 	u_seg, u_seg_test, v_seg, v_seg_test, v_poly_length;
  IGRdouble	tol;
  extern   IGRdouble	sqrt();
  extern IGRdouble   fabs();
  IGRint  	i, j, jj, k, u_ptr, v_ptr, ptr, v_inc;
  IGRlong	u_num_poles, v_num_poles;
  IGRlong 	msg_loc;
  IGRshort	u_order, v_order;
  IGRboolean	status; 

  *linear_map_ok = TRUE;
  *msg = MSSUCC;
  status = BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, tol);

  if (!((surface->u_order == 2) &&
	(surface->v_order == 2) &&
	(surface->planar) &&
	(!surface->rational) ))
  {
	*linear_map_ok = FALSE;
	goto wrapup;
  }

  poles = surface->poles;
  u_num_poles = surface->u_num_poles;
  v_num_poles = surface->v_num_poles;
  u_knots = surface->u_knots;
  u_order = surface->u_order;
  v_knots = surface->v_knots;
  v_order = surface->v_order;

  u_ptr = surface->u_num_poles * 3;
  u_poly_length = 0;
  for (i = 0; i < 3; i++)
	u_poly_length += (poles[u_ptr - 3 + i]  - poles[i] ) *
			 (poles[u_ptr - 3 + i]  - poles[i] );
  u_poly_length = sqrt(u_poly_length);

  for (i = 0; i < v_num_poles; i++)
  {
	ptr = u_ptr * i;
	for (j = 0; j < 3; j++)
	{
	  cum_vec[j] = 0;
	  nor_cum_vec[j] = 0;
	}
        for (k = 1; (k < u_num_poles) && (*linear_map_ok); k++)
	{
	  
	   for (j = 0; j < 3; j++)
	   {
		test_vec[j] = poles[ptr+3+j] - poles[ptr+j];
		cum_vec[j] += test_vec[j];
	   }
	
	   /*
	    * Go in the v-direction and
   	    * check if the u-polygon segments are equal or not.
	    */
	 
	   if (i == 0)
	   {
	     u_seg = 0;

	     for (j = 0; j < 3; j++)
		   u_seg += test_vec[j] * test_vec[j];
             u_seg = sqrt(u_seg);

	     v_ptr = u_ptr + (k-1)*3;
	     for (jj = 1; (jj < v_num_poles)&&(*linear_map_ok);jj++)
	     {
		u_seg_test = 0;
		for (j = 0; j < 3; j++)
		    u_seg_test += ( poles[v_ptr+3+j] - poles[v_ptr+j]) 
				  * ( poles[v_ptr+3+j] - poles[v_ptr+j]) ;

                u_seg_test = sqrt(u_seg_test);

		if (fabs( u_seg_test - u_seg ) > tol)
                             *linear_map_ok = FALSE;
		v_ptr += u_ptr;
	      }

	   } /* if (i == 0) */
	   
	   /*
	    * check if the knots are uniformally distributed
	    */

	   cum_vec_length = 0;
	   for (j = 0; j < 3; j++)
	      cum_vec_length += cum_vec[j] * cum_vec[j];

	   cum_vec_length = sqrt(cum_vec_length);

	   if ((((u_poly_length == 0.0) ? 0.0 : fabs(cum_vec_length / u_poly_length)) - 
		u_knots[u_order+k-1]) > tol)*linear_map_ok = FALSE;

	   /*
	    * check if the polygons are collinear or not
	    */

	   status = BSnorvec (&msg_loc, test_vec);

	   if ( (k > 1) && (*linear_map_ok))
	   {
		dot_product = 0;
		for (j = 0; j < 3; j++)
		  dot_product += test_vec[j] * nor_cum_vec[j];

		if (dot_product < 0.999) *linear_map_ok = FALSE;
	   }

	   if (*linear_map_ok)
	   {
		for (j = 0; j < 3; j++)
			nor_cum_vec[j] += test_vec[j];
		status = BSnorvec(&msg_loc, nor_cum_vec);
	    }

	ptr += 3;

        } /* for (k = 1; (k < u_num_poles) && (*linear_map_ok);
	     k++) */

  } /* for (i = 0; i < v_num_poles; i++) */


  if (*linear_map_ok)
  {
    v_ptr = 3;
    v_inc = u_num_poles * 3;
    v_poly_length = 0;

    for (i = 0; i < 3; i++)
    {
	v_poly_length += (poles[v_inc*(v_num_poles-1)+i] - poles[i] ) 
			*(poles[v_inc*(v_num_poles-1)+i] - poles[i] );
    }
    v_poly_length = sqrt(v_poly_length);

    for (i = 0; i < u_num_poles; i++)
    {
	ptr = v_ptr * i;

	for (j = 0; j < 3; j++)
	{
	  cum_vec[j] = 0;
	  nor_cum_vec[j] = 0;
	}
	
        for (k = 1; (k < v_num_poles) && (*linear_map_ok); k++)
	{
	   for (j = 0; j < 3; j++)
	   {
		test_vec[j] = poles[ptr+v_inc+j] - poles[ptr+j];
		cum_vec[j] += test_vec[j];
	   }
	
	   /*
	    * Go in the u-direction and
   	    * check if the v-polygon segments are equal or not.
	    */
	 
	   if (i == 0)
	   {
	     v_seg = 0;
	     for (j = 0; j < 3; j++)
		   v_seg += test_vec[j] * test_vec[j];
             v_seg = sqrt(v_seg);
             
	     u_ptr = v_ptr + (k-1)*v_inc;
	     for (jj = 1; (jj < u_num_poles)&& (*linear_map_ok);jj++)
	     {
		v_seg_test = 0;
		for (j = 0; j < 3; j++)
		    v_seg_test += ( poles[u_ptr+v_inc+j] - poles[u_ptr+j])
			 * ( poles[u_ptr+v_inc+j] - poles[u_ptr+j]) ;

                v_seg_test = sqrt(v_seg_test);

		if (fabs( v_seg_test - v_seg ) > tol)
                            *linear_map_ok = FALSE;
		u_ptr += 3;
	      }

	   } /* if (i == 0) */

	   
	   /*
	    * check if the knots are uniformally distributed
	    */

	   cum_vec_length = 0;
	   for (j = 0; j < 3; j++)
	      cum_vec_length += cum_vec[j] * cum_vec[j];

	   cum_vec_length = sqrt(cum_vec_length);

	   if (fabs((cum_vec_length / v_poly_length)
		 - v_knots[v_order+k-1]) > tol)	*linear_map_ok = FALSE;

	   /*
	    * check if the polygons are collinear or not
	    */

	   status = BSnorvec (&msg_loc, test_vec);

	   if ( (k > 1) && (*linear_map_ok))
	   {
		dot_product = 0;
		for (j = 0; j < 3; j++)
		  dot_product += test_vec[j] * nor_cum_vec[j];

		if (dot_product < 0.999) *linear_map_ok = FALSE;
	   }

	   if (*linear_map_ok)
	   {
		for (j = 0; j < 3; j++)	nor_cum_vec[j] += test_vec[j];
		status = BSnorvec(&msg_loc, nor_cum_vec);
	    }

	ptr += v_inc;

        } /* for (k = 1; (k < v_num_poles) && (*linear_map_ok);
	     k++) */

    } /* for (i = 0; i < u_num_poles; i++) */
	
  } /* if (*linear_map_ok) */

wrapup:
    return (1);

}
