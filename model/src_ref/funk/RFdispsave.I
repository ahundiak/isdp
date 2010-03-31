class implementation Root;

#include <stdio.h>
#include <FI.h>
#include "igrtypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
 
/* indices for the on and off symbols in GRbar.sym */
#define ON_SYMBOL1               20
#define OFF_SYMBOL1              20
#define ACTIVE_SYMBOL1           20
#define INACTIVE_SYMBOL1         20
 

IGRint rfDisplaySaveBtn(on)
IGRint on;
{
    IGRint outline_color, fill_color, filled_index = -1, outline_index = -1;
    /* command key for the Toggle Save command */
    static char SAVE_CMD[] = "EXSvFl" ;
   
    if (on)
    {
        outline_index = ACTIVE_SYMBOL1;
        outline_color = FI_BLUE; 
    }
    else
    {
        outline_index = ACTIVE_SYMBOL1;
        outline_color = FI_BLACK; 
    }
 
    GRcustom_hilite_button(SAVE_CMD, 1, filled_index, fill_color,
                           outline_index, outline_color);
 
    return(TRUE);
}

end implementation Root;
