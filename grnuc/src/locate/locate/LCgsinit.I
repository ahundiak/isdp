/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	This function will create a graphics set object.  It is called when
	the name being used to locate an object is a regular expression.

	It will then send a start transition to create an initial save
	set object.  

Notes
	This is presently called only from LCnmlocate (a function to
	perform named locates).

History
	7/30/87	Creation Date.
  scw  07/13/92 Ansi conversion
*/
class implementation Root;


#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "grgsdef.h"
#include "grgsmacros.h"

from GRgrset import GSstart_transition;

LCgsinit (mod, gs_id, sv_id)
struct GRmd_env *mod;
struct GRid     *gs_id;
struct GRid     *sv_id;
{
    IGRlong sts, msg, om_msg;
    IGRint properties = 0, ret_code = 0;

    gs_id->osnum = mod->md_id.osnum;

    om_msg = gr$gsinit (msg = &sts,
               senderid = NULL_OBJID,
               p_objid = &gs_id->objid,
               osnum = mod->md_id.osnum,
               flag = 3, /* graphics set for formation of select set
                            that honors hilight */
              );
    
    if (!(1&om_msg)) {
        om$report_error (sts = om_msg);
        goto WRAP;
    }
    if (sts == MSFAIL) {
        goto WRAP;
    }
    sts = om$send (msg = message GRgrset.GSstart_transition (&msg,
                                 mod, &properties, NULL, sv_id),
                   senderid = NULL_OBJID,
                   targetid = gs_id->objid,
                   targetos = gs_id->osnum);    
    if (!(1&sts)) {
        om$report_error (sts = sts);
        goto WRAP;
    }
    ret_code = 1;

WRAP:
    return (ret_code);
}

end implementation Root;
