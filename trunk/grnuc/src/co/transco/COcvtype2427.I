/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function converts an IGDS B-spline curve or
 *  B-spline surface to its OSA counterpart.
 */

class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "bsparameters.h"
#include "bserr.h"

from GRgraphics import GRchgprops;

method cvt_type2427 (IGRlong *msg; struct GRid *object_info)
{
	struct IGDS_bscurve	*igdsbscurve = NULL;

	struct IGDS_bssurf	*igdsbssurf = NULL;

	struct IGDS_bscomponent	*igdsbscomponent;

	static IGRchar		*GUbc_classes[3] = { "GR2ibcsubbc",
						     "GR3ibcsubbc",
						     "GRbcsubbc"    };

	IGRchar			class_name[80];	/* class name for object     */
	IGRshort		i;		/* loop counter		     */
	IGRint			sav_ele_size;
	IGRlong 		ret_code = 0;	/* bs function return status */
	IGRlong			status = 0;
	IGRshort		bs_stat;
	IGRlong			*long_ptr;
	IGRshort		*short_ptr;
	IGRchar			*char_ptr;
	IGRlong			num_longs = 0;
	IGRshort		num_knots = 0;
	IGRshort		num_poles = 0;
	short unsigned		props;
	IGRuchar 		level = 0;
	IGRlong			nbytes;
	IGRlong			size;
	IGRshort		datflg;
	IGRchar			*buf_ptr;
	struct IGResbc		class_attr;
	struct IGResbs		class_attr2;
	struct GUcontrol_struct	*formatted_bs;
	IGRshort		ndices;
	IGRshort		surf_type;
	short unsigned		symbology = 0;
	IGRlong			tempdummy;
	IGRboolean		polydis = FALSE;
	IGRboolean		surfdis;
	IGRboolean		dealloc_flag;
	IGRlong			num_uvpoles;
	IGRdouble		dist_tol;
	IGRdouble		distance;
	IGRvector		dummy_vector;
extern    void    BSsftstclsd();
extern    void    BStst_plan();
	struct GUcommon_header_info element;	/* GUgetname info	     */
	IGRint			has_link;
	IGRchar			name[257];	/* element's name	     */
	IGRshort		set = 1;
	IGRshort		properties;
	IGRchar			*typeface = NULL;
	IGRchar			*charmap = NULL;

	/*
	 *  Initialize flags.
	 */

	bs_stat = 1;
	dealloc_flag = FALSE;
	sav_ele_size = me->cvt_bufs.ele_size;
	
	if ( me->IGDS_file_type == GU_2I )
	{
	    ndices = 2;
	}
	else
	{
	    ndices = 3;
	}

	datflg = -1;

	/*
 	 *  Cast buffer to reflect a curve or a surface.
	 */

	switch ( me->cvt_bufs.ele_type )
	{
	    case GU_BS_CURVE_HEADER:
#ifdef BIG_ENDIAN
		GRswap_type27_ele(me->cvt_bufs.ele_buf);
#endif
		igdsbscurve = (struct IGDS_bscurve *) me->cvt_bufs.ele_buf;
		symbology = igdsbscurve->header.symbology;
		props = igdsbscurve->header.properties;
		level = igdsbscurve->header.level;
		num_knots = igdsbscurve->curve.num_knots;
		surf_type = 0;
		if ( igdsbscurve->curve.order & 0x10 )
		{
		    surfdis = TRUE;
		    status = (OM_S_SUCCESS);
	    	}
		else
		{
		    surfdis = FALSE;
		    status = FALSE;
		}
		if ( igdsbscurve->curve.order & 0x20 )
		{
		    polydis = TRUE;
		    status = ( OM_S_SUCCESS);
		}
		else
		{
		    polydis = FALSE;
		    status = FALSE;
		}

		break;
	    case GU_BS_SURF_HEADER:
#ifdef BIG_ENDIAN
		GRswap_type24_ele(me->cvt_bufs.ele_buf);
#endif
		igdsbssurf = (struct IGDS_bssurf *) me->cvt_bufs.ele_buf;
		symbology = igdsbssurf->header.symbology;
		props = igdsbssurf->header.properties;
		level = igdsbssurf->header.level;
		num_knots = igdsbssurf->surf.num_knots_u +
			    igdsbssurf->surf.num_knots_v;
		surf_type = igdsbssurf->surf.surf_type;
		if ( igdsbssurf->surf.order_u & 0x10 )
		{
		    surfdis = TRUE;
		    status = ( OM_S_SUCCESS);
		}
		else
		{
		    surfdis = FALSE;
		    status = FALSE;
		}
		if ( igdsbssurf->surf.order_u & 0x20 )
		{
		    polydis = TRUE;
		    status = ( OM_S_SUCCESS);
		}
		else
		{
		    polydis = FALSE;
		    status = FALSE;
		}

		break;
	}

	/*
	 *  Call routine to determine the size of the buffer
	 *  needed to hold the bspline representation of the
	 *  OSA object.  If the default buffer is not large
	 *  enough, then allocate a buffer that is large enough.
	 */

	GUbsp_bufsize ( me->cvt_bufs.ele_buf, &datflg, &size );
	if ( size*2+32 > GUBSBUF_SIZE )
	{
	    nbytes = size * 2 + 84;
	    buf_ptr = om$malloc ( size = nbytes );
	    dealloc_flag = TRUE;
	}
	else
	{
	    buf_ptr = me->cvt_bufs.bs_buf;
	}

	/*
	 *  Call routines to take IGDS elements and format the
	 *  OSA bspline representation.
	 */

	ret_code = GUbsp_format ( &bs_stat, me->cvt_bufs.ele_buf, 
				  &ndices, buf_ptr, &size );

	while ( (ret_code == 1) && (bs_stat == 1) )
	{
	    status = om$send (	mode = OM_e_wrt_object, 
				msg = message COcvigdsige.cvt_next_ele (
					       msg, object_info ), 
				senderid = my_id, 
				targetid = my_id );
				
	    sav_ele_size += me->cvt_bufs.ele_size;

	    igdsbscomponent = (struct IGDS_bscomponent *) me->cvt_bufs.ele_buf;
	    long_ptr = (IGRlong *) &(igdsbscomponent->components);


	    switch ( me->cvt_bufs.ele_type )
	    {
		case GU_BS_KNOT:

	    	    for ( i = 0; i < num_knots; i++ )
	    	    {
			GUswapint ( &(long_ptr[i]), &tempdummy );
	    	    }

		    status = ( OM_S_SUCCESS);
		    break;

		case GU_BS_POLE:


		    short_ptr = (IGRshort *) &(igdsbscomponent->components);
		    num_poles = *short_ptr;
		    if ( me->IGDS_file_type == GU_2I)
		    {
	    		/*
	    		 * 2-D bspline curve.
	    		 */

	    		num_longs = num_poles * 2;

		    }
		    else
		    {
	    		/*
   	    		 * 3-D b-spline curve.
	    		 */
	
	    		num_longs = num_poles * 3;
	
		    }

		    short_ptr++;
	    	    char_ptr = (IGRchar *) short_ptr;

		    for ( i = 0; i < num_longs; i++ )
		    {
	    		GUswapint_by_char ( char_ptr );
			char_ptr += 4;
		    }
		    status = ( OM_S_SUCCESS);
		    break;
		case GU_BS_WEIGHT_FACTOR:

	    	    for ( i = 0; i < num_poles; i++ )
	    	    {
			GUswapint ( &(long_ptr[i]), &tempdummy );
	    	    }

		    status = ( OM_S_SUCCESS);
		    break;
		case GU_BS_SURF_BOUNDARY:
		    
		    short_ptr = (IGRshort *) &(igdsbscomponent->components);
		    short_ptr++;
		    num_longs = *short_ptr;
		    short_ptr++;
		    long_ptr = (IGRlong *) short_ptr;

		    for ( i = 0; i < num_longs*2; i++ )
		    {
			GUswapint ( &(long_ptr[i]), &tempdummy );
		    }

		    status = ( OM_S_SUCCESS);
		    break;

	    }

	    /*
	     *  Call routine to continue to format the bspline
	     *  representation of the curve or surface.
	     */

	    ret_code = GUbsp_format ( &bs_stat, me->cvt_bufs.ele_buf, &ndices, 
				      buf_ptr, &size );

	} /* end while */

	/*
	 *  Construct the B-spline curve or surface object if 
	 *  the entire IGDS element was processed successfully.
	 */

	if ( (ret_code == 1) && (bs_stat == 3) )
	{

	    formatted_bs = (struct GUcontrol_struct *) buf_ptr;

	    /*
	     *  Set up construction parameters for either the
	     *  curve or the surface.
	     */

	    switch ( formatted_bs->iscurve )
	    {
		case TRUE:

		    /*
		     *  This is a bspline curve element.
		     */
		    if (! formatted_bs->curve.rational )
		    {
			formatted_bs->curve.weights = 0;
		    }
	    	    strcpy ( class_name, GUbc_classes[me->object_type] );

	    	    /*
	     	     *  Set up class attributes for the object.
	     	     */

	    	    class_attr.is_polydis = polydis;
	    	    class_attr.is_curvedis = TRUE;

		    status = BSEXTRACTPAR ( msg, BSTOLLENVEC, dist_tol );

		    MA2pt2dis ( msg, &formatted_bs->curve.poles[0],
				&formatted_bs->curve.poles[(num_poles-1)*3],
				&distance );

		    if ( distance < (dist_tol * dist_tol) )
		    {
			formatted_bs->curve.phy_closed = TRUE;
		    }
		    else
		    {
			formatted_bs->curve.phy_closed = FALSE;
		    }

		    BStst_plan ( formatted_bs->curve.num_poles,
				 formatted_bs->curve.poles,
				 formatted_bs->curve.weights,
				 &formatted_bs->curve.planar,
				 dummy_vector, msg );
		    /*
		       Check the user data linkage for an element name.
		     */
		    element = igdsbscurve->header;
		    has_link = GUattr_link (msg, &igdsbscurve->header, name,
				&igdsbscurve->header.symbology,
				typeface, charmap);
		
            	    /*
	     	     *  construct an OSA object
	     	     */

	    	    status = GUconstruct( &(formatted_bs->curve), 
				 object_info, 
		    	    	 class_name, &level, &symbology, 
				 &props, &class_attr, &me->scale_factor,
				 &me->current_env );

		    if (has_link & HAS_FILLED_TYPE)
		    {
		       properties = 0;
		       properties |= GRFILLED_DISPLAY;
		       status = om$send (
				msg = message GRgraphics.GRchgprops (msg, &set,
								&properties),
				targetid = object_info->objid,
				targetos = object_info->osnum);
		    }
		    break;
		case FALSE:

		    /*
		     *  This is a B-spline surface element.
		     */

	 	    if ( !formatted_bs->surf.rational )
		    {
			formatted_bs->surf.weights = 0;
		    }
		    strcpy ( class_name, "EMSgenbs" );

	    	    /*
	    	     *  Set up class attributes for the object.
	    	     */

	    	    class_attr2.u_rules = 0;
	    	    class_attr2.v_rules = 0;
	    	    class_attr2.is_polydis = polydis;
	    	    class_attr2.is_surfdis = TRUE;
	    	    class_attr2.is_slowdis = FALSE;
	    	    class_attr2.type = 0;
	    
		    BSsftstclsd ( &formatted_bs->surf, msg );

		    num_uvpoles = formatted_bs->surf.u_num_poles *
			          formatted_bs->surf.v_num_poles;

		    BStst_plan ( num_uvpoles, formatted_bs->surf.poles,
				 formatted_bs->surf.weights, 
				 &formatted_bs->surf.planar, dummy_vector,
				 msg );

		    /*
		       Check the user data linkage for an element name.
		     */
		    element = igdsbssurf->header;
		    has_link = GUattr_link (msg, &igdsbssurf->header, name,
					&igdsbssurf->header.symbology,
					typeface, charmap);

            	    /*
	    	     *  construct an OSA object
	    	     */

	    	    status = GUconstruct( &(formatted_bs->surf), 
				 object_info, 
		    	   	 class_name, &level, &symbology, 
				 &props, &class_attr2, &me->scale_factor,
				 &me->current_env );

		    if (has_link & HAS_FILLED_TYPE)
		    {
		       props = 0;
		       props |= GRFILLED_DISPLAY;
		       status = om$send (
				msg = message GRgraphics.GRchgprops (msg, &set,
						(IGRshort *)&props),
				targetid = object_info->objid,
				targetos = object_info->osnum);
		    }

		    break;

		    /* 
		     *  Enter the IGDS element's name into the translated element's
		     *  data structure.

		     if (has_link & HAS_NAME_TYPE)
		     {
		       GUputname(msg, name, object_info, &me->current_env);
 		     }

		     */

	    }
	}

	if ( dealloc_flag )
	{
	    om$dealloc ( ptr = buf_ptr );
 	}

 	me->cvt_bufs.ele_size = sav_ele_size;

return (status) ;

}
end implementation COcvigdsige;
