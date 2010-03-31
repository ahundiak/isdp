#include "stdio.h"
#include "wl.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igecolor.h"

OM_S_OBJID 	NULL_OBJID = 0;
short *IGErgb_table = NULL;
extern int	IGEnum_shds;
char DPdlist_feedback_in_progress = 0;

/*---HSlogical_color_to_physical_slot------------------------------*/

void	HSlogical_color_to_physical_slot()
	{
	fprintf( stderr, "STUB: HSlogical_color_to_physical_slot\n" );
	}


/*---DLget_GPIPE_data------------------------------*/

void	DLget_GPIPE_data()
	{
	fprintf( stderr, "STUB: DLget_GPIPE_data\n" );
	}

/*---DLget_EG_data------------------------------*/

void	DLget_EG_data()
	{
	fprintf( stderr, "STUB: DLget_EG_data\n" );
	}

IGRint IGEload_context( WLuint32 context_no, struct IGEcontext_info  *context_info )

	{
	context_no = 0;	
	context_info->cube_size = IGEnum_shds;
	return(0);
	}

static int	pe = 1;
/*---IGEcmap_color_to_index------------------------------*/

IGRint IGEcmap_color_to_index (WLuint32 context_no, 
                               WLuint32 index, 
                               WLuint32 red, 
                               WLuint32 green, 
                               WLuint32 blue, 
                               WLuint32 flag, 
                               WLuint32 *phy_index)

	{
	/*fprintf( stderr, "STUB: IGEcmap_color_to_index\n" );*/

	context_no =
	index = 
	red = 
	green =
	blue =
	flag = 
	*phy_index = 0;

*phy_index = pe++;
	return(0);
	}


/*---IGEcmap_color_to_rgb------------------------------*/

IGRint IGEcmap_color_to_rgb (WLuint32 context_no, WLuint32 index, WLuint32 red, WLuint32 green, WLuint32 blue, WLuint32 flag, WLuint32 *out_red, WLuint32 *out_green, WLuint32 *out_blue)

	{
	fprintf( stderr, "STUB: IGEcmap_color_to_rgb\n" );

	context_no =
	index =
	red =
	green =
	blue =
	flag =
	*out_red =
	*out_green =
	*out_blue = 0;

	return(0);
	}


/*---IGEcmap_init------------------------------*/

IGRint	IGEcmap_init(WLuint32 context_no)
	{
	struct WLcontext_info	context_info;
	
	WLget_context_info( context_no, &context_info );
	HRinit_rgb( context_info.base_depth );

	return(0);
	}


/*---IGErgb_to_index------------------------------*/

IGRint	IGErgb_to_index (WLuint32 context_no, IGRint x, IGRint y, IGRint red, IGRint grn, IGRint blu)

	{
	fprintf( stderr, "STUB: IGErgb_to_index\n" );
	context_no = x= y= red= grn= blu= 0;
	return(0);
	}


/*---IGEindex_to_rgb------------------------------*/

void IGEindex_to_rgb (WLuint32 context_no, IGRint flag, IGRint index, IGRint *out_red, IGRint *out_green, IGRint *out_blue)

	{
	fprintf( stderr, "STUB: IGEindex_to_rgb\n" );

	context_no =
	flag =
	index =
	*out_red =
	*out_green =
	*out_blue = 0;
	}


/*---IGEgetabsclrindx------------------------------*/

IGRint	IGEgetabsclrindx( int context, int log_color, int *abs_color )
	{
	*abs_color = log_color;
	return(0);
	}


/*---HSconvert_to_indexed_context------------------------------*/

void	HSconvert_to_indexed_context()
	{
	fprintf( stderr, "STUB: HSconvert_to_indexed_context\n" );
	}


/*---HSrestore_window_context------------------------------*/

void	HSrestore_window_context()
	{
	fprintf( stderr, "STUB: HSrestore_window_context\n" );
	}


/*---HSsetup_fem_simulated_ramp------------------------------*/

void	HSsetup_fem_simulated_ramp()
	{
	fprintf( stderr, "STUB: HSsetup_fem_simulated_ramp\n" );
	}

DPinq_buf_ptrs()
	{
	fprintf( stderr, "STUB: DPinq_buf_ptrs\n" );
	}

MSmessage()
	{
	fprintf( stderr, "STUB: MSmessage\n" );
	}

MS_init()
	{
	fprintf( stderr, "STUB: MS_init\n" );
	}

MS_fix_type()
	{
	fprintf( stderr, "STUB: MS_fix_type\n" );
	}

MS_out_msg()
	{
	fprintf( stderr, "STUB: MS_out_msg\n" );
	}

MS_onoff()
	{
	fprintf( stderr, "STUB: MS_onoff\n" );
	}

UI_prompt()
	{
	fprintf( stderr, "STUB: UI_prompt\n" );
	}

UI_status()
	{
	fprintf( stderr, "STUB: UI_status\n" );
	}

IGEgetrgbvalue()
	{
	fprintf( stderr, "STUB: IGEgetrgbvalue\n" );
	}

NCsave_trap()
	{
	fprintf( stderr, "STUB: NCsave_trap\n" );
	}

NCsetup_shading_window()
	{
	fprintf( stderr, "STUB: NCsetup_shading_window\n" );
	}

HSget_table_display_mode()
	{
	fprintf( stderr, "STUB: HSget_table_display_mode\n" );
	}

HSget_symbology_modes()
	{
	fprintf( stderr, "STUB: HSget_symbology_modes\n" );
	}

HSget_active_shading_symb()
	{
	fprintf( stderr, "STUB: HSget_active_shading_symb\n" );
	}

HSget_element_shading_symb()
	{
	fprintf( stderr, "STUB: HSget_element_shading_symb\n" );
	}

