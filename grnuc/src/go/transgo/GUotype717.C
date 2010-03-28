/*
Name
	GUotype717

Description
	This function will convert an MDEM text object to IGDS format.

History
	???	??/??/8?    creation
        mrm     09/15/91    fixed "mess" with uninitialized pointer.
        mrm     03/26/92    added dimension arg to GRswap_type717_ele
*/

#include "exsysdep.h"
#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "msdef.h"
#include "exlocaledef.h"
#include "exlocale.h"
#include "fontdef.h"
#include "font.h"
#include "dpdls.h"

struct type17_element
{
    struct GUcommon_header_info	header;
    IGRchar			font;
    IGRchar			just;
    IGRshort			text_data;
};


IGRint GUotype717 ( msg, file_des, dgn_buf, ele_buf, ele_size, class_name,
		    geometry, range, symbology, properties, 
		    text_attr, text_string, md_env, x_ratio, y_ratio,
		    has_name, name, fill_bit, convert, scale_factor )

IGRlong			*msg;
IGRint			*file_des;
IGRchar			*dgn_buf;
struct type17_element	*ele_buf;
IGRint			*ele_size;
IGRchar			*class_name;
struct IGRlbsys		*geometry;
GRrange			range;
struct GRsymbology	*symbology;
IGRushort 		*properties;
struct IGRestx		*text_attr;
IGRchar			*text_string;
struct GRmd_env		*md_env;
IGRdouble		*x_ratio;
IGRdouble		*y_ratio;
IGRboolean		*has_name;
IGRchar			*name;
IGRboolean		*fill_bit;
IGRboolean		*convert;
IGRdouble		*scale_factor;

