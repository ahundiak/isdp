/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:21 $
$Locker:  $
*/

/*
 *HISTORY:
 *	05/26/92  Use DPinvmxRT() to calculate inverse matrix faster -- [TW]
 *	10/6/93   Use DPinvmxRT() to calculate inverse matrix faster -- [TW]
 */

class implementation DPvw;

/* #define DPBG yes */

#include <stdio.h>
#include <FI.h>
#include <math.h>

#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"

#include "grmsg.h"
#include "DPview.h"
#include "bstypes.h"

/* prototype files */

#include "DPvw_cal.h"
#include "DPvwi.h"
#include "dpalignper.h"
#include "DPcvtpersp.h"
#include "DPinvmxRT.h"

#include "bsdistptpt.h"
#include "maptsxfor.h"
#include "marotmx.h"
#include "mainvmx.h"


/********** DPoffset() **************************************************/
/*									*/
/************************************************************************/

IGRdouble DPoffset(x1,x2,rub_ratio,max_value)

IGRdouble x1,x2;	/* x2 > x1 > 0 */
IGRdouble rub_ratio;   /* ratio of rubber line length to MAX length */
			/* a number between 0.0 and 1.0 */
IGRdouble max_value;

{
    IGRdouble y1,y2;
    IGRdouble xr, yr;
    IGRdouble offset;

    y2 = 1.0 / x2;		/* f(x) = 1/x */

    xr = x2 - (x2 - x1) * rub_ratio ;
    yr = 1.0 / xr - y2;			/* f(x) = 1/x */
    y1 = 1.0 / x1 - y2;	

    offset = (max_value / y1) * yr;

    return(offset);
}


/*********** DPcenter() *****************************************/
/*								*/
/* change center for the curr window	       			*/
/* After this call, the base_p struct and wrk_p need to be regenerated to reflect this change.*/
/****************************************************************/

DPcenter(msg,actz_pt,update,base_p,wrk_p)

IGRlong              *msg; 
IGRdouble            *actz_pt; 
int                  update;
struct DPbase_gg_t   *base_p;
struct DPview_wrk_t  *wrk_p;

{
    IGRlong num_points = 1;
    IGRdouble actz_pt_vw[3];
    IGRdouble d1;


    MAptsxform(msg, &num_points, (IGRdouble *)base_p->gg.wld_to_view, actz_pt,
               actz_pt_vw);

       /*
	*  calc coi
	*  If coi on the act_z plane, these can be omitted
	*/
	wrk_p->coi_vw[2] = base_p->coi_vw[2];
	d1 = base_p->coi_vw[2]/actz_pt_vw[2];  /* denominator will not be 0 in persp */
	d1 = (d1 > 0.0)? d1 : -d1;
	wrk_p->coi_vw[0] = actz_pt_vw[0] * d1;
	wrk_p->coi_vw[1] = actz_pt_vw[1] * d1;

    	MAptsxform(msg,&num_points,base_p->view_to_wld,
					wrk_p->coi_vw,wrk_p->coi);
	/* 
	 *  calc eye_pt
	 */
    	wrk_p->eye_pt_vw[0] = wrk_p->coi_vw[0];
    	wrk_p->eye_pt_vw[1] = wrk_p->coi_vw[1];
    	wrk_p->eye_pt_vw[2] = 0.0;
    	MAptsxform(msg,&num_points,base_p->view_to_wld,
				wrk_p->eye_pt_vw,wrk_p->eye_pt);

    DPwrk_to_gg(msg,wrk_p,NULL,update);

    return(TRUE);
}

/*******************************************************************/
/* from the two mouse points, calc new eye_pt and vw_volume, act_z */
/* and wld_to_view matrix in the wrk_p struct.			   */
/*******************************************************************/


DPcal_zoom(msg,factor,base_p,wrk_p,in_flags)

IGRlong              *msg;
IGRdouble            factor;
struct DPbase_gg_t   *base_p;
struct DPview_wrk_t  *wrk_p;
IGRint               in_flags;

