/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method returns the nesting information about a loop. The
  information is exchanged via the structure EMSnest_info.Upon output, the
  struture has the loopid,loop properties, parent id, parent properties,
  and the range box of the loop.If the loop has no parent then NULL_OBJID
  is returned for the parent id.

History
	SM	03/09/87	Creation date.
*/
class implementation EMSloop;

#include "EMS.h"
#include "OMmacros.h"
#include "emsmacros.h"

from EMSloopset import EMget_props;

method EMgivenestinfo(IGRlong *EMmsg;struct EMSnest_info *nesting)
 {
    IGRlong 		sts,size;
    OM_S_CHANSELECT	to_outter;

    *EMmsg = EMS_S_Success;
    sts = OM_S_SUCCESS;

    to_outter.type = OM_e_addr;
    to_outter.u_sel.addr = &ME.EMSloop->to_outter;

    nesting->loopid = my_id;
    nesting->lp_props = ME.EMSloop->lp_props;
    nesting->parent = NULL_OBJID;
    nesting->parent_props = NULL;

    sts = om$send(msg=message EMSboundary.EMget_objid
				(EMmsg,&nesting->parent),
			p_chanselect=&to_outter);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);

    if(!IF_NULL_OBJID(nesting->parent))
     {
       if(ME.EMSloop->lp_props & EMLP_EXTERNAL)
	{
          sts = om$send(msg=message EMSloopset.EMget_props
				(EMmsg,(IGRushort *) (&nesting->parent_props)),
			p_chanselect = &to_outter);
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
	}
       else
	{
          sts = om$send(msg=message EMSloop.EMget_props
				(EMmsg,(IGRushort *) (&nesting->parent_props)),
			p_chanselect = &to_outter);
          EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_OMerror,wrapup);
	}

     }


/* Put my range box
*/
    size = 4 * sizeof(IGRdouble);
    OM_BLOCK_MOVE(ME.EMSloop->range,nesting->range,size);

wrapup:
    EMWRAPUP(*EMmsg,sts,"In EMSloop.EMgivenestinfo")
    return(sts);
 }

    
end implementation EMSloop;
