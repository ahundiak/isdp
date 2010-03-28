/*
Name
        GUotype6

Description
        This utility function formats an IGDS type 6 shape element according
        to the defining geometry, symbology and properties.

History
        ???     ??/??/??    creation
        mrm     02/08/92    handle user-defined line styles
*/

#include "exsysdep.h"
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "msdef.h"
#include "dpdls.h"

#argsused
GUotype6( msg, file_des, dgn_buf, ele_buf, ele_size, class_name,
	  geometry, range, symbology, geometric_props, properties,
	  has_name, name, fill_bit )

IGRlong			*msg;
IGRint			*file_des;
IGRchar			*dgn_buf;
struct IGDS_shape	*ele_buf;
IGRint			*ele_size;
IGRchar			class_name[];
struct IGRbsp_curve	*geometry;
GRrange			range;
struct GRsymbology	*symbology;
IGRushort 		*properties;
IGRboolean		*has_name;
IGRchar			*name;
IGRboolean		*fill_bit;

{

    IGRint		i;			/* lcv 			*/
    IGRint		j;			/* lcv 			*/
    IGRint		k;			/* lcv 			*/
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
    IGRlong		name_msg;		/* add ele name		*/
    struct IGDS_complex		*cpxshape;
    struct IGDS_linestring	*linestring;
#ifdef BIG_ENDIAN
    IGRshort             direc = 1;
#endif

    *msg = GUsuccess;

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
	 *  Format a complex shape header element.
	 */

	type = 14;
	
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
	
	/*     An attribute linkage of 4 words has to be added to all
	 * complex elements, inorder to meet some IGDS minimum element
	 * size requirements. The words_to_follow, wds_in_descript and
	 * ele_size are adjusted accordingly.
	 */
 
	cpxshape = (struct IGDS_complex *) ele_buf;
	cpxshape->header.words_to_follow = 18 + 4;
	cpxshape->header.index_to_ae = 4;
	cpxshape->wds_in_descript = ((num_ele-1)*(((101*ndices)*2)+19)) +
				    ((num_last*ndices)*2+19) + 1 + 4;
	cpxshape->num_elements = num_ele;
	cpxshape->dummy_linkage = 0;

	/*
	 *  Write the complex shape header element to the file.
	 */

	*ele_size = 48;
	write_mode = GUWRITE;
#ifdef BIG_ENDIAN
	GRswap_type1214_ele(ele_buf);
#endif
	brc = GUwrite_element(	msg, dgn_buf, ele_buf, &type, ele_size,
				file_des, &write_mode, &block_ptr,
				&byte_ptr );

	/*
	 *  Format the line string elements which will make
	 *  up the complex shape element.
	 */

	type = 4;
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

	    linestring->header.level |= 0x80; /* set component bit */
	    linestring->header.words_to_follow = 17 + 2*(num_points*ndices);
	    linestring->header.index_to_ae = 
				linestring->header.words_to_follow - 14;
	    linestring->lnstr.num_points = num_points;

	    /*
	     *  Get the points out of the shape object.
	     */

	    if ( ndices == 2)
	    {
		k = 0;
		for ( j = 0; j < num_points; j ++ )
	    	{
		    point[k] = GUnint ( geometry->poles[i] );
		    point[k+1] = GUnint ( geometry->poles[i+1] );
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
		    point[j] = GUnint ( geometry->poles[i] );
		    GUswapint ( &point[j], &point[j] );
		    i++;
	 	}

		i -= 3;

	    }
	    

	    memcpy(&(linestring->lnstr.pnts_ptr), (char *)point, 
                   num_points*ndices*4 );

	    /*
	     *  Write the element out to the file.
	     */

	    *ele_size = (linestring->header.words_to_follow+2) * 2;
	    write_mode = GUWRITE;
#ifdef BIG_ENDIAN
	    GRswap_type4_ele(ele_buf,ndices,direc);
#endif
	    brc = GUwrite_element( msg, dgn_buf, ele_buf, &type, ele_size,
				   file_des, &write_mode, &block_ptr,
				   &byte_ptr );


	    num_ele--;

	}

    }
    else
    {
	/*
	 *  Format an IGDS shape element.
	 */

	type = 6;
	
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

	ele_buf->header.words_to_follow = 17 + 2*(ndices*geometry->num_poles);
	ele_buf->header.index_to_ae = ele_buf->header.words_to_follow - 14;
	ele_buf->shape.num_points = geometry->num_poles;


	/*
	 *  Get the points out of the shape object.
	 */

    	if ( ndices == 2)
	{
	    i = 0;
	    for ( j = 0; j < geometry->num_poles*3; j += 3 )
	    {
		point[i] = GUnint ( geometry->poles[j] );
		point[i+1] = GUnint ( geometry->poles[j+1] );
		i += 2;
	    }

	    for ( j = 0; j < geometry->num_poles*2; j++ )
	    {
		GUswapint ( &point[j], &point[j] );
	    }

				
	}
	else
	{
  	    i = 0;
 	    for ( j = 0; j < geometry->num_poles*3; j ++ )
	    {
		point[j] = GUnint ( geometry->poles[i] );
		GUswapint ( &point[j], &point[j] );
		i++;
	    }

	}

	memcpy(&(ele_buf->shape.pnts_ptr), (char *)point, 
               geometry->num_poles*ndices*4 );

        /* check whether a user-defined linestyle is present */
        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(&name_msg, symbology->display_attr.style,
                              ele_buf);

        /*  If an element name is present, it will be added to the tranlated
         *  element's user data linkage in the igds design file.
         */
	GRadd_name_to_buf(&name_msg, has_name, name, ele_buf);
#ifdef BIG_ENDIAN
	if (*has_name)
            GRswap_name_linkage(ele_buf);
#endif

        /*  If the polygon fill bit is set, attribute linkage data is added
         *  to the formatted element.
         */
	GRpoly_fill(msg, fill_bit, ele_buf);
#ifdef BIG_ENDIAN
	if (*fill_bit)
            GRswap_poly_linkage(ele_buf);
#endif

        /*
         *  Write the complex shape header element to the file.
         */
	*ele_size = (ele_buf->header.words_to_follow+2) * 2;
	write_mode = GUWRITE;
#ifdef BIG_ENDIAN
	GRswap_type6_ele(ele_buf,ndices,direc);
#endif
	brc = GUwrite_element(	msg, dgn_buf, ele_buf, &type, ele_size,
				file_des, &write_mode, &block_ptr,
			        &byte_ptr );

    }

	
wrap_up:

	return(brc);

} /* end GUotype6 */
