/* ###################   APOGEE COMPILED   ################## */
/*
Notes 
	This method returns the merged, logical geometry of a loop.

Arguments
	bcgeom		output		Merged curve for the loop. Memory
					is always allocated by the
					method. Should be freed using
					BSfreecv().
	ptol		input		Parametric tolerance.
	options		input		Currently ignored.
	
History
	SM	16-Oct-89	Creation.

        Sudha   06/04/93        modified to include BSprototype header files

*/
class implementation EMSloop;

#include "bserr.h"
#include "bsparameters.h"
#include "bschgdeppar.h"

#ifndef DEBUG
#define DEBUG	0
#endif

#if DEBUG
#define MaxEdges	1
#else
#define MaxEdges	10
#endif

from EMSedge import EMgetbcgeom;
extern OMuword OPP_EMSptedge_class_id;

method EMgetbcgeom(IGRlong *EMmsg;
		   struct IGRbsp_curve **bcgeom;
		   struct EMSpartolbasis *ptol;
		   IGRushort options)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 OMuint                 numedges = 0;
 IGRint			i, frominx, toinx;
 struct IGRbsp_curve	*edgescv = NULL, edgescvbuf[MaxEdges];
 OM_S_CHANSELECT	to_ed;
 IGRboolean		rev = FALSE, sts_func = TRUE;
 IGRdouble		bastol;
 extern IGRboolean	EFmerge_curves();
 GRobjid		edid;

 BSEXTRACTPAR(&rc, BSTOLBASIS, bastol);

 *EMmsg = EMS_S_Success;
 EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
 *bcgeom = NULL;
 if(!ptol->is_valid)
  {
   sts = om$send(msg=message EMSboundary.EMgetsurface_info(EMmsg, NULL, ptol),
			targetid = my_id);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_LoopError,wrapup);
  }

 sts = om$get_channel_count(object = me, p_chanselect = &to_ed, 
			    count = &numedges);
 EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
 EMerr_hndlr(!numedges, *EMmsg, EMS_I_NoSolution, wrapup);

 if(numedges > MaxEdges)
  edgescv = (struct IGRbsp_curve *) om$malloc(size = numedges * 
				sizeof(struct IGRbsp_curve));
 else edgescv = edgescvbuf;
 EMerr_hndlr(!edgescv, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 for(i=0; i<numedges; i++)
  {
   edgescv[i].poles = NULL;
   edgescv[i].knots = NULL;
   edgescv[i].weights = NULL;
  }
 rev = ME.EMSloop->lp_props & EMLP_REVERSED;

 frominx = rev ? numedges -1 : 0;
 toinx = rev ? 0 : numedges;
 numedges = 0;
 for(i=frominx; (rev ? i>=0 : i<toinx); (rev ? i-- : i++))
  {
   sts = om$send(msg = message EMSboundary.EMget_objid(EMmsg, &edid), 
		p_chanselect = &to_ed, from = i, to = i);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

   if(EFisAncestryValid(EMmsg, edid, OM_Gw_current_OS, OPP_EMSptedge_class_id, 
			TRUE))   continue;
			
   sts = om$send(msg = message EMSedge.EMgetbcgeom(EMmsg, 0, MAXINT, 
			FALSE, NULL, &edgescv[numedges++], ptol, NULL), 
			targetid = edid);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
  }
 if(!numedges)
  *EMmsg = EMS_I_Degenerate;
 else
  {
   *EMmsg = EMS_S_Success;
   sts = OM_S_SUCCESS;
   BSchgdeppar (ptol->tol, &rc);
   sts_func = EFmerge_curves(numedges, NULL, edgescv, NULL_OBJID, bcgeom, 
			     TRUE, &rc);
   if(!(1&rc)) *EMmsg = EMS_E_Fail; 
  }

wrapup:
BSchgdeppar (bastol, &rc);
if(edgescv)
 {
  for(i=0; i<numedges; i++)
   {
    if(edgescv[i].poles) om$dealloc(ptr = edgescv[i].poles);
    if(edgescv[i].knots) om$dealloc(ptr = edgescv[i].knots);
    if(edgescv[i].weights) om$dealloc(ptr = edgescv[i].weights);
   }
 }
if(edgescv && (edgescv != edgescvbuf)) om$dealloc(ptr = edgescv);

EMWRAPUP(*EMmsg, sts, "In EMSloop.EMgetbcgeom");
return(sts);

}

end implementation EMSloop;
