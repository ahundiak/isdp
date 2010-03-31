class implementation SKgeometry;

#define NUM_STATIC 5

extern GRclassid OPP_SKmgr_class_id, OPP_SKgeometry_class_id;

method SKgetmgr (IGRlong *msg; GRobjid *mgrid)
{
  IGRint i;
  OMuint  count;
  IGRlong stat_OM;
  GRclassid ownerclass;
  OM_S_CHANSELECT chan_to_owner;
  OM_S_OBJECT_LINKAGE *objlist, objlist_mem[5];

  *msg = EMS_I_NotFound;
  stat_OM = OM_S_SUCCESS;

  objlist = NULL;

  stat_OM = om$make_chanselect (channame = "GRconnector.to_owners", 
   p_chanselect = &chan_to_owner);
  EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);

  stat_OM = om$get_channel_count (object = me, p_chanselect = &chan_to_owner,
   count = &count);
  EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_OMerror, ret_end);
  
  if (count)
   {
    if (count > NUM_STATIC)
       objlist = (OM_S_OBJECT_LINKAGE *) om$malloc (size = count * 
                                       sizeof (OM_S_OBJECT_LINKAGE));
    else
       objlist = objlist_mem;

    EMerr_hndlr (!objlist, *msg, EMS_E_NoDynamicMemory, ret_end);
  
    om$get_channel_objects (object = me, p_chanselect = &chan_to_owner,
       count = &count, size = count, list = objlist);
  
    for (i=0; i<count; i++)
      {
      om$get_classid (objid = objlist[i].S_objid, p_classid = &ownerclass);

      stat_OM = om$is_ancestry_valid (subclassid = ownerclass,
                 superclassid = OPP_SKmgr_class_id);
      if (stat_OM == OM_S_SUCCESS)
        {
        *mgrid = objlist[i].S_objid;
        *msg = EMS_I_Found;
        goto ret_end;
        }
      else
        {
          stat_OM = om$is_ancestry_valid(subclassid = ownerclass,
                                        superclassid = OPP_SKgeometry_class_id);
          if(stat_OM == OM_S_SUCCESS)
          {
            om$send (msg = message SKgeometry.SKgetmgr (msg, mgrid),
                    targetid = objlist[i].S_objid);
            if(*msg == EMS_I_Found)
              goto ret_end;
          }
          else
          {
           stat_OM = OM_S_SUCCESS; 
           continue;
          }
        }
      }
   }
    
ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgeometry.SKgetmgr");
  return (stat_OM);
}

end implementation SKgeometry;
