/* ceo/arg_name.I -- JAJ:01-27-88 */
/*
  translate a string into its variable name value
*/
class implementation CEO;


#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
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
  char * ch = '\0';
  int	 arg_num = -1;
  extern COB_fetch_first_arg_num ( );

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_instance		* p_CEO = ME.CEO;

  _bugprint(bflag=TFLAG,str=
    "+CEO.arg_name_to_value:  arg='%s', addr_mode=%d, [me]class='%s', *is_const=%d\n",
    var = `arg, addr_mode, ( class_name ? class_name : "" ), *is_const` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;

  if ( class_name[0] )	/*** arg string used to begin with "me->" ***/
    {
	/**************************************************************/
	/*			  CEO instance data		      */
	/**************************************************************/
      if ( ! strcmp ( arg, "ret" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->l = p_CEO->ret;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->ret] data->l=%d  =?=  ME.CEO->ret=%d\n",
    		  var = `data->l, p_CEO->ret` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO->ret;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[&me->ret] data->p=0x%x  =?=  & ME.CEO->ret=0x%x\n",
    		  var = `data->p, &p_CEO->ret` )
	      _bugprint(bflag=CEO_debug,str=
		"     *data->p=%d  =?=  ME.CEO->ret=%d\n",
    		      var=`*data->p, p_CEO->ret`);
	    }
	} /*** ME.CEO->ret ***/
      else if ( ! strcmp ( arg, "number_of_forms" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO->number_of_forms;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->n_of_forms] data->i=%d =?= ME.CEO->number_of_forms=%d\n",
    		  var = `data->i, p_CEO->number_of_forms` );
	    }
	} /*** ME.CEO->number_of_forms ***/
      else if ( ! strcmp ( arg, "const_class" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = p_CEO->const_class;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[me->const_class] data->p=0x%x  =?=  ME.CEO->const_class=0x%x\n",
    		  var = `data->p, p_CEO->const_class` )
	      _bugprint(bflag=CEO_debug,str=
		  "     ME.CEO->const_class = '%s'\n",
    		  var = p_CEO->const_class )
	      _bugprint(bflag=CEO_debug,str=
		  "     *data->p='%s'\n", var=*data->p );
	    }
	} /*** ME.CEO->const_class ***/
      else if ( ! strcmp ( arg, "const_chansel" ) )
	{
	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO->const_chansel;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[&me->const_chansel] data->p=0x%x  =?= & ME.CEO->const_chansel=0x%x\n",
    		  var = `data->p, & p_CEO->const_chansel` )
	    }
	} /*** & ME.CEO->const_chansel ***/
      else if ( ! strcmp ( arg, "origin_x" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO->origin_x;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->origin_x] data->i=%d =?= ME.CEO->origin_x=%d\n",
    		  var = `data->i, p_CEO->origin_x` );
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO->origin_x;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[&me->origin_x] data->p=0x%x  =?=  & ME.CEO->origin_x=0x%x\n",
    		  var = `data->p, &p_CEO->origin_x` )
	      _bugprint(bflag=CEO_debug,str=
		"     *data->p=%d  =?=  ME.CEO->origin_x=%d\n",
    		      var=`*data->p, p_CEO->origin_x`);
	    }
	} /*** ME.CEO->origin_x ***/
      else if ( ! strcmp ( arg, "origin_y" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO->origin_y;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->origin_y] data->i=%d =?= ME.CEO->origin_y=%d\n",
    		  var = `data->i, p_CEO->origin_y` );
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO->origin_y;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[&me->origin_y] data->p=0x%x  =?=  & ME.CEO->origin_y=0x%x\n",
    		  var = `data->p, &p_CEO->origin_y` )
	      _bugprint(bflag=CEO_debug,str=
		"     *data->p=%d  =?=  ME.CEO->origin_y=%d\n",
    		      var=`*data->p, p_CEO->origin_y`);
	    }
	} /*** ME.CEO->origin_y ***/
      else if ( ! strcmp ( arg, "forms" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) ME.CEO->forms;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[me->forms] data->p=0x%x  =?=  ME.CEO->forms=0x%x\n",
    		  var = `data->p, ME.CEO->forms` );
	    }
	} /*** ME.CEO->forms ***/
      else if ( ! strncmp ( arg, "forms[", 6 ) )
	{
	  arg_num = COB_fetch_first_arg_num ( arg, &ch );
	  if ( arg_num < 0  ||  arg_num >= p_CEO->number_of_forms )
	    {
	      fprintf ( stderr,
		"\nCEO.arg_name_to_value:  Reference to me->forms[%d] in state table argument is not valid\n\n", arg_num );
	    }
	  else
	    {
	      if ( ! strcmp ( ch, ".form_ptr" ) )
		{
		 if ( addr_mode == _COB_regular )
		  {
		    data->p = ME.CEO->forms[arg_num].form_ptr;
		    * ret_type = _COB_arg_p;
		    /***   * is_const = 1;  ***/
		    _bugprint(bflag=CEO_debug,str=
		      "[me->forms[%d].form_ptr] data->p=0x%x  =?=  ME.CEO->forms[%d].form_ptr=0x%x\n",
    		      var = `arg_num, data->p, arg_num, ME.CEO->forms[arg_num].form_ptr` );
		  }
		} /*** me->forms[xxx].form_ptr ***/
	      else if ( ! strcmp ( ch, ".label" ) )
		{
		 if ( addr_mode == _COB_regular )
		  {
		    data->i = ME.CEO->forms[arg_num].label;
		    * ret_type = _COB_arg_i;
		    _bugprint(bflag=CEO_debug,str=
		      "[me->forms[%d].label] data->i=%d  =?=  ME.CEO->forms[%d].label=%d\n",
    		      var = `arg_num, data->i, arg_num, ME.CEO->forms[arg_num].label` );
		  }
		} /*** me->forms[xxx].label ***/
	      else if ( ! strcmp ( ch, ".displayed" ) )
		{
		 if ( addr_mode == _COB_regular )
		  {
		    data->c = ME.CEO->forms[arg_num].displayed;
		    * ret_type = _COB_arg_c;
		    _bugprint(bflag=CEO_debug,str=
		      "[me->forms[%d].displayed] data->c=%d  =?=  ME.CEO->forms[%d].displayed=%d\n",
    		      var = `arg_num, data->c, arg_num, ME.CEO->forms[arg_num].displayed` );
		  }
		} /*** me->forms[xxx].displayed ***/
	      else if ( ! strcmp ( ch, ".x" ) )
		{
		 if ( addr_mode == _COB_regular )
		  {
		    data->i = ME.CEO->forms[arg_num].x;
		    * ret_type = _COB_arg_i;
		    _bugprint(bflag=CEO_debug,str=
		      "[me->forms[%d].x] data->i=%d  =?=  ME.CEO->forms[%d].x=%d\n",
    		      var = `arg_num, data->i, arg_num, ME.CEO->forms[arg_num].x` );
		  }
		 else if ( addr_mode == _COB_address )
		  {
		    data->p = (char *) & ME.CEO->forms[arg_num].x;
		    * ret_type = _COB_arg_p;
		    /***  *is_const = 1; ***/
		    _bugprint(bflag=CEO_debug,str=
		      "[&me->forms[%d].x] data->p=0x%x  =?=  & ME.CEO->forms[%d].x=0x%x\n",
    		      var = `arg_num, data->p, arg_num, & ME.CEO->forms[arg_num].x` )
		    _bugprint(bflag=CEO_debug,str=
		      "     *data->p=%d  =?=  ME.CEO->forms[%d].x=%d\n",
    		      var=`*data->p, arg_num, ME.CEO->forms[arg_num].x`);
		  }
		} /*** me->forms[xxx].x ***/
	      else if ( ! strcmp ( ch, ".y" ) )
		{
		 if ( addr_mode == _COB_regular )
		  {
		    data->i = ME.CEO->forms[arg_num].y;
		    * ret_type = _COB_arg_i;
		    _bugprint(bflag=CEO_debug,str=
		      "[me->forms[%d].y] data->i=%d  =?=  ME.CEO->forms[%d].y=%d\n",
    		      var = `arg_num, data->i, arg_num, ME.CEO->forms[arg_num].y` );
		  }
		 else if ( addr_mode == _COB_address )
		  {
		    data->p = (char *) & ME.CEO->forms[arg_num].y;
		    * ret_type = _COB_arg_p;
		    /***  *is_const = 1; ***/
		    _bugprint(bflag=CEO_debug,str=
		      "[&me->forms[%d].y] data->p=0x%x  =?=  & ME.CEO->forms[%d].y=0x%x\n",
    		      var = `arg_num, data->p, arg_num, & ME.CEO->forms[arg_num].y` )
		    _bugprint(bflag=CEO_debug,str=
		      "     *data->p=%d  =?=  ME.CEO->forms[%d].y=%d\n",
    		      var=`*data->p, arg_num, ME.CEO->forms[arg_num].y`);
		  }
		} /*** me->forms[xxx].y ***/
	      else if ( ! strcmp ( ch, ".name" ) )
		{
		 if ( addr_mode == _COB_regular )
		  {
		    data->p = ME.CEO->forms[arg_num].name;
		    * ret_type = _COB_arg_p;
		    /***   * is_const = 1;  ***/
		    _bugprint(bflag=CEO_debug,str=
		      "[me->forms[%d].name] data->p=0x%x  =?=  ME.CEO->forms[%d].name=0x%x\n",
    		      var = `arg_num, data->p, arg_num, ME.CEO->forms[arg_num].name` );
		    _bugprint(bflag=CEO_debug,str=
		      "     *data->p='%s'  =?=  ME.CEO->forms[%d].name='%s'\n",
    		      var=`*data->p, arg_num, ME.CEO->forms[arg_num].name`);
		  }
		} /*** me->forms[xxx].name ***/

	    } /*** end else ( arg_num OK ) ***/
	} /*** ME.CEO->forms[x]._____ ***/
      else if ( ! strcmp ( arg, "status_display_form_ptr" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = p_CEO->status_display_form_ptr;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->status_display_form_ptr] data->p=0x%x  =?=  ME.CEO->status_display_form_ptr=0x%x\n",
    		  var = `data->p, p_CEO->status_display_form_ptr` )
	    }
	} /*** ME.CEO->status_display_form_ptr ***/
      else if ( ! strcmp ( arg, "response" ) )
	{
	  if ( addr_mode == _COB_indirect )
	    {
	      data->i = * p_CEO->response;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_debug,str=
		  "[*me->response] data->i=%d  =?=  *ME.CEO->response=%d\n",
    		  var = `data->i, *p_CEO->response` );
	    }
	  else if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO->response;
	      * ret_type = _COB_arg_p;		/*** --JAJ:04-27-88 ***/
	      /***   *is_const = 1;      it's a int*		    ***/
	      _bugprint(bflag=CEO_debug,str=
		  "[me->response] data->p=0x%x  =?=  ME.CEO->response=0x%x\n",
    		  var = `data->p, p_CEO->response` )
	      _bugprint(bflag=CEO_debug,str=
		"   *data->p=%d  =?=  *ME.CEO->response=%d\n",
    		      var=`*data->p, *p_CEO->response`);
	    }
	} /*** ME.CEO->response ***/
      else if ( ! strcmp ( arg, "response_data" ) )
	{
	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO->response_data;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[&me->response_data] data->p=0x%x  =?=  &ME.CEO->response_data=0x%x\n",
    		  var = `data->p, &p_CEO->response_data` )
	      _bugprint(bflag=CEO_debug,str=
		  "		*data->p = '%s'\n",
    		  var = `*data->p` )
	      _bugprint(bflag=CEO_debug,str=
		  "		ME.CEO->response_data = '%s'\n",
    		  var = `p_CEO->response_data` );
	    }
	  else if ( addr_mode == _COB_regular )
	    {
	      data->p = p_CEO->response_data;
	      * ret_type = _COB_arg_p;		/*** --JAJ:03-29-88 ***/
	      /***   *is_const = 1;      it's a char*, not an array ***/
	      _bugprint(bflag=CEO_debug,str=
		  "[me->response_data] data->p=0x%x  =?=  ME.CEO->response_data=0x%x\n",
    		  var = `data->p, p_CEO->response_data` )
	      _bugprint(bflag=CEO_debug,str=
		  "		data->p = '%s'\n", var = data->p )
	      _bugprint(bflag=CEO_debug,str=
		  "		ME.CEO->response_data = '%s'\n",
    		  var = p_CEO->response_data );
	    }
	} /*** ME.CEO->response_data ***/
      else if ( ! strcmp ( arg, "nbytes1" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO->nbytes1;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->nbytes1] data->i=%d =?= ME.CEO->nbytes1=%d\n",
    		  var = `data->i, p_CEO->nbytes1` );
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO->nbytes1;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[&me->nbytes1] data->p=0x%x  =?=  & ME.CEO->nbytes1=0x%x\n",
    		  var = `data->p, &p_CEO->nbytes1` )
	      _bugprint(bflag=CEO_debug,str=
		"     *data->p=%d  =?=  ME.CEO->nbytes1=%d\n",
    		      var=`*data->p, p_CEO->nbytes1`);
	    }
	} /*** ME.CEO->nbytes1 ***/
      else if ( ! strcmp ( arg, "prompt" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = p_CEO->prompt;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[me->prompt] data->p=0x%x  =?=  ME.CEO->prompt=0x%x\n",
    		  var = `data->p, p_CEO->prompt` )
	      _bugprint(bflag=CEO_debug,str=
		  "		data->p = '%s'\n", var = data->p )
	      _bugprint(bflag=CEO_debug,str=
		  "		  ME.CEO->prompt = '%s'\n",
    		  var = p_CEO->prompt );
	    }
	} /*** ME.CEO->prompt ***/
      else if ( ! strcmp ( arg, "msg" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = p_CEO->msg;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[me->msg] data->p=0x%x  =?=  ME.CEO->msg=0x%x\n",
    		  var = `data->p, p_CEO->msg` )
	      _bugprint(bflag=CEO_debug,str=
		  "		data->p = '%s'\n", var = data->p )
	      _bugprint(bflag=CEO_debug,str=
		  "		  ME.CEO->msg = '%s'\n",
    		  var = p_CEO->msg );
	    }
	} /*** ME.CEO->msg ***/
      else if ( ! strcmp ( arg, "status" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = p_CEO->status;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[me->status] data->p=0x%x  =?=  ME.CEO->status=0x%x\n",
    		  var = `data->p, p_CEO->status` )
	      _bugprint(bflag=CEO_debug,str=
		  "		data->p = '%s'\n", var = data->p )
	      _bugprint(bflag=CEO_debug,str=
		  "		  ME.CEO->status = '%s'\n",
    		  var = p_CEO->status );
	    }
	} /*** ME.CEO->status ***/
      else if ( ! strcmp ( arg, "error_box" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = ME.CEO->error_box;
	      * ret_type = _COB_arg_p;
	      /*****   * is_const = 1;  IT'S a VLA *****/
	      _bugprint(bflag=CEO_debug,str=
		  "[me->error_box] data->p=0x%x  =?=  ME.CEO->error_box=0x%x\n",
    		  var = `data->p, ME.CEO->error_box` )
	      _bugprint(bflag=CEO_debug,str=
		  "		data->p = '%s'\n", var = data->p )
	      _bugprint(bflag=CEO_debug,str=
		  "		  ME.CEO->error_box = '%s'\n",
    		  var = ME.CEO->error_box );
	    }
	} /*** ME.CEO->error_box ***/
      else if ( ! strcmp ( arg, "filter_mode" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->l = p_CEO->filter_mode;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->filter_mode] data->l=%d =?= ME.CEO->filter_mode=%d\n",
    		  var = `data->l, p_CEO->filter_mode` );
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO->filter_mode;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[&me->filter_mode] data->p=0x%x  =?=  & ME.CEO->filter_mode=0x%x\n",
    		  var = `data->p, &p_CEO->filter_mode` )
	      _bugprint(bflag=CEO_debug,str=
		"     *data->p=%d  =?=  ME.CEO->filter_mode=%d\n",
    		      var=`*data->p, p_CEO->filter_mode`);
	    }
	} /*** ME.CEO->filter_mode ***/

	/**************************************************************/
	/*			super_cmd instance data		      */
	/**************************************************************/
      else if ( ! strcmp ( arg, "mytype" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = ME.super_cmd->mytype;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->mytype] data->i=%d  =?=  ME.super_cmd->mytype=%d\n",
    		  var = `data->i, ME.super_cmd->mytype` );
	    }
	} /*** ME.super_cmd->mytype ***/
      else if ( ! strcmp ( arg, "form_requested" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = ME.super_cmd->form_requested;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_debug,str=
		  "[me->form_req] data->i=%d  =?=  ME.super_cmd->form_requested=%d\n",
    		  var = `data->i, ME.super_cmd->form_requested` );
	    }
	} /*** ME.super_cmd->form_requested ***/
      else if ( ! strcmp ( arg, "cmd_key" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = ME.super_cmd->cmd_key;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[me->cmd_key] data->p=0x%x  =?=  ME.super_cmd->cmd_key=0x%x\n",
    		  var = `data->p, ME.super_cmd->cmd_key` )
	      _bugprint(bflag=CEO_debug,str=
		  "		  *data->p = '%s'\n", var=`*data->p`)
	      _bugprint(bflag=CEO_debug,str=
		  "		  ME.super_cmd->cmd_key = '%s'\n",
    		  var = ME.super_cmd->cmd_key );
	    }
	} /*** ME.super_cmd->cmd_key ***/
      else if ( ! strcmp ( arg, "active_form_name" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = ME.super_cmd->active_form_name;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[me->active_form_name] data->p=0x%x  =?=  ME.super_cmd->active_form_name=0x%x\n",
    		  var = `data->p, ME.super_cmd->active_form_name` )
	      _bugprint(bflag=CEO_debug,str=
		  "     *data->p = '%s'\n", var=`*data->p`)
	      _bugprint(bflag=CEO_debug,str=
		  "     ME.super_cmd->active_form_name = '%s'\n",
    		  var = ME.super_cmd->active_form_name );
	    }
	} /*** ME.super_cmd->active_form_name ***/
      else if ( ! strcmp ( arg, "path" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = ME.super_cmd->path;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[me->path] data->p=0x%x  =?=  ME.super_cmd->path=0x%x\n",
    		  var = `data->p, ME.super_cmd->path` )
	      _bugprint(bflag=CEO_debug,str=
		  "		  *data->p = '%s'\n", var=`*data->p`)
	      _bugprint(bflag=CEO_debug,str=
		  "		  ME.super_cmd->path = '%s'\n",
    		  var = ME.super_cmd->path );
	    }
	} /*** ME.super_cmd->path ***/
    }
  else	/*** arg string did not begin with "me->" ***/
    {
	/**************************************************************/
	/*			  Global variables		      */
	/**************************************************************/
      if ( ! strcmp ( arg, "sts" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) & p_CEO->ret;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_debug,str=
		  "[sts] data->p=0x%x  =?=  & ME.CEO->ret=0x%x\n",
    		  var = `data->p, &p_CEO->ret` )
	      _bugprint(bflag=CEO_debug,str=
		  "		  *data->p = %ld\n", var=`*data->p`)
	      _bugprint(bflag=CEO_debug,str=
		  "		  ME.CEO->ret = %d\n",
    		  var = p_CEO->ret );
	    }
	  else if ( addr_mode == _COB_indirect )
	    {
	      data->l = p_CEO->ret;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_debug,str=
		  "[*sts] data->l=%ld  =?=  ME.CEO->ret=%ld\n",
    		  var = `data->l, p_CEO->ret` );
	    }
	}
      else if ( ! strcmp ( arg, "my_id" ) && addr_mode == _COB_regular )
	{
	  data->oid = my_id;
	  * ret_type = _COB_arg_oid;
	  * is_const = 1;
	  _bugprint(bflag=CEO_debug,str=
		  "[my_id] data->oid=%d  =?=  my_id=%d\n",
    		  var = `data->oid, my_id` );
	}
      else if ( ! strcmp ( arg, "OM_Gw_current_OS" )  &&
				addr_mode == _COB_regular )
	{
	  data->us = OM_Gw_current_OS;
	  * ret_type = _COB_arg_us;
	  * is_const = 1;
	  _bugprint(bflag=CEO_debug,str=
	      "[OM_GW_current_OS] data->us=%hd  =?=  OM_GW_current_OS=%hd\n",
    	      var = `data->us, OM_Gw_current_OS` );
	}
      else if ( ! strcmp ( arg, "NULL_OBJID" )  &&
				addr_mode == _COB_regular )
	{
	  data->oid = NULL_OBJID;
	  * ret_type = _COB_arg_oid;
	  * is_const = 1;
	  _bugprint(bflag=CEO_debug,str=
		  "[NULL_OBJID] data->oid=%d  =?=  NULL_OBJID=%d\n",
    		  var = `data->oid, NULL_OBJID` );
	}
    }

  _bugprint(bflag=TFLAG,str=
    "-CEO.arg_name_to_value:  data->[l]=%ld, *ret_type=%d, *is_const=%d\n",
    var = `data->l, *ret_type, *is_const` )

  return OM_S_SUCCESS;
} /*** end of CEO.arg_name_to_value method ***/



