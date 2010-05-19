/*
Author:  dh
Date:  3/15/95
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "dpstruct.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "vemsg.h"

#include "msdef.h"
#include "msmacros.h"

/* prototype files */
#include "VEpr_utilfnc.h"

#define MAX_HEARTBEAT_PERIODS 5

/* External Global Variables */
extern struct VEexecution_parms VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern IGRchar VEactivated_string[20];
extern IGRchar VEcompleted_string[20];

/* indicates whether VDS VE-specific processing is being done */
extern IGRboolean VDve_processing;

/* Static Variables */
static FILE *batch_fp;
static IGRint next_percentage;
static time_t beg_time;
static IGRboolean show_elapsed = FALSE; /* must be initialized to false */

/* Static variables for heartbeat message */
static IGRchar heartbeat_string[60];
static IGRint min_hb_length, max_hb_length, cur_hb_length;
static time_t last_hb_time;

/*--- VEinit_heartbeat ------------------------------------------------------*/

void VEinit_heartbeat( string )

	IGRchar *string;

/*
NAME
	VEinit_heartbeat

DESCRIPTION
	This function initializes the data required to show a heart beat
	message.  The heart beat message consists of the character string
	'string' followed by periods.

PARAMETERS
	string (IN) - the string to use for the heartbeat message

GLOBALS USED
	heartbeat_string (static)
	min_hb_length, max_hb_length, cur_hb_length (static)
	last_hb_time (static)

HISTORY
	05/28/90    S.P. Rogers
	   Creation Date
*/

	{
	if ( ! VEexec_parms.VEbatch )
	   {
	   last_hb_time = time( NULL );

	   sprintf( heartbeat_string, "%s ", string );

	   min_hb_length = cur_hb_length = strlen( heartbeat_string );
	   max_hb_length = min_hb_length + MAX_HEARTBEAT_PERIODS;

	   /* display initial message */
	   ex$message( field         = ERROR_FIELD,
	               in_buff       = heartbeat_string,
	               justification = CENTER_JUS );
	   }

	}  /* VEinit_heartbeat */


/*--- VEupdate_heartbeat ------------------------------------------------------*/

void VEupdate_heartbeat()

/*
NAME
	VEupdate_heartbeat

DESCRIPTION
	This function updates the heart beat indicator during GVE/GPE
	processing.  It adds periods to the heartbeat string and re-displays
	it in the ERROR_FIELD.  It also updates the elapsed time in the
	PROMPT_FIELD.

PARAMETERS
	none

GLOBALS USED
	heartbeat_string (static)
	min_hb_length, max_hb_length, cur_hb_length (static)
	last_hb_time (static)
	show_elapsed (static)

HISTORY
	05/08/89    S.P. Rogers
	   Creation Date
*/

	{
	time_t min, sec;
	time_t this_time;

	if ( ! VEexec_parms.VEbatch )
	   {
	   this_time = time( NULL );

	   if ( (this_time - last_hb_time) >= 5 )
	      {
	      /* at least five seconds have elapsed since last update */
	      last_hb_time = this_time;
	      if ( cur_hb_length == max_hb_length )
	         {
	         cur_hb_length = min_hb_length + 1;
	         heartbeat_string[ min_hb_length ] = '.';
	         heartbeat_string[ cur_hb_length ] = '\0';
	         }
	      else
	         {
	         heartbeat_string[ cur_hb_length++ ] = '.';
	         heartbeat_string[ cur_hb_length ]   = '\0';
	         }

	      ex$message( field         = ERROR_FIELD,
                          in_buff       = heartbeat_string,
	                  justification = CENTER_JUS );

	      if ( show_elapsed )
	         {
	         min = (this_time - beg_time) / 60;
	         sec = (this_time - beg_time) % 60;
	         ex$message( field         = PROMPT_FIELD,
	                     msgnumb       = VE_I_ElapsedTime,
	                     type          = "%d%d",
	                     var           = `min,sec`,
	                     justification = CENTER_JUS );
	         }
	      }

	   }

	}  /* VEupdate_heartbeat */

/*---- VEupdate_num_finished ----------------------------------------------*/

