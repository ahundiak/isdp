/*----
    Abstract:  This Command Object allow to add as new root an optional object
               (track point, coordinate system or plane ) to an associatve 
               object.

   
 CHANGE HISTORY:
    ch  mars-87 : design date.
    ch  jan -87 : update for 1.1 release.
*/

class specification COadd_opt (0:1) of COpara;

#include "parametric.h"

instance COadd_opt
{
 struct GRid opt_root;  /* optionnal root  */
 IGRlong loc_opt,       /* prompt to locate optionnal root */
	 acc_opt,       /* prompt to accept optionnal root */
	 loc_obj,	/* prompt to locate object to mocify */
	 acc_obj;	/* prompt to accept object to modify */
 
};

override wakeup, execute;

end specification COadd_opt;
