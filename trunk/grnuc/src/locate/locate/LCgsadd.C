/* #######################    APOGEE COMPILED   ######################## */

/*
Abstract
	This routine is called from the action handler.  It is meant
	to localize the interface points to the graphics set.  Since there
	is an action handler to add to sets this routine simply calls 
	GRgslocact.  If there is a need to do more than this the locate
	filters will not need to change only the interface defined in
	this routine will.

Notes
	The graphics set do not support nested save sets.  Therefore
	there is only one layer of moudule information.  The remainder
	is concatenated.

History
	7/31/87	Creation Date
  scw  07/13/92 Ansi conversion

*/
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "griodef.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "grgsdef.h"
#include "grgs.h"

LCadd_sav(gs_id, sv_id, new_entry)
struct GRid gs_id, sv_id;
struct GRlc_info *new_entry;
{
    enum GRlocate_action action;

    action = add_all;
    
    return (GRgsaction (new_entry, &action, &gs_id, &sv_id, NULL, FALSE));
}
