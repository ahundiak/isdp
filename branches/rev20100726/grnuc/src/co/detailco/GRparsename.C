/* #######################    APOGEE COMPILED   ######################## */

/*\
DESCRIPTION
   This function will convert a string to a filename and save view
   name.

   *msg           IGRlong        completion code
   *string        IGRchar        string containing filename : save view
   *filename      IGRchar        string containing the filename
   *saveview_name IGRchar        string containing save view name.

RETURN VALUES
   MSSUCC  -- successful completion
   MSFAIL  -- if failure

HISTORY
   HGW   04/02/87 : Creation
   SCW   07/08/92 : ANSI conversion
\*/

#include "coimport.h"
#include "igrtypedef.h"
#include "msdef.h"

IGRint GRrfparsenames (msg, string, filename, saveview_name)
IGRlong     *msg;
IGRchar     string[];
IGRchar     filename[];
IGRchar     saveview_name[];
{
IGRint   i, length;

   *msg = MSSUCC;   
   length = strlen(string);

   for (i = 0; i < length; ++i)
   {
      if (string[i] == ':')
      {
         strncpy (filename, string, i);
         strcpy (saveview_name, &string[i+1]);
         return(1);
      }
   }
   strcpy (filename, string);
   return(1);
}
