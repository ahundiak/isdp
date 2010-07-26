/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRjust_horizontal
 
     Abstract:

               This routine may insert, replace or delete a horizontal
           justification move esacpe sequence in a text string.  Sufficient
           memory must be allocated by the calling routine to accommodate
           an additional escape sequence.
-----
%SC%

  VALUE = GRjust_horizontal(msg,text_string,text_length,text_just,
                            text_width,just_info,num_positions,positions)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    *text_length  IGRshort          length of text string
    text_just     IGRshort          text justification
    text_width    IGRdouble         text width
    *just_info    struct just_info  justification information
    num_positions IGRint            # of positions in text string to update
    *positions[]  IGRshort          array of positions in text string to
                                    update when the size of the text string
                                    is changed; a NULL pointer may be passed
                                    in if an update isn't desired
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------    ----------------  -----------------------------------------
     *text_string  IGRuchar          justified text string
     *text_length  IGRshort          length of justified text string
     *positions[]  IGRshort          updated positions in the text string

     VALUE (IGRlong) =    MSSUCC    - if successful
                          MSFAIL    - if failure
-----
%MD%

     MODULES INVOKED:
                        GRhorizontal_just_mv
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  11/10/87 : Design date.
        WBC  11/10/87 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine may insert, replace or delete a horizontal
justification move esacpe sequence in a text string.  Sufficient
memory must be allocated by the calling routine to accommodate
an additional escape sequence.  The last line of the text string
will be justified using the information in the structure "just_info".
----*/
/*EH*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "ex.h"
#include "gr.h"
#include "igrdp.h"
#include "gotextdef.h"
#include "gotext.h"
#include "OMmacros.h"
#include "grimport.h"

IGRboolean GRjust_horizontal(msg,text_string,text_length,text_just,
                             text_width,just_info,num_positions,positions)

IGRlong                *msg;
IGRuchar               *text_string; /* entire text string                   */
IGRshort               *text_length; /* length of the text string            */
IGRshort               text_just;    /* text justification                   */
IGRdouble              text_width;   /* text width                           */
struct just_info       *just_info;   /* justification information            */
IGRint                 num_positions;/* # of positions in string to update   */
IGRshort               *positions[]; /* array of positions in text string to */
                                     /* update when the size of the text     */
                                     /* string is changed; a NULL pointer may*/
                                     /* be passed in if an update isn't      */
                                     /* desired                              */
{
    extern IGRboolean  GRhorizontal_just_mv();

    IGRdouble   h_move;                 /* horizontal justification move    */
    IGRlong     temp_msg;               /* return code                      */
    IGRint      i;

    *msg = MSSUCC;

    /*
     *  find the horizontal justification move for the last line in the
     *  text string
     */

    GRhorizontal_just_mv(&temp_msg,text_just,text_width,just_info,&h_move);

    if (h_move)  /* horizontal move to be inserted or replaced */
    {
        if (*text_length <= just_info->just_esc_pos + 9 ||
            text_string[just_info->just_esc_pos] != ESC ||
            (text_string[just_info->just_esc_pos + 1] != 'H' &&
             text_string[just_info->just_esc_pos + 1] != 'J'))
        {
            /*
             *  must insert horizontal move escape sequence and
             *  then copy the horizontal move into the
             *  appropriate position
             */

            OM_BLOCK_MOVE(&text_string[just_info->just_esc_pos],
                          &text_string[just_info->just_esc_pos + 10],
                          (IGRint)(*text_length - just_info->just_esc_pos));

            *text_length += 10;

            text_string[just_info->just_esc_pos] = ESC;

            if (just_info->just_esc_pos) /* horizontal move after a linefeed */
            {
                text_string[just_info->just_esc_pos + 1] = 'H';
            }
            else  /* stroke start move */
            {
                text_string[just_info->just_esc_pos + 1] = 'J';
            }

            /*
             *  if requested, update the positions in the text string
             */

            for (i = 0; i < num_positions; ++i)
            {
                if (*(positions[i]) >= just_info->just_esc_pos)
                {
                    *(positions[i]) += 10;
                }
            }
        }

        /*
         *  horizontal move escape sequence has 
         *  been inserted into text string; simply copy
         *  move into appropriate position
         */

        OM_BLOCK_MOVE(&h_move,&text_string[just_info->just_esc_pos + 2],8);
    }
    else
    {
        /*
         *  h_move is 0; if horizontal move escape sequence
         *  is in the string, remove it.  otherwise, do nothing
         */

        if (*text_length > just_info->just_esc_pos + 9 &&
            text_string[just_info->just_esc_pos] == ESC &&
            (text_string[just_info->just_esc_pos + 1] == 'H' ||
             text_string[just_info->just_esc_pos + 1] == 'J'))
        {
            /*
             *  remove the escape sequence
             */

            *text_length -= 10;

            OM_BLOCK_MOVE(&text_string[just_info->just_esc_pos + 10],
                          &text_string[just_info->just_esc_pos],
                          (IGRint)(*text_length - just_info->just_esc_pos));

            /*
             *  if requested, update the position in the text string
             */

            for (i = 0; i < num_positions; ++i)
            {
                if (*(positions[i]) > just_info->just_esc_pos)
                {
                    *(positions[i]) -= 10;
                }
            }
        }
    }
    return(TRUE);
}
