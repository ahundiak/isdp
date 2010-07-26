/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRfind_esc_char
 
     Abstract:
                This routine searches forward in a text string for an
                escape character.
-----
%SC%

  VALUE = GRfind_esc_char(msg,text_string,text_length,flags,num_chars)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ---------------------------------------
    *msg           IGRlong           completion code
    *text_string   IGRuchar          text string
    text_length    IGRshort          length of text string (in bytes)
    flags          IGRint            indicates character code type -
                                     7, 8 or 16 bit
                                     (#defines for flag are in fontdef.h)
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *num_chars     IGRshort        number of consecutive non-escape
                                  characters

   VALUE (IGRlong) =    MSSUCC         - if successful
                        ESCAPE_TYPE    - if two consecutive escape characters
                                         are found
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
        
        WBC  11/04/87 : Design date.
        WBC  11/04/87 : Creation date.
        DEK  06/10/88 : Included 16-bit characters.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine searches forward in a text string for an escape
character.  The number of consecutive non-escape characters is
returned in the argument num_chars.  The text string is searched
until an escape character is found or the end of the text string
is reached.  If two consecutive escape characters are found,
num_chars is incremented by one character and msg is set to
ESCAPE_TYPE.
----*/
/*EH*/

#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "dpdef.h"
#include "fontdef.h"
#include "grimport.h"

IGRshort GRfind_esc_char(msg,text_string,text_length,flags,num_chars)

IGRlong             *msg;                /* completion code                  */
IGRuchar            *text_string;        /* text string                      */
IGRshort            text_length;         /* length of text string (in bytes) */
IGRint              flags;               /* indicates character code tye -   */
                                         /* 7, 8 or 16 bit text              */
                                         /* (#defines for flags in fontdef.h)*/
IGRshort            *num_chars;          /* number of consecutive non-escape
                                            characters                       */
{
    IGRshort        i;                   /* index counter                    */

    *msg = MSSUCC;

    /*
     *  find the number of bytes required to represent each character;
     *  search the text string for the first encountered escape character
     */

    if (!(flags & SIXTEEN_BIT))   /* 7 or 8 bit character code */
    {
        for (*num_chars = 0; *num_chars < text_length && *text_string; (*num_chars)++)
        {
            if (*text_string++ == ESC)
            {
                if (*text_string == ESC)
                {
                    /*
                     *  this substring ends with an escape character
                     */

                    (*num_chars)++;
                    *msg = ESCAPE_TYPE;
                }
                break;
            }
        }
    }
    else   /* 16 bit character code => 2 bytes per character */
    {
        *num_chars = 0;
        i = 0;

        while (i < text_length && text_string[i] != ESC)
        {
           ++(*num_chars);
           i += 2;
        }
    }
    return(TRUE);
}
