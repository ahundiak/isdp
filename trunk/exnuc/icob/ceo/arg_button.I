/* ceo/arg_button.I -- JAJ:02-15-88 */
/*
  function COB_process_EX_button_arg():
    translates a string (known to describe an EX_button structure)
    into its variable name value for the CEO.arg_name_to_value method
*/

class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif

void COB_process_EX_button_arg ( addr_mode, p_button, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
struct EX_button* p_button;	/* ptr to real button to get data from*/
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
				/*   me->event1.event.button.x	      */
				/*			     ^	      */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const; 	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  _bugprint(bflag=TFLAG,str=
   "+COB_process_EX_button_arg(arg='%s',addr_mode=%d, p_button=(0x)%x):\n",
    var = `arg, addr_mode, p_button` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;

  if ( ! strcmp ( arg, "x" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->d = p_button->x;
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->d=%lf  =?=  p_button->x = %lf\n",
    	      var=`data->d, p_button->x`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->x);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->x=(0x)%x\n",
    	      var=`data->p, &p_button->x`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%lf  =?=  p_button->x = %lf\n",
    	      var=`*data->p, p_button->x`)
	}
    }  /* x */
  else if ( ! strcmp ( arg, "y" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->d = p_button->y;
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->d=%lf  =?=  p_button->y = %lf\n",
    	      var=`data->d, p_button->y`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->y);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->y=(0x)%x\n",
    	      var=`data->p, &p_button->y`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%lf  =?=  p_button->y = %lf\n",
    	      var=`*data->p, p_button->y`)
	}
    }  /* y */
  else if ( ! strcmp ( arg, "z" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->d = p_button->z;
	  * ret_type = _COB_arg_d;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->d=%lf  =?=  p_button->z = %lf\n",
    	      var=`data->d, p_button->z`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->z);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->z=(0x)%x\n",
    	      var=`data->p, &p_button->z`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%lf  =?=  p_button->z = %lf\n",
    	      var=`*data->p, p_button->z`)
	}
    }  /* z */
  else if ( ! strcmp ( arg, "window" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->l = p_button->window;
	  * ret_type = _COB_arg_l;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->l=%ld  =?=  p_button->window = %ld\n",
    	      var=`data->l, p_button->window`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->window);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->window=(0x)%x\n",
    	      var=`data->p, &p_button->window`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%ld  =?=  p_button->window = %ld\n",
    	      var=`*data->p, p_button->window`)
	}
    }  /* window */
  else if ( ! strcmp ( arg, "objid" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->oid = p_button->objid;
	  * ret_type = _COB_arg_oid;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->oid=%d  =?=  p_button->objid = %d\n",
    	      var=`data->oid, p_button->objid`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->objid);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->objid=(0x)%x\n",
    	      var=`data->p, &p_button->objid`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%d  =?=  p_button->objid = %d\n",
    	      var=`*data->p, p_button->objid`)
	}
    }  /* objid */
  else if ( ! strcmp ( arg, "osnum" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->us = p_button->osnum;
	  * ret_type = _COB_arg_us;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->us=%hd  =?=  p_button->osnum = %hd\n",
    	      var=`data->us, p_button->osnum`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->osnum);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->osnum=(0x)%x\n",
    	      var=`data->p, &p_button->osnum`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%hd  =?=  p_button->osnum = %hd\n",
    	      var=`*data->p, p_button->osnum`)
	}
    }  /* osnum */
  else if ( ! strcmp ( arg, "numb" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->s = p_button->numb;
	  * ret_type = _COB_arg_s;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->s=%hd  =?=  p_button->numb = %hd\n",
    	      var=`data->s, p_button->numb`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->numb);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->numb=(0x)%x\n",
    	      var=`data->p, &p_button->numb`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%hd  =?=  p_button->numb = %hd\n",
    	      var=`*data->p, p_button->numb`)
	}
    }  /* numb */
  else if ( ! strcmp ( arg, "clicks" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->s = p_button->clicks;
	  * ret_type = _COB_arg_s;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->s=%hd  =?=  p_button->clicks = %hd\n",
    	      var=`data->s, p_button->clicks`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->clicks);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->clicks=(0x)%x\n",
    	      var=`data->p, &p_button->clicks`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%hd  =?=  p_button->clicks = %hd\n",
    	      var=`*data->p, p_button->clicks`)
	}
    }  /* clicks */
  else if ( ! strcmp ( arg, "button_down" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->s = p_button->button_down;
	  * ret_type = _COB_arg_s;
	  _bugprint(bflag=CEO_debug,str=
	      "  data->s=%hd  =?=  p_button->button_down = %hd\n",
    	      var=`data->s, p_button->button_down`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) &(p_button->button_down);
	  * ret_type = _COB_arg_p;
	  /***   * is_const = 1;   JAJ:02/04/91 ***/
	  _bugprint(bflag=CEO_debug,str=
	      "  data->p=(0x)%x  =?=  & p_button->button_down=(0x)%x\n",
    	      var=`data->p, &p_button->button_down`)
	  _bugprint(bflag=CEO_debug,str=
	      "   *data->p=%hd  =?=  p_button->button_down = %hd\n",
    	      var=`*data->p, p_button->button_down`)
	}
    }  /* button_down */

/*quit:*/
  _bugprint(bflag=TFLAG,str=
    "-COB_process_EX_button_arg():  data->[l] = %ld, *ret_type = %d\n",
    var = `data->l, *ret_type` );
   /*** put a ';' at the end of the last bugprint so opp will      ***/
   /***   take it if you're not compiling with DEBUG		   ***/

} /*** end of function COB_process_EX_button_arg () ***/

end implementation CEO;
