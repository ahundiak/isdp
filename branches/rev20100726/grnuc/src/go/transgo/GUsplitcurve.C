/* #######################    APOGEE COMPILED   ######################## */
/*
 * This function takes a general B-spline curve with boundaries, splits it
 * at the boundary values, and creates multiple IGDS B-spline curves.
 * Currently, the multiple generated curves are not grouped in any manner.
 *
 * History
 *    ????    ??/??/??   long,long ago
 *    dhm     04/02/92   changed the allocation of the output curve because
 *                       it wasn't allocated enough memory for the poles and
 *                       knots in all cases.
 */

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "madef.h"
#include "transdef.h"
#include "transerr.h"

GUsplit_curve(	msg, file_des, dgn_buf, igds, igds_size, class_name, geometry,
		range, symbology, geometric_props, properties, bsc_attr )

    IGRlong		*msg;
    IGRint		*file_des;
    IGRchar		*dgn_buf;
    IGRchar		*igds;
    IGRint		*igds_size;
    IGRchar		class_name[];
    struct IGRbsp_curve	*geometry;
    GRrange		range;
    struct GRsymbology	*symbology;
    struct GRprops	*geometric_props;
    IGRshort		*properties;
    struct IGResbc	*bsc_attr;

{ /* begin GUsplit_curve */

    IGRboolean		brc;
    IGRboolean		planar;
    IGRboolean		sts;
    IGRboolean		has_name = FALSE;
    IGRboolean		fill_bit = FALSE;

    IGRlong		i;

    IGRdouble		*u_start;
    IGRdouble		*u_stop;
    GRname		name;

    struct IGRbsp_curve	*curve;
    extern void         BSalloccv();
    extern IGRboolean   BSfreecv();

    *msg = GUsuccess;
    brc  = GUsuccess;

    curve = NULL;

   /*
    * If there are no boundaries, just write out the surface as is.
    */

    if ( ! geometry->num_boundaries )
    {
	GUotype27( msg, file_des, dgn_buf, igds, igds_size, class_name,
		   geometry, range, symbology, geometric_props, properties,
		   bsc_attr, &has_name, name, &fill_bit );

	if ( *msg != GUsuccess )
	{
	    brc = FALSE;
	}

	goto wrap_up;

    }

   /*
    * Well, if we made it here the curve must have some boundaries.
    */

    u_start = geometry->knots;
    u_stop = geometry->bdrys;

    /*
     * Allocate the memory for the output curve structure.  dhm  4/2/92
     */

    BSalloccv(geometry->order, geometry->num_poles, geometry->rational,
              geometry->num_boundaries, &curve, msg);

    planar = 0;

    for ( i = 0 ; i <= geometry->num_boundaries ; i++ )
    {
	if ( i == geometry->num_boundaries )
	{
	    u_stop = &geometry->knots[geometry->num_knots - 1];
	}

	if ( MAabsolute( *u_stop - *u_start ) > .0000001 )
	{
	    sts = BSactivsplt(msg,geometry,u_start,u_stop,curve,&planar);

	    if ( ! sts )
	    {
		brc = FALSE;
		*msg = GUSPLITERR;
		goto wrap_up;
	    }

	    /*  
	     * calculate the range of the curve piece
	     */

	    MAcubepy ( msg, curve, &range[0], &range[3] );

	    GUotype27(	msg, file_des, dgn_buf, igds, igds_size, class_name,
			curve, range, symbology, geometric_props, properties,
			bsc_attr, &has_name, name, &fill_bit );

	    if ( *msg != GUsuccess )
	    {
		brc = FALSE;
		goto wrap_up;
	    }

	}

	u_stop  += 2;
	u_start = u_stop - 1;

    } /* end splitting curve between boundaries */

wrap_up:

    if (curve)  BSfreecv(msg, curve);
    return(brc);

} /* end GUsplit_curve */
