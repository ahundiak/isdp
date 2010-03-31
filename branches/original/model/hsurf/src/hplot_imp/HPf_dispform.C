 
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1


#include <stdio.h>
#include <FI.h>
#include <sys/types.h>

#include "wl.h"

#if !defined( CLIX ) && !defined(SUNOS5)
#include <sys/dir.h>
#endif
 
#if defined (SUNOS5)
#include <dirent.h>
#endif

#include <sys/stat.h>

#include "DIdef.h"
#include "sys/utsname.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "madef.h"
#include "pidef.h"
#include "plotmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "FI.h"
#include "hsdef.h"
#include "HSplot.h"
#include "HSplot_def.h"
#include "HSplot_label.h"
#include "hsmsg.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_hplot.h"

/*-----------------------
 *  for function
 *     HFI_confirm_box
 */
 
#include "HSpr_co_func.h"

/*----------------------*/


#include "HSplot.h"
#include "HSplot_def.h"

#include "HSpr_hplot.h"

/*---HPdisplay_create_form-------------------------------*/

/*
NAME
	HPdisplay_create_form
	
KEYWORDS
	shaded plotting
	create shaded plotfile
	
DESCRIPTION
	Initialize and display the create shaded plot file form
	
PARAMTERS
	info	:(IN) : shaded plotting global information
	
GLOBALS USED
	-none-
	
FUNCTIONS CALLED
	FI_confirm_box
	FIf_display
	FIf_get_location
        FIf_is_displayed
	FIfld_set_text
	FIg_enable
	FIg_erase
	FIg_set_state_off
	FIg_set_state_on
	FIg_set_text
	HPcreate_form_notify
	HPgenerate_unique_name
	ex$message
	memcpy
	sprintf
	stat (sun only)
	statl (clipper only)
	strcmp
	uname

HISTORY
	??/??/??	M. Lanier
		Created
        H.S.Gandhi   07/07/93
            Made a fix for the TR#119304360 so that the shaded plotfile form
            does not do a double update

*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPdisplay_create_form( struct HSplot_info *info )
#else
	void	HPdisplay_create_form( info )

	struct HSplot_info	*info;
#endif

	{
	IGRlong			status;

	IGRchar			buff[100], buf1[100], buf2[100], buf3[40];
	struct utsname		node;
	int			xpos, ypos;
        int                     disp_sts=0;

#	ifdef CLIX
		struct statl		stbuf;
#	else
		struct stat		stbuf;
#	endif	

	/*
	 *  Set the active form to Create Shaded Plot File
	 */
	 	
	info->displayed_form = info->create_form;
	
	FIg_erase( info->displayed_form, CP_CONVERT_WINDOW );


	if( info->dpb_flags & HS_PLOT_WINDOW_CONTENTS )
		info->dpb_flags &= ~HS_PLOT_WINDOW_CONTENTS;
	else
		info->dpb_flags |=  HS_PLOT_WINDOW_CONTENTS;

	HPcreate_form_notify( CP_FENCE_WINDOW_CONTENTS, info );
	

	/*
	 *  Set the state of the save plotfile check
	 */
	 		
	if( info->dpb_flags & HS_PLOT_SAVE_PLOTFILE )	
		FIg_set_state_on ( info->create_form, CP_SAVE_PLOTFILE );
	else
		FIg_set_state_off( info->create_form, CP_SAVE_PLOTFILE );
	
	/*
	 *  Set the state of the save rasterfile check
	 */
	 	
	if( info->dpb_flags & HS_PLOT_SAVE_RASTERFILE )
		FIg_set_state_on ( info->create_form, CP_SAVE_RASTERFILE );
	else
		FIg_set_state_off( info->create_form, CP_SAVE_RASTERFILE );
		
	/*
	 *  Set the state of the save textfile check
	 */
	 	
	if( info->dpb_flags & HS_PLOT_SAVE_TEXTFILE )
		FIg_set_state_on ( info->create_form, CP_SAVE_TEXTFILE );
	else
		FIg_set_state_off( info->create_form, CP_SAVE_TEXTFILE );
		
	/*
	 *  Display the rasterfile and plotfile
	 */
	 		
	FIg_set_text( info->create_form, CP_PLOTFILE, info->plotfile );
	FIg_set_text( info->create_form, CP_RASTERFILE, info->rasterfile );
	
	if( info->dpb_flags & HS_PLOT_CREATE_TEXTFILE )
		FIg_set_text( info->create_form, CP_TEXTFILE, info->textfile );
	else
		{
		ex$message( msgnumb=HS_I_NA, buff=buff );
		FIfld_set_text( 
			info->displayed_form, 
			CP_TEXTFILE, 
			0, 0, buff, 0 );
		}
	
	/*
	 *  Display the form
	 */

	/*if( info->displayed_form_no == HSplot_CREATE_FORM )*/
          /* Makes a check if the form is already displayed. If the form */
          /* is already displayed, then do not display it again. This is */
          /* fix for TR#119304360. HSG;07/07/93                          */
          FIf_is_displayed(info->create_form,&disp_sts);
          if (disp_sts)
             FIg_enable(info->create_form, FI_FORM_GROUP);
          else
		{
		FIg_enable( info->create_form, FI_FORM_GROUP );
		FIf_display( info->create_form );	
		info->displayed_form_no = HSplot_CREATE_FORM;
		}

	/*
	 *  Check that the shaded plotfile already exist
	 */
	 
