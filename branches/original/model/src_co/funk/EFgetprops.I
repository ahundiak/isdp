/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"

%safe
#include <math.h>
%endsafe

/*
 Description

 This function get the properties of
 an object associated with the input
 event.

 History

  11/04/87 : rlw : The beginning
 */

#include "ems_m_inc.h"			/* Includes everything */

from GRvg import GRgeomprops;

IGRlong EFgetprops(
 event,
 my_stupid_id,
 properties,
 msg)

struct		GRevent *event;
OM_S_OBJID	my_stupid_id;
struct		GRprops *properties;
IGRlong		*msg;

{
 IGRlong	sts;
 struct		GRlc_info *loc_info;
 struct		GRid *id;
 struct		GRmdenv_info *mdenv_info;
/*
 * Do it
 */
 loc_info = &event->located_object[0];
 id = &loc_info->located_obj;
 mdenv_info = &loc_info->module_info.md_env;
 sts = om$send(
   msg = message GRvg.GRgeomprops(
    msg,
    &mdenv_info->matrix_type,
    mdenv_info->matrix,
    properties),
   senderid = my_stupid_id,
   targetid = id->objid,
   targetos = id->osnum);
/*
 * eof
 */
 return(sts);
}

end implementation Root;
