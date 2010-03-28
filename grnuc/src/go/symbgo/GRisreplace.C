/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRis_symbol_replacable

Description
   This routine will check to see if a symbol is replacable.

   objid             GRobjid           object id
   osnum             GRspacenum        object space number 
   chansel           OM_p_CHANSELECT   channel selector

History
   Gray Winn   11/24/87    Creation date
   scw         07/22/92    ansi conversion
\*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

IGRint GRis_symbol_replacable (osnum, objid, chansel)
GRspacenum        osnum;
GRobjid           objid;
OM_p_CHANSELECT   chansel;
{
IGRlong     om_msg;
OMuint      count;
IGRint      i;
GRobjid     go_objid;
GRspacenum  go_osnum;
GRclassid   classid;
GRclassid   go_classid;

   om_msg = om$get_channel_count (osnum = osnum, objid = objid, 
            p_chanselect = chansel, count = &count);

   om_msg = om$get_classid (osnum = osnum, classname = "GRsymbol",
            p_classid = &classid);

   for (i=0; i < count; ++i)
   {
      om_msg = om$get_objid_at_index (osnum = osnum, objid = objid, 
               p_chanselect = chansel, index = i, objidaddr = &go_objid, 
               osnumaddr = &go_osnum);

      om_msg = om$get_classid (osnum = go_osnum, objid = go_objid,
               p_classid = &go_classid);

      om_msg = om$is_ancestry_valid (subclassid = go_classid,
               superclassid = classid);

      if (om_msg == OM_S_SUCCESS) return(OM_E_ABORT);
   }
   return(OM_S_SUCCESS);
}
