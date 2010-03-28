/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/predicate_l.I */
/*
  determine if something is so
*/
class implementation CEO_LOCATE;

/**********************************************************************/
/**	NOTE:  This file was copied over from CEO on 10-20-87	     **/
/**********************************************************************/

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <griomacros.h>	/* need this for vsd_empty stuff-JAJ:09-28-87 */
#include <COBint.h>	/* need this for data_val  ---   JAJ:12-02-88 */

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


method predicate (
  int	  selector;
  int     operator;
  char	* char_data; /*** changed from data_union - JAJ:02-08-88 ***/
  int	* is_so )
{
extern  int       strcmp ();
  long            opnd1, opnd2;
  double          fopnd1, fopnd2;
  enum { is_int, is_dbl }       opnd_type;
  data_val	* data = (data_val *) char_data;  /*** JAJ:12-02-88 ***/

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_instance		* p_CEO = ME.CEO;
  struct CEO_LOCATE_instance	* p_CEO_LOCATE = ME.CEO_LOCATE;


  _bugprint(bflag=TFLAG, str =
	"+CEO_LOCATE.predicate: selector=%d, operator=%d, data->str='%s', *is_so=%d\n",
	var = `selector, operator, data->str, *is_so` )

  if ( selector >= 0  &&  selector  <= EX_MAX_RESPONSE )
    {
	* is_so = ( p_CEO_LOCATE->event1.response == selector );
	_bugprint(bflag=CEO_LOCATE_debug, str = 
	    "* is_so = ( me->event1.response == selector ) = %d\n",
	    var = *is_so )
    }
  else
    switch ( selector )
      {
        case _ceo_null_string:
        case _ceo_null_text_value:
          * is_so = ( p_CEO_LOCATE->event1.response == EX_STRING || p_CEO_LOCATE->event1.response ==
              CMD_STRING ) && ( p_CEO_LOCATE->event1.event.keyin [0] == NULL );
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

        case _ceo_vsd_and_q_empty:		/*** JAJ:09-28-87 ***/
          * is_so = vsd_and_queue_empty ;
	  if ( * is_so ) p_CEO_LOCATE->event1.subtype = GRst_DEFAULT;
          break;

        case _ceo_vsd_empty:
          * is_so = vsd_empty ;
	  if ( * is_so ) p_CEO_LOCATE->event1.subtype = GRst_DEFAULT;
          break;

        case _ceo_q_empty:
          * is_so = queue_empty ;
	  if ( * is_so ) p_CEO_LOCATE->event1.subtype = GRst_DEFAULT;
          break;

        case _ceo_else:
	    /*** Don't eat cmd strings of any kind - JAJ:02-10-88 ***/
	    /*** Don't eat STATUS_DISP either      - JAJ:12-09-88 ***/
	    /*** Don't eat POCKET menus either     - JAJ:07-18-89 ***/

	  if (	p_CEO_LOCATE->event1.response == EX_CMD_KEY	|| 
		p_CEO_LOCATE->event1.response == CMD_STRING	||
		* p_CEO->response == EX_CMD_KEY		||
		* p_CEO->response == CMD_STRING		||
		* p_CEO->response == EX_POCKET		||
		* p_CEO->response == STATUS_DISP )
	    {
	      * is_so = 0;
	    }
	  else
	    {
	      * is_so = 1;
	    }
          break;

        case _ceo_return_code:
        case _ceo_mytype:
          * is_so = _true;
          break;

        case _ceo_angle:
        case _ceo_distance:
        case _ceo_scalar:
          * is_so = ( p_CEO_LOCATE->event1.response == EX_VALUE );
          break;

        case _ceo_text_value:
          * is_so = ( p_CEO_LOCATE->event1.response == EX_STRING );
          break;

        case GR_UNKNOWN_TYPE:
          * is_so = ( p_CEO_LOCATE->event1.response == GR_UNKNOWN_TYPE );
          break;

        default:
          * is_so = ( p_CEO->ret == selector );
	  _bugprint(bflag=CEO_LOCATE_debug, str =
		"USER selector = %d, me->ret = %d, *is_so = %d\n",
		 var = `selector, p_CEO->ret, *is_so` )
          goto quit;
          break;
      }

  _bugprint(bflag=CEO_LOCATE_debug, str = 
    "After 1st 'if': * is_so = %d\n", var = *is_so )

  if ( * is_so && (operator != _ceo_noop) )
    {
      switch ( selector )
        {
          case EX_DATA:
          case D_DATA:
            opnd1 = p_CEO_LOCATE->event1.subtype;
            opnd2 = data->i;
            opnd_type = is_int;
            break;

          case EX_STRING:
          case CMD_STRING:
          case _ceo_text_value:
	    if ( operator == _ceo_subtype )
	      {
		opnd1 = p_CEO_LOCATE->event1.subtype;
		opnd2 = data->i;
		opnd_type = is_int;
	      }
	    else
	      {
		opnd1 = strcmp ( p_CEO_LOCATE->event1.event.keyin, data->str );
		opnd2 = 0;
		opnd_type = is_int;
	      }
            break;

          case _ceo_null_string:
          case _ceo_null_text_value:
	    if ( operator == _ceo_subtype )
	      {
		opnd1 = p_CEO_LOCATE->event1.subtype;
		opnd2 = data->i;
		opnd_type = is_int;
	      }
	    else
		goto quit;
	    break;

          case EX_CHAR:
            opnd1 = p_CEO_LOCATE->event1.event.keyin [0];
            opnd2 = data->str [0];
            opnd_type = is_int;
            break;

          case EX_VALUE:
          case _ceo_angle:
          case _ceo_distance:
          case _ceo_scalar:
	    if ( operator == _ceo_subtype )
	      {
		opnd1 = p_CEO_LOCATE->event1.subtype;
		opnd2 = data->i;
		opnd_type = is_int;
	      }
	    else
	      {
		fopnd1 = p_CEO_LOCATE->event1.event.value;
		fopnd2 = data->d;
		opnd_type = is_dbl;
	      }
            break;

          case GR_UNKNOWN_TYPE:	/*** JAJ:03-28-88 ***/
	    if ( operator == _ceo_subtype )
	      {
                opnd1 = * p_CEO->response;
                sscanf ( data->str, "%d", &opnd2 );
                opnd_type = is_int;

	        _bugprint(bflag=CEO_LOCATE_debug, str = 
                  "GR_UNKNOWN_TYPE.____:  *ME->CEO.response = %d\n",
	          var = *p_CEO->response )
	        _bugprint(bflag=CEO_LOCATE_debug, str = 
                  "GR_UNKNOWN_TYPE.____:  opnd1 = %d, opnd2 = %d\n",
	          var = `opnd1, opnd2` )
	      }
	    else
		goto quit;
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
            break;
        }

      if ( opnd_type == is_int )
	{
	_bugprint(bflag=CEO_LOCATE_debug, str = 
        "Inside 2nd 'if': opnd_type = is_int; opnd1 = %d, opnd2 = %d\n",
	    var = `opnd1, opnd2` )
	}
      else
	{
	_bugprint(bflag=CEO_LOCATE_debug, str = 
        "Inside 2nd 'if': opnd_type = is_dbl; fopnd1 = %f, fopnd2 = %f\n",
	    var = `fopnd1, fopnd2` )
	}

      switch ( opnd_type )
        {
          case is_int:
            switch ( operator )
              {
                case _ceo_eq:
                case _ceo_subtype:
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
	"-CEO_LOCATE.predicate: selector=%d, operator=%d, data->s='%s', *is_so=%d\n",
	var = `selector, operator, data->str, *is_so` )
  return OM_S_SUCCESS;
}
end implementation CEO_LOCATE;
