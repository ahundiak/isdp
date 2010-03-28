/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRaccumulate_range

Description
   This function will accumulate range, given the old range
   and the new range to be accumulated.

   *msg         IGRlong         completion code
   range[]      IGRdouble       The new range.
   acc_range[]  IGRdouble       The accumaulated range

Return Values
   MSSUCC   if successful

History
   Gray Winn   06/17/86  : Creation date.
\*/

#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"

IGRint GRaccumulate_range (msg, range, acc_range )
IGRlong     *msg;
IGRdouble   range[];
IGRdouble   acc_range[];
{
IGRint   i,j;

   *msg = MSSUCC;
   for (i=0; i <= 2; ++i)
   {
      for (j=i; j <= 5; j += 3)
      {
         if (range[j] < acc_range[i])
         {
            acc_range[i] = range[j];
         }else if (range[j] > acc_range[i+3])
         {
            acc_range[i+3] = range[j];
         }
      }
   }

return(1);
}
