
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/

class		HSplotform
super_class	HSwindow
command_object	HSM_M_CreateShadedPlotFile, HSplot_CREATE_FORM, HSCShPlFl
product_name	"$MODEL"

/* do not display the CREATE FORM automatically. fixes TR# 119304360 */
form		"HSCrShPlFl", HSplot_CREATE_FORM, 0, 0, 0
form		"HSSbShPlFl", HSplot_SUBMIT_FORM, 0, 0, 0
form		"PlotQStat",  HSplot_STATUS_FORM, 0, 0, 0
form		"HSSbShPlOp", HSplot_OPTION_FORM, 0, 0, 0
start_state	wait_for_input

specification

#include "FI.h"
#include "HSplot.h"
#include "HSplot_def.h"

instance
	{
	struct HSplot_info	info;
	}

implementation

#define HP_FILE_OPEN_ERROR	-1
#define HP_NORMAL		0

#define ACCESS_MODE		0777

#include <stdio.h>
#include <string.h>

#include "wl.h"
#include <FI.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/utsname.h>

#include "OMminimum.h"
#include "igrtypedef.h"

#include "OMerrordef.h"
#include "msdef.h"

#include "igewindow.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igr.h"

#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"

#include "msdef.h"
#include "msmacros.h"

#include "griodef.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "exdef.h"
#include "ex.h"
#include "comiscmac.h"

#include "exmacros.h"

#include "pidef.h"
#include "plotmacros.h"

#include "hsurferrpriv.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmsg.h"
#include "hsmacdef.h"
#include "hsmacros.h"

#include "HSplot_label.h"

/*------------------------------
 *  for functions
 *     HPcollect_element_to_plot
 *     HPcreate_form_notify
 *     HPdisplay_create_form
 *     HPdisplay_option_form
 *     HPdisplay_queue_form
 *     HPdisplay_submit_form
 *     HPfiledef
 *     HPgenerate_unique_name
 *     HPoption_form_notify
 *     HPstatus_form_notify
 *     HPsubmit_form_notify
 *     HPwrite_header
 */
 
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "HSpr_hplot.h"

/*-----------------------------*/


state_table

#include "HSplot_def.h"
#include "hsmsg.h"

#define HP_FILE_OPEN_ERROR	-1

at init		do HSplot_init()
at wakeup	do HSplot_wakeup()
at sleep	do HSplot_sleep()
at delete	do HSplot_delete()

/*---wait_for_input---(state)------------------------------------------*/

state wait_for_input
	message_key HSM_M_CreateShadedPlotFile
	mask "GRm_DATA | GRm_STRING | GRm_TEXT_VALUE | GRm_FORM_FINISHED | GRm_MOVE_ON | GRm_RJT_MOVEON"
	filter get_event
	prompt " "
	
	on EX_FORM_FINISHED
		do which_state
			on RETURN_CODE = EXIT_COMMAND 
				state terminate
				
			on RETURN_CODE = EXECUTE_COMMAND
				do pre_get_ele
				state get_elements
		state .

	on EX_DATA or EX_STRING
		do get_selected_window( sts, 1, 1, 0, 0 )
			on SUCCESS
				do get_window_info
				state .
				
		state.
	
/*---which_state---(action)-------------------------------------------------*/

action	which_state

	{
	*sts = me->info.switch1;
	}

/*---get_elements---(status)----------------------------------------------------*/

state get_elements
	prompt	"select element"
	locate_display           "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
	locate_properties        "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	locate_owner             "LC_RIGID_OWNER | LC_RIGID_COMP | LC_FLEX_COMP | LC_REF_OBJECTS"
	gslocate_num_inputs      0
	locate_class             "GRgraphics"
	unhilight_mode		 "GRhe"
	filter                   gs_locate_noauto

	on EX_DATA or EX_OBJID
		do make_plotfile
		state -

/*---get_window_info-------------------------------------------------------*/

