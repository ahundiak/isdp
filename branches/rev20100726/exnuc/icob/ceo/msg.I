/* ceo/msg.I */
/*
  if argument key is non-null, retrieve char string from message system.
  display current message chars in message field of IMPS form.
*/
class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method msg ( char * msg_string )
{
  _bugprint(bflag=TFLAG, str = "+CEO.msg:  msg_key = '%s'\n",
	var = msg_string )


  if ( msg_string ) strcpy ( me->msg, msg_string );

  /** UI_message ( me->msg ); JAJ:11-17-87 **/
  ex$message( field = MESSAGE_FIELD, msgnumb = MS_NO_MSG,
	      justification = CENTER_JUS, in_buff = me->msg );

/*quit:*/
  _bugprint(bflag=TFLAG, str = "-CEO.msg:\n" )
  return OM_S_SUCCESS;
}
end implementation CEO;
