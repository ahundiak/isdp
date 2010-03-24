/* ceo/dynamics.I */
/*
   perform dynamics -- dummy declared for children
*/
class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method dynamics (
  int	  dynamics;
  int	* sts )
{
 _bugprint(bflag=TFLAG,str="+CEO.dynamics:  dynamics = %d, *sts = %d\n",
	var = `dynamics, *sts` )

  * sts = OM_S_SUCCESS;

  _bugprint(bflag=TFLAG, str="-CEO.dynamics:  *sts = %d\n", var = *sts )
  return OM_S_SUCCESS;
}
end implementation CEO;
