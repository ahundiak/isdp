/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRvertical_ss_move
 
     Abstract:  This routine returns the height of the vertical stroke
                start move of a text string.
-----
%SC%

     VALUE =  GRvertical_ss_move(msg,text_string,text_length,
                                 text_height,v_move)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                   DESCRIPTION
     ----------   ------------     -------------------------------------
     *text_string IGRuchar         text string
     *text_length IGRshort         number of bytes in text string
     text_height  IGRdouble        text height at the beginning of the
                                   text string
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -------------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
     *v_move      IGRdouble       stroke start vertical move

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: 
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
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
  This routine returns the height of the vertical stroke start
move of a specified text string.
----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "OMmacros.h"
#include "gotextdef.h"

#argsused
IGRboolean GRvertical_ss_move(msg,text_string,text_length,text_height,v_move)

IGRlong              *msg;         /* return code                          */
IGRuchar             *text_string; /* text string                          */
IGRshort             *text_length; /* number of bytes in the text string   */
IGRdouble            text_height;  /* text height at the beginning of the  */
                                   /* text string                          */
IGRdouble            *v_move;      /* stroke start vertical move           */

{
    /*
     *  copy the stroke start move values of the text string into the
     *  horizontal and vertical move parameters
     */

    if ((*text_length > 9) &&
        (text_string[0] == ESC))
    {
        if (text_string[1] == 'j')
        {
            OM_BLOCK_MOVE(&text_string[2],v_move,8);
            *v_move = -(*v_move) * text_height;
        }
        else if (text_string[1] == 'J')
        {
            if ((*text_length > 19) &&
                (text_string[10] == ESC) &&
                (text_string[11] == 'j'))
            {
                OM_BLOCK_MOVE(&text_string[12],v_move,8);
                *v_move = -(*v_move) * text_height;
            }
            else
            {
                *v_move = 0.0;
            }
        }
        else
        {
            *v_move = 0.0;
        }
    }
    else
    {
        *v_move = 0.0;
    }
    return(TRUE);
}
