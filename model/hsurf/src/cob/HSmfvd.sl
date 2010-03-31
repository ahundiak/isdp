
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $
*/

class              HSmfvd
super_class        HSwindow
command_object     "z multi frame save frame",0,HSMlFrSvFr
synonym            "z multi frame view dynamics",1,HSMlFrVwDy
product_name       "$MODEL"
start_state        start

specification

instance
	{
	IGRint		start_frame, end_frame;
	IGRint		oscilate;
	IGRchar		filename[12];
	}

state_table

#include "hsmsg.h"

implementation

#define CHECK_RETURN_CODES 0

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "hsmsg.h"

%safe

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*
 *  Prototype declaration for static functions
 */

/* HSmfvdi.I */
static void build_filename __((IGRchar *src, IGRint ext, IGRchar *dest));

#if defined(__cplusplus)
}
#endif


#undef __

%endsafe

	
/*---build_filename------------------------------------------------------*/

/*
 *  Given the extention'less design file name, and a numeric extention,
 *  build a filename
 */

static void build_filename( src, ext, dest )

IGRchar	*src;
IGRint	ext;
IGRchar	*dest;

	{
	IGRint	i;
	IGRchar	cext[3];

	/*
	 *  Copy the designfile name to the output string and add
	 *  a period
	 */
	 	 	
	memcpy( dest, src, i = strlen( src ) );
	
	dest[i++] = '.';

	/*
	 *  Convert the numeric extention to a string
	 */
	 	
	sprintf( cext, "%1d", ext );

	/*
	 *  Append the extention to the filename, padding the
	 *  extention with leading zeros, out to three characters
	 */
	 
	switch( strlen(cext) )
		{
		case 1:
			dest[i++] = '0';
			dest[i++] = '0';
			dest[i++] = cext[0];
			break;
				
		case 2:
			dest[i++] = '0';
			dest[i++] = cext[0];
			dest[i++] = cext[1];
			break;
				
		case 3:
			dest[i++] = cext[0];
			dest[i++] = cext[1];
			dest[i++] = cext[2];
			break;
		}

	dest[i] = 0;
	}

/*---default transitions for all states---------------------------*/

state *
	on EX_RJT_MOVEON state .
	on EX_RESTART    state start
	on EX_BACK_UP    state -

/*---start--(state)-----------------------------------------------*/

state start
	on CMD_TYPE = 0 or CMD_TYPE = 1
		state	get_window

/*---get_window---(state)-----------------------------------------*/

/*
 *  Have the user select a window and then branch on the command type
 */
 
state get_window

	execute		display_command_title
	prompt_key	HS_P_SelWin
	filter		get_event

	on EX_DATA or EX_STRING
		do get_selected_window( sts, 0, 1, 0, 0 )
		
			on SUCCESS
				do which_mode
					on RETURN_CODE = 0
						do get_filename
						state get_frame_number
						
					on RETURN_CODE = 1
						do get_filename
						state get_frame_range
						
				state .


			on ELSE
				state .
				
		state .

/*---get_frame_number---(state)------------------------------------------*/

/*
 *  For save frame mode, get the frame number with which to append onto
 *  the name of the output file
 */
 
state get_frame_number

	prompt	"Enter Frame Number"
	filter	get_event
	
	on EX_STRING
		do  read_range
		do  save_frame
		state terminate
		
	on EX_RJT_MOVEON
		state terminate
		
	on EX_BACKUP
		state -
		
/*---get_frame_range---(state)------------------------------------------*/

/*
 *  For view dynamics, get a range of frames to display
 */
 
state get_frame_range

	prompt	"Enter Frame Range"
	filter	get_event
	
	on EX_STRING
		do  read_range
		state  get_oscilate
		
	on EX_RJT_MOVEON
		state terminate
		
	on EX_BACKUP
		state -
		
/*---get_oscilate---(state)------------------------------------------*/

