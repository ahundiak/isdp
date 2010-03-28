/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRupdweightform
 
     Abstract:

      This function will take a valid line weight value and update the
active line weight form.
-----
%SC%

     VALUE =  GRupdweightform(msg,active_weight,form_ptr)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------
     active_weight IGRchar unsigned   active line weight parameter
     form_ptr      Form               pointer to form to be updated
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
        
        WBC  08/06/87 : Design date.
        WBC  08/06/87 : Creation date.
        WBC  06/19/89 : Update to change c-based forms.
        dhm  07/13/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
      This function will take a valid line weight value and update
the active line weight form.
----*/
/*EH*/

#include "coimport.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "adpdef.h"
#include "FI.h"
#include "msdef.h"

IGRint GRupdweightform(msg,active_weight,form_ptr)

IGRlong           *msg;          /* return code                   */
IGRuchar          active_weight; /* active line weight parameter  */
Form              form_ptr;      /* pointer to form to be updated */
{
    IGRchar       weight[10];

    *msg = MSSUCC;

    /*
     *  must change the line gadget's weight on the form
     */

    FIg_erase(form_ptr,GRWEIGHT_LINE);
    FIg_set_line_weight(form_ptr,GRWEIGHT_LINE,(IGRint)active_weight);
    FIg_display(form_ptr,GRWEIGHT_LINE);

    /*
     *  update the weight slider and the weight number field on the form
     */

    FIg_set_value(form_ptr,GRWEIGHT_SLIDER,(double)active_weight);
    sprintf(weight,"%d",(IGRint)active_weight);
    FIfld_set_text(form_ptr,GRWEIGHT_FIELD,0,0,weight,FALSE);

    return(TRUE);
}
