/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:             FEadd_font
 
     Abstract:  This routine compares the given font with those in
                the Font Executive table. If a match is found, the
                times-used counter is incremented and the font id
                is returned. If no match is found, this routine
                loads in the specified font and fills in the next
                available entry of the Font Executive table, setting
                the times used counter to one.


     MODULE NAME:             FErm_font

     Abstract:  This routine compares the font file specification
                with those in the Font Executive table. If a match
                is found, a check is made to see if the times used
                counter is one. If the times used counter is one,
                clear the counter and remove the font from virtual 
                memory. If the times used counter is not one, simply
                decrement the counter.
-----
%SC%

  VALUE = FEadd_font(msg,typeface,bodysize,aspect,rotation,slant,
                     charmap,flags,rangecount,rangespec,font_id)

  VALUE = FErm_font(msg,font_id)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    *typeface     char              typeface file used to create font
    bodysize      real64            bodysize; lines per em square
    aspect        real64            aspect ratio
    rotation      real64            ccw rotation angle
    slant         real64            ccw slant
    *charmap      IGRchar           character mapping
    flags         int32             font specification flags 
    rangecount    IGRshort          number of ranges
    *rangespec    RangeSpec         range of characters to generate
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
    ----------     --------------- -----------------------------------------
    *msg           IGRlong         completion code
    *font_id       FontId          identifies which font has been created
-----
%MD%

     MODULES INVOKED:   FSNewFont
                        FSDelFont
-----
%RL%

      RELATIONS REFERENCED:  none

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  01/13/88 : Design date.
        DEK  01/14/88 : Creation date.
        DEK  03/31/88 : Changed to allow default values; called from macro.
        DEK  04/19/88 : Rangespec capability added.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
FEadd_font:

     This routine compares the given font with those in the Font 
Executive table. If a match is found, the times-used counter is 
incremented and the font id is returned. If no match is found, this 
routine loads in the specified font and fills in the next available 
entry of the Font Executive table, setting the times used counter 
to one.

FErm_font:

  This routine compares the font file specification with those in the 
Font Executive table. If a match is found, a check is made to see if 
the times used counter is one. If the times used counter is one, clear 
the counter and remove the font from virtual memory. If the times used 
counter is not one, simply decrement the counter.
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
#include <stdio.h>
#include "exlocaledef.h"
#include "exlocale.h"
#include "exmacros.h"

static IGRshort              fe_num_entries = 0;  /* number of entries in font
                                                     executive               */
static struct fontexec_entry *fnt_exec = 0;       /* pointer to table of font
                                                     executive entries       */

IGRboolean FEadd_font(msg,typeface,bodysize,aspect,rotation,slant,
                      charmap,flags,rangecount,rangespec,font_id)

