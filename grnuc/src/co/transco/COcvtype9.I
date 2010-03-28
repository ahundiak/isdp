/* #######################    APOGEE COMPILED   ######################## */
class implementation COcvigdsige;

#include "exsysdep.h"
#include "coimport.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "transdef.h"
#include "msdef.h"

/*
 *  This function will get the active design
 *  parameters from the IGDS type 9 element
 *  and place them in the DPB.
 */

method cvt_type9 (IGRlong *msg; struct GRid *object_info)

{
    IGRshort			*ele_ptr;
    IGRshort			*igds_symb_ptr;
    IGRshort			i;
    struct GRdpb_scale 		act_scales;
    struct IGRdisplay 		display;
    IGRulong 			musupu[3];
    IGRchar			mu_name[3];
    IGRchar			su_name[3];
    IGRdouble			uom_factor;
    IGRshort			level;
    IGRlong			status;
    IGRlong			nbytes_in_buffer;
    IGRlong			nbytes_transferred;
    IGRboolean			level_symb = FALSE;
#ifdef BIG_ENDIAN
    IGRint			swapped_int;
    IGRshort			GRswap_count;
    IGRshort			swapped_short;
    IGRint			*int_ptr;
#endif

    status = TRUE;

    ele_ptr = (IGRshort *) me->cvt_bufs.ele_buf;
#ifdef BIG_ENDIAN
    int_ptr = (IGRint *) me->cvt_bufs.ele_buf;
#endif

    /*
     *  Set the design file type.
     */

#ifdef BIG_ENDIAN
    GRconv_short(ele_ptr,&swapped_short);
    if ( ((swapped_short & 0x00c0) >> 7) == 1)
#else
    if ( ((*ele_ptr & 0x00c0) >> 7) == 1)
#endif
    {
	me->IGDS_file_type = GU_3D;

	/*
	 *  ------  ATTENTION ------
	 *  will need to add capability for 3I
	 */
    }
    else
    {
	me->IGDS_file_type = GU_2I;
    }

    me->object_type = GU_3D;

    /*
     *  Get current symbology from DPB.
     */

    nbytes_in_buffer = sizeof(act_scales);

    gr$get_active_scale ( msg = msg,
		          sizbuf = &nbytes_in_buffer,
		          buffer = &act_scales,
		          nret = &nbytes_transferred );

    igds_symb_ptr = ele_ptr + 554;

    /*
     *	Pull the MU:SU:PU definition from the type 9.
     */

    OM_BLOCK_MOVE( igds_symb_ptr, musupu, 12);

    igds_symb_ptr += 6;

    OM_BLOCK_MOVE( igds_symb_ptr, mu_name, 2);

    igds_symb_ptr += 1;

    OM_BLOCK_MOVE(igds_symb_ptr, su_name, 2);

    igds_symb_ptr += 9;

    if  (mu_name[1] == ' ')
    {
	mu_name[1] = '\0';
    }

    mu_name[2] = '\0';
    su_name[2] = '\0';
#ifdef BIG_ENDIAN
    GRconv_int(&musupu[0],&swapped_int);
    GUswapint ( &swapped_int, &musupu[0] );
    GRconv_int(&musupu[1],&swapped_int);
    GUswapint ( &swapped_int, &musupu[1] );
    GRconv_int(&musupu[2],&swapped_int);
    GUswapint ( &swapped_int, &musupu[2] );
#else
    GUswapint ( &musupu[0], &musupu[0] );
    GUswapint ( &musupu[1], &musupu[1] );
    GUswapint ( &musupu[2], &musupu[2] );
#endif


    me->scale_factor = (musupu[1] * musupu[2]);

    status = co$cvt_exp_to_wrk ( msg = msg,
				 osnum = object_info->osnum,
				 unit_type = "UOM_DISTANCE",
				 units = 1.0,
				 alias = mu_name,
				 result = &uom_factor );

    /*
     * TR 91n2419.   dhm    02/18/92.
     * mu_name is coming in as MU (most of the time) which the UOM system
     * doesn't reckonize as a valid alias. Therefore, set the status return
     * code back to success and keep processing with the current scale
     * factor.
     */

    if ( (*msg)&status&1 )
    {
      me->scale_factor /= uom_factor;
    }
    else
      status = 1;

    /*
     *  Pull the symbology out of the IGDS type nine.
     */
/*
#ifdef BIG_ENDIAN
     int_ptr += 285;
     for(GRswap_count=0;GRswap_count < 6;GRswap_count++)
     {
	GRconv_int(int_ptr+GRswap_count,&swapped_int);
	*(int_ptr+GRswap_count) = swapped_int;
     }
#endif
*/
    fltvax_to_flt32 ( 1, igds_symb_ptr, &act_scales.Active_xscale );
    igds_symb_ptr += 4;
    fltvax_to_flt32 ( 1, igds_symb_ptr, &act_scales.Active_yscale );
    igds_symb_ptr += 4;
    fltvax_to_flt32 ( 1, igds_symb_ptr, &act_scales.Active_zscale );
    igds_symb_ptr += 25;
    level = *((IGRchar *)igds_symb_ptr);
    igds_symb_ptr += 3;
#ifdef BIG_ENDIAN
    GRconv_short(igds_symb_ptr,&swapped_short);
    display.color = ( (swapped_short & 0xFF00) >> 8 ) + 1;
    display.weight = ( (swapped_short & 0x00F8) >> 3 );
    display.style = swapped_short & 0x0007;
#else
    display.color = ( (*igds_symb_ptr & 0xFF00) >> 8 ) + 1;
    display.weight = ( (*igds_symb_ptr & 0x00F8) >> 3 );
    display.style = *igds_symb_ptr & 0x0007;
#endif

    /*
     *  Put the new symbology into the DPB.
     */

    nbytes_in_buffer = sizeof(act_scales);
    gr$put_active_scale ( msg = msg, 
   	           sizbuf = &nbytes_in_buffer,
		   buffer = &act_scales );

    nbytes_in_buffer = sizeof(display);
    gr$put_active_display ( msg = msg, sizbuf = &nbytes_in_buffer,
			     buffer = &display );

    nbytes_in_buffer = 2;
    gr$put_active_level ( msg = msg, sizbuf = &nbytes_in_buffer,
			   buffer = &level );

    /*
     *  Create the views as they were set up in the
     *  VAX design file.
     */

    GUcreate_views ( me->cvt_bufs.ele_buf, &me->IGDS_file_type, 
		     &me->scale_factor );

    /*  Check if the level symbology flag is active  */

    ele_ptr = (IGRshort *) me->cvt_bufs.ele_buf;
    ele_ptr += 23;
    for ( i=0; i<8; i++)
    {
#ifdef BIG_ENDIAN
    level_symb = *ele_ptr & 0x0004;
#else
    level_symb = *ele_ptr & 0x0400;
#endif
	if ( level_symb )
        {
	   *msg = GULEVEL_SYMB_ON ;
	   break;
	}
	ele_ptr += 59;
    }

   return ( status );
}
end implementation COcvigdsige;


