/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRupdcolorform
 
     Abstract:

      This function will take a valid color value and update the active color
form.
-----
%SC%

     VALUE =  GRupdcolorform(msg,active_color,num_colors,form_ptr)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------
     active_color IGRshort unsigned   active color parameter (logical number)
     num_colors   IGRshort            number of buttons on the color palette
     form_ptr     Form                pointer to the form to be updated
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        return code
                                    MSSUCC    - if successful
                                    MSFAIL    - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:
     methods:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  07/31/87 : Design date.
        WBC  07/31/87 : Creation date.
        WBC  06/19/89 : Updated to work with c-based forms.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
      This function will take a valid color value and update the
active color form.
----*/
/*EH*/

#include "coimport.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "adpdef.h"
#include "FI.h"
#include "msdef.h"

IGRint GRupdcolorform(msg,active_color,num_colors,form_ptr)

IGRlong           *msg;        /* return code                            */
IGRushort         active_color;/* active color parameter (logical number)*/
IGRshort          num_colors;  /* number of buttons on the color palette */
Form              form_ptr;    /* pointer to the form to be updated      */

{
    *msg = MSSUCC;

    /*
     * need to push the active color button on the color form's palette if
     * the active color is not background (active_color == 0); if the active
     * color is background, need all buttons on the palette to be popped up
     */

    if (active_color)
    {
        /*
         * if the active color number is greater than the number of
         * color buttons displayed, must "wrap around" the active color
         * to one of the color buttons
         */

        active_color %= num_colors;

        /*
         * if the active color is a multiple of the number of color buttons,
         * must set active color to the number of color buttons so the last
         * color button will be pushed
         */

        if (!active_color)
        {
            active_color = num_colors;
        }
        FIg_set_state_on(form_ptr,active_color + GRCOLOR_PALETTE_LABEL);
    }
    else
    {
        /*
         * push the background color button
         */

        FIg_set_state_on(form_ptr,GRCOLOR_BACKGROUND_BUTTON);
    }
    return(TRUE);
}
