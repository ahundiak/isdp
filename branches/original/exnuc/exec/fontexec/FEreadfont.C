/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:             FEread_font
 
     Abstract:  This routine compares the given font file with those in
                the Font Executive table. If a match is found, the
                times-used counter is incremented and the font id
                is returned. If no match is found, this routine
                reads in the specified font and fills in the next
                available entry of the Font Executive table, setting
                the times used counter to one.
-----
%SC%

  VALUE = FEread_font(msg,fontfile,font_id)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    *fontfile     char              file used to read in font 
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
    ----------     --------------- -----------------------------------------
    *msg           IGRlong         completion code
    *font_id       FontId          identifies which font has been created
-----
%MD%

     MODULES INVOKED:   FSReadFontFile

-----
%RL%

      RELATIONS REFERENCED:  none

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  07/25/88 : Design date.
        DEK  07/25/88 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
FEread_font: This routine compares the given font file with those in
the Font Executive table. If a match is found, the times-used counter 
is incremented and the font id is returned. If no match is found, 
this routine reads in the specified font and fills in the next
available entry of the Font Executive table, setting the times used 
counter to one.
----*/
/*EH*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "FS.h"
#include "fedef.h"
#include "fe.h"
#include "OMprimitives.h"
#include "exlocaledef.h"
#include "exlocale.h"
#include <stdio.h>
#include "exmacros.h"

static IGRshort             num_file_entries = 0;  /* # of entries in fe */
static struct fontexec_file *fnt_exec_file = 0;    /* ptr to table of fe entries */

IGRboolean FEread_font(msg,fontfile,font_id)

IGRlong             *msg;            /* completion code                 */
char                *fontfile;       /* file used to read in font       */
FontId              *font_id;        /* identifies font                 */
{
   extern IGRint    FSReadFontFile();
   extern IGRchar   *strchr();

   IGRboolean       value;           /* return code                     */
   IGRboolean       reuse;           /* if true, have reused entry      */
   IGRboolean       match;           /* if true, already have entry     */
   IGRshort         i;               /* index counters                  */
   IGRshort         entry = 0;       /* entry to use in font exec       */
   IGRint           status;          /* return code from font server    */
   IGRchar          *slash;          /* check for '/' in fontfile name  */
   IGRchar          path_fontfile[PATH_LENGTH];
   FILE             *fp;             /* fontfile file pointer           */
   IGRchar          active_language[PATH_LENGTH];

   *msg = MSSUCC;
   value = TRUE;
   reuse = FALSE;
   match = FALSE;
   status = TRUE;

   /*
    * search through the table to see if this is a duplicate font
    */

   for (i = 0; i < num_file_entries; ++i)
   {
      if ((strcmp(fontfile,fnt_exec_file[i].fontfile) == 0))
      {
         /*
          * have match, need to increment times used counter
          * and return font id
          */

         ++(fnt_exec_file[i].times_used);
         *font_id = fnt_exec_file[i].font_id;
         match = 1;
         break;
      }
   }         /* end if (fnt_exec_file != 0) */

   if (!match)
   {
      if (num_file_entries == 0)
      {
         /*
          * first time for Font Executive, need to malloc the memory
          * and set the number of entries to one
          */

         fnt_exec_file = (struct fontexec_file *)om$malloc(size = sizeof(struct fontexec_file));

         if (fnt_exec_file == 0)
         {
            /*
             * no dynamic memory available -- return failure
             */

            *msg = MSFAIL;
            value = FALSE;
            goto WRAPUP;
         }

         num_file_entries = 1;
         entry = 0;
      }
      else           /* not first time table used */
      {
         /*
          * search through table to see if there is an entry that
          * is not being used; if so, use that entry
          */

         for (i = 0; i < num_file_entries; ++i)
         {
            if (fnt_exec_file[i].times_used == 0)
            {
               /*
                * use this entry
                */

               entry = i;
               reuse = TRUE;
               break;
            }
         }

         if (!reuse)
         {
            /*
             * realloc the Font Executive to accomodate another entry and
             * increment the number of entries
             */

            ++num_file_entries;

            fnt_exec_file = (struct fontexec_file *)om$realloc(ptr = (char *)fnt_exec_file,
                                                            size = num_file_entries * sizeof(struct fontexec_file));

            if (fnt_exec_file == 0)
            {
               /*
                * no dynamic memory available -- return failure
                */

               *msg = MSFAIL;
               value = FALSE;
               goto WRAPUP;
            }

            entry = num_file_entries - 1;

         }                       /* end not reuse */
      }                  /* end not first time */

      slash = strchr(fontfile,'/');

      if (!slash)
      {
         /*
          * if no path name with font file, then search the directory
          * paths for this file; use locale to find the active language
          */

         ex$language (language = active_language);

         for (i = 0; status == TRUE; ++i)
         {
            if (status = ex$get_path(index = i,
                                     path = path_fontfile,
                                     len = sizeof(path_fontfile)))
            {
               strcat(path_fontfile,"config/");
               strcat(path_fontfile,active_language);
               strcat(path_fontfile,"/fontfile/");
               strcat(path_fontfile,fontfile);

               if (fp = fopen(path_fontfile,"r"))
               {
                  fclose(fp);
                  break;
               }
            }
         }          /* end for each directory path */

         /*
          * if the fontfile was not found in the directory path search,
          * it may be a user defined fontfile; need to check in resrc
          */

         if (status == FALSE)
         {
            strcpy(path_fontfile,"/usr/ip32/resrc/fontserver/fontfile/");
            strcat(path_fontfile,fontfile);
         }
      }
      else      /* have path included with font file */
      {
         strcpy(path_fontfile,fontfile);
      }

      if ((status = FSReadFontFile(path_fontfile,font_id)) == FS_NO_ERROR)
      {
         strcpy(fnt_exec_file[entry].fontfile,fontfile);
         fnt_exec_file[entry].font_id = *font_id;
         fnt_exec_file[entry].times_used = 1;
      }
      else
      {
         --num_file_entries;
         *msg = status;
         value = FALSE;
      }
   }              /* end no match */

WRAPUP:

   return(value);
}

