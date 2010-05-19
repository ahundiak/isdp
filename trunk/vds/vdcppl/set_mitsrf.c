/* $Id: set_mitsrf.c,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / set_mitsrf.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: set_mitsrf.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	 VDS 2.0 - PPM macro library - 92/07/09 (alc)
 */

#include <stdio.h>
#include "bstypes.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"


/*=========================================================================*/
/*   			evaluate the general surface 			   */
/*									   */
set_mitsrf( rc, cen, nor, pts, n_pts, ext_flag, cv, sf)
/*	    O , I  , I  , I  , I    , I       , I , O			   */
/*=========================================================================*/


IGRlong			*rc;
IGRdouble		*cen;
IGRdouble		*nor;
IGRdouble		*pts;
IGRint			n_pts;
IGRboolean		ext_flag;
struct IGRbsp_curve	*cv;
struct IGRbsp_surface   *sf;

{

extern	IGRdouble 	BSdotp();

IGRint			i, j, k, l, k1, k2, k3;
IGRint			num_p, num_p3;
IGRint			n_sec;
IGRdouble		nvec[3], vdif[3], dir[3];
IGRdouble		a, s, quot;




/*--------------------        beginning of code      ------------------------*/


	num_p = cv->num_poles;
	num_p3 = 3 * cv->num_poles;


	/* --- copy the first row --- */

	if( cv->rational != FALSE ){

	/*^ printf("cv->rational=%d\n",cv->rational); */

	    for(i=0;i<num_p3;i+=3){
		j = i / 3;
		k1 = i + 1;
		k2 = i + 2;
		sf->poles[i]  = cv->poles[i]  / cv->weights[j];
		sf->poles[k1] = cv->poles[k1] / cv->weights[j];
		sf->poles[k2] = cv->poles[k2] / cv->weights[j];
	    }
	}
	else{
	    for(i=0;i<num_p3;i+=3){
		k1 = i + 1;
		k2 = i + 2;
		sf->poles[i]   = cv->poles[i];
		sf->poles[k1]  = cv->poles[k1];
		sf->poles[k2]  = cv->poles[k2];
	    }
	}

	/* --- for each section project the poles in the next section --- */


	if( ext_flag == TRUE )  n_sec = n_pts - 2;
	else			n_sec = n_pts - 1;
	

	for( i=0; i<n_sec; i++){

	   BSmkvec(rc,vdif,cen,&(pts[3*(i+1)]));
	   BScrossp(rc,vdif,nor,nvec);
	   BSnorvec(rc,nvec);
	   BSmkvec(rc,dir,&(pts[3*i]),&(pts[3*(i+1)]));
	   BSnorvec(rc,dir);
	   s = BSdotp(rc,dir,nvec);

	   /*^ printf(" s =%f\n",s); */

	   for( k=0;k<num_p3;k+=3){

		k1 = i*num_p3 + k;
		k2 = i*num_p3 + k + 1;
		k3 = i*num_p3 + k + 2;

		vdif[0] = cen[0] - sf->poles[k1];
		vdif[1] = cen[1] - sf->poles[k2];
		vdif[2] = cen[2] - sf->poles[k3];

    		quot = ( vdif[0] * nvec[0] + 
			 vdif[1] * nvec[1] + 
			 vdif[2] * nvec[2] ) / s;

		sf->poles[k1+num_p3] = sf->poles[k1] + quot * dir[0];
		sf->poles[k2+num_p3] = sf->poles[k2] + quot * dir[1];
		sf->poles[k3+num_p3] = sf->poles[k3] + quot * dir[2];

	   }/* loop to project poles in section plane */

	}/* loop on each section */

	/* --- if the last section is just an extent then copy and move ---*/

	if( ext_flag == TRUE ){

	   BSmkvec(rc,vdif,&(pts[3*(n_pts-2)]),&(pts[3*(n_pts-1)]));
	    
	   /*^ printf("vdif=",vdif[0],vdif[1],vdif[2]); */
	    

	   i = num_p3*(n_pts-2);
	   j = num_p3*(n_pts-1);

	   for( k=i;k<j;k+=3){
		sf->poles[num_p3+k]   = sf->poles[k]   + vdif[0];
		sf->poles[num_p3+k+1] = sf->poles[k+1] + vdif[1];
		sf->poles[num_p3+k+2] = sf->poles[k+2] + vdif[2];
	   }
	}

	/* --- if the curve is rational apply the weights factor to the poles
	       and set up the sf->weights			        --- */

	if( cv->rational != FALSE ){
	     
		/*^ printf( " rational elem\n"); */

	    for(k=0;k<n_pts;k++){
		l = k * num_p3;
	    	for(i=0;i<num_p3;i+=3){
			j = i / 3;
			sf->poles[l+i]   = sf->poles[l+i]   * cv->weights[j];
			sf->poles[l+i+1] = sf->poles[l+i+1] * cv->weights[j];
			sf->poles[l+i+2] = sf->poles[l+i+2] * cv->weights[j];
	    	}
	    }
	    
	    for(k=0;k<n_pts;k++){
		i = k * num_p;
		for(l=0;l<num_p;l++) sf->weights[i+l] = cv->weights[l];
	    }
	}

	/* --- set sf structure	---*/

	sf->u_order       = cv->order;
	sf->v_order       = 2;
	sf->u_periodic    = FALSE;
	sf->v_periodic    = FALSE;
	sf->u_non_uniform = cv->non_uniform;
	sf->v_non_uniform = TRUE;
	sf->u_num_poles   = cv->num_poles;
	sf->v_num_poles   = n_pts;
	sf->u_num_knots   = cv->num_knots;
	sf->v_num_knots   = n_pts + 2;

	j = cv->num_knots;
	for(i=0;i<j;i++) sf->u_knots[i] = cv->knots[i];

	a = n_pts - 1;

	for(i=1;i<n_pts;i++) sf->v_knots[i+1] = i / a;
	sf->v_knots[0]       = 0.0;
	sf->v_knots[1]       = 0.0;
	sf->v_knots[n_pts]   = 1.0;
	sf->v_knots[n_pts+1] = 1.0;
	     
	/*^
		for(i=0;i<sf->v_num_knots;i++)
			 printf( "sf->v_knots[",i,"]=",sf->v_knots[i]); 
	*/
	     
	sf->rational       = cv->rational;
	sf->planar         = FALSE;
	sf->u_phy_closed   = cv->phy_closed;
	sf->v_phy_closed   = FALSE;
	sf->pos_orient	   = TRUE;
	sf->on_off         = FALSE;
	sf->num_boundaries = 0; 

	*rc = BSSUCC;
}
