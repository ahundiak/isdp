/* ceo/predicate.I */
/*
  determine if something is so
*/
class implementation CEO;

#include <stdio.h>
#include <COBint.h>		/*** needed for data_val ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method predicate (
  int	  selector;
  int	  operator;
  char	* char_data; /*** changed from data_union - JAJ:02-08-88 ***/
  int	* is_so )
{
extern  int       strcmp ();
  long	    opnd1, opnd2;
  double	  fopnd1, fopnd2;
  enum { is_int, is_dbl }       opnd_type;
  data_val	* data = (data_val *) char_data;  /*** JAJ:12-02-88 ***/

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_instance		* p_CEO = ME.CEO;


  _bugprint(bflag=TFLAG, str =
	"+CEO.predicate: selector=%d, operator=%d, data->str='%s', *is_so=%d\n",
	var = `selector, operator, data->str, *is_so` )

  if ( selector >= 0  &&  selector  <= EX_MAX_RESPONSE )
    {
	* is_so = ( * p_CEO->response == selector );
	_bugprint(bflag=CEO_debug, str = 
	    "* is_so = ( * p_CEO->response == selector ) = %d\n",
	    var = *is_so )
    }
  else
    switch ( selector )
      {
	case _ceo_null_string:
	/*** case _ceo_null_text_value:  ***/
	  * is_so = ( * p_CEO->response == EX_STRING || * p_CEO->response ==
	      CMD_STRING ) && ( p_CEO->response_data [0] == '\0' );
	  break;

	case _ceo_success:
	  * is_so = (( p_CEO->ret & 7 ) == SUCC );
	  break;

	case _ceo_info:
	  * is_so = (( p_CEO->ret & 7 ) == INFO );
	  break;

	case _ceo_warning:
	  * is_so = (( p_CEO->ret & 7 ) == WARN );
	  break;

	case _ceo_error:
	  * is_so = (( p_CEO->ret & 7 ) == ERRO );
	  break;

	case _ceo_severe:
	  * is_so = (( p_CEO->ret & 7 ) == SEVE );
	  break;

	case _ceo_else:
	    /*** Don't eat cmd strings of any kind - JAJ:02-10-88 ***/
	    /*** Don't eat STATUS_DISP either      - JAJ:12-09-88 ***/
	    /*** Don't eat POCKET menus either     - JAJ:07-18-89 ***/
	  * is_so = ! ( * p_CEO->response == EX_CMD_KEY ||
			* p_CEO->response == CMD_STRING ||
			* p_CEO->response == EX_POCKET	||
			* p_CEO->response == STATUS_DISP );
	  break;

	case _ceo_return_code:
	case _ceo_mytype:
	  * is_so = _true;
	  break;

	default:
	  * is_so = ( p_CEO->ret == selector );
	  _bugprint(bflag=CEO_debug, str =
		"USER selector = %d, me->ret = %d, *is_so = %d\n",
		 var = `selector, p_CEO->ret, *is_so` )
	  goto quit;
	  /*break;*/
      }

  _bugprint(bflag=CEO_debug, str = 
    "After 1st 'if': * is_so = %d\n", var = *is_so )

  if ( * is_so && (operator != _ceo_noop) )
    {
      switch ( selector )
	{
	  case EX_STRING:
	  case CMD_STRING:
	  case _ceo_text_value:
	    opnd1 = strcmp ( p_CEO->response_data, data->str );
	    opnd2 = 0;
	    opnd_type = is_int;
	    break;

	  case EX_CHAR:
	    opnd1 = p_CEO->response_data [0];
	    opnd2 = data->str [0];
	    opnd_type = is_int;
	    break;

	  case _ceo_return_code:
	    opnd1 = p_CEO->ret;
	    opnd2 = data->i;
	    opnd_type = is_int;
	    break;

	  case _ceo_mytype:
	    opnd1 = ME.super_cmd->mytype;
	    opnd2 = data->i;
	    opnd_type = is_int;
	    break;

	  default:
	    goto quit;
	    /*break;*/
	}

      if ( opnd_type == is_int )
	{
	_bugprint(bflag=CEO_debug, str = 
	"Inside 2nd 'if': opnd_type = is_int; opnd1 = %d, opnd2 = %d\n",
	    var = `opnd1, opnd2` )
	}
      else
	{
	_bugprint(bflag=CEO_debug, str = 
	"Inside 2nd 'if': opnd_type = is_dbl; fopnd1 = %f, fopnd2 = %f\n",
	    var = `fopnd1, fopnd2` )
	}

      switch ( opnd_type )
	{
	  case is_int:
	    switch ( operator )
	      {
		case _ceo_eq:
		  * is_so = opnd1 == opnd2;
		  break;

		case _ceo_ne:
		  * is_so = opnd1 != opnd2;
		  break;

		case _ceo_lt:
		  * is_so = opnd1 < opnd2;
		  break;

		case _ceo_le:
		  * is_so = opnd1 <= opnd2;
		  break;

		case _ceo_ge:
		  * is_so = opnd1 >= opnd2;
		  break;

		case _ceo_gt:
		  * is_so = opnd1 > opnd2;
		  break;
	      }
	    break;

	  case is_dbl:
	    switch ( operator )
	      {
		case _ceo_eq:
		  * is_so = fopnd1 == fopnd2;
		  break;

		case _ceo_ne:
		  * is_so = fopnd1 != fopnd2;
		  break;

		case _ceo_lt:
		  * is_so = fopnd1 < fopnd2;
		  break;

		case _ceo_le:
		  * is_so = fopnd1 <= fopnd2;
		  break;

		case _ceo_ge:
		  * is_so = fopnd1 >= fopnd2;
		  break;

		case _ceo_gt:
		  * is_so = fopnd1 > fopnd2;
		  break;
	      }
	    break;
	}
    }

quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO.predicate: selector=%d, operator=%d, data->s='%s', *is_so=%d\n",
	var = `selector, operator, data->str, *is_so` )
  return OM_S_SUCCESS;
}
end implementation CEO;
