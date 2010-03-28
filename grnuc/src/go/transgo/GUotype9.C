/*
Name
        GUotype9

Description
        This function formats and writes an IGDS type 9 design file
        header element.

History
        moses   01/01/01    created
        mrm     03/31/92    removed swap for vwtrn and vwcnv
*/

#include "exsysdep.h"
/*
#include "grimport.h"
*/
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "igr.h"
#include "msdef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "codef.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "exmacros.h"


IGRint GUotype9(msg, ele_buf, gragad_setup, scale_factor, trans_limits)
IGRlong 	*msg;
IGRchar		*ele_buf;
struct GRid	gragad_setup[];
IGRdouble	*scale_factor;
IGRdouble	trans_limits[];
{
    IGRchar		mu_name[3];
    IGRchar		su_name[3];
    IGRchar		*viewmode_ptr;
    IGRchar		screen1;
    IGRchar		screen2;
    IGRboolean		chk_status;
    IGRboolean 		vw_overflow = FALSE;
    IGRshort		*ele_ptr;
    IGRshort		*musupu_ptr;
    IGRshort		level;
    IGRshort		dim = 4;
#ifdef BIG_ENDIAN
    IGRshort            swapped_short;
    IGRint              swapped_int;
#endif
    IGRint		i;
    IGRint		j;
    IGRlong		gragad_flags[2];
    IGRlong		status;
    IGRlong		temp_long;
    IGRlong		ret_bytes1;
    IGRlong		ret_bytes2;
    IGRlong		ret_bytes3;
    IGRlong		ret_bytes4;
    IGRlong		ret_bytes5;
    IGRlong		ret_bytes6;
    IGRlong		which_error;
    IGRlong		vw_transform[18];
    IGRlong		num_vals = 7;
    IGRlong		vw_cnv[2];
    IGRulong	        musupu[3];
    IGRdouble		act_z;
    IGRdouble		origin[3];
    IGRdouble		new_pts[3];
    IGRdouble		rotation[16];
    IGRdouble		invmx[16];
    IGRdouble		wld_to_view[16];
    IGRdouble		vw_volume[6];
    IGRdouble		uom_factor;
    IGRdouble		my_max;
    IGRdouble		chk_array[7];
    IGRdouble		conversion;
    IGRdouble		x_uor;
    IGRdouble		y_uor;
    IGRdouble		scale_x;
    IGRdouble		scale_y;
    IGRdouble		xyz_extents[3];
    struct var_list	params[7];
    struct GRid		module;
    struct GRdpb_scale  act_scales;
    struct IGRdisplay   display;


    *msg = MSSUCC;
    ex$get_cur_mod(id = &module.objid, osnum = &module.osnum);

    /*
     *  Initialize pointers into the type 9 element.
     */

    ele_ptr = (IGRshort *)ele_buf;

    musupu_ptr = ele_ptr + 554;
    viewmode_ptr = (IGRchar *)(ele_ptr + 22);
#ifdef BIG_ENDIAN
    screen1 = *(viewmode_ptr + 1);
    screen2 = *viewmode_ptr;
#else
    screen1 = *viewmode_ptr++;
    screen2 = *viewmode_ptr;
#endif
    ele_ptr += 23;

    /*
     *  Set up the scale factor for IGE to IGDS working units
     */

    OM_BLOCK_MOVE(musupu_ptr, musupu, 12);
    musupu_ptr += 6;

    OM_BLOCK_MOVE(musupu_ptr, mu_name, 2);
    musupu_ptr += 1;

    OM_BLOCK_MOVE(musupu_ptr, su_name, 2);
    musupu_ptr += 1;

    mu_name[2] = '\0';
    su_name[2] = '\0';

#ifdef BIG_ENDIAN
    GRconv_int(&musupu[0],&musupu[0]);
    GRconv_int(&musupu[1],&musupu[1]);
    GRconv_int(&musupu[2],&musupu[2]);
#endif
    GUswapint(&musupu[0], &musupu[0]);
    GUswapint(&musupu[1], &musupu[1]);
    GUswapint(&musupu[2], &musupu[2]);
    *scale_factor = (long)(musupu[1] * musupu[2]);
    
    status = co$cvt_exp_to_wrk(msg = msg,
                               osnum = module.osnum,
                               unit_type = "UOM_DISTANCE",
                               units = 1.0,
                               alias = mu_name,
                               result = &uom_factor);

    /* dhm   2/25/92
     * mu_name is coming in as MU (most of the time) which the UOM system
     * doesn't reckonize as a valid alias. Therefore, set the status return
     * code back to success and keep processing with the current scale
     * factor.
     */

    if (*msg & status & 1)
    {
	*scale_factor /= uom_factor;
    }
    else
    {
        status = 1;
    }

    /*
     *  Set up the view information in the design
     *	header (if specified) for each of the eight IGDS views.
     */

    for (i = 0; i < 8; i++)
    {
	/*
         * clear the line constructs bit so that elements of class
         * "Construction element" will not be displayed
         */

#ifdef BIG_ENDIAN
	*ele_ptr &= ~(0x0010);
#else
	*ele_ptr &= ~(0x1000);
#endif
	/*
         *  Check to see if view information has been specified
         *  for this view.  NULL if not specified.
         */

	if (gragad_setup[i].objid != NULL)
	{
	    /*
             *  force slow text and slow font
             */

#ifdef BIG_ENDIAN
	    *ele_ptr &= 0xFDFF; /* clear fast text bit */
	    *ele_ptr |= 0x0400; /* set slow font bit   */
#else
	    *ele_ptr &= 0xFFFD; /* clear fast text bit */
	    *ele_ptr |= 0x0004; /* set slow font bit   */
#endif
	    /*
             *  Inquire the window parameters which will specify
             *  the view information for this view.
             */

	    params[0].var 		= GRAGAD_FLAGS;
	    params[0].var_ptr		= (IGRchar *)gragad_flags;
	    params[0].num_bytes		= sizeof(IGRlong)*2;
	    params[0].bytes_returned	= &ret_bytes1;
	
	    params[1].var 		= VW_VOLUME;
	    params[1].var_ptr		= (IGRchar *)vw_volume;
	    params[1].num_bytes		= sizeof(IGRdouble)*6;
	    params[1].bytes_returned	= &ret_bytes2;
	
            /*
                changed param from VIEW_ROTATION for TR 91N3825 - iso
                view would not plot if reference plane lock was on.
                12/31/91 - vce
            */
	    params[2].var 		= VW_ROT_NO_CON;
	    params[2].var_ptr		= (IGRchar *)rotation;
	    params[2].num_bytes		= sizeof(IGRdouble)*16;
	    params[2].bytes_returned	= &ret_bytes3;
	
	    params[3].var 		= VIEW_ORIGIN;
	    params[3].var_ptr		= (IGRchar *)origin;
	    params[3].num_bytes		= sizeof(IGRdouble)*3;
	    params[3].bytes_returned	= &ret_bytes4;
	
	    params[4].var 		= ACT_Z;
	    params[4].var_ptr		= (IGRchar *)&act_z;
	    params[4].num_bytes		= sizeof(IGRdouble);
	    params[4].bytes_returned	= &ret_bytes5;

	    params[5].var		= WLD_TO_VIEW;
	    params[5].var_ptr		= (IGRchar *)wld_to_view;
	    params[5].num_bytes		= sizeof(IGRdouble)*16;
	    params[5].bytes_returned 	= &ret_bytes6;

	    params[6].var 		= END_PARAM;
	
	    status = dp$inq_set_gragad(msg = msg, 
                                       inq0_set1 = 0, 
                                       osnum = gragad_setup[i].osnum, 
                                       gragad_objid = gragad_setup[i].objid, 
                                       which_error = &which_error, 
                                       var_list = params);
					
 	    if (!(status & 1))
	    {
		goto wrap_up;
	    }

            /* set the grid display flag (TR90N1904) */

	    if (*gragad_flags & GRID_ON)
	    {
#ifdef BIG_ENDIAN
                *ele_ptr |= 0x0002;
#else
                *ele_ptr |= 0x0200;
#endif
	    }

            if (trans_limits)
            {
                /* insert the plot range rather than the view range */
                OM_BLOCK_MOVE(&trans_limits[6], vw_volume,
                              6 * sizeof(IGRdouble));
            }

     	    /*
             *  Apply scale factor and check for integer overflow.
             */

	    for (j = 0; j < 3; j++)
	    {
		origin[j] *= *scale_factor;
		chk_array[j] = origin[j];
	    }
	    for (j = 0; j < 6; j++)
	    {
		vw_volume[j] *= *scale_factor;
	    }

	    /*
             *  Set up view conversion factor, and calculate the x and y
             *  extents
             */

	    if (((i+1) == screen1) || ((i+1) == screen2))
	    {
		x_uor = 1280;   /*  full screen mode  */
		y_uor = 992;
	    }
	    else
	    {
		x_uor = 640;    /*  quad screen mode  */
		y_uor = 496;
	    }

	    scale_x = x_uor / (vw_volume[3] - vw_volume[0]);
	    scale_y = y_uor / (vw_volume[4] - vw_volume[1]);

	    if (scale_x < scale_y)
	    {
		conversion = scale_x;
	    }
	    else
	    {
		conversion = scale_y;
	    }

            if (trans_limits)
            {
                /* set the view extents to the plot space */

		xyz_extents[0] = vw_volume[3] - vw_volume[0];
		xyz_extents[1] = vw_volume[4] - vw_volume[1];
	    	xyz_extents[2] = vw_volume[5] - vw_volume[2];
            }
	    else
	    {
		xyz_extents[0] = x_uor / conversion;
		xyz_extents[1] = y_uor / conversion;
	    	xyz_extents[2] = vw_volume[5] - vw_volume[2];
            }

	    chk_array[3] = xyz_extents[0];
	    chk_array[4] = xyz_extents[1];
	    chk_array[5] = xyz_extents[2];

	    act_z *= *scale_factor;
	    chk_array[6] = act_z;

	    chk_status = GUcheck_overflow(msg, &num_vals, chk_array,
                                          &my_max);
	    if (!chk_status)
	    {
		vw_overflow = TRUE;
	   	ele_ptr += 59;
	    }
	    else
	    {
	    	/* 
                 *  Set up view table information.
                 */

	    	ele_ptr += 5;

	    	/* 
                 *  Set up the view origin.
                 */
	
		j = 1;

		MAptsxform(msg, &j, wld_to_view, origin, new_pts);

		new_pts[0] += vw_volume[0];
		new_pts[1] += vw_volume[1];
		new_pts[2] += vw_volume[2];

		MAinvmx(msg, &dim, wld_to_view, invmx);

		MAptsxform(msg, &j, invmx, new_pts, new_pts);

	    	for (j = 0; j < 3; j++)
	    	{
		    temp_long = GUnint(new_pts[j]);
	   	    GUswapint(&temp_long, &temp_long);
#ifdef BIG_ENDIAN
		    GRconv_int(&temp_long,&temp_long);
#endif
		    memcpy(ele_ptr, &temp_long, 4);
		    ele_ptr += 2;
	    	}

	    	/*
                 *  Set up the view extents.
                 */

	    	for (j = 0; j < 3; j++)
	    	{
		    temp_long = GUnint(xyz_extents[j]);
	  	    GUswapint(&temp_long, &temp_long);
#ifdef BIG_ENDIAN
		    GRconv_int(&temp_long,&temp_long);
#endif
		    memcpy(ele_ptr, &temp_long, 4);
		    ele_ptr += 2;
	    	}

	    	/*
                 *  Set up the view transformation matrix.
                 */

	    	rotation[3] = rotation[4];
	    	rotation[4] = rotation[5];
	    	rotation[5] = rotation[6];
	    	rotation[6] = rotation[8];
	    	rotation[7] = rotation[9];
	    	rotation[8] = rotation[10];

	    	GRFlt32ToFltVax(9, rotation, vw_transform);
		memcpy(ele_ptr, vw_transform, 72);
	    	ele_ptr += 36;

	    	/*
                 *  Set up view conversion factor.
                 */

		GRFlt32ToFltVax(1, &conversion, &vw_cnv[0]);
		memcpy(ele_ptr, vw_cnv, 8);
	    	ele_ptr += 4;

	    	/*
                 *  Set up the view active z.
                 */
	
	    	temp_long = GUnint(act_z);
	        GUswapint(&temp_long, &temp_long);
#ifdef BIG_ENDIAN
	        GRconv_int(&temp_long,&temp_long);
#endif
		memcpy(ele_ptr, &temp_long, 4);
	        ele_ptr += 2;
	    }
	}
	else
	{
	    ele_ptr += 59;
	}
    }

    /*
     *	Set up the active system parameters from the DPB.
     */

    ele_ptr += 15;

    /*
     *  Get the active symbology from the DPB.
     */

    gr$get_active_scale(buffer = &act_scales);

    GRFlt32ToFltVax(1, &act_scales.Active_xscale, &vw_transform[0]);
    GRFlt32ToFltVax(1, &act_scales.Active_yscale, &vw_transform[2]);
    GRFlt32ToFltVax(1, &act_scales.Active_zscale, &vw_transform[4]);
    memcpy(ele_ptr, vw_transform, 24);
    ele_ptr += 33;

    gr$get_active_level(buffer = &level);

    *((IGRchar *) ele_ptr) = level;
    ele_ptr += 3;

    gr$get_active_display(buffer = &display);

    *(((IGRchar *) ele_ptr) + 1) = display.color;
    *((IGRchar *) ele_ptr) = (display.weight << 3) |
        display.style;

wrap_up:

    if (vw_overflow)
    {
	*msg = GUVIEW_OVERFLOW;
    }

    return(TRUE);
}
