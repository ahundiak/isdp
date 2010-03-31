class specification CODelSecSol (1:0) of super_cmd;

/************************************************************************

 ** This class was specifically created to handle the peculiar case of **
 ** deletion of the gen. solid created by section views                ** 
 ** CR Section View Enhancements.

 ** 09/09/96 Creation - Sp.Balamurugan                                 **
*************************************************************************/

#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "igrdef.h"
#include "lcdef.h"
#include "lc.h"


instance CODelSecSol
{
  struct GRevent locate_event, acc_event;
  struct GRlc_stack locate_stack;
};

override init,wakeup,execute;

end specification CODelSecSol;