#	ifdef CLIX
	    if( !statl( info->plotfile, &stbuf ) )
#	else
	    if( !stat( info->plotfile, &stbuf ) )
#	endif
		{
		if( strcmp( info->plotfile, info->last_checked_plotfile ) != 0 )
			{
			ex$message( msgnumb=HS_E_OvrWrtPflHd,   buff=buf1 );
			ex$message( msgnumb=HS_E_OvrWrtPflCan1, buff=buf2 );
			ex$message( msgnumb=HS_E_OvrWrtPflChk,  buff=buf3 );

			sprintf( buff, "%s\n%s\n%s", buf1, buf2, buf3 );

			ex$message( msgnumb=HS_E_OvrWrtPflNotice,   buff=buf1 );

			FIf_get_location( info->create_form, &xpos, &ypos );

			FIg_disable( info->displayed_form, FI_FORM_GROUP );
#ifndef X11
			status = FI_confirm_box(
				FI_CURRENT_SCREEN,
				xpos+178, ypos+94,
				buf1,
				FI_RED,
				"swiss742",
				36.0,
				buff,
				FI_BLACK,
				"swiss742",
				18.0,
				FI_LEFT_JUSTIFIED,
				FI_ACCEPT | FI_CANCEL,
				40 );
#else
			status = HFI_confirm_box(
				FI_CURRENT_SCREEN,
				xpos+178, ypos+94,
				buf1,
				FI_RED,
				"swiss742",
				36.0,
				buff,
				FI_BLACK,
				"swiss742",
				18.0,
				FI_LEFT_JUSTIFIED,
				FI_ACCEPT | FI_CANCEL,
				40 );

#endif
			FIg_enable( info->displayed_form, FI_FORM_GROUP );

			if( !status )
				{
				uname( &node );
				HPgenerate_unique_name( node.nodename, buff );
	
				sprintf( info->plotfile, "%s.pfl", buff );

				FIfld_set_text( 
					info->displayed_form, 
					CP_PLOTFILE,
					0, 0, info->plotfile, 0 );
				}
			}
		}

	memcpy( info->last_checked_plotfile, info->plotfile, strlen(info->plotfile)+1 );

	if( info->dpb_flags & HS_PLOT_CREATE_TEXTFILE )
		{
			
		/*
		 *  Check that the IGDS textfile already exist
		 */
	 
#		ifdef CLIX
		    if( !statl( info->textfile, &stbuf ) )
#		else
		    if( !stat( info->textfile, &stbuf ) )
#		endif
			{
			if( strcmp( info->textfile, info->last_checked_textfile ) != 0 )
				{
				ex$message( msgnumb=HS_E_OvrWrtTflHd,   buff=buf1 );
				ex$message( msgnumb=HS_E_OvrWrtPflCan1, buff=buf2 );
				ex$message( msgnumb=HS_E_OvrWrtPflChk,  buff=buf3 );

				sprintf( buff, "%s\n%s\n%s", buf1, buf2, buf3 );

				ex$message( msgnumb=HS_E_OvrWrtPflNotice,   buff=buf1 );

				FIf_get_location( info->create_form, &xpos, &ypos );

				FIg_disable( info->displayed_form, FI_FORM_GROUP );
#ifndef X11
				status = FI_confirm_box(
					FI_CURRENT_SCREEN,
					xpos+178, ypos+144,
					buf1,
					FI_RED,
					"swiss742",
					36.0,
					buff,
					FI_BLACK,
					"swiss742",
					18.0,
					FI_LEFT_JUSTIFIED,
					FI_ACCEPT | FI_CANCEL,
					40 );
#else
				status = HFI_confirm_box(
					FI_CURRENT_SCREEN,
					xpos+178, ypos+144,
					buf1,
					FI_RED,
					"swiss742",
					36.0,
					buff,
					FI_BLACK,
					"swiss742",
					18.0,
					FI_LEFT_JUSTIFIED,
					FI_ACCEPT | FI_CANCEL,
					40 );
#endif
				FIg_enable( info->displayed_form, FI_FORM_GROUP );

				if( !status )
					{
					uname( &node );
					HPgenerate_unique_name( node.nodename, buff );
	
					sprintf( info->textfile, "%s.pfl", buff );

					FIfld_set_text( 
						info->displayed_form, 
						CP_PLOTFILE,
						0, 0, info->textfile, 0 );
					}
				}
			}
		}
		
	memcpy( info->last_checked_textfile, info->textfile, strlen(info->textfile)+1 );
	}

