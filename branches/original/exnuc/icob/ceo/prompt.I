/* ceo/prompt.I */
/*
  if argument string is non-null, put chars in prompt field of instance data.
*/
class implementation CEO;

#include <ctype.h>	/*** need this for is_blanks() function ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method prompt ( char * prompt_str )
{
  char * ch, is_blanks;


  _bugprint(bflag=TFLAG, str =
	"+CEO.prompt:  incoming prompt_str= '%s'; my_id = %d, sender_id = %d, me->prompt = '%s'\n",
	var = `prompt_str, my_id, sender_id, me->prompt` )

  if ( prompt_str )
    {
	strcpy ( me->prompt, prompt_str );
	/***  see if the prompt string is really all blanks  ***/
	for ( is_blanks = 1, ch = me->prompt ;  *ch ; ch++ )
	  {
	    if ( ! isspace(*ch) )
	      {
		is_blanks = 0;
		break;
	      }
	  }
	if ( is_blanks )
	        /* UI_prompt ( "" ); 	JAJ:11-17-87 */
		ex$message( field = PROMPT_FIELD, msgnumb = MS_NO_MSG,
		    justification = RIGHT_JUS, in_buff = "" );
    }
  else
      /* UI_prompt ( "" ); 	JAJ:11-17-87 */
      ex$message( field = PROMPT_FIELD, msgnumb = MS_NO_MSG,
	    justification = RIGHT_JUS, in_buff = "" );

/*quit:*/
  _bugprint(bflag=TFLAG, str =
	"-CEO.prompt:  me->prompt = prompt_str= '%s'\n",
	var = me->prompt )
  return OM_S_SUCCESS;
}
end implementation CEO;
