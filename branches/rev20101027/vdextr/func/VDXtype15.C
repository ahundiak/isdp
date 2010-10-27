/* $Id: VDXtype15.C,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXtype15.C
 *
 * Description:
 *		Support function for extract for review command.
 *	
 *	VDXtype15:
 *	This utility function formats an IGDS type 15 ellipse element
 *	according to the defining geometry, symbology and properties.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXtype15.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
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

#ifndef type15_element

struct	type15_element
{
	struct GUcommon_header_info	header;
	unsigned long			primary[2];
	unsigned long 			secondary[2];
	IGRlong				rotation_origin[10];
};
#endif

VDXtype15(  msg, file_des, dgn_buf, igds, igds_size, class_name,
	   geometry, range, symbology, properties, grgroup,scale )

	IGRlong			*msg;
	IGRlong			*file_des;
	IGRchar			*dgn_buf;
	struct type15_element *igds;
	IGRlong			*igds_size;
	IGRchar			class_name[];
	struct IGRarc		*geometry;
	GRrange			range;
	struct GRsymbology	*symbology;
	IGRshort		*properties;
	IGRshort		grgroup[];
	IGRlong			scale;	  /* amount to scale up the geometry */

{ 
	IGRdouble		dtemp[3];
	IGRdouble		quaternions[4];
	IGRshort		i;
	IGRshort		m;
	IGRshort		type = 15;		/* igds element type */
	IGRshort		write_mode;		/* mode for writing */
	IGRint			block_ptr;
 	IGRint			byte_ptr;
	IGRlong			status = TRUE;		/* return status */
	IGRlong			name_msg;		/* add ele name  */
	IGRshort		dim;

	*msg = GUsuccess;

    /* scale the range */

    for(m=0;m<6;m++) range[m] *= scale;
/*
    printf("Range\n%lf,%lf,%lf\n%lf,%lf,%lf\n",range[0],range[1],range[2],range[3],range[4],range[5]);
*/
/*
 * call function to load header data.
 */

	GUload_IGDSheader( msg, class_name, &type, symbology, properties,
			   range, igds );

	if ( *msg != GUsuccess )
	{
	    status = FALSE;
	    goto wrap_up;
	}	    

	if ( ! strncmp(class_name,"GR2",3) )
	{
	    /*
	     *  2-D arc
	     */

	    igds->header.words_to_follow = 34;
    	    igds->header.graphic_group = (IGRshort) grgroup[3];
	    *igds_size = 72;
	    igds->header.index_to_ae = 20;
        dim = 2;

	}
	else
	{
	    /*
	     *  3-D arc
	     */

	    igds->header.words_to_follow = 44;
            igds->header.graphic_group = (IGRshort) grgroup[3];
	    *igds_size = 92;
	    igds->header.index_to_ae = 30;

	    /*
	     *  load the primary and secondary axis
	     */

	    dtemp[0] = geometry->prim_axis * scale;
	    flt32_to_fltvax ( 1, &dtemp[0], igds->primary );
	    dtemp[0] = geometry->sec_axis * scale;
	    flt32_to_fltvax ( 1, &dtemp[0], igds->secondary );


	    /*
	     *  load the quaternions
	     */

	    GUrotmx_to_quat ( geometry->rot_matrix, quaternions );

            for ( i = 0; i < 4; ++i )
	    {	   
	 	igds->rotation_origin[i] = GUnint (quaternions[i]);
		GUswapint ( &igds->rotation_origin[i], &igds->rotation_origin[i] );
	    }

	    /*
	     *  load the origin of the arc
	     */
	    dtemp[0] = geometry->origin[0] * scale;
	    dtemp[1] = geometry->origin[1] * scale;
	    dtemp[2] = geometry->origin[2] * scale;

	    flt32_to_fltvax ( 3, dtemp, &igds->rotation_origin[4] );

            dim = 3;
	}

    	GRadd_dmrs_to_buf(&name_msg, grgroup, igds);

        /* check whether a user-defined linestyle is present */

        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(&name_msg, symbology->display_attr.style, igds);

	*igds_size = (igds->header.words_to_follow + 2) * 2;

#ifdef BIG_ENDIAN
	GRswap_type15_ele(igds,dim);
#endif

	write_mode = GUWRITE;
	status = GUwrite_element( msg, dgn_buf, igds, &type, igds_size,
				  file_des, &write_mode, &block_ptr,
				  &byte_ptr );

wrap_up:

	return(status);

}
