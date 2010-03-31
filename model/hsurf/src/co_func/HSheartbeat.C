
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/


#include <stdio.h>
#include <math.h>
#include <time.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_co_func.h"


#define MAX_HEARTBEAT_PERIODS 5

extern IGRboolean DPdynamic_update_in_progress;

static char heartbeat_string[100];
static int min_length, max_length, cur_length;
static time_t last_time;


/*--- HSinit_heartbeat ------------------------------------------------------*/

void HSinit_heartbeat( IGRchar * string )

/*
NAME
        HSinit_heartbeat

DESCRIPTION
        Given a string that is to be the base for a heartbeat message, initialize the
        the variables needed to display the heartbeat and display the first message.

PARAMETERS
        string (IN) - the string to use as part of the heartbeat message

GLOBALS USED
        heartbeat_string (static)
        last_time (static)
        min_length, max_length, cur_length (static)

HISTORY
        07/20/89    S.P. Rogers
           Creation Date
        06/22/92    S.P. Rogers
           Changed to use ANSI standard time() function
*/

{

   if ( !DPdynamic_update_in_progress )
   {
      strcpy( heartbeat_string, string );
      strcat( heartbeat_string, " " );
      min_length = cur_length = strlen( heartbeat_string );
      max_length = min_length + MAX_HEARTBEAT_PERIODS;

      ex$message( field = ERROR_FIELD, in_buff = heartbeat_string, justification = CENTER_JUS );

      /* record time of this message */
      last_time = time( NULL );
   }

}/* HRinit_heartbeat */


/*--- HSupdate_heartbeat -------------------------------------------------*/

void HSupdate_heartbeat( void )

/*
NAME
        HSupdate_heartbeat

DESCRIPTION
        Update the periods in the HSURF heartbeat message if at least five seconds
        have gone by since the last update.

PARAMETERS
        none

GLOBALS USED
        heartbeat_string (static)
        last_time (static)
        min_length, max_length, cur_length (static)

HISTORY
        07/20/89    S.P. Rogers
           Creation Date
        06/22/92    S.P. Rogers
           Changed to use ANSI standard time() function
*/

{
   time_t this_time;

   if ( !DPdynamic_update_in_progress )
   {
      this_time = time( NULL );
      if ( ( this_time - last_time ) >= 5 )
      {
         last_time = this_time;

         if ( cur_length == max_length )
         {
            cur_length = min_length + 1;
            heartbeat_string[min_length] = '.';
            heartbeat_string[cur_length] = '\0';
         }
         else
         {
            heartbeat_string[cur_length++] = '.';
            heartbeat_string[cur_length] = '\0';
         }

         ex$message( field = ERROR_FIELD, in_buff = heartbeat_string, justification = CENTER_JUS );
      }

   }

}/* HSupdate_heartbeat */