/*--------------------------------------------------------------------*/
int COB_fetch_first_arg_num ( arg_str, str_ptr_out )
  char * arg_str;
  char ** str_ptr_out;
{
#define NUM_STR_DIM 132
  int		ii;
  char	      *	ch = '\0';
  char		num_str[ NUM_STR_DIM ];
  int		found_num = -1;
  COB_arg_union data;
  int		data_type;
  extern char * strchr();
  extern 	COB_actions_const_arg ();

  _bugprint(bflag=TFLAG, str =
    "+COB_fetch_first_arg_num ( arg_str = '%s' )\n", var = arg_str )

  * str_ptr_out = NULL;
  ch = strchr ( arg_str, '[' );
  if ( ! (*ch) )	/** string doesn't contain a '[' char **/
    goto quit;
    
  for ( ii=0, ch++; *ch && (*ch != ']') && (ii<NUM_STR_DIM); ii++, ch++)
    {
	num_str[ii] = *ch;
    }

  if ( *ch == ']' )
    {
	num_str[ii] = '\0';
	* str_ptr_out = ch+1;
    }
  else
	goto quit;	/*** the ']' was never found ***/

  /*** translate the string into a number ***/
  if ( COB_actions_const_arg ( num_str, &data, &data_type ) )
    {
      if ( data_type == _COB_arg_l )
	    found_num = data.l;
    }


quit:
  _bugprint(bflag=TFLAG, str =
    "-COB_fetch_first_arg_num(arg_str='%s', *str_ptr_out='%s'):  num=%d\n",
	 var = `arg_str, *str_ptr_out, found_num` )

  return found_num;

}  /*** end of function COB_fetch_first_arg_num() ***/


end implementation CEO;