HSget_top_range()
	{
	fprintf( stderr, "STUB: HSget_top_range\n" );
	}

HSget_global_lights()
	{
	fprintf( stderr, "STUB: HSget_global_lights\n" );
	}

HSdpb_get_shading_tolerance()
	{
	fprintf( stderr, "STUB: HSdpb_get_shading_tolerance\n" );
	}

GRsetinqcolcal()
	{
	fprintf( stderr, "STUB: GRsetinqcolcal\n" );
	}
	
HScolor_compensate()
	{
	fprintf( stderr, "STUB: HScolor_compensate\n" );
	}


IGEinq_term_info()
	{
	fprintf( stderr, "STUB: IGEinq_term_info\n" );
	}

IGEreadresclr()
	{
	fprintf( stderr, "STUB: IGEreadresclr\n" );
	}

HRinit_pool_memory_management()
	{
	fprintf( stderr, "STUB: HRinit_pool_memory_management\n" );
	}

HRinit_rle()
	{
	fprintf( stderr, "STUB: HRinit_rle\n" );
	}

HRactivate_trapezoids()
	{
	fprintf( stderr, "STUB: HRactivate_trapezoids\n" );
	}

HRprocess_scanline()
	{
	fprintf( stderr, "STUB: HRprocess_scanline\n" );
	}

HRfini_rle()
	{
	fprintf( stderr, "STUB: HRfini_rle\n" );
	}

HRinit_display_parms()
	{
	fprintf( stderr, "STUB: HRinit_display_parms\n" );
	}

CLAA_get_answer_ptrs()
	{
	fprintf( stderr, "STUB: CLAA_get_answer_ptrs\n" );
	}

CLAA_answer_complete()
	{
	fprintf( stderr, "STUB: CLAA_answer_complete\n" );
	}

AA_need_to_flush_answers()
	{
	fprintf( stderr, "STUB: AA_need_to_flush_answers\n" );
	}

AA_config_path()
	{
	/* fprintf( stderr, "STUB: AA_config_path\n" ); */
	}

AA_print_statistics()
	{
	fprintf( stderr, "STUB: AA_print_statistics\n" );
	}

AA_really_busy()
	{
	fprintf( stderr, "STUB: AA_really_busy\n" );
	}

int AA_allocate()
	{
	return( 0 );
	}

CLAA_get_request_ptrs()
	{
	fprintf( stderr, "STUB: CLAA_get_request_ptrs\n" );
	}

CLAA_request_complete()
	{
	fprintf( stderr, "STUB: CLAA_request_complete\n" );
	}


HSupdate_heartbeat()
	{
	fprintf( stderr, "STUB: HSupdate_heartbeat\n" );
	}

HSdisplay_memory_realloc_message()
	{
	fprintf( stderr, "STUB: HSdisplay_memory_realloc_message\n" );
	}

HSerase_memory_realloc_message()
	{
	fprintf( stderr, "STUB: HSerase_memory_realloc_message\n" );
	}

HRset_rendering_lights()
	{
	fprintf( stderr, "STUB: HRset_rendering_lights\n" );
	}

DPinq_style()
	{
	fprintf( stderr, "STUB: DPinq_style\n" );
	}

DPget_frame_block()
	{
	fprintf( stderr, "STUB: DPget_frame_block\n" );
	}

IGEstop()
	{
	fprintf( stderr, "STUB: IGEstop\n" );
	}

IGEresetstop()
	{
	fprintf( stderr, "STUB: IGEresetstop\n" );
	}

HSget_color_table_info()
	{
	fprintf( stderr, "STUB: HSget_color_table_info\n" );
	}

HScheck_status()
	{
	fprintf( stderr, "STUB: HScheck_status\n" );
	}

HRalloc_span_trap()
	{
	fprintf( stderr, "STUB: HRalloc_span_trap\n" );
	}

HRalloc_trapezoid_uv()
	{
	fprintf( stderr, "STUB: HRalloc_trapezoid_uv\n" );
	}

HRbucket_sort_trapezoid()
	{
	fprintf( stderr, "STUB: HRbucket_sort_trapezoid\n" );
	}

HSassign_edgeII_vlt_to_window()
	{
	fprintf( stderr, "STUB: HSassign_edgeII_vlt_to_window\n" );
	}

HSclear_window()
	{
	fprintf( stderr, "STUB: HSclear_window\n" );
	}

int HSget_vm_stats( unsigned long *total_virtual_mem,
			    unsigned long *used_virtual_mem,
			    unsigned long *physical_mem )
{

	if( total_virtual_mem )
	{
		*total_virtual_mem = 99999999;
	}
	if( used_virtual_mem )
	{
		*used_virtual_mem = 0;
	}
	if( physical_mem )
	{
		*physical_mem = 16000000; /* 16 megabytes */
	}

return(1);
} /* HSget_vm_stats */

void HSlvhl_create_curve()
{
	fprintf( stderr, "STUB: HSlvhl_create_curve\n" );
} /* HSlvhl_create_curve */


/*
 * HSget_hilite() returns the index of the hilight plane.
 *
 * HISTORY: 12/04/91	Created.
 *								Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
void HSget_hilite( int *hilite )
#else
void HSget_hilite( hilite )
	int *hilite;
#endif

{
	*hilite = 0xff;
} /* HSget_hilite */

void DPhidecursor( int win )
{
WLhide_cursor( win, 0 );
}
void DPshowcursor( int win )
{
WLshow_cursor( win );
}
void DPsync( int win )
{
WLflush( win );
}
void DPset_foreground_color()
{
fprintf( stderr, "STUB: DPset_foreground_color\n" );
}
void HSforce_hardware_mode()
{
fprintf( stderr, "STUB: HSforce_hardware_mode\n" );
}

