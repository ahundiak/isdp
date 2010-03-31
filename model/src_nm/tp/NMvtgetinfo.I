class implementation NMvertex;

#define StaticBuf 10

method NMget_info(IGRlong *EMmsg; IGRint *num_vtxuse; GRobjid **vtxuse;
		   unsigned char *props; IGRushort options)
{
 IGRlong		sts = OM_S_SUCCESS;
 OM_S_CHANSELECT	to_vtxuse;
 OMuint			count = 0;
 IGRint                 i;
 OM_S_OBJECT_LINKAGE	*locvtxuse = NULL, locvtxusebuf[StaticBuf];


 *EMmsg = EMS_S_Success;
 NMmake_chanselect(NMvertex_to_vtx_uses, &to_vtxuse);
 if(num_vtxuse) *num_vtxuse = 0;
 if(vtxuse) *vtxuse = NULL;
 if(props) *props = ME.NMvertex->props;
 if(!num_vtxuse || !vtxuse) goto wrapup;

 sts = om$get_channel_count(object = me, p_chanselect = &to_vtxuse, 
       count = &count);
 if(!(1&sts)) goto wrapup;
 if(!count) goto wrapup;

 if(count > StaticBuf)
  locvtxuse = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count *
		sizeof(OM_S_OBJECT_LINKAGE));
 else locvtxuse = locvtxusebuf;
 EMerr_hndlr(!locvtxuse, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 sts = om$get_channel_objects(object = me, p_chanselect = &to_vtxuse, 
       list = locvtxuse, size = count, count = &count);
 if(!(1&sts)) goto wrapup;

 *vtxuse = (GRobjid *) om$malloc(size = count * sizeof(GRobjid));
 EMerr_hndlr(!*vtxuse, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

 *num_vtxuse = 0;
 for(i=0; i<count; i++)
  (*vtxuse)[(*num_vtxuse)++] = locvtxuse[i].S_objid;

wrapup:
if(locvtxuse && (locvtxuse != locvtxusebuf)) om$dealloc(ptr = locvtxuse);
if(!(1&*EMmsg&sts) && vtxuse && *vtxuse)
 {
  om$dealloc(ptr = *vtxuse);
  *vtxuse = NULL;
  if(num_vtxuse) *num_vtxuse = 0;
 }

EMWRAPUP(*EMmsg, sts, "NMvertex.NMget_info");
return(sts);
}

end implementation NMvertex;
