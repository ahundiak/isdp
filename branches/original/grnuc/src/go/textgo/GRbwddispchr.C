/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRbwd_disp_char
 
     Abstract:
                This routine moves forward in a text string searching for 
                the last displayable character in the string before the 
                specified index. If one is found, it's position in the text
                string and a TRUE value is returned. Otherwise, FALSE will
                be returned.
-----
%SC%

  VALUE = GRbwd_disp_char(msg,text_string,end_index,font,font_info,
                          prev_font,char_index)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg            IGRlong          completion code
    *text_string    IGRuchar         entire text string
    *end_index      IGRshort         position in text string to search to
    *font           IGRshort         indicates the text string's initial
                                     font
    *font_info      struct vfont_entry initial font information
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *font          IGRshort        font at char_index
   *font_info     struct vfont_entry font information at char_index
   *prev_font     IGRshort        previous font at char_index
   *char_index    IGRshort        index of last displayable character

   VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:    GRfwd_esc_seq:      move forward over escape
                                             sequence
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:   

-----

%CH%
     CHANGE HISTORY:
        
        DEK  09/12/88 : Design date.
        DEK  09/12/88 : Creation date.
        WBC  01/03/89 : Added the font_flags arguments to support
                        8-bit fonts.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
----------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
----------------------------------------------------------------------
     This routine moves forward in a text string searching for the 
last displayable character in the string before the specified index. 
If one is found, it's position in the text string and a TRUE value is 
returned. Otherwise, FALSE will be returned.
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "OMmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"

IGRboolean GRbwd_disp_char(msg,text_string,end_index,font,font_info,
                           prev_font,char_index)

IGRlong             *msg;          /* completion code                        */
IGRuchar            *text_string;  /* entire text string                     */
IGRshort            *end_index;    /* position in text string to search to   */
IGRshort            *font;         /* current font                           */
struct vfont_entry  *font_info;    /* font information                       */
IGRshort            *prev_font;    /* previous font                          */
IGRshort            *char_index;   /* index of the first deleteable char     */
                                   /* that precedes the char at end_index    */

{
    extern IGRshort  GRfwd_esc_seq();/* move forward over an escape sequence */

    struct vfont_entry prev_font_info; /* previous font information          */
    struct vfont_entry tmp_font_info;  /* temporary font information         */
    IGRboolean       value;        /* functional return value                */
    IGRboolean       multi_mode;   /* go past one or several escape sequences*/
    IGRboolean       font_changed; /* tells if there was a change or pop font*/
                                   /* esc seq since the last displayable char*/
    IGRshort         tmp_font;
    IGRshort         i;            /* index counter                          */
    IGRshort         esc_seq_chars;/* number of characters in the escape seq */

    *msg = MSSUCC;
    i = 0;
    value = FALSE;
    multi_mode = FALSE;
    font_changed = FALSE;
    *prev_font = -1;
    *char_index = 0;

    while (i < *end_index)
    {
       /*
        *  if a displayable char is found (which includes escape and linefeed
        *  escape sequences), save the index of the char
        */

       if (GRfwd_esc_seq(msg,text_string,end_index,&multi_mode,&i,
                         &esc_seq_chars))
       {
          if (text_string[i + 1] == 'f')
          {
              /*
               * a change font escape sequence; must find the
               * font type
               */

              OM_BLOCK_MOVE(&(text_string[i + 2]),&tmp_font,2);

              font$get_info(msg = msg,
                            font_num = &tmp_font,
                            font_info = &tmp_font_info);
              font_changed = TRUE;
          }
          else if ((text_string[i + 1] == 'p') &&
                   (text_string[i + 2] & POP_FONT))
          {
              if (*prev_font != -1)
              {
                 tmp_font = *prev_font;
                 tmp_font_info = prev_font_info;
                 font_changed = TRUE;
              }
          }

          i += esc_seq_chars;
       }
       else   /* a displayable character */
       {
           *char_index = i;
           value = TRUE;

           if (font_changed)
           {
              *prev_font = *font;
              prev_font_info = *font_info;
              *font = tmp_font;
              *font_info = tmp_font_info;
              font_changed = FALSE;
           }

           if (text_string[i] == ESC)
           {
              i += 2;  /* ESC ESC or ESC LINEFEED char */
           }
           else  /* regular displayable char */
           {
              if (font_info->flags & SIXTEEN_BIT)
              {
                  i += 2;
              }
              else
              {
                  ++i;
              }
           }
       }
    }          /* end while */

    return(value);
}
