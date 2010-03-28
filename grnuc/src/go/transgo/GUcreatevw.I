/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function will extract the view table information
 *  from the IGDS type 9 element and use this information to
 *  set up the windows of the OSA system to resemble the VAX
 *  based views as closely as possible.
 */

class implementation GRvg;

#include "exsysdep.h"
#include "grimport.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

from IGEwindow import activate;
from IGEgragad import gragad_cons;
from IGEgadget import add_gadget;

void     GUcreate_views ( ele_buf, db_type, scale_factor )

IGRchar			*ele_buf;
IGRint			*db_type;
IGRdouble		*scale_factor;

{
    IGRshort		*view_table_ptr;
    IGRint		i,j,k,l;
    IGRuint	level_mask[((DP_NUM_OF_LEVELS - 1) / 32 ) + 1];
    IGRint		status;
    IGRint		num_ids;
    IGRint		num_gadgets;
    IGRlong		view_array[30];
    IGRlong		msg, tempdummy;
    IGRlong		mess;
    IGRlong		ret_bytes1;
    IGRlong		ret_bytes2;
    IGRlong		ret_bytes3;
    IGRlong		ret_bytes4;
    IGRlong		ret_bytes5;
    IGRlong		ret_bytes6;
    IGRlong		ret_bytes7;
    IGRlong		ret_bytes8;
    IGRlong		ret_bytes9;
    IGRlong		which_error;
    IGRdouble		vw_volume[6];
    IGRdouble		scratch[9];
    IGRdouble		rotation[16];
    IGRdouble		origin[3];
    IGRdouble		act_z;
    IGRlong		uor_grid;
    IGRlong		grid_per_ref;
    IGRdouble		uor_per_grid;
    IGRshort		*begin_ptr;
    struct GRid		window;
    IGRshort		set0_inq1;
    IGRlong		nbytes_in_buffer;
    IGRlong		nbytes_transferred;
    struct GRmd_env	ModuleInfo;
    IGRdouble		min_x,min_y,max_x,max_y;
    IGRchar		screen1,screen2;

    static IGRchar	window_name[12] = "Window";
    static IGRchar	gadget_name[10] = "View";

    IGRint		gadget_flags[2];
    IGRint		window_flags[2];
    IGRint		grid_flag;

    GRobjid		win_ids[8];
    GRobjid		gad_ids[8];

    struct GRid		gadget;

    struct var_list	params[10];
    int                 right_left;
#ifdef BIG_ENDIAN
    int			swapped_int;
    IGRshort            swapped_short;
    IGRshort            GRswap_count;
#endif

    /*
     *  Set up view table pointer.
     */

    view_table_ptr = (IGRshort *) ele_buf;

    /*
     *  Initialize gadget flags to set.
     */

     gadget_flags[0] = GRID_ON | GRID_LOCK | IS_WIN_ON;
     gadget_flags[1] = 0;

    /*
     *  Skip type 9 header.
     */

    view_table_ptr += 14;

    /*
     *  Set up information which was common to all views
     *  in the VAX design file.
     */

#ifdef BIG_ENDIAN
    if ( *view_table_ptr & 0x0100 )
#else
    if ( *view_table_ptr & 0x0001 )
#endif
    {
	gadget_flags[1] |= GRID_LOCK;
    }

    view_table_ptr += 5;

    OM_BLOCK_MOVE( view_table_ptr, &uor_grid, 4);

#ifdef BIG_ENDIAN
    GRconv_int(&uor_grid,&swapped_int);
    uor_grid = swapped_int;
#endif
    GUswapint ( &uor_grid, &tempdummy );
    uor_per_grid = (IGRdouble) tempdummy;
    uor_per_grid /= *scale_factor;
    view_table_ptr += 2;
#ifdef BIG_ENDIAN
    GRconv_short(view_table_ptr,&swapped_short);
    grid_per_ref = swapped_short;
#else
    grid_per_ref = *view_table_ptr;
#endif
    view_table_ptr += 1;
#ifdef BIG_ENDIAN
    GRconv_short(view_table_ptr,&swapped_short);
    screen1 = swapped_short & 0x00FF;
    screen2 = swapped_short >> 8;
#else
    screen1 = *view_table_ptr & 0x00FF;
    screen2 = *view_table_ptr >> 8;
#endif
    view_table_ptr += 1;

    /*
     *  Use uor's per grid to calculate uor's per
     *  reference, as it is stored per reference in IGE.
     */

    uor_per_grid *= grid_per_ref;

    nbytes_in_buffer = sizeof(ModuleInfo);
    gr$get_module_env ( msg = &msg,
			sizbuf = &nbytes_in_buffer,
			buffer = &ModuleInfo, 
		        nret = &nbytes_transferred );

	/*
	 *  Set window grid on or off.
	 */

#ifdef BIG_ENDIAN
	if ( *view_table_ptr & 0x0002 )
#else
	if ( *view_table_ptr & 0x0200 )
#endif
	{
	    grid_flag = 1;
	    gadget_flags[1] |= GRID_ON;
	}
	else
	{
	    grid_flag = 0;
	}

    /*
     *  10/9/86 In converting to OM 4.0, windows have changed to a
     *  window-gadget form. Now we're going to construct a window
     *  of class IGEwindow, then construct a gadget for the window
     *  that reflects the IGDS view passed in.
     */

    /*
     *  Construct hardware windows.
     */

    for ( j = 0; j <= 4; j += 4 )
    {

	if ( j == 0 )
	{
	    right_left = RIGHT_SCREEN;
	}
	else
	{
	    right_left = LEFT_SCREEN;
	}

    	for ( i = 0; i < 4; i++ )
    	{  
	    k = i+j+1;

	    /*
	     *  Put in default window name.
	     */

	    sprintf ( &(gadget_name[4]) , "%d", k );
	    sprintf ( &(window_name[6]) , "%d", k );

	    /*
	     *  Check to see if a graphic gadget already exists with
	     *	this name, if so, skip this view.
	     */

	    dp$get_gragad_id ( msg = &msg,
			       name = gadget_name,
			       array_size = 0,
			       total_num = &num_gadgets,
			       numberofids = &num_ids,
			       found_GRids = NULL );

	    if ( !num_gadgets )
	    {
	    	GUiget_window_min_max ( &k, &screen1, &screen2, &min_x,
				    	&min_y, &max_x, &max_y );

	    	/*
	    	 *  Construct the window object.
	     	 */

	    	status = ige$construct_win ( msg = &mess,
					     win_class = "GRwindow",
					     win_objid = &(win_ids[i+j]),
					     mod_id = ModuleInfo.md_id.objid,
				             mod_osnum = ModuleInfo.md_id.osnum,
					     name = gadget_name,
				             screen = right_left,
					     dep_indep = IGE_INDEPENDENT,
					     min_x = min_x,
					     min_y = min_y,
					     max_x = max_x,
				             max_y = max_y );

	   	/*
	   	 *  Construct gadget to attach to this window.
	   	 */

	    	status = om$construct ( osnum = ModuleInfo.md_id.osnum,
				    	classname = "IGEgragad",
				    	p_objid = &(gad_ids[i+j]),
				    	msg = message IGEgragad.gragad_cons
						( &mess, gadget_name,
					  	0.0, 0.0, 1.0, 1.0 ) );

	   	/*
	   	 *  Attach the gadget to the window.
	   	 */

	    	status = om$send ( msg = message IGEgadget.add_gadget
						( &mess, &(gad_ids[i+j]), 1 ),
				   senderid = gad_ids[i+j],
				   targetid = win_ids[i+j],
				   targetos = ModuleInfo.md_id.osnum );

	    	/*
	    	 *  Inquire the default window parameters for the 
	    	 *  window just constructed.
	    	 */

	    	window.osnum = ModuleInfo.md_id.osnum;
	    	window.objid = win_ids[i+j];
	    	set0_inq1 = 1;

	   	/*
	    	 *  Get the level info from the IGDS window.
	    	 */

	    	begin_ptr = view_table_ptr + 1;

	    	OM_BLOCK_MOVE ( begin_ptr, level_mask, 8 );

#ifdef BIG_ENDIAN
		GRconv_int(&level_mask[0],&swapped_int);
	    	level_mask[0] = ~swapped_int;
		GRconv_int(&level_mask[1],&swapped_int);
	    	level_mask[1] = ~swapped_int;
#else
		level_mask[0] = ~level_mask[0];
		level_mask[1] = ~level_mask[1];
#endif
	    	msg = dp$levels_on_off ( msg = &mess,
				     	 osnum = ModuleInfo.md_id.osnum,
				     	 levels_mask = level_mask,
				     	 update = FALSE,
				     	 on_off_flag = 0,
				     	 objid = gad_ids[i+j] );

	    	/*
	    	 *  Get view parameters out of IGDS element.
	    	 */

	    	begin_ptr = view_table_ptr + 5;

	    	OM_BLOCK_MOVE( begin_ptr, view_array, 108 );

#ifdef BIG_ENDIAN
		for(GRswap_count=0;GRswap_count < 27;GRswap_count++);
		{
			GRconv_int(&view_array[GRswap_count],&swapped_int);
			view_array[GRswap_count] = swapped_int;
		}
#endif

	    	for ( l = 0; l < 6; l++ )
	    	{
		    GUswapint ( &(view_array[l]), &tempdummy );
                    vw_volume[l] = (IGRdouble) tempdummy;
	    	}

	    	/*
	    	 *  Calculate the view origin.
	    	 */

	    	for ( l = 0; l < 3; l++ )
	    	{
		    origin[l] = vw_volume[l];
	    	}


	    	/*
	    	 *  Kludge to convert 2D VAX views to OSA 3D windows.
	    	 */

	    	if ( *db_type == GU_2I )
	    	{
		    vw_volume[2] = GUMINVV_Z_2D;
		    vw_volume[5] = GUMAXVV_Z_2D;
		    origin[2] = GUMINVV_Z_2D;	/* should = values given 2-d objects */
	    	}

	    	for ( l = 0; l < 3; l++ )
	    	{
		    origin[l] /= *scale_factor;
		    vw_volume[l] = 0.0;
	    	}

	      	for ( l = 3; l < 6; l++ )
	    	{
		    vw_volume[l] /= *scale_factor;
	    	}

	    	/*
	    	 *  Set up view rotation.
	    	 */

	    	GUswapint ( &(view_array[26]), &tempdummy );
                act_z = (IGRdouble) tempdummy;
	    	fltvax_to_flt32 ( 9, &(view_array[6]), scratch );

	    	act_z /= *scale_factor;

	    	if ( *db_type == GU_2I )
	    	{
		    act_z = GUACT_Z_2D;	/* should = values given 2-D objects */
	    	    rotation[0] = scratch[0];
	    	    rotation[1] = scratch[1];
	    	    rotation[2] = 0.0;
	    	    rotation[3] = 0.0;
	    	    rotation[4] = scratch[2];
	    	    rotation[5] = scratch[3];
	    	    rotation[6] = 0.0;
	    	    rotation[7] = 0.0;
	    	    rotation[8] = 0.0;
	    	    rotation[9] = 0.0;
	    	    rotation[10] = 1.0;
	    	    rotation[11] = 0.0;
	    	    rotation[12] = 0.0;
	    	    rotation[13] = 0.0;
	    	    rotation[14] = 0.0;
	    	    rotation[15] = 1.0;
	    	}
	    	else
	    	{
	    	    rotation[0] = scratch[0];
	    	    rotation[1] = scratch[1];
	    	    rotation[2] = scratch[2];
	    	    rotation[3] = 0.0;
	    	    rotation[4] = scratch[3];
	    	    rotation[5] = scratch[4];
	    	    rotation[6] = scratch[5];
	    	    rotation[7] = 0.0;
	    	    rotation[8] = scratch[6];
	    	    rotation[9] = scratch[7];
	    	    rotation[10] = scratch[8];
	    	    rotation[11] = 0.0;
	    	    rotation[12] = 0.0;
	    	    rotation[13] = 0.0;
	    	    rotation[14] = 0.0;
	    	    rotation[15] = 1.0;
	    	}

	    	/*
	     	 *  Set the gadget parameters to resemble the IGDS view
	     	 *  as closely as possible.
	     	 */

	    	gadget.osnum = ModuleInfo.md_id.osnum;
	    	gadget.objid = gad_ids[i+j];
	    	set0_inq1 = 0;

	    	params[0].var			= GRAGAD_FLAGS;
	    	params[0].var_ptr		= (IGRchar *) gadget_flags;
	    	params[0].num_bytes		= sizeof(IGRint) * 2;
	    	params[0].bytes_returned	= &ret_bytes5;

	    	params[1].var			= GRID_PER_REF_X;
	    	params[1].var_ptr		= (IGRchar *) &grid_per_ref;
	    	params[1].num_bytes		= sizeof(IGRlong);
	    	params[1].bytes_returned	= &ret_bytes6;

	    	params[2].var			= GRID_PER_REF_Y;
	    	params[2].var_ptr		= (IGRchar *) &grid_per_ref;
	    	params[2].num_bytes		= sizeof(IGRlong);
	    	params[2].bytes_returned	= &ret_bytes7;

	    	params[3].var			= UOR_PER_REF_X;
	    	params[3].var_ptr		= (IGRchar *) &uor_per_grid;
	    	params[3].num_bytes		= sizeof(IGRdouble);
	    	params[3].bytes_returned	= &ret_bytes8;

	    	params[4].var			= UOR_PER_REF_Y;
	    	params[4].var_ptr		= (IGRchar *) &uor_per_grid;
	    	params[4].num_bytes		= sizeof(IGRdouble);
	    	params[4].bytes_returned	= &ret_bytes9;

	    	params[5].var			= VW_VOLUME;
	    	params[5].var_ptr		= (IGRchar *) vw_volume;
	    	params[5].num_bytes		= sizeof(IGRdouble) * 6;
	    	params[5].bytes_returned	= &ret_bytes1;

	    	params[6].var			= VIEW_ROTATION;
	    	params[6].var_ptr		= (IGRchar *) rotation;
	    	params[6].num_bytes		= sizeof(IGRmatrix);
	    	params[6].bytes_returned	= &ret_bytes3;

	    	params[7].var			= VIEW_ORIGIN;
	    	params[7].var_ptr		= (IGRchar *) origin;
	    	params[7].num_bytes		= sizeof(IGRdouble) * 3;
	    	params[7].bytes_returned	= &ret_bytes4;

	    	params[8].var			= ACT_Z;
	    	params[8].var_ptr		= (IGRchar *) &act_z;
	    	params[8].num_bytes		= sizeof(IGRdouble);
	    	params[8].bytes_returned	= &ret_bytes2;

	    	params[9].var			= END_PARAM;
	    	params[9].var_ptr		= NULL;
	    	params[9].num_bytes		= 0;
	    	params[9].bytes_returned	= NULL;

	    	status = dp$inq_set_gragad ( msg = &msg,
					     inq0_set1 = 1,
					     which_error = &which_error,
					     var_list = params,
					     gragad_objid = gad_ids[i+j],
					     osnum = ModuleInfo.md_id.osnum );

	    	window_flags[0] = WIN_IS_ON;
	    	window_flags[1] = 0;

	    	params[0].var			= WINDOW_FLAGS;
	    	params[0].var_ptr		= (IGRchar *) window_flags;
	    	params[0].num_bytes		= sizeof(IGRint) * 2;
	    	params[0].bytes_returned	= &ret_bytes2;

	    	params[1].var			= END_PARAM;
	    	params[1].var_ptr		= NULL;
	    	params[1].num_bytes		= 0;
	    	params[1].bytes_returned	= NULL;

	    	status = ige$inq_set_window ( msg = &msg,
					      inq0_set1 = 1,
					      which_error = &which_error,
					      var_list = (struct win_var_list *)params,
					      window_objid = win_ids[i+j],
					      osnum = ModuleInfo.md_id.osnum );

	    } /* end if gadget does not exists */


	    /*
	     *  Set pointer to next view in the view table info
	     *  of the type nine.
 	     */

	    view_table_ptr += 59;  

    	}
    }

}

end implementation GRvg;
