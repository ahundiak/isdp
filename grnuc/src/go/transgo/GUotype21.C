/* #######################    APOGEE COMPILED   ######################## */
/*
 * This utility function formats an IGDS B-spline pole element according
 * to the defining geometry, symbology and properties.
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

#argsused
GUotype21( msg, file_des, dgn_buf, igds, igds_size, class_name, geometry,
	   range, symbology, geometric_props, properties, poles, num_poles )

	IGRlong			*msg;
	IGRint			*file_des;
	IGRchar			*dgn_buf;
	IGRchar			*igds;
	IGRint			*igds_size;
	IGRchar			class_name[];
	GRrange			range;
	struct GRsymbology	*symbology;
	IGRshort		*properties;
	IGRdouble		poles[];
	IGRlong			*num_poles;

{ /* begin GUotype21 */

	IGRint			block_ptr;
	IGRint			byte_ptr;
	IGRchar			*char_ptr;		/* array index */
	IGRchar			*char_ptr1;		/* array index */
	IGRshort		i;			/* lcv */
	IGRshort		num_coordinates;	/* for 2-D, 3-D */
	IGRshort		*short_ptr;		/* local variable */
	IGRshort		type;			/* igds element type */
	IGRshort		write_mode;		/* mode for writing */
	IGRlong			brc = TRUE;		/* return status */
	IGRlong			*long_ptr;		/* array index */
	IGRlong			pts[303];		/* working array */
	IGRdouble		*dbl_ptr;		/* array index */
	struct IGDS_o_bscomponent	*component;	/* IGDS components */
#ifdef BIG_ENDIAN
	IGRshort 	         direc = 1;
#endif

	*msg = GUsuccess;

	write_mode = GUWRITE;

	component = ( struct IGDS_o_bscomponent * ) igds;

	/*
	 * write out pole element.
	 */

	type = GU_BS_POLE;

	/*
	 * call function to load header data for pole element.
	 */

	GUload_IGDSheader( msg, class_name, &type, symbology, properties,
			   range, component );

	if ( *msg != GUsuccess )
	{
	    brc = FALSE;
	    goto wrap_up;
	}

	/*
	 * load local header data and poles as integers.
	 */

	if ( ! strncmp(class_name,"GR2",3) )
	{
	    component->header.words_to_follow = 17 + 4 * *num_poles;
	    component->header.index_to_ae     =  3 + 4 * *num_poles;
	    *igds_size			      = 38 + 8 * *num_poles;
	    num_coordinates		      = *num_poles * 2;
	}
	else
	{
	    component->header.words_to_follow = 17 + 6 * *num_poles;
	    component->header.index_to_ae     =  3 + 6 * *num_poles;
	    *igds_size			      = 38 + 12 * *num_poles;
	    num_coordinates		      = *num_poles * 3;
	}

	component->header.level |= 0x80;
	short_ptr  = ( IGRshort * ) component->components;
	*short_ptr = *num_poles;

	long_ptr = pts;
	dbl_ptr  = poles;

	/*
	 * pole values are not aligned in buffer, so we have to use a temporary
	 * array and then move them over.
	 */

	for ( i = 0 ; i < num_coordinates ; i++ )
	{
	    *long_ptr = GUnint(*dbl_ptr);
	    GUswapint(long_ptr,long_ptr);
	    long_ptr++;
	    dbl_ptr++;
	}

	char_ptr  = &component->components[2];
	char_ptr1 = ( IGRchar * ) pts;
	i = num_coordinates * 4;

	memcpy ( char_ptr, char_ptr1, i );

#ifdef BIG_ENDIAN
	GRswap_type21_ele(component,direc);
#endif
	brc = GUwrite_element(	msg, dgn_buf, component, &type, igds_size,
				file_des, &write_mode, &block_ptr,
				&byte_ptr );

wrap_up:

	return(brc);

} /* end GUotype21 */