{
    IGRlong  num_points;
    IGRdouble d1;
    IGRdouble new_eye;

    IGRdouble vw_x_ext,vw_y_ext;

   /*
    * auto mode processing
    */

    if(wrk_p->s_auto && (in_flags & EN_AUTO) )
    {
	if(wrk_p->ratio_x == 0.0) wrk_p->ratio_x = 1.0;

	if( factor > MAX_ZOOM_FACTOR) factor = MAX_ZOOM_FACTOR;
	else if( factor < INV_MAX_ZOOM_FACTOR) factor = INV_MAX_ZOOM_FACTOR;

	/* make the factor near 1, so won't zoom toooo fast */

	if( factor > 1.0)  /* zoom in */
	{
	    factor =  1.0 + (factor - 1.0) * INV_MAX_ZOOM_FACTOR;
	}
	else if(factor < 1.0 ) /* zoom out */
	{
	    factor = factor - INV_MAX_ZOOM_FACTOR;
	    factor = 0.5 + factor * 0.5 / (1.0 - INV_MAX_ZOOM_FACTOR);
	}

	wrk_p->ratio_x *= factor;
	if(wrk_p->ratio_x > MAX_DOUBLE ) wrk_p->ratio_x = MAX_DOUBLE;
	else if (wrk_p->ratio_x < INV_MAX_DOUBLE ) wrk_p->ratio_x = INV_MAX_DOUBLE;

	factor = wrk_p->ratio_x;
    }

#ifdef DEBUG
printf("DPcal_zoom: factor=%f\n",factor); fflush(stdout);
#endif

   /* parallel zoom */

    if( !(wrk_p->flags & IS_PERSP )) 
    {
	d1 = 1.0 / factor;

	vw_x_ext = (base_p->gg.vw_volume[3] - base_p->gg.vw_volume[0])*d1/2.0;
	vw_y_ext = (base_p->gg.vw_volume[4] - base_p->gg.vw_volume[1])*d1/2.0;

	wrk_p->vw_volume[0] = base_p->coi_vw[0] - vw_x_ext;
	wrk_p->vw_volume[3] = base_p->coi_vw[0] + vw_x_ext;
	wrk_p->vw_volume[1] = base_p->coi_vw[1] - vw_y_ext;
	wrk_p->vw_volume[4] = base_p->coi_vw[1] + vw_y_ext;

    } 
    else 
    {
       /*
    	* perspective zoom
    	*/

       	if( factor > 1.0 ) /* Zoom In */
      	{

	    /*
	     * adjust eye_pt, coi, vw_volume, and act_z 
	     */

	    if( wrk_p->s_target_locked == ON )
	    {
	    	/* new eye_pt in VCS1 */

	    	d1 = 1.0 / factor;

	    	wrk_p->eye_pt_vw[2] = base_p->coi_vw[2] * (1.0 - d1);

	    	new_eye = wrk_p->eye_pt_vw[2];

	       /*
	   	* try to keep near_plane unmoved. But if eye is over near_plane, 
	   	* then adjust the near_plane to the nearest. (Notice: impossible
	   	* to go over the far plane ) 
	   	*/

           	wrk_p->vw_volume[5] =  base_p->gg.vw_volume[5] - new_eye ;
	   	wrk_p->vw_volume[2] =  base_p->gg.vw_volume[2] - new_eye ;

                /* is new eye over both near and far plane*/

		if ((wrk_p->vw_volume[5] > -DISPLAY_DELTA) && 
                    (wrk_p->vw_volume[2] > -DISPLAY_DELTA))
                {
	      	    wrk_p->vw_volume[5] = -DISPLAY_DELTA; 
	  	    wrk_p->vw_volume[2] = -(DISPLAY_DELTA+DISPLAY_DELTA); 
                }
                else
                {
                   if (wrk_p->vw_volume[2] > -DISPLAY_DELTA) /* new eye over far clip plane */
                   {
                      wrk_p->vw_volume[2] = -(DISPLAY_DELTA + DISPLAY_DELTA);
                   }
                   else
                   {
                      if(wrk_p->vw_volume[5] > -DISPLAY_DELTA) /* new eye over near clip plane */
                      {
                         wrk_p->vw_volume[5] = wrk_p->vw_volume[2] * 0.01;
                      }
                   }
                   
                }

/*	old   	if(wrk_p->vw_volume[5] > -DISPLAY_DELTA) */
/*	      	    wrk_p->vw_volume[5] = -DISPLAY_DELTA; */

		/* act_z stay */
		
		wrk_p->act_z =  base_p->gg.act_z - new_eye ;
	    }

	    else /* target is not locked */
	    {
		/* new eye */

		d1 = factor;
	        wrk_p->eye_pt_vw[2] =  base_p->coi_vw[2] * (d1 - 1.0); 
	    	new_eye = wrk_p->eye_pt_vw[2];

	   	/* volume,coi,act_z go with eye */

	   	wrk_p->coi_vw[2] = new_eye + base_p->coi_vw[2];

    	   	num_points = 1;

    	   	MAptsxform(msg,&num_points,base_p->view_to_wld,
				wrk_p->coi_vw, wrk_p->coi);

 	   	/* act_z goes with eye automatically */
	    }
    	}
        else /* factor < 1, zoom out */
    	{
	    /* new eye_pt */

	    d1 = 1.0 / factor;
	    wrk_p->eye_pt_vw[2] =  -base_p->coi_vw[2] * (d1 - 1.0); 

	    new_eye = wrk_p->eye_pt_vw[2];

	    /*
	     * coi, vw_volume, and act_z 
	     */

	    if( wrk_p->s_target_locked == ON )
	    {
		/* near plane move with eye, far plane stay */

		wrk_p->vw_volume[5] = base_p->gg.vw_volume[5];

	   	wrk_p->vw_volume[2] = base_p->gg.vw_volume[2] - new_eye;

		/* act_z stay */
		
		wrk_p->act_z = base_p->gg.act_z - new_eye;

		/* wld coi not change */
	    }
	    else /* target is not locked */
	    {
	   	/* volume,coi,act_z move with eye */

	   	wrk_p->coi_vw[2] = new_eye + base_p->coi_vw[2];

    	   	num_points = 1;
    	   	MAptsxform(msg,&num_points,base_p->view_to_wld,
				wrk_p->coi_vw, wrk_p->coi);

		/* act_z already goes with eye */

	    }
    	}

       /*
     	* calc wrk_p->eye_pt
     	*/
    	num_points = 1;
    	MAptsxform(msg,&num_points,base_p->view_to_wld,
			wrk_p->eye_pt_vw, wrk_p->eye_pt);

    } /* end persp zoom */

    return(TRUE);
}



/************************************************************************/
/*									*/
/*	DPcal_around_coi()
/*									*/
/************************************************************************/
DPcal_around_coi(msg,rad_v,rad_h,base_p,wrk_p,in_flags)

IGRlong *msg;
IGRdouble rad_v,rad_h;
struct DPbase_gg_t *base_p;
struct DPview_wrk_t *wrk_p;
IGRint in_flags;

