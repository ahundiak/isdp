/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRfind_position
 
     Abstract:
            This routine finds the actual position in a text string
            given a line number and a user position.  The actual
            position includes any escape sequences or linefeeds in
            the text string.
-----
%SC%

  VALUE = GRfind_position(msg,text_string,text_length,current_line,
                          user_position,actual_position)
-----
%EN%
 
     ON ENTRY:

        NAME        DATA TYPE                      DESCRIPTION
    ------------   ---------------   ------------------------------------
    *msg           IGRlong           completion code
    *text_string   IGRuchar          entire text string
    *text_length   IGRshort          length of the text string
    *line_num      IGRshort          line number user is on
    *user_position IGRshort          user positon on the current line
                                     (excluding escape sequences)
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
   *actual_position IGRshort      position in text string
                                  (including escape sequences)

   VALUE (IGRlong) =    MSSUCC    - if successful
-----
%MD%

     MODULES INVOKED:   GRfwd_esc_seq

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%
-----

%CH%
     CHANGE HISTORY:
        
        WBC  09/24/86 : Design date.
        WBC  09/24/86 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This routine finds the actual position in the text string
corresponding to the user position in the text string indicated by
the line number the user is on and the position in that line.
----*/
/*EH*/

#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "gotextdef.h"
#include "grimport.h"

IGRboolean GRfind_position(msg,text_string,text_length,line_num,
                           user_position,actual_position)

IGRlong             *msg;                /* completion code        */
IGRuchar            *text_string;        /* entire text string     */
IGRshort            *text_length;        /* length of text string  */
IGRshort            *line_num;           /* line number user is on */
IGRshort            *user_position;      /* position in the line   */
                                         /* user is on             */
IGRshort            *actual_position;    /* position in text string*/
{
    extern IGRshort  GRfwd_esc_seq();

    IGRshort      num_chars;           /* number of characters moved past */
                                       /* in the escape sequence(s)       */
    IGRshort      current_line;
    IGRshort      current_position;    /* position on current line        */
    IGRboolean    multi_mode;          /* skip a single or consecutive    */
                                       /* escape sequences                */
    *msg = MSSUCC;
    *actual_position = 0;
    current_line = 1;
    current_position = 1;
    multi_mode = 1;

    /*
     *  skip any leading escape sequences
     */

    *actual_position = GRfwd_esc_seq(msg,text_string,text_length,&multi_mode,
                                     actual_position,&num_chars);

    /*
     *  move through text string until correct line number and position
     *  in that line are reached
     */

    while (current_line < *line_num || current_position < *user_position)
    {
        if (text_string[*actual_position] == ESC)
        {
            if (text_string[*actual_position + 1] == LINEFEED)
            {
                ++current_line;
                current_position = 1;
            }
            else   /*  there is an escape escape; skip it */
            {
                ++current_position;
            }
            *actual_position += 2;
        }
        else    /* regular character */
        {
            ++current_position;
            ++(*actual_position);
        }

        /*
         *  skip any trailing escape sequences
         */

        *actual_position += GRfwd_esc_seq(msg,text_string,text_length,
                                       &multi_mode,actual_position,&num_chars);
    }
    return(TRUE);
}
