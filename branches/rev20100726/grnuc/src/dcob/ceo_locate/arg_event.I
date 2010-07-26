/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/arg_event.I -- JAJ:02-15-88 */
/*
  function COB_process_GRevent_arg():
    translates a string (known to describe a GRevent structure)
    into its variable name value for the CEO.arg_name_to_value method
*/

class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


void   COB_process_GRevent_arg ( addr_mode, p_event, arg,
			data, ret_type, is_const )
	/* Incoming */
  int		  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
  struct GRevent* p_event;	/* ptr to real event to take data from*/
  char  	* arg;		/* arg string to find a value for;    */
				/*   starts at			      */
				/*   me->event1.response	      */
				/*	        ^		      */
	/* Outgoing */
  COB_arg_union	* data;		/* value of arg string variable       */
  int		* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  char		* is_const; 	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */
{
  char * ch = '\0';
  int	 arg_num = -1;  
  extern COB_process_EX_button_arg  ( );
  extern COB_process_GRlc_info_arg ( );
  extern COB_fetch_first_arg_num ( );


  _bugprint(bflag=TFLAG,str=
  "+COB_process_GRevent_arg(arg='%s', addr_mode=%d, p_event=(0x)%x):\n",
    var = `arg, addr_mode, p_event` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;


  if ( ! strcmp ( arg, "response" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->i = p_event->response;
	  * ret_type = _COB_arg_i;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[response]  data->i=%d  =?=  p_event->response = %d\n",
    	      var=`data->i, p_event->response`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_event->response);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&response] data->p=(0x)%x =?=  & p_event->response=(0x)%x\n",
    	      var=`data->p, &(p_event->response)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "   *data->p = %d  =?=  p_event->response = %d\n",
    	      var=`*data->p, p_event->response`)
	}
    }  /*** response ***/
  else if ( ! strcmp ( arg, "nbytes" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->i = p_event->nbytes;
	  * ret_type = _COB_arg_i;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[nbytes] data->i=%d  =?=  p_event->nbytes = %d\n",
    	      var=`data->i, p_event->nbytes`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_event->nbytes);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&nbytes] data->p=(0x)%x =?=  & p_event->nbytes=(0x)%x\n",
    	      var=`data->p, &(p_event->nbytes)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "   *data->p=%d  =?=  p_event->nbytes = %d\n",
    	      var=`*data->p, p_event->nbytes`)
	}
    }  /*** nbytes ***/
  else if ( ! strcmp ( arg, "event" ) )
    {
      if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_event->event);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&event] data->p=(0x)%x =?=  & p_event->event=(0x)%x\n",
    	      var=`data->p, &(p_event->event)`)
	}
    }  /*** & event ***/
  else if ( ! strncmp ( arg, "event.", 6 ) )
    {
       if ( ! strcmp ( &arg[6], "button" ) )
	{
	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & (p_event->event.button);
	      * ret_type = _COB_arg_p;
	      /***  * is_const = 1;		JAJ:02/04/91  ***/
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&event.button] data->p=(0x)%x =?=  & p_event->event.button=(0x)%x\n",
    	          var=`data->p, &(p_event->event.button)`)
	    }
	}  /*** & event.button ***/
       else if ( ! strncmp ( &arg[6], "button.", 7 ) )
	{
	 _bugprint(bflag=CEO_LOCATE_debug,str=
	  "Calling COB_process_EX_button_arg ('%s', p_button=(0x)%x)\n",
	    var = `&arg[13], & (p_event->event.button)` )
	  COB_process_EX_button_arg ( addr_mode,
			& ( p_event->event.button ),
			& arg[13], data, ret_type, is_const );

	}  /** event.button.___ **/
       else if ( ! strcmp ( &arg[6], "keyin" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_event->event.keyin;
	      * ret_type = _COB_arg_p;
	      /***  * is_const = 1;		JAJ:02/04/91  ***/
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[event.keyin] data->p=(0x)%x =?=  p_event->event.keyin=(0x)%x\n",
    	          var=`data->p, p_event->event.keyin`)
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  data->p='%s'  =?=  p_event->event.keyin='%s'\n",
    	          var=`data->p, p_event->event.keyin`)
	    }
	}  /*** event.keyin ***/
       else if ( ! strcmp ( &arg[6], "value" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->d = p_event->event.value;
	      * ret_type = _COB_arg_d;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[event.value] data->d=%lf  =?=  p_event->event.value=%lf\n",
    	          var=`data->d, p_event->event.value`)
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & (p_event->event.value);
	      * ret_type = _COB_arg_p;
	      /***  * is_const = 1;		JAJ:02/04/91  ***/
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&event.value] data->p=(0x)%x =?=  & p_event->event.value=(0x)%x\n",
    	          var=`data->p, &(p_event->event.value)`)
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  * data->p=%lf  =?=  p_event->event.value=%lf\n",
    	          var=`*data->p, p_event->event.value`)
	    }
	}  /*** event.value ***/
    }  /*** event.____ ***/
  else if ( ! strcmp ( arg, "subtype" ) )
    {
      if ( addr_mode == _COB_regular )
	{
	  data->i = p_event->subtype;
	  * ret_type = _COB_arg_i;
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[subtype] data->i=%d  =?=  p_event->subtype = %d\n",
    	      var=`data->i, p_event->subtype`)
	}
      else if ( addr_mode == _COB_address )
	{
	  data->p = (char *) & (p_event->subtype);
	  * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&subtype] data->p=(0x)%x =?= & p_event->subtype=(0x)%x\n",
    	      var=`data->p, & (p_event->subtype)`)
	  _bugprint(bflag=CEO_LOCATE_debug,str=
	      "   *data->p=%d  =?=  p_event->subtype = %d\n",
    	      var=`*data->p, p_event->subtype`)
	}
    }  /*** subtype ***/
  else if ( ! strcmp ( arg, "num_id" ) )
    {
      if ( addr_mode == _COB_regular )
        {
          data->s = p_event->num_id;
          * ret_type = _COB_arg_s;
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[num_id] data->s=%hd  =?=  p_event->num_id = %hd\n",
    	      var=`data->s, p_event->num_id`)
        }
      else if ( addr_mode == _COB_address )
        {
          data->p = (char *) & (p_event->num_id);
          * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&num_id] data->p=(0x)%x =?=  & p_event->num_id=(0x)%x\n",
    	      var=`data->p, & (p_event->num_id)`)
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "   *data->p=%hd  =?=  p_event->num_id = %hd\n",
    	      var=`*data->p, p_event->num_id`)
        }
    }  /*** num_id ***/
  else if ( ! strcmp ( arg, "num_val" ) )
    {
      if ( addr_mode == _COB_regular )
        {
          data->s = p_event->num_val;
          * ret_type = _COB_arg_s;
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[num_val] data->s=%hd  =?=  p_event->num_val = %hd\n",
    	      var=`data->s, p_event->num_val`)
        }
      else if ( addr_mode == _COB_address )
        {
          data->p = (char *) & (p_event->num_val);
          * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&num_val] data->p=(0x)%x =?=  & p_event->num_val=(0x)%x\n",
    	      var=`data->p, &(p_event->num_val)`)
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "   *data->p=%hd  =?=  p_event->num_val = %hd\n",
    	      var=`*data->p, p_event->num_val`)
        }
    }  /*** num_val ***/
  else if ( ! strcmp ( arg, "values" ) )
    {
      if ( addr_mode == _COB_regular )
        {
          data->p = (char *) p_event->values ;
          * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[values]  data->p=(0x)%x =?=  p_event->values=(0x)%x\n",
    	      var=`data->p, p_event->values` )
        }
    }  /*** & values ***/
  else if ( ! strcmp ( arg, "values[0]" ) )
    {
      if ( addr_mode == _COB_regular )
        {
          data->d = p_event->values[0];
          * ret_type = _COB_arg_d;
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[values[0]] data->d=%lf  =?=  p_event->values[0] = %lf\n",
    	      var=`data->d, p_event->values[0]`)
        }
      else if ( addr_mode == _COB_address )
        {
          data->p = (char *) & (p_event->values[0]);
          * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&values[0]] data->p=(0x)%x  =?=  & p_event->values[0]=(0x)%x\n",
    	      var=`data->p, & (p_event->values[0])`)
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "   *data->p=%lf  =?=  p_event->values[0] = %lf\n",
    	      var=`*data->p, p_event->values[0]`)
        }
    }  /*** values[0] ***/
  else if ( ! strcmp ( arg, "values[1]" ) )
    {
      if ( addr_mode == _COB_regular )
        {
          data->d = p_event->values[1];
          * ret_type = _COB_arg_d;
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[values[1]] data->d=%lf  =?=  p_event->values[1] = %lf\n",
    	      var=`data->d, p_event->values[1]`)
        }
      else if ( addr_mode == _COB_address )
        {
          data->p = (char *) & (p_event->values[1]);
          * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "[&values[1]] data->p=(0x)%x  =?=  & p_event->values[1]=(0x)%x\n",
    	      var=`data->p, & (p_event->values[1])`)
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "   *data->p=%lf  =?=  p_event->values[1] = %lf\n",
    	      var=`*data->p, p_event->values[1]`)
        }
    }  /*** values[1] ***/
  else if ( ! strcmp ( arg, "located_object" ) )
    {
      if ( addr_mode == _COB_regular )
        {
          data->p = (char *) p_event->located_object;
          * ret_type = _COB_arg_p;
	  /***  * is_const = 1;		JAJ:02/04/91  ***/
          _bugprint(bflag=CEO_LOCATE_debug,str=
	      "  data->p=(0x)%x =?=  p_event->located_object=(0x)%x\n",
    	      var=`data->p, p_event->located_object` )
        }
    }  /*** located_object ***/
  else if ( ! strncmp ( arg, "located_object[", 15 ) )
    {
      _bugprint(bflag=CEO_LOCATE_debug,str=
	   "Calling COB_fetch_first_arg_num ('%s')\n", var = arg )
      arg_num = COB_fetch_first_arg_num ( arg, &ch );
      _bugprint(bflag=CEO_LOCATE_debug,str=
	   "Called COB_fetch_first_arg_num (ch='%s'): arg_num = %d\n",
	    var = `ch, arg_num` )

#define LC_OBJECT_DIM	2
      if ( arg_num < 0  ||  arg_num >= LC_OBJECT_DIM )
	{
	  fprintf ( stderr,
	    "\nCOB_process_GRevent():  Reference to struct GRevent field located_object[%d]\n\tin state table argument is invalid\n\n", arg_num );
	}
      else
	{
	    /*** eat up the "." after the closing ']' ***/
	 ch++;				/*** JAJ:04-19-88 ***/

	  _bugprint(bflag=CEO_LOCATE_debug,str=
	 "Calling COB_process_GRlc_info_arg ('%s', p_lc_info=(0x)%x)\n",
	    var = `ch, & (p_event->located_object[arg_num])` )
	  COB_process_GRlc_info_arg ( addr_mode,
			& ( p_event->located_object[arg_num] ),
			ch, data, ret_type, is_const );
	}
    }  /*** located_object[x].____ ***/


  _bugprint(bflag=TFLAG,str=
    "-COB_process_GRevent_arg():  data->[l] = %ld, *ret_type = %d\n",
    var = `data->l, *ret_type` );

} /*** end of function COB_process_GRevent_arg () ***/

end implementation CEO_LOCATE;
