/* ceo/status.I */
/*
  if argument key is non-null, retrieve char string from message system.
  display current status chars in status field of IMPS form (Input,
  Message, Prompt, Status form appears at top of screen).
*/
class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method status ( char * status_string )
{
  _bugprint(bflag=TFLAG, str = "+CEO.status:  status_string = '%s'; me->status = '%s'\n",
	var = `status_string, me->status` )

  if ( status_string )
	strcpy ( me->status, status_string );

  /*** UI_status ( me->status );  JAJ:11-17-87 ***/
  ex$message( field = ERROR_FIELD, msgnumb = MS_NO_MSG,
	      justification = CENTER_JUS, in_buff = me->status );

/*quit:*/
  _bugprint(bflag=TFLAG, str = "-CEO.status:  status_string = '%s'; me->status = '%s'\n",
	var = `status_string, me->status` )
  return OM_S_SUCCESS;
}
end implementation CEO;
