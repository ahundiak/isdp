/* #######################    APOGEE COMPILED   ######################## */
#include "exsysdep.h"
/*
#include "grimport.h"
*/
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"

IGRint GUonamedvws ( msg, file_des, dgn_buf, ele_buf, mod_info, scale_factor )

IGRlong		*msg;
IGRlong 	*file_des;
IGRchar		*dgn_buf;
IGRchar		*ele_buf;
struct GRmd_env	*mod_info;
IGRdouble 	*scale_factor;

{
    IGRint		iloop;
    IGRint		j;
    IGRint		kloop;
    IGRint		num_chars;
    IGRint		num_windows = 0;
    IGRint		num_gadgets = 0;
    IGRint		wn_list_size = 32;
    IGRint		gad_list_size = 32;
    IGRint		block_ptr;
    IGRint		byte_ptr;
    IGRchar		gragad_nam[32];
    IGRlong		status;
    IGRlong		ele_type = 5;
    IGRlong		ele_size = 182;
    IGRlong		temp_long;
    IGRlong		temp_long2;
    IGRlong		ret_bytes1;
    IGRlong		ret_bytes2;
    IGRlong		ret_bytes3;
    IGRlong		ret_bytes4;
    IGRlong		ret_bytes5;
    IGRlong		ret_bytes6;
    IGRlong		which_error;
    IGRlong		vw_transform[18];
    IGRlong		ten = 10;
    IGRshort		*ele_ptr;
    IGRshort		rad_50[2];
    IGRshort		write_mode = GUWRITE;
    IGRdouble		act_z;
    IGRdouble		origin[3];
    IGRdouble		rotation[16];
    IGRdouble		vw_volume[6];
    IGRdouble		my_max = 0.0;
    IGRdouble		chk_array[10];
    IGRboolean		chk_status;
    IGRboolean		vw_overflow = FALSE;
    IGRlong		gragad_flags[2];
    struct GRid		window_id;
    struct GRid		gadget_id;
    struct var_list	params[7];
    OM_S_CHANSELECT     chan_def;
    OM_S_OBJECT_LINKAGE	wn_list[32];
    OM_S_OBJECT_LINKAGE	gad_list[32];
#ifdef BIG_ENDIAN
    IGRshort  swapped_short,GRswap_count;
    IGRint    swapped_int;
#endif

    /*
     *  Initialize buffer with data which will be common to
     *  all named views created.
     */

    GUonvinit ( ele_buf );

    /* Initialises the pointers in the params variable */

    params[0].var = GRAGAD_FLAGS;
    params[0].var_ptr = (IGRchar *) gragad_flags;
    params[0].num_bytes = sizeof(IGRlong)*2;
    params[0].bytes_returned = &ret_bytes1;

    params[1].var = VW_VOLUME;
    params[1].var_ptr = (IGRchar *) vw_volume;
    params[1].num_bytes = sizeof(IGRdouble)*6;
    params[1].bytes_returned = &ret_bytes2;

    params[2].var = VIEW_ROTATION;
    params[2].var_ptr = (IGRchar *) rotation;
    params[2].num_bytes = sizeof(IGRdouble)*16;
    params[2].bytes_returned = &ret_bytes3;

    params[3].var = VIEW_ORIGIN;
    params[3].var_ptr = (IGRchar *) origin;
    params[3].num_bytes = sizeof(IGRdouble)*3;
    params[3].bytes_returned = &ret_bytes4;

    params[4].var = ACT_Z;
    params[4].var_ptr = (IGRchar *) &act_z;
    params[4].num_bytes = sizeof(IGRdouble);
    params[4].bytes_returned = &ret_bytes5;

    params[5].var = GRAGAD_NAME;
    params[5].var_ptr = (IGRchar *) gragad_nam;
    params[5].num_bytes = sizeof(gragad_nam);
    params[5].bytes_returned = &ret_bytes6;

    params[6].var = END_PARAM;

    /*
     *  Set up information required to get the object
     *	ids of all of the windows.
     */

    chan_def.type = OM_e_name;
    chan_def.u_sel.name = "windows";

    status = om$get_channel_count(osnum = mod_info->md_id.osnum,
                                  objid = mod_info->md_id.objid,
                                  p_chanselect = &chan_def,
                                  count = (OMuint *) &num_windows );

    /*
     *  For each existing window, notify each graphic gadget connected
     *  to it to get the graphic information and use it to construct a
     *  type5, level3, class1 named view element.
     */

	status = om$get_channel_objects(osnum = mod_info->md_id.osnum,
                                        objid = mod_info->md_id.objid,
                                        p_chanselect = &chan_def,
                                        list = wn_list,
                                        size = wn_list_size,
                                        count = (OMuint *) &num_windows);

	for ( iloop = 0; iloop < num_windows; ++iloop )
	{
    	    /*
    	     *  Initialize pointer into the type 5 element.
    	     */

    	    ele_ptr = (IGRshort *) ele_buf;
    	    ele_ptr += 33;

	    /*
	     *  Inquire the window parameters.
	     */

	    window_id.objid = wn_list[iloop].S_objid;
	    window_id.osnum = mod_info->md_id.osnum;
   
	    /*
	     *  Set up information required to get the object
	     *	ids of all of the windows.
	     */

	    chan_def.type = OM_e_name;
	    chan_def.u_sel.name = "to_children";

	    status = om$get_channel_count(osnum = mod_info->md_id.osnum,
	                                  objid = window_id.objid,
	                                  p_chanselect = &chan_def,
 	                                 count = (OMuint *) &num_gadgets );

	    /*
	     *  For each existing gadget, get the gadget information and use
	     *  it to construct a type5, level3, class1 named view element.
	     */

		status = om$get_channel_objects(osnum = mod_info->md_id.osnum,
	                                        objid = window_id.objid,
	                                        p_chanselect = &chan_def,
	                                        list = gad_list,
	                                        size = gad_list_size,
	                                        count = (OMuint *) &num_gadgets);

	    for ( kloop = 0; kloop < num_gadgets; ++kloop )
	    {
	   	gadget_id.objid = gad_list[kloop].S_objid;
		gadget_id.osnum = mod_info->md_id.osnum;

		status = dp$inq_set_gragad ( msg = msg,
					     inq0_set1 = 0,
					     osnum = gadget_id.osnum,
					     gragad_objid = gadget_id.objid,
					     which_error = &which_error,
					     var_list = params );


	  	if ( !(status & 1) )
		{
		    goto wrap_up;
	        }

		/*
		 *  Apply scale factor and check for integer overflow.
   		 */

		for ( j = 0; j < 3; j++ )
		{
		    origin[j] *= *scale_factor;
		    chk_array[j] = origin[j];
		}
		for ( j = 0; j < 6; j++ )
		{
		    vw_volume[j] *= *scale_factor;
		    chk_array[j+3] = vw_volume[j];
		}
		act_z *= *scale_factor;
	  	chk_array[9] = act_z;

		chk_status = GUcheck_overflow ( msg, &ten, chk_array,
					        &my_max );
		if ( !chk_status )
	  	{
		    vw_overflow = TRUE;
		}
		else
		{
		    /* 
   	             *  Set up the view origin.
	             */
	
	            for ( j = 0; j < 3; j++ )
	            {
		   	temp_long = GUnint ( origin[j] );
		    	temp_long2 = GUnint ( vw_volume[j] );
		    	temp_long += temp_long2;
#ifdef BIG_ENDIAN
			GRconv_int(&temp_long,&swapped_int);
		    	memcpy ( ele_ptr, &swapped_int, 4 );
#else
		    	memcpy ( ele_ptr, &temp_long, 4 );
#endif
		    	ele_ptr += 2;
	            }

	            /*
	             *  Set up the view extents.
	             */

                    for ( j = 3; j < 6; j++ )
	            {
		    	temp_long = GUnint ( vw_volume[j] );
		    	temp_long2 = GUnint ( vw_volume[j-3] );
		    	temp_long -= temp_long2;
#ifdef BIG_ENDIAN
			GRconv_int(&temp_long,&swapped_int);
		    	memcpy ( ele_ptr, &swapped_int, 4 );
#else
		    	memcpy ( ele_ptr, &temp_long, 4 );
#endif
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

	            flt32_to_fltvax ( 9, rotation, vw_transform );
#ifdef BIG_ENDIAN
		    for(GRswap_count=0;GRswap_count <=17;GRswap_count++)
		    {
		    GRconv_int(&vw_transform[GRswap_count],&swapped_int);
		    vw_transform[GRswap_count] = swapped_int;
		    }
#endif
	            memcpy ( ele_ptr, vw_transform, 72 );
	            ele_ptr += 36;

	            /*
	             *  Set up view conversion factor.
	             */

#ifdef BIG_ENDIAN
	            *ele_ptr++ = 0xf03c;
	            *ele_ptr++ = 0xbbc8;
		    *ele_ptr++ = 0xc1fd;
	            *ele_ptr++ = 0x9939;
#else
	            *ele_ptr++ = 0x3cf0;
	            *ele_ptr++ = 0xc8bb;
		    *ele_ptr++ = 0xfdc1;
	            *ele_ptr++ = 0x3999;
#endif
		    /*
	             *  Set up the view active z.
	             */
	
	            temp_long = GUnint ( act_z );
#ifdef BIG_ENDIAN
		    GRconv_int(&temp_long,&swapped_int);
	            memcpy ( ele_ptr, &swapped_int, 4 );
#else
	            memcpy ( ele_ptr, &temp_long, 4 );
#endif
	            ele_ptr += 4;
	
	            /*
	             *  Set up rad50 view name.
	             */

	            for ( num_chars = strlen(gragad_nam); num_chars < 6;
						          num_chars++ )
	            {
		    	strcat ( gragad_nam, " " );   /*  pad with blanks  */
	            }
		
	            num_chars = 6;
	            GUascii_to_rad50 ( &num_chars, gragad_nam, rad_50 );
#ifdef BIG_ENDIAN
		    GRconv_short(&rad_50[0],&swapped_short);
		    rad_50[0] = swapped_short;
		    GRconv_short(&rad_50[1],&swapped_short);
		    rad_50[1] = swapped_short;
#endif
	            memcpy ( ele_ptr, rad_50, 4 );
	            ele_ptr += 2;

	            /*
		     *  Write the named view element out to the design file.
	             */
	
		    status = GUwrite_element ( msg, dgn_buf, ele_buf,
					       &ele_type, &ele_size, file_des,
					       &write_mode, &block_ptr,
					       &byte_ptr );
	   	}

	    }
        }

    wrap_up:
	return ( status );

}
