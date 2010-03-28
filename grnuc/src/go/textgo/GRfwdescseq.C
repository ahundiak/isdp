/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRfwd_esc_seq
 
     Abstract:
                This routine moves forward past an escape sequence(s) in a text
                string.  It can move past either a single escape sequence
                or past several consecutive escape sequences until a
                "displayable" character is reached (a linefeed or two
                consecutive escape characters will be considered displayable
                characters here) or the end of the text string is reached.
                The number of characters in the escape sequence(s) is
                returned.  If the start_position is at a "displayable"
                character, zero is returned.
-----
%SC%

  VALUE = GRfwd_esc_seq_chars(msg,text_string,text_length,multi_mode,
                              start_position,num_chars)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ---------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    *text_length  IGRshort          length of text string
    *multi_mode   IGRboolean        0 - move past a single escape sequence
                                    1 - move past consecutive escape
                                        sequences until a displayable char.
                                        or end of string is reached
    *start_position IGRshort        position to move from in text string
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *num_chars     IGRshort         total number of characters moved past in
                                   the text string
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
        
        WBC  01/12/86 : Design date.
        WBC  01/12/86 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine moves forward past either a single escape sequence
(multi_mode = FALSE) or several escape sequences until a
"displayable" character or the end of the text string is reached
(multi_mode = TRUE).  The number of characters in the escape
sequence(s) is returned.  If the start_position is at a displayable
character, zero is returned.
----*/
/*EH*/

#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "grimport.h"

IGRshort GRfwd_esc_seq(msg,text_string,text_length,multi_mode,
                       start_position,num_chars)
IGRlong             *msg;                /* completion code               */
IGRuchar            *text_string;        /* entire text string            */
IGRshort            *text_length;        /* length of text string         */
IGRboolean          *multi_mode;         /* 0 - move past single esc. seq.*/
                                         /* 1 - move past multi. esc. seq.*/
IGRshort            *start_position;     /* start position in text string */
IGRshort            *num_chars;          /* number of chars. moved past   */
{
    IGRshort         i;                  /* index counter                 */

    *msg = MSSUCC;
    i = *start_position;
    *num_chars = 0;

    /*
     *  move over any escape sequence(s)
     */

    if ((i < *text_length) && (text_string[i] == ESC))
    {
        do
        {
            if ((text_string[i + 1] == 'H') ||
                (text_string[i + 1] == 'J') ||
                (text_string[i + 1] == 'j') ||
                (text_string[i + 1] == 'h') ||
                (text_string[i + 1] == 'v') ||
                (text_string[i + 1] == 's') ||
                (text_string[i + 1] == 'x') ||
                (text_string[i + 1] == 'y') ||
                (text_string[i + 1] == 'C'))
            {
                i += 10;
                *num_chars += 10;
            }
            else if ((text_string[i + 1] == 'f') ||
                     (text_string[i + 1] == 'c') ||
                     (text_string[i + 1] == 'F'))
            {
                i += 4;
                *num_chars += 4;
            }
            else if (text_string[i + 1] == 'E')
            {
                i += 2;
                *num_chars += 2;
            }
            else if ((text_string[i + 1] == 'p') ||
                     (text_string[i + 1] == 'w'))
            {
                i += 3;
                *num_chars += 3;
            }
            else if (text_string[i + 1] == 'M')
            {
                i += 20;
                *num_chars += 20;
            }
            else if (text_string[i + 1] == 'm')
            {
               i += 19;
               *num_chars += 19;
            }
            else if ((text_string[i + 1] == ESC) ||
                     (text_string[i + 1] == LINEFEED))
            {
                break; /* the index (*num_chars) is at a displayable char*/
            }
	    else	{	
		*num_chars += 1;
		break;
	   }
        }
        while (*multi_mode && (i < *text_length) && (text_string[i] == ESC));
    }
    return(*num_chars);
}
