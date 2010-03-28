/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/filter_l.I */
class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <lcmacros.h>
#include <griomacros.h>	    /** need this for co$getevent **/
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


method filter (
  int	  filter;
  int   * response;
  char	* response_data )
{
  int		   status;
  char             msgbuff[MS_MAX_MSG_LENGTH];

  struct GRevent * p_event3 = NULL;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_instance		* p_CEO = ME.CEO;
  struct CEO_LOCATE_instance	* p_CEO_LOCATE = ME.CEO_LOCATE;

  _bugprint(bflag = TFLAG, str = "+CEO_LOCATE.filter: = %d\n",var = filter)
  p_CEO->ret = OM_S_SUCCESS;

  switch ( filter )
   {
      case _wfi:	/****  copied from CEO -- JAJ:10-29-87  ****/
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"filter = '_wfi' = %d\n", var = filter)

	  /*** don't issue a prompt if there's input already there ***/
	if ( queue_empty )			/*** JAJ:10-26-88  ***/
	  {
	    ex$message( field = PROMPT_FIELD, msgnumb = MS_NO_MSG,
		    justification = RIGHT_JUS, in_buff = p_CEO->prompt );
	  }

	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "Calling ex$wait_for_input()\n")
	status = ex$wait_for_input (
		    response = response,
		    buffer = response_data,
		    mode = p_CEO->filter_mode,
		    byte = & p_CEO->nbytes1 );	/*** JAJ:04-20-88 ***/
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "Called ex$wait_for_input(*response=%d, response_data='%s', size=%d)\n",
	    var = `* response, response_data, p_CEO->nbytes1` )

	p_CEO_LOCATE->event1.response = * response;
	p_CEO_LOCATE->event1.subtype = GRst_REGULAR;

	if ( status == 1 )
	  p_CEO->ret = OM_S_SUCCESS;
	else		/*** JAJ:03-21-88 ***/
	  {
#ifdef DEBUG
	    fprintf(stderr,"CEO_LOCATE.filter:  ex$wait_for_input() status = %d\n",
		status );
#endif
	    p_CEO->ret = COB_E_FILTER_FAIL;
	    break;
	  }

	switch ( * response )
	  {
	    case EX_STRING:
	    case CMD_STRING:
	    case EX_CHAR:
	      strcpy ( p_CEO_LOCATE->event1.event.keyin, response_data );
	      break;
	    default:
	      p_CEO_LOCATE->event1.nbytes = sizeof ( p_CEO_LOCATE->event1.event );
	      memcpy ( (char *)& p_CEO_LOCATE->event1.event, response_data, p_CEO_LOCATE->event1.nbytes );
	      break;
	  }
	break;

      case _get_event: 	/*** moved from CEO - JAJ:10-20-87 ****/
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"filter = '_get_event' = %d\n", var = filter)

	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "Before co$getevent(): mask = 0x%x val_type '%s'\n",
	    var = `p_CEO_LOCATE->event_mask1, (p_CEO_LOCATE->value_type ? p_CEO_LOCATE->value_type : "null" )` )

	status = co$getevent (
		msg 		= (IGRlong *) & p_CEO->ret,
		event_mask	= p_CEO_LOCATE->event_mask1,
		event_size	= p_CEO_LOCATE->event_size,
		event		= & p_CEO_LOCATE->event1,
		prompt		= p_CEO->prompt,
		value_type	= p_CEO_LOCATE->value_type,
		response	= response,
		response_data	= response_data,
		nbytes		= & p_CEO->nbytes1,    /*JAJ:04-20-88 */
		mode		= p_CEO->filter_mode,  /*JAJ:08-25-87 */
		scale_flag	= p_CEO_LOCATE->scale_flag ); /*JAJ:05-22-89 */

	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "After co$getevent(): me->event1.response=%d, *response=%d, status=%d, me->ret=%d\n",
	    var = `p_CEO_LOCATE->event1.response, * response, status, p_CEO->ret` )

	if ( status != MSSUCC )	/*** JAJ:03-21-88 ***/
	  {
#ifdef DEBUG
	    fprintf(stderr,"CEO_LOCATE.filter:  co$getevent() status = %d\n",
		status );
#endif
	    p_CEO->ret = COB_E_FILTER_FAIL;
	  }

	break;

      case _gr_locate_event3:	/*** JAJ:08-19-87 ***/
	_bugprint(bflag = CEO_LOCATE_debug, str =
	    "filter = _gr_locate_event3 = %d\n", var = filter)
	p_event3 = &p_CEO_LOCATE->event3;
	/* _no_break; */

      case _gr_locate:
	_bugprint(bflag = CEO_LOCATE_debug, str =
	    "filter = _gr_locate = %d\n", var = filter)
	p_CEO_LOCATE->DisplayMode = GRhe; /**** = GRbdhe; --JAJ:06-02-88 ****/

	_send ( my_id, CEO_LOCATE.display_located ( & p_CEO->ret ));
	_bugprint(bflag = CEO_LOCATE_debug, str =
	    "After CEO_LOCATE.display_located:  me->ret = %d, status = %d\n",
	    var = `p_CEO->ret, status` )
#ifdef DEBUG
	_check2 ( status, p_CEO->ret );
