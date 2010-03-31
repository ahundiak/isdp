class implementation SKgeometry;

#define STATIC_MAX_DEFPTS 3
#include <alloca.h>

void EMgetskvars (msg, options, md_env, geomid, skmgrid, num_vgpts, vgpts)
IGRlong *msg;
IGRushort options;
struct GRmd_env *md_env;
struct GRid *geomid;
struct GRid *skmgrid;
IGRint *num_vgpts;
GRobjid *vgpts;
{
  IGRboolean vgpts_present;
  IGRlong stat_OM, msg_loc;
  IGRint i;
  OMuint count;
  GRclassid geom_classid;
  GRobjid geom_mgr;
  OM_S_CHANSELECT chan_to_defpts;
  OM_S_OBJECT_LINKAGE *objlist, objlist_mem[STATIC_MAX_DEFPTS];
  extern void EMasptgrnd();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *num_vgpts = 0;

  objlist = NULL;

  om$get_classid (osnum = geomid->osnum, objid = geomid->objid,
   p_classid = &geom_classid);

  vgpts_present = FALSE;
  if (om$is_ancestry_valid (subclassid = geom_classid,
       superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS &&
      geomid->osnum == skmgrid->osnum)
    {
    om$send (msg = message SKgeometry.SKgetmgr (&msg_loc, &geom_mgr),
     targetid = geomid->objid, targetos = geomid->osnum,
     senderid = NULL_OBJID);

    if (geom_mgr == skmgrid->objid)
      vgpts_present = TRUE;
    }

  if (vgpts_present)
    {
    EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
    count = 0;
    om$get_channel_count (objid = geomid->objid, osnum = geomid->osnum,
     p_chanselect = &chan_to_defpts, count = &count);
    EMerr_hndlr (!count, *msg, EMS_E_InvalidCase, ret_end);

    if (count > STATIC_MAX_DEFPTS)
      objlist = stackalloc (count * sizeof (OM_S_OBJECT_LINKAGE));
    else
      objlist = objlist_mem;
    EMerr_hndlr (!objlist, *msg, EMS_E_NoDynamicMemory, ret_end);

    om$get_channel_objects (objid = geomid->objid, osnum = geomid->osnum,
     p_chanselect = &chan_to_defpts, count = &count, size = count,
     list = objlist);

    for (i=0; i<count; i++)
      vgpts[i] = objlist[i].S_objid;
    *num_vgpts = count;
    }
  else
    {
    EMasptgrnd (&msg_loc, NULL, md_env, geomid, skmgrid, num_vgpts, vgpts);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMgetskvars");
  return;
}

end implementation SKgeometry;

