/*

    Abstract:  This Command Object allow to change the parents of a
       parametric object.


   
 CHANGE HISTORY:
    ch  11-jan-87 : design date.

*/

class specification COchangroot (0:1) of COpara;

#include "parametric.h"

instance COchangroot
{
 struct GRid root[2];     /* located old and new root for change root   */
 struct GRid context[2];  /* corresponding context			*/
 int 	     type[2];     /* graphic type of the element		*/
 struct GRid object;      /* located object to change root or children  */
};

override wakeup, execute;

end specification COchangroot;
