/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   EMSsubbs    
     METHOD NAME:   GRclipto

     Abstract: 
                This method returns the class name of the object
        that B-spline subsurafce clips to.

-----
%SC%    

     GRclipto(msg,classname,num_vla)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        completion code
                                    - MSSUCC always successful
     *classname   IGRchar        array for classname
     num_vla      IGRlong        number of variable length arrays 
                                    needed for the new object

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:                   None.

     Methods:           
                                None.

-----
%RL%

     RELATIONS REFERENCED:      None.
-----
%NB%

     NOTES:                     None.
-----
%CH%

     CHANGE HISTORY:
        
        RC      10/01/86 : Creation date.
       rlw	01/05/88 : Changed clipto class to EMSgenbs
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

        This method returns the class name of EMSsubbs, which is
        what this object clips to. 
---*/
/*EH*/

class implementation EMSsubbs;

#include "EMS.h"

# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

/* #include "gopriv.h" */

method GRclipto(IGRlong *msg; IGRchar *classname)
{

        *msg = MSSUCC;                  /* initialize to success        */

        strcpy(classname,"EMSgenbs"); /* clipto classname               */

        return (OM_S_SUCCESS);

}

end implementation EMSsubbs;