{
/*
	IGRshort  four=4; 
*/
	IGRdouble vec[3];
	IGRdouble rot_xmx[4][4];
	IGRdouble rot_zmx[4][4];
	IGRdouble wld_to_vw[4][4], vw_to_wld[4][4];
	IGRdouble vw_eye[3];
	IGRlong num_points = 1;

        IGRdouble vpn[3];
	IGRdouble vup[3],vxx[3];
	IGRdouble rotate[16],temp_mx[4][4];
	IGRdouble pi2;

    *msg = MSSUCC;

    /* rotate around z-axis matrix */

    if(wrk_p->s_auto && (in_flags & EN_AUTO) )
    {
	pi2 = PI * 2.0;
	wrk_p->ratio_x += rad_h / 10;
	wrk_p->ratio_x -= pi2 * (IGRint)(wrk_p->ratio_x/pi2);
	rad_h = wrk_p->ratio_x;

	wrk_p->ratio_y += rad_v / 10;
	wrk_p->ratio_y -= pi2 * (IGRint)(wrk_p->ratio_x/pi2);
	rad_v = wrk_p->ratio_y;

    }
    vec[0] = 0.0;
    vec[1] = 0.0;
    vec[2] = 1.0;
    MArotmx(msg,vec,&rad_h,(IGRdouble *)rot_zmx);

   /* rotate around  x-axis matrix */

    vec[0] = 1.0;	
    vec[1] = 0.0;
    vec[2] = 0.0;
    MArotmx(msg,vec,&rad_v,(IGRdouble *)rot_xmx);

   /* 
    * build VCS2: z:abs_up; y: -vpn (proj) OR -vup ; origin: coi
    *
    */

    MAptsxform(msg, &num_points, (IGRdouble *)base_p->gg.rotation,
               base_p->abs_up, vec);

    if(vec[2] > 0.999 || vec[2] < -0.999 )  /* abs_up parallel with vpn */
    {
	vec[0] = -base_p->gg.vup[0];
	vec[1] = -base_p->gg.vup[1];
	vec[2] = -base_p->gg.vup[2];

	DPalignper(msg, 0, base_p->abs_up, vec, base_p->gg.coi, rotate,
                   (IGRdouble *)wld_to_vw);
	/* MAinvmx(msg, &four, (IGRdouble *)wld_to_vw, (IGRdouble *)vw_to_wld); */
	DPinvmxRT((IGRdouble *)wld_to_vw, (IGRdouble *)vw_to_wld);
    }
    else
    {
	vec[0] = -base_p->gg.vpn[0];
	vec[1] = -base_p->gg.vpn[1];
	vec[2] = -base_p->gg.vpn[2];

	DPalignper(msg, 0, base_p->abs_up, vec, base_p->gg.coi, rotate,
                   (IGRdouble *)wld_to_vw);

	/* MAinvmx(msg, &four, (IGRdouble *)wld_to_vw, (IGRdouble *)vw_to_wld); */
	DPinvmxRT((IGRdouble *)wld_to_vw, (IGRdouble *)vw_to_wld);
    }


       /*
        * calc new eye point ( and vup ) 
        */

	/* represent eye in VCS2 */

    	MAptsxform(msg, &num_points, (IGRdouble *)wld_to_vw, base_p->gg.eye_pt,
                     vw_eye); 

	/* rotate vw_eye around x */ 

    	MAptsxform(msg, &num_points, (IGRdouble *)rot_xmx, vw_eye, vw_eye);

	if( ( vw_eye[0] < 0.001 && vw_eye[0] > -0.001 ) && 
	    ( vw_eye[1] < 0.001 && vw_eye[1] > -0.001 ) )   /* vw_eye on z-axis */
	{
	    /* just rotate vup, instead of vw_eye */

    	    MAptsxform(msg, &num_points, (IGRdouble *)rot_zmx, base_p->gg.vup,
                       wrk_p->vup);

	}
	else
	{
	    /* rotate vw_eye around z within system2 */

    	    MAptsxform(msg, &num_points, (IGRdouble *)rot_zmx, vw_eye, vw_eye);

	    /* new vup determined by abs_up,  no tilt */

	    OM_BLOCK_MOVE(base_p->abs_up,wrk_p->vup,sizeof(IGRdouble)*3);
	}


	/* represent vw_eye in wld */

    	MAptsxform(msg, &num_points, (IGRdouble *)vw_to_wld, vw_eye,
                   wrk_p->eye_pt); 

       /*
    	* calc vpn
    	*/
    	wrk_p->vpn[0] = wrk_p->coi[0] - wrk_p->eye_pt[0];
    	wrk_p->vpn[1] = wrk_p->coi[1] - wrk_p->eye_pt[1];
    	wrk_p->vpn[2] = wrk_p->coi[2] - wrk_p->eye_pt[2];

       /*
	*  indexing
	*/
	if(wrk_p->s_indexing && (in_flags & EN_INDEXING) )
	{
	   DPalignper(msg, 0, wrk_p->vpn, wrk_p->vup, wrk_p->eye_pt, rotate,
                      (IGRdouble *)temp_mx);

	    vxx[0] = rotate[0];
	    vxx[1] = rotate[1];
	    vxx[2] = rotate[2];

            vup[0] = rotate[4];
            vup[1] = rotate[5];
            vup[2] = rotate[6];

	    vpn[0] = - rotate[8];
	    vpn[1] = - rotate[9];
 	    vpn[2] = - rotate[10];

	    DPview_indexing(vup,vpn,vxx,
			wrk_p->vup,wrk_p->eye_pt,wrk_p->coi,
			MOVE_EYE,wrk_p->idx_view_tol, &(wrk_p->idx_flag) );

	    if( wrk_p->idx_flag )
	    {
    		wrk_p->vpn[0] = wrk_p->coi[0] - wrk_p->eye_pt[0];
    		wrk_p->vpn[1] = wrk_p->coi[1] - wrk_p->eye_pt[1];
    		wrk_p->vpn[2] = wrk_p->coi[2] - wrk_p->eye_pt[2];
	    }
	}


	if( ! (wrk_p->flags & IS_PERSP) )
	{
    	   wrk_p->vpn[0] = wrk_p->coi[0] - wrk_p->eye_pt[0];
    	   wrk_p->vpn[1] = wrk_p->coi[1] - wrk_p->eye_pt[1];
    	   wrk_p->vpn[2] = wrk_p->coi[2] - wrk_p->eye_pt[2];

	   DPalignper(msg,0,wrk_p->vpn,wrk_p->vup,wrk_p->eye_pt,
				wrk_p->rotation,wrk_p->wld_to_view);
	}

    return(TRUE);

}



