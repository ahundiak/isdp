/*----
    Abstract:  This Command Object allow to update associative object.

 CHANGE HISTORY:
    ch  jan-88 : design date.
---- */

class specification COupdate (0:1) of COpara;

#include "parametric.h"

instance COupdate
{
 struct GRid object;
 variable struct GRid mismatched[100];
 int n_mismatched;
 
};
override init, wakeup, execute;

end specification COupdate;
