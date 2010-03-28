/* #######################    APOGEE COMPILED   ######################## */


class implementation Root;
/*
Abstract
	This routine will provide an interface to the graphics
	sets to delete the graphics set and all the save sets connected
	to it.

Notes
	This function is provided so that if graphics sets change, as
	subsystems are likely to do, that the locate filters do not
	need to change, only this function needs to be modified.

History

	8/03/87	Creation Date
  scw  07/13/92 Ansi conversion
*/

#include "grimport.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

from GRgrset import GSdissolve;

LCgsclean (gs_id)
struct GRid gs_id;

{
    IGRlong msg;

    return (om$send (msg = message GRgrset.GSdissolve (&msg),
                   senderid = NULL_OBJID,
                   targetid = gs_id.objid,
                   targetos = gs_id.osnum));
}

end implementation Root;
