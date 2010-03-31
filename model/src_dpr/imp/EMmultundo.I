/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

/* HISTORY
   
  AMD       04/05/90          Creation Date

*/

#include <stdio.h>
#include "EMS.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "EMSdpr.h"
#include "EMSprop.h"
#include "OMmacros.h"

#define TRUE 1

from EMSsfboolean import EMget_operation_type;

method EMmult_undo(IGRlong           *EMmsg;
                   IGRushort *option;
                   struct GRmd_env   *my_env;
                   struct GRid       **active_state; 
                   IGRint            *num, 
                                     *buff_size;
                   GRobjid           **display_ids;
                   IGRint            *display_count,
                                     *invoke_count)

{
 IGRlong            sts,rc;
 IGRint             i,j, count = 3;
 IGRushort          mult_union;
 OM_S_CHANSELECT    to_comps;
 OM_S_OBJID         local_id, next_obj;
 OMuword            osnumaddr;
 IGRboolean         wrap_up;
 enum GRdpmode      display_mode;
 enum EMSbooltype   exact_type;

 *EMmsg = EMS_S_Success;
 sts = OM_S_SUCCESS;
 *option = EMS_DONT_REDRAW | EMS_DO_DISPLAY;

/* if operation_type is disjoint-difference boolean then get the objid
of the multiple_union node from the SSI table */

 sts = om$send ( msg = message EMSsfboolean.EMget_operation_type (
                               EMmsg,
                               NULL,
                               &exact_type,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL,
                               NULL ),
                   targetid = my_id );
 if ( !(1 & sts) ) goto wrapup;
     if( exact_type == EMSbool_disjointD)
            {
              union EMSssi_table            *ssi;
              struct EMSboolssi_table       *my_info;
              GRobjid                       *sf_rem_id;            
              ssi = NULL;
              sts = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                            targetid = my_id);
              my_info = &ssi->bool_info;
              sf_rem_id = &my_info->surface_out_ids[0];
              local_id = *sf_rem_id;

              sts = om$send(msg = message EMSdpr.EMundo(
                        EMmsg,
                        option,
                        my_env,
                        active_state,
                        num,
                        NULL,
                        display_ids,
                        display_count,
                        invoke_count),
                  targetid = my_id);
             }
      else
              local_id = my_id;

 sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

  do
   {
    for ( i=0; i < count; i++)
     {
  /* Check for the EMS_MULT_BOOL bit */
       sts = om$send( msg = message EMSdpr.EMget_dpr_props( 
                           EMmsg , &mult_union ),
                      p_chanselect = &to_comps,
                      from = i, to = i,
                      senderid = local_id);
       if (mult_union & EMS_MULT_BOOL) 
       {
       sts = om$get_objid_at_index(
                      objid = local_id,                       
                      p_chanselect = &to_comps,
                      index = i,
                      objidaddr = &next_obj,
                      osnumaddr = &osnumaddr);
       if ( !(1 & sts) ) goto wrapup;
       break;
       }
     }

      /* Undo */

       {
        *option = EMS_DONT_REDRAW | EMS_DO_DISPLAY;
        sts = om$send(msg = message EMSdpr.EMundo(
                        EMmsg,
                        option,
                        my_env,
                        active_state,
                        num,
                        NULL,
                        display_ids,
                        display_count,
                        invoke_count),
                  targetid = local_id,
                  targetos = OM_Gw_current_OS,
                  senderid = NULL_OBJID);
       if ( !(1 & sts) ) goto wrapup;
         }
     local_id = next_obj;

     }while(TRUE);

 
wrapup:
/* Perform the display now */
     display_mode = GRbd;
     for (i=0; i<*display_count; i++)
     {
       {
         sts = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
                                 &my_env->md_env.matrix_type,
                                 my_env->md_env.matrix, &display_mode,
                                 &my_env->md_id),
                           targetid = (*display_ids)[i]);
       }
     }

      if (*display_ids) 
      { 
        om$dealloc(ptr = *display_ids);
        display_ids = NULL;
      }

  return(OM_S_SUCCESS);

}
end implementation EMSdpr; 
