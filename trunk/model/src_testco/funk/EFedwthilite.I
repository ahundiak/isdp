class implementation ECsfedloc;

/*

   This function hilites the edge being passed in with weight.
   Currently the object being hilited needs to be an edge and the
   weight of the hilite has been set to 4. The display mode for the 
   edge has also been set to EMS_WHL_EDGE. 

History

   AMD :  02/18/92  :  Creation.

*/

#include "EMSlmdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"

from EMSboundary import EMgetsurface_info;
from EMSsubbs import EMget_ele_header;
from EMSedge  import EMdisplay;

IGRlong EFhilite_edge_with_weight ( msg, md_env, edgeid, display_mode)

IGRlong           *msg;
struct GRmd_env   md_env;
GRobjid           edgeid;
enum  GRdpmode    display_mode;

{
 IGRlong sts;
 GRspacenum osnum;
 IGRshort  disp_flag;
 GRobjid  srfid;
 struct DPele_header     srf_ele_header;
 union IGRele_attr       ele_spec_att;
 GRrange                 range;
 struct IGResqbs         bsqsurf;
 struct GRsymbology      symb;
 
 sts = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 osnum = md_env.md_id.osnum;
 
 /* Get the surface to which this edge belongs to */

    sts = om$send ( msg = message EMSboundary.EMgetsurface_info
                          (msg, &srfid, NULL),
                    targetid = edgeid,
                    senderid = NULL_OBJID,
                    targetos = osnum );
    EMomerr_hndlr (sts, ret_end, "EMsubbs.EMget_ele_header");  

 /* Get the element header for the surface */
    ele_spec_att.bsqsurf = &bsqsurf;
    sts = om$send (msg = message EMSsubbs.EMget_ele_header(msg,
                         NULL,&md_env.md_env, NULL,
                         &srf_ele_header, range,
                         &symb.display_attr, ele_spec_att, NULL),
             targetid = srfid,
             senderid = NULL_OBJID,
             targetos = osnum);
    EMomerr_hndlr (sts, ret_end, "EMsubbs.EMget_ele_header");  

 /* Increase the weight by 4 */
    srf_ele_header.dis_att->weight += 2;

 /*  Do it!!!!!!!!! */

    disp_flag = EMS_WHL_EDGE;
    sts = om$send ( msg = message EMSedge.EMdisplay ( msg, 
                     &srf_ele_header,
                     &md_env.md_env.matrix_type,
                     md_env.md_env.matrix,
                     &display_mode,NULL,
                     disp_flag, NULL),
             targetid = edgeid,
             senderid = NULL_OBJID, 
             targetos = osnum );
    EMomerr_hndlr ( sts, ret_end, "EMdisplay");
 
 /* Reset the weight */
    srf_ele_header.dis_att->weight -= 2; 

ret_end:

 return (sts);
}

end implementation ECsfedloc;
