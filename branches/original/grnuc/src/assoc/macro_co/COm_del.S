/*----

     Abstract:  Delete or Dump a parametric macro


      D.PAYANNET    10/14/86	: Design date.

----*/

class specification COm_del (0:1) of COpara;

#include "macro.h"

instance COm_del
  {
  IGRchar Macro_Name[macro_MAX_CHAR+14];    /* name of the macro                 */
};

override 
  wakeup,
  sleep,
  execute;

end specification COm_del;