/*---HPdisplay_submit_form-------------------------------*/

/*
NAME
	HPdisplay_submit_form
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Initialize and display the submit shaded plot file form

PARAMTERS
	info	:(IN) : shaded plotting global information
	
GLOBALS USED
	-none-
	
FUNCTIONS CALLED
	FIf_display
	FIfld_get_list_text
	FIfld_set_text
	FIg_erase
	FIg_set_state_off
	FIg_set_state_on
	FIg_set_text
	HPpqinfo
	HPshow_size
	HPspformatqinfo
	HPspqlist
	HPsubmit_form_notify
	ex$message
	sscanf

HISTORY
	??/??/??	M. Lanier
		Created	
		
	02/12/93	M. Lanier
		Changed call to HPpqinfo, HPspformatqinfo to COpqinfo,
		COqpformatqinfo.  
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPdisplay_submit_form( struct HSplot_info *info )
#else
	void	HPdisplay_submit_form( info )

	struct HSplot_info	*info;
#endif

	{
	IGRlong		status;
	IGRchar		buf[80];
	IGRint		qcount;
	IGRint		sel;
	IGRchar		buff[100], buf0[100], unit[18];
	IGRchar		defq[100];
	int		xpos, ypos;

	info->displayed_form = info->submit_form;
	info->displayed_form_no = HSplot_SUBMIT_FORM;

	/*status = FIg_erase( info->displayed_form, SP_JOB_STATUS );*/

	ex$message( msgnumb=HS_I_SubShaPlt, buff=buff );
	status = FIg_set_text( info->displayed_form, SP_FORM_TITLE, buff );
	
	/* fill in the plotter list */

	if( HPspqlist( info->submit_form, &qcount, info->queue, &info->con_flags ) == PI_F_NOQUEUE )
		{
				
		/* no queues defined */
		
		ex$message( msgnumb = HS_E_NoPlotQ, buff = buf );
		
		FIfld_set_text( 
			info->submit_form, 
			SP_QUEUE,
			0, 0, buf, 0 );
				
		FIfld_set_text( 
			info->submit_form, 
			FI_MSG_FIELD, 
			0, 0, buf, 0 );
		}
	else
		{
		if( info->queue[0] == NULL || (info->con_flags & HP_CONTROL_DEF_QUE_NOT_EXIST) )
			{
					
			/* grab the first plotter in the list */
			sscanf( info->queue, "%s", defq );	
			FIfld_get_list_text( 
					info->submit_form,
					SP_QUEUE,
					0, 0, 64, 
					buf, &sel );
						
			sscanf( buf, "%s", info->queue );

			}

		/* display the default plotter, filename, and pen table */

		HPpqinfo( info->queue, 
                          &info->plotter_max[0], &info->plotter_max[1], 
                          &info->plotter_resolution, 
                          unit );
			
		HPspformatqinfo( 
			info->queue, 
			info->plotter_max[0],
			info->plotter_max[1], 
                        info->plotter_resolution,
			unit,
			buf );
				
		FIfld_set_text( 
			info->submit_form, 
			SP_QUEUE,
			0, 0, buf, 0 );
		}

	if( info->con_flags & HP_CONTROL_SUBMIT_PLOTFILE )
		{
		FIfld_set_text( 
			info->submit_form, 
			SP_PLOTFILE,
			0, 0, info->plotfile, 0 );

		ex$message( msgnumb=HS_I_NA, buff=buff );			
		
		if( info->con_flags & HP_CONTROL_SUBMIT_TEXTFILE )
			FIfld_set_text( 
				info->submit_form, 
				SP_TEXTFILE,
				0, 0, info->textfile, 0 );
		else
			FIfld_set_text( 
				info->submit_form, 
				SP_TEXTFILE,
				0, 0, buff, 0 );

		FIfld_set_text(
			info->submit_form,
			SP_RASTERFILE,
			0, 0, buff, 0 );
		}
	else
		{
		FIfld_set_text( 
			info->submit_form, 
			SP_RASTERFILE,
			0, 0, info->rasterfile, 0 );

		ex$message( msgnumb=HS_I_NA, buff=buff );
		
		if( info->con_flags & HP_CONTROL_SUBMIT_TEXTFILE )
			FIfld_set_text( 
				info->submit_form, 
				SP_TEXTFILE,
				0, 0, info->textfile, 0 );
		else
			FIfld_set_text( 
				info->submit_form, 
				SP_TEXTFILE,
				0, 0, buff, 0 );

		FIfld_set_text(
			info->submit_form,
			SP_PLOTFILE,
			0, 0, buff, 0 );
		}
	
	/*
	 *  Set the image size.
	 */


	HPshow_size( info );	
	HPsubmit_form_notify(
		SP_SCALE,
		info );

	/*
	 *  set the number of copies
	 */
	 			
	sprintf( buf, "%1d", info->copies );
	FIfld_set_text(
		info->submit_form,
		SP_COPIES,
		0, 0, buf, 0 );
		
	FIg_set_text(
		info->submit_form,
		SP_DATE,
		"" );

	if( info->dpb_flags & HS_PLOT_MAIL_AT_BEGIN )
		FIg_set_state_on ( info->submit_form, SP_MAIL_BEGIN );
	else
		FIg_set_state_off( info->submit_form, SP_MAIL_BEGIN );
		
	if( info->dpb_flags & HS_PLOT_MAIL_AT_END )
		FIg_set_state_on ( info->submit_form, SP_MAIL_END );
	else
		FIg_set_state_off( info->submit_form, SP_MAIL_END );
		
	
