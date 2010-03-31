/*
Check to make sure there is a vertex use in each parametric space.
*/
class implementation NMvertex;

#define StaticBuf	10

extern OMuint OM_Gf_verbose_warning;

method NMcheck(IGRlong *EMmsg; struct NMgmSSI *ssi; 
		unsigned int connect_opt)
{
 IGRlong		sts;
 OM_S_CHANSELECT 	to_vtxuses;
 OM_S_OBJECT_LINKAGE	*objlnk = NULL, objlnkbuf[StaticBuf];
 struct GRid		*vtxuses = NULL, vtxusesbuf[StaticBuf];
 OMuint			num_vtxuses = 0;
 IGRint			i;

 *EMmsg = EMS_S_Success;
 NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtxuses);

 sts = om$get_channel_count(object = me, p_chanselect = &to_vtxuses, 
       count = &num_vtxuses);
 if(!(1&sts)) goto wrapup;
 EMerr_hndlr(!num_vtxuses, *EMmsg, EMS_I_Useless, wrapup);

 if(num_vtxuses > StaticBuf)
  {
   objlnk = (OM_S_OBJECT_LINKAGE *) om$malloc(size = num_vtxuses *
	    sizeof(OM_S_OBJECT_LINKAGE));
   vtxuses = (struct GRid *) om$malloc(size = num_vtxuses *
		sizeof(struct GRid));
  }
 else
  {
   objlnk = (OM_S_OBJECT_LINKAGE *) objlnkbuf;
   vtxuses = (struct GRid *) vtxusesbuf;
  }

 sts = om$get_channel_objects(object = me, p_chanselect = &to_vtxuses, 
       list = objlnk, size = num_vtxuses, count = &num_vtxuses);
 if(!(1&sts)) goto wrapup;

 for(i=0; i<num_vtxuses; i++)
  {
   vtxuses[i].objid = objlnk[i].S_objid;
   vtxuses[i].osnum = objlnk[i].osnum;
  }

 sts = om$send(msg = message Root.wild_disconnect(to_vtxuses), 
       targetid = my_id);
 if(!(1&sts)) goto wrapup;


 sts = om$send(msg = message NMvertex.NMconnect_vertex_uses(EMmsg, num_vtxuses,
       vtxuses, ME.GR3dpoint->point, ssi, connect_opt), targetid = my_id);

wrapup:
if(objlnk && (objlnk != objlnkbuf)) om$dealloc(ptr = objlnk);
if(vtxuses && (vtxuses != vtxusesbuf)) om$dealloc(ptr = vtxuses);

if(OM_Gf_verbose_warning)
 {
  EMWRAPUP(*EMmsg, sts, "NMvertex.NMcheck");
 }

return(sts);
}


end implementation NMvertex;
