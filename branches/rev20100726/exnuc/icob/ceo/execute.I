/* ceo/execute.I -- JAJ:04-07-88 */
/*
	This is basically a re-router method which does nothing but
    call CEO.real_execute with certain arguments.  This method is
    overridden by CEO_LOCATE, so that it calls CEO.real_execute with
    different arguments.
*/
class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method execute (
  int	* response;
  char	* response_data;
  int	  position )
{
  int	status;


  _bugprint(bflag=TFLAG, str =
	"+CEO.execute:  *response=%d, response_data='%s', pos=%d; me->ret=%d\n",
	var = `*response, response_data, position, me->ret` )


    /*** CEO & CEO_LOCATE have identical execute methods except	    ***/
    /***   for the following line:			 	    ***/
    /***   CEO calls real_execute with &me->response		    ***/
    /***   CEO_LOCATE calls real_execute with			    ***/
    /***  		    & of a ptr to me->event1.response	    ***/
  _bugprint(bflag=CEO_debug, str =
	"Sending CEO.execute( resp, resp_data, pos, &me->response )\n")
  _send ( my_id, CEO.real_execute ( response, response_data, position,
			 & me->response ));
#ifdef DEBUG
  _cob_check ( status, "CEO.execute:  CEO.real_execute() failed");
#endif


/*quit:*/
  _bugprint(bflag=TFLAG, str =
	"-CEO.execute:  *response=%d, response_data='%s', pos=%d, me->ret=%d\n",
	var = `*response, response_data, position, me->ret` )

  return OM_S_SUCCESS;
}
end implementation CEO;
