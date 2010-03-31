#include <string.h>
#include <stdio.h>
#include <time.h>
#include <sys/utsname.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HPglobal.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

/*--- HPgenerate_unique_name --------------------------------------------------------*/

/*
NAME
   HPgenerate_unique_name
        
KEYWORDS
   HSplot
        
DESCRIPTION
   This function constructs a unique file name that has the
   format: xxxxyyyyyy  where

      xxxx  - are the unique characters from the machines network address
              (i.e., 08-00-36-xx-xx-00).  The network address is determined
              by reading the file corresponding to the machine's node name
              from the /usr/lib/nodes/owned directory.

      yyyyyy - are the last six characters of the string that represents
               the number of seconds that have elapsed since Jan 1, 1970.

   If locating the network address files, or we're on a non CLIX workstation
   then the last 4 characters of the nodename is used.

HISTORY
   08/24/88	S.P. Rogers
      Creation Date (for Generate Visible Edges)
*/

void HPgenerate_unique_name (char *unique_name)

   {
   char ch;
   char filename[60];
   char string[132];
   char *node_string;
   char *search_string;
   char gmt_string[30];
   short eof_found;
   short found;
   int i;
   int cnt;
   long gmt;
   FILE *fp;
   struct utsname name;

   /* get the workstation node name */

   uname( &name );

   /*  Only on CLIX workstations, do we try and use the machine nodename */

#  if defined (CLIX)

   /* open the network address file and find the    */
   /* line that contains the network address string */

   search_string = "Address";
   eof_found = FALSE;
   found = FALSE;

   strcpy (filename, "/usr/lib/nodes/owned/");
   strcat (filename, name.nodename);

   fp = fopen (filename, "r");

   if (fp)
      {
      do
         {
         /* read to the next new-line character */
         cnt = 0;
         ch = getc (fp);
         while (ch != '\n')
            {
            string[cnt++] = ch;
            ch = getc (fp);
            if (feof (fp))
               {
               eof_found = TRUE;
               break;
               }
            }
         string[cnt++] = '\0';

         /* see if the search_string is contained in this line */
         for (i = 0; i < cnt - strlen (search_string); i++)
            {
            if (strncmp (&string[i], search_string, strlen (search_string)) == 0)
               {
               found = TRUE;
               break;
               }
            }
         }

      while ((!found) && (!eof_found));

      fclose (fp);
      } /* end: if ( fp ) */

   if (found)
      {
      /* the Network Address was found */

      /* skip the first 3 dashes of the Network Address */
      node_string = string;
      for (i = 0; i < 3; i++)
         {
         node_string = strchr (node_string, '-');
         node_string++;
         }

      /* copy out the 4 characters that we want */
      unique_name[0] = node_string[0];
      unique_name[1] = node_string[1];

      unique_name[2] = node_string[3];
      unique_name[3] = node_string[4];
      }
   else
#  endif /* CLIX */
      {

      /*
       * attemp to find network address failed => use last 4 chars of node
       * name instead
       */

      strncpy (unique_name, &name.nodename[strlen (name.nodename) - 4], 4);
      }

   unique_name[4] = '\0';

   /* append elapsed seconds stamp to string */

   gmt = time (0);
   sprintf (gmt_string, "%d", gmt);
   strcat (unique_name, &gmt_string[strlen (gmt_string) - 6]);

   }    /* HPgenerate_unique_name */
