/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRtext
     METHOD NAME:  GRchange_flag

     Abstract: This method sets or clears the specified bits of the text
               object's flag.
-----
%SC%    

     GRchange_flag(msg,set,bitmask)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   ------------------------------------
     set          IGRint         TRUE if the specified bits are to be
                                 set, FALSE if they are to be cleared
     bitmask      IGRshort       bits to be set or cleared

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE              DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        completion code
                                     MSSUCC - successful completion
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none.

     Methods:  none.
-----
%RL%

     RELATIONS REFERENCED:  none.
-----
%NB%

     NOTES:  none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     09/06/88: Design date.
        WBC     09/06/88: Creation date.
        SCW     07/22/92: Removed copyright header
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
  This method sets or clears the specified bits of the text
object's flag.
----*/
/*EH*/

class implementation GRtext;

#include "grimport.h"
#include "msdef.h"

method GRchange_flag(IGRlong *msg; IGRint set; IGRshort bitmask)
{

    *msg = MSSUCC;

    if (set)  /* set the specified bits in flag */
    {
        me^^GRtext.attr.flag |= bitmask;
    }
    else  /* clear the specified bits in flag */
    {
        me^^GRtext.attr.flag &= ~bitmask;
    }

    return (OM_S_SUCCESS);
}

end implementation GRtext;
