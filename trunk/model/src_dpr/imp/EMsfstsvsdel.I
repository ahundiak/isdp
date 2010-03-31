/* ###################   APOGEE COMPILED   ################## */
/*
History

        SM      20th Century    Creation date.
        SM      29-Sep-1989     Ignore any ids in my instance data
                                which are not valid or which are not
                                edges as a safety check.
        DLB     3/27/91         Don't reset instance data if ssi is coming in.
        DLB     6/27/91         Also dont disconnect common edges if ssi is
                                coming in.
*/

class implementation EMSsfstitch;

#include "EMSopt.h"

from EMSedge import EMset_props;
extern OMuword OPP_EMSedge_class_id;

method EMsavestatedelete(IGRlong *EMmsg; struct GRmd_env *my_env;
                         union EMSssi_table *ssi)
{
 IGRlong                        sts;
 union EMSssi_table             *mod_table = NULL;
 struct EMSstchssi_table        *my_info = NULL;
 IGRint                         i, j;
 OM_S_CHANSELECT                to_common_edge;
 extern IGRint                  EMmake_chanselect();
 extern IGRboolean              EFisAncestryValid();

 sts = EMmake_chanselect(EMSedge_to_common_edge, &to_common_edge);

 if (!ssi)
 {
   sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &mod_table),
                 targetid = my_id);
   if (! (1 & sts & *EMmsg)) goto wrapup;
 }
 else
   mod_table = ssi;

 my_info = &mod_table->stch_info;

 if (ME.EMSdpr->dpr_props & EMSIS_ACTIVE_PATH)
  {
   /* Delete all out edges */

   for(i=0; i<my_info->num_edges_out; i++)
    {
     if(!EFisAncestryValid(EMmsg, my_info->edges_out[i], OM_Gw_current_OS, 
                           OPP_EMSedge_class_id, TRUE)) continue;
                        
     sts = om$send(msg = message Root.delete(NULL), 
                targetid = my_info->edges_out[i]);
     if(!(1&sts)) goto wrapup;
    }

  }  
 else
 {
   /* Delete all in edges */
   
   GRobjid      *id;

   id = my_info->edges_in;
   for(i=0; i<my_info->num_edges_out; i++)
   {
     for(j=0; j<my_info->num_edges_in[i]; j++, id++)
     {
       if(!EFisAncestryValid(EMmsg, *id, OM_Gw_current_OS, 
                             OPP_EMSedge_class_id, TRUE)) continue;
                        
       sts = om$send(msg = message Root.delete(NULL), 
                     targetid = *id);
       if(!(1&sts)) goto wrapup;
     }
   }

   if (!ssi)
   {
     /* Disconnect all the common edge connections */

     for(i=0; i<my_info->num_edges_connected; i+=2)
     {
       if(EFisAncestryValid(EMmsg, my_info->edges_connected[i], 
                            OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE)) 
       {         
         sts = om$send(msg = message EMSedge.EMset_props(EMmsg,
                             EMED_SUBORDINATE | EMED_REVERSE_CONNECT,
                             EMS_O_OFF), 
                       targetid = my_info->edges_connected[i]);
         EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);

         sts = om$send(msg = message Root.wild_disconnect(to_common_edge), 
                       targetid = my_info->edges_connected[i]);
         EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
       }
 
       if(EFisAncestryValid(EMmsg, my_info->edges_connected[i + 1], 
                            OM_Gw_current_OS, OPP_EMSedge_class_id, TRUE)) 
       {
         sts = om$send(msg = message EMSedge.EMset_props(EMmsg,
                             EMED_SUBORDINATE | EMED_REVERSE_CONNECT,
                             EMS_O_OFF), 
                       targetid = my_info->edges_connected[i + 1]);
         EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_EdgeError, wrapup);
       }
     }
   }
 }

 if (!ssi) ME.EMSsfstitch->num_edges_out = 0;

wrapup:
  if (mod_table && !ssi) om$dealloc(ptr = mod_table);
  EMWRAPUP(*EMmsg, sts, "sfst.svstdel");
  return(sts);
}
end implementation EMSsfstitch;