/************************************************************************/
/*									*/
/*	DPcal_around_eye()
/*									*/
/************************************************************************/
DPcal_around_eye(msg,rad_v,rad_h,base_p,wrk_p,in_flags)

IGRlong             *msg;
IGRdouble           rad_v,rad_h;
struct DPbase_gg_t  *base_p;
struct DPview_wrk_t *wrk_p;
IGRint              in_flags;

{
	IGRlong  num_points = 1;
/*
	IGRshort four = 4;
*/

	IGRdouble vec[3];
	IGRdouble rot_xmx[4][4];
	IGRdouble rot_zmx[4][4];
	IGRdouble wld_to_vw[4][4], vw_to_wld[4][4],temp_mx[4][4];
	IGRdouble vw_coi[3];

        IGRdouble vpn[3],vup[3];
	IGRdouble vxx[3];
	IGRdouble rotate[16];


    *msg = MSSUCC;

    /* rotate around z-axis matrix */

    if(wrk_p->s_auto && (in_flags & EN_AUTO) )
    {
	wrk_p->ratio_x += rad_h / 10;
	wrk_p->ratio_x = ( wrk_p->ratio_x > MAX_DOUBLE)? MAX_DOUBLE:wrk_p->ratio_x;
	rad_h = wrk_p->ratio_x;

	wrk_p->ratio_y += rad_v / 10;
	wrk_p->ratio_y = ( wrk_p->ratio_y > MAX_DOUBLE)? MAX_DOUBLE:wrk_p->ratio_y;
	rad_v = wrk_p->ratio_y;
    }


    vec[0] = 0.0;
    vec[1] = 0.0;
    vec[2] = 1.0;
    MArotmx(msg, vec, &rad_h, (IGRdouble *)rot_zmx);
 
    /* rotate around  x-axis matrix */

    vec[0] = 1.0;	
    vec[1] = 0.0;
    vec[2] = 0.0;
    MArotmx(msg, vec, &rad_v, (IGRdouble *)rot_xmx);

   /* 
    * build VCS2: z:abs_up; y: -vpn (proj) OR -vup ; origin: coi
    *
    */

    MAptsxform(msg, &num_points, (IGRdouble *)base_p->gg.rotation,
                base_p->abs_up,vec);

    if(vec[2] > 0.999 || vec[2] < -0.999 )  /* abs_up parallel with vpn */
    {
	/* take vup (proj) as y-axis */

	vec[0] = -base_p->gg.vup[0];
	vec[1] = -base_p->gg.vup[1];
	vec[2] = -base_p->gg.vup[2];

 	DPalignper(msg, 0, base_p->abs_up, vec, base_p->gg.eye_pt,rotate,
                   (IGRdouble *)wld_to_vw);
	/* MAinvmx(msg, &four, (IGRdouble *)wld_to_vw, (IGRdouble *)vw_to_wld); */
	DPinvmxRT((IGRdouble *)wld_to_vw, (IGRdouble *)vw_to_wld);
    }
    else
    {
	/* take vpn (proj) as y-axis */

	vec[0] = base_p->gg.vpn[0];
	vec[1] = base_p->gg.vpn[1];
	vec[2] = base_p->gg.vpn[2];

	DPalignper(msg, 0, base_p->abs_up, vec, base_p->gg.eye_pt, rotate,
                   (IGRdouble *)wld_to_vw);
	/* MAinvmx(msg, &four, (IGRdouble *)wld_to_vw, (IGRdouble *)vw_to_wld); */
	DPinvmxRT((IGRdouble *)wld_to_vw, (IGRdouble *)vw_to_wld);
    }


       /*
        * calc new coi point ( and vup ) 
        */

	/* represent coi in VCS2 */

    	MAptsxform(msg, &num_points, (IGRdouble *)wld_to_vw, base_p->gg.coi,
                   vw_coi); 

	/* rotate vw_eye around x */ 

    	MAptsxform(msg, &num_points, (IGRdouble *)rot_xmx, vw_coi, vw_coi);

	if( ( vw_coi[0] < 0.001 && vw_coi[0] > -0.001 ) && 
	    ( vw_coi[1] < 0.001 && vw_coi[1] > -0.001 ) )   /* vw_coi on z-axis */
	{
	    /* just rotate vup, instead of vw_coi */

    	    MAptsxform(msg, &num_points, (IGRdouble *)rot_zmx, base_p->gg.vup,
                       wrk_p->vup);

	}
	else
	{
	    /* rotate vw_coi around z within system2 */

    	    MAptsxform(msg, &num_points, (IGRdouble *)rot_zmx, vw_coi, vw_coi);

	    /* new vup determined by abs_up,  no tilt */

	    OM_BLOCK_MOVE(base_p->abs_up,wrk_p->vup,sizeof(IGRdouble)*3);
	}


	/* represent vw_coi in wld */

    	MAptsxform(msg, &num_points, (IGRdouble *)vw_to_wld, vw_coi,
                                                                 wrk_p->coi); 

       /*
    	* calc vpn
    	*/
    	wrk_p->vpn[0] = wrk_p->coi[0] - wrk_p->eye_pt[0];
    	wrk_p->vpn[1] = wrk_p->coi[1] - wrk_p->eye_pt[1];
    	wrk_p->vpn[2] = wrk_p->coi[2] - wrk_p->eye_pt[2];



       /*
	*  indexing
	*/
	if(wrk_p->s_indexing && ( in_flags & EN_INDEXING) )
	{
	  /* 
	   * Since the probality that vpn and vup are parallel is so small,
	   * I don't check it here to save time.
	   */

	   DPalignper(msg, 0, wrk_p->vpn, wrk_p->vup, wrk_p->eye_pt, rotate,
                      (IGRdouble *)temp_mx);

	    vxx[0] = rotate[0];
	    vxx[1] = rotate[1];
	    vxx[2] = rotate[2];

            vup[0] = rotate[4];
            vup[1] = rotate[5];
            vup[2] = rotate[6];

	    vpn[0] = - rotate[8];
	    vpn[1] = - rotate[9];
 	    vpn[2] = - rotate[10];

	    DPview_indexing(vup,vpn,vxx,
			wrk_p->vup,wrk_p->eye_pt,wrk_p->coi,
			MOVE_TAR,wrk_p->idx_view_tol, &(wrk_p->idx_flag) );

	    if( wrk_p->idx_flag )
	    {
    		wrk_p->vpn[0] = wrk_p->coi[0] - wrk_p->eye_pt[0];
    		wrk_p->vpn[1] = wrk_p->coi[1] - wrk_p->eye_pt[1];
    		wrk_p->vpn[2] = wrk_p->coi[2] - wrk_p->eye_pt[2];
	    }
	}


	if( ! (wrk_p->flags & IS_PERSP) )
	{
	   DPalignper(msg,0,wrk_p->vpn,wrk_p->vup,wrk_p->eye_pt,
				wrk_p->rotation,wrk_p->wld_to_view);
	}


    return(TRUE);

}

