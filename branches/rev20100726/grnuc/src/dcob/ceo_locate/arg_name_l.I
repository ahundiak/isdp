/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/arg_name_l.I -- JAJ:02-14-88 */
/*
  translate a string into its variable name value
*/
class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
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
  struct GRevent * p_event;
  int		   status;
  extern	   COB_process_GRevent_arg  ();
  extern	   COB_process_GRmd_env_arg ();

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_LOCATE_instance	* p_CEO_LOCATE = ME.CEO_LOCATE;


  _bugprint(bflag=TFLAG,str=
    "+CEO_LOCATE.arg_name_to_value:  arg='%s', addr_mode=%d, [me]class='%s', *is_const=%d\n",
    var = `arg, addr_mode, ( class_name ? class_name : "" ), *is_const` )

  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;

  if ( class_name[0] )	/*** arg string used to begin with "me->" ***/
    {
	/**************************************************************/
	/*		  CEO_LOCATE instance data		      */
	/**************************************************************/
      if ( !strcmp(arg, "event1")  ||  !strcmp(arg, "event2")  ||
				       !strcmp(arg, "event3")	)
	{
	  if ( arg[5] == '1' )
		p_event = & p_CEO_LOCATE->event1;
	  else if ( arg[5] == '2' )
		p_event = & p_CEO_LOCATE->event2;
	  else
		p_event = & p_CEO_LOCATE->event3;

	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) p_event;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->event%c] data->p= 0x%x  =?=  ME.CEO_LOCATE->event%d= 0x%x\n",
    		      var = `arg[5], data->p, arg[5], p_event` )
	    }
	} /*** & ME.CEO_LOCATE->event[1,2,3] ***/
      else if (    ! strncmp(arg, "event1.", 7)  ||
		   ! strncmp(arg, "event2.", 7)  ||
		   ! strncmp(arg, "event3.", 7)		)
	{
	  if ( arg[5] == '1' )
		p_event = & p_CEO_LOCATE->event1;
	  else if ( arg[5] == '2' )
		p_event = & p_CEO_LOCATE->event2;
	  else
		p_event = & p_CEO_LOCATE->event3;

	 _bugprint(bflag=CEO_LOCATE_debug,str=
	    "Calling COB_process_GRevent_arg ('%s', p_event= 0x%x)\n",
	    var = `&arg[7], p_event` )
	  COB_process_GRevent_arg ( addr_mode, p_event,
				  &arg[7], data, ret_type, is_const );

	} /*** ME.CEO_LOCATE->event[1,2,3]._____ ***/
      else if ( !strcmp(arg, "ModuleInfo") )
	{
	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->ModuleInfo;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->ModuleInfo] data->p= 0x%x  =?=  ME.CEO_LOCATE->ModuleInfo= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->ModuleInfo` )
	    }
	} /*** & ME.CEO_LOCATE->ModuleInfo ***/
      else if ( ! strncmp(arg, "ModuleInfo.", 11 ) )
	{
	 _bugprint(bflag=CEO_LOCATE_debug,str=
	   "Calling COB_process_GRmd_env_arg ('%s', p_md_env= 0x%x)\n",
	    var = `&arg[11], &p_CEO_LOCATE->ModuleInfo` )
	  COB_process_GRmd_env_arg ( addr_mode,
				  &p_CEO_LOCATE->ModuleInfo,
				  &arg[11], data, ret_type, is_const );

	} /*** ME.CEO_LOCATE->ModuleInfo._____ ***/
      else if ( !strcmp(arg, "locate_ModuleInfo") )
	{
	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->locate_ModuleInfo;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->locate_ModuleInfo] data->p= 0x%x  =?=  ME.CEO_LOCATE->locate_ModuleInfo= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->locate_ModuleInfo` )
	    }
	} /*** & ME.CEO_LOCATE->locate_ModuleInfo -- JAJ:10-02-89 ***/
      else if ( ! strncmp(arg, "locate_ModuleInfo.", 18 ) )
	{
	 _bugprint(bflag=CEO_LOCATE_debug,str=
	   "Calling COB_process_GRmd_env_arg ('%s', p_md_env= 0x%x)\n",
	    var = `&arg[11], &p_CEO_LOCATE->locate_ModuleInfo` )
	  COB_process_GRmd_env_arg ( addr_mode,
				  &p_CEO_LOCATE->locate_ModuleInfo,
				  &arg[18], data, ret_type, is_const );

	} /*** ME.CEO_LOCATE->locate_ModuleInfo.___ -- JAJ:10-02-89 ***/
      else if ( !strcmp(arg, "event_mask1") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->l = p_CEO_LOCATE->event_mask1;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->event_mask1] data->l= 0x%x  =?=  ME.CEO_LOCATE->event_mask1= 0x%x\n",
    		      var = `data->l, p_CEO_LOCATE->event_mask1` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->event_mask1;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->event_mask1] data->p= 0x%x  =?=  &ME.CEO_LOCATE->event_mask1= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->event_mask1` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->event_mask1= 0x%x\n",
    		      var = `*data->p, p_CEO_LOCATE->event_mask1` )
	    }
	} /*** ME.CEO_LOCATE->event_mask1 ***/
      else if ( !strcmp(arg, "scale_flag") )	/*** JAJ:05-22-89 ***/
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_LOCATE->scale_flag;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->scale_flag] data->i= %d  =?=  ME.CEO_LOCATE->scale_flag= %d\n",
    		      var = `data->i, p_CEO_LOCATE->scale_flag` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->scale_flag;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->scale_flag] data->p= 0x%x  =?=  &ME.CEO_LOCATE->scale_flag= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->scale_flag` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->scale_flag= 0x%x\n",
    		      var = `*data->p, p_CEO_LOCATE->scale_flag` )
	    }
	} /*** ME.CEO_LOCATE->scale_flag ***/
      else if ( !strcmp(arg, "event_size") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i =  p_CEO_LOCATE->event_size;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->event_size] data->i=%d  =?=  ME.CEO_LOCATE->event_size=%d\n",
    		      var = `data->i, p_CEO_LOCATE->event_size` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->event_size;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->event_size] data->p= 0x%x  =?=  &ME.CEO_LOCATE->event_size= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->event_size` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%d  =?=  ME.CEO_LOCATE->event_size=%d\n",
    		      var = `*data->p,p_CEO_LOCATE->event_size` )
	    }
	} /*** ME.CEO_LOCATE->event_size ***/
      else if ( !strcmp(arg, "DisplayMode") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_LOCATE->DisplayMode;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->DisplayMode] data->i=%d  =?=  ME.CEO_LOCATE->DisplayMode=%d\n",
    		      var = `data->i, p_CEO_LOCATE->DisplayMode` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->DisplayMode;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->DisplayMode] data->p= 0x%x  =?=  &ME.CEO_LOCATE->DisplayMode= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->DisplayMode` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%d  =?=  ME.CEO_LOCATE->DisplayMode=%d\n",
    		      var = `*data->p,p_CEO_LOCATE->DisplayMode` )
	    }
	} /*** ME.CEO_LOCATE->DisplayMode ***/
      else if ( !strcmp(arg, "HilightMode") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_LOCATE->HilightMode;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->HilightMode] data->i=%d  =?=  ME.CEO_LOCATE->HilightMode=%d\n",
    		      var = `data->i, p_CEO_LOCATE->HilightMode` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->HilightMode;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->HilightMode] data->p= 0x%x  =?=  &ME.CEO_LOCATE->HilightMode= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->HilightMode` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%d  =?=  ME.CEO_LOCATE->HilightMode=%d\n",
    		      var = `*data->p,p_CEO_LOCATE->HilightMode` )
	    }
	} /*** ME.CEO_LOCATE->HilightMode ***/
      else if ( !strcmp(arg, "UnhilightMode") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_LOCATE->UnhilightMode;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->UnhilightMode] data->i=%d  =?=  ME.CEO_LOCATE->UnhilightMode=%d\n",
    		      var = `data->i, p_CEO_LOCATE->UnhilightMode` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->UnhilightMode;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->UnhilightMode] data->p= 0x%x  =?=  &ME.CEO_LOCATE->UnhilightMode= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->UnhilightMode` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%d  =?=  ME.CEO_LOCATE->UnhilightMode=%d\n",
    		      var = `*data->p,p_CEO_LOCATE->UnhilightMode` )
	    }
	} /*** ME.CEO_LOCATE->UnhilightMode ***/
      else if ( !strcmp(arg, "value_type") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->value_type;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->value_type] data->p= 0x%x  =?=  ME.CEO_LOCATE->value_type= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->value_type` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "\tdata->p='%s'  =?=  ME.CEO_LOCATE->value_type='%s'\n",
    		      var = `data->p, p_CEO_LOCATE->value_type` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->value_type;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->value_type] data->p= 0x%x  =?=  &ME.CEO_LOCATE->value_type= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->value_type` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p='%s'  =?=  ME.CEO_LOCATE->value_type='%s'\n",
    		      var = `*data->p,p_CEO_LOCATE->value_type` )
	    }
	} /*** ME.CEO_LOCATE->value_type ***/
      else if ( !strcmp(arg, "value_type_locate") ) /** JAJ:12-19-88 **/
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->value_type_locate;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->value_type_locate] data->p= 0x%x  =?=  ME.CEO_LOCATE->value_type_locate= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->value_type_locate` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "\tdata->p='%s'  =?=  ME.CEO_LOCATE->value_type_locate='%s'\n",
    		      var = `data->p, p_CEO_LOCATE->value_type_locate` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->value_type_locate;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->value_type_locate] data->p= 0x%x  =?=  &ME.CEO_LOCATE->value_type_locate= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->value_type_locate` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p='%s'  =?=  ME.CEO_LOCATE->value_type_locate='%s'\n",
    		      var = `*data->p,p_CEO_LOCATE->value_type_locate` )
	    }
	} /*** ME.CEO_LOCATE->value_type_locate ***/
      else if ( !strcmp(arg, "value_type_accept") ) /** JAJ:12-19-88 **/
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->value_type_accept;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->value_type_accept] data->p= 0x%x  =?=  ME.CEO_LOCATE->value_type_accept= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->value_type_accept` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "\tdata->p='%s'  =?=  ME.CEO_LOCATE->value_type_accept='%s'\n",
    		      var = `data->p, p_CEO_LOCATE->value_type_accept` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->value_type_accept;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->value_type_accept] data->p= 0x%x  =?=  &ME.CEO_LOCATE->value_type_accept= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->value_type_accept` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p='%s'  =?=  ME.CEO_LOCATE->value_type_accept='%s'\n",
    		      var = `*data->p,p_CEO_LOCATE->value_type_accept` )
	    }
	} /*** ME.CEO_LOCATE->value_type_accept ***/
      else if ( ! strcmp ( arg, "DatabaseType" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->DatabaseType;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->DatabaseType] data->p= 0x%x  =?=  ME.CEO_LOCATE->DatabaseType= 0x%x\n",
    		  var = `data->p, p_CEO_LOCATE->DatabaseType` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "     ME.CEO_LOCATE->DatabaseType = '%s'\n",
    		  var = p_CEO_LOCATE->DatabaseType )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "     *data->p='%s'\n", var=*data->p );
	    }
	} /*** ME.CEO_LOCATE->DatabaseType ***/
      else if ( !strcmp(arg, "ActiveScale") )
	{
	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->ActiveScale;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->ActiveScale] data->p= 0x%x  =?=  ME.CEO_LOCATE->ActiveScale= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->ActiveScale` )
	    }
	} /*** & ME.CEO_LOCATE->ActiveScale ***/
      else if ( ! strncmp(arg, "ActiveScale.", 12 ) )
	{
	 _bugprint(bflag=CEO_LOCATE_debug,str=
	   "Calling COB_process_GRdpb_scale_arg ('%s', p_GRdpb_scale= 0x%x)\n",
	    var = `&arg[12], &p_CEO_LOCATE->ActiveScale` )
	  COB_process_GRdpb_scale_arg ( addr_mode,
				  &p_CEO_LOCATE->ActiveScale,
				  &arg[12], data, ret_type, is_const );

	} /*** ME.CEO_LOCATE->ActiveScale._____ ***/
      else if ( !strcmp(arg, "ActiveDisplay") )
	{
	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->ActiveDisplay;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->ActiveDisplay] data->p= 0x%x  =?=  ME.CEO_LOCATE->ActiveDisplay= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->ActiveDisplay` )
	    }
	} /*** & ME.CEO_LOCATE->ActiveDisplay ***/
      else if ( ! strncmp(arg, "ActiveDisplay.", 14 ) )
	{
	 _bugprint(bflag=CEO_LOCATE_debug,str=
	   "Calling COB_process_IGRdisplay_arg ('%s', p_IGRdisplay= 0x%x)\n",
	    var = `&arg[14], &p_CEO_LOCATE->ActiveDisplay` )
	  COB_process_IGRdisplay_arg ( addr_mode,
				  &p_CEO_LOCATE->ActiveDisplay,
				  &arg[14], data, ret_type, is_const );

	} /*** ME.CEO_LOCATE->ActiveDisplay._____ ***/
      else if ( !strcmp(arg, "ActiveAngle") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->d = p_CEO_LOCATE->ActiveAngle;
	      * ret_type = _COB_arg_d;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->ActiveAngle] data->d=%lf  =?=  ME.CEO_LOCATE->ActiveAngle=%lf\n",
    		      var = `data->d, p_CEO_LOCATE->ActiveAngle` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->ActiveAngle;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->ActiveAngle] data->p= 0x%x  =?=  &ME.CEO_LOCATE->ActiveAngle= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->ActiveAngle` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%lf  =?=  ME.CEO_LOCATE->ActiveAngle=%lf\n",
    		      var = `*data->p,p_CEO_LOCATE->ActiveAngle` )
	    }
	} /*** ME.CEO_LOCATE->ActiveAngle ***/
      else if ( !strcmp(arg, "ActiveLevel") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->s = p_CEO_LOCATE->ActiveLevel;
	      * ret_type = _COB_arg_s;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->ActiveLevel] data->s=%hd  =?=  ME.CEO_LOCATE->ActiveLevel=%hd\n",
    		      var = `data->s, p_CEO_LOCATE->ActiveLevel` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->ActiveLevel;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->ActiveLevel] data->p= 0x%x  =?=  &ME.CEO_LOCATE->ActiveLevel= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->ActiveLevel` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%hd  =?=  ME.CEO_LOCATE->ActiveLevel=%hd\n",
    		      var = `*data->p,p_CEO_LOCATE->ActiveLevel` )
	    }
	} /*** ME.CEO_LOCATE->ActiveLevel ***/
      else if ( ! strcmp ( arg, "acc_prompt" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->acc_prompt;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->acc_prompt] data->p= 0x%x  =?=  ME.CEO_LOCATE->acc_prompt= 0x%x\n",
    		  var = `data->p, p_CEO_LOCATE->acc_prompt` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "     ME.CEO_LOCATE->acc_prompt = '%s'\n",
    		  var = p_CEO_LOCATE->acc_prompt )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "     *data->p='%s'\n", var=*data->p );
	    }
	} /*** ME.CEO_LOCATE->acc_prompt ***/
      else if ( ! strcmp ( arg, "reloc_prompt" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->reloc_prompt;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->reloc_prompt] data->p= 0x%x  =?=  ME.CEO_LOCATE->reloc_prompt= 0x%x\n",
    		  var = `data->p, p_CEO_LOCATE->reloc_prompt` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "     ME.CEO_LOCATE->reloc_prompt = '%s'\n",
    		  var = p_CEO_LOCATE->reloc_prompt )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "     *data->p='%s'\n", var=*data->p );
	    }
	} /*** ME.CEO_LOCATE->reloc_prompt ***/
      else if ( !strcmp(arg, "event_mask2") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->l = p_CEO_LOCATE->event_mask2;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->event_mask2] data->l= 0x%x  =?=  ME.CEO_LOCATE->event_mask2= 0x%x\n",
    		      var = `data->l, p_CEO_LOCATE->event_mask2` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->event_mask2;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->event_mask2] data->p= 0x%x  =?=  &ME.CEO_LOCATE->event_mask2= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->event_mask2` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->event_mask2= 0x%x\n",
    		      var = `*data->p,p_CEO_LOCATE->event_mask2` )
	    }
	} /*** ME.CEO_LOCATE->event_mask2 ***/
      else if ( ! strcmp ( arg, "nbytes2" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_LOCATE->nbytes2;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->nbytes2] data->i=%d =?= ME.CEO_LOCATE->nbytes2=%d\n",
    		  var = `data->i, p_CEO_LOCATE->nbytes2` );
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->nbytes2;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->nbytes2] data->p= 0x%x  =?=  & ME.CEO_LOCATE->nbytes2= 0x%x\n",
    		  var = `data->p, &p_CEO_LOCATE->nbytes2` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		"     *data->p=%d  =?=  ME.CEO_LOCATE->nbytes2=%d\n",
    		      var=`*data->p, p_CEO_LOCATE->nbytes2`);
	    }
	} /*** ME.CEO_LOCATE->nbytes2 ***/
      else if ( !strcmp(arg, "display_flag") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->l = p_CEO_LOCATE->display_flag;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->display_flag] data->l= 0x%x  =?=  ME.CEO_LOCATE->display_flag= 0x%x\n",
    		      var = `data->l, p_CEO_LOCATE->display_flag` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->display_flag;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->display_flag] data->p= 0x%x  =?=  &ME.CEO_LOCATE->display_flag= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->display_flag` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->display_flag= 0x%x\n",
    		      var = `*data->p,p_CEO_LOCATE->display_flag` )
	    }
	} /*** ME.CEO_LOCATE->display_flag ***/
      else if ( !strcmp(arg, "type") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_LOCATE->type;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->type] data->i=%d  =?=  ME.CEO_LOCATE->type=%d\n",
    		      var = `data->i, p_CEO_LOCATE->type` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->type;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->type] data->p= 0x%x  =?=  &ME.CEO_LOCATE->type= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->type` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%d  =?=  ME.CEO_LOCATE->type=%d\n",
    		      var = `*data->p,p_CEO_LOCATE->type` )
	    }
	} /*** ME.CEO_LOCATE->type ***/
      else if ( !strcmp(arg, "action_handler") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->action_handler;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->action_handler] data->p= 0x%x  =?=  ME.CEO_LOCATE->action_handler= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->action_handler` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->action_handler;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->action_handler] data->p= 0x%x  =?=  &ME.CEO_LOCATE->action_handler= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->action_handler` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->action_handler= 0x%x\n",
    		      var = `*data->p,p_CEO_LOCATE->action_handler` )
	    }
	} /*** ME.CEO_LOCATE->action_handler ***/
      else if ( !strcmp(arg, "action_args") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->action_args;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->action_args] data->p= 0x%x  =?=  ME.CEO_LOCATE->action_args= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->action_args` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->action_args;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->action_args] data->p= 0x%x  =?=  &ME.CEO_LOCATE->action_args= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->action_args` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->action_args= 0x%x\n",
    		      var = `*data->p,p_CEO_LOCATE->action_args` )
	    }
	} /*** ME.CEO_LOCATE->action_args ***/
      else if ( !strcmp(arg, "regex") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_LOCATE->regex;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->regex] data->i=%d  =?=  ME.CEO_LOCATE->regex=%d\n",
    		      var = `data->i, p_CEO_LOCATE->regex` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->regex;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->regex] data->p= 0x%x  =?=  &ME.CEO_LOCATE->regex= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->regex` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%d  =?=  ME.CEO_LOCATE->regex=%d\n",
    		      var = `*data->p,p_CEO_LOCATE->regex` )
	    }
	} /*** ME.CEO_LOCATE->regex ***/
      else if ( !strcmp(arg, "stack_size") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->i = p_CEO_LOCATE->stack_size;
	      * ret_type = _COB_arg_i;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->stack_size] data->i=%d  =?=  ME.CEO_LOCATE->stack_size=%d\n",
    		      var = `data->i, p_CEO_LOCATE->stack_size` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->stack_size;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->stack_size] data->p= 0x%x  =?=  &ME.CEO_LOCATE->stack_size= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->stack_size` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p=%d  =?=  ME.CEO_LOCATE->stack_size=%d\n",
    		      var = `*data->p,p_CEO_LOCATE->stack_size` )
	    }
	} /*** ME.CEO_LOCATE->stack_size ***/
      else if ( !strcmp(arg, "select") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->select;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->select] data->p= 0x%x  =?=  ME.CEO_LOCATE->select= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->select` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->select;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->select] data->p= 0x%x  =?=  &ME.CEO_LOCATE->select= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->select` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->select= 0x%x\n",
    		      var = `*data->p,p_CEO_LOCATE->select` )
	    }
	} /*** ME.CEO_LOCATE->select ***/
      else if ( !strcmp(arg, "select_args") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->select_args;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->select_args] data->p= 0x%x  =?=  ME.CEO_LOCATE->select_args= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->select_args` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->select_args;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->select_args] data->p= 0x%x  =?=  &ME.CEO_LOCATE->select_args= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->select_args` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->select_args= 0x%x\n",
    		      var = `*data->p,p_CEO_LOCATE->select_args` )
	    }
	} /*** ME.CEO_LOCATE->select_args ***/
      else if ( !strcmp(arg, "located_chansel") )
	{
	  if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->located_chansel;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->located_chansel] data->p= 0x%x  =?=  &ME.CEO_LOCATE->located_chansel= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->located_chansel` )
	    }
	} /*** & ME.CEO_LOCATE->located_chansel ***/
      else if ( !strcmp(arg, "range_handler") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->range_handler;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->range_handler] data->p= 0x%x  =?=  ME.CEO_LOCATE->range_handler= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->range_handler` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->range_handler;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->range_handler] data->p= 0x%x  =?=  &ME.CEO_LOCATE->range_handler= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->range_handler` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->range_handler= 0x%x\n",
    		      var = `*data->p,p_CEO_LOCATE->range_handler` )
	    }
	} /*** ME.CEO_LOCATE->range_handler ***/
      else if ( !strcmp(arg, "range_args") )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) p_CEO_LOCATE->range_args;
	      * ret_type = _COB_arg_p;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[me->range_args] data->p= 0x%x  =?=  ME.CEO_LOCATE->range_args= 0x%x\n",
    		      var = `data->p, p_CEO_LOCATE->range_args` )
	    }
	  else if ( addr_mode == _COB_address )
	    {
	      data->p = (char *) & p_CEO_LOCATE->range_args;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[&me->range_args] data->p= 0x%x  =?=  &ME.CEO_LOCATE->range_args= 0x%x\n",
    		      var = `data->p, &p_CEO_LOCATE->range_args` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "  *data->p= 0x%x  =?=  ME.CEO_LOCATE->range_args= 0x%x\n",
    		      var = `*data->p,p_CEO_LOCATE->range_args` )
	    }
	} /*** ME.CEO_LOCATE->range_args ***/
    }
  else	/*** arg string did not begin with "me->" ***/
    {
	/**************************************************************/
	/*	  Global variables (and enum's )		      */
	/**************************************************************/

	/*** put "sts" entry in here, as well as in CEO, so it	***/
	/***   doesn't have to search all entries here, and go  ***/
	/***   call CEO's method		-- JAJ:08-26-88 ***/
      if ( ! strcmp ( arg, "sts" ) )
	{
	  if ( addr_mode == _COB_regular )
	    {
	      data->p = (char *) & ME.CEO->ret;
	      * ret_type = _COB_arg_p;
	      				  /*** --JAJ:10-03-90 ***/
	      /*** * is_const = 1;    INSTANCE DATA CAN MOVE  ***/

	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[sts] data->p= 0x%x  =?=  & ME.CEO->ret= 0x%x\n",
    		  var = `data->p, &ME.CEO->ret` )
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "		  *data->p = %ld\n", var=`*data->p`)
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "		  ME.CEO->ret = %d\n",
    		  var = ME.CEO->ret );
	    }
	  else if ( addr_mode == _COB_indirect )
	    {
	      data->l = ME.CEO->ret;
	      * ret_type = _COB_arg_l;
	      _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[*sts] data->l=%ld  =?=  ME.CEO->ret=%ld\n",
    		  var = `data->l, ME.CEO->ret` );
	    }
	}
		/**********************************/
		/**** start of GRdpmode enum's ****/
		/**********************************/
      else if ( !strcmp(arg, "GRbd")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRbd;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;

	    _bugprint(bflag=CEO_LOCATE_debug,str=
	    "[enum GRbd] data->i=%d  =?=  GRbd=%d\n",
    		      var = `data->i, GRbd` )
	} /*** enum "GRbd" ***/
      else if ( !strcmp(arg, "GRbe")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRbe;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;

	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRbe] data->i=%d  =?=  GRbe=%d\n",
    		      var = `data->i, GRbe` )
	} /*** enum "GRbe" ***/
      else if ( !strcmp(arg, "GRhd")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRhd;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;

	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRhd] data->i=%d  =?=  GRhd=%d\n",
    		      var = `data->i, GRhd` )
	} /*** enum "GRhd" ***/
      else if ( !strcmp(arg, "GRhe")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRhe;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;

	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRhe] data->i=%d  =?=  GRhe=%d\n",
    		      var = `data->i, GRhe` )
	} /*** enum "GRhe" ***/
      else if ( !strcmp(arg, "GRbdhd")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRbdhd;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRbdhd] data->i=%d  =?=  GRbdhd=%d\n",
    		      var = `data->i, GRbdhd` )
	} /*** enum "GRbdhd" ***/
      else if ( !strcmp(arg, "GRbehe")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRbehe;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRbehe] data->i=%d  =?=  GRbehe=%d\n",
    		      var = `data->i, GRbehe` )
	} /*** enum "GRbehe" ***/
      else if ( !strcmp(arg, "GRbdhe")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRbdhe;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRbdhe] data->i=%d  =?=  GRbdhe=%d\n",
    		      var = `data->i, GRbdhe` )
	} /*** enum "GRbdhe" ***/
      else if ( !strcmp(arg, "GRbehd")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRbehd;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRbehd] data->i=%d  =?=  GRbehd=%d\n",
    		      var = `data->i, GRbehd` )
	} /*** enum "GRbehd" ***/
      else if ( !strcmp(arg, "GRhhd")  &&  addr_mode == _COB_regular )
	{
	    data->i = GRhhd;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRhhd] data->i=%d  =?=  GRhhd=%d\n",
    		      var = `data->i, GRhhd` )
	} /*** enum "GRhhd" ***/
      else if ( !strcmp(arg, "GRhdo") &&  addr_mode == _COB_regular )
	{
	    data->i = GRhdo;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRhdo] data->i=%d  =?=  GRhdo=%d\n",
    		      var = `data->i, GRhdo` )
	} /*** enum "GRhdo" ***/
      else if ( !strcmp(arg, "GRhhdo") &&  addr_mode == _COB_regular )
	{
	    data->i = GRhhdo;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRhhdo] data->i=%d  =?=  GRhhdo=%d\n",
    		      var = `data->i, GRhhdo` )
	} /*** enum "GRhhdo" ***/
      else if ( !strcmp(arg, "GRheo") &&  addr_mode == _COB_regular )
	{
	    data->i = GRheo;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRheo] data->i=%d  =?=  GRheo=%d\n",
    		      var = `data->i, GRheo` )
	} /*** enum "GRheo" ***/
      else if ( !strcmp(arg, "GRbdheo") &&  addr_mode == _COB_regular )
	{
	    data->i = GRbdheo;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRbdheo] data->i=%d  =?=  GRbdheo=%d\n",
    		      var = `data->i, GRbdheo` )
	} /*** enum "GRbdheo" ***/
      else if ( !strcmp(arg, "GRbeheo") &&  addr_mode == _COB_regular )
	{
	    data->i = GRbeheo;
	    * ret_type = _COB_arg_i;
	    * is_const = 1;
	    _bugprint(bflag=CEO_LOCATE_debug,str=
		  "[enum GRbeheo] data->i=%d  =?=  GRbeheo=%d\n",
    		      var = `data->i, GRbeheo` )
	} /*** enum "GRbeheo" ***/

		/**********************************/
		/**** end of GRdpmode enum's   ****/
		/**********************************/

    }

	/*** if it's unknown, send it to parent ***/
  if ( * ret_type == _COB_UNKNOWN_ARG )
    {
      _bugprint(bflag=CEO_LOCATE_debug, str=
	  "Passing arg string back to CEO\n" )
      status = om$send ( targetid = my_id,
			 mode = OM_e_wrt_message,
			 msg = message CEO.arg_name_to_value (
					addr_mode, class_name, arg,
					data, ret_type, is_const ) );
#ifdef DEBUG
      _cob_check ( status, \
	  "CEO_LOCATE.arg_name_to_value:  CEO.arg_name_to_value() failed." );
#endif
    }


  _bugprint(bflag=TFLAG,str=
    "-CEO_LOCATE.arg_name_to_value:  data->[l]=%ld, *ret_type=%d, *is_const=%d\n",
    var = `data->l, *ret_type, *is_const` )

  return OM_S_SUCCESS;

} /*** end of CEO_LOCATE.arg_name_to_value method ***/


end implementation CEO_LOCATE;
