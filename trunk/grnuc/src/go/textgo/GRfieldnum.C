/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRfield_num
 
     Abstract:

        This routine determines what field number needs to be used
     in the next set field escape sequence.
-----
%SC%

  VALUE = GRfield_num(msg,text_string,text_length,field_num)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          text string to examine
    *text_length  IGRshort          length of text string
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     ---------------   --------------------------------------
   *field_num     IGRuchar          number of field to use

     VALUE (IGRlong) = TRUE
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
        
        DEK  02/04/87 : Design date.
        DEK  02/04/87 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine determines what field number needs to be used in
the next set field escape sequence.
----*/
/*EH*/

#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "gotextdef.h"
#include "grimport.h"

IGRboolean GRfield_num(msg,text_string,text_length,field_num)

IGRlong             *msg;               /* completion code         */
IGRuchar            *text_string;       /* text string             */
IGRshort            *text_length;       /* length of text string   */
IGRuchar            *field_num;         /* field number to use     */
{
    IGRshort i;

    /*
     * initialization
     */

    *msg = MSSUCC;
    *field_num = 0;

    for (i = 0; i < *text_length; ++i)
    {
        if (text_string[i] == ESC)
        {
            if (text_string[i + 1] == ESC)
            {
                ++i;                         /* skip over ESC ESC */
            }
            else if (text_string[i + 1] == 'F')
            {
                i += 3;                      /* skip over set field */
                ++(*field_num);
            }
        }
    }
    return(TRUE);
}
