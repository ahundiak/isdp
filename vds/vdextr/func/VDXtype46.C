/* $Id: VDXtype46.C,v 1.1.1.1 2001/01/04 21:08:48 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXtype46.C
 *
 * Description:
 *		Support function for extract for review command.
 *
 *	VDXtype46:
 *	This utility function formats an IGDS type 4 linestring or
 *	type 6 shape elements according to the defining geometry,
 *	symbology and properties.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXtype46.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:48  cvs
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


#include <stdio.h>
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

VDXtype46( range, geometry, msg, file_des, dgn_buf, ele_buf, ele_size, 
	  class_name, symbology, properties, grgroup, scale)

IGRlong			*msg;
IGRint			*file_des;
IGRchar			*dgn_buf;
struct IGDS_linestring	*ele_buf;
IGRint			*ele_size;
IGRchar			class_name[];
struct IGRbsp_curve	*geometry;
IGRdouble		range[6];
struct GRsymbology	*symbology;
IGRushort 		*properties;
IGRshort		grgroup[];
IGRlong			scale;

{

    IGRint		i;			/* lcv 			*/
    IGRint		j;      		/* lcv 			*/
    IGRint		k;			/* lcv 			*/
    IGRint		m;			/* lcv 			*/
    IGRint		num_ele;
    IGRint		num_last;
    IGRint		block_ptr;
    IGRint		byte_ptr;
    IGRshort		type;			/* igds element type 	*/
    IGRshort		write_mode;		/* mode for writing 	*/
    IGRshort		ndices;
    IGRshort		num_points;
    IGRlong		point[303];
    IGRlong		brc = TRUE;		/* return status 	*/
    IGRlong		name_msg;		/* add ele name	status	*/
    IGRboolean		flatten = FALSE;
    IGRlong		words_in_descript;
    struct IGDS_complex		*cpxstring;
    struct IGDS_linestring	*linestring;


    *msg = GUsuccess;

    /* scale the range */

    for(m=0;m<6;m++) range[m] *= scale;

    /*
     *  Set up ndices according to the database type.
     */

    if ( ! strncmp(class_name,"GR2",3) ) 
    {
	ndices = 2;
    }
    else
    {
	ndices = 3;
    }

    /*  
     *  Check the number of points that make up the shape.
     *  If it is greater than 101 then the shape will be
     *  broken down into linestrings and a complex shape 
     *  will be formed from them.  Otherwise an IGDS shape
     *  element will be formatted.
     */

    if ( geometry->num_poles > 101 )
    {
	/*
	 *  Calculate the number of elements required to
	 *  complete the IGE object.
	 */

	num_ele = (geometry->num_poles - 1)/100;
     	if ( (geometry->num_poles-1)%100 > 0 )
	{
	    num_ele++;
	}
	
	/*
	 *  Calculate the number of points in the last line
	 *  string required to complete the IGE object.
	 */
 	
	num_last = geometry->num_poles % 100;
	if ( num_last == 0 )
	{
	    num_last = 100;
	}
	else if ( num_last == 1 )
	{
	    num_last = 101;
	}

	/* 
	 *  IGDS headers have 16 bits to store the value of wds_in_
	 *  descript.  If that value is larger than 65536, then	
	 *  the element must be flattened into individual line strings.
	 */

	words_in_descript = ((num_ele-1)*(((101*ndices)*2)+19)) +
			   ((num_last*ndices)*2+19) + 1;
	
	/* 	A dummy attribute linkage of 4 words has to be added 
	 *  to complex headers, inorder to meet some IGDS minimum 
	 *  element size requirements. The words_in_descript, ele_size
	 *  and words_to_follow are adjusted accordingly.
	 */

	words_in_descript += 4;

	if ( words_in_descript > 65535 )
	{
		flatten = TRUE;
	}
	
	/*
	 *  Format a complex string header element.
	 */


       if ( !flatten )
       {

    		if ( ! strcmp(class_name,"GR3dpolygon") ) 
    		{
			type = 14;
    		}
    		else
    		{
			type = 12;
    		}

	
    	/*
     	 * call function to load header data.
    	 */

    	GUload_IGDSheader( msg, class_name, &type, symbology, properties,
		       	   range, ele_buf );

	if ( *msg != GUsuccess )
    	{
	    brc = FALSE;
	    goto wrap_up;
    	}	    

	cpxstring = (struct IGDS_complex *) ele_buf;
	cpxstring->header.words_to_follow = 18 + 4;
	cpxstring->header.graphic_group = (IGRshort) grgroup[3];
	cpxstring->header.index_to_ae = 4;
	cpxstring->wds_in_descript = (IGRushort) words_in_descript;
	cpxstring->num_elements = num_ele;
	cpxstring->dummy_linkage = 0;

	/*
	 *  Write the complex shape header element to the file.
	 */

	*ele_size = 48;

    	GRadd_dmrs_to_buf(&name_msg, grgroup, ele_buf);

	write_mode = GUWRITE;
#ifdef BIG_ENDIAN
	GRswap_type1214_ele(ele_buf);
#endif
	brc = GUwrite_element(	msg, dgn_buf, 
				ele_buf, 
				&type,
				ele_size, file_des, 
				&write_mode, &block_ptr,
				&byte_ptr );
      }

    }
    else
    {
	num_ele = 1;
	num_last = geometry->num_poles;
    }

    /*
     *  Format the line string elements which will make
     *  up the complex string element.
     */

	if ( strcmp(class_name,"GR3dpolygon") == 0 && geometry->num_poles < 102 ) 
    	{
		type = 6;
    	}
    	else
    	{
		type = 4;
    	}

    i = 0;

    while ( num_ele >= 1 )
    {
        GUload_IGDSheader( msg, class_name, &type, symbology, 
			   properties, range, ele_buf );
	if ( *msg != GUsuccess )
  	{
	    brc = FALSE;
	    goto wrap_up;
    	}	    

        /*
	 *  Set the number of points which will make up
	 *  this particular line string.
	 */

        if ( num_ele > 1 )
	{
	    num_points = 101;
	}
	else
	{
	    num_points = num_last;
	}

	/*
	 *  Calculate and set up some header information.
	 */

	linestring = (struct IGDS_linestring *) ele_buf;

   	if ( (geometry->num_poles > 101) && (!flatten) )
	{
	    linestring->header.level |= 0x80; /* set complex bit */
	}

	linestring->header.type = type;
	linestring->header.words_to_follow = 17 + 2*(num_points*ndices);
	linestring->header.index_to_ae = 
			linestring->header.words_to_follow - 14;
	linestring->header.graphic_group = (IGRshort) grgroup[3];
	linestring->lnstr.num_points = num_points;

	/*
	 *  Get the points out of the linestring object.
	 */

	if ( ndices == 2)
	{
	    k = 0;
	    for ( j = 0; j < num_points; j ++ )
	    {
		point[k] = GUnint ( geometry->poles[i] * scale);
		point[k+1] = GUnint ( geometry->poles[i+1] * scale );
		k += 2;
		i += 3;
	    }

	    for ( j = 0; j < num_points*2; j++ )
	    {
		GUswapint ( &point[j], &point[j] );
	    }

	    i -= 3;
				
	}
	else
	{
	    for ( j = 0; j < num_points*3; j ++ )
	    {
		point[j] = GUnint ( geometry->poles[i]*scale);
		GUswapint ( &point[j], &point[j] );
		i++;
	    }

	    i -= 3;

	}

	memcpy(&(linestring->lnstr.pnts_ptr), (char *)point,
               num_points*ndices*4 );

    	GRadd_dmrs_to_buf(&name_msg, grgroup, ele_buf);

        /* check whether a user-defined linestyle is present */
        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(&name_msg, symbology->display_attr.style,
                              ele_buf);
        /*
         *  Write the element out to the file.
         */

	*ele_size = (ele_buf->header.words_to_follow+2) * 2;

	write_mode = GUWRITE;

#ifdef BIG_ENDIAN
	GRswap_type4_ele(ele_buf,ndices,direc);
#endif

	brc = GUwrite_element( msg, dgn_buf, ele_buf, &type, ele_size,
	    		       file_des, &write_mode, &block_ptr,
			       &byte_ptr );
	num_ele--;

    }


	
wrap_up:

	return(brc);

} /* end VDXtype46 */
