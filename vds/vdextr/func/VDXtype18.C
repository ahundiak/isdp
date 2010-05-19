/* $Id: VDXtype18.C,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXtype18.C
 *
 * Description:
 *		Support function for extract for review command.
 *
 *	VDXtype18 :
 *	This utility function formats an IGDS type 18 surface elements
 *	according to the defining geometry, symbology and properties.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXtype18.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  13:58:34  pinnacle
 * for dynapipe
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/16/99        ylong           created
 *
 ***************************************************************************/


#include <stdio.h>
#include <math.h>
#include "exsysdep.h"
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "msdef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "dpdls.h"
#define VDX_TOL	0.0001
#define VDX_v_dot(v1,v2) ( (v1)[0]*(v2)[0] + (v1)[1]*(v2)[1] + (v1)[2]*(v2)[2] )
#define	VDX_PI	3.14159265
#define VDXasin(angle) (asin(angle))


VDXtype18( msg, file_des, dgn_buf, ele_buf, ele_size, 
	  class_name, num_profiles, types, num_pnts, pnts, 
	  symbology, properties, fill_bit, grgroup, scale, range )


IGRint			*msg;
IGRint			*file_des;
IGRchar			*dgn_buf;
struct IGDS_linestring	*ele_buf;
IGRint			*ele_size;
IGRchar			*class_name;
IGRint			num_profiles;
IGRint			*types;
IGRint			*num_pnts;
IGRdouble		*pnts;
struct GRsymbology	*symbology;
IGRushort 		*properties;
IGRboolean		*fill_bit;
IGRshort		*grgroup;
IGRint			scale;
IGRdouble		*range;

