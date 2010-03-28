/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRtext_eol
 
     Abstract:
                This routine finds the number of bytes from the specified
             position in the text string to the next linefeed escape sequence
             or the end of the text string.
-----
%SC%

  VALUE = GRtext_eol_chars(msg,text_string,text_length,
                           start_position,num_chars)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ---------------------------------------
    *text_string    IGRuchar        entire text string
    *text_length    IGRshort        length of text string
    *start_position IGRshort        initial position in the text string
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *msg           IGRlong          completion code
   *num_chars     IGRshort         number of bytes from the start position
                                   to the next linefeed escape sequence or
                                   the end of the text string
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
        
        WBC  06/08/88 : Design date.
        WBC  06/08/88 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
  This routine finds the number of bytes from the specified
position in the text string to the next linefeed escape sequence
or the end of the text string.
----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gotextdef.h"
#include "msdef.h"

IGRboolean GRtext_eol(msg,text_string,text_length,start_position,num_chars)

IGRlong             *msg;                /* completion code               */
IGRuchar            *text_string;        /* entire text string            */
IGRshort            *text_length;        /* length of text string         */
IGRshort            *start_position;     /* start position in text string */
IGRshort            *num_chars;          /* number of chars. moved past   */

{
    IGRboolean     multi_mode;         /* skip single or multiple esc seq   */
    IGRshort       i;                  /* index counter                     */
    IGRshort       num_esc_chars;      /* number of chars in the esc seq(s) */

    *msg = MSSUCC;
    i = *start_position;
    *num_chars = 0;
    multi_mode = TRUE;

    /*
     *  find next linefeed escape sequence or the end of the text string
     */

    while ((i < *text_length) &&
           ((text_string[i] != ESC) ||
            (text_string[i + 1] != LINEFEED)))
    {
        if (GRfwd_esc_seq(msg,text_string,text_length,
                          &multi_mode,&i,&num_esc_chars))
        {
            i += num_esc_chars;
        }
        else   /* displayable char */
        {
            if (text_string[i] == ESC)     /* two consecutive esc chars */
            {
                i += 2;
            }
            else
            {
                i++;
            }
        }
    }     /* end while statement */
    *num_chars = i - *start_position;

    return(TRUE);
}
