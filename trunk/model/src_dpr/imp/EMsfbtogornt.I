/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
#include "EMSdpr.h"
#if DEBUG
#include "stdio.h"
#endif

method EMtoggleOrient(IGRlong *EMmsg; IGRushort options)
/*
Description
    This message will reverse the orientation of the set 1 elements if this 
    is a subtraction type operation.

Return Values
    EMS_S_Success if all is well.

Notes
    This message comes into play during a random access tree operation (namely
    unevaluate and evaluate).

    About parameters:
        options -
          EMtoggle_orient_FLIP_TO_INACTIVE - if set the orientation should
          flipped as if the state were inactive.  If already so, then do
          nothing.

History
    DLB 02/04/90 The declaration of this msg is moved up to EMSdpr. 
    DLB 07/11/89 Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  OM_S_CHANSELECT to_comps;
  IGRboolean      rev_orient=FALSE;


  *EMmsg = EMS_S_Success;

  if ( (options & EMtoggle_orient_FLIP_AS_IF_INACTIVE) &&
       (ME.EMSdpr->dpr_props & EMS_ORIENT_FLIPPED) )
  {
    /*Aready set as if inactive so do nothing.*/
#   if DEBUG
      fprintf(stderr,"orientation already flipped on node %d - do nothing\n",
              my_id);
#   endif
    goto wrapup;
  }

  if (!(ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE))
  {
    OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(
                            EMmsg, NULL, NULL, NULL, &rev_orient, NULL,
                            NULL, NULL, NULL, NULL, NULL, NULL),
                      targetid = my_id);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (rev_orient)
    {
#     if DEBUG
        fprintf(stderr,"reversing orientation on node %d\n", my_id);
#     endif

      EMmake_chanselect(GRcmpowner_to_components, &to_comps);
      OM_stat = om$send(msg = message EMSsurface.EMrevorient(EMmsg), 
                        p_chanselect = &to_comps,
                        from = 1);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      ME.EMSdpr->dpr_props ^= EMS_ORIENT_FLIPPED;
    }
  }

  wrapup:
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfbool.EMtoggleOrient")
    return(OM_stat);
}
end implementation EMSsfboolean;
