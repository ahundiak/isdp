/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRjust_vertical
 
     Abstract:

               This routine may insert, replace or delete a vertical
           justification move esacpe sequence in a text string.  Sufficient
           memory must be allocated by the calling routine to accommodate
           an additional escape sequence.
-----
%SC%

  VALUE = GRjust_vertical(msg,text_string,text_length,text_just,
                          text_height,extents,num_positions,positions)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   --------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    *text_length  IGRshort          length of text string
    text_just     IGRshort          text justification
    text_height   IGRdouble         text height
    *extents      struct extents    unjustified extents of the text string
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
                        GRvertical_just_mv
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  11/11/87 : Design date.
        WBC  11/11/87 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine may insert, replace or delete a vertical
justification move esacpe sequence in a text string.  Sufficient
memory must be allocated by the calling routine to accommodate
an additional escape sequence.
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

IGRboolean GRjust_vertical(msg,text_string,text_length,text_just,
                           text_height,extents,num_positions,positions)

IGRlong                *msg;
IGRuchar               *text_string; /* entire text string                   */
IGRshort               *text_length; /* length of the text string            */
IGRshort               text_just;    /* text justification                   */
IGRdouble              text_height;  /* text height                          */
struct extents         *extents;     /* unjustified extents of text string   */
IGRint                 num_positions;/* # of positions in string to update   */
IGRshort               *positions[]; /* array of positions in text string to */
                                     /* update when the size of the text     */
                                     /* string is changed; a NULL pointer may*/
                                     /* be passed in if an update isn't      */
                                     /* desired                              */
{
    extern IGRboolean  GRvertical_just_mv();

    IGRdouble   v_move;                 /* vertical justification move      */
    IGRlong     temp_msg;               /* return code                      */
    IGRint      i;

    *msg = MSSUCC;

    /*
     *  find the vertical justification move for the text string
     */

    GRvertical_just_mv(&temp_msg,text_just,text_height,extents,&v_move);

    if (v_move)
    {
        /*
         *  if the vertical move escape sequence has already been inserted into
         *  the text string, simply insert the vertical move value into the
         *  appropriate position.  Otherwise, insert the vertical move escape
         *  sequence into the text string and insert the vertical move value
         *  into the appropriate position
         */

        if (*text_length > 9 &&
            text_string[0] == ESC &&
            text_string[1] == 'J')
        {
            if (*text_length < 20 ||
                text_string[10] != ESC ||
                text_string[11] != 'j')
            {
                OM_BLOCK_MOVE(&text_string[10],
                              &text_string[20],
                              (IGRint)(*text_length - 10));

                *text_length += 10;

                text_string[10] = ESC;
                text_string[11] = 'j';

                /*
                 *  if requested, update the positions in the text string
                 */

                for (i = 0; i < num_positions; ++i)
                {
                    if (*(positions[i]) >= 10)
                    {
                        *(positions[i]) += 10;
                    }
                }
            }

            OM_BLOCK_MOVE(&v_move,&text_string[12],8);
        }
        else if (*text_length < 10 ||
                text_string[0] != ESC ||
                 text_string[1] != 'j')
        {
            OM_BLOCK_MOVE(text_string,
                          &text_string[10],
                          (IGRint)(*text_length));

            *text_length += 10;

            text_string[0] = ESC;
            text_string[1] = 'j';

            OM_BLOCK_MOVE(&v_move,&text_string[2],8);

            /*
             *  if requested, update the positions in the text string
             */

            for (i = 0; i < num_positions; ++i)
            {
                *(positions[i]) += 10;
            }
        }
        else
        {
            /*
             *  vertical move escape sequence has already been inserted
             *  into beginning of text string;  simply insert the move value
             */

            OM_BLOCK_MOVE(&v_move,&text_string[2],8);
        }
    }
    else
    {
        /*
         *  v_move is 0;  if vertical move escape sequence is in the text
         *  string, remove it. if not, do nothing.
         */

        if (*text_length > 9 &&
            text_string[0] == ESC &&
            text_string[1] == 'J')
        {
            if (*text_length > 19 &&
                text_string[10] == ESC &&
                text_string[11] == 'j')
            {
                /*
                 *  remove the escape sequence
                 */

                *text_length -= 10;

                OM_BLOCK_MOVE(&text_string[20],
                              &text_string[10],
                              (IGRint)(*text_length - 10));

                /*
                 *  if requested, update the positions in the text string
                 */

                for (i = 0; i < num_positions; ++i)
                {
                    if (*(positions[i]) >= 20)
                    {
                        *(positions[i]) -= 10;
                    }
                }
            }
        }
        else if (*text_length > 9 &&
                 text_string[0] == ESC &&
                 text_string[1] == 'j')
        {
            /*
             *  remove the escape sequence
             */

            *text_length -= 10;

            OM_BLOCK_MOVE(&text_string[10],text_string,
                          (IGRint)(*text_length));

            /*
             *  if requested, update the positions in the text string
             */

            for (i = 0; i < num_positions; ++i)
            {
                if (*(positions[i]) >= 10)
                {
                    *(positions[i]) -= 10;
                }
            }
        }
    }
    return(TRUE);
}
