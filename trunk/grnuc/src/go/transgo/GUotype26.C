/* #######################    APOGEE COMPILED   ######################## */
/*
 * This utility function formats an IGDS B-spline knot element according
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
GUotype26( msg, file_des, dgn_buf, igds, igds_size, class_name, geometry,
	   range, symbology, geometric_props, properties, knots, num_knots )

	IGRlong			*msg;
	IGRint			*file_des;
	IGRchar			*dgn_buf;
	IGRchar			*igds;
	IGRint			*igds_size;
	IGRchar			class_name[];
	struct IGRbsp_curve	*geometry;
	GRrange			range;
	struct GRsymbology	*symbology;
	struct GRprops		*geometric_props;
	IGRshort		*properties;
	IGRdouble		knots[];
	IGRlong			*num_knots;

{ /* begin GUotype26 */

	IGRint			block_ptr;
	IGRint			byte_ptr;
	IGRshort		i;			/* lcv */
	IGRshort		type;			/* igds element type */
	IGRshort		write_mode;		/* mode for writing */
	IGRlong			brc = TRUE;		/* return status */
	IGRlong			*long_ptr;		/* array index */
	IGRdouble		*dbl_ptr;		/* array index */
	IGRdouble		dbl;			/* working variable */
	struct IGDS_o_bscomponent *component;		/* IGDS components */
#ifdef BIG_ENDIAN
	IGRshort		direc =1;
#endif

	*msg = GUsuccess;

	write_mode = GUWRITE;

	type = GU_BS_KNOT;

	component = ( struct IGDS_o_bscomponent * ) igds;

        /*
         * call function to load header data for knot element.
         */

	brc = GUload_IGDSheader( msg, class_name, &type, symbology, properties,
				 range, component );

	if ( *msg != GUsuccess )
	    goto wrap_up;

        /*
         * load local header data and knot values as integers.
         */

	component->header.level		 |= 0x80;
	component->header.words_to_follow = 16 + 2 * *num_knots;
	component->header.index_to_ae     = 2  + 2 * *num_knots;

	long_ptr  = (IGRlong *) component->components;
	dbl_ptr   = knots;

	for ( i = 0 ; i < *num_knots ; i++ )
	{
	    if ( (*dbl_ptr < 0.0) || (*dbl_ptr > 1.0) )
	    {
		brc = FALSE;
		goto wrap_up;
	    }

	    dbl = *dbl_ptr * GRDGNLIMITS_MAX_D;
	    *long_ptr = GUnint(dbl);
	    GUswapint(long_ptr,long_ptr);

	    long_ptr++;
	    dbl_ptr++;
	}

	*igds_size = 36 + 4 * *num_knots;
#ifdef BIG_ENDIAN
	GRswap_type26_ele(component,direc);
#endif
	brc = GUwrite_element(	msg, dgn_buf, component, &type, igds_size,
				file_des, &write_mode, &block_ptr,
				&byte_ptr );

wrap_up:

	return(brc);

} /* end GUotype26 */
