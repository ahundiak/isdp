class implementation NMlistedge;


method EMinit_associative  (IGRlong *EMmsg;
                            IGRushort options;
                            IGRint num_parents;
                            struct EMSobject_info *parent_info;
                            IGRint type;
                            unsigned int size;
                            IGRchar *recomp_info;
                            struct GRvg_construct *construct_list)

{
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_edges;
 IGRint			i;
 struct GRid		my_GRid;
 IGRboolean		tagit = FALSE;
 GRspacenum		tagos = OM_Gw_current_OS;

 *EMmsg = EMS_S_Success;

 NMmake_chanselect(NMlistedge_to_edges, &to_edges);
 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;

 /* Assuming that all the input parents are ems edges, connect the listener
    NMedge on the notification channel of each ems edge.
 */

 for(i=0; i<num_parents; i++)
  {
   sts = om$send(msg = message GRnotify.GRntfyconn(EMmsg, &my_GRid, 
	 &to_edges, &i, &tagit, &tagos), 
	 targetid = parent_info[i].grid.objid);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

wrapup:
EMWRAPUP(*EMmsg, sts, "NMlistedge.EMinit_associative");
return(sts);
}

end implementation NMlistedge;
