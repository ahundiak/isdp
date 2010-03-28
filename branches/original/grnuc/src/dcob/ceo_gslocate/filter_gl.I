/* ceo_gslocate/filter_gl.I */
class implementation CEO_GSLOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif

method filter (
  int	  filter;
  int   * response;
  char	* response_data )
{
  int		   status;
  char             msgbuff[MS_MAX_MSG_LENGTH];

  IGRboolean aflag=0;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_instance		* p_CEO		 = ME.CEO;
  struct CEO_LOCATE_instance	* p_CEO_LOCATE   = ME.CEO_LOCATE;
  struct CEO_GSLOCATE_instance	* p_CEO_GSLOCATE = ME.CEO_GSLOCATE;

  _bugprint(bflag = TFLAG, str = "+CEO_GSLOCATE.filter: = %d\n",var = filter)
  p_CEO->ret = OM_S_SUCCESS;

  switch ( filter )
   {
      case _gs_locate:
	_bugprint(bflag = CEO_GSLOCATE_debug, str =
	    "filter = _gs_locate = %d\n", var = filter)

			/*** dpmode = GRbdhe, --JAJ:06-02-88 ***/
	status = gr$gsdisplay ( msg = &p_CEO->ret, dpmode = GRhe,
			p_chanselect = &p_CEO_LOCATE->located_chansel );
	_bugprint(bflag = CEO_GSLOCATE_debug, str =
	    "After gr$gsdisplay():  me->ret = %d, status = %d\n",
	    var = `p_CEO->ret, status` )
#ifdef DEBUG
        _cob_check2 ( status, p_CEO->ret, \
		"CEO_GSLOCATE.filter:  gr$gsdisplay() failed." );
#endif

	status = gr$gsempty ( msg = &p_CEO->ret,
			p_chanselect = &p_CEO_LOCATE->located_chansel );
	_bugprint(bflag = CEO_GSLOCATE_debug, str =
	    "After gr$gsempty():  me->ret = %d, status = %d\n",
	    var = `p_CEO->ret, status` )
#ifdef DEBUG
        _cob_check2 ( status, p_CEO->ret, \
		"CEO_GSLOCATE.filter:  gr$gsemtpy() failed." );
#endif

        /* _no_break; */

      case _gs_locate_noauto:
	_bugprint(bflag = CEO_GSLOCATE_debug, str =
	    "filter = _gs_locate_noauto = %d\n", var = filter)
        if ( !p_CEO->prompt [0] )
        {
          ex$message(msgnumb = GR_P_EntLocPnt, buff = msgbuff);
          strcpy ( p_CEO->prompt, msgbuff );
        }
        if ( !p_CEO_LOCATE->acc_prompt [0] )
        {
          ex$message(msgnumb = GR_P_Acc, buff = msgbuff);
          strcpy ( p_CEO_LOCATE->acc_prompt, msgbuff );
        }
        if ( !p_CEO_LOCATE->reloc_prompt [0] )
        {
          ex$message(msgnumb = GR_I_EleNotFound, buff = msgbuff );
          strcpy ( p_CEO_LOCATE->reloc_prompt, msgbuff );
        }

        /* Fix for delete and move in RFA. Put in the action handler to 
         * disallow selection of objects in deactivated os. The action
         * handler is always set to NULL in the case of delete and move
         * cmd. Therefore it looks safe to put our own. Well, we know
         * what to remove in case something blows up.
         * Added for Element Locate On/Off and Element display On/Off
         * -- bbkr 26/02/97  
         */

        aflag=pwIsActivationOn();
        if(aflag && 
          ((p_CEO_LOCATE->attributes.owner_action & LC_DELETE_CMD) ||
          (p_CEO_LOCATE->attributes.owner_action & LC_MOVE_CMD)    ||
          (p_CEO_LOCATE->attributes.owner_action &LC_NON_GEOM_MOD)))
        {
         GRspacenum osn;
         extern IGRlong RFlocate_ref_objects_handler();
         osn = pwGetActiveOs();
         
           if((p_CEO_LOCATE->attributes.owner_action & LC_NON_GEOM_MOD)||
              (p_CEO_LOCATE->attributes.owner_action & LC_MOVE_CMD)) 
               p_CEO_LOCATE->attributes.owner_action |= LC_REF_OBJECTS; 

        status = gr$gslocate (
            msg = & p_CEO->ret,
            eventsize = p_CEO_LOCATE->event_size, /* DON'T use the address here */
            event1 = & p_CEO_LOCATE->event2,
            event2 = & p_CEO_LOCATE->event1,
            mask1 = p_CEO_LOCATE->event_mask2,
            mask2 = p_CEO_LOCATE->event_mask1,
	    nbytes1 = & p_CEO_LOCATE->nbytes2,	/*** JAJ:04-21-88 ***/
	    nbytes2 = & p_CEO->nbytes1,	/*** JAJ:04-21-88 ***/
            stack = & p_CEO_LOCATE->stack,
            locate_prompt = p_CEO->prompt,
            acc_prompt = p_CEO_LOCATE->acc_prompt,
            relocate_prompt = p_CEO_LOCATE->reloc_prompt,
            display_flag = p_CEO_LOCATE->display_flag,
            dyn = p_CEO_LOCATE->dyn,
            type = p_CEO_LOCATE->type,
	    rtree_classes = p_CEO_LOCATE->locate_rtree,
	    eligible_classes = p_CEO_LOCATE->locate_eligible,
            attributes = & p_CEO_LOCATE->attributes,
	    action_handler = RFlocate_ref_objects_handler,
	    action_args	= &osn,
	    regex	= p_CEO_LOCATE->regex,
	    stack_size  = p_CEO_LOCATE->stack_size,
	    select	= p_CEO_LOCATE->select,
	    select_args = p_CEO_LOCATE->select_args,
	    locate_event  = & p_CEO_LOCATE->event3,	/*** JAJ:08-24-87 ***/
	    locate_state  = & p_CEO_GSLOCATE->locate_state,	/*** (args peculiar ***/
	    num_inputs    = p_CEO_GSLOCATE->num_inputs,	/***  to gslocate ) ***/
	    input1_mask   = p_CEO_GSLOCATE->spec_mask1,
	    input2_mask   = p_CEO_GSLOCATE->spec_mask2,
	    input1_prompt = p_CEO_GSLOCATE->spec_prompt1,
	    input2_prompt = p_CEO_GSLOCATE->spec_prompt2,
	    p_chanselect  = & p_CEO_LOCATE->located_chansel,
	    hilight_mode  = p_CEO_LOCATE->HilightMode,	      /* JAJ:04-21-88 */
	    unhilight_mode= p_CEO_LOCATE->UnhilightMode,      /*  " " " "     */
	    range_handler = p_CEO_LOCATE->range_handler,      /* JAJ:11-01-88 */
	    range_args	  = p_CEO_LOCATE->range_args,	      /*  " " " "     */
	    value_type1   = p_CEO_LOCATE->value_type_locate,  /* JAJ:12-19-88 */
	    value_type2   = p_CEO_LOCATE->value_type_accept,  /* JAJ:12-19-88 */
	    scale_flag	  = p_CEO_LOCATE->scale_flag );	      /* JAJ:05-22-89 */
        }
        else
        {
          /* EMS 3.3 PLoad Show Stopper fix - Delete command sets the 
           * LC_REF_OBJECTS bit unconditionally. This allowed objects in
           * attached reference files to be deleted. A cleaner fix would be 
           * to remove the bit in the Delete command and add it in locate as 
           * in Move (See the 'if' of this 'else').  
           */
 
          if (p_CEO_LOCATE->attributes.owner_action & LC_DELETE_CMD)
          {
            if ( p_CEO_LOCATE->attributes.owner_action & LC_REF_OBJECTS)
            {
               p_CEO_LOCATE->attributes.owner_action &= ~LC_REF_OBJECTS;
            }
          }

        status = gr$gslocate (
            msg = & p_CEO->ret,
            eventsize = p_CEO_LOCATE->event_size, /* DON'T use the address here */
            event1 = & p_CEO_LOCATE->event2,
            event2 = & p_CEO_LOCATE->event1,
            mask1 = p_CEO_LOCATE->event_mask2,
            mask2 = p_CEO_LOCATE->event_mask1,
	    nbytes1 = & p_CEO_LOCATE->nbytes2,	/*** JAJ:04-21-88 ***/
	    nbytes2 = & p_CEO->nbytes1,	/*** JAJ:04-21-88 ***/
            stack = & p_CEO_LOCATE->stack,
            locate_prompt = p_CEO->prompt,
            acc_prompt = p_CEO_LOCATE->acc_prompt,
            relocate_prompt = p_CEO_LOCATE->reloc_prompt,
            display_flag = p_CEO_LOCATE->display_flag,
            dyn = p_CEO_LOCATE->dyn,
            type = p_CEO_LOCATE->type,
	    rtree_classes = p_CEO_LOCATE->locate_rtree,
	    eligible_classes = p_CEO_LOCATE->locate_eligible,
            attributes = & p_CEO_LOCATE->attributes,
	    action_handler = p_CEO_LOCATE->action_handler,  /*** JAJ:08-19-87 ***/
	    action_args	= p_CEO_LOCATE->action_args,	  /***  also below  ***/
	    regex	= p_CEO_LOCATE->regex,
	    stack_size  = p_CEO_LOCATE->stack_size,
	    select	= p_CEO_LOCATE->select,
	    select_args = p_CEO_LOCATE->select_args,
	    locate_event  = & p_CEO_LOCATE->event3,	/*** JAJ:08-24-87 ***/
	    locate_state  = & p_CEO_GSLOCATE->locate_state,	/*** (args peculiar ***/
	    num_inputs    = p_CEO_GSLOCATE->num_inputs,	/***  to gslocate ) ***/
	    input1_mask   = p_CEO_GSLOCATE->spec_mask1,
	    input2_mask   = p_CEO_GSLOCATE->spec_mask2,
	    input1_prompt = p_CEO_GSLOCATE->spec_prompt1,
	    input2_prompt = p_CEO_GSLOCATE->spec_prompt2,
	    p_chanselect  = & p_CEO_LOCATE->located_chansel,
	    hilight_mode  = p_CEO_LOCATE->HilightMode,	      /* JAJ:04-21-88 */
	    unhilight_mode= p_CEO_LOCATE->UnhilightMode,      /*  " " " "     */
	    range_handler = p_CEO_LOCATE->range_handler,      /* JAJ:11-01-88 */
	    range_args	  = p_CEO_LOCATE->range_args,	      /*  " " " "     */
	    value_type1   = p_CEO_LOCATE->value_type_locate,  /* JAJ:12-19-88 */
	    value_type2   = p_CEO_LOCATE->value_type_accept,  /* JAJ:12-19-88 */
	    scale_flag	  = p_CEO_LOCATE->scale_flag );	      /* JAJ:05-22-89 */
       }

	_bugprint(bflag = CEO_GSLOCATE_debug, str =
	    "After gr$gslocate: me->ret = %d, status = %d\n",
	    var = `p_CEO->ret, status` )

	if ( status != 1 )
	  {
#ifdef DEBUG
	    fprintf(stderr,"CEO_GSLOCATE.filter:  gr$gslocate() status = %d\n",
		status );
#endif
            /***    *response = TERMINATE; 	-- JAJ:03-21-88 ***/
	    p_CEO->ret = COB_E_FILTER_FAIL;
	  }
        break;

      default:
	_bugprint(bflag = CEO_GSLOCATE_debug, str =
	    "Burping filter = %d back to CEO_LOCATE.filter\n",
	    var = filter)
        status = om$send ( targetid = my_id,
            msg = message CEO_LOCATE.filter ( filter, response, response_data ),
            mode = OM_e_wrt_message );
#ifdef DEBUG
        _cob_check ( status, \
		"CEO_GSLOCATE.action:  CEO_LOCATE.filter() failed." );
#endif
        break;
    }
quit:
  _bugprint(bflag = TFLAG, str =
	"-CEO_GSLOCATE.filter: me->ret=%d, status=%d\n",
	var = `p_CEO->ret,status` )

  return OM_S_SUCCESS;  /*** JAJ:03-21-88 ***/
}


IGRlong RFlocate_ref_objects_handler(osn, new_entry, locate_args, action)
GRspacenum *osn;
struct  GRlc_info *new_entry;
struct  LC_action_args *locate_args;
enum    GRlocate_action *action;
{
  IGRboolean  call_action_handler = FALSE;
  IGRlong sts = OM_S_SUCCESS;

  switch(*action)
  {
      case add_all:
      case add_inside:
      case add_outside:
      case add_overlap:
      case add_nopost:
      {
         if (new_entry->located_obj.osnum != *osn)
         {
            call_action_handler = FALSE;
         }
         else
         {
            call_action_handler = TRUE;
         }
      }
      break;

      default:

      break;
  }

  /* Call the default action handler */

  if(call_action_handler)
      sts = LCptlocact(NULL, new_entry, locate_args, action);
  else
      sts = OM_S_SUCCESS;

  return(sts);
}


end implementation CEO_GSLOCATE;
