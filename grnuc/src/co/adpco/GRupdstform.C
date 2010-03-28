/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRupdstyleform
 
     Abstract:

      This function will take a valid line style value and update the active
line style form.
-----
%SC%

     VALUE =  GRupdstyleform(msg,active_style,form_ptr)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------
     active_style IGRchar unsigned    active line style parameter
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
        dhm  07/13/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
      This function will take a valid line style value and update
the active line style form.
----*/
/*EH*/

#include "coimport.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "adpdef.h"
#include "FI.h"
#include "msdef.h"

IGRint GRupdstyleform(msg,active_style,form_ptr)

IGRlong           *msg;          /* return code                       */
IGRuchar          active_style;  /* active line style                 */
Form              form_ptr;      /* pointer to the form to be updated */
{

    *msg = MSSUCC;

    /*
     * set check mark on for the active line style; since the checklist is
     * a single select group, don't have to erase previous check mark
     */

    FIg_set_state_on(form_ptr,active_style + GRSTYLE_FIRST_CHECKLIST);

    return(TRUE);
}
