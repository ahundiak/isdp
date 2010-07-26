/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  
 
		   	     
-----
%SC%

     VALUE = 

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     vt            pointer	  pointer to the view structure
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     mess	  IGRlong	 DPSUCC -- successful completion
				 DPVWNODEF -- no view structure for view
				 DPVUPPRLVPN -- vup and vpn are parallel, 
				 hence the matrices can not be computed

     VALUE (IGRboolean) = TRUE -- successful completion
		       FALSE -- unsuccessful ;  check message
-----
%MD%

     MODULES INVOKED:	MAzrotmx()
		      	MAyrotmx()
		        MAinvmx()	
 			MAptpldis()
			MAmulmx()
			MAidmx()
----- 
%NB%

     NOTES: 
-----
%CH%
     CHANGE HISTORY:
	
	MS  07/25/85  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

IF the transformations are in PHIGS standard they must first be
converted to IGR standards before calculations can be done.
----*/
/*EH*/

class implementation IGEgragad;

#include "grimport.h"
#include "igr.h"
#include "dpdef.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "maerr.h"

/* prototype files */
%safe
#include "dpsetrng.h"
#include "dpalignper.h"

#include "mainvmx.h"
#include "madabs.h"
#include "madotvc.h"
#include "macrossvc.h"
#include "maidmx.h"
#include "mamulmx.h"
#include "masincos.h"
#include "malnplise.h"
#include "maptsxfor.h"
%endsafe


 method DPcal_persp (IGRlong *mess)
{

IGRlong status = OM_E_ABORT;           
IGRlong num_points = 1;/* the num_points beins sent to be mult. by a matrix */
IGRshort n = 4;        /* the # of rows & columns in a square matrix, which  
			is passed to a routine to find its inverse        */

/* The following 3 variables are used as parameters for the MAmulmx
   where 2 matrices are multiplied together.                          */
IGRshort rows1 = 4;        /* the # of rows in the first matrix.        */
IGRshort col1_rows2 = 4; /* the # of columns in the first matrix which
			equals the # of rows in the second matrix.   */
IGRshort col2 = 4;      /* the # of columns in the second matrix.       */
IGRshort i;		     /* index variable */
IGRshort k;
IGRshort x;
IGRshort y;
IGRshort z;
IGRdouble pt[24];
IGRdouble scale[4][4];	     /* scale matrix for moving from view to viewport*/
IGRdouble temp_1mx[4][4];    /* these are temporary matrices */
IGRdouble temp_2mx[4][4]; 	

IGRdouble shear[4][4];       /* matrix for preforming a shear */
IGRdouble ss_mtx[4][4];
IGRdouble TransEYEPT[4][4];
IGRdouble per_trans[4][4];
IGRdouble right_handed[4][4];
IGRdouble half_way_mtx[4][4];
IGRdouble trans_ex[4][4];
IGRdouble viewport[4][4];
IGRdouble view_to_wld[4][4];
IGRdouble post_rotation[4][4];
IGRdouble half_angle;
IGRdouble sine;
IGRdouble m_cos;
IGRdouble x_scrn_ext;
IGRdouble y_scrn_ext;
IGRdouble p_plane_ext;
IGRdouble x_plane_ext;
IGRdouble y_plane_ext;
IGRdouble back_pln_dlt;
IGRdouble z_ext;
IGRdouble z_min;
IGRdouble z_scale = 1;
IGRdouble cross_prod[3];    /* cross product of VUP & VPN.               */
IGRdouble epsilon;	 /* a small # close to 0 that is used in comparisons */
IGRdouble tolerance;
IGRdouble t;
IGRdouble COI_plane[3];
IGRdouble tmp_pt[3];			
IGRdouble z_axis[3];
IGRdouble dot_prod;
IGRvector vw_vec1;
IGRvector coi;               /* the center of interest */
IGRvector fin_vrp;   	/* VRP after it has been multipled by the rotation 
			    matrices */
struct IGRplane proj_plane;
struct IGRline vw_vector;

/*****************************************************************************/

*mess = MSSUCC;


tmp_pt[0] = 0;
tmp_pt[1] = 0;
tmp_pt[2] = 0;

z_axis[0] = 0;
z_axis[1] = 0;
z_axis[2] = 1;

/* initalizing matrices */

if (!MAidmx(mess, (IGRdouble *)shear))
 {
    goto fini;
 }
OM_BLOCK_MOVE(shear,TransEYEPT,(sizeof(IGRdouble)*16));
OM_BLOCK_MOVE(shear,trans_ex,(sizeof(IGRdouble)*16));
OM_BLOCK_MOVE(shear,per_trans,(sizeof(IGRdouble)*16));
OM_BLOCK_MOVE(shear,scale,(sizeof(IGRdouble)*16));
OM_BLOCK_MOVE(shear,viewport,(sizeof(IGRdouble)*16));

epsilon = .00001;
if (ME.IGEgragad->gragad.vw_volume[2] < 0)
{
	ME.IGEgragad->gragad.vw_volume[2] = epsilon;
}
if (ME.IGEgragad->gragad.vw_volume[5] < 0)
{
	ME.IGEgragad->gragad.vw_volume[5] = epsilon;
}
if (ME.IGEgragad->gragad.act_z > ME.IGEgragad->gragad.vw_volume[5] ||
    ME.IGEgragad->gragad.act_z < ME.IGEgragad->gragad.vw_volume[2])
{
   	ME.IGEgragad->gragad.act_z = ME.IGEgragad->gragad.vw_volume[2] + ((ME.IGEgragad->gragad.vw_volume[5] - ME.IGEgragad->gragad.vw_volume[2]) / 2.0 );
}

    /* Checking to see if the VPN and VUP are parallel. If they are, then
       they are invalid.                                                   */  
    MAcrossvc(mess,ME.IGEgragad->gragad.vup,ME.IGEgragad->gragad.vpn,cross_prod);
    if ((cross_prod[0] == 0) && (cross_prod[1] == 0) && (cross_prod[2]
== 0))
     {
        *mess = DPVUPPRLVPN;	
    	goto fini;
     }

    for ( i = 0; i < 3; ++i )
    {
	TransEYEPT[i][3] = -ME.IGEgragad->gragad.eye_pt[i];
	vw_vec1[i] = ME.IGEgragad->gragad.coi[i] - ME.IGEgragad->gragad.eye_pt[i];
    }
    /* be sure that the view vector and the vpn are going in approximately 
	the same direction */
    if (!MAdotvc(mess,vw_vec1,ME.IGEgragad->gragad.vpn,&dot_prod))
    {
	goto fini;
    }
    if (dot_prod < 0 )
    {
	ME.IGEgragad->gragad.vpn[0] = -ME.IGEgragad->gragad.vpn[0];
	ME.IGEgragad->gragad.vpn[1] = -ME.IGEgragad->gragad.vpn[1];
	ME.IGEgragad->gragad.vpn[2] = -ME.IGEgragad->gragad.vpn[2];
    }
    DPalignper( mess, (DPRIGHT_ROT | DPLEFT_VIEW), ME.IGEgragad->gragad.vpn,
		ME.IGEgragad->gragad.vup, ME.IGEgragad->gragad.eye_pt,
		(IGRdouble *)ME.IGEgragad->gragad.rotation, 
		(IGRdouble *)half_way_mtx);

     DPsetrng(mess, (IGRdouble *)half_way_mtx, &ME.IGEgragad->gragad.vv_range_chk);
     DPsetrng(mess, (IGRdouble *)half_way_mtx, &ME.IGEgragad->gragad.range_chk);

    /**************** CALCULATING THE POST ROTATION MATRIX ******************/

    if (!MAptsxform(mess, &num_points, (IGRdouble *)half_way_mtx,
			ME.IGEgragad->gragad.vrp, fin_vrp))
     	 {
	    goto fini;
	 }     	

    if (!MAptsxform(mess, &num_points, (IGRdouble *)half_way_mtx,
			ME.IGEgragad->gragad.coi, coi))
     	 {
	    goto fini;
	 }     	
	vw_vector.point1 = tmp_pt;
	vw_vector.point2 = coi;
	proj_plane.point = fin_vrp;
	proj_plane.normal = z_axis; 
	tolerance = 0.00000001;
	if (!MAlnplisect (mess, &vw_vector, &proj_plane, &tolerance, COI_plane, &t))
	{
#ifdef DEBUG
	    printf("error in line plane intersect");
#endif
	    goto fini;
	}
	if (((COI_plane[0] != 0)||(COI_plane[1] != 0))&&( fin_vrp[2] != 0 ))
	 {
	    shear[0][2] = COI_plane[0]/fin_vrp[2];
            shear[1][2] = COI_plane[1]/fin_vrp[2];
	 }
	ME.IGEgragad->gragad.vw_angle= MAdabs(mess,&ME.IGEgragad->gragad.vw_angle);
	half_angle = ME.IGEgragad->gragad.vw_angle / 2.0;
	if (!MAsincos(mess,&half_angle,&sine,&m_cos) )
	{
	    goto fini;
	}
	back_pln_dlt = 	(sine/m_cos) * ME.IGEgragad->gragad.vw_volume[5];
	back_pln_dlt = MAdabs (mess, &back_pln_dlt);
	x_scrn_ext = ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep;
	y_scrn_ext = ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep;
	p_plane_ext = 2.0 * (sine/m_cos) * fin_vrp[2];
	p_plane_ext = MAdabs (mess,&p_plane_ext);	
	if (y_scrn_ext > x_scrn_ext)
	{

	    x_plane_ext = p_plane_ext;
	    y_plane_ext = p_plane_ext / x_scrn_ext * y_scrn_ext;
	    ME.IGEgragad->gragad.vw_volume[0] = -back_pln_dlt;
	    ME.IGEgragad->gragad.vw_volume[3] = back_pln_dlt;
	ME.IGEgragad->gragad.vw_volume[1] = -back_pln_dlt / x_scrn_ext * y_scrn_ext;
	ME.IGEgragad->gragad.vw_volume[4] = back_pln_dlt / x_scrn_ext * y_scrn_ext;

	}
	else
	{
	    y_plane_ext = p_plane_ext;
	    x_plane_ext = p_plane_ext / y_scrn_ext * x_scrn_ext;
	    ME.IGEgragad->gragad.vw_volume[0] = -back_pln_dlt / y_scrn_ext * x_scrn_ext;
	    ME.IGEgragad->gragad.vw_volume[3] = back_pln_dlt/ y_scrn_ext * x_scrn_ext;
	ME.IGEgragad->gragad.vw_volume[1] = -back_pln_dlt;
	ME.IGEgragad->gragad.vw_volume[4] = back_pln_dlt;

	}

	scale[0][0] = 2* fin_vrp[2] / 
			(x_plane_ext * ME.IGEgragad->gragad.vw_volume[5]); 
	scale[1][1] = 2* fin_vrp[2] /
			(y_plane_ext * ME.IGEgragad->gragad.vw_volume[5]); 

	scale[2][2] = 1 /  ME.IGEgragad->gragad.vw_volume[5]; 

	ME.IGEgragad->gragad.vvol_viewport_scale = x_scrn_ext / x_plane_ext;
	ME.IGEgragad->gragad.vvol_viewport_scale = y_scrn_ext / y_plane_ext;

	z_min = ME.IGEgragad->gragad.vw_volume[2] / ME.IGEgragad->gragad.vw_volume[5];

	per_trans[2][2] = 1/(1 - z_min);

	per_trans[2][3] = -z_min / (1 - z_min);

	per_trans[3][2] = 1;

	per_trans[3][3] = 0;

	if (!MAmulmx(mess, &rows1, &col1_rows2, &col2, (IGRdouble *)scale,
			(IGRdouble *)shear, (IGRdouble *)ss_mtx))
	 {
	    goto fini;
	 }

	if (!MAmulmx(mess, &rows1, &col1_rows2, &col2, (IGRdouble *)per_trans, 
			(IGRdouble *)ss_mtx, (IGRdouble *)post_rotation))
	 {
	    goto fini;
	 }

/************* CALCULATING THE FINAL MATRIX ********************/

/* changing to back to a right handed coordinate system by swapping the y's */
if (!MAidmx(mess, (IGRdouble *)right_handed))
 {
    goto fini;
 }
    right_handed[1][1] = -1; 

 if (!MAmulmx(mess, &rows1, &col1_rows2, &col2, (IGRdouble *)right_handed,
		(IGRdouble *)post_rotation, (IGRdouble *)temp_1mx))
 {
    goto fini;
 }
 
 if (!MAmulmx(mess, &rows1, &col1_rows2, &col2, (IGRdouble *)temp_1mx,
		(IGRdouble *)half_way_mtx, 
		(IGRdouble *)ME.IGEgragad->gragad.wld_to_view))
 {
    goto fini;
 }
 ME.IGEgragad->gragad.flags &= ~AXIS_WLD_ALIGN;

/******** TRYING TO CALCULATE VIEWPORT PARAMETERS AND INVERSES ************/

if (p_plane_ext == x_plane_ext)
{
   z_scale = x_scrn_ext / x_plane_ext;
}
if (p_plane_ext == y_plane_ext)
{
   z_scale = y_scrn_ext / y_plane_ext;
}
    ME.IGEgragad->gragad.dit_clip_range[0] = ME.IGEgadget->min_x_dep;
    ME.IGEgragad->gragad.dit_clip_range[1] = ME.IGEgadget->min_y_dep;
    ME.IGEgragad->gragad.dit_clip_range[2] = 0;
    z_ext = ME.IGEgragad->gragad.vw_volume[5] - ME.IGEgragad->gragad.vw_volume[2];
    ME.IGEgragad->gragad.dit_clip_range[3] = ME.IGEgadget->max_x_dep;
    ME.IGEgragad->gragad.dit_clip_range[4] = ME.IGEgadget->max_y_dep;
    ME.IGEgragad->gragad.dit_clip_range[5] = z_ext * z_scale;
    viewport[0][0] = x_scrn_ext / 2.0;
    viewport[1][1] = y_scrn_ext / 2.0;
    viewport[2][2] = z_ext * z_scale ;
/* remember that the scaling in the end should be equal */
viewport[0][3] = (ME.IGEgadget->max_x_dep + ME.IGEgadget->min_x_dep) / 2.0;
viewport[1][3] = (ME.IGEgadget->max_y_dep + ME.IGEgadget->min_y_dep) / 2.0;
viewport[2][3] = ME.IGEgragad->gragad.dit_clip_range[2];

 if (!MAmulmx(mess, &rows1, &col1_rows2, &col2, (IGRdouble *)viewport,
		(IGRdouble *)temp_1mx, (IGRdouble *)temp_2mx))
 {
    goto fini;
 }
 tmp_pt[0] = 0.0;
 tmp_pt[1] = 0.0;
 tmp_pt[2] = ME.IGEgragad->gragad.act_z;
 if (!MAptsxform(mess, &num_points, (IGRdouble *)temp_2mx, tmp_pt, tmp_pt))
     	 {
	    goto fini;
	 }     	
 ME.IGEgragad->gragad.act_z_screen = tmp_pt[2];
if (!MAmulmx(mess, &rows1, &col1_rows2, &col2, (IGRdouble *)viewport,
		(IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
		(IGRdouble *)ME.IGEgragad->gragad.wld_to_viewport))
  {
    goto fini;
  }

k=0;
   for( z = 0; z < 2; z++)
   {
      for( y = 0; y < 2; y++)
      {
         for ( x = 0; x < 2; x++)
         {
             pt[k++] = (x) ? ME.IGEgragad->gragad.dit_clip_range[3]: ME.IGEgragad->gragad.dit_clip_range[0];
             pt[k++] = (y) ? ME.IGEgragad->gragad.dit_clip_range[4]: ME.IGEgragad->gragad.dit_clip_range[1];
             pt[k++] = (z) ? ME.IGEgragad->gragad.dit_clip_range[5] :
                                           ME.IGEgragad->gragad.dit_clip_range[2];
         }
      }
   }
 
MAinvmx(mess, &n, (IGRdouble *)ME.IGEgragad->gragad.wld_to_viewport,
		(IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld);
num_points = 8;
    if (!MAptsxform(mess, &num_points, (IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld,
			pt, pt))
     	 {
	    goto fini;
	 }     	
if (!MAinvmx(mess, &n, (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
			(IGRdouble *)view_to_wld))
   {
        goto fini;
    }

status = OM_S_SUCCESS;

fini:
     return(status);
}
end implementation IGEgragad;
