/*----

    Abstract:  This Command Object defines certain data that is common
             between various parametric construction command objects.

               
 CHANGE HISTORY:


	CH-JLA       : 10-jul-86  first test
---- */


class specification COpara (0:1) of COroot;

#include "codef.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "dp.h" 
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "grio.h"
#include "lc.h"

#include "parametric.h"


instance COpara
{
    IGRchar                loc_prompt[MAX_PROMPT_SIZE];   /* locate prompt */
    IGRchar                acc_prompt[MAX_PROMPT_SIZE];   /* accept prompt */
    IGRchar                reloc_prompt[MAX_PROMPT_SIZE]; /* relocate prompt */
    IGRboolean             input_requested;
    struct    GRlc_locate  attr;      /* locate attr eg class, level */
    struct    GRlc_stack   locate_stack; /* stack for the locate filter */

    struct IGRdisplay      Active_display;/* active display    */
    IGRshort               Active_level;  /* active level      */



    IGRint              action;       /* an action to be performed */
    IGRchar             DatabaseType[MAX_DB_TYPE_SIZE];

};

override sleep, init;

end specification COpara;
