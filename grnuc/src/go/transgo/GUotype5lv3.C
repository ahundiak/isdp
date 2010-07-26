/* #######################    APOGEE COMPILED   ######################## */
/* ------------------------------------------------------ 
     This routine converts an IGE saved view into IGDS
   ------------------------------------------------------ */

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



IGRint GUotype5lv3 (msg, file_des, dgn_buf, ele_buf, mod_info, scale_factor)

IGRlong			*msg;
IGRlong			*file_des;
IGRchar			*dgn_buf;
IGRchar			*ele_buf;
struct GRmd_env		*mod_info;
IGRdouble		*scale_factor;

{
   IGRshort		i;
   IGRshort		write_mode = GUWRITE;
   IGRshort		*ele_ptr;
   IGRshort		rad_vw_name[2];
   IGRshort		rad_vw_descript[9];
   IGRshort		dim = 4;
   IGRint		j;
   IGRint		num_chars;
   IGRint		block_ptr;
   IGRint		byte_ptr;
   IGRlong		ret_code;
   IGRlong		status;
   IGRlong		num_views = 0;
   IGRlong 		total_num_views;
   IGRlong		array_size = 30;   /*  10 is changed to 30 tr:90n2395 */
   IGRlong		temp_long;
   IGRlong		ele_type = 5;
   IGRlong		ele_size = 182;
   IGRlong		ret_bytes1;
   IGRlong		ret_bytes2;
   IGRlong		ret_bytes3;
   IGRlong		ret_bytes4;
   IGRlong		ret_bytes5;
   IGRlong		ret_bytes6;
   IGRlong		ret_bytes7;
   IGRlong		ret_bytes8;
   IGRlong		which_error;
   IGRlong		vw_transform[18];
   IGRlong		vw_cnv[2];
   IGRlong		seven = 7;
   IGRlong		gragad_flags[2];
   IGRdouble		act_z;
   IGRdouble		origin[3];
   IGRdouble		new_pts[3];
   IGRdouble		rotation[16];
   IGRdouble		wld_to_view[16];
   IGRdouble		invmx[16];
   IGRdouble		vw_volume[6];
   IGRdouble		my_max = 0.0;
   IGRdouble		chk_array[10];
   IGRdouble		x_uor;
   IGRdouble		y_uor;
   IGRdouble		scale_x;
   IGRdouble		scale_y;
   IGRdouble		extents[3];
   IGRdouble		conversion;
   IGRboolean		chk_status;
   IGRboolean		vw_overflow = FALSE;
   IGRchar		vw_name[2];
   IGRchar		svw_name[32];
   IGRchar		vw_descript[28];
   struct GRid		vw_list[30]; /* 10 is changed to 30 tr:90n2395 mohan */
   struct GRid		gadget_id;
   struct var_list	params[9];
#ifdef BIG_ENDIAN
   IGRshort             GRswap_count,swapped_short;
   IGRint               swapped_int;
#endif

   /* --- Initialise the pointers in the params variable --- */


   params[0].var = GRAGAD_FLAGS;
   params[0].var_ptr = (IGRchar *)gragad_flags;
   params[0].num_bytes = sizeof(IGRlong)*2;
   params[0].bytes_returned = &ret_bytes1;

   params[1].var = VW_VOLUME;
   params[1].var_ptr = (IGRchar *)vw_volume;
   params[1].num_bytes = sizeof(IGRdouble)*6;
   params[1].bytes_returned = &ret_bytes2;

   params[2].var = VIEW_ROTATION;
   params[2].var_ptr = (IGRchar *)rotation;
   params[2].num_bytes = sizeof(IGRmatrix);
   params[2].bytes_returned = &ret_bytes3;

   params[3].var = VIEW_ORIGIN;
   params[3].var_ptr = (IGRchar *)origin;
   params[3].num_bytes = sizeof(IGRdouble)*3;
   params[3].bytes_returned = &ret_bytes4;

   params[4].var = ACT_Z;
   params[4].var_ptr = (IGRchar *)&act_z;
   params[4].num_bytes = sizeof(IGRdouble);
   params[4].bytes_returned = &ret_bytes5;

   params[5].var = GRAGAD_NAME;
   params[5].var_ptr = (IGRchar *)svw_name;
   params[5].num_bytes = sizeof(svw_name);
   params[5].bytes_returned = &ret_bytes6;

   params[6].var = WLD_TO_VIEW;
   params[6].var_ptr = (IGRchar *)wld_to_view;
   params[6].num_bytes = sizeof(IGRmatrix);
   params[6].bytes_returned = &ret_bytes7;

   params[7].var = DESCRIPT;
   params[7].var_ptr = (IGRchar *)vw_descript;
   params[7].num_bytes = sizeof(vw_descript);
   params[7].bytes_returned = &ret_bytes8;

   params[8].var = END_PARAM;

   /* ------ Set the common header info, which is the ------ 
      ------	  same for all IGDS saved views	      ------ */

   GUonvinit (ele_buf);


   /* ------ Obtain the GRids of all the saved views  ------
      ------      defined in the object space         ------ */

   vw_name[0] = '*';
   vw_name[1] = '\0';

   status = dp$get_saved_vw_id (msg = &ret_code,
				name = vw_name,
				array_size = array_size,
				total_num = &total_num_views,
				numberofids = &num_views,
				found_GRids = vw_list,
				osnum = mod_info->md_id.osnum );


   /* ------ For each saved view in IGE, an element ------ 
      ------     is written into the IGDS file      ------ */

   for (i=0; i<num_views; i++)
   {
	ele_ptr = (IGRshort *) ele_buf;

	gadget_id.objid = vw_list[i].objid;
	gadget_id.osnum = mod_info->md_id.osnum;

	status = dp$inq_set_gragad ( msg = msg,
				     inq0_set1 = 0,
				     osnum = gadget_id.osnum,
				     gragad_objid = gadget_id.objid,
				     which_error = &which_error,
				     var_list = params );


	if ( !(status & 1) )
	{
	    goto wrapup;
	}

	/* ------ write the view description ------ */

	ele_ptr += 18;
	for (j = strlen(vw_descript); j < 27; j++ )
	{
	    strcat (vw_descript, " " );
	}
	num_chars = 27;
	GUascii_to_rad50 (&num_chars, vw_descript, rad_vw_descript);
#ifdef BIG_ENDIAN
        for(GRswap_count=0;GRswap_count <=8;GRswap_count++)
	{
	GRconv_short(&rad_vw_descript[GRswap_count],&swapped_short);
	rad_vw_descript[GRswap_count] = swapped_short;
	}
#endif
	memcpy (ele_ptr, rad_vw_descript, 18);
	ele_ptr += 15;
	
	
	/* ------  Apply scale factor and check for ------ 
	   ------        integer overflow 	    ------ */

	for ( j = 0; j < 3; j++ )
	{
	     origin[j] *= *scale_factor;
	     chk_array[j] = origin[j];
	}

	for ( j = 0; j < 6; j++ )
	{
	     vw_volume[j] *= *scale_factor;
	}

	x_uor = 640;
	y_uor = 496;

	scale_x = x_uor / (vw_volume[3] - vw_volume[0]);
	scale_y = y_uor / (vw_volume[4] - vw_volume[1]);

	if ( scale_x < scale_y )
	{
	   conversion = scale_x;
	}
	else
	{
	   conversion = scale_y;
	}

	extents[0] = x_uor / conversion;
	extents[1] = y_uor / conversion;
	extents[2] = vw_volume[5] - vw_volume[2];

	for ( j=0; j<3; j++ )
	{
	    chk_array[j+3] = extents[j];
	}

	act_z *= *scale_factor;
	chk_array[6] = act_z;

	chk_status = GUcheck_overflow ( msg, &seven, chk_array,
					        &my_max );
	if ( !chk_status )
	{
	      vw_overflow = TRUE;
	}
	else
	{
		/* ------ Set up the view origin ------ */
	
		j = 1;
		MAptsxform ( msg, &j, wld_to_view, origin, new_pts ); 
		new_pts[0] += vw_volume[0];
		new_pts[1] += vw_volume[1];
		new_pts[2] += vw_volume[2];
		MAinvmx (msg, &dim, wld_to_view, invmx);
		MAptsxform (msg, &j, invmx, new_pts, new_pts );

		for ( j = 0; j < 3; j++ )
	        {
		     temp_long = GUnint (new_pts[j]);
#ifdef BIG_ENDIAN
		     GRconv_int(&temp_long,&swapped_int); 
		     memcpy ( ele_ptr, &swapped_int, 4 );
#else
		     memcpy ( ele_ptr, &temp_long, 4 );
#endif
		     ele_ptr += 2;
	        }

	        /* ------ Set up the view extents ------ */

                for ( j = 0; j < 3; j++ )
	        {
		    temp_long = GUnint (extents[j]);
#ifdef BIG_ENDIAN
		     GRconv_int(&temp_long,&swapped_int); 
		     memcpy ( ele_ptr, &swapped_int, 4 );
#else
		     memcpy ( ele_ptr, &temp_long, 4 );
#endif
		    ele_ptr += 2;
	        }

	         /* Set up the view transformation matrix */

           	 rotation[3] = rotation[4];
		 rotation[4] = rotation[5];
	         rotation[5] = rotation[6];
	         rotation[6] = rotation[8];
	         rotation[7] = rotation[9];
	         rotation[8] = rotation[10]; 

	         flt32_to_fltvax ( 9, rotation, vw_transform );
#ifdef BIG_ENDIAN
	         for(GRswap_count=0;GRswap_count<= 17;GRswap_count++)
		 {
                     GRconv_int(&vw_transform[GRswap_count],&swapped_int);
                     vw_transform[GRswap_count] = swapped_int;
		 }
#endif
		 memcpy ( ele_ptr, vw_transform, 72 );
	         ele_ptr += 36;

	         /* ---- Set up view conversion factor ---- */

		  flt32_to_fltvax (1, &conversion, &vw_cnv[0] );
#ifdef BIG_ENDIAN
		  GRconv_int(vw_cnv,&swapped_int);
		  vw_cnv[0] = swapped_int;
		  GRconv_int(&vw_cnv[1],&swapped_int);
		  vw_cnv[1] = swapped_int;
#endif
		  memcpy (ele_ptr, vw_cnv, 8);
		  ele_ptr += 4;

	          /* -----  Set up the view active z ----- */
	
	          temp_long = GUnint (act_z);
#ifdef BIG_ENDIAN
		  GRconv_int(&temp_long,&swapped_int); 
		  memcpy ( ele_ptr, &swapped_int, 4 );
#else
		  memcpy ( ele_ptr, &temp_long, 4 );
#endif
	          ele_ptr += 4;
	
	          /* ----- Set up rad50 view name ----- */

	          for (j = strlen(svw_name); j < 6; j++ )
	          {
		      strcat ( svw_name, " " );   /*  pad with blanks  */
	          }
		
	          num_chars = 6;
	          GUascii_to_rad50 ( &num_chars, svw_name, rad_vw_name );
#ifdef BIG_ENDIAN
	          GRconv_short(rad_vw_name,&swapped_short);
		  rad_vw_name[0] = swapped_short;
	          GRconv_short(&rad_vw_name[1],&swapped_short);
		  rad_vw_name[1] = swapped_short;
#endif
		  memcpy ( ele_ptr, rad_vw_name, 4 );
	          ele_ptr += 2;

		  /* ----- Write the named view element out ----- 
		     -----        to the design file 	    ----- */
	
		  status = GUwrite_element ( msg, dgn_buf, ele_buf,
					     &ele_type, &ele_size, file_des,
					     &write_mode, &block_ptr,
					     &byte_ptr );
		}

	}
 
wrapup:
	return ( status );

}



