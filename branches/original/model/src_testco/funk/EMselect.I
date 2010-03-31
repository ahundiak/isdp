/*
 * This was written by Chopra.

22 May 1989 jBk Replaced invocations of GRgetevent with uses of
                co$getevent.

 * 10/13/88 : dhm : Changed to display the level and type in status field.
 * 05/13/87 : rlw : Changed EMlc_stack to GRlc_stack
 *                  Removed inclusion of EMlc.h
 * 05/14/87 : rlw : Reworked.  The basic problem was that this routine
 *                  was not decrementing the number of stack entries
 *                  as it went along or really ever.  The causes problems
 *                  in the command object.
 * 12/09/87 : RC  : Modified for version 1.1.0
 */

#define TRUE    1
#define FALSE   0

class implementation Root;

#include "EMS.h"
# include "OMminimum.h"
# include "OMerrordef.h"
# include "igetypedef.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "msdef.h"
# include "emsmacros.h"
# include "emsdef.h"
# include "emserr.h"
# include "EMSmsgdef.h"
# include "exdef.h"     /* GRm_RJT_MOVEON */
# include "ex.h"        /* needed by grio.h */
# include "griodef.h"   /* GR_UNKNOWN_TYPE, GRm_RESET */
# include "grio.h"      /* GRevent */
# include "lcdef.h"
# include "lc.h"
# include "griomacros.h"    /* co$getevent */
# include "EC_M.h"
# include "EC_I.h"
# include "msmacros.h"

#define st_mod     stack->entry[stack->num_entries - 1].module_info
#define st_ent     stack->entry[stack->num_entries - 1]

from GRgraphics import GRdisplay;

IGRint  EMselect (msg, mask, size, response, 
            response_data, accept_event, obj_hilited, stack, acc_prompt)

IGRlong                 *msg;
IGRlong                 *mask;
IGRint                  *size;
struct  GRevent         *accept_event;
IGRint                  *response;
IGRchar                 *response_data;
IGRchar                 *obj_hilited;
struct GRlc_stack       *stack;
IGRchar                 *acc_prompt;
                                  
{

 IGRlong          OM_stat, mthd_stat /*, new_mask */;
 IGRint           status;
 IGRchar          stat_str[50];
 IGRboolean       object_accepted = FALSE;
 enum GRdpmode    display_mode;

 *msg = MSSUCC;
 OM_stat = OM_S_SUCCESS;
 ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
            in_buff = acc_prompt);

 do
 {
    /*
     * Get the type and level for display to the status field.
     * dhm   10/13/88.
     */

    LCget_info(st_ent.located_obj.objid, st_ent.located_obj.osnum,
               stat_str);

    /*
     *   Highlight the element
     */

    display_mode = GRbdhd;  /* Draw the element in highlight */
    OM_stat = om$send (mode = OM_e_wrt_object, 
                       msg = message GRgraphics.GRdisplay (
                        &mthd_stat, 
                        &(st_mod.md_env.matrix_type),
                         st_mod.md_env.matrix, &display_mode,
                        &st_mod.md_id),
                       senderid = NULL_OBJID,
                       targetid = st_ent.located_obj.objid,
                       targetos = st_ent.located_obj.osnum);

    EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg, EMS_E_Fail,wrapup);

    *obj_hilited = TRUE;
/*
    new_mask = *mask | GRm_RJT_MOVEON;
*/
    ex$message(field = ERROR_FIELD, in_buff = stat_str);
/*
    status = GRgetevent (&mthd_stat, &new_mask, size, accept_event, 
                          response, response_data);
*/
    status = co$getevent (
        msg = &mthd_stat,
        event_mask = *mask | GRm_RJT_MOVEON,
        response = response,
        response_data = response_data,
        event = accept_event
    );

    EMerr_hndlr (!(1&status&mthd_stat),*msg,EMS_E_Fail,wrapup);

    switch (accept_event->response)
    {
        
      /* 
       *  The case of the rejected object
       *  unhilight and increment stack if possible
       */

      case EX_RJT_MOVEON:
      case EX_BACK_UP:

        display_mode = GRbdhe;
        OM_stat = om$send (mode = OM_e_wrt_object, 
                           msg = message GRgraphics.GRdisplay (
                            &mthd_stat, 
                            &(st_mod.md_env.matrix_type),
                             st_mod.md_env.matrix, &display_mode,
                            &st_mod.md_id),
                           senderid = NULL_OBJID,
                           targetid = st_ent.located_obj.objid,
                           targetos = st_ent.located_obj.osnum);

        EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail,wrapup);

        *obj_hilited = FALSE;
        --stack->num_entries;
        break;

                        
      case GR_UNKNOWN_TYPE:
        *msg = 0;
        break;
        
      default:
        /*
         * if the response is neither RESET nor
         * GR_UNKNOWN_TYPE, it is an indication
         * of accepted object.
         */

        *msg = 1;
        accept_event->located_object[0].located_obj =
        stack->entry[stack->num_entries - 1].located_obj;

        accept_event->located_object[0].module_info =
        stack->entry[stack->num_entries - 1].module_info;

        object_accepted = TRUE;
        stack->num_entries = 0;
        break;

    } /* switch (accept_event->response) */

} while ( stack->num_entries && 
          accept_event->response == RESET);

        
wrapup:

  if ( *obj_hilited && ( !(1 & OM_stat) || !(1 & mthd_stat) ||
                                        !object_accepted) )

  {
    display_mode = GRbdhe;
                                        
    OM_stat = om$send (mode = OM_e_wrt_object, 
                       msg = message GRgraphics.GRdisplay (
                        &mthd_stat, &(st_mod.md_env.matrix_type),
                         st_mod.md_env.matrix,
                        &display_mode,
                        &st_mod.md_id),
                       senderid = NULL_OBJID,
                       targetid = st_ent.located_obj.objid,
                       targetos = st_ent.located_obj.osnum);


        *obj_hilited = FALSE;
     }
        
   if (accept_event->response == EX_RJT_MOVEON)
           accept_event->response = response[0] = EX_BACK_UP;

    return( OM_stat );
}

end implementation Root;
