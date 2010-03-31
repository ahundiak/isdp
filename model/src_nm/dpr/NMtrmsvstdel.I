class implementation NMtrim;

#include "nddef.h"

from NMinters import NMget_inters;
extern OMuword OPP_NMinters_class_id;

method EMsavestatedelete (IGRlong *EMmsg; struct GRmd_env *my_env;
                          union EMSssi_table *ssi)
{
 IGRlong		sts = OM_S_SUCCESS;
 union EMSssi_table	*mod_table = NULL;
 IGRboolean		active;
 IGRint                 i, j, count = 0;
 GRobjid                *id;
 struct EMSboolssi_table *my_info;
 IGRint			NMdisconnect_edges();
 struct EMSinters	*inters[2];
 OM_S_CHANSELECT	to_ed, to_lp;
 union EMSparent_info  	roots[2];
 unsigned int	root_type[2];
 struct GRid		parents[2], src;

 *EMmsg = EMS_S_Success;
 inters[0] = inters[1] = NULL;
 active = ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH;

 if (!ssi)
  {
   sts = om$send(msg = message EMSdpr.EMgetSSI (EMmsg, &mod_table),
         targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }
 else
  mod_table = ssi;

 my_info = &mod_table->bool_info;

 /* Get my source object for the intersection data
 */
 sts = om$send(msg = message NDnode.NDget_objects(ND_ROOT, parents, 2, NULL, 0,
       MAXINT, &count), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;
 if(count)
  {
   root_type[0] = root_type[1] = EMSgrid;
   sts = om$send(msg = message EMSassoc.EMget_parent_info(EMmsg, NULL, count, 
         (IGRchar *) parents, root_type, roots), targetid = my_id);
   if(!(1&*EMmsg&sts)) goto wrapup;
   src = roots[SrcIdx].grobj.grid;

   /* Get the intersection data.
   */
   sts = om$send(msg = message NMinters.NMget_inters(EMmsg, &inters[0], 
         &inters[1], NULL, NULL, NULL, NULL, NULL), targetid = src.objid, 
         targetos = src.osnum);
   if(!(1&*EMmsg&sts)) goto wrapup;

   /* For all the loops which are to be deleted (loops in or loops out), 
      disconnect the edges provided by my inters src object. I didn't create
      them so I ain't deleting them.
   */
   sts = EMmake_chanselect(EMSbd_owner_to_comps, &to_ed);
   sts = EMmake_chanselect(EMSedge_to_owner, &to_lp);
   if (active)
    {
     /* loops out are to be deleted
     */
     id = my_info->region_out_ids;
     for (i = 0; i < my_info->num_surfaces; i++)
      for (j = 0; j < my_info->num_regions_out[i]; j++)
       {
        sts = NMdisconnect_edges(EMmsg, inters, id, &to_ed, &to_lp);
        if(!(1&*EMmsg&sts)) goto wrapup;
        id++;
       }
    }
   else
    {
     /*loops in are to be deleted
     */
     id = my_info->region_in_ids;
     for (i = 0; i < my_info->num_surfaces; i++)
      for (j = 0; j < my_info->num_regions_in[i]; j++)
       {
        sts = NMdisconnect_edges(EMmsg, inters, id, &to_ed, &to_lp);
        if(!(1&*EMmsg&sts)) goto wrapup;
        id++;
       }
    } 

  } /* if count */
 
 /* Do not send the ssi even if obtained here, because the following method
    may do something different based on whether there is ssi incoming. So
    pass on whatever this method got.
 */
 sts = om$send(mode = OM_e_wrt_message, 
       msg = message EMSsfboolean.EMsavestatedelete (EMmsg, my_env, ssi),
       targetid = my_id);

 if (!ssi)
  {
   /* Reset the instance data */
   ME.EMSsfregmod->num_surfaces = 0;
   ME.EMSsfboolean->num_composites = 0;
  }

wrapup:
if (mod_table && !ssi) om$dealloc (ptr = mod_table);
for(i=0; i<2; i++)
 if(inters[i])
  {
   IGRlong rc;

   if(!inters[i]) continue;
   (void) NMset_object_data_to_null(inters[i], TRUE, TRUE);
   EMinters_data_free(&rc, inters[i], MAXINT, NULL, NULL);
   EMinters_free(inters[i], MAXINT);
  }
EMWRAPUP(*EMmsg, sts, "NMtrim.EMsavestatedelete");
return(sts);
}

end implementation NMtrim;
