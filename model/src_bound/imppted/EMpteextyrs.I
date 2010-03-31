/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	Whenever the ptedge gets this message it make a copy of itself. Like
	non-degenerate edges, a part extraction is not possible in
	ptedge.
	The output_pairs option is meaningless for the same reason.
*/

class implementation EMSptedge;

#include "EMS.h"
#include "emsimpdef.h"

method EMextractyourself(IGRlong *EMmsg;
			 struct EMSsfintedpar *my_bdrys,*ele_bdrys;
			 IGRint num_bdrys;GRobjid **output_obj;
			 struct EMSsfintedpar ***out_bdrys,***against_bdrys;
			 IGRboolean output_pairs;
			 IGRushort options;struct EMSpartedinfo *bnd;
			 struct EMSpartolbasis *partolbasis)
{
   IGRlong		sts;
   IGRboolean		delete_me;

   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   delete_me = options & EMImpBnd_NoInputDelete ? FALSE : TRUE;

   if(!(*output_obj))
	*output_obj = (GRobjid *) om$malloc(size=sizeof(GRobjid));
   EMerr_hndlr(!*output_obj,*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);

   sts = om$construct_and_copy(object = me, p_objid=*output_obj);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);

   /*
    * If this edge is a model-space edge, connect it's extracted piece
    * to the associations of this edge.
    */

   if (ME.EMSedge->ed_props & EMED_XYZ)
    {
      sts = om$send (msg = message EMSedge.EMconn_to_myassoc (EMmsg,
               1, *output_obj), targetid = my_id);
      EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
    }

  if(options & EMImpBnd_MaintainAssoc)
   {
    sts = om$send (msg = message EMSedge.EMconn_to_myassoc 
               (EMmsg, num_bdrys, *output_obj), targetid = my_id);
    EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_EdgeError,wrapup);
   }

  if(delete_me)
     sts = om$send(msg=message Root.delete(TRUE),targetid=my_id);

wrapup:

   EMWRAPUP(*EMmsg,sts,"In EMSptedge.EMextractyourself");
   return(sts);
}

end implementation EMSptedge;