/************************************************************************/
/*									*/
/*	DPcal_tilt()							*/
/*									*/
/************************************************************************/
DPcal_tilt(msg,rad,base_p,wrk_p, in_flags)

IGRlong             *msg;
IGRdouble           rad;
struct DPbase_gg_t  *base_p;
struct DPview_wrk_t *wrk_p;
IGRint              in_flags;

{
    IGRlong one = 1;
    IGRdouble vec[3];
    IGRdouble mtx[4][4];

    if(wrk_p->s_auto && (in_flags & EN_AUTO) )
    {
	wrk_p->ratio_x += rad / 10;
	wrk_p->ratio_x = ( wrk_p->ratio_x > MAX_DOUBLE)? MAX_DOUBLE:wrk_p->ratio_x;
	rad = wrk_p->ratio_x;
    }
    vec[0] = 0.0;
    vec[1] = 0.0;
    vec[2] = 1.0;
    MArotmx(msg, vec, &rad, (IGRdouble *)mtx);

    /* rotate (0,1,0) around viewing z within coi system */

    vec[0] = 0.0;
    vec[1] = 1.0;
    vec[2] = 0.0;
    MAptsxform(msg, &one, (IGRdouble *)mtx, vec, vec);

    /* represent in wld */

    MAptsxform(msg,&one,base_p->inv_rotation,vec,wrk_p->vup);

   /*
    *  indexing
    */

    if(wrk_p->s_indexing && (in_flags & EN_INDEXING) )
    {
	DPlevel_indexing(msg,base_p,wrk_p);
    }


    if( !(wrk_p->flags & IS_PERSP) )
    {
	   DPalignper(msg,0,wrk_p->vpn,wrk_p->vup,wrk_p->eye_pt,
				wrk_p->rotation,wrk_p->wld_to_view);
    }

    return(TRUE);

}
/************************************************************************/
/*									*/
/*	DPcal_vwangle()	-- adjust other values by the new angle in wrk_p */
/*									*/
/************************************************************************/
DPcal_vwangle(msg,base_p,wrk_p,in_flags)

IGRlong             *msg;
struct DPbase_gg_t  *base_p;
struct DPview_wrk_t *wrk_p;
IGRint              in_flags;

{
    IGRlong one = 1;
    IGRdouble half_angle,d1,new_eye;

    if( wrk_p->vw_angle > 3.14 )  
		wrk_p->vw_angle = 3.14;  /* max angle possible */ 

    if( wrk_p->vw_angle < MIN_ANGLE)
		wrk_p->vw_angle = MIN_ANGLE;  /* min angle possible */


    /*
     * Indexing, adjust the angle if needed
     */

    if(wrk_p->s_indexing && (in_flags & EN_INDEXING) )
    {
    	DPfocal_indexing(msg,wrk_p,&wrk_p->tmp_int);
    }

    	/* 
	 * calc tan_x, tan_y to adjust the pyramids 
	 */

	half_angle = wrk_p->vw_angle/2.0;

	if( base_p->scrn_width < base_p->scrn_length )
	{
	    wrk_p->tan_x = tan(half_angle);
	    wrk_p->tan_y = wrk_p->tan_x * 
				(base_p->scrn_length/base_p->scrn_width);
	}
	else
	{
	    wrk_p->tan_y = tan(half_angle);
	    wrk_p->tan_x = wrk_p->tan_y * 
				(base_p->scrn_width/base_p->scrn_length);
	}


       /*
	* if target is locked, adjust eye also to make the object same size
	* ( In fact, target is always locked. Maybe I should use a diff word )
	*/

	if( wrk_p->s_angle_zoom == OFF ) /* size of object locked, not real zoom */
	{
	    d1 = -base_p->tan_x * base_p->coi_vw[2];
	    wrk_p->coi_vw[2] = d1 / wrk_p->tan_x;		/* new dist */
	    wrk_p->eye_pt_vw[2] = wrk_p->coi_vw[2] + base_p->coi_vw[2];
	
	    /* new eye */

    	    MAptsxform(msg,&one,base_p->view_to_wld,wrk_p->eye_pt_vw,
					wrk_p->eye_pt);

	    new_eye = wrk_p->eye_pt_vw[2];

	    if(new_eye < 0.0)  /* same code as fly in */
	    {
           	wrk_p->vw_volume[5] = base_p->gg.vw_volume[5] - new_eye ;
	   	wrk_p->vw_volume[2] = base_p->gg.vw_volume[2] - new_eye ;

	   	if(wrk_p->vw_volume[5] > -DISPLAY_DELTA) /* new eye over near clip plane */
	      	    wrk_p->vw_volume[5] = -DISPLAY_DELTA;

	   	if(wrk_p->vw_volume[2] > -DISPLAY_DELTA) /* new eye over far clip plane */
	  	    wrk_p->vw_volume[2] = -DISPLAY_DELTA;

		/* act_z stay */
		
		wrk_p->act_z =  base_p->gg.act_z - new_eye ;

	    }
	    else  /* same code as fly out */
	    {

		/* near plane move with eye, far plane stay */

		wrk_p->vw_volume[5] = base_p->gg.vw_volume[5];

	   	wrk_p->vw_volume[2] = base_p->gg.vw_volume[2] - new_eye;

		/* act_z stay */
		
		wrk_p->act_z = base_p->gg.act_z - new_eye;

	    }
 	}

    return(TRUE);

}