{
    IGRint		i;			/* lcv 			*/
    IGRint		j;      		/* lcv 			*/
    IGRint		m;			/* lcv 			*/
    IGRint		n;			/* lcv 			*/
    IGRint		xx;			/* lcv 			*/
    IGRint		k;
    IGRdouble		quaternions[4];
    IGRdouble		scalRange[6];
    IGRint		block_ptr;
    IGRint		byte_ptr;
    IGRshort		type;			/* igds element type 	*/
    IGRshort		write_mode;		/* mode for writing 	*/
    IGRlong		point[303];
    IGRlong		brc = TRUE;		/* return status 	*/
    IGRlong		name_msg;		/* add ele name	status	*/
    IGRlong		words_in_descript;
    IGRdouble		rad, center[3], matrix[16], sweep, opnts[12];
    IGRushort		privProp;

struct IGDS_18
{
    struct GUcommon_header_info	header;
    IGRshort 			wds_in_descript;
    IGRshort			num_elements;
    IGRshort 			surface_type; /* 0-9 */
} *surface_str;  

    struct IGDS_linestring	*linestring;

struct	type16_element
{
	struct GUcommon_header_info	header;
	IGRlong				start;
	IGRlong				sweep;
	unsigned long			primary[2];
	unsigned long			secondary[2];
	IGRlong				rotation_origin[10];
} *arc;
IGRint	wid = 0;
IGRint	tmp_num_profiles = 0;

	//printf("I'm in type18.C, num_profiles=%d\n",num_profiles);
	//fflush(stdout);

	if( num_profiles == 0 ) tmp_num_profiles = 4;
	else tmp_num_profiles = num_profiles;

	//printf("tmp_num_profiles=%d\n",tmp_num_profiles);

	for(xx=0;xx<16;xx++) matrix[xx] = 0.0;

    	*msg = GUsuccess;

    	/* scale the range */

	for(m=0;m<6;m++) scalRange[m] = range[m] * scale;

	/* words in descrip */

	wid = 0;
	//printf("about to add up wtf. tmp_num\n");

	for(m=0;m<tmp_num_profiles;m++)
	{
		if( types[m] == 0)
		{
			wid = wid + (num_pnts[m]*6+19);
		}else{
			wid = wid + 50;
		}
	}
	words_in_descript = wid + 6;
	//printf("words to follow in type18=%d\n",words_in_descript);

	/*
	 *  Format a type 18 surface header element.
	 */

	if( *fill_bit == 0) type = 18;
	else type = 19;
    	/*
     	 * call function to load header data.
    	 */

	privProp = *properties;
    	GUload_IGDSheader( msg, class_name, &type, symbology, &privProp,
		       	   scalRange, ele_buf );

	//printf("past GUload_IGDSheader\n");

	if ( *msg != GUsuccess )
    	{
	    brc = FALSE;
	    goto wrap_up;
    	}	    

	//printf("about to fill surface structure\n");

	surface_str = (struct IGDS_18 *) ele_buf;
	surface_str->header.words_to_follow = 19;
	surface_str->header.graphic_group = grgroup[3];
	surface_str->header.index_to_ae = 5;
	surface_str->wds_in_descript = (IGRushort) words_in_descript;
	surface_str->num_elements = tmp_num_profiles;
	surface_str->surface_type = types[tmp_num_profiles];

	/*
		printf("num_elements=%d, header.level=%d, prop=%d\n", 
		surface_str->num_elements, 
		surface_str->header.level,
		surface_str->header.properties);
		printf("type 18 elebuf words to follow=%d\n",ele_buf->header.words_to_follow);
	*/

	GRadd_dmrs_to_buf(&name_msg, grgroup, ele_buf);
	
	/*
	printf("after add DMRS words to follow=%d\n",ele_buf->header.words_to_follow);
	printf("num_elements=%d\n", surface_str->num_elements);
	*/
	/*
	 *  Write the surface header element to the file.
	 */

	*ele_size = (ele_buf->header.words_to_follow+2) * 2;
	write_mode = GUWRITE;

	brc = GUwrite_element(	msg, dgn_buf, 
				ele_buf, 
				&type,
				ele_size, file_des, 
				&write_mode, &block_ptr,
				&byte_ptr );
	/*
	printf("past write surface header msg=%d\n",brc);
	*/

     /*
      *	write surface boundary data
      */

    for(i=0;i<tmp_num_profiles;i++ )
    {

     if( types[i] == 0)
     {
	/* format a linestring here */

	type = 4;

        GUload_IGDSheader( msg, class_name, &type, symbology, 
			   properties, scalRange, ele_buf );

	if ( *msg != GUsuccess )
  	{
	    brc = FALSE;
	    goto wrap_up;
    	}	    


	/*
	 *  Calculate and set up some header information.
	 */

	linestring = (struct IGDS_linestring *) ele_buf;
	linestring->header.level |= 0x80; /* set complex bit */
	linestring->header.graphic_group = grgroup[3];
	linestring->header.type = type;

	if( i > 1 && num_profiles == 0) linestring->header.properties |= 4;

	linestring->header.words_to_follow = 17 + (num_pnts[i]*6);
	linestring->header.index_to_ae = linestring->header.words_to_follow - 14;
	linestring->lnstr.num_points = num_pnts[i];

	/*
	 *  Get the points out of the linestring object.
	 */

	m = 0;

	for(n=0;n<i;n++)m += num_pnts[n];

	m *= 3;

	for ( j = 0; j < num_pnts[i]*3; j ++ )
	{
		point[j] = GUnint ( pnts[m]*scale);
		GUswapint ( &point[j], &point[j] );
		m++;
	}

	memcpy(&(linestring->lnstr.pnts_ptr), (char *)point, num_pnts[i]*12 );
   }
   else
   {
	/* format an arc here */

	type = 16;

        GUload_IGDSheader( msg, class_name, &type, symbology, 
			   properties, scalRange, ele_buf );

	if ( *msg != GUsuccess )
  	{
	    brc = FALSE;
	    goto wrap_up;
    	}	    


	/*
	 *  Calculate and set up some header information.
	 */

	arc = (struct type16_element *) ele_buf;
	arc->header.level |= 0x80; /* set complex bit */
	arc->header.graphic_group = grgroup[3];
	arc->header.type = 16;
	arc->header.words_to_follow = 48;
	arc->header.index_to_ae = 34;

	if( i > 1 && num_profiles == 0) arc->header.properties |= 4; /* set rule line bit */

	arc->start =  GUnint( 0.0 );
	GUswapint ( &arc->start, &arc->start );

	m = 0;

	for(n=0;n<i;n++)m += num_pnts[n];

	m *= 3;

	for(xx=0; xx<12; xx++) opnts[xx]= pnts[m+xx] * scale;

	if( i == 2 && num_profiles == 0)
	{

		for(xx=0; xx<12; xx++) matrix[xx] = pnts[xx+m+12] * scale;

		for(xx=12; xx<15; xx++) matrix[xx] = 0.0;

		VDXradius1(&matrix[0],&matrix[3],&matrix[6],&matrix[9],
			&rad, center, matrix, &sweep);
		/*
		printf("\n\n\tCenter curve 4 [%lf, %lf, %lf]\n\n",
			center[0], center[1], center[2]);
		*/

	}

	VDXradius1(&opnts[0],&opnts[3],&opnts[6],&opnts[9],
		&rad, center, matrix, &sweep);

	//printf("\n\t\tin type18 sweep=%.3f\n",sweep);

	arc->sweep = GUnint ( ( (sweep/57.29577) * 360000.0)
				     / (VDX_PI / 180.0) );

	GUswapint ( &arc->sweep, &arc->sweep );

	/*
	*  load the primary and secondary axis
	*/

	flt32_to_fltvax ( 1, &rad, arc->primary );
	flt32_to_fltvax ( 1, &rad, arc->secondary );

	/*
	 *  load the quaternions
	*/

	GUrotmx_to_quat ( matrix, quaternions );
        for ( xx = 0; xx < 4; ++xx )
	{	   
		arc->rotation_origin[xx] = GUnint (quaternions[xx]);
		GUswapint ( &arc->rotation_origin[xx],
			    &arc->rotation_origin[xx] );
	}

	/*
	 *  load the origin of the arc
	 */

	flt32_to_fltvax ( 3, center, &arc->rotation_origin[4] );

	/*
	 *  Set the data for the arc here.
	 */

   } /* end of if(types[]) */


	/* check whether a user-defined linestyle is present */

        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(&name_msg, symbology->display_attr.style,
                              ele_buf);

        /*
         *  Write the element out to the file.
         */

	*ele_size = (ele_buf->header.words_to_follow+2) * 2;
	write_mode = GUWRITE;

	brc = GUwrite_element( msg, dgn_buf, ele_buf, &type, ele_size,
	    		       file_des, &write_mode, &block_ptr,
			       &byte_ptr );
    }

	
wrap_up:

	return(brc);

} /* end VDXtype18 */


