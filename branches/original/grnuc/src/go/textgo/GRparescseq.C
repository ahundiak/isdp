/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRparse_escape_seqence
 
     Abstract:  This routine removes any extraneous change font
                escape sequences from the text string.
-----
%SC%

     VALUE =  GRparse_escape_sequence(msg,text_string,text_length,
                                      font,prev_font,font_info,start_index,
                                      finish_index)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     *text_string IGRuchar         text string to strip escape sequences
                                   from
     *text_length IGRshort         number of bytes in the unstripped
                                   text string
     font         IGRshort         'active' font at start_index position
     prev_font    IGRshort         previous 'active' font at start index
     *font_info   struct vfont_entry font information at start_index
     start_index  IGRshort         position in string to start searching
     *finish_index IGRshort        position in string to stop searching
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   -----------    -------------------------------------
     *msg         IGRlong        Completion code
                                    - MSSUCC if successful

     *text_string IGRuchar       text string without escape sequences
     *text_length IGRshort       number of bytes in the stripped
                                 text string
     *finish_index IGRshort      index adjusted according to the escape
                                 sequences removed

     VALUE (IGRboolean) = TRUE            - always successful
-----
%MD%

     MODULES INVOKED: 
-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        DEK  10/07/88 : Design date.
        DEK  10/07/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine removes any extraneous escape sequences from the 
text string.
----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "OMmacros.h"
#include "gotextdef.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

IGRboolean GRparse_escape_sequence(msg,text_string,text_length,font,prev_font,
                                   font_info,start_index,finish_index)

IGRlong           *msg;          /* completion code                          */
IGRuchar          *text_string;  /* text string possibly containing esc seqs */
IGRshort          *text_length;  /* number of bytes in the unstripped string */
IGRshort          font;          /* 'active' font at start_index position    */
IGRshort          prev_font;     /* previous 'active' font at start_index    */
struct vfont_entry *font_info;   /* font information at start_index          */
IGRshort          start_index;   /* position in string to start search       */
IGRshort          *finish_index; /* position in string to stop search        */
{
   extern IGRshort      GRfwd_beg_esc_seq();
   extern IGRshort      GRfwd_esc_seq();

   struct vfont_entry   cur_font_info;  /* current font information          */
   IGRshort             i, end_index;
   IGRshort             num_chars;      /* num esc seq chars to search for   */
   IGRchar              esc_chars[2];   /* characters in escape sequences    */
   IGRshort             beg_esc;        /* position in string esc seq begins */
   IGRshort             disp_font;      /* font at the last displayable char */
   IGRshort             disp_position;  /* index after last displayable char */
   IGRshort             font_hold;      /* font number from change font esc  */
   IGRboolean           multi_mode, change_font, pop_font;

   /*
    * initialization
    */

   *msg = MSSUCC;

   i = start_index;        /* initialize loop to desired positions in string */

   change_font = FALSE;
   pop_font = FALSE;
   disp_font = font;
   disp_position = i;
   cur_font_info = *font_info;

   multi_mode = TRUE;
   num_chars = 2;       /* search for change font and pop font esc sequences */
   esc_chars[0] = 'f';
   esc_chars[1] = 'p';
   end_index = *finish_index;

   /*
    * if end index is at an escape sequence, need to increment it past any
    * consecutive escape sequences since change font escape sequences may
    * follow the current position, and it may be possible to remove them
    */

   end_index += GRfwd_esc_seq(msg,text_string,text_length,
                              &multi_mode,&end_index,&num_chars);

   multi_mode = FALSE;

   while (i <= end_index)
   {
      if ((i < end_index) &&
         (GRfwd_esc_seq(msg,text_string,text_length,
                        &multi_mode,&i,&num_chars)))
      {
         if (text_string[i + 1] == 'f')
         {
            OM_BLOCK_MOVE(&text_string[i + 2],&font_hold,(IGRint)2);

            prev_font = font;
            font = font_hold;

            font$get_info(msg = msg,
                          font_num = &font,
                          font_info = &cur_font_info);

            change_font = TRUE;
         }
         else if ((text_string[i + 1] == 'p') &&
                  (text_string[i + 2] & POP_FONT))
         {
            font = prev_font;

            font$get_info(msg = msg,
                          font_num = &font,
                          font_info = &cur_font_info);

            pop_font = TRUE;
         }

         i += num_chars;
      }
      else  /* displayable char */
      {
         /*
          * if a change font escape sequence has been moved past and a pop
          * font has not, see if the current font is the same one as the font
          * at the previous displayable char; may be able to remove the change
          * font escape sequence(s)
          */

         if ((change_font) &&
             (!pop_font) &&
             (font == disp_font))
         {
            /*
             * if a pop font escape sequence follows the the current position
             * before a change font escape sequence, cannot remove the previous
             * change font escape sequence(s) since this may adversely affect
             * the following pop font
             */

            if (GRfwd_beg_esc_seq(msg,text_string,text_length,&num_chars,
                                  esc_chars,NULL,&i,&prev_font,&font,
                                  &cur_font_info,&beg_esc))
            {
               if ((text_string[i + 1] == 'p') &&
                   (text_string[i + 2] & POP_FONT))
               {
                  pop_font = TRUE;
               }
            }

            if (!pop_font)
            {
               while (GRfwd_esc_seq(msg,text_string,text_length,
                                    &multi_mode,&disp_position,&num_chars))
               {
                  if (text_string[disp_position + 1] == 'f')
                  {
                     OM_BLOCK_MOVE(&text_string[disp_position + 4],
                                   &text_string[disp_position],
                                   (IGRint)(*text_length - (disp_position + 4)));

                     *text_length -= 4;
                     end_index -= 4;
                     i -= 4;

                     if (disp_position < *finish_index)
                     {
                        *finish_index -= 4;
                     }
                  }
                  else
                  {
                     disp_position += num_chars;
                  }
               }
            }
         }

         /*
          * check to see if the char is an escape, linefeed or 16 bit char
          */

         if ((text_string[i] == ESC) ||
             (cur_font_info.flags & SIXTEEN_BIT))
         {
            i += 2;
         }
         else  /* 7 or 8 bit char */
         {
            ++i;
         }
         change_font = FALSE;
         pop_font = FALSE;
         disp_font = font;
         disp_position = i;
      }
   }           /* end while loop */

   return(TRUE);
}