void VEupdate_num_finished(  )
/*
NAME
   VEupdate_num_finished

DESCRIPTION
   This function updates the "xxx Activated, yyy Completed" status message
   when an element is completed (i.e., removed from the active list).  If VE
   is running interactively, the message is written to the keyin field on the
   screen for each element that is completed.  If VE is running in batch
   mode, the message is written to the log file for the last element to
   complete, so a completion time can be seen in the log file.

PARAMETERS
   none

GLOBALS USED
   VEexec_status, VEexec_parms
   VEactivated_string, VEcompleted_string (static)
   show_elapsed (static)

HISTORY
   xx/xx/xx  S.P. Rogers  Creation Date
   3/15/95  dh  Modified to exclude conditionally the "activated/completed"
                message for VDS-specific VE processing
*/
{
   IGRchar temp_string[100], msg_buff[100];
   time_t now, min, sec;

   VEexec_status.VEfinished_elems++;

   sprintf( temp_string, "%d %s, %d %s", VEexec_status.VEactivated_elems,
            VEactivated_string, VEexec_status.VEfinished_elems,
            VEcompleted_string );

   if ( ( !VEexec_parms.VEbatch ) && ( !VDve_processing ) )
   {
      ex$message( in_buff = temp_string, field = KEYIN_FIELD );
   }

   if ( VEexec_status.VEfinished_elems == VEexec_status.VEtotal_elems )
   {
      now = time( NULL ) - beg_time;
      min = now / 60;
      sec = now % 60;
      ex$message( msgnumb = VE_I_ElapsedTime, type = "%d%d",
                  var = `min, sec `, buff = msg_buff );

      if ( VEexec_parms.VEbatch )
      {
         /* write the string and time stamp to the log file => if the */
         /* format of this line is changed the function used by "Retrieve */
         /* Edge Results From Server" will have to be modified too. */
         fprintf( batch_fp, "      %s   %s\n", temp_string, msg_buff );
         fflush( batch_fp );
      }
      else if ( show_elapsed )
      {
         /* write out total elapsed time to the UNIX window */
         fprintf( stderr, "%s\n", msg_buff );
      }
   }
}/* VEupdate_num_finished */

/*---- VEupdate_num_activated ---------------------------------------------*/

void VEupdate_num_activated(  )
/*
NAME
   VEupdate_num_activated

DESCRIPTION
   This function updates the "xxx Activated, yyy Completed" status message in
   the message strip whenever a new element is activated.  If CVE/CPE is
   running in batch mode, it writes the message to the log file along with a
   time stamp each time the activated count reaches a multiple of 5% of the
   elements activated.

PARAMETERS
   none

GLOBALS USED
   VEexec_status, VEexec_parms
   VEactivated_string, VEcompleted_string (static)

HISTORY
   xx/xx/xx  S.P. Rogers  Creation Date
   3/15/95  dh  Modified to exclude conditionally the "activated/completed"
                message for VDS-specific VE processing
*/
{
   IGRchar temp_string[100], msg_buff[100];
   IGRint percent_activated;
   time_t now, min, sec;

   VEexec_status.VEactivated_elems++;

   sprintf( temp_string, "%d %s, %d %s", VEexec_status.VEactivated_elems,
            VEactivated_string, VEexec_status.VEfinished_elems,
            VEcompleted_string );

   if ( VEexec_parms.VEbatch )
   {
      percent_activated =
         ( ( ( IGRdouble ) VEexec_status.VEactivated_elems ) /
           ( ( IGRdouble ) VEexec_status.VEtotal_elems ) ) * 100.0;

      if ( percent_activated >= next_percentage )
      {
         /* write the string and time stamp to the log file => if the */
         /* format of this line is changed the function used by "Retrieve */
         /* Edge Results From Server" will have to be modified too. */
         now = time( NULL ) - beg_time;
         now = time( NULL ) - beg_time;
         min = now / 60;
         sec = now % 60;
         ex$message( msgnumb = VE_I_ElapsedTime, type = "%d%d",
                     var = `min, sec `, buff = msg_buff );

         fprintf( batch_fp, "      %s   %s\n", temp_string, msg_buff );
         fflush( batch_fp );
         next_percentage = ( ( percent_activated / 5 ) + 1 ) * 5;
      }
   }
   else
   {
      VEupdate_heartbeat(  );
      if ( !VDve_processing )
      {
         ex$message( in_buff = temp_string, field = KEYIN_FIELD );
      }
   }
}/* VEupdate_num_activated */

/*---- VEdisplay_processing_message ---------------------------------------*/

