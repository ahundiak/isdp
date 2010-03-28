/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRget_field_len
 
     Abstract:  This routine returns the length in bytes of the specified
                field.
-----
%SC%

     VALUE =  GRget_field_len(msg,text_string,text_length,beg_field,
                              prev_font,current_font,font_flags,field_length)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     *text_string IGRuchar         text string
     *text_length IGRshort         number of bytes in text string
     *beg_field   IGRshort         position in string field begins
     prev_font    IGRshort         previous font at beg_field
     current_font IGRshort         current font at beg_field
     font_flags   IGRint           indicates font type at beg_field
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -------------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *field_length IGRshort       number of bytes in the field

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: GRfwd_esc_seq

-----
%NB%

     NOTES:
-----

%CH%
     CHANGE HISTORY:
        
        DEK  11/30/87 : Design date.
        DEK  11/30/87 : Creation date.
        DEK  06/10/88 : Included 16-bit characters.
        WBC  01/03/89 : Added the font_flags argument to support
                        8-bit fonts.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine returns the length in bytes of the specified field.
----*/
/*EH*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "grimport.h"
#include "OMmacros.h"
#include "fontmacros.h"

IGRboolean GRget_field_len(msg,text_string,text_length,beg_field,
                           prev_font,current_font,font_flags,field_length)

IGRlong             *msg;            /* completion code                      */
IGRuchar            *text_string;    /* text string                          */
IGRshort            *text_length;    /* number of bytes in the text string   */
IGRshort            *beg_field;      /* position in string field begins      */
IGRshort            prev_font;       /* indicates previous font at beg_field */
IGRshort            current_font;    /* indicate font at beg_field           */
IGRint              font_flags;      /* indicates font type at beg_field     */
IGRshort            *field_length;   /* length in bytes of field             */
{
    extern IGRboolean   GRfwd_esc_seq();    /* returns # bytes in escape seq */

    struct vfont_entry  font_info;          /* current font information      */
    IGRboolean          multi_mode;         /* skip single/multiple esc seq  */
    IGRuchar            field_nest;         /* current field nesting         */
    IGRuchar            begin_nest;         /* holder for save field nesting */
    IGRshort            num_esc_chars;      /* # chars in the escape seq(s)  */
    IGRshort            position;           /* position to calculate length  */
    IGRshort            s_hold;             /* stores a short from the string*/

    /*
     * initialization
     */

    *msg = MSSUCC;
    multi_mode = FALSE;            /* skip only one escape sequence */
    field_nest = 0;
    begin_nest = 0;
    position = *beg_field + 4;

    do
    {
       if (GRfwd_esc_seq(msg,text_string,text_length,&multi_mode,
                         &position,&num_esc_chars))
       {
          if (text_string[position + 1] == 'F')
          {
             ++field_nest;
          }
          else if (text_string[position + 1] == 'E')
          {
             if (field_nest == begin_nest)
             {
                break;
             }

             --field_nest;
          }
          else if (text_string[position + 1] == 'f')
          {
             /*
              * a change font escape sequence; must find the font type
              */

             OM_BLOCK_MOVE(&(text_string[position + 2]),&s_hold,2);

             font$get_info(msg = msg,
                           font_num = &s_hold,
                           font_info = &font_info);

             prev_font = current_font;
             current_font = s_hold;

             font_flags = font_info.flags;
          }
          else if (text_string[position + 1] == 'p' && 
                   text_string[position + 2] & POP_FONT)
          {
             if (prev_font != -1)
             {
                current_font = prev_font;

                font$get_info(msg = msg,
                              font_num = &current_font,
                              font_info = &font_info);

                font_flags = font_info.flags;
             }
          }

          position += num_esc_chars;
       }
       else
       {
          if (font_flags & SIXTEEN_BIT)
          {
             position += 2;
          }
          else
          {          
             ++position;
          }
       }
    } while (position < *text_length);

    *field_length = position - *beg_field;

    return(TRUE);
}
