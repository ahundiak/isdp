/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRvalid_cursor_position
 
     Abstract:
               This routine determines if the specified index is a valid cursor
               position and if it isn't, finds the valid cursor position that
               immediately precedes the specified index.
-----
%SC%

  VALUE = GRvalid_cursor_position(msg,text_string,text_length,prev_font,
                                  current_font,font_flags,target_index,
                                  cursor_index)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ----------------------------------------
    *msg          IGRlong            completion code
    *text_string  IGRuchar           entire text string
    text_length   IGRshort           length of te text string
    prev_font     IGRshort           previous font in string
    current_font  IGRshort           current font in string
    font_flags    IGRint             info about the current font
    target_index  IGRshort           index to find valid cursor position
                                     at or before
    *cursor_index  IGRshort          current index of a valid cursor position
                                     (if this is not known, send index = 0)
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *cursor_index  IGRshort        index of valid cursor position at or
                                  before the specified index

   VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES: 
-----

%CH%
     CHANGE HISTORY:
        
        WBC  08/16/88 : Design date.
        WBC  08/16/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine determines if the specified index is a valid cursor
position and if it isn't, finds the valid cursor position that
immediately precedes the specified index.
----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gotextdef.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"

#argsused
IGRint GRvalid_cursor_position(msg,text_string,text_length,prev_font,
                               current_font,font_flags,target_index,
                               cursor_index)

IGRlong             *msg;          /* return code                            */
IGRuchar            *text_string;  /* entire text string                     */
IGRshort            text_length;   /* length of the text string              */
IGRshort            prev_font;     /* previously used font in string         */
IGRshort            current_font;  /* current font in string                 */
IGRint              font_flags;    /* info about the current font            */
IGRshort            target_index;  /* index to find valid cursor position    */
                                   /* at or before                           */
IGRshort            *cursor_index; /* Input:  current cursor position index  */
                                   /* (initialize to 0 if not known)         */
                                   /* Output:  index of valid cursor position*/
                                   /* at or before the target index          */

{
    IGRlong          temp_msg;
    IGRshort         temp_index;

    temp_index = 0;
    /*
     * if the current cursor index is greater than the target index, must
     * initialize the current cursor index to 0 since we can only move forward
     * through a text string; move forward from one valid cursor position to
     * the next to the target position
     */

    if (*cursor_index > target_index)
    {
        *cursor_index = 0;
    }

    while (*cursor_index < target_index)
    {
        temp_index = *cursor_index;

        GRfwd_cursor_position(&temp_msg,text_string,text_length,
                              temp_index,&prev_font,&current_font,
                              &font_flags,cursor_index);
    }

    /*
     * if the last valid cursor position found is past the target position and
     * the original cursor position is not on a stroke start justification
     * move (which is not a valid cursor position - must move past it), return
     * the valid cursor position that precedes the target position
     */

    if ((*cursor_index > target_index) &&
        ((text_string[temp_index] != ESC) ||
         ((text_string[temp_index + 1] != 'j') &&
          (text_string[temp_index + 1] != 'J'))))

    {
        *cursor_index = temp_index;
    }
    return(TRUE);
}
