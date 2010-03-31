/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method performs the activation procedure for a sticth DPR
	node. The only entities affected by stitch are edges (not
	regions). Hence no display action is required.
	
History
	SM	06-Oct-88	Creation.
	SM	29-Sep-89	Use EFisAncestryValid to make sure ids
				are valid edges.
*/
	
class implementation EMSsfstitch;

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"

from EMSedge import EMget_props, EMconnect_edges;
extern OMuword OPP_EMSedge_class_id;

method EMactivate(IGRlong *EMmsg;IGRshort *option;
                  struct GRmd_env *env;
                  GRobjid **display_ids;
                  IGRint *display_count)
{
 IGRlong			sts;
 struct EMSstchssi_table	*my_info = NULL;
 IGRint				i;
 union EMSssi_table		*mod_table = NULL;
 IGRboolean			one_by_many = TRUE;
 extern void			EFrpl_old_new_eds();
 IGRushort		junkprops = NULL;
 extern IGRboolean		EFisAncestryValid();

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &mod_table),
                targetid = my_id);
 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

 my_info = &mod_table->stch_info;

 if(my_info->num_edges_out)
  {
   EFrpl_old_new_eds(EMmsg, my_info->num_edges_out, my_info->edges_out,
		    my_info->num_edges_in, my_info->edges_in, 
                    OM_Gw_current_OS, one_by_many, FALSE, TRUE);
   EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  
  }

 /* The edge connection needs to be done after edge replacement because
    reversibility check warrants that the edge(s) have accesss to the 
    surface. 
 */
 for(i=0; i<my_info->num_edges_connected; i+=2)
  {
   if(!EFisAncestryValid(EMmsg, my_info->edges_connected[i], 
			OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE) ||
      !EFisAncestryValid(EMmsg, my_info->edges_connected[i+1], 
			OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE))
	continue;
	
   /* We need to connect the edges i and i + 1 across the common edge
      channel. These edges were not split during this state since they match
      each other within tolerance.
      I have to get the props from the edge to which I am going to send
      EMconnect_edges message because that message does not let me pass 
      NULL and take props from instance data.
   */
   sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &junkprops), 
				targetid = my_info->edges_connected[i]);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

   sts = om$send(msg = message EMSedge.EMconnect_edges
			(EMmsg, 
			 junkprops, 
			 TRUE, /* test reversibility */
			 my_info->edges_connected[i+1], /*partner id*/
			 NULL_OBJID, /* srfid */
			 NULL_OBJID, /* partner srfid */
			 &env->md_env), 
		targetid = my_info->edges_connected[i]);
   EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_Fail, wrapup);

  }
wrapup:
if(mod_table) om$dealloc(ptr = mod_table);

EMWRAPUP(*EMmsg, sts, "In EMSsfstitch.EMactivate");
return(sts);
}

end implementation EMSsfstitch;
