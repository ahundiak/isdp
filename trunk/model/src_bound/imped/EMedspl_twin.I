/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

#include "EMS.h"
#include "EMSdef.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "emsinter.h"
#include "emssfint.h"

method EMsplit_twin(IGRlong         *EMmsg;
                    IGRint          num_parm;
                    struct GRmd_env *my_env;
                    IGRdouble       *parm;
                    IGRint          *split_num;
                    GRobjid         *edge_ids;
                    IGRboolean      *reverse)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date
	  SM		14-May-88	Made modifications forced by change
					in arguments to EMSedge.EMsplityourself
Algorithm
       
      This method splits my common edge at parameters corresponding
      to parms[]. Get my and my common edge's location. Get all the
      parameters on my common edge corresponding to parms[]. Split the 
      common edge at the first parameter or next  or next .. until a
      split is successful. Save the split edge depending on its 
      reversibility bit and also 'my location' on my loop. Split the 
      other split edge at its next parameter and repeat this process 
      for all the parameters on the common edge.
               Insert knot vectors on the common edge's surface at
      parameters where the common edge was split. Set the reversibility
      bit for all the split edges if the original edge's (common edge)
      bit was ON. Finally set the un-compatibility bit for the edge on
      the opposite side of the common edge to ON.  
*/
{
  IGRlong               stat_OM,msg;
  IGRboolean            proc_ind;
  IGRshort              my_edge_pos, com_edge_pos;
  IGRint                i;
  struct EMSedgebound   my_edge_info;
  struct EMSedgebound   *edge_info;
  struct EMSpartolbasis my_tol_info;
  GRobjid               comm_surf_id, my_surf = NULL_OBJID;
  GRobjid               top_edge, edgea[2];
  OM_S_CHANSELECT       to_common_edge;
  struct EMSsfintedpar	split_info, *split_info_ptr[2];

/*-------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *split_num = 0;
  proc_ind = FALSE;
  edge_info = NULL;
  split_info_ptr[0] = &split_info;
  split_info_ptr[1] = NULL;
  split_info.info = NULL;
  split_info.next = NULL;

  if (num_parm)
   {
    edge_info = (struct EMSedgebound *) om$malloc(size=num_parm *
                                        sizeof(struct EMSedgebound));
    EMerr_hndlr (! edge_info,*EMmsg,EMS_E_NoDynamicMemory, wrapup);
   }

  my_tol_info.tol = NULL;
  my_tol_info.is_valid = FALSE;
  my_tol_info.in_world = FALSE;
  my_tol_info.mattyp = &my_env->md_env.matrix_type;
  my_tol_info.mat = my_env->md_env.matrix;

  to_common_edge.type = OM_e_addr;
  to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;

  if(ME.EMSedge->ed_props & EMED_REVERSE_CONNECT)
     *reverse = TRUE;
  else 
     *reverse = FALSE;

  if (num_parm)
   {
    stat_OM = om$send(msg = message EMSedge.EMget_location(&msg,
                            &com_edge_pos),
                      p_chanselect = &to_common_edge);
    EMomerr_hndlr(stat_OM, wrapup, "EMedspl_twin.EMget_location");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

    stat_OM = om$send(msg = message EMSedge.EMget_location(&msg,
                            &my_edge_pos),
                      targetid = my_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedspl_twin.EMget_location");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }
  /* get the curve parameters of my common edge */                
  
  for (i=0; i<num_parm; i++)
   {    

    if (my_edge_pos == 0 || my_edge_pos == 1)
        my_edge_info.param = parm[i];
    else
        my_edge_info.param = 1 - parm[i];

    my_edge_info.span_inx = 0;

    stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                            &my_edge_info, &edge_info[i],
                            my_env, com_edge_pos, &my_surf, 
                            &comm_surf_id),
                      targetid = my_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedspl_twin.EMtwin_crv_parm");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  for (i=0; i<num_parm; i++)
   {
    /* get the top most edge which needs to be split */
    
    stat_OM = om$send(msg = message EMSedge.EMgettopedge (&msg,
                            &edge_info[i], &my_tol_info, &top_edge),
                      p_chanselect = &to_common_edge);
    EMomerr_hndlr(stat_OM, wrapup, "EMedspl_twin.EMgettopedge");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

    /* split the top most edge at app parameter */
    split_info.edgeid = top_edge;
    split_info.edgepar = edge_info[i];
    split_info.intloc = EMScvint_unknown;
    stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                          &edge_info[i], NULL, split_info.point),
                          targetid = top_edge);
    EMerr_hndlr(!(1&msg&stat_OM), *EMmsg, EMS_E_EdgeError, wrapup);

    stat_OM = om$send(msg = message EMSedge.EMsplityourself(&msg, 
                            split_info_ptr, NULL, NULL, edgea,
                            NULL, NULL, NULL, &my_tol_info,
                            my_env, NULL, NULL, NULL),
                      targetid = top_edge);
    EMomerr_hndlr(stat_OM, wrapup, "EMedspl_twin.EMsplityourself");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

    /* save the appropriate edge in edge_ids */

    if (edgea[0] != NULL_OBJID)
     {
      proc_ind = TRUE;
      if (my_edge_pos == 0 || my_edge_pos == 1)
       {
        if (! *reverse)
            edge_ids[*split_num] = edgea[0];
        else
            edge_ids[*split_num] = edgea[1];
       }
      else
       {
        if (! *reverse)
            edge_ids[*split_num] = edgea[1];
        else
            edge_ids[*split_num] = edgea[0];
       }
      (*split_num)++; 
     }
   }
if (proc_ind)
 {
  /*
   * store the last split edge in edge_ids which will not be split 
   * any further
   */

   if (my_edge_pos == 0 || my_edge_pos == 1)
    {
     if (! *reverse)
         edge_ids[*split_num] = edgea[1];
     else
         edge_ids[*split_num] = edgea[0];
    }
   else
    {
     if (! *reverse)
         edge_ids[*split_num] = edgea[0];
     else
         edge_ids[*split_num] = edgea[1];
    }

   (*split_num)++;

   /*
    * set the EMS_REVERSE_CONNECT property of the part edges
    * (split edges) to ON, if the original common edge's bit was
    * ON
    */ 

   if (*reverse)
    {
     for (i=0; i<(*split_num); i++)
      {
       stat_OM = om$send(msg = message EMSedge.EMset_props (&msg,
                               EMED_REVERSE_CONNECT, EMS_O_ON),
                         targetid = edge_ids[i]);
       EMomerr_hndlr(stat_OM, wrapup, "EMedspl_twin.EMset_props");
       EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
      }
    }

 }

wrapup:
  
   if(edge_info) om$dealloc(ptr = edge_info);
   return(stat_OM);
}

end implementation EMSedge;
