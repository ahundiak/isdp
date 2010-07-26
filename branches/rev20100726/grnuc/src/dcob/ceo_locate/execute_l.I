/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/execute_l.I -- JAJ:04-07-88 */
/*
        This is basically a re-router method which does nothing but
    call CEO.real_execute with certain arguments.  This method is
    overridden by CEO_LOCATE, so that it calls CEO.real_execute with
    different arguments.
*/
class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <griomacros.h> /*** for clear_vsd -- JAJ:11-17-89 ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


method execute (
  int	* response;
  char	* response_data;
  int	  position )
{
  int	status;
  int * me_event1_response_ptr = & me->event1.response;


  _bugprint(bflag=TFLAG, str =
	"+CEO_LOCATE.execute:  *response=%d, response_data='%s', pos=%d; me->ret=%d\n",
	var = `*response, response_data, position, me->ret` )


    /*** CEO & CEO_LOCATE have identical execute methods except     ***/
    /***   for the following line:			 	    ***/
    /***   CEO calls real_execute with &me->response 		    ***/
    /***   CEO_LOCATE calls real_execute with			    ***/
    /***		    & of a ptr to me->event1.response	    ***/
  _bugprint(bflag=CEO_debug, str =
	"Sending CEO.execute( resp, resp_data, pos, && me->event1.response )\n")
  _send ( my_id, CEO.real_execute ( response, response_data, position,
			 & me_event1_response_ptr ));
#ifdef DEBUG
  _cob_check ( status, \
	"CEO_LOCATE.execute:  CEO.real_execute() failed." );
#endif



  _bugprint(bflag=TFLAG, str =
	"-CEO_LOCATE.execute:  *response=%d, response_data='%s', pos=%d, me->ret=%d\n",
	var = `*response, response_data, position, me->ret` )

  /*** clear the vsd if the user keyed in some type of string ***/
					/*** JAJ:11-17-89 ***/
  if ( *response == EX_STRING || *response == CMD_STRING )
    clear_vsd;

  return OM_S_SUCCESS;
}
end implementation CEO_LOCATE;
