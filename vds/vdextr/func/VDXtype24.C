/* $Id: VDXtype24.C,v 1.1.1.1 2001/01/04 21:08:47 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vds/vdextr/func/VDXtype24.C
 *
 * Description:
 *		Support function for extract for review command.
 *
 *	VDXtype24:
 *	This utility function formats an IGDS B-spline surface header element
 *	according to the defining geometry, symbology and properties.  It also
 *	makes calls to the routines to create B-spline constituent entities.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXtype24.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:47  cvs
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
#include "msdef.h"
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

VDXtype24( msg, file_des, dgn_buf, igds, igds_size, class_name,
	   geometry, range, symbology, geometric_props, properties,
	   grgroup, scale )

	IGRlong			*msg;
	IGRint			*file_des;
	IGRchar			*dgn_buf;
	IGRchar			*igds;
	IGRint			*igds_size;
	IGRchar			class_name[];
	struct IGRbsp_surface	*geometry;
	GRrange			range;
	struct GRsymbology	*symbology;
	struct GRprops		*geometric_props;
	IGRshort		*properties;
	IGRlong			scale;	  /* amount to scale up the geometry */
	IGRshort		grgroup[];  /* graphic group number */

{ /* begin VDXtype24 */
	IGRint			block_ptr;
	IGRint			byte_ptr;
	IGRshort		temp;
	IGRshort		type;		/* igds element type */
	IGRshort		write_mode;	/* mode for writing */
	IGRlong			brc = TRUE;	/* return status */
	IGRlong			i;		/* lcv */
	IGRlong			j;		/* lcv */
	IGRlong			k;		/* lcv */
	IGRlong			l;		/* lcv */
	IGRlong			m;		/* lcv */
	IGRlong			n;		/* lcv */
	IGRlong			new_num_poles;	/* compressed num of poles */
	IGRlong			poles_lost;	/* num poles lost in v */
	IGRlong			name_msg;	/* add ele name	*/
	IGRdouble		*double_ptr1;	/* lcv */
	IGRdouble		*double_ptr2;	/* lcv */
	IGRdouble		*old_p;		/* index into old poles	*/
	IGRdouble		*new_p;		/* index into new poles	*/
	IGRdouble		*old_w;		/* index into old weights */
	IGRdouble		*new_w;		/* index into new weights */
	IGRdouble		max_weight;	/* maximum weight value */
	IGRdouble		*weight_ptr;	/* pointer to weight array */
	IGRdouble		min_u;		/* minimum u knot value */
	IGRdouble		max_u;		/* maximum u knot value */
	IGRdouble		diff_u;		/* u knot vector range */
	IGRdouble		min_v;		/* minimum v knot value */
	IGRdouble		max_v;		/* maximum v knot value */
	IGRdouble		diff_v;		/* v knot vector range */
	IGRdouble		knots[10000];	/* array for u/v knots */
	struct IGDS_bssurf	*surface;	/* IGDS surface header */
extern    void    BSsubdivsf();
extern    void    BSfreesf();

	*msg = GUsuccess;

    /* scale the range */

    for(m=0;m<6;m++) range[m] *= scale;

    /* scale the poles */
    for(m=0;m<geometry->u_num_poles*geometry->v_num_poles*3;m++) geometry->poles[m] *= scale;

	if ( geometry->u_num_poles > 1001 || geometry->v_num_poles > 1001 )
	{
	    brc = FALSE;
	    *msg = MSFAIL;
	    goto wrap_up;
	}

	write_mode = GUWRITE;

	surface = ( struct IGDS_bssurf * ) igds;

	/*
	 * call function to load header data for surface header.
	 */

	type = GU_BS_SURF_HEADER;

	brc = GUload_IGDSheader( msg, class_name, &type, symbology, properties,
				 range, surface );

	if ( *msg != GUsuccess )
	{
	    goto wrap_up;
	}

	/*
	 *  Set the on/off bit (the H bit)
	 */

	if ( geometry->num_boundaries )
	{
	    if ( geometry->on_off )
	    {
		surface->header.properties &= 0x7fff;
	    }
	    else
	    {
		surface->header.properties |= 0x8000;
	    }
	}
	else
	{
	    surface->header.properties &= 0x7fff;
	}

	/*
	 * Make sure the knot values range from 0 to 1.
	 */

	min_u  = geometry->u_knots[geometry->u_order - 1];
	max_u  = geometry->u_knots[geometry->u_num_knots - geometry->u_order];
	diff_u = max_u - min_u;

	min_v  = geometry->v_knots[geometry->v_order - 1];
	max_v  = geometry->v_knots[geometry->v_num_knots - geometry->v_order];
	diff_v = max_v - min_v;

	if ( geometry->u_num_knots != 0 )
	{
	    GUnormalize_knots ( geometry->u_knots, geometry->u_knots,
		&geometry->u_num_knots, &geometry->u_order );
	}
	else
	{
	    geometry->u_non_uniform = 0;
	}

	if ( geometry->v_num_knots != 0)
	{
	    GUnormalize_knots ( geometry->v_knots, geometry->v_knots,
		&geometry->v_num_knots, &geometry->v_order );
	}
	else
	{
	    geometry->v_non_uniform = 0;
	}

	/*
	 * If the surface is non_uniform we have to compress the knots.
	 */

	if ( geometry->u_non_uniform )
	{
	    MAbcukunexpand ( msg, &geometry->u_order, &geometry->u_num_knots,
		geometry->u_knots, &geometry->u_num_knots, geometry->u_knots );

	    if ( geometry->u_num_knots == 0 )
	    {
		geometry->u_non_uniform = 0;
	    }
	}
	else
	{
	    geometry->u_num_knots = 0;
	}

	if ( geometry->v_non_uniform )
	{
	    MAbcukunexpand ( msg, &geometry->v_order, &geometry->v_num_knots,
		geometry->v_knots, &geometry->v_num_knots, geometry->v_knots );

	    if ( geometry->v_num_knots == 0 )
	    {
		geometry->v_non_uniform = 0;
	    }
	}
	else
	{
	    geometry->v_num_knots = 0;
	}

	/*
	 * If the surface is periodic, we have to compress the weights &
	 * poles.
	 */

	if ( (geometry->u_periodic) && (geometry->u_order > 2) )
	{

	    old_p = geometry->poles;
	    new_p = old_p;
	    old_w = geometry->weights;
	    new_w = old_w;

	    for ( i = 0 ; i < geometry->v_num_poles ; i++ )
	    {
		MAbcupunexpand( msg, &geometry->u_order, &geometry->rational,
				&geometry->u_num_poles, old_p, old_w,
				&new_num_poles, new_p, new_w );

		old_p += geometry->u_num_poles * 3;
		new_p += new_num_poles * 3;
		old_w += geometry->u_num_poles;
		new_w += new_num_poles;
	    }

	    geometry->u_num_poles = new_num_poles;

	} /* end compressing knots in u */

	if ( (geometry->v_periodic) && (geometry->v_order > 2) )
	{

	/*
	 * Compressing the poles in v is easy. In the end, we're just gonna
	 * have the first (v_order / 2 - 1) rows removed and enough
	 * rows left off at the end to make a total of (v_order - 2)
	 * rows left off.
	 */

	    poles_lost = geometry->v_order - 2;
	    geometry->v_num_poles -= poles_lost;

	    if ( poles_lost > 1 )
	    {
	    /*
	     * If poles_lost is 1, then the row lost is on the end
	     * of the array and we don't have to do any moving.
	     */

		old_p = geometry->poles +
		    (geometry->v_order / 2 - 1) * geometry->u_num_poles * 3;
		new_p = geometry->poles;

		new_num_poles = geometry->u_num_poles * geometry->v_num_poles;

		for ( i = 0 ; i < new_num_poles * 3 ; i++ )
		{
		    *new_p++ = *old_p++;
		}

		if ( geometry->rational )
		{
		    old_w = geometry->weights +
			(geometry->v_order / 2 - 1) * geometry->u_num_poles;
		    new_w = geometry->weights;

		    for ( i = 0 ; i < new_num_poles ; i ++ )
		    {
			*new_w++ = *old_w++;
		    }

		} /* end rational case */

	    } /* end poles_lost > 1 */

	} /* end compressing poles & weights in  v */

	new_num_poles = geometry->u_num_poles * geometry->v_num_poles;

	if ( geometry->rational )
	{

	    /*
	     * unweight poles for IGDS.
	     */

	    new_p = geometry->poles;
	    new_w = geometry->weights;

	    for ( i = 0 ; i < new_num_poles ; i++, new_w++ )
	    {
		for ( j = 0 ; j < 3 ; j++ )
		{
		    *new_p++ /= *new_w;
		}
	    }

	    /*
	     * make sure all weight values are less than 1.
	     */

	    weight_ptr = geometry->weights;
	    GUarray_max(weight_ptr,&max_weight,new_num_poles);

	    if ( max_weight > 1.0 )
	    {
		for ( i = 0 ; i < new_num_poles ; i++ )
		{
		    geometry->weights[i] = geometry->weights[i] / max_weight;
		}
	    }

	} /* end correcting weights for IGDS */

	/*
	 * load necessary header data such as words in description.
	 */

	surface->header.words_to_follow = 27;
	surface->header.graphic_group   = (IGRshort) grgroup[3];
	surface->header.index_to_ae	= 13;
	surface->surf.surf_type		= 0;
	surface->surf.order_u		= geometry->u_order - 2;
	surface->surf.order_v		= geometry->v_order - 2;
	surface->surf.num_poles_u	= geometry->u_num_poles;
	surface->surf.num_poles_v	= geometry->v_num_poles;
	surface->surf.num_knots_u	= geometry->u_num_knots;
	surface->surf.num_knots_v	= geometry->v_num_knots;

	surface->surf.order_u      	|= 0x10;

	if ( geometry->rational )
	{
	    surface->surf.order_u      |= 0x40;
	}

	if ( geometry->u_periodic )
	{
	    surface->surf.order_u      |= 0x80;
	}

	if ( geometry->v_periodic )
	{
	    surface->surf.order_v      |= 0x80;
	}

	surface->surf.rules_u = 2;
	surface->surf.rules_v = 2;

	surface->surf.num_boundaries	=
	    (geometry->num_boundaries < 16) ? geometry->num_boundaries : 16;

	surface->surf.wds_in_descript = 9;

	if ( ! strncmp(class_name, "GR2", 3) )
	{
	    surface->surf.wds_in_descript +=
		geometry->v_num_poles * (19 + 4 * geometry->u_num_poles);
	}
	else
	{
	    surface->surf.wds_in_descript +=
		geometry->v_num_poles * (19 + 6 * geometry->u_num_poles);
	}

	if ( geometry->rational )
	{
	    surface->surf.wds_in_descript +=
		geometry->v_num_poles * (18 + 2 * geometry->u_num_poles);
	}

	if ( geometry->u_non_uniform || geometry->v_non_uniform )
	{
	    surface->surf.wds_in_descript +=
		18 + 2 * (geometry->u_num_knots + geometry->v_num_knots);
	}

	m = 0;
	n = 0;
	for ( i = 0 ; i < geometry->num_boundaries && m < 16 ; i++ )
	{
	    temp = geometry->bdrys[i].num_points;

	    /*
	     *  Check to make sure entire boundary will fit into 
	     *  at the most four(4) IGDS type 25's
	     */

	    if ( temp <= 600 && ((m+(temp/150)) < 16) )
	    {
		n++;
	    	j = 1;
		while ( j < temp && m < 16)
	    	{
		    if ( temp >= j + 150 )
		    {
		    	surface->surf.wds_in_descript += 624;
		    }
		    else
		    {
		        surface->surf.wds_in_descript += 
					20 + (temp - j + 1) * 4;
		    }
		    j += 150;
		    m++;
		}
	    }
	}

	surface->surf.num_boundaries = n;
	GUswapint( &surface->surf.wds_in_descript,
		 &surface->surf.wds_in_descript );

	*igds_size = 58;

    	GRadd_dmrs_to_buf(&name_msg, grgroup, igds);

        /* check whether a user-defined linestyle is present */
        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(&name_msg, symbology->display_attr.style, igds);

	*igds_size = (surface->header.words_to_follow + 2) * 2;

        /*
         *  Write the element out to the file.
         */

	brc = GUwrite_element(	msg, dgn_buf, surface, &type, igds_size,
				file_des, &write_mode, &block_ptr,
				&byte_ptr );

	if ( *msg != GUsuccess )
	{
	    goto wrap_up;
	}

	/*
	 * if the surface is non-uniform, we have to write out a type 26 knot
	 * element.
	 */

	if ( geometry->u_non_uniform || geometry->v_non_uniform )
	{

	    /*
	     * We have to copy the knot vectors into one contiguous array.
	     */

	    double_ptr1 = knots;
	    double_ptr2 = geometry->u_knots;

	    for ( i = 0 ; i < geometry->u_num_knots ; i++ )
	    {
		*double_ptr1++ = *double_ptr2++;
	    }

	    double_ptr2 = geometry->v_knots;

	    for ( i = 0 ; i < geometry->v_num_knots ; i++ )
	    {
		*double_ptr1++ = *double_ptr2++;
	    }

	    i = geometry->u_num_knots + geometry->v_num_knots;

	    brc = GUotype26( msg, file_des, dgn_buf, igds, igds_size,
			     class_name, geometry, range, symbology,
			     geometric_props, properties, knots, &i );

	    if ( *msg != GUsuccess )
	    {
		goto wrap_up;
	    }

	}

	/*
	 * If the surface contains boundaries, we have to write out the
	 * boundary elements now.
	 */

	if ( geometry->num_boundaries )
	{
	    m = 0;
	    for ( i = 0 ; i < geometry->num_boundaries && m < 16 ; i++ )
	    {

		temp = geometry->bdrys[i].num_points;

		/*
		 * We have to check and make sure the knot range is
		 * appropriate, ie. 0-1. If it isn't, we have to scale
		 * and translate as needed.
		 */

		if ( (min_u  != 0.0) || (min_v  != 0.0) ||
		     (diff_u != 1.0) || (diff_v != 1.0) )
		{

		    for ( j = 0 ; j < temp * 2 ; j += 2 )
		    {

			geometry->bdrys[i].points[j] =
			    (geometry->bdrys[i].points[j] - min_u) / diff_u;

			geometry->bdrys[i].points[j+1] =
			    (geometry->bdrys[i].points[j+1] - min_v) / diff_v;


		        /*  eliminate trailing digits in
			 *  boundary parameters due to
			 *  floating point arithmetic
			 */

			if(geometry->bdrys[i].points[j]<0.0)
			  geometry->bdrys[i].points[j] = 0.0;

			if(geometry->bdrys[i].points[j]>1.0)
			  geometry->bdrys[i].points[j] = 1.0;

			if(geometry->bdrys[i].points[j+1]<0.0)
			  geometry->bdrys[i].points[j+1] = 0.0;

			if(geometry->bdrys[i].points[j+1] > 1.0)
			  geometry->bdrys[i].points[j+1] = 1.0;
		    }

		} /* end correcting boundary points */

		/*
		 *  Check to make sure entire boundary can fit
		 */

		if ( (temp <= 600 ) && ((m+(temp/150)) < 16) )
	 	{
		    j = 1;

		    while ( j < temp && m < 16 )
		    {

		        if ( temp >= j + 150 )
		        {
			    k = 151;
		        }
		        else
		        {
			    k = temp - j + 1;
		        }

		        /*
		         * l is the boundary number we're working on.
		         * j is the index into the array of boundary points.
		         * k is the number of boundary points for this element.
		         */

		        l = i + 1;

		        brc = GUotype25( msg, file_des, dgn_buf, igds,
					 igds_size, class_name, geometry,
					 range, symbology, geometric_props,
					 properties, 
					 &geometry->bdrys[i].points[(j-1)*2 ],
				         &k, &l);

		        if ( *msg != GUsuccess )
		        {
			    goto wrap_up;
		        }

		        j += 150;
		        m++;

		    } /* end while for single boundary */
	        } /* end if fit */
	        else
	        {
		    /* boundary will be skipped */
  	        }
	    } /* end for loop for num_boundaries */

	} /* end if num_boundaries */

	/*
	 * write out pole elements.
	 */

	new_p = geometry->poles;
	new_w = geometry->weights;

	for ( i = 0 ; i < geometry->v_num_poles ; i++ )
	{

	    brc = GUotype21( msg, file_des, dgn_buf, igds, igds_size,
			     class_name, geometry, range, symbology,
			     geometric_props, properties, new_p,
			     &geometry->u_num_poles );

	    if ( *msg != GUsuccess )
	    {
		goto wrap_up;
	    }

	    /*
	     * if the surface is rational, we have to write out a type 28
	     * weight factor element.
	     */

	    if ( geometry->rational )
	    {
		brc = GUotype28( msg, file_des, dgn_buf, igds, igds_size,
				 class_name, geometry, range, symbology,
				 geometric_props, properties, new_w,
				 &geometry->u_num_poles );
	    }

	    new_p += geometry->u_num_poles * 3;
	    new_w += geometry->u_num_poles;

	} /* end poles and weights */

wrap_up:

    for(m=0;m<geometry->u_num_poles*geometry->v_num_poles*3;m++) geometry->poles[m] /= scale;

	return(brc);

} /* end VDXtype24 */
