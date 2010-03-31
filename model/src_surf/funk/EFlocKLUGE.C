/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "EMSlc.h"

/*
Abstract

    This file is used as a KLUGE to get the locate tolerance from
    the GRlocate_processing method for EMSsubbs to the GRlnprocess
    method. It wil not be needed for version 1.2.0.

History

    27 Dec 92   NP      Modified for ANSI compliance. ANSI C does not like a
			semi-colon after the curly brace at the end of the 
			function definition (why WAS it there in the first
			place ??). This is for functions:
			EMSsubbs_put_locate_window(),EMSsubbs_get_locate_window()
    09 Dec 88   AIC     Remove put/get-locate-tolerance function
                        and add put/get-locate-window function.

    01 Jul 88   AIC     Removed I-am-locating, I-am-not-locating,
                        and am-I-locating functions.

    ?? ??? 88   AIC     Creation Date.
*/


/*
 * The following functions store and retrieve the locate window
 * objid/osnum.
 */
GRobjid     window_objid;
GRspacenum  window_osnum;

void EMSsubbs_put_locate_window(objid, osnum)

GRobjid     objid;
GRspacenum  osnum;

{
  window_objid = objid;
  window_osnum = osnum;
}

void EMSsubbs_get_locate_window(objid, osnum)

GRobjid     *objid;
GRspacenum  *osnum;

{
  *objid = window_objid;
  *osnum = window_osnum;
}




/*
  ABSTRACT

    Yet another kluge is introduced here. This will be removed when the
    locate things (methods/structures/etc) all support the data-ptr
    in the GRlc_cvl structure to the point when it becomes usable. For
    now a locally static structure is defined which is used to convey the
    information back and forth the methods called within the
    surface-locate.

  HISTORY

    SS  :  09/26/88  :  Creation

*/

static struct EMSsrflocinfo srfloc;

void EMsrfloc_init (srfobj)
GRobjid srfobj;
{
  srfloc.valid = FALSE;
  srfloc.srf_obj = srfobj;
  return;
}


IGRboolean EMsrfloc_putinfo (srfobj, gradataobj, loctype, edgeobj)
GRobjid srfobj, gradataobj, edgeobj;
enum EMSsrfloctype loctype;
{
  if (IF_EQ_OBJID (srfobj, srfloc.srf_obj))
    {
    srfloc.valid = TRUE;
    srfloc.gradata_obj = gradataobj;
    srfloc.loc_type = loctype;
    srfloc.edge_obj = edgeobj;
    return (TRUE);
    }
  else
    return (FALSE);
}


IGRboolean EMsrfloc_getinfo (srfobj, gradataobj, loctype, edgeobj)
GRobjid *srfobj, *gradataobj, *edgeobj;
enum EMSsrfloctype *loctype;
{
  if (srfloc.valid)
    {
    *srfobj = srfloc.srf_obj;
    *gradataobj = srfloc.gradata_obj;
    *loctype = srfloc.loc_type;
    *edgeobj = srfloc.edge_obj;
    return (TRUE);
    }
  else
    return (FALSE);
}
