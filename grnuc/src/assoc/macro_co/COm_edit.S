/*----
     Abstract:  Copy a parametric macro

      CHANGE HISTORY

      D.PAYANNET    10/14/86	: Design date.

----*/


class specification COm_edit (0:1) of COpara;

#include "macro.h"
#define macro_MAX 40

instance COm_edit
{
  int        	num_up;                     	/* Number of upscan     */
  int        	curr_temp;                  	/* Current template     */
  int	     	tot_temp;
  struct sup    dup[macro_MAX];
  struct stemp  dtemp[macro_MAX];
  int        	asgn_temp_map[macro_MAX];   	/*                       */
  IGRchar    	macro_name[macro_MAX_CHAR];     /* name of the macro     */
  IGRchar    	full_name[macro_MAX_CHAR+14];	/* name of the macro     */
  struct GRid	macro_id;
};

override
  wakeup,
  sleep,
  execute;

end specification COm_edit;