/*
Removed because I think that these fields are no longer on the
submit form.  Mike 11-7-97

	if( info->dpb_flags & HS_PLOT_BLACK_AND_WHITE )
		FIg_set_state_on ( info->submit_form, SP_BLACK_AND_WHITE );
	else
		FIg_set_state_off( info->submit_form, SP_BLACK_AND_WHITE );
	
	if( info->dpb_flags & HS_PLOT_WHITE_BACKGROUND )
		FIg_set_state_on ( info->submit_form, SP_WHITE_BACKGROUND );
	else
		FIg_set_state_off( info->submit_form, SP_WHITE_BACKGROUND );
*/


	FIf_display( info->submit_form );			

	if((info->con_flags & HP_CONTROL_DEF_QUE_NOT_EXIST) && (defq[0] != 0) &&
            (info->dpb_flags & HS_PLOT_OLD_FILE))
		{
		ex$message( msgnumb=HS_E_OvrWrtPflNotice, buff=buf0 );
		ex$message( msgnumb = HS_I_QueNotExist,
			       type = "%s",
			        var = `defq`,
			       buff = buff );
		
		FIf_get_location( info->submit_form, &xpos, &ypos );

		status = FI_message_box(
			FI_CURRENT_SCREEN,
			xpos+178, ypos+94,
			buf0,
			FI_RED,
			"swiss742",
			36.0,
			buff,
			FI_BLACK,
			"swiss742",
			18.0,
			FI_LEFT_JUSTIFIED,
			40 );
		}
	}

