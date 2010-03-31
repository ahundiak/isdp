class implementation NMpartedge;

method NMget_region_edge(IGRlong *EMmsg; GRobjid *region_edge, *region_loop)
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 OM_S_CHANSELECT	to_comps;
 OM_S_OBJECT_LINKAGE	edge;
 OMuint			count;
 IGRboolean		found = FALSE;

 *EMmsg = EMS_S_Success;
 if(region_edge) *region_edge = NULL_OBJID;
 if(region_loop) *region_loop = NULL_OBJID;
 sts = EMmake_chanselect (EMSbd_owner_to_comps, &to_comps);
	
 edge.S_objid = my_id;
 edge.osnum = OM_Gw_current_OS;
 count = 1;
 while(count && !found)
  {
   sts = om$get_channel_objects(objid = edge.S_objid, p_chanselect = &to_comps,
	 list = &edge, size = 1, count = &count);
   if(!(1&sts)) goto wrapup;

   /* If the component is not of NMpartedge ancentry then we have hit a region
      edge. If not keep going down.
   */
   found = !EFisAncestryValid(EMmsg, edge.S_objid, edge.osnum, 
			      OPP_NMpartedge_class_id, FALSE);    
  }

 if(found)
  {
   if(region_edge) *region_edge = edge.S_objid;
   if(region_loop)
    sts = EMsend_loops(&rc, message EMSboundary.EMget_objid
	  (EMmsg, region_loop), edge.S_objid, 0, MAXINT, EMLP_ACTIVE, NULL, 
	  NULL);
  }
 else *EMmsg = EMS_I_NotFound;

wrapup:
EMWRAPUP(*EMmsg, sts, "NMpartedge.NMget_region_edge");
return(sts);
}

end implementation NMpartedge;
