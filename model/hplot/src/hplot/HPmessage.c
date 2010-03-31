#include <stdio.h>
#include <string.h>
#include <UMS.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hplot.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot.h"
#include "hpmsg.h"

#define DEBUG 0

struct msgstuff
   {
   int index;
   char string[80];
   };

static IGRchar initialized = 0; /* been here flag */

static char prod_name[24] = {"HSplot"};
static char msgfile[24] = {"hpmsg.msg"};


static void HPconsole_write (char *str)
   {
   FILE *fp;

   fp = fopen ("/dev/console", "w");
   fprintf (fp, "%s\n", str);
   fclose (fp);
   }

/*---HPfind_message_file-----------------------------------------------*/

/*
NAME
        HPfind_message_file
        
KEYWORDS
        HSplot
        messages
        
DESCRIPTION
        Reads the product data file to get the path's to the different
        products and attempts to find the message file in one of those
        products.
        
PARAMETERS
        msg_patn	:(OUT): string containing the message file name with
                                full path name
                                
HISTORY
        ??/??/??	M. Lanier
                Created
*/

void	HPfind_message_file (char *msg_path)

   {
   char c, *s, stuff[132], *getenv (), *envr;
   FILE *mp, *fp, *fopen ();
   char A[80], B[80], C[80], D[80], E[80];
   struct stat stat_buf;

#  if DEBUG
   fprintf( stderr, "HPfind_message_file:\n" );
#  endif

   envr = getenv ("HSplot_MSG_HOME");

#  if DEBUG
   fprintf( stderr, "   HSplot_MSG_HOME = " );
   if( envr != NULL )
      fprintf( stderr, "%s\n", envr );
   else
      fprintf( stderr, "NULL\n" );
#  endif

   if( envr != NULL )
      {
      strcpy( E, envr );

      sprintf (msg_path, "%s/config/english/messages/%s", E, msgfile);

      mp = fopen (msg_path, "r");

#     if DEBUG
      fprintf( stderr, "   msg_path = %s\n", msg_path );
#     endif

      if (mp) return;
      }

   else
      {
      envr = getenv ("INGRHOME");

#     if DEBUG
      fprintf( stderr, "   INGRHOME = " );
      if( envr != NULL )
         fprintf( stderr, "%s\n", envr );
      else
         fprintf( stderr, "NULL\n" );
#     endif

      if (envr != NULL)
         sprintf (stuff, "%s/product_data", envr);
      else
         sprintf (stuff, "/usr/ip32/product_data");

#     if DEBUG
      fprintf( stderr, "   stuff = %s\n", stuff );
#     endif

      fp = fopen (stuff, "r");
      msg_path[0] = 0;

      for (;;)
         {
         memset (stuff, 0, 132);
         s = stuff;
         while ((c = getc (fp)) != 10)
            {
            if (c < 0) return;

            *s++ = c;
            }

         sscanf (stuff, "%s %s %s %s %s", A, B, C, D, E);

#        if DEBUG
         fprintf( stderr, "   A, B, C, D, E: %s %s %s %s %s\n", A, B, C, D, E );
#        endif

         sprintf (msg_path, "%s/config/english/messages/%s", E, msgfile);

         if( stat( msg_path, &stat_buf ) == 0 ) break;
         }

      fclose( fp );

#     if DEBUG
      fprintf( stderr, "   msg_path(2) = %s\n", msg_path );
#     endif

      mp = fopen (msg_path, "r");
      if (mp) 
         {
         fclose( mp );
         return;
         }
      }
   }

/*---HPinitialize_message_system-------------------------------------*/

/*
NAME
        HPinitialize_message_system
        
KEYWORDS
        HSplot
        messages
        
DESCRIPTION
        Initialize the HSplot message system
        
PARAMTERS
        pname		:(IN) : Product name
        mfname		:(IN) : Name of the message file

FUNCTIONS CALLED
        memset
        memcpy
        fopen
        fclose
        HPfind_message_file
        UMSInitMsg
                
HISTORY
        ??/??/??	M. Lanier
                Created
*/

HPinitialize_message_system (char *pname, char *mfname)

   {
   IGRchar msgnam[180]; /* a place to put message string for output */
   FILE *fyl;   /* for finding message file */
   int status;

   /*
    * initialize if first time here
    */

   memset (prod_name, 0, 24);
   memset (msgfile, 0, 24);

   memcpy (prod_name, pname, strlen (pname));
   memcpy (msgfile, mfname, strlen (mfname));

   if (!initialized)
      {

      /*
       * Find the message file.  Get the path of this program and look in the
       * current default directory.
       */

      HPfind_message_file (msgnam);

      if ((fyl = fopen (msgnam, "r")) == NULL)
         {
         fprintf (stderr, "%s: %s not found\n", prod_name, msgnam);
         }
      else
         {
         fclose (fyl);
         initialized = 1;

         /* HPinit_messages( msgnam ); */
         status = UMSInitMsg (msgnam, UMS_INDEX);
         }
      }
   }

/*---HPmessage--------------------------------------------------------------*/

/*
NAME
        HPmessage
        
KEYWORDS
        HSplot
        messages
        
DESCRIPTION
        Given the message number, get the text of the message
        
PARAMETERS
        msgnumb		:(IN) :  Message number to look up
        msgstring	:(OUT):  text of the message
        flag		:(IN) :  Actions flags
                                
GLOBALS USED
        -none-
        
FUNCTIONS CALLED
        UMSGetByNum

HISTORY
        ??/??/??	M. Lanier
                Created
*/

IGRint HPmessage (IGRint msgnumb, IGRchar * msgstring, IGRint flag)

   {
   IGRchar buff[256];   /* a place to put message string for output */
   char *temp_ptr;
   IGRchar *exefile ();

   /*
    * The variable flag has the following meaning
    * 
    * 0 - Dont include standard prefix on message 1 - Include standard prefix on
    * message
    */

   /*
    * get more args and setup message string based on message number
    */

   temp_ptr = NULL;
   if (!msgnumb)
      return (0);

   if (msgstring != NULL)
      {

      /*
       * single string arg -- return success error code
       */

      if (initialized)
         {
         UMSGetByNum (buff, msgnumb, "%s", msgstring);
         }
      else
         {
         sprintf (buff, "error %d (%d) -- %s", msgnumb, msgnumb & 7, msgstring);
         }
      }
   else
      {

      /*
       * no arg message
       */

      if (initialized)
         {
         UMSGetByNum (buff, msgnumb, 0);
         }
      else
         {
         sprintf (buff, "error %d (%d)", msgnumb, msgnumb & 7);
         }
      }

   {
   char	msgstr[132];

   if( flag & HPmessage_PREFIX_PRODNAME )
      sprintf (msgstr, "%s: %s", prod_name, &buff[1]);
   else
      sprintf (msgstr, "%s", &buff[1]);

   fprintf( stderr, "%s\n", msgstr );

   if( flag & HPmessage_CONSOLE_WRITE )
      HPconsole_write( msgstr );
   }

   return (0);
   }

void	HPmessage_str( char *buff, int flag )
   {
   char	msgstr[132];

   if( flag & HPmessage_PREFIX_PRODNAME )
      sprintf (msgstr, "%s: %s", prod_name, &buff[1]);
   else
      sprintf (msgstr, "%s", &buff[1]);

   fprintf( stderr, "%s\n", msgstr );

   if( flag & HPmessage_CONSOLE_WRITE )
      HPconsole_write( msgstr );
   }
