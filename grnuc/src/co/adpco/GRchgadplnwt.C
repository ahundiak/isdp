/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRchg_adp_line_weight
 
     Abstract:

      This function updates the weight of the line gadget on the
      SetADPWeight form.
-----
%SC%

     VALUE =  GRchg_adp_line_weight(form_label,label,value,form_ptr)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------
     form_label    int                form label
     label         int                label of the gadget whose data has
                                      changed
     value         double             return value of the gadget
     form_ptr      Form               pointer to the form whose gadget was
                                      updated
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
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
        
        WBC  06/21/89 : Design date.
        WBC  06/21/89 : Creation date.
        dhm  07/13/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
  This function updates the weight of the line gadget on the
SetADPWeight form.
----*/
/*EH*/

#include "coimport.h"
#include "FI.h"
#include "adpdef.h"

#argsused
void GRchg_adp_line_weight(form_label,label,value,form_ptr)

int form_label;  /* form label                                   */
int label;       /* label of the gadget whose data has changed   */
double value;    /* return value of the gadget                   */
Form form_ptr;   /* pointer to the form whose gadget was updated */
{
    FIg_erase(form_ptr,GRWEIGHT_LINE);
    FIg_set_line_weight(form_ptr,GRWEIGHT_LINE,(IGRint)value);
    FIg_display(form_ptr,GRWEIGHT_LINE);
}