{

    IGRint			i;
    IGRint			block_ptr;
    IGRint			byte_ptr;
    IGRint			swap_array[9];
    IGRint			ret_code = TRUE;
    IGRchar			*text_ptr;
    IGRchar			*igds_string;
    IGRuchar			num_chars = 0;
    IGRchar			num_ed_fields;
    IGRlong			status;
    IGRshort			type;
    IGRshort			dim = 4;
    IGRshort			write_mode = GUWRITE;
    IGRdouble			length_mult;
    IGRdouble			height_mult;
    IGRdouble			quaternions[4];
    IGRdouble			igds_origin[3];
    IGRboolean			initial_call = TRUE;
    GRrange			igds_range;
    IGRmatrix			rot_matrix;
    IGRpoint			x_point,y_point,origin_pt;
    IGRdouble			points_array[9];
    struct IGRpolyline		py;
    struct vfont_entry          fontinfo;

    extern    IGRchar    GUotxtesc();
    IGRshort ndices;


    text_ptr = text_string;

			
    /*
     *	Calculate the quaternions from the
     *	rotation matrix of the text object.
     *
     *  Extract any scaling from the lbs matrix
     *  and produce a matrix containing pure
     *  rotation.
     */

    x_point[0] = geometry->matrix[0];
    x_point[1] = geometry->matrix[4];
    x_point[2] = geometry->matrix[8];
    y_point[0] = geometry->matrix[1];
    y_point[1] = geometry->matrix[5];
    y_point[2] = geometry->matrix[9];
    origin_pt[0] = origin_pt[1] = origin_pt[2] = 0.0;

    MA3protmx ( msg, origin_pt, x_point, y_point, rot_matrix );
    MAtrnmx ( msg, &dim, rot_matrix, rot_matrix );

    GUrotmx_to_quat ( rot_matrix, quaternions );

    /*
     *	Process the text string.
     */


    while ( (num_chars = GUotxtesc(&initial_call, convert, md_env, &text_ptr, 
				   geometry->matrix, text_attr, &fontinfo, symbology,
				   igds_origin, igds_range, &igds_string)) > 0 )
    {
    	/*
    	 *  Load IGDS element header data.
    	 */

    	type = 17;

    	GUload_IGDSheader ( msg, class_name, &type, symbology, properties, 
			    range, ele_buf );		/* RANGE IS KLUDGED */
			
    	ele_buf->header.words_to_follow = 36 + ( num_chars/2);
    	if ( (num_chars%2) != 0 )
    	{
	    ele_buf->header.words_to_follow++;
    	}

    	ele_buf->header.index_to_ae = ele_buf->header.words_to_follow - 14;

    	/*
    	 *  Calculate the text length and height
    	 *  multipliers.
    	 */

	length_mult = ((text_attr->width / 6.0) * 1000) * *x_ratio;
 	height_mult = ((text_attr->height / 6.0) * 1000) * *y_ratio;

	if (*convert)
	{
	   if (( text_attr->font == 102 ) && ((i = strlen(igds_string)) == 1 )
	      && ( igds_string[0] == 'Z' ))
	   {
	      height_mult *= 0.8834;
	      igds_origin[1] += (((0.1166 * text_attr->height) * *scale_factor) / 2);
	   }
	}
        else  /* creating a plotting meta file */
        {
            IGRdouble slant_angle;
            struct EX_fonts       font_parameters;  /* locale parameters  */
            struct EX_locale_var  var_list;         /* locale identifiers */

            /*
             * adding a user data attribute linkage to the text element
             * so that it will be plotted using Font Server
             */

            var_list.var = EX_font_parameters;
            var_list.var_ptr = (IGRchar *) &font_parameters;

            ex$inq_locale (msg = msg,
                           var = &var_list,
                           flags = EX_Text | EX_Logical_Name, 
                           identifier = (IGRchar *) fontinfo.fontfile);

            if (*msg & 1)
            {
                slant_angle = 0.0;
		ndices = ele_buf->header.words_to_follow;
                GRfont_user_linkage(msg,&font_parameters,&slant_angle,
                                    (*properties & GRFILLED_DISPLAY) ? 1 : 0,
                                    ele_buf);
#ifdef BIG_ENDIAN
		GRswap_font_linkage(ele_buf,ndices);
#endif
                /*
                 * This text string will be plotted using Font Server, so
                 * the length and height multipliers must be calculated
                 * differently; the text size multipliers are expected to be
                 * the text bodysize in UORs divided by 100. Text width and
                 * height do not include descent but Font Server's definition
                 * of bodysize expects the text size to include descent.
                 * The 10 this equation is being multiplied by comes from the
                 * division by 100 metioned earlier and multiplication by
                 * 1000 necessary because of retaining precision since we
                 * are going to an integer data base.  The x_ratio and y_ratio
                 * come from a combination of scaling (if any) in the text
                 * element's local bounded system matrix and the scale in
                 * the IGDS seed_file used.
                 */
/* the plotting software has been changed to expect the text size as it is
 * in an IGDS text element so the length and height multipliers don't need
 * to be changed : 04/18/91
                length_mult = (text_attr->width * (fontinfo.bodysize / (fontinfo.bodysize - fontinfo.descent))) * 10 * *x_ratio;
                height_mult = (text_attr->height * (fontinfo.bodysize / (fontinfo.bodysize - fontinfo.descent))) * 10 * *y_ratio;
*/
            }
        }

    	/*
    	 *  Swap all integer data into VAX format.
    	 */

    	swap_array[0] = GUnint ( length_mult );
    	swap_array[1] = GUnint ( height_mult );
    	swap_array[2] = GUnint ( quaternions[0] );
    	swap_array[3] = GUnint ( quaternions[1] );
    	swap_array[4] = GUnint ( quaternions[2] );
    	swap_array[5] = GUnint ( quaternions[3] );
    	swap_array[6] = GUnint ( igds_origin[0] );
    	swap_array[7] = GUnint ( igds_origin[1] );
    	swap_array[8] = GUnint ( igds_origin[2] );
    	for ( i = 0; i < 9; i++ )
    	{
	    GUswapint ( &swap_array[i], &swap_array[i] );
    	}


	/*  The call to GUotxtesc routine alters the origin of the 
	 *  text. This may leave the origin at a point outside the
	 *  range. Inorder to avoid this, the range is validated
	 *  to include the origin also.
	 */

	for ( i = 0; i < 6; i++ )
	{
	    points_array[i] = range[i];
	}

	for ( i = 0; i < 3; i++ )
	{
	    points_array[6+i] = igds_origin[i];
	}

	py.num_points = 3;
	py.points = points_array;

	MApyextents(msg, &py, &range[0], &range[3]);





    	/*
    	 *	Load remaining data into element buffer.
    	 */

    	ele_buf->font = text_attr->font;
    	ele_buf->just = text_attr->just;

    	memcpy((char *)&(ele_buf->text_data), (char *)swap_array, 36 );

  	num_ed_fields = 0;

    	memcpy ( ((IGRchar *) &(ele_buf->text_data))+37, &num_ed_fields, 1 );

        /*
         * if converting to a plotting meta file and this is a 16 bit font,
         * the bytes must be swapped in the text string since Font Server
         * expects the char codes as unsigned shorts and we must divide the
         * number of chars by 2 since num_chars currently represents the
         * number of bytes in the text string and we want the number of text
         * characters
         */

        if (! *convert && (fontinfo.flags & SIXTEEN_BIT))
        {
            swab(igds_string, ((IGRchar *) &(ele_buf->text_data))+38, num_chars);
            num_chars /= 2;
        }
        else
        {
            memcpy ( ((IGRchar *) &(ele_buf->text_data))+38, igds_string, num_chars );
        }
        memcpy(((IGRchar *)&(ele_buf->text_data))+36, (char *)&num_chars, 1);

        /* check whether a user-defined linestyle is present */
        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(msg, symbology->display_attr.style, ele_buf);

        /*  If an element name is present, it will be added to the tranlated
         *  element's user data linkage in the igds design file.
         */
	GRadd_name_to_buf(msg, has_name, name, ele_buf);
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
         *  Write the new text element out to the IGDS file.
         */
    	*ele_size = (ele_buf->header.words_to_follow+2) * 2;
#ifdef BIG_ENDIAN
	GRswap_type717_ele(ele_buf, GU_3D);
#endif
	status = GUwrite_element ( msg, dgn_buf, ele_buf, &type, ele_size, 
		       	       	   file_des, &write_mode, &block_ptr,
			       	   &byte_ptr );

    }  /* end while */

    return ( ret_code );
	
	    
}
