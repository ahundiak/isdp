/* ###################   APOGEE COMPILED   ################## */
class specification ECdynload (1:0) of COconst;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "OMlimits.h" 
#include "dp.h"         /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"

/*
Abstract:
    DEBUG COMMAND

History:
    DLB  08/03/87     Creation date.
*/
 
override execute,
/*
Motivation: 
    This method will read in a file name and give it to om to be 
    dynamically loaded.
*/
sleep;

end specification ECdynload;