#endif

	status = lc$wild_disconnect ( p_chanselect =
				& p_CEO_LOCATE->located_chansel );
	_bugprint(bflag = CEO_LOCATE_debug, str =
	    "After lc$wild_disconnect:  status = %d\n", var = status )
#ifdef DEBUG
	_check ( status );
#endif

	/* _no_break; */

      case _gr_locate_noauto_event3:	/*** JAJ:08-19-87 ***/
	if ( filter == _gr_locate_noauto_event3 )
	  {
	    _bugprint(bflag = CEO_LOCATE_debug, str =
	      "filter = _gr_locate_noauto_event3 = %d\n", var = filter)
	    p_event3 = &p_CEO_LOCATE->event3;
	  }
	/* _no_break; */

      case _gr_locate_noauto:
	_bugprint(bflag = CEO_LOCATE_debug, str =
	    "filter = _gr_locate_noauto = %d\n", var = filter)
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

	status = lc$locate (
	    rc = (IGRlong *) & p_CEO->ret,
	    eventsize = & p_CEO_LOCATE->event_size,
	    event1 = & p_CEO_LOCATE->event2,
	    event2 = & p_CEO_LOCATE->event1,
	    mask1 = p_CEO_LOCATE->event_mask2,
	    mask2 = p_CEO_LOCATE->event_mask1,
	    nbytes1 = & p_CEO_LOCATE->nbytes2,	/*** JAJ:04-21-88 ***/
	    nbytes2 = & p_CEO->nbytes1, 	/*** JAJ:04-21-88 ***/
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
	    act_handler = p_CEO_LOCATE->action_handler,   /*** JAJ:08-19-87 ***/
	    act_args	= p_CEO_LOCATE->action_args,	/***  also below  ***/
	    regex	= p_CEO_LOCATE->regex,
	    stack_size  = p_CEO_LOCATE->stack_size,
	    select	= p_CEO_LOCATE->select,
	    select_args = p_CEO_LOCATE->select_args,
	    event3      = p_event3,
	    hilight_mode   = p_CEO_LOCATE->HilightMode,       /* JAJ:02-14-88 */
	    unhilight_mode = p_CEO_LOCATE->UnhilightMode,
	    range_handler  = p_CEO_LOCATE->range_handler,     /* JAJ:11-01-88 */
	    range_args	   = p_CEO_LOCATE->range_args,	      /*  " " " "     */
	    value_type1    = p_CEO_LOCATE->value_type_locate, /* JAJ:12-19-88 */
	    value_type2    = p_CEO_LOCATE->value_type_accept, /* JAJ:12-19-88 */
	    scale_flag	   = p_CEO_LOCATE->scale_flag );      /* JAJ:05-22-89 */

	_bugprint(bflag = CEO_LOCATE_debug, str =
	    "After lc$locate: me->ret = %d, status = %d\n",
	    var = `p_CEO->ret, status` )
	if ( status == 1 )
	  { /***  connect the located object (if any)  ***/
	    /***    to the located_chansel	***/
	    if ( p_CEO->ret == LC_OBJ_LOCATED		||
		 p_CEO->ret == LC_ONE_ELEM_ACCEPT ) /** JAJ:12-12-89 **/
	      {
		/*** if event 3 was not used, then the located	***/
		/***    object is in event1			***/
		if ( p_event3 == NULL )
		    p_event3 = & p_CEO_LOCATE->event1;

				/***********  --JAJ:10-02-89 **********/
		p_CEO_LOCATE->locate_ModuleInfo =
			        p_event3->located_object[0].module_info;

		status = lc$connect (
			p_chanselect = & p_CEO_LOCATE->located_chansel,
			go_objid =
			  p_event3->located_object[0].located_obj.objid,
			go_osnum =
			 p_event3->located_object[0].located_obj.osnum);
#ifdef DEBUG
		_check ( status );
#endif
		_bugprint(bflag = CEO_LOCATE_debug, str =
		    "After lc$connect:  status = %d\n", var = status )
		_bugprint(bflag = CEO_LOCATE_debug, str =
		    "After lc$connect:\n\tme->event_.located_object[0].located_obj.(osnum,objid) = %d, %d\n",
		var = `p_event3->located_object[0].located_obj.osnum, p_event3->located_object[0].located_obj.objid` )
	      }
	  }
	else  /*** locate failure ***/
	  {
#ifdef DEBUG
	    fprintf(stderr,"CEO_LOCATE.filter:  lc$locate() status = %d\n",
		status );
#endif
	    /***    *response = TERMINATE; 	-- JAJ:03-21-88 ***/
	    p_CEO->ret = COB_E_FILTER_FAIL;
	  }
	break;

      default:
	_bugprint(bflag = CEO_LOCATE_debug, str =
	    "Burping filter = %d back to CEO.filter\n", var = filter)
	status = om$send ( targetid = my_id,
	    msg = message CEO.filter ( filter, response, response_data ),
	    mode = OM_e_wrt_message );
#ifdef DEBUG
	_check ( status );
#endif
	break;
    }

  _bugprint(bflag = TFLAG, str =
	"-CEO_LOCATE.filter: me->ret=%d, status=%d\n",
	var = `p_CEO->ret, status` )
  return OM_S_SUCCESS;
}
end implementation CEO_LOCATE;
