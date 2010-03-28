/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRodd_esc_chars
 
     Abstract:
                This routine moves backward past consecutive escape characters
                in a text string.  If the number of consecutive escape
                characters is odd, the return code will be TRUE.  Otherwise
                the return code will be FALSE.  The number of consecutive
                escape characters will be returned.
-----
%SC%

  VALUE = GRodd_esc_chars_chars(msg,text_string,start_position,num_escapes)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ---------------------------------------
    *msg            IGRlong          completion code
    *text_string    IGRuchar         entire text string
    start_position  IGRshort         beginning position to search backwards
                                     for consecutive escape characters
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *num_escapes   IGRshort         total number of consecutive escape
                                   characters moving backward from the
                                   start position
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
        
        WBC  01/30/86 : Design date.
        WBC  01/30/86 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine moves backward past consecutive escape characters.
If the number of consecutive escape characters is odd, the return
code will be TRUE; otherwise it will be FALSE.  The number of
consecutive escape characters will be returned.
----*/
/*EH*/

#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"
#include "grimport.h"

IGRboolean GRodd_esc_chars(msg,text_string,start_position,num_escapes)

IGRlong             *msg;                /* completion code               */
IGRuchar            *text_string;        /* entire text string            */
IGRshort            start_position;      /* start position in text string */
IGRshort            *num_escapes;        /* number of cons. escape chars. */
{
    IGRboolean       value;              /* return value                  */

    *msg = MSSUCC;
    *num_escapes = 0;

    /*
     *  loop backwards past consecutive escape characters until the beginning
     *  of the text string or a non-escape character is encountered
     */

    for (; start_position >= 0 && text_string[start_position] == ESC; --start_position, ++(*num_escapes));

    if (*num_escapes & 1)
    {
        value = TRUE;   /* odd number of consecutive escape characters  */
    }
    else
    {
        value = FALSE;  /* even number of consecutive escape characters */
    }
    return(value);
}
