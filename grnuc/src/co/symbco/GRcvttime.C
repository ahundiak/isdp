/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRcvt_time_to_ascii

Description
   This function returns the a string which contains the time in
   ascii.

   *msg           IGRlong           return code 
   *time          IGRint            The time in gmt.
   string[]       IGRchar           The character string.

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn      02/02/87  Changes for version 1.1
   Gray Winn      02/02/87  Creation date.
   Scott Walters  07/07/92  Changed ctime arg from int to time_t (ansi)
\*/

#include "coimport.h"
#include <time.h>
#include "igrtypedef.h"
#include "msdef.h"

extern char *ctime();

IGRint  GRcvt_time_to_ascii (msg, input_time, string)
IGRlong  *msg;
time_t   *input_time;
IGRchar  string[];
{
   *msg = MSSUCC;
   strcpy(string,ctime(input_time));
   return(1);
}
