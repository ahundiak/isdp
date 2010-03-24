/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:             FEcheck_rangespec
 
     Abstract:  This routine checks to see if two range specifications
                are the same. If they are the same TRUE is returned
                otherwise FALSE is returned.
-----
%SC%

  VALUE = FEcheck_rangespec(msg,rangecount,rangespec1,rangespec2)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    rangecount    IGRshort          number of ranges in range specs
    *rangespec1   RangeSpec         first range of characters
    *rangespec2   RangeSpec         second range of characters
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
    ----------     --------------- -----------------------------------------
    *msg           IGRlong         completion code
-----
%MD%

     MODULES INVOKED:   none

-----
%RL%

      RELATIONS REFERENCED:  none

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  04/20/88 : Design date.
        DEK  04/20/88 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
FEcheck_rangespec

  This routine checks to see if two range specifications are the 
same. If they are the same TRUE is returned otherwise FALSE is 
returned.
 
----*/
/*EH*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "FS.h"
#include "fedef.h"
#include "OMprimitives.h"

IGRboolean FEcheck_rangespec(msg,rangecount,rangespec1,rangespec2)

IGRlong             *msg;            /* completion code                 */
IGRshort            rangecount;      /* number of ranges in range specs */
RangeSpec           *rangespec1;     /* first range of characters       */
RangeSpec           *rangespec2;     /* second range of characters      */
{
   IGRint           i;               /* index counter                   */
   IGRboolean       value;           /* status return code              */

   value = TRUE;
   *msg = MSSUCC;

   for (i = 0; i < rangecount; ++i)
   {
      if ((rangespec1[i].start != rangespec2[i].start) ||
          (rangespec1[i].count != rangespec2[i].count))
      {
         value = FALSE;
         break;
      }
   }

   return(value);
}
