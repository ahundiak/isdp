/*----

    Abstract:  This Command Object performs a partial delete defined by
               2 objects points

 CHANGE HISTORY:


	jla  : 20-jan-87  design date 

---- */

class specification COparadel (0:1) of COpara;

#include "parametric.h"


instance COparadel
{
struct   GRid    list_id[3];     /* parent objid                              */
struct   GRid    context[3];          /* context of the objects */
IGRdouble        point[4];       /* point when object is closed               */
GRclassid        as_classid;     /* classid of associative                    */
short            closed;         /* Flag = TRUE if the curve is cloased       */
};

override wakeup, execute;

end specification COparadel;
