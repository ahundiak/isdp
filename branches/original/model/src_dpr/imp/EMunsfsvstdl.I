class implementation EMSsfunitesf;

#include "EMS.h"
/* IF_NULL_OBJID, om$dimension_of */
# include "OMmacros.h"

/*

HISTORY

  07/14/92  :  AMD  :  Creation

*/

method EMsavestatedelete (IGRlong *EMmsg; struct GRmd_env *my_env;
                          union EMSssi_table *ssi)
{
 IGRlong               OM_stat;
 union EMSssi_table    *mod_table;
 struct EMSunssi_table *my_info;
 IGRint                i, j, k;


 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;
 mod_table = NULL;
 
 if (!ssi)
 {
   /*Get the table of objects to delete from me.*/
   OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &mod_table),
                     targetid = my_id);
   if (! (1 & OM_stat & *EMmsg)) goto wrapup;
 }
 else
   mod_table = ssi;

 my_info = &mod_table->un_info;

 if (!(ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH))
 {
  if (!ssi)
   {
     /*Delete all added surfaces.*/

      GRobjid  new_plane;
      GRspacenum dumosnum;
      OM_S_CHANSELECT to_comps;
      OMuint  count=0;

      EMmake_chanselect( GRcmpowner_to_components, &to_comps);

      OM_stat = om$get_channel_count(object = me,
                                     p_chanselect = &to_comps,
                                     count = &count); 
      EMerr_hndlr( !(1 & OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

      if(count == 2)
      {
       OM_stat = om$get_objid_at_index ( objid = my_id,
                                         p_chanselect = &to_comps,
                                         index = 1,
                                         objidaddr = &new_plane,
                                         osnumaddr = &dumosnum);
       EMomerr_hndlr (OM_stat, wrapup, "om$get_objid_at_index");  

       OM_stat = om$send (msg = message GRgraphics.GRdelete(EMmsg, my_env), 
                          targetid = new_plane);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;
      }
   }
 } /*end else*/

 if (!ssi)
 {
   /*Reset the instance data*/

   ME.EMSsfregmod->num_surfaces = 0;
   ME.EMSsfunitesf->num_composites = 0;
   ME.EMSsfunitesf->num_edges = 0;
 }
 
 wrapup:
  if (mod_table && !ssi) om$dealloc(ptr = mod_table);
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsfunitesf.EMsavestatedelete");
  return(OM_stat);

}
end implementation EMSsfunitesf;