/*
 *  Find out if the user wants to oscilate through the frames or
 *  cycle
 */
 
state get_oscilate

	prompt	"Oscilate Through Frames? [y/n]"
	filter	get_event
	
	on EX_STRING
		do  read_oscilate
		do  view_dynamics
		state  terminate
		
	on EX_RJT_MOVEON
		state terminate
		
	on EX_BACKUP
		state -
		
/*---which_mode------------------------------------------------------*/

action	which_mode

	{
	*sts = me->mytype;
	}

/*---display_command_title---(action)--------------------------------*/

action display_command_title
	{
	if( me->mytype == 0 )
		{
		ex$message( msgnumb=HSM_M_MultFrmSaveFrm, field=MESSAGE_FIELD );
		}
	else		
		{
		ex$message( msgnumb=HSM_M_MultFrmVwDyn, field=MESSAGE_FIELD );
		}
	}

/*---get_filename---(action)-----------------------------------------*/

/*
 *  Get the designfile name, trnucate to 10 characters and drop the extention
 */
 
action	get_filename
	{
	IGRint		ret_bytes;
	IGRchar		temp_file[200];
	IGRint		which_error;
	IGRchar		*first_period, *strchr();
	
	struct EX_var_list	var_list[2];
	
	ret_bytes = sizeof( temp_file );
	
	var_list[0].var       = EX_CUR_FILENAME;
	var_list[0].var_value = temp_file;
	var_list[0].num_bytes = &ret_bytes;
	var_list[1].var       = EX_END_PARAM;
	
	*sts = ex$global( var = var_list,
		  which_error = &which_error );

	/*
	 *  Truncate file name to 10 characters
	 */
	 
	if( strlen( temp_file ) > 10 )
		temp_file[10] = '\0';
		
	/*
	 *  Truncate file name to before the first period
	 */
	 
	first_period = strchr( temp_file, '.' );
	if( first_period )
		*first_period = '\0';
		
	memcpy( me->filename, temp_file, strlen( temp_file )+1 );
	}

/*---read_range---(action)-----------------------------------------------*/

/*
 *  Get the frame number/frame range keyin from the user and parse out
 *  the number(s)
 */
 
action read_range
	{
	char	*kn;
	
	me->start_frame = 0;
	me->end_frame = 0;

	kn = me->event1.event.keyin;
		
	/*
	 *  get the first number out of the string
	 */
	 
	while( *kn >= '0' && *kn <= '9' )
		{
		me->start_frame = (me->start_frame * 10) + (*kn - '0');
		kn++;
		}
	
	/*
	 *  if the non-digit is not 0, then get next number
	 */
	 	
	if( *kn != 0 )
		{
		while( !(*kn >= '0' && *kn <= '9') && *kn != 0 ) kn++;
		
		if( *kn != 0 )
			{
			while( *kn >= '0' && *kn <= '9' )
				{
				me->end_frame = (me->end_frame * 10) + (*kn - '0');
				kn++;
				}
			}
		}
	}
		
/*---read_oscilate---(action)--------------------------------------------*/

/*  
 *  Parse the users response to the oscilate (y/n) prompt
 */
 
action read_oscilate
	{
	if( me->event1.event.keyin[0] == 'y' )
		me->oscilate = 1;
	else
		me->oscilate = 0;
	}
		
/*---save_frame---(action)-----------------------------------------------*/

/*
 *  Having the window and frame number, save the frame into a feedback
 *  buffer and write to disk
 */
 