action get_window_info

	{
	struct var_list		var_list[2];
	IGRlong			bytes_returned;
	IGRlong			which_error;
	IGRchar			gragad_name[GRNAME_SIZE];
	struct GRevent		window_event;
	IGRlong			msg, sts;
	

	var_list[0].var            = GRAGAD_NAME;
	var_list[0].var_ptr        = gragad_name;
	var_list[0].num_bytes      = sizeof( gragad_name );
	var_list[0].bytes_returned = &bytes_returned;
	
	var_list[1].var            = END_PARAM;

	dp$inq_set_gragad( msg = &msg,
		     inq0_set1 = 0,
		         osnum = me->win_ids[0].osnum,
		  gragad_objid = me->win_ids[0].objid,
		   which_error = &which_error,
		      var_list = var_list );

	memcpy( me->info.window_name, gragad_name, strlen( gragad_name )+1 );
	window_event.response = EX_DATA;
	window_event.event.button.objid = me->win_ids[0].objid;
	window_event.event.button.osnum = me->win_ids[0].osnum;
	
	sts = plot$get_window_range(
			msg = &msg,
		      event = &window_event,
		     window = &me->info.window,
		      world = &me->info.range[0],
		       view = &me->info.range[6] );

	me->info.con_flags |= HP_CONTROL_WINDOW_DEFINED;
	
	FIfld_set_text( me->info.displayed_form, CP_STATUS_FIELD, 0, 0, "", 0 );
	}

/*---pre_get_ele-----------------------------------------------------------*/

action pre_get_ele
	{
	IGRlong		msg;
	IGRlong		size;
	int		response;
	
	size = strlen( me->info.window_name ) + 1;
	response = EX_STRING;
		
	status = ex$putque(  msg = &msg,
			response = &response,
			    byte = &size,
			  buffer = (IGRchar *)me->info.window_name );
			  
	size = strlen( me->info.command ) + 1;
	response = EX_CMD_KEY;
	
	status = ex$putque(  msg = &msg,
			response = &response,
			    byte = &size,
			    mode = EX_HELP_QUIET | EX_MSG_QUIET,
			  buffer = me->info.command );
	}
	
/*---HSplot_init---(action)----------------------------------------------*/

/*
 *  Initialize the HSplot command information
 */
 
