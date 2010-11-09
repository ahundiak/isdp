/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRprocess_adp
 
     Abstract:

      This function processes input from the Active Drawing Parameters form.
-----
%SC%

     VALUE =  GRprocess_adp(form_label,label,value,form_ptr)
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
        
        WBC  06/09/89 : Design date.
        WBC  06/09/89 : Creation date.
        dhm  07/13/92 : ANSI conversion.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
      This function processes input from the Active Drawing
Parameters form.
----*/
/*EH*/

#include "coimport.h"
#include "FI.h"
#argsused
void GRprocess_adp(

int form_label,  /* form label                                   */
int label,       /* label of the gadget whose data has changed   */
double value,    /* return value of the gadget                   */
Form form_ptr)   /* pointer to the form whose gadget was updated */
{
}