/************************************************************************/
/*									*/
/*	DPcal_pan()							*/
/*									*/
/************************************************************************/
DPcal_pan(msg,dist_x,dist_y,base_p,wrk_p,in_flags)

IGRlong              *msg;
IGRdouble            dist_x,dist_y;
struct DPbase_gg_t   *base_p;
struct DPview_wrk_t  *wrk_p;
IGRint               in_flags;

{
    IGRlong    num_pts = 1;

    if(wrk_p->s_auto && (in_flags & EN_AUTO) )
    {
	wrk_p->ratio_x += (dist_x/10.0);
	wrk_p->ratio_y += (dist_y/10.0);
	dist_x = wrk_p->ratio_x;
	dist_y = wrk_p->ratio_y;
    }

        /* new eye_pt in viewing system */

    wrk_p->eye_pt_vw[0] = dist_x;
    wrk_p->eye_pt_vw[1] = dist_y;
    wrk_p->eye_pt_vw[2] = 0.0;

    MAptsxform(msg,&num_pts,base_p->view_to_wld,
			wrk_p->eye_pt_vw,wrk_p->eye_pt);

#ifdef NNNNNNN
    if( wrk_p->s_target_locked == OFF )	/* if target unlocked */
    {
    	wrk_p->coi_vw[0] = vec[0];
    	wrk_p->coi_vw[1] = vec[1];
    	wrk_p->coi_vw[2] = base_p->coi_vw[2]; 

    	MAptsxform(msg,&num_pts,base_p->view_to_wld,wrk_p->coi_vw,wrk_p->coi);
	
		/* all other viewing parameters not changed */
    }
    else   /* else if target is locked */  
    {
	   /* calc act_z */

        wrk_p->act_z = -BSdistptpt( &rc, wrk_p->eye_pt, wrk_p->coi);

	   /* calc volume, let far plane stay */

        wrk_p->vw_volume[2]= wrk_p->act_z + (base_p->gg.vw_volume[2] - 
                                             base_p->coi_vw[2]);

	   /* ??? vup may need to change because of tilt ??? */

    	   /* new vpn */

        wrk_p->vpn[0] = wrk_p->coi[0] - wrk_p->eye_pt[0];
        wrk_p->vpn[1] = wrk_p->coi[1] - wrk_p->eye_pt[1];
        wrk_p->vpn[2] = wrk_p->coi[2] - wrk_p->eye_pt[2];
    }
#endif

	/* only use target unlocked case, move view vector parallely */

    wrk_p->coi_vw[0] = wrk_p->eye_pt_vw[0];
    wrk_p->coi_vw[1] = wrk_p->eye_pt_vw[1];
    wrk_p->coi_vw[2] = base_p->coi_vw[2]; 

    MAptsxform(msg,&num_pts,base_p->view_to_wld,wrk_p->coi_vw,wrk_p->coi);


    if( ! (wrk_p->flags & IS_PERSP ) )
    {
        DPalignper(msg,0,wrk_p->vpn,wrk_p->vup,wrk_p->eye_pt,
				wrk_p->rotation,wrk_p->wld_to_view);
    }

    return(TRUE);

}


/**********************************************************************/


DPview_indexing(vup,vpn,vxx,r_vup,eye_pt,coi,adjust,idx_tol,idx_flag)

IGRdouble *vup;	 		/* I unit */
IGRdouble *vpn;  		/* I unit */
IGRdouble *vxx;			/* I unit */
IGRdouble *r_vup;		/* I/O : real up */
IGRdouble *eye_pt; 		/* I/O wld  */
IGRdouble *coi; 		/* I/O wld  */
IGRint 	  adjust;   		/* I: MOVE_EYE or MV_COI, or MV_VUP */
IGRdouble idx_tol;		/* I   cosin*/
IGRint    *idx_flag;		/* O   */

