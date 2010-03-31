class implementation NMedflp;

#include "OMmacros.h"
#include "emssfint.h"
#include "emsmacros.h"

from EMSedge import EMptproject, EMgettopedge, EMendpts;

extern OMuword OPP_NMedflp_class_id;

IGRint NMincedence(EMmsg, inedpar, sfid, ptol, outedpar)
IGRlong *EMmsg;
struct EMSsfintedpar *inedpar, *outedpar;
struct EMSpartolbasis *ptol;
struct GRid *sfid;
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 IGRdouble		enduv[2][2], dist1, dist2;
 struct EMSedgebound 	endpar[2];
 struct EMSproj_info	projinfo;
 GRspacenum		edgeos;
 struct GRid		*edflp = NULL;
 IGRint			j, num_edflp = 0;
 OM_S_CHANSELECT	to_ed;
 OMuword 		exact_clsid = OPP_NMedflp_class_id;
 struct EMSsfintedpar	locinedpar;

 *EMmsg = EMS_S_Success;
 EMerr_hndlr(!ptol || !sfid, *EMmsg, EMS_E_InvalidArg, wrapup);
 edgeos = sfid->osnum;

 *outedpar = *inedpar;
 outedpar->edgeid = NULL_OBJID;

 if(inedpar->intloc == EMScvint_rtendcoll)
  inedpar->intloc = EMScvint_rtend;
 else if(inedpar->intloc == EMScvint_lfendcoll)
  inedpar->intloc = EMScvint_lfend;
 else if( (inedpar->intloc == EMScvint_endcoll) || 
	  (inedpar->intloc == EMScvint_end))
  {
   sts = om$send(msg = message EMSedge.EMendpts(EMmsg, enduv[0], enduv[1], 
         &endpar[0], &endpar[1], NULL), senderid = NULL_OBJID, 
         targetid = inedpar->edgeid, targetos = edgeos);
   if(!(1&*EMmsg&sts)) goto wrapup;

   dist1 = EM2ddistptpt(enduv[0], inedpar->point);
   if(dist1 < ptol->tol)
    {
     inedpar->intloc = EMScvint_lfend;
     inedpar->edgepar = endpar[0];
    }
   else
    {
     dist2 = EM2ddistptpt(enduv[1], inedpar->point);
     if(dist2 < ptol->tol)
      {
       inedpar->intloc = EMScvint_rtend;
       inedpar->edgepar = endpar[1];
      }
    }
  }

 if(inedpar->intloc == EMScvint_middle)
  {
   sts = NMsend_to_partedges(&rc, message EMSedge.EMgettopedge(EMmsg, 
         &inedpar->edgepar, ptol, &outedpar->edgeid), inedpar->edgeid, edgeos, 
         0, MAXINT, NULL, NULL, NULL);
   EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
   if(!(1&*EMmsg&sts)) goto wrapup;

   if(IF_NULL_OBJID(outedpar->edgeid)) 
    {
     sts = EMsend_partedges(&rc, message EMSedge.EMgettopedge(EMmsg, 
           &inedpar->edgepar, ptol, &outedpar->edgeid), inedpar->edgeid,
           0, MAXINT, NULL, NULL, NULL);
     EMerr_hndlr(!(1&rc), *EMmsg, EMS_E_Fail, wrapup);
     if(!(1&*EMmsg&sts)) goto wrapup;
    }

   if(IF_NULL_OBJID(outedpar->edgeid)) 
    {
     *EMmsg = EMS_I_NotFound;
     goto wrapup;
    }

   /* Found a NMpartedge where this incedence can be shifted. Collect and
      update the relevant data.
   */
   sts = om$send(msg = message EMSedge.EMendpts(EMmsg, enduv[0], enduv[1], 
         &endpar[0], &endpar[1], NULL), senderid = NULL_OBJID, 
         targetid = outedpar->edgeid, targetos = edgeos);
   if(!(1&*EMmsg&sts)) goto wrapup;

   dist1 = EM2ddistptpt(enduv[0], inedpar->point);
   if(dist1 < ptol->tol)
    {
     outedpar->intloc = EMScvint_lfend;
     outedpar->edgepar = endpar[0];
     goto wrapup;
    }

   dist2 = EM2ddistptpt(enduv[1], inedpar->point);
   if(dist2 < ptol->tol)
    {
     outedpar->intloc = EMScvint_rtend;
     outedpar->edgepar = endpar[1];
     goto wrapup;
    }

   /* If not at either ends of the NMpartedge, must be in the middle.
   */
   sts = om$send(msg = message EMSedge.EMptproject(EMmsg, inedpar->point, 
         1, &projinfo, NULL, ptol), senderid = NULL_OBJID, 
         targetid = outedpar->edgeid, targetos = edgeos);
   if(!(1&*EMmsg&sts)) goto wrapup;

   outedpar->intloc = EMScvint_middle;
   outedpar->edgepar = projinfo.param;
  }
 else if( (inedpar->intloc == EMScvint_rtend) || 
	  (inedpar->intloc == EMScvint_lfend))
  {
   sts = NMget_feature_loops(EMmsg, sfid, &num_edflp, &edflp, 
         &exact_clsid, 1, NULL, 0, NULL);
   if(!(1&*EMmsg&sts)) goto wrapup;
	
   for(j=0; j<num_edflp; j++)
    {
     GRobjid region_edge = NULL_OBJID;
     IGRboolean begin = FALSE;

     if(inedpar->intloc == EMScvint_lfend) begin = TRUE;

     sts = om$send(msg = message NMfeaturelp.NMget_nesting_parent(EMmsg, 
           &region_edge, TRUE), targetid = edflp[j].objid, 
           targetos = edflp[j].osnum, senderid = NULL_OBJID); 
     if(!(1&*EMmsg&sts)) goto wrapup;
     if(IF_EQ_OBJID(inedpar->edgeid, region_edge))
      {
       OMuword junk;
       OMuint numed;
	
       /* Out of the edges in this NMedflp, choose the appropriate
	  edge (first or last)
       */
       EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);

       sts = om$get_channel_count(objid = edflp[j].objid, 
	      p_chanselect = &to_ed, count = &numed);
       if(!(1&sts)) goto wrapup;
       if(!numed) continue;

       sts = om$get_objid_at_index(objid = edflp[j].objid, 
	     p_chanselect = &to_ed, 
	     index = begin ? 0 : (numed - 1), 
	     objidaddr = &outedpar->edgeid, osnumaddr = &junk);
       if(!(1&sts)) goto wrapup;

       /* Found a NMpartedge where this incedence can be shifted. Collect and
          update the relevant data.
       */
       sts = om$send(msg = message EMSedge.EMendpts(EMmsg, 
             NULL, NULL, begin ? &endpar[0] : NULL, begin ? NULL : &endpar[0], 
	     NULL), 
	     senderid = NULL_OBJID, targetid = outedpar->edgeid, 
	     targetos = edgeos);
       if(!(1&*EMmsg&sts)) goto wrapup;

       outedpar->intloc = begin ? EMScvint_lfend : EMScvint_rtend;
       outedpar->edgepar = endpar[0];

       break;
      } /* if(IF_EQ_OBJID(inedpar->edgeid, region_edge)) */
       	
    } /* for(j=0; j<num_edflp; j++) */

   if(!IF_NULL_OBJID(outedpar->edgeid)) goto wrapup;

   /* Topological checks (to avoid geometry tolerance problems) have
      failed. Try geometrical check to shift the incedence. I do this by
      forcing the location to be in middle and recursively calling the 
      function. However, during the recursive call, the location should
      revert back to one of the ends. 
   */
   locinedpar = *inedpar;
   locinedpar.intloc = EMScvint_middle;
   sts = NMincedence(EMmsg, &locinedpar, sfid, ptol, outedpar);
   if(!(1&*EMmsg&sts)) goto wrapup;
   if((!IF_NULL_OBJID(outedpar->edgeid)) &&
      (outedpar->intloc == EMScvint_middle))
    outedpar->edgeid = NULL_OBJID;

  } /* If location at end */

wrapup:
EMWRAPUP(*EMmsg, sts, "NMincedence");
return(sts);
}

end implementation NMedflp;