action HSplot_init()

	{
	struct utsname	node;
	IGRchar		stuff[80];
	IGRint		sizbuf, nret;
	IGRlong		msg;
	extern char	*getenv();
	char		*expr;
	IGRint		use_default_file;

	/*
	 *  Get the form pointer for the four forms 
	 */

	me->info.create_form = me->forms[0].form_ptr;
	me->info.submit_form = me->forms[1].form_ptr;
	me->info.status_form = me->forms[2].form_ptr;
	me->info.option_form = me->forms[3].form_ptr;

	/*
	 *  Set the Create Shaded Plot File as the default form
	 */
	 	
	me->info.displayed_form    = me->info.create_form;
	me->info.displayed_form_no = HSplot_CREATE_FORM;
	
	me->info.queue[0] = NULL;
	me->info.date[0] = NULL;
	me->info.nodename[0] = NULL;
	me->info.copies = 1;
	
	me->info.plotter_max[0] = 0.0;
	me->info.plotter_max[1] = 0.0;
	
	me->info.size_x = me->info.size_y = 0.0;
	me->info.units = UNIT_INCHES;
	me->info.scale = 1.0;
	
	me->info.job_to_can[0] = 0;
	me->info.last_job_queue[0] = NULL;
	me->info.last_job_id[0] = NULL;
	me->info.last_job_name[0] = NULL;
	
	me->info.line_width_const = 0.01;
	me->info.max_line_width = 16;
	me->info.raster_type = 25;

	use_default_file = 0;
	expr = getenv( "HSplot_use_default_file" );
	if ( expr )
		sscanf( expr, "%d", &use_default_file );
		
	if( use_default_file )
		me->info.con_flags = HP_CONTROL_SUBMIT_PLOTFILE;
	else
		me->info.con_flags = HP_CONTROL_SUBMIT_PLOTFILE | HP_CONTROL_USE_DPB_DEFAULTS;

	if( me->info.con_flags & HP_CONTROL_USE_DPB_DEFAULTS )
		{
			
		/*
		 *  Get the Create Shaded Plot File command default values from
		 *  the design file dpb data
		 */
		 
		hs$get_hplot_info(   hplot_flags = &me->info.dpb_flags,
				       plot_file =  me->info.plotfile,
				     raster_file =  me->info.rasterfile,
				       text_file =  me->info.textfile,
				      plot_queue =  me->info.queue,
				     plot_x_size = &me->info.size_x,
				     plot_y_size = &me->info.size_y,
				    /*plot_scale = &me->info.scale,*/
				      num_copies = &me->info.copies,
					    date =  me->info.date,
				line_width_const = &me->info.line_width_const,
				  max_line_width = &me->info.max_line_width,
				     raster_type = &me->info.raster_type );
		}
	else
		{
			
		/*
		 *  Get the Create Shaded Plot File command default values from
		 *  the HSplot.def file in grnuc/userdata
		 */
		 
		status = (int)HPfiledef( 
				TRUE, 
				me->info.plotfile, 
				me->info.rasterfile, 
				me->info.textfile, 
				me->info.queue,
				me->info.date,
				&me->info.size_x,
				&me->info.size_y,
				NULL, /* &me->info.scale, */
				&me->info.copies,
				&me->info.line_width_const,
				&me->info.max_line_width,
				&me->info.raster_type,
				(IGRint *)&me->info.dpb_flags );
		}

	if( me->info.dpb_flags & HS_PLOT_CREATE_TEXTFILE )
		me->info.con_flags |= HP_CONTROL_SUBMIT_TEXTFILE;
		
	/* 
	 *  Build default filenames for those that didn't
	 *  have one saved
	 */
	 
	uname( &node );
	HPgenerate_unique_name( node.nodename, stuff );
	
	if( me->info.plotfile[0] == 0 )
		sprintf( me->info.plotfile, "%s.pfl", stuff );

	if( me->info.textfile[0] == 0 )
		sprintf( me->info.textfile, "/usr/tmp/%s.txt", stuff );
		
	sprintf( me->info.unique_textfile, "/usr/tmp/%s.txt", stuff );

	me->info.last_checked_plotfile[0] = 0;
	me->info.last_checked_textfile[0] = 0;

	if( me->info.rasterfile[0] == 0 )
		sprintf( me->info.rasterfile, "/usr/tmp/%s.rgb", stuff );
		
	/* 
	 *  Get the module information
	 */

	sizbuf = sizeof( struct GRmd_env );
	gr$get_module_env(
		msg = &msg,
	     sizbuf = &sizbuf,
	     buffer = &me->info.module,
	       nret = &nret );

	me->info.con_flags |= HP_CONTROL_CREATE_FORM_DISPLAYED;
	}

/*---HSplot_wakeup---(action)--------------------------------------------------*/

action HSplot_wakeup()
	{

	/*
	 *  Initialize and display the default form.
	 */
	 
        if( me->info.con_flags & HP_CONTROL_CREATE_FORM_DISPLAYED )
	   HPdisplay_create_form( &me->info );
			
        if( me->info.con_flags & HP_CONTROL_CREATE_FORM_DISABLED )
           {
	   HPdisplay_create_form( &me->info );
           FIg_disable( me->info.create_form, FI_FORM_GROUP );
	   }
			
        if( me->info.con_flags & HP_CONTROL_SUBMIT_FORM_DISPLAYED )
	   HPdisplay_submit_form( &me->info );
			
        if( me->info.con_flags & HP_CONTROL_STATUS_FORM_DISPLAYED )
	   HPdisplay_queue_form( &me->info );
			
        if( me->info.con_flags & HP_CONTROL_OPTION_FORM_DISPLAYED )
	   HPdisplay_option_form( &me->info );
	}

/*---HSplot_sleep---(action)---------------------------------------------------*/

action HSplot_sleep()
	{
        if( me->info.con_flags & HP_CONTROL_OPTION_FORM_DISPLAYED )
           FIf_erase( me->info.option_form );
           
        if( me->info.con_flags & HP_CONTROL_STATUS_FORM_DISPLAYED )
           FIf_erase( me->info.status_form );
           
        if( me->info.con_flags & HP_CONTROL_SUBMIT_FORM_DISPLAYED )
           FIf_erase( me->info.submit_form );
           
        if( me->info.con_flags & HP_CONTROL_CREATE_FORM_DISPLAYED )
           FIf_erase( me->info.create_form );
           
        if( me->info.con_flags & HP_CONTROL_CREATE_FORM_DISABLED )
           FIf_erase( me->info.create_form );
           
	}

