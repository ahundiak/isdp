/*
Name
        GUotype16

Description
        This utility function formats an IGDS type 16 arc element according to
        the defining geometry, symbology and properties.

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
#include "madef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "msdef.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "dpdls.h"

struct	type16_element
{
	struct GUcommon_header_info	header;
	IGRlong				start;
	IGRlong				sweep;
	unsigned long			primary[2];
	unsigned long			secondary[2];
	IGRlong				rotation_origin[10];
};

#argsused
GUotype16( msg, file_des, dgn_buf, igds, igds_size, class_name,
	   geometry, range, symbology, geometric_props, properties,
	   has_name, name, fill_bit )

	IGRlong			*msg;
	IGRlong			*file_des;
	IGRchar			*dgn_buf;
	struct type16_element	*igds;
	IGRlong			*igds_size;
	IGRchar			class_name[];
	struct IGRarc		*geometry;
	GRrange			range;
	struct GRsymbology	*symbology;
	IGRshort		*properties;
	IGRboolean		*has_name;
	IGRchar			*name;
	IGRboolean		*fill_bit;

{ 

	IGRshort		i;
	IGRdouble		quaternions[4];
	IGRshort		type = 16;		/* igds element type */
	IGRshort		write_mode;		/* mode for writing */
	IGRint			block_ptr;
  	IGRint			byte_ptr;
	IGRlong			status = TRUE;		/* return status    */
	IGRlong			name_msg;		/* add ele name	    */
	IGRshort		dim;

	*msg = GUsuccess;

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

        /*
         * load start and sweep angles
         */

	if ( ! strncmp(class_name,"GR2",3) )
 	{
	    /*
	     *  2-D arc
	     */

	    igds->header.words_to_follow = 38;
	    *igds_size = 80;
	    igds->header.index_to_ae = 24;

        dim = 2;
	}
	else
	{
	    /*
	     *  3-D arc
	     */

	    igds->header.words_to_follow = 48;
	    *igds_size = 100;
	    igds->header.index_to_ae = 34;

	    igds->start =  GUnint( (geometry->start_angle * 360000.0)
				     / (PI / 180.0) );
	    
	    GUswapint ( &igds->start, &igds->start );

	    if ( geometry->sweep_angle == 2 * PI )
	    {
		igds->sweep = 0;
	    }
	    else
	    {
		igds->sweep = GUnint ( (geometry->sweep_angle * 360000.0) 
					/ (PI / 180.0) );

                /* TR:90N1634   Mohan. */

                if (igds->sweep < 0 )
                {
                    igds->sweep = 0x80000000 | (~igds->sweep + 1 );
                }
	    }

	    GUswapint ( &igds->sweep, &igds->sweep );

	    /*
	     *  load the primary and secondary axis
	     */

	    flt32_to_fltvax ( 1, &geometry->prim_axis, igds->primary );
	    flt32_to_fltvax ( 1, &geometry->sec_axis, igds->secondary );

	    /*
	     *  load the quaternions
	     */

	    GUrotmx_to_quat ( geometry->rot_matrix, quaternions );

            for ( i = 0; i < 4; ++i )
	    {	   
	 	igds->rotation_origin[i] = GUnint (quaternions[i]);
		GUswapint ( &igds->rotation_origin[i],
			  &igds->rotation_origin[i] );
	    }

	    /*
	     *  load the origin of the arc
	     */

	    flt32_to_fltvax ( 3, geometry->origin, &igds->rotation_origin[4] );

        dim = 3;
	}

        /* check whether a user-defined linestyle is present */
        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(&name_msg, symbology->display_attr.style, igds);

        /*  If an element name is present, it will be added to the tranlated
         *  element's user data linkage in the igds design file.
         */
	GRadd_name_to_buf( &name_msg, has_name, name, igds );
#ifdef BIG_ENDIAN
	if (*has_name)
            GRswap_name_linkage(igds);
#endif

        /*  If the polygon fill bit is set, attribute linkage data is added
         *  to the formatted element.
         */
	GRpoly_fill( msg, fill_bit, igds);
#ifdef BIG_ENDIAN
	if (*fill_bit)
            GRswap_poly_linkage(igds);
#endif

        /*
         *  Write the complex shape header element to the file.
         */
	*igds_size = (igds->header.words_to_follow + 2) * 2;

#ifdef BIG_ENDIAN
	GRswap_type16_ele(igds,dim);
#endif

	write_mode = GUWRITE;
	status = GUwrite_element( msg, dgn_buf, igds, &type, igds_size,
				  file_des, &write_mode, &block_ptr,
				  &byte_ptr );

wrap_up:

	return(status);

}
