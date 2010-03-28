/* ceo_gslocate/arg_name_gl.I -- JAJ:02-14-88 */
/*
  translate a string into its variable name value
*/
class implementation CEO_GSLOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif


method arg_name_to_value (
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
  char		* class_name;	/* not NULL => argname used to start  */
				/*   with "me(class_name)->" of some  */
				/*   form; now this has been stripped */
				/* NULL => original arg had no "me->" */
  char  	* arg;		/* arg string to find a value for     */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const;)	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  int 	 status;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_GSLOCATE_instance	* p_CEO_GSLOCATE = ME.CEO_GSLOCATE;

  _bugprint(bflag=TFLAG,str=
    "+CEO_GSLOCATE.arg_name_to_value:  arg='%s', addr_mode=%d, [me]class='%s', *is_const=%d\n",
    var = `arg, addr_mode, ( class_name ? class_name : "" ), *is_const` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;

  if ( class_name[0] )	/*** arg string used to begin with "me->" ***/
    {
	/**************************************************************/
	/*		  CEO_GSLOCATE instance data		      */
	/**************************************************************/
      if ( ! strcmp ( arg, "spec_prompt1" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_GSLOCATE->spec_prompt1;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[me->spec_prompt1] data->p=(0x)%x  =?=  ME.CEO_GSLOCATE->prompt=(0x)%x\n",
    		  var = `data->p, p_CEO_GSLOCATE->spec_prompt1` )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "             data->p = '%s'\n", var = data->p )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "             ME.CEO_GSLOCATE->spec_prompt1 = '%s'\n",
    		  var = p_CEO_GSLOCATE->spec_prompt1 )
	    }
	} /*** ME.CEO_GSLOCATE->spec_prompt1 ***/
      else if ( ! strcmp ( arg, "spec_prompt2" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_GSLOCATE->spec_prompt2;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[me->spec_prompt2] data->p=(0x)%x  =?=  ME.CEO_GSLOCATE->prompt=(0x)%x\n",
    		  var = `data->p, p_CEO_GSLOCATE->spec_prompt2` )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "             data->p = '%s'\n", var = data->p )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "             ME.CEO_GSLOCATE->spec_prompt2 = '%s'\n",
    		  var = p_CEO_GSLOCATE->spec_prompt2 )
	    }
	} /*** ME.CEO_GSLOCATE->spec_prompt2 ***/
      else if ( ! strcmp ( arg, "spec_mask1" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->l = p_CEO_GSLOCATE->spec_mask1;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[me->spec_mask1] data->l=%d =?= ME.CEO_GSLOCATE->spec_mask1=%d\n",
    		  var = `data->l, p_CEO_GSLOCATE->spec_mask1` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_GSLOCATE->spec_mask1;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[&me->spec_mask1] data->p=(0x)%x  =?=  & ME.CEO_GSLOCATE->spec_mask1=(0x)%x\n",
    		  var = `data->p, &p_CEO_GSLOCATE->spec_mask1` )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "                ME.CEO_GSLOCATE->spec_mask1 = %d\n",
    		  var = p_CEO_GSLOCATE->spec_mask1 )
	    }
	} /*** ME.CEO_GSLOCATE->spec_mask1 ***/
      else if ( ! strcmp ( arg, "spec_mask2" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->l = p_CEO_GSLOCATE->spec_mask2;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[me->spec_mask2] data->l=%d =?= ME.CEO_GSLOCATE->spec_mask2=%d\n",
    		  var = `data->l, p_CEO_GSLOCATE->spec_mask2` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_GSLOCATE->spec_mask2;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[&me->spec_mask2] data->p=(0x)%x  =?=  & ME.CEO_GSLOCATE->spec_mask2=(0x)%x\n",
    		  var = `data->p, &p_CEO_GSLOCATE->spec_mask2` )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "                ME.CEO_GSLOCATE->spec_mask2 = %d\n",
    		  var = p_CEO_GSLOCATE->spec_mask2 )
	    }
	} /*** ME.CEO_GSLOCATE->spec_mask2 ***/
      else if ( ! strcmp ( arg, "locate_state" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_GSLOCATE->locate_state;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[me->locate_state] data->i=%d =?= ME.CEO_GSLOCATE->locate_state=%d\n",
    		  var = `data->i, p_CEO_GSLOCATE->locate_state` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_GSLOCATE->locate_state;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[&me->locate_state] data->p=(0x)%x  =?=  & ME.CEO_GSLOCATE->locate_state=(0x)%x\n",
    		  var = `data->p, &p_CEO_GSLOCATE->locate_state` )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "               ME.CEO_GSLOCATE->locate_state = %d\n",
    		  var = p_CEO_GSLOCATE->locate_state )
	    }
	} /*** ME.CEO_GSLOCATE->locate_state ***/
      else if ( ! strcmp ( arg, "num_inputs" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_GSLOCATE->num_inputs;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[me->num_inputs] data->i=%d =?= ME.CEO_GSLOCATE->num_inputs=%d\n",
    		  var = `data->i, p_CEO_GSLOCATE->num_inputs` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_GSLOCATE->num_inputs;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[&me->num_inputs] data->p=(0x)%x  =?=  & ME.CEO_GSLOCATE->num_inputs=(0x)%x\n",
    		  var = `data->p, &p_CEO_GSLOCATE->num_inputs` )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "               ME.CEO_GSLOCATE->num_inputs = %d\n",
    		  var = p_CEO_GSLOCATE->num_inputs )
	    }
	} /*** ME.CEO_GSLOCATE->num_inputs ***/
    }
  else	/*** arg string did not begin with "me->" ***/
    {
	/**************************************************************/
	/*			  Global variables		      */
	/**************************************************************/

	/*** put "sts" entry in here, as well as in CEO and	    ***/
	/***   CEO_LOCATE, so it doesn't have to search all	    ***/
	/*** entries here, and go call CEO's method -- JAJ:08-26-88 ***/
      if ( ! strcmp ( arg, "sts" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) & ME.CEO->ret;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[sts] data->p=(0x)%x  =?=  & ME.CEO->ret=(0x)%x\n",
    		  var = `data->p, &ME.CEO->ret` )
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "		  *data->p = %ld\n", var=`*data->p`)
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "		  ME.CEO->ret = %d\n",
    		  var = ME.CEO->ret );
	    }
	  else if ( addr_mode == _COB_indirect )
	    {
	      data->l = ME.CEO->ret;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_GSLOCATE_debug,str=
		  "[*sts] data->l=%ld  =?=  ME.CEO->ret=%ld\n",
    		  var = `data->l, ME.CEO->ret` );
	    }
	}
    }

	/*** if it's unknown, send it to parent ***/
  if ( * ret_type == _COB_UNKNOWN_ARG )
    {
      _bugprint(bflag=CEO_GSLOCATE_debug, str=
	  "Passing arg string back to CEO_LOCATE\n" )
      status = om$send ( targetid = my_id,
			 mode = OM_e_wrt_message,
			 msg = message CEO_LOCATE.arg_name_to_value (
					addr_mode, class_name, arg,
					data, ret_type, is_const ) );
#ifdef DEBUG
      _cob_check ( status, \
	"CEO_GSLOCATE.arg_name_to_value:  CEO_LOCATE.arg_name_to_value() failed." );
#endif
    }

quit:
  _bugprint(bflag=TFLAG,str=
    "-CEO_GSLOCATE.arg_name_to_value:  data->[l]=%ld, *ret_type=%d, *is_const=%d\n",
    var = `data->l, *ret_type, *is_const` )

  return OM_S_SUCCESS;

} /*** end of CEO_GSLOCATE.arg_name_to_value method ***/


end implementation CEO_GSLOCATE;