int VDXradius1(p1, p2, p3, p4, rad, cen, matrix, sweep)
double p1[3], p2[3], p3[3], p4[3], *rad, cen[3], matrix[16], *sweep;
{

double	a, b, c, angle;
double	tmp1[3],tmp2[3],tmp3[3];
double	tmp4[3],tmp5[3],tmp6[3];
double	r, old_cen[3],r1,r2;
int	xx, msg;
IGRdouble dtmp=0.0;

	/* TR179900203 add this declaration to top */
	IGRdouble d = 0.0;

/*
	printf("INPUT to VDXradius1\n	X %lf, %lf, %lf\n	Y %lf, %lf, %lf\n	Z %lf, %lf, %lf\n	C %lf, %lf, %lf\n",
		matrix[0], matrix[4], matrix[8],
		matrix[1], matrix[5], matrix[9],
		matrix[2], matrix[6], matrix[10],
		matrix[12], matrix[13], matrix[14]);
	printf("	p1[%lf, %lf, %lf\n",p1[0],p1[1],p1[2]);
	printf("	p2[%lf, %lf, %lf\n",p2[0],p2[1],p2[2]);
	printf("	p3[%lf, %lf, %lf\n",p3[0],p3[1],p3[2]);
	printf("	p4[%lf, %lf, %lf\n",p4[0],p4[1],p4[2]);
*/

	/* if the surface revoles around a point */
	if(p1[0] - VDX_TOL < p2[0] && p1[0] + VDX_TOL > p2[0] && 
	   p1[0] - VDX_TOL < p3[0] && p1[0] + VDX_TOL > p3[0] &&
	   p1[1] - VDX_TOL < p2[1] && p1[1] + VDX_TOL > p2[1] && 
	   p1[1] - VDX_TOL < p3[1] && p1[1] + VDX_TOL > p3[1] &&
	   p1[2] - VDX_TOL < p2[2] && p1[2] + VDX_TOL > p2[2] && 
	   p1[2] - VDX_TOL < p3[2] && p1[2] + VDX_TOL > p3[2])
	{

		if( matrix[12] == 0.0 && matrix[13] == 0.0 && matrix[14] == 0.0 )
		{
			for(xx=0;xx<3;xx++) matrix[12+xx] = cen[xx] = p1[xx];
		}
		else
		{
		
			for(xx=0;xx<3;xx++)
			{ 
				old_cen[xx] = matrix[12+xx];
				cen[xx] = p1[xx];
				tmp1[xx] = old_cen[xx] - cen[xx];
				tmp2[xx] = matrix[xx*4];
				matrix[12+xx] = cen[xx];
			}
			
			VDXv_len1(tmp1,&a);
			VDXv_scale1(tmp1, 1/a, tmp3);

			/* set the z axis of matrix */
			for(xx=0;xx<3;xx++) matrix[xx*4+2] = tmp3[xx];

			VDXv_cross1(tmp2,tmp3,tmp5);
			VDXv_len1(tmp5,&a);
			VDXv_scale1(tmp5, 1/a, tmp4);

			/* set the y axis of matrix */
			for(xx=0;xx<3;xx++) matrix[xx*4+1] = tmp4[xx];
			
			VDXv_cross1(tmp4,tmp3,tmp5);
			VDXv_len1(tmp5,&a);
			VDXv_scale1(tmp5, 1/a, tmp3);

			/* set the x axis of matrix */
			for(xx=0;xx<3;xx++) matrix[xx*4] = tmp3[xx];


		}
		if(matrix[15] == 0.0)	*sweep = 360.0;
		else	*sweep = matrix[15];

		*rad = 10.0;
		msg = 0;
		goto wrap_up;
	}

	/* if the arc is closed */
	if( p1[0] - VDX_TOL < p4[0] && p1[0] + VDX_TOL > p4[0] && 
	    p1[1] - VDX_TOL < p4[1] && p1[1] + VDX_TOL > p4[1] && 
	    p1[2] - VDX_TOL < p4[2] && p1[2] + VDX_TOL > p4[2] )
	{
/*
	printf("arc is closed\n");	
*/
	VDXcalc_radius(p2, p3, p4, &r1);
	VDXcalc_radius(p1, p2, p3, &r2);
	VDXcalc_radius(p4, p2, p3, &r);
	*rad = r;
/*
	printf("rad1=%lf, rad2=%lf, rad3=%lf\n",r1,r,r2);
*/

	if( r + VDX_TOL < r1 || r - VDX_TOL > r1 ||
 	    r + VDX_TOL < r2 || r - VDX_TOL > r2 )
	{
		msg = -1;
		goto wrap_up;
	}	
/*					
	printf("arc is closed\n");
*/
	*sweep = 0.0;


 	/* calculate the center of the arc */

	for(xx=0;xx<3;xx=xx+1)
	{ 
		tmp1[xx]=(p1[xx]-p2[xx]);
		tmp2[xx]=(p3[xx]-p2[xx]);
	}

	VDXv_len1(tmp1,&a);
	VDXv_scale1(tmp1, 1/a,tmp3); /* x unit vector */

	VDXv_len1(tmp2,&b);
	VDXv_scale1(tmp2, 1/b,tmp4); /* y unit vector */
	b /=2;

	VDXv_cross1(tmp3,tmp4,tmp5);
	VDXv_len1(tmp5,&a);
	VDXv_scale1(tmp5, 1/a,tmp6); /* z unit vector */

	VDXv_cross1(tmp4,tmp6,tmp5); /* new x unit vector */
	VDXv_scale1(tmp2, .5,tmp4);
	a = sqrt( fabs( (r*r)-(b*b) ) );

	VDXv_len1(tmp5,&c);
	VDXv_scale1(tmp5, a/c,tmp3);

	for(xx=0;xx<3;xx=xx+1)
	{ 
		cen[xx]= p2[xx] + tmp3[xx] + tmp4[xx];
		matrix[12+xx] = cen[xx];
	}

	/* create the rotation matrix */

	for(xx=0;xx<3;xx=xx+1)
	{ 
		tmp1[xx]=p1[xx]-cen[xx];
		tmp2[xx]=p2[xx]-cen[xx];
	}

	/* X axis for matrix */

	VDXv_len1(tmp1,&a);
	VDXv_scale1(tmp1, 1/a, tmp3);

	for(xx=0;xx<3;xx=xx+1)	matrix[xx*4] = tmp3[xx];

	VDXv_len1(tmp2,&a);

	/* temp Y axis for matrix */

	VDXv_scale1(tmp2, 1/a, tmp4);

	VDXv_cross1(tmp3,tmp4,tmp5);
	VDXv_len1(tmp5,&a);
		
	/* Z axis for matrix */

	VDXv_scale1(tmp5, 1/a, tmp6);

	for(xx=0;xx<3;xx=xx+1)	matrix[xx*4+2] = tmp6[xx];

	/* Y axis for matrix */

	VDXv_cross1(tmp6,tmp3,tmp4);
	for(xx=0;xx<3;xx=xx+1)	matrix[xx*4+1] = tmp4[xx];

	msg = 0;
	goto wrap_up;
   }


/*
 *	THE ARC IS OPEN CHECK FOR COMMON CENTERS
 */

	VDXcalc_radius(p2, p3, p4, &r1);
	VDXcalc_radius(p1, p2, p4, &r2);
	VDXcalc_radius(p1, p3, p4, &r);
	*rad = r;
/*
	printf("rad1=%lf, rad2=%lf, rad3=%lf\n",r1,r,r2);
*/
	if( r + VDX_TOL < r1 || r - VDX_TOL > r1 ||
 	    r + VDX_TOL < r2 || r - VDX_TOL > r2 )
	{
		msg = -1;
		goto wrap_up;
	}						


 	/* calculate the center of the arc */

	for(xx=0;xx<3;xx=xx+1)
	{ 
		tmp1[xx]=(p1[xx]-p2[xx]);
		tmp2[xx]=(p3[xx]-p2[xx]);
	}

	VDXv_len1(tmp1,&a);
	VDXv_scale1(tmp1, 1/a,tmp3); /* x unit vector */

	VDXv_len1(tmp2,&b);
	VDXv_scale1(tmp2, 1/b,tmp4); /* y unit vector */
	b /=2.0;

	VDXv_cross1(tmp3,tmp4,tmp5);
	VDXv_len1(tmp5,&a);
	VDXv_scale1(tmp5, 1/a,tmp6); /* z unit vector */

	VDXv_cross1(tmp4,tmp6,tmp5); /* new x unit vector */
	VDXv_scale1(tmp2, .5,tmp4);

	a=sqrt(fabs((r*r)-(b*b)));

	VDXv_len1(tmp5,&c);
	VDXv_scale1(tmp5, a/c,tmp3);

	for(xx=0;xx<3;xx=xx+1)
	{ 
		cen[xx]= p2[xx] + tmp3[xx] + tmp4[xx];
		matrix[12+xx] = cen[xx];
	}
/*
	printf("\t\tOpen arc center[%lf, %lf, %lf]\n",cen[0],cen[1],cen[2]);
*/
	/* create the rotation matrix */

	for(xx = 0; xx < 3; xx = xx + 1)
	{ 
		tmp1[xx]=p1[xx]-cen[xx];
		tmp2[xx]=p2[xx]-cen[xx];
	}

	/* X axis for matrix */

	VDXv_len1(tmp1,&a);
	VDXv_scale1(tmp1, 1/a, tmp3);

	matrix[0] = tmp3[0];
	matrix[4] = tmp3[1];
	matrix[8] = tmp3[2];

	VDXv_len1(tmp2,&a);

	/* temp Y axis for matrix */

	VDXv_scale1(tmp2, 1/a, tmp4);

	VDXv_cross1(tmp3,tmp4,tmp5);
	VDXv_len1(tmp5,&a);
		
	/* Z axis for matrix */

	VDXv_scale1(tmp5, 1/a, tmp6);
	matrix[2]  = tmp6[0];
	matrix[6]  = tmp6[1];
	matrix[10] = tmp6[2];

	/* Y axis for matrix */

	VDXv_cross1(tmp6,tmp3,tmp4);
	matrix[1] = tmp4[0];
	matrix[5] = tmp4[1];
	matrix[9] = tmp4[2];

/*
	for(xx=0;xx<3;xx=xx+1)
	{ 
		tmp1[xx]=p1[xx]-cen[xx];
		tmp2[xx]=p3[xx]-cen[xx];
	}
*/
	for(xx=0;xx<3;xx=xx+1)
	{ 
		tmp1[xx]=p1[xx]-cen[xx];
		tmp2[xx]=p4[xx]-cen[xx];
	}

	VDXv_len1(tmp1,&a);
	VDXv_scale1(tmp1, 1/a, tmp3);
	VDXv_len1(tmp2,&a);
	VDXv_scale1(tmp2, 1/a, tmp4);

	angle=VDX_v_dot(tmp3, tmp4);
	//printf("angle=%.3f\n",angle);

	*sweep=(90-asin(angle)*57.2957804);

	//printf("!!!!!!computed arc sweep =%.3f\n",*sweep);

	/* TR179900203 Begin changes */
	/*check the length between the points to check arc angle */
	// printf("#### Got to changed code ***\n");
	
	for(xx=0;xx<3;xx=xx+1)
	{ 
		tmp1[xx]=p1[xx]-p4[xx];
		tmp2[xx]=p2[xx]-p4[xx];
		tmp3[xx]=p1[xx]-p2[xx];
	}

	VDXv_len1(tmp1,&a);
	VDXv_len1(tmp2,&b);
	VDXv_len1(tmp3,&c);
		
	d = sqrt( b*b + c*c);
	if ( a < d ) { 
		#ifdef DEBUG
		printf("sweep angle must be greater than or 180\n");
		#endif
		if( *sweep < 180 ) *sweep = 360.0 - *sweep;
	}else if ( a == d ) { 
		#ifdef DEBUG
		printf("sweep angle is 180\n");
		#endif
		*sweep = 180.0;
	}else {
		#ifdef DEBUG
		printf("sweep angle must be less than 180\n");
		#endif
		if( *sweep > 180 ) *sweep = 360.0 - *sweep;
	}

	/* TR179900203 End of changes */

	if(angle > -(1+VDX_TOL) && angle < -(1-VDX_TOL)) *sweep=180;
	msg = 0;

	//printf("!!!!!!computed arc sweep =%.3f\n",*sweep);

	msg = 0;

wrap_up:

	return(msg);

}

