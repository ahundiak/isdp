/* $Id: VDXtype23.C,v 1.1.1.1 2001/01/04 21:08:46 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXtyp23.C
 *
 * Description:
 *		Support function for extract for review command.
 *
 *	VDXtype23:
 *	This utility function formats an IGDS type 23 cone element
 *	according to the defining geometry, symbology, and properties.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXtype23.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:46  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  13:58:34  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 ***************************************************************************/

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
#include "EMSsfparms.h"
/*
#include "cimath.h"
extern IGRchar		*memcpy();
*/

#ifndef type23_element

struct type23_element
{
    struct GUcommon_header_info header;
    IGRshort	info[49];
};
#endif

#define VDX_v_cross(v1,v2,V) \
	(V)[0]= (v1)[1]*(v2)[2] - (v1)[2]*(v2)[1] ; \
	(V)[1]= (v1)[2]*(v2)[0] - (v1)[0]*(v2)[2] ; \
	(V)[2]= (v1)[0]*(v2)[1] - (v1)[1]*(v2)[0] ;

#define VDX_v_scale(v,s,V) \
	(V)[0]=(v)[0]*(s); \
	(V)[1]=(v)[1]*(s); \
	(V)[2]=(v)[2]*(s); 

#define VDX_v_equal(v1,v2) \
	(v2)[0] = (v1)[0] ; \
	(v2)[1] = (v1)[1] ; \
	(v2)[2] = (v1)[2] ;

#define VDX_v_len(v) sqrt( (v)[0]*(v)[0] + (v)[1]*(v)[1] + (v)[2]*(v)[2] )


/*#argsused*/
IGRlong VDXtype23(msg, file_des, dgn_buf, igds, igds_size, class_name, 
		geometry, range, symbology, properties, grgroup, scale)

IGRlong *msg;
IGRint *file_des;
IGRchar *dgn_buf;
struct type23_element *igds;
IGRint *igds_size;
IGRchar class_name[];
struct EMsurface_params *geometry;
GRrange range;
struct GRsymbology *symbology;
IGRshort *properties;
IGRlong		scale;	  /* amount to scale up the geometry */
IGRshort 	grgroup[];  /* graphic group number */
{
    IGRdouble	quaternions[4];
    IGRshort i;			   /* lcv */
    IGRshort m;			   /* lcv */
    IGRshort type = 23;		   /* igds element type */
    IGRshort write_mode;	   /* mode for writing */
    IGRint block_ptr;
    IGRint byte_ptr;
    IGRlong brc = TRUE;		   /* return status */
    IGRlong lmsg;		   /* add ele name  */
    IGRint  Size48short;
    IGRlong ty23_info[24];
    IGRshort type1;
    double matrix[16];
    double dtemp[8], x[3],y[3],z[3],temp[3];

    *msg = GUsuccess;

    /* scale the range */

    for(m=0;m<6;m++) range[m] *= scale;

    /* call function to load header data */

    GUload_IGDSheader(msg, class_name, &type, symbology, properties,
		      range, igds);

    if (*msg != GUsuccess)
    {
	brc = FALSE;
	goto wrap_up;
    }

    igds->header.words_to_follow = 57;
    igds->header.graphic_group = (IGRshort) grgroup[3];
    *igds_size = 118;
    igds->header.index_to_ae = 43;
    /* set the type of cone */

    if(( strcmp(class_name,"EMScylindr") == 0 ) ||
       ( strcmp(class_name,"EMAcylindr"))) type1 = 1; 
    else    type1 = 3;

    /* set surface bit */
 
   type1 |= 0x8000;

    memcpy( (IGRchar *)&igds->info[0], (IGRchar *) &type1, sizeof(IGRshort) );

/*
    printf("cone type is set\n");

    printf("Origin\n%lf, %lf, %lf\nVector\n%lf, %lf, %lf\n",
		geometry->params.cone.base_center[0],
		geometry->params.cone.base_center[1],
		geometry->params.cone.base_center[2],
		geometry->params.cone.height[0],
		geometry->params.cone.height[1],
		geometry->params.cone.height[2]);

    printf("surface is set\n\n\n");
*/

    for(m=0;m<3; m++)
    {
	dtemp[m] = (geometry->params.cone.base_center[m] * scale);
	dtemp[m+4] = (geometry->params.cone.height[m] + geometry->params.cone.base_center[m]) * scale;
	temp[m] = geometry->params.cone.height[m];
	/*
	printf("%lf, %lf\n",geometry->params.cone.base_center[m],geometry->params.cone.height[m]);
	*/
    }

    dtemp[3] = (geometry->params.cone.base_radius * scale);

    if(( strcmp(class_name,"EMScylindr") == 0 ) ||
       ( strcmp(class_name,"EMAcylindr") == 0 ))
	    dtemp[7] = (geometry->params.cone.base_radius * scale);
    else
	    dtemp[7] = (geometry->params.cone.top_radius * scale);

    flt32_to_fltvax ( 8, dtemp, &ty23_info[4] );

    /*
    *  load the quaternions
    */

	for(i=1;i<15;i++)
	{
		matrix[i] = 0.0;
	}

	matrix[15] = 1.0;

	/* set up the rotation matrix from the z vector of the cone */

	x[0] = .7071; x[1]= .7071; x[2] = 0.0;

	VDX_v_scale(temp, 1/VDX_v_len(temp), z);

	if( z[0] == x[0] &&  z[1] == x[1] &&  z[2] == x[2] ) x[0] = -.7071;	

	VDX_v_cross( z, x, temp);
	VDX_v_scale(temp, 1/VDX_v_len(temp), y);
	VDX_v_cross(y, z, x);

	for(m=0;m<3;m++)
	{
		matrix[m*4+0] = x[m];
		matrix[m*4+1] = y[m];
		matrix[m*4+2] = z[m];
	}


    GUrotmx_to_quat ( matrix, quaternions);

    for ( m = 0; m < 4; ++m )
    {
	ty23_info[m] = GUnint (quaternions[m]);
	GUswapint ( &ty23_info[m], &ty23_info[m] );
    }

   Size48short  = 48 * sizeof(IGRshort);

   memcpy( (IGRchar *)&igds->info[1], (IGRchar *) &ty23_info[0], Size48short );

    	GRadd_dmrs_to_buf(&lmsg, grgroup, igds);

    /* check whether a user-defined linestyle is present */
    if (symbology->display_attr.style >= BUILTIN_STYLES)
        GRaddStyleLinkage(&lmsg, symbology->display_attr.style, igds);

    *igds_size = (igds->header.words_to_follow + 2) * 2;

    write_mode = GUWRITE;
    brc = GUwrite_element(msg, dgn_buf, igds, &type, igds_size,
			  file_des, &write_mode, &block_ptr, &byte_ptr);

wrap_up:

    return (brc);
}