{

     IGRint i;

    *idx_flag = 0;
 
    /*
     * if vpn is almost parallel to a world axix, then the XY plane of the
     * pyramid is almost parallel to the plane perpendicular to that world
     * axis
     */

    /* check vpn with world axis */

    for(i=0;i<3;i++)
    {
    	if( vpn[i] > idx_tol )   		/* vpn // wld axis */
    	{
	    *idx_flag |= VIEW_XY_INDEXED;	/* XY side parallel to a wld plane */
	    DPalign_vpn(i,TRUE,eye_pt,coi,adjust);
	    break;
        }
        else if( vpn[i] < -idx_tol ) 	/* vpn // negative X-axis */
        {
	    *idx_flag |= VIEW_XY_INDEXED;
	    DPalign_vpn(i,FALSE,eye_pt,coi,adjust);
	    break;
        }
    }

   /*
    * keep vpn unchange, the view box can rotate around vpn, so
    * vup can also indexing.
    * check vup with world axis 
    */

    for(i=0;i<3;i++)
    {
    	if( vup[i] > idx_tol )   		/* vup // wld axis */
    	{
	    *idx_flag |= VIEW_XZ_INDEXED;
	    DPalign_vup(i,TRUE,r_vup,eye_pt,coi,adjust);
	    break;
	}
	else if(vup[i] < -idx_tol)
	{
	    *idx_flag |= VIEW_XZ_INDEXED;
	    DPalign_vup(i,FALSE,r_vup,eye_pt,coi,adjust);
	    break;
	}
    }

   /*
    * if two viewing axis (vpn, vup) are aligned,
    * the third one must be aligned. i.e.
    */

    if( (*idx_flag & VIEW_XY_INDEXED) && (*idx_flag & VIEW_XZ_INDEXED) )
    {
	*idx_flag = VIEW_XYZ_INDEXED; 
	goto wrapup;
    }

   /*
    * check if side planes are parallel to wld planes. Now it is impossible
    * that this third axis is aligned and one of the other viewing axis is
    * also aligned. Since if so, the whole system will be aligned and it would
    * have been found out previously. Hence, at this point, we know that the
    * above two viewing axis can never be aligned, and nothing changed so
    * far.
    */

    for(i=0;i<3;i++)
    {
    	if( vxx[i] > idx_tol || vxx[i] < -idx_tol)   /* vxx // wld axis */
    	{
	    *idx_flag |= VIEW_YZ_INDEXED;
	    DPalign_vxx(i,r_vup,eye_pt,coi,adjust);
	    break;
	}
    }
      
wrapup:

   return(TRUE);
}

/*********************************************************************/
/* Adjust eye_pt or coi to make the viewing vector parallel with the */
/* world axis 							     */
/*********************************************************************/

DPalign_vpn(axis,positive,eye_pt,coi,adjust)

IGRint     axis;    	 /* 0, 1, 2 : x,y,z axis */
IGRint     positive;	  /* FALSE: negative axis */
IGRdouble  *eye_pt;
IGRdouble  *coi;
IGRint     adjust;

{
    IGRint    i;
    IGRlong   msg;
    IGRdouble dist;
    IGRdouble delta = 0.0000001; /* deviate from the correct position. see comments below */

    dist = BSdistptpt(&msg, eye_pt, coi);

    if( ! positive )  dist = -dist;

    if(adjust == MOVE_EYE)
    {
	for(i=0;i<3;i++)
	{
	    if( i == axis )
	   	eye_pt[i] = coi[i] - dist;  /* if positive, coi > eye */
	    else
	    {
	      /* Avoid wrk_p->vpn and wrk_p->vup parallel, since it will
	       * be impossible to do DPalign_per(). Although we can use
	       * special way to get the rotation matrix when they are parallel,
	       * it takes valuable execution time. Here I change vpn a little,
	       * so that they are not parallel. This is not a perfect solution.  
	       */

		if( axis == 2 )  /* wld z axis, also wrk_p->vup in the current implementation!! */
		{
		   eye_pt[i] = coi[i] + delta;
		}
		else
		   eye_pt[i] = coi[i];
	    }
	}
    }
    else
    {
	for(i=0;i<3;i++)
	{
	    if( i == axis )
	   	coi[i] = eye_pt[i] + dist; /* if positive, coi > eye */
	    else
	    {
		/*  Avoid wrk_p->vpn and wrk_p->vup parallel.
		 *  see above comments
		 */

		if( axis == 2 )  /* wld z axis, also wrk_p->vup in the current implementation!! */
		{
		   coi[i] = eye_pt[i] + delta;
		}
		else
		   coi[i] = eye_pt[i];
	    }
	}
    }

    return(TRUE);

}

/********************************************************************/
/* VUP align to the world axis. Adjust eye_pt or coi to the same    */
/* world plane perpendicular to the VUP. 			    */
/* Notice: the distance from eye to coi changed a little	    */
/********************************************************************/

DPalign_vup(axis,positive_direction,r_vup,eye_pt,coi,adjust)

IGRint     axis;
IGRint     positive_direction;
IGRdouble  *r_vup;
IGRdouble  *eye_pt;
IGRdouble  *coi;
IGRint     adjust;

{

    IGRdouble unit;
    IGRint i;

    if(positive_direction) unit = 1.0;
    else		   unit = -1.0;

    for(i=0;i<3;i++)
    {
	if(axis == i)
	{
	    r_vup[i] = unit;

	    if( adjust == MOVE_EYE )
		eye_pt[i] = coi[i];
	    else
		coi[i] = eye_pt[i];
	}
	else
	{
            r_vup[i] = 0.0;
	}
    }
    return(TRUE);

}

/*******************************************************************/
/* if axis is X, then let VUP and vpn lies on the world YZ plane.  */
/* So vxx will be created as wanted.				   */
/* Other axis similar.						   */
/* Distance from eye to coi may changed a little		   */
/*******************************************************************/

DPalign_vxx(axis,r_vup,eye_pt,coi,adjust)

IGRint     axis;
IGRdouble  *r_vup;
IGRdouble  *eye_pt;
IGRdouble  *coi;
IGRint     adjust;

{
    IGRint i;

    for(i=0;i<3;i++)
    {    
	if( i== axis )
	{
	    r_vup[i] = 0.0;
	    if(adjust == MOVE_EYE)
	    {
		eye_pt[i] = coi[i];
	    }
	    else
	    {
		coi[i] = eye_pt[i];
	    }
	    break;
	}
    }

    return(TRUE);
}

/*********** DPlevel_indexing() *****************************************/
/*									*/
/* If vup is near the plane determined by abs_up and vpn, then set it   */
/* the plane so that the view level.					*/
/************************************************************************/

DPlevel_indexing(msg,base_p,wrk_p)

IGRlong             *msg;
struct DPbase_gg_t  *base_p;
struct DPview_wrk_t *wrk_p;

{
    IGRdouble vec[3];
    IGRlong   one = 1;

	wrk_p->idx_flag = 0;

