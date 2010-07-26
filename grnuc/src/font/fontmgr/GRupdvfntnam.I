/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             GRupd_vfont_name
 
     Abstract:

              This routine updates the virtual font name of the
              specified entry.
-----
%SC%

    VALUE = GRupd_vfont_name(IGRlong *msg; IGRshort entry_number;
                             IGRchar *new_name)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------
    entry_number  IGRshort          virtual font number
    *new_name     IGRchar           new name for virtual font name
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     ---------------  --------------------------------------
     *msg           IGRlong          completion code

     VALUE (IGRlong) =    MSSUCC   - if successful
                          MSFAIL   - if failure
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
        
        DEK  08/08/88 : Design date.
        DEK  08/08/88 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine updates the virtual font name of the specified entry.
----*/
/*EH*/

class implementation GRfm;

#include "grimport.h"
#include "OMerrordef.h"

method GRupd_vfont_name(IGRlong *msg; IGRshort entry_number; IGRchar *new_name)
{
   *msg = MSSUCC;

   strcpy((char *)(me^^GRfm.vfont[entry_number].vfontname),new_name);

   return(OM_S_SUCCESS);

}

end implementation GRfm;
