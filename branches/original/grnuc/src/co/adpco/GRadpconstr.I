/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              Intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRadp 
     METHOD NAME:             super_construct
 
     Abstract:

        This routine connects the Active Drawing Parameters super to the
        current module's color table object.
-----
%SC%

     VALUE =  super_construct()
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     VALUE (IGRlong) =    MSSUCC    - if successful
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
        
        WBC  08/12/88 : Design date.
        WBC  08/12/88 : Creation date.
        elp  02/11/92 : integrate WL
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine connects the Active Drawing Parameters super to the
current module's color table object.
----*/
/*EH*/

class implementation   GRadp;

#include "coimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

method super_construct()
{
    IGRint              status;         /* return code */

    /*
     * Connect the Active Drawing Parameters super to the color table
     * object of the current module.
     */

    status = ige$connect_color_notify();

    if (status & 1)  /* successful connecting to the color table object */
    {
        return(OM_S_SUCCESS);
    }
    else  /* failed to connect to the color table object */
    {
        return(OM_E_ABORT);
    }
}

end implementation GRadp;