action save_frame

	{
	IGRlong		msg;
	GRobjid		frame_id;
	GRspacenum	frame_osnum;
   	IGRchar		*fb_buffer;
	IGRint		fb_buffer_size;
	IGRint		fb_buffer_status;
	IGRint		buffer_size;
	IGRchar		filename[20];
	IGRint		fd;
	

    	status = OM_S_SUCCESS;	
	msg = MSSUCC;

	status = dp$reset_frames( msg = &msg);

	/*
	 *  Allocate memory for the feedback buffer.  100000 bytes is a guess
	 *  for size.  Then call start_frame to setup the save
	 */
	 
	fb_buffer = (IGRchar *)malloc( fb_buffer_size = 100000 );
			
	status = dp$start_frame( msg = &msg,
			    frame_no = me->start_frame,
			  load_frame = FALSE,
			    feedback = TRUE,
			feedback_buf = fb_buffer,
		       feedback_size = fb_buffer_size,
			   gragad_id = me->win_ids[0].objid,
			gragad_osnum = me->win_ids[0].osnum,
			    frame_id = &frame_id,
			 frame_osnum = &frame_osnum);

	if(!status)
		{
		fprintf( stderr, "Error in start_frame\n");
		goto wrapup;
		}


	/*
	 *  Call gen_update to collect the data and fill the feedback
	 *  buffer
	 */
	 	
	dp$gen_update( msg = &msg,
		     erase = FALSE,
		     objid = frame_id,
		     osnum = frame_osnum);

	
	/* 
	 *  Call end_frame to get information about the save
	 */
	 
	status = dp$end_frame( msg = &msg,
		     fb_buf_status = &fb_buffer_status,
		       buffer_size = &buffer_size,
			  frame_id = frame_id,
		       frame_osnum = frame_osnum);

	if(!status)
		{
		fprintf( stderr, "Error in end_frame\n");
		goto wrapup;
		}

	/*
	 *  Build the filename, create the file and write the
	 *  information onto disk.  I put the buffer size at the
	 *  top of the file so I'll know how much to allocate when
	 *  I start dynamics
	 */
	 		
	build_filename( me->filename, me->start_frame, filename );
	fd = creat( filename, 0777 );
	write( fd, &buffer_size, 4 );
	write( fd, fb_buffer, buffer_size+1 );
	close( fd );

wrapup:

	/*
	 *  free the feedback buffer memory and return
	 */
	 
	free( fb_buffer );
	}

/*---view_dynamics---(action)--------------------------------------------*/

action view_dynamics
	{
	IGRlong		msg;
   	IGRchar		**fb_buffer;
	IGRint		buffer_size;
	IGRint		i;
	IGRchar		filename[20];
	IGRint		fd;


	/*
	 *  Call reset frames.  If I don't do this, then new frames will
	 *  be appended to the old ones
	 */
	 
	status = dp$reset_frames( msg = &msg);

	/*
	 *  Allocate a buffer of pointers, one pointer for each frame
	 */
	 
	fb_buffer = (IGRchar **)malloc( sizeof(IGRchar *) * (me->end_frame - me->start_frame + 1) );
	
	/*
	 *  Loop through all the frames, read the data from disk and
	 *  load into memory
	 */
	 
	for( i=me->start_frame; i<=me->end_frame; i++ )
		{
			
		/*
		 *  build the filename, open the file and read the buffer size
		 */
		 
		build_filename( me->filename, i, filename );

		fd = open( filename, 0 );
		read( fd, &buffer_size, 4 );

		/*
		 *  allocate memory for the buffer and read the data
		 */
		 
		fb_buffer[i] = (IGRchar *)malloc( buffer_size+1 );
		
		read( fd, fb_buffer[i], buffer_size+1 );
		close( fd );

		/*
		 *  load the data into memory
		 */
		 
		status = dp$load_frame( msg = &msg,
				     buffer = fb_buffer[i],
				buffer_size = buffer_size );
		}

	/*
	 *  Display all the frames
	 */
	 	
	status = dp$display_frames( msg = &msg,
		       number_of_cycles = DPUNLIMITED_CYCLES,
			      direction = me->oscilate ? DPOSCILATING : DPFORWARD,
			      gragad_id = me->win_ids[0].objid,
			   gragad_osnum = me->win_ids[0].osnum );
			
	if (!status)
		{
		fprintf( stderr, "Error in display_frames\n");
		}
	}

