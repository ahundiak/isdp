/* ceo/filter.I */
/*
   invoke indicated filter
*/
class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method filter (
  int	  filter;
  int   * response;
  char	* response_data )
{
  int	status;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_instance		* p_CEO = ME.CEO;


  _bugprint(bflag=TFLAG, str = "+CEO.filter:  *response  = %d, response_data = '%s', filter = %d\n",
	var = `*response, response_data, filter` )


  switch ( filter )
   {
      /************************************ JAJ:05/21/91 ***********
      case _none:
	_bugprint(bflag=CEO_debug, str =
		"filter = '_none' = %d\n", var = filter)
	break;
      **************************************************************/

      case _menu:
	_bugprint(bflag=CEO_debug, str =
		"filter = '_menu' = %d\n", var = filter)
	ex$message( field = PROMPT_FIELD, msgnumb = MS_NO_MSG,
		    justification = RIGHT_JUS, in_buff = p_CEO->prompt);
	break;

      case _wfi:
	_bugprint(bflag=CEO_debug, str =
		"filter = '_wfi' = %d\n", var = filter)
	ex$message( field = PROMPT_FIELD, msgnumb = MS_NO_MSG,
		    justification = RIGHT_JUS, in_buff = p_CEO->prompt);
	_bugprint(bflag=CEO_debug, str =
	    "Calling ex$wait_for_input()\n")
	status = ex$wait_for_input (
	    response = response,
	    buffer = response_data,
	    mode = p_CEO->filter_mode,
	    byte = & p_CEO->nbytes1 );   /*** JAJ:04-20-88 ***/
	_bugprint(bflag=CEO_debug, str =
	    "Called ex$wait_for_input(*response=%d, response_data='%s', size=%d)\n",
	    var = `* response, response_data, p_CEO->nbytes1` )

	if ( status == 1 )
	  p_CEO->ret = OM_S_SUCCESS;
	else		/*** JAJ:03-21-88 ***/
	  {
	    fprintf(stderr,"CEO.filter:  ex$wait_for_input() status = %d\n",
		status );
	    p_CEO->ret = COB_E_FILTER_FAIL;
	    break;
	  }

	/******* split COB into IGE COB and DRAFT COB	***************/
	/******* so this isn't necessary here anymore   ***************/
	/*    me->event1.response = * response;   -JAJ:10-20-87 ****/
	/*    me->event1.subtype = GRst_REGULAR;		****/
	/*    switch ( * response )
	  {
	    case EX_STRING:
	    case CMD_STRING:
	    case EX_CHAR:
	      strcpy ( me->event1.event.keyin, response_data );
	      break;
	    default:
	      me->event1.nbytes = sizeof ( me->event1.event );
	      memcpy ( & me->event1.event, response_data, me->event1.nbytes );
	      break;
	  }
	***************************************************************/
	break;

      default:
	_bugprint(bflag=CEO_debug, str =
	    "filter = ? = %d\n", var = filter)
	fprintf(stderr,"CEO.filter:  Unknown filter # %d\n", filter );

	break;
    }

/*quit:*/
  _bugprint(bflag=TFLAG, str = "-CEO.filter:  *response=%d, response_data='%s', filter=%d\n",
	var = `*response, response_data, filter` )
  return OM_S_SUCCESS;
}
end implementation CEO;
