/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method performs the deactivation procedure for a sticth DPR
	node. The only entities affected by stitch are edges (no regions).
	So no display action is required.
	
History
	SM	06-Oct-88	Creation.
	SM	30-Jun-89	Reverse the sequence of edges passed
				to EFreplace_old_new_edges().
	SM	29-Sep-89	Use EFisAncestryValid to make sure ids
				are valid edges.
*/

#ifndef	DEBUG
#define DEBUG	0
#endif

#if DEBUG
#define BufSize	1
#else
#define BufSize	100
#endif

class implementation EMSsfstitch;

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "OMmacros.h"


from EMSedge import EMset_props;
extern OMuword OPP_EMSedge_class_id;

method EMdeactivate(IGRlong *EMmsg; IGRshort *option;
                            struct GRmd_env *env;
                    GRobjid **display_ids; IGRint *display_count)
{
 IGRlong			sts;
 struct EMSstchssi_table	*my_info = NULL;
 IGRint				i;
 union EMSssi_table		*mod_table = NULL;
 OM_S_CHANSELECT		to_common_edge;
 IGRboolean			one_by_many = FALSE;
 extern void			EFrpl_old_new_eds();
 extern IGRint			EMmake_chanselect();
 IGRint				*numedsin = NULL, totaledsin = 0, num = 0, 
				numedsin_buf[BufSize];
 GRobjid			*edsout = NULL, *edsin = NULL, 
				edsout_buf[BufSize], edsin_buf[BufSize];
 extern IGRboolean		EFisAncestryValid();

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sts = EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);

 sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &mod_table),
                targetid = my_id);
 EMerr_hndlr(!(1&*EMmsg&sts),*EMmsg,EMS_E_Fail,wrapup);  

 my_info = &mod_table->stch_info;

 for(i=0; i<my_info->num_edges_connected; i+=2)
  {
   if(EFisAncestryValid(EMmsg, my_info->edges_connected[i], 
			OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE)) 
    {
     sts = om$send(msg = message EMSedge.EMset_props
	(EMmsg, EMED_SUBORDINATE | EMED_REVERSE_CONNECT, EMS_O_OFF), 
			targetid = my_info->edges_connected[i]);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
    }

   if(EFisAncestryValid(EMmsg, my_info->edges_connected[i + 1], 
			OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE)) 
    {
     sts = om$send(msg = message EMSedge.EMset_props
	(EMmsg, EMED_SUBORDINATE | EMED_REVERSE_CONNECT, EMS_O_OFF), 
			targetid = my_info->edges_connected[i + 1]);
     EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
    }

   if(EFisAncestryValid(EMmsg, my_info->edges_connected[i], 
			OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE)) 
    {
     sts = om$send(msg = message Root.wild_disconnect(to_common_edge), 
			targetid = my_info->edges_connected[i]);
     EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
    }

  }

 /*
  Scenario : edge 1 is replaced by edges 2 and 3. Later, during the same
  operation, edge 3 is replaced by edges 4 and 5. This information is
  sequentially stored in the save state data. While deactivating we need
  to follow a reverse sequence viz. remove 4 and 5 and put back 3 and then
  remove 2 and 3 and put back 1.
  To achieve the reverse sequence the data passed to EFrpl_old_new_eds()
  is reversed.
 */
 if(my_info->num_edges_out)
  {
   for(i=0; i<my_info->num_edges_out; i++)
    totaledsin += my_info->num_edges_in[i];

   if(my_info->num_edges_out > BufSize)
   {
    numedsin = (IGRint *) om$malloc
               (size = my_info->num_edges_out * sizeof(IGRint));
    edsout = (GRobjid *) om$malloc
             (size = my_info->num_edges_out * sizeof(GRobjid));
   }
   else
   {
    numedsin = numedsin_buf;
    edsout = edsout_buf;
   }

   if(totaledsin > BufSize)
    edsin = (GRobjid *) om$malloc(size = totaledsin * sizeof(GRobjid));
   else edsin = edsin_buf;

   EMerr_hndlr(!numedsin || !edsin || !edsout, *EMmsg, EMS_E_NoDynamicMemory, 
		wrapup);
   num = 0;
   for(i=my_info->num_edges_out-1; i>=0; i--)
    {
     edsout[num] = my_info->edges_out[i];
     numedsin[num++] = my_info->num_edges_in[i];
    }
   num = 0;
   for(i=totaledsin-1; i>=0; i--)
   edsin[num++] = my_info->edges_in[i];

   OM_BLOCK_MOVE(edsout, my_info->edges_out, my_info->num_edges_out *
			sizeof(GRobjid));
   OM_BLOCK_MOVE(numedsin, my_info->num_edges_in, my_info->num_edges_out *
			sizeof(IGRint));
   OM_BLOCK_MOVE(edsin, my_info->edges_in, totaledsin * sizeof(GRobjid));


   EFrpl_old_new_eds(EMmsg, my_info->num_edges_out, my_info->edges_out,
				my_info->num_edges_in, my_info->edges_in, 
					OM_Gw_current_OS, one_by_many,
					!(*option & EMS_UNDO_SAVE), TRUE);
 }

wrapup:
if(mod_table) om$dealloc(ptr = mod_table);
if(edsout && (edsout != edsout_buf)) om$dealloc(ptr = edsout);
if(edsin && (edsout != edsout_buf)) om$dealloc(ptr = edsin);
if(numedsin && (numedsin != numedsin_buf)) om$dealloc(ptr = numedsin);

EMWRAPUP(*EMmsg, sts, "In EMSsfstitch.EMdeactivate");
return(sts);
}

end implementation EMSsfstitch;