/*---HSplot_delete---(action)-----------------------------------------------*/

action HSplot_delete
	{
	}
	
/*---form_notification---(action)-----------------------------------------------*/

action form_notification

	{	
#	ifdef CLIX 
		struct statl	stbuf;
#	else
		struct stat	stbuf;
#	endif

	me->info.con_flags &= ~ HP_CONTROL_EXIT;
	
	switch( form_label )
		{
		case HSplot_CREATE_FORM:
			HPcreate_form_notify( gadget_label, &me->info );
			me->ret = TRUE;
			break;

		case HSplot_SUBMIT_FORM:
			HPsubmit_form_notify( gadget_label, &me->info );
			me->ret = TRUE;
			break;
	
		case HSplot_STATUS_FORM:
			HPstatus_form_notify( gadget_label, &me->info );
			me->ret = TRUE;
			break;

		case HSplot_OPTION_FORM:
			HPoption_form_notify( gadget_label, &me->info );
			me->ret = TRUE;
			break;

		default:
			me->ret = FALSE;
		}

	if( me->info.con_flags & HP_CONTROL_EXIT ) 
		{
		_put_response( resp=EX_FORM_FINISHED );

		if( me->info.switch1 == EXIT_COMMAND )
			{
			if( !(me->info.dpb_flags & HS_PLOT_SAVE_PLOTFILE) )
#				ifdef CLIX 
					if( !statl( me->info.plotfile, &stbuf ) )
						unlink( me->info.plotfile );
#				else
					if( !stat ( me->info.plotfile, &stbuf ) )
						unlink( me->info.plotfile );
#				endif

			if( !(me->info.dpb_flags & HS_PLOT_SAVE_TEXTFILE) )
#				ifdef CLIX 
					if( !statl( me->info.textfile, &stbuf ) )
						unlink( me->info.textfile );
#				else
					if( !stat ( me->info.textfile, &stbuf ) )
						unlink( me->info.textfile );
#				endif
			}
		}
	}


/*---make_plotfile---(action)----------------------------------------*/

action make_plotfile
	{
	struct GRid		myself;
	IGRint		levels[32];
	IGRlong		byte_rcvd, msg, which_error;
	struct var_list	inq_list[2];
	struct GRid	my_GRid;
	IGRchar		buff[100];
	Form		form_ptr;

	form_ptr = me->forms[0].form_ptr;


	
	my_GRid.objid = my_id;
	my_GRid.osnum = OM_Gw_current_OS;
	
	inq_list[0].var			= LEVELS;
	inq_list[0].var_ptr		= (IGRchar *) levels;
	inq_list[0].num_bytes		= 32 * sizeof( IGRint );
	inq_list[0].bytes_returned	= &byte_rcvd;
	
	inq_list[1].var			= END_PARAM;

	dp$inq_set_gragad(
		msg		= &msg,
		inq0_set1	= 0,
		osnum		= me->win_ids[0].osnum,
		gragad_objid	= me->win_ids[0].objid,
		which_error	= &which_error,
		var_list	= inq_list );

	HPcollect_element_to_plot( 
			&me->info,
			&my_GRid,
			&me->located_chansel,
			levels );

	/*
	 *  rewind the file and rewrite the header of the header.
	 *  note the "0" argument here and "1" before
	 */
	 
	lseek( me->info.file_id, (long)0, 0 );
	
	myself.objid = my_id;
	myself.osnum = OM_Gw_current_OS;

	HPwrite_header( &me->info, 0 );

	close( me->info.file_id );

	ex$message( msgnumb = HS_I_PltFlCrd, buff = buff );
	FIg_set_text( form_ptr, CP_STATUS_FIELD, buff );
	sleep( 3 );
	
	if( me->info.dpb_flags & HS_PLOT_WINDOW_CONTENTS )
		{
		ex$message( msgnumb = HS_P_SelWin, buff = buff );
		}
		       
	FIg_set_text( form_ptr, CP_STATUS_FIELD, buff );
	}


