/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"

%safe
#include <math.h>
%endsafe


/*
 Description

 This function get the abstract buffer
 of an object.

 History

  12/08/87 : rlw : The beginning
  12/21/87 : rlw : Added code to return MSFAIL if sts is FALSE
 */

#include "ems_m_inc.h"			/* Includes everything */

from GRvg import GRgenabsg;

IGRlong EFgetabstract(
 event,
 my_stupid_id,
 abstract_buffer_pointer,
 msg)

struct		GRevent *event;
OM_S_OBJID	my_stupid_id;
IGRchar		**abstract_buffer_pointer;
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
   msg = message GRvg.GRgenabsg(
    msg,
    &mdenv_info->matrix_type,
    mdenv_info->matrix,
    abstract_buffer_pointer),
   senderid = my_stupid_id,
   targetid = id->objid,
   targetos = id->osnum);
  if (! (1 & sts))
   *msg = MSFAIL;
/*
 * eof
 */
 return(sts);
}

end implementation Root;
