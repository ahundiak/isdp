/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:             GRvalid_string
 
     Abstract:

               This routine determines if a text string is valid; that is,
           if the field numbers are unique, and the begin and end fields
           match properly.
-----
%SC%

  VALUE = GRvalid_string(msg,string,text_length,prev_font,
                         current_font,font_info)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ------------------------------------
    *string       IGRuchar          character string 
    *text_length  IGRshort          length of the text string
    prev_font     IGRshort          previous font at beginning of string
    current_font  IGRshort          current font at beginning of string
    *font_info    struct vfont_entry font information at beginning of
                                     the string
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     --------------- -----------------------------------------
     *msg           IGRlong         completion code

     VALUE (IGRlong) =    MSSUCC    - if successful
                          MSFAIL    - if the begin and end fields don't match
                          MSINARG   - if a field number was used more than once
-----
%MD%

     MODULES INVOKED:   GRfwd_beg_esc_seq

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  03/20/87 : Design date.
        WBC  03/20/87 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine determines if a text string is valid.  A valid
text string's fields have unique field numbers and the begin and end
fields match correctly.
----*/
/*EH*/

#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "grimport.h"
#include "fontdef.h"
#include "font.h"

IGRboolean GRvalid_string(msg,string,text_length,prev_font,
                          current_font,font_info)

IGRlong            *msg;           /* completion code                      */
IGRuchar           *string;        /* character string                     */
IGRshort           *text_length;   /* length of the text string            */
IGRshort           prev_font;      /* previous font at beginning of string */
IGRshort           current_font;   /* current font at beginning of string  */
struct vfont_entry *font_info;     /* font information at beginning of     */
                                   /* the string                           */

{
    extern IGRshort    GRfwd_beg_esc_seq(); /* function to find specified    */
                                            /* escape sequence(s)            */

    struct vfont_entry cur_font_info;       /* current font information      */
    IGRshort           num_chars;           /* number of esc. seq. chars     */
    IGRshort           beg_esc;             /* index of beginning of esc. seq*/
    IGRshort           index;
    IGRshort           delimiters;          /* represents the number of open */
                                            /* fields; this should never be  */
                                            /* negative (an end field without*/
                                            /* a beginning) and should equal */
                                            /* zero if all fields are matched*/
    IGRchar            esc_chars[2];        /* esc. seq. chars to search for */
    IGRuchar           field_nums[256];     /* table of field numbers that   */
                                            /* have been used                */
    IGRboolean         status;              /* return value                  */
    IGRlong            temp_msg;

    *msg = MSSUCC;
    status = TRUE;
    cur_font_info = *font_info;
    num_chars = 2;
    esc_chars[0] = 'F';
    esc_chars[1] = 'E';
    delimiters = 0;

    for (index = 0; index < 256; field_nums[index] = 0, ++index);

    /*
     *  Search the text string for begin or end field escape sequences.  When a
     *  field is encountered, check the field number to ensure it's unique.
     *  Also check the begin and end fields to make sure they match correctly
     *  (must have a begin field before an end field and each field must be
     *   terminated).
     */

    index = 0;

    while (index < *text_length)
    {
        if (GRfwd_beg_esc_seq(&temp_msg,string,text_length,&num_chars,
                              esc_chars,NULL,&index,&prev_font,
                              &current_font,&cur_font_info,&beg_esc))
        {
            if (string[beg_esc + 1] == 'F')  /* begin field esc. seq. */
            {
                if (field_nums[(IGRuchar)string[beg_esc + 2]])
                {
                    /*
                     *  this field number has already been used; error
                     */

                    *msg = MSINARG;
                    status = FALSE;
                    break;
                }
                else
                {
                    /*
                     *  identify this field number as being used and increment
                     *  field delimiter balance
                     */

                    field_nums[(IGRuchar)string[beg_esc + 2]] = 1;
                    ++delimiters;
                    index = beg_esc + 3;
                }
            }
            else    /* an end field escape sequence was found */
            {
                --delimiters;  /* decrement the field delimiter balance */

                if (delimiters < 0)
                {
                    *msg = MSFAIL;
                    status = FALSE;
                    break;
                }
                index = beg_esc + 1;
            }
        }
        else  /* there are no more begin or end fields in the string */
        {
            break;
        }
        ++index;
    }

    /*
     *  make sure the begin and end fields are balanced (delimiter should = 0)
     */

    if ((status) && (delimiters))
    {
        *msg = MSFAIL;
        status = FALSE;
    }
    return(status);
}