/*---HPdisplay_queue_form-------------------------------*/

/*
NAME
	HPdisplay_queue_form
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	initialize and display the shaded queue status form
	
PARAMETERS
	into	:(IN) : shaded plotting global information
	
GLOBALS USED
	-none-
	
FUNCTIONS CALLED
	FIf_display
	FIfld_set_text
	FIg_set_symbol_file
	FIg_set_symbol_index
	HPget_qstat_command
	HPstatus_form_notify
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPdisplay_queue_form( struct HSplot_info *info )
#else
	void	HPdisplay_queue_form( info )

	struct HSplot_info	*info;
#endif

	{
	IGRchar		buff[100];

	info->displayed_form = info->status_form;
	info->displayed_form_no = HSplot_STATUS_FORM;

	HPget_qstat_command( info->queue, buff );
	FIfld_set_text( info->displayed_form, QS_QUEUE, 0, 0, buff, 0 );
	
	FIg_set_symbol_file( info->status_form, 26, "MDpop.sym" );
	FIg_set_symbol_index( info->status_form, 26, 11 );
	
	FIg_set_symbol_file( info->status_form, 25, "HS.sym" );
	FIg_set_symbol_index( info->status_form, 25, 25 );
	
	FIf_display( info->status_form );
		
	HPstatus_form_notify(
		QS_UPDATE,
		info );
	}

/*---HPdisplay_option_form-------------------------------*/

void	HPdisplay_option_form( info )

struct HSplot_info	*info;

	{
	IGRchar		buff[100];

	info->displayed_form = info->option_form;
	info->displayed_form_no = HSplot_OPTION_FORM;

        FIg_erase( info->option_form, OP_EXCLUDE_WIREFRAME_ELEMENTS );
	
	sprintf( buff, "%f", info->t_line_width_const );
	FIg_set_text( info->option_form, OP_LINE_WIDTH_CONSTANT, buff );
	
	sprintf( buff, "%d", info->t_max_line_width );
	FIg_set_text( info->option_form, OP_MAX_LINE_WIDTH, buff );

	FIg_set_state( info->option_form, OP_BACKGROUND_COLOR, !(info->opt_flags & HS_PLOT_WHITE_BACKGROUND) );
	FIg_set_state( info->option_form, OP_RASTERFILE_DATA_TYPE, info->t_raster_type != 25 );
	FIg_set_state( info->option_form, OP_EDGE_DISPLAY, info->opt_flags & HS_PLOT_BLACK_AND_WHITE );
	FIg_set_state( info->option_form, OP_EXCLUDE_WIREFRAME_ELEMENTS, (info->opt_flags & HS_PLOT_EXCLUDE_WIREFRAME) );
	
	sprintf( buff, "Background Color" );
	if( info->opt_flags & HS_PLOT_BLACK_AND_WHITE )
		sprintf( buff, "%s\nBlack", buff );
	else
		sprintf( buff, "%s\nOriginal", buff );
		
	FIg_set_on_text( info->option_form, OP_BACKGROUND_COLOR,  buff );

	FIf_display( info->option_form );
	}