VDXv_cross1(v1,v2,v3)
double	v1[3], v2[3], v3[3];
{
	v3[0]= v1[1]* v2[2] -  v1[2]* v2[1] ;
	v3[1]= v1[2]* v2[0] -  v1[0]* v2[2] ;
	v3[2]= v1[0]* v2[1] -  v1[1]* v2[0] ;
}

VDXv_scale1(v1,s,v2)
double v1[3], v2[3], s;
{
	v2[0]=v1[0]*s;
	v2[1]=v1[1]*s;
	v2[2]=v1[2]*s; 
}

VDXv_len1(v1,l)
double v1[3],*l;
{
	*l = sqrt(fabs( v1[0]*v1[0]+v1[1]*v1[1]+v1[2]*v1[2]));
}

VDXcalc_radius(p2, p3, p4, rad)
double	p2[3], p3[3], p4[3], *rad;
{
int	i;
double	a=0.0, b=0.0, c=0.0, h=0.0, x=0.0;
double	tmp1[3], tmp2[3], tmp3[3], tmp=0.0;

	for(i=0;i<3;i=i+1)
	{ 
		tmp1[i]=p3[i]-p2[i];
		tmp2[i]=p4[i]-p2[i];
		tmp3[i]=p3[i]-p4[i];
	}

	VDXv_len1(tmp1,&a);
	VDXv_len1(tmp2,&b);
	VDXv_len1(tmp3,&c);
	x=(a*a+b*b-c*c)/(2*b);
	h=sqrt(fabs(a*a-x*x));
	*rad=(a*c)/(2*h);
}