       /* 
	* if vpn parallel with abs_up , index not calculated 
	* Note: following code assumed that abs_up=(0,0,1).
	*/

	if( ( wrk_p->vpn[0]<0.00001 && wrk_p->vpn[0] > -0.00001) &&
	    ( wrk_p->vpn[1]<0.00001 && wrk_p->vpn[1] > -0.00001) )
	{
	    goto wrapup;
	}

	/* check if indexing */

	MAptsxform(msg, &one, (IGRdouble *)base_p->gg.rotation, base_p->abs_up,
                   vec);

	if(vec[0] < 0.999 && vec[0] > -0.999)  /* not parallel */
	{
            DPalignper(msg,0,wrk_p->vpn,base_p->abs_up,wrk_p->eye_pt,
				wrk_p->rotation,wrk_p->wld_to_view);
    
	    MAptsxform(msg,&one,wrk_p->rotation,wrk_p->vup,vec);
	
	    if( (vec[1] > 0.0) && 
		( vec[0] < wrk_p->idx_horizon_tol && 
	          vec[0] > -wrk_p->idx_horizon_tol ) ) /* near the vertical plane,indexing happen */
	    {
		wrk_p->idx_flag =  LEVEL_HRZN_INDEXED;

		wrk_p->vup[0] = base_p->abs_up[0];
		wrk_p->vup[1] = base_p->abs_up[1];
		wrk_p->vup[2] = base_p->abs_up[2];
	    }  
	}

wrapup:
    return(TRUE);
}

/************* DPfocal_indexing() ***************************************/
/* wrk_p->vw_angle Degree is adjusted if indexing happen		*/ 
/************************************************************************/

DPfocal_indexing(msg,wrk_p,idx)

IGRlong *msg;
struct DPview_wrk_t  *wrk_p;
IGRint               *idx;

{
    IGRint     i;
    IGRdouble  angle,angle_lo,angle_hi;

    *msg = OM_S_SUCCESS;

    *idx = -1;    		/* indexing stop not found yet */

    wrk_p->idx_flag = 0;

    angle = wrk_p->vw_angle * 180 / PI ;  /* to degree */

    angle_lo = angle - wrk_p->idx_angle_tol;
    angle_hi = angle + wrk_p->idx_angle_tol;

    /* 
     * find the 1st angle within tolerance range.
     * Note: idx_angle[] is in decrease order.
     */


    for(i=0;i<NUM_FOCAL_INDEX;i++)
    {
	if(wrk_p->idx_angle[i] < angle_lo) break;  /* no longer possible */

	if(wrk_p->idx_angle[i] < angle_hi)
	{
	    wrk_p->idx_flag = FOCAL_INDEXED;
	    wrk_p->vw_angle = wrk_p->idx_angle[i] * PI / 180; /* to rad */
	    *idx = i;
	    break;
	}
    }
    return(TRUE);
}


/**************************************************************************/
/* Set angle to curr_win. If curr_win was parallel, change to perspective.*/
/* if was perspective and the new angle is 0, change to parallel. Give a  */
/* message about this on the message strip				  */
/**************************************************************************/


DPset_angle(msg,base_p,wrk_p,pyrmd_p,angle)  /* angle is already 0 <= angle <= 179.9 */

IGRlong               *msg;
struct DPbase_gg_t    *base_p;
struct DPview_wrk_t   *wrk_p;
struct DPpyramid_t    *pyrmd_p;
IGRdouble             angle;

{
    char buf[40]; 

    *msg = OM_S_SUCCESS;
    buf[0] = '\0';

    /* change negative angle to positive */ 

    angle = (angle < 0.0)? -angle : angle ;


    if( !(wrk_p->flags & IS_PERSP) && angle < MIN_ANGLE)
    {
	goto wrapup;		/* do nothing */
    }
    else if ( (wrk_p->flags & IS_PERSP) && angle < MIN_ANGLE)
    {
     	/* convert to paralllel */

	DPcvtpersp(msg,&wrk_p->windows[wrk_p->curr_win],DP_CVT_UPDATE);

	if( !(*msg & 1) )
	{
#ifdef DEBUG
	    fprintf(stderr,"DPcal_cmd.I: error in DPcvtpersp to paral\n");
#endif
	    goto wrapup;
	}		

        DPget_base_wrk(msg,base_p,wrk_p);  /* read in new gg */

	ex$message(buff=buf,msgnumb=GR_E_VwChToParallel);

	goto wrapup;    
    }
    else if ( !(wrk_p->flags & IS_PERSP)) 
    {
	 /* convert to perspective */

	DPcvtpersp(msg,&wrk_p->windows[wrk_p->curr_win],
				DP_CVT_TO_PERSP |DP_CAL);

	if( !(*msg & 1) )
	{
#ifdef DEBUG
	    fprintf(stderr,"DPcal_cmd.I: error in DPcvtpersp to persp \n");
#endif
	    goto wrapup;
	}		

        DPget_base_wrk(msg,base_p,wrk_p);  /* read in new gg */

	ex$message(buff=buf,msgnumb=GR_E_VwChToPersp);
    }

   /*
    * change persp. view angle 
    */

    wrk_p->vw_angle = angle * PI / 180.0 ;

    DPcal_vwangle(msg,base_p, wrk_p, 0);  /* adjust other values */

    DPwrk_to_gg(msg,wrk_p,NULL,TRUE);	  /* update window */

    /* get new base_p and wrk_p */

    DPget_base_wrk(msg,base_p,wrk_p);
    
   /*
    * display pyramids on all other windows's hilite plane
    */

    DPdp_pyramid(msg,pyrmd_p,wrk_p,wrk_p->view_to_wld,TRUE); /* TRUE: erase the hilite plane first */


wrapup:

    ex$message(field=ERROR_FIELD, in_buff = buf);


    return(TRUE);

}


end implementation DPvw;