void VEdisplay_processing_message(  )
/*
NAME
   VEdisplay_processing_message

DESCRIPTION
   This function displays the "Processing xxx total elements" message at the
   beginning of CVE/CPE processing.

PARAMETERS
   none

GLOBALS USED
   VEexec_status, VEexec_parms
   processing_string

HISTORY
   xx/xx/xx  S.P. Rogers  Creation Date
   3/15/95  dh  Modified to change conditionally the "processing n elements"
                message to "processing" for VDS-specific VE processing
*/
{
   IGRchar processing_string[60];

   if ( !VDve_processing )
   {
      ex$message( msgnumb = VE_I_Processing, type = "%d",
                  var = `VEexec_status.VEtotal_elems `,
                  buff = processing_string );
   }
   else
   {
      sprintf( processing_string, "Processing" );
   }

   if ( VEexec_parms.VEbatch )
   {
      fprintf( batch_fp, "   %s\n\n", processing_string );
      fflush( batch_fp );
   }
   else
   {
      VEinit_heartbeat( processing_string );
   }
}/* VEdisplay_processing_message */

/*--- VEinit_messages ------------------------------------------*/

void VEinit_messages()

/*
NAME
	VEinit_messages

DESCRIPTION
	This function initializes the values/strings used by VE
	when displaying messages.

PARAMETERS
	none

GLOBALS USED
	VEexec_parms
	VEactivated_string, VEcompleted_string (static)
	show_elapsed (static)

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	time_t  min, sec;
	IGRchar *expansion;

	/* initialize time variables */
	beg_time = time( NULL );

	/* determine if we should show elapsed time for interactive runs */
	expansion = getenv( "VE_SHOW_ELAPSED_TIME" );
	if ( (expansion == NULL) || (expansion[0] != '1') )
	   show_elapsed = FALSE;
	else
	   show_elapsed = TRUE;

	/* load the activated and completed strings */
	ex$message( msgnumb = VE_I_Activated,
	            buff    = VEactivated_string );

	ex$message( msgnumb = VE_I_Completed,
	            buff    = VEcompleted_string );

	if ( show_elapsed && (!VEexec_parms.VEbatch) )
	   {
	   min = 0; sec = 0;
	   ex$message( field         = PROMPT_FIELD,
	               msgnumb       = VE_I_ElapsedTime,
	               type          = "%d%d",
	               var           = `min,sec`,
	               justification = CENTER_JUS );
	   }
	               
	}  /* VEinit_messages */


/*---- VEissue_abort_message -----------------------------------*/

void VEissue_abort_message()

/*
NAME
	VEissue_abort_message

DESCRIPTION
	This function displays the "Aborting ..." message when VE is aborting
	due to the user hitting the stop button.

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	ex$message( msgnumb = VE_I_Aborting );
	}  /* VEissue_abort_message */


/*--- VEinit_batch_logging -----------------------------------------------*/

void VEinit_batch_logging( unique )

	IGRchar *unique;

/*
NAME
	VEinit_batch_logging

DESCRIPTION
	This function initializes batch mode logging.  It opens the log file
	and writes the starting time stamp to it.

PARAMETERS
	unique (IN) - unique prefix for log file

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRchar msg_buff[60];
	IGRchar fname[200];
	IGRchar *time_stamp;
	time_t  gmt;

	next_percentage = 5;

	sprintf( fname, "%s.log", unique );
	batch_fp = fopen( fname, "a" );

	/* write the current process id to the log file */
	ex$message( msgnumb = VE_I_BgProcId, buff = msg_buff );
	fprintf( batch_fp, "\n%s  %d\n\n", msg_buff, getpid() );

	/* write the starting time stamp to the log file => if the format      */
	/* of this line is changed the function used by "Retrieve Edge Results */
	/* From Server" will have to modified to.                              */
	/* write the starting time stamp to the log file */
	gmt = time( NULL );
	time_stamp = ctime( &gmt );
	fprintf( batch_fp, "START TIME: %s\n", time_stamp );

	fflush( batch_fp );

	}  /* VEinit_batch_logging */


/*--- VEstop_batch_logging -----------------------------------------*/

void VEstop_batch_logging()

/*
NAME
	VEstop_batch_logging

DESCRIPTION
	This function stops batch mode logging.  It writes the ending time
	time stamp to the log file and closes it.

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	xx/xx/xx    S.P. Rogers
	   Creation Date
*/

	{
	IGRchar *time_stamp;
	time_t  gmt;

	/* write the ending time stamp to the log file */
	gmt = time( NULL );
	time_stamp = ctime( &gmt );
	fprintf( batch_fp, "\nSTOP TIME: %s\n", time_stamp );

	fprintf( batch_fp, "\nThe EMS version and error messages follow:\n\n" );
	fclose( batch_fp );

	}  /* VEstop_batch_logging */
