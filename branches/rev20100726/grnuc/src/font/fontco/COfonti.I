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
              intergraph and/or other  third parties which is
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
 
     CLASS NAME   COfont

     METHOD NAMES delete

     Abstract:    This method clears the VSD (Variable String Descriptor)
                  and deletes the current command object.
-----
%SC%
     Value = COfont_delete_method(int f_defer_flag)

-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     ------------   -----------------------------------

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%MD%

     MODULES AND METHODS INVOKED:

     Methods:    Root.delete

-----
%RL%

     RELATIONS REFERENCED:

-----
%UI%

     USER INTERFACE DESCRIPTION:

-----
%NB%

     NOTES:  

-----
%CH%
     CHANGE HISTORY:
        
        WBC  03/27/86 : Design date.
        WBC  03/27/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This method clears the VSD (Variable String Descriptor) and
deletes the current command object.
----*/
/*EH*/

class implementation COfont;

#include "coimport.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

method delete(int f_defer_flag)

{
    IGRlong  status;

    clear_vsd;

    /*
     *  send to my parent class
     */

    status = om$send(mode = OM_e_wrt_message,
                     msg = message Root.delete(f_defer_flag),
                     targetid = my_id );

    return(status);
}

end implementation COfont;
