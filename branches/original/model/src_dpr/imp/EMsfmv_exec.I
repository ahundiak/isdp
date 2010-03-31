/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfmove;

#include "EMS.h"
#include "emsdef.h"
#include "EMSbnddef.h"
#include "EMSlm.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"

from EMSboundary import EMgetsurface_info;
from EMSsubbs import EMexeinst;

method EMmove_execute (IGRlong         *EMmsg;
                       IGRpoint        from_point,
                                       to_point;
                       struct GRmd_env *my_env;
                       IGRshort        *option;
                       GRobjid         **display_ids;
                       IGRint          *display_count)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
                - EMS_E_Fail (severe) if failure

Assumption

Bugs

History
        
          gupta         05/04/87:       design date
                        10/19/87:       major modification for new system
Algorithm

      This method accumulates the exec instruction info belonging to
      the same loop and executes these instructions through EMexeinst.

*/

{
 IGRlong                  stat_OM, msg;
 IGRshort                 i, j;
 IGRint                   loop_count, inst_no;
 IGRvector                vector;
 struct                   EMinstruction_table_info *instructions;
 GRobjid                  new_surf_id, surf_id;

/*----------------------------------------------------------------*/
 
 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;

 instructions = NULL;

 loop_count = OM_DIMENSION_OF(ME.EMSdpr->ids);
 
 for (i=0 ; i < 3 ; i++)
  {
    vector[i] = to_point[i] - from_point[i];
  }

 for (i=0; i<loop_count; i++)
  {
   instructions = NULL;
   inst_no = 0;

   instructions = (struct EMinstruction_table_info *) om$malloc (size =
                   ME.EMSsfmove->no_of_instructions *
                              sizeof(struct EMinstruction_table_info));

   for (j=0; j<ME.EMSsfmove->no_of_instructions; j++)
    {
     if (ME.EMSsfmove->exec_info[j].index == i)
      {
       instructions[inst_no] = ME.EMSsfmove->exec_info[j].instruction;
       inst_no ++;
      }
    }
  
   /* Get the surface id corresponding to the loop */ 

   stat_OM = om$send (msg = message EMSboundary.EMgetsurface_info(&msg,
                            &surf_id, NULL),
                      targetid = ME.EMSdpr->ids[i]);
   EMomerr_hndlr(stat_OM, wrapup, "EMlmmv_exec.EMgetsurf_info");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_LoopError, wrapup);

   if (*option & EMS_DO_DISPLAY)
   {
     IGRint      inx;          /*DECLARE*/
     enum GRdpmode display_mode = GRbehe;
     IGRboolean  got_it = FALSE;    

     /*Has the added surface already been erased?*/
     for (inx=0; inx<*display_count; inx++)
     {
       if ( (*display_ids)[inx] == surf_id)
       {
         got_it = TRUE;
         break;
       }
     }

     if (!got_it)
     {
       stat_OM = om$send(msg = message GRgraphics.GRdisplay(&msg,
                               &my_env->md_env.matrix_type, 
                               my_env->md_env.matrix, &display_mode,
                               &my_env->md_id),
                         targetid = surf_id);
       EMerr_hndlr(!(1&stat_OM&msg), *EMmsg, msg, wrapup);
  
       /**Store modified id**/
       EFrealloc_if_needed(EMmsg, display_ids, *display_count, 
                           DPR_DISPLAY_BUFF_INCR, sizeof(GRobjid));
       if (!(1 & *EMmsg)) goto wrapup;

       (*display_ids)[*display_count] = surf_id;
       (*display_count)++;
     }
   }

   /* execute the instructions -- change the surface geometry */

   stat_OM = om$send(msg = message EMSsubbs.EMexeinst(&msg, vector,
                           my_env, inst_no, &new_surf_id, instructions),
                     targetid = surf_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMlmmv_exec.EMexeinst");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
  
   if (instructions) om$dealloc(ptr = instructions);
  }

 for (i=0; i < 3 ; i++)
  {
    ME.EMSsfmove->from_point[i]  = from_point[i];
    ME.EMSsfmove->to_point[i]  = to_point[i];
    
  }

wrapup:

 return(stat_OM);
}

end implementation EMSsfmove;
