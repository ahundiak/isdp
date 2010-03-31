
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

/*
DESCRIPTION
	rle_view
	
	   - View a type 27 or 29 RLE file or the difference between two rle files
	   
	   Options:
	   
	      -f [file1] -f [file2] : diffrence two files
	      
	      -f [file]             : view a single file

HISTORY
	S.P. Rogers  11/24/89  Creation Date
*/

#include <stdio.h>
#include <tools.h>
#include <sdl.h>
#include <math.h>
#include "FI.h"
#include "rle_view.h"
#include "hsmsg.h"
#include "hsmachine.h"
#include "hsanimate.h"

#define IGRchar		char
#define IGRint		int
#define IGRlong		long

#include "ms.h"

/*
MSmessage ( (field), (msgnumb), (msgname), (justification), (buff),
                (type), (var), (in_buff), (time), (seconds) );
*/

MSmessage( FieldNumber, MessageNumber, MessageName, Justification, Buffer, Garbage1, Garbage2, InBuff )
	int FieldNumber, MessageNumber;
	char MessageName[], Buffer[], InBuff[];
	int Justification, Garbage1, Garbage2;
{
	char MsgBuffer[200];

	if( Justification == -1 ) Justification = 1;
	if( Buffer )
	{
		if( GetMessage( MessageNumber, Buffer, (char **)0 ) )
		{
			sprintf( Buffer, "ERROR: Message %d not found in message file hsmessage.msg\n",
				MessageNumber );
		}
	}
	else if( InBuff )
		Display_message( FieldNumber+1, Justification, InBuff );
	else if( !GetMessage( MessageNumber, MsgBuffer, (char **)0 ) )
		Display_message( FieldNumber+1, Justification, MsgBuffer );
	else
	{
		sprintf( MsgBuffer, "ERROR: Message %d not found in message file hsmessage.msg\n",
			MessageNumber );
		Display_message( FieldNumber, CENTER, MsgBuffer );
	}

} /* MSmessage */

static int MsgNo;

MS_init( MS_msg, MessageNumber, MessageName, InBuffer, FieldNumber, Justification )
struct MS_sd_msg *MS_msg;
int MessageNumber;
char MessageName[], InBuffer[];
int FieldNumber, Justification;
{
	MsgNo = MessageNumber;
} /* MS_init */

MS_fix_type()
{
} /* MS_fix_type */

MS_out_msg( MS_msg, Buffer, FieldNumber, Justification, Time, Seconds )
struct MS_sd_msg *MS_msg;
char Buffer[];
int FieldNumber, Justification;
int Time, Seconds; /* Not supported! */
{
	char LocalBuffer[200];

	if( !GetMessage( MsgNo, LocalBuffer, (char **)&(MS_msg->variables) ) )
	{
		Display_message( FieldNumber+1, Justification, LocalBuffer );
/*		sleep( 3 );
		Display_message( FieldNumber+1, LEFT, "" );
*/
	}
	else
		fprintf( stderr, "ERROR: Message %d not found in message file hsmessage.msg\n",
			MsgNo );

} /* MS_out_msg */

HSget_vm_stats( total_mem, used_mem )
int *total_mem, *used_mem;
{
	/* Fake out the caller and always say there's enough memory */
	*used_mem = 0;
	*total_mem = HS_DSPLIMG_TILER_RESERVE;

} /* HSget_vm_stats */


/*--- HSgetMachineInfo ---------------------------------------------------*/

void HSgetMachineInfo( NumPlanes, TermType, Max_C_S )
	int *NumPlanes, *TermType, *Max_C_S;
{
	int          vs_no;
	int          temp_num_planes;
#ifndef RUN_X
	struct scr_info screen_info[MAX_SCREENS];

	/* base everything on the RIGHT VIRTUAL screen */
	Inq_displayed_vs( &vs_no );

	Inq_screen_info( screen_info );

	if ( screen_info[vs_no].vsi_flags & VSI_TRC_ABILITY )
	{
	   if (TermType) *TermType = EDGEII_TRC;
	   if (NumPlanes) *NumPlanes = EDGEII_TRC_NUM_PLANES;
	   if (Max_C_S) *Max_C_S = EDGEII_TRC_COLOR_SLOTS;
	}
	else
	{
#endif
	   /* no solution for X-windows yet */
/*	   ige$inq_term_info( num_of_planes = &temp_num_planes ); */
#ifndef RUN_X
	   temp_num_planes = screen_info[vs_no].vsi_num_planes;
#endif

	   if (NumPlanes)
		*NumPlanes = temp_num_planes;

	   switch ( temp_num_planes )
	      {
	      case GS_NUM_PLANES:
	         if (TermType) *TermType = GS;
	         if (Max_C_S) *Max_C_S = GS_COLOR_SLOTS;
	         break;

	      case GXGZ_NUM_PLANES:
	         if (TermType) *TermType = GXGZ;
	         if (Max_C_S) *Max_C_S = GXGZ_COLOR_SLOTS;
	         break;

	      case TURQ_NUM_PLANES:
	         if (TermType) *TermType = TURQ;
	         if (Max_C_S) *Max_C_S = TURQ_COLOR_SLOTS;
	         break;
	      }

#ifndef RUN_X
	}
#endif

} /* HSgetMachineInfo */

