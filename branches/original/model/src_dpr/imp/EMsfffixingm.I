class implementation EMSsfboolfea;

#include "emsdef.h"
#include "EMSmsgdef.h"

method EMfixInGeomIds(IGRlong           *EMmsg; 
                      struct GRmd_env   *env;
                      IGRushort options)
/*
Description
    This message will handle special case of added geometry which is also 
    removed by the same operation.  The only known case of this is in the
    boolean feature class.  When invoked, this method deletes such surfaces.

Return Values    
    EMS_S_Success if all is well.

Notes
    options - None so far.

History
    DLB     09/03/91    Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  OMuint                  cnt, ii, jj, kk;
  GRobjid                 *sf_ids;
  union EMSssi_table      *ssi=NULL;
  struct EMSboolssi_table *my_info;
  OM_S_CHANSELECT         to_comps;
  OM_S_OBJECT_LINKAGE     *link_ids=NULL;

  
  *EMmsg = EMS_S_Success;

  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;  

  my_info = &ssi->bool_info;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_comps,
                                 count = &cnt);
  if (!(1 & OM_stat)) goto wrapup;

  link_ids = (OM_S_OBJECT_LINKAGE *) alloca(cnt * sizeof(OM_S_OBJECT_LINKAGE));
  if (!link_ids) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}
  
  OM_stat = om$get_channel_objects(object = me,
                                   p_chanselect = &to_comps,
                                   list = link_ids,
                                   size = cnt,
                                   count = &cnt);
  if (!(1 & OM_stat)) goto wrapup;                                   

  for(ii=1; ii<cnt; ii++)
  {
    sf_ids = my_info->surface_out_ids;
    for(jj=0; jj<my_info->num_composites; jj++)
    {
      if (link_ids[ii].S_objid == my_info->composite_ids[jj])
      {
        for(kk=0; kk<my_info->num_surfaces_out[jj]; kk++, sf_ids++)
        {
          OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                            targetid = *sf_ids);
          if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        }
      }
      else sf_ids += my_info->num_surfaces_out[jj];
    }
  }  

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "sfboolfea.fixInGmIds")
  return(OM_stat);
}
end implementation EMSsfboolfea;
