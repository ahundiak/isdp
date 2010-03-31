/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSerrordef.h"

method EMget_props_type(IGRlong *EMmsg; IGRushort *props;
										IGRuchar  *type;)
/*
History

	SAM		30/10/87	Creation Date

*/
{
  *EMmsg = EMS_S_Success;
  if(props) *props = ME.EMSedge->ed_props;

  if(type) *type  = ME.EMSedge->curve_type;

  if(!props && !type) *EMmsg = EMS_E_InvalidArg;

  return(OM_S_SUCCESS);
}

end implementation EMSedge;