IGRlong             *msg;            /* completion code                 */
char                *typeface;       /* typeface used to create font    */
Real64              bodysize;        /* bodysize; lines per em square   */
Real64              aspect;          /* aspect ratio                    */
Real64              rotation;        /* ccw rotation of characters      */
Real64              slant;           /* ccw slant                       */
char                *charmap;        /* character mapping               */
Int32               flags;           /* misc font specification flags   */
IGRshort            rangecount;      /* number of ranges of characters  */
RangeSpec           *rangespec;      /* range of characters to generate */
FontId              *font_id;        /* identifies font                 */
{
   extern IGRboolean FEcheck_rangespec();
   extern IGRint     FSNewFont();
   extern IGRchar   *strrchr();

   IGRboolean       value;           /* return code                     */
   IGRboolean       reuse;           /* if true, have reused entry      */
   IGRboolean       match;           /* if true, already have entry     */
   IGRshort         i;               /* index counters                  */
   IGRshort         entry = 0;       /* entry to use in font exec       */
   FontSpec         fontspec;        /* specs used to create font       */
   IGRchar          *slash;          /* check for '/' in fontfile name  */
   IGRchar          charmap_filename[PATH_LENGTH];
   IGRchar          typeface_filename[PATH_LENGTH];

   *msg = MSSUCC;
   value = TRUE;
   reuse = FALSE;
   match = FALSE;

   /*
    * search through the table to see if this is a duplicate font
    */

   for (i = 0; i < fe_num_entries; ++i)
   {
      if ((fnt_exec[i].times_used != 0) &&
          (strcmp(typeface,fnt_exec[i].typeface) == 0) &&
          (bodysize == fnt_exec[i].bodysize) &&
          (rotation == fnt_exec[i].rotation) &&
          (flags == fnt_exec[i].flags) &&
          (strcmp(charmap,fnt_exec[i].charmap) == 0) &&
          (slant == fnt_exec[i].slant) &&
          (aspect == fnt_exec[i].aspect) &&
          (rangecount == fnt_exec[i].rangecount) &&
          (FEcheck_rangespec(msg,rangecount,rangespec,fnt_exec[i].rangespec)))
      {
         /*
          * have match, need to increment times used counter
          * and return font id
          */

         ++(fnt_exec[i].times_used);
         *font_id = fnt_exec[i].font_id;
         match = 1;
         break;
      }
   }         /* end if (fnt_exec != 0) */

   if (!match)
   {
      if (fe_num_entries == 0)
      {
         /*
          * first time for Font Executive, need to malloc the memory
          * and set the number of entries to one
          */

         fnt_exec = (struct fontexec_entry *)om$malloc(size = sizeof(struct fontexec_entry));

         if (fnt_exec == 0)
         {
            /*
             * no dynamic memory available -- return failure
             */

            *msg = MSFAIL;
            value = FALSE;
            goto WRAPUP;
         }

         fe_num_entries = 1;
         entry = 0;
      }
      else           /* not first time table used */
      {
         /*
          * search through table to see if there is an entry that
          * is not being used; if so, use that entry
          */

         for (i = 0; i < fe_num_entries; ++i)
         {
            if (fnt_exec[i].times_used == 0)
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

            ++fe_num_entries;

            fnt_exec = (struct fontexec_entry *)om$realloc(ptr = (char *)fnt_exec,
                                                       size = fe_num_entries *sizeof(struct fontexec_entry));

            if (fnt_exec == 0)
            {
               /*
                * no dynamic memory available -- return failure
                */

               *msg = MSFAIL;
               value = FALSE;
               goto WRAPUP;
            }

            entry = fe_num_entries - 1;

         }                       /* end not reuse */
      }                  /* end not first time */

      slash = strrchr(charmap,'/');

      if (slash)
      {
         /*
          * if a path name was specified with the character mapping, then
          * get just the character mapping file name
          */

         ++slash;  /* skip past last slash character to the file name */
         strcpy(charmap_filename,slash);
      }
      else  /* no path included with character mapping file */
      {
         strcpy(charmap_filename,charmap);
      }

      slash = strrchr(typeface,'/');

      if (slash)
      {
         /*
          * if a path name was specified with the typeface, then
          * get just the typeface file name
          */

         ++slash;  /* skip past last slash character to the file name */
         strcpy(typeface_filename,slash);
      }
      else  /* no path included with character mapping file */
      {
         strcpy(typeface_filename,typeface);
      }

      fontspec.typeface = typeface_filename;
      fontspec.bodySize = bodysize;
      fontspec.resFactor = 1.0;
      fontspec.aspect = aspect;
      fontspec.rotation = rotation;
      fontspec.slant = slant;
      fontspec.charMap = charmap_filename;
      fontspec.flags = flags;

      if (FSNewFont(&fontspec,rangespec,font_id) == FS_NO_ERROR)
      {
         /*
          * fill in information for the Font Executive table
          */

         strcpy(fnt_exec[entry].typeface,typeface);
         fnt_exec[entry].bodysize = bodysize;
         fnt_exec[entry].aspect = aspect;
         fnt_exec[entry].rotation = rotation;
         fnt_exec[entry].slant = slant;
         strcpy(fnt_exec[entry].charmap,charmap);
         fnt_exec[entry].flags = flags;
         fnt_exec[entry].font_id = *font_id;
         fnt_exec[entry].times_used = 1;

         fnt_exec[entry].rangecount = rangecount;
         if (rangespec != NULL)
         {
            fnt_exec[entry].rangespec = (RangeSpec *) om$malloc (size =
                                        sizeof(RangeSpec) * rangecount);

            if (fnt_exec[entry].rangespec == 0)
            {
               /*
                * no dynamic memory available -- return failure
                */

               *msg = MSFAIL;
               value = FALSE;
               goto WRAPUP;
            }

            for (i = 0; i < rangecount; ++i)
            {
               fnt_exec[entry].rangespec[i] = rangespec[i];
            }
         }
         else
         {
            fnt_exec[entry].rangespec = NULL;
         }
      }
      else
      {
         --fe_num_entries;
         *msg = FS_CANT_MAKE_FONT;
         value = FALSE;
      }
   }              /* end no match */

WRAPUP:

   return(value);
}

IGRboolean FErm_font(msg,font_id)

IGRlong             *msg;            /* completion code             */
FontId              font_id;         /* font identification number  */
{
   extern IGRint    FSDeleteFont();

   IGRshort         i;               /* index counter             */
   IGRboolean       value;           /* return code               */

   *msg = MSSUCC;
   value = TRUE;

   for (i = 0; i < fe_num_entries; ++i)
   {
      if (font_id == fnt_exec[i].font_id)
      {
         /*
          * have match, check to see if times used counter
          * is one (no one else is using this font)
          */

         if (fnt_exec[i].times_used == 1)
         {
            /*
             * can remove this font from virtual memory
             */

            if (FSDeleteFont(fnt_exec[i].font_id) == FS_NO_ERROR)
            {
               fnt_exec[i].times_used = 0;
            }
            else
            {
               *msg = FS_INVALID_FONT;
            }
         }
         else
         {
            /*
             * other Font Managers are using this font;
             * cannot remove it!
             */

            --fnt_exec[i].times_used;
         }

         break;
      }             /* end have match */
   }          /* end for (i = 0, ...) */

   return(value);
}
