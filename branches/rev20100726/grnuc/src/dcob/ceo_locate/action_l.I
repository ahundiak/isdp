/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/action_l.I */
class implementation CEO_LOCATE;
/*
  perform indicated action
*/

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <griomacros.h> /*** need this for vsd_and_queue_empty	 ***/
#include <ctype.h>	/*** need this for isspace()		 ***/
#include <OMmacros.h>	/*** need this for om$vla_set_dimension()***/
#include <lcmacros.h>	/*** need this for lc$wild_disconnect()  ***/
#include <griodef.h>	/*** need this for GRm_ mask settings	 ***/
#include <ode_export.h> /*** kludge required - prompt truncation ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


method action (
  int	  selector;
  int	  int_or_str_ptr;
  int	* sts )
{
  int			status,ii;
  char		      *	ch;
  char			class_name[ OM_K_MAXCLASS_LEN + 2];
			 /** need '+ 2' for a '--' for locate class **/
  OMuword		class_id;
  OM_S_CLASSLIST  *	locate_class_thing = NULL;
  char 			temp_str[_max_data_union_str];

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_instance		* p_CEO = ME.CEO;
  struct CEO_LOCATE_instance	* p_CEO_LOCATE = ME.CEO_LOCATE;

  _bugprint(bflag=TFLAG, str =
	"+CEO_LOCATE.action:  sel=%d, int_or_str_ptr=[%d], *sts=%d\n",
	var = `selector, int_or_str_ptr, *sts` )
/*
  _bugprint(bflag=TFLAG, str =
	"+CEO_LOCATE.action:  sel=%d, int_or_str_ptr=[%d | '%s'], *sts=%d\n",
	var = `selector, int_or_str_ptr, int_or_str_ptr >=0 ? (char *)int_or_str_ptr : "" , *sts` )
*/

  * sts = OM_S_SUCCESS;
  switch ( selector )
    {
      case _hilite_const:  /*** moved from CEO-- JAJ:10-19-87 ***/
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "selector = _hilite_const = %d\n", var = selector )
	if ( int_or_str_ptr == 1 )
	  {	/**** = GRbdhd; --JAJ:06-02-88 ****/
	      p_CEO_LOCATE->DisplayMode = GRhd;
	  }
	else
	  {	/**** = GRbdhe; --JAJ:06-02-88 ****/
	      p_CEO_LOCATE->DisplayMode = GRhe;
	  }
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "me->DisplayMode = %d\n", var = p_CEO_LOCATE->DisplayMode )
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "Sending CEO_LOCATE.display_constructed()\n")
	status = om$send ( targetid = my_id,
	    msg = message CEO_LOCATE.display_constructed ( (long *)sts ));
	_cob_check ( status, \
	  "CEO_LOCATE.action:  CEO_LOCATE.display_constructed() failed." );
	break;

      case _discon_const:  /*** moved from CEO-- JAJ:10-19-87 ***/
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "selector = _discon_const = %d\n", var = selector )
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "Sending CEO_LOCATE.disconnect_constructed()\n")
	status = om$send ( targetid = my_id,
	    msg = message CEO_LOCATE.disconnect_constructed ( (long *)sts ));
	_cob_check ( status, \
	  "CEO_LOCATE.action:  CEO_LOCATE.disconnect_constructed() failed." );
	break;

      case _dynamics:
	/** this is repeated in CEO.action, except for the vsd check **/
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = '_dynamics' = %d\n", var = selector)

	if ( vsd_and_queue_empty )
	  {
	    _bugprint(bflag=CEO_LOCATE_debug, str =
		"Sending myself CEO.dynamics( dynamics = int_or_str_ptr = %d )\n",
		var = int_or_str_ptr )
	    /* UI_prompt ( me->prompt ); 	JAJ:11-17-87 */
	    ex$message( field = PROMPT_FIELD, msgnumb = MS_NO_MSG,
		    justification = RIGHT_JUS, in_buff = p_CEO->prompt);
	    _send ( my_id, CEO.dynamics ( int_or_str_ptr, sts ));
#ifdef DEBUG
	    _cob_check2 ( status, *sts, \
		"CEO_LOCATE.action:  CEO.dynamics() failed." );
#endif
	  }
	break;

      case _event_mask1:
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = '_event_mask' = %d\n", var = selector)
	p_CEO_LOCATE->event_mask1 = int_or_str_ptr; 
	if ( p_CEO_LOCATE->event_mask1 & GRm_ANGLE )
	  {
	    p_CEO_LOCATE->event_mask1 ^= GRm_ANGLE;
	    p_CEO_LOCATE->event_mask1 |= GRm_VALUE;
	    p_CEO_LOCATE->value_type = GRIO_ANGLE;
	  }
	if ( p_CEO_LOCATE->event_mask1 & GRm_DIST )
	  {
	    p_CEO_LOCATE->event_mask1 ^= GRm_DIST;
	    p_CEO_LOCATE->event_mask1 |= GRm_VALUE;
	    p_CEO_LOCATE->value_type = GRIO_DISTANCE;
	  }
	if ( p_CEO_LOCATE->event_mask1 & GRm_SCALAR )
	  {
	    p_CEO_LOCATE->event_mask1 ^= GRm_SCALAR;
	    p_CEO_LOCATE->event_mask1 |= GRm_VALUE;
	    p_CEO_LOCATE->value_type = GRIO_SCALAR;
	  }
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"me->event_mask1 = %d; me->value_type = %d\n",
		var = `p_CEO_LOCATE->event_mask1, p_CEO_LOCATE->value_type` )
	break;

      case _value_type:
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = '_value_type' = %d\n", var = selector)
	p_CEO_LOCATE->value_type = (char *) int_or_str_ptr;
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"me->event_mask1 = %d; me->value_type = %d\n",
		var = `p_CEO_LOCATE->event_mask1, p_CEO_LOCATE->value_type` )
	break;

      case _value_type_locate:
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = '_value_type_locate' = %d\n", var=selector)
	p_CEO_LOCATE->value_type_locate = (char *) int_or_str_ptr;
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"me->event_mask1 = %d; me->value_type_locate = %d\n",
		var = `p_CEO_LOCATE->event_mask1, p_CEO_LOCATE->value_type_locate` )
	break;

      case _value_type_accept:
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = '_value_type_accept' = %d\n", var=selector)
	p_CEO_LOCATE->value_type_accept = (char *) int_or_str_ptr;
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"me->event_mask1 = %d; me->value_type_accept = %d\n",
		var = `p_CEO_LOCATE->event_mask1, p_CEO_LOCATE->value_type_accept` )
	break;

      case _relocate:
	if ( ((char *) int_or_str_ptr)[0] )
	{
	    strcpy ( p_CEO_LOCATE->reloc_prompt, (char *) int_or_str_ptr );
	    /* KLUDGE - null terminate big strings */
	    p_CEO_LOCATE->reloc_prompt[_max_key-1] = '\0';
        }
	break;
      case _relocate_key:
	ex$message ( msgnumb = int_or_str_ptr,
	buff = p_CEO_LOCATE->reloc_prompt );
	/* KLUDGE - null terminate big strings */
	p_CEO_LOCATE->reloc_prompt[_max_key-1] = '\0';
	break;
      case _accept:
	if ( ((char *) int_or_str_ptr)[0] )
        {
	    strcpy ( p_CEO_LOCATE->acc_prompt, (char *) int_or_str_ptr );
	    /* KLUDGE - null terminate big strings */
	    p_CEO_LOCATE->acc_prompt[_max_key-1] = '\0';
        }
	break;
      case _accept_key:
	ex$message ( msgnumb = int_or_str_ptr,
	             buff = p_CEO_LOCATE->acc_prompt );
	/* KLUDGE - null terminate big strings */
	p_CEO_LOCATE->acc_prompt[_max_key-1] = '\0';
	break;
	
      /**** lc$locate arg:  locate THIS CLASS NAME (& subclasses ) ****/
      case _locate_class:			  /*** JAJ:12-17-87 ***/
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "selector = _locate_class;  locate_class = '%s'\n",
	    var = `(char *) int_or_str_ptr` )
	strcpy ( temp_str, "+" );
	strcat ( temp_str, (char *) int_or_str_ptr );

	_bugprint(bflag=CEO_LOCATE_debug, str =
	 "Sending my_id CEO_LOCATE.action ( _locate_eligible, '%s' )\n",
		var = temp_str )
	_send ( my_id, CEO_LOCATE.action( _locate_eligible,
					 (int) temp_str, sts));
#ifdef DEBUG
	_cob_check2 ( status, *sts, \
	  "CEO_LOCATE.action:  CEO_LOCATE.action ( _locate_eligible ) failed." );
#endif

	break;

      /**** lc$locate arg:  restrict locate to this class name in the rtree ****/
      case _locate_rtree:
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "selector = _locate_rtree;  locate_class = '%s'\n",
	    var = `(char *) int_or_str_ptr` )
	locate_class_thing = & p_CEO_LOCATE->locate_rtree_thing;
	/** no break **/

      /**** lc$locate arg:  restrict locate to this class name ****/
      case _locate_eligible:
	if ( ! locate_class_thing )
	  {
	    locate_class_thing = & p_CEO_LOCATE->locate_eligible_thing;

	    _bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = _locate_eligible;  locate_class = '%s'\n",
		var = `(char *) int_or_str_ptr` )
	  }
	
	locate_class_thing->w_flags = 0;
	for ( ch = (char *) int_or_str_ptr, ii = 0  ; !ii ; )
	  {
	    for ( ; isspace(* ch) ; ch++ );	/* eat blanks */
	    switch ( * ch )
	      {
		case '+':
		case '&':	/*** locate subclasses also ***/
		  locate_class_thing->w_flags |= OM_CLST_subclass;
		  ch++;
		  break;
		case '!':
		case '~':
		case '-':	/** locate all classes EXCEPT these **/
		  locate_class_thing->w_flags |= OM_CLST_negation;
		  ch++;
		  break;
		default:  /**  *ch = first letter of class list **/
		  ii = 1;
		  break;
	      }
	  }
	locate_class_thing->w_count = 0;
	
	/*** now, loop thru the class name list and convert the ***/
	/***   class names to classids ***/
	while ( * ch )
	  {
	    /***  eat blanks & commas  ***/
	    for ( ; isspace(*ch) || (*ch == ',') ; ch++ );

	    /*** read in one name, up to a ',' or EOL or a ' '  ***/
	    for ( ii = 0; * ch && ( * ch != ',' ) && (! isspace(*ch)); ch ++ )
	      {
		class_name[ii] = *ch;
		ii++;
	      }
	    class_name[ii] = '\0';

	    /*** get the classid for this name ***/
	    status = om$get_classid ( classname = class_name,
				p_classid = &class_id );

	    if ( ! ( 1 & status ) )	/*** this is a bad class name ***/
	      {
#ifdef DEBUG /*** don't do this for the gen. public -- JAJ:03-21-88 ***/
		fprintf(stderr,
		    "\nCEO_LOCATE.action_l:  Error in getting classid for classname '%s'\n",
		    class_name );
		om$report_error( sts = status );

#endif
		/*** keep on truckin' though ***/
	      }
	    else	/*** this is a valid class name ***/
	      {
		locate_class_thing->w_count ++;

		if ( selector == _locate_rtree )
		  {
		    status = om$vla_set_dimension ( 
				varray = ME.CEO_LOCATE->rtree_classids,
				size = locate_class_thing->w_count );
		    _cob_check ( status, \
			  "CEO_LOCATE.action:  om$vla_set_dimension ( me->rtree_classids ) failed." );

		    /*** actually put the classid in the vla  ***/
		    me->rtree_classids[locate_class_thing->w_count - 1]
					= class_id ;
		  }
		else
		  {
		    status = om$vla_set_dimension ( 
				varray = ME.CEO_LOCATE->eligible_classids,
				size = locate_class_thing->w_count );
		    _cob_check ( status, \
			  "CEO_LOCATE.action:  om$vla_set_dimension ( me->eligible_classids ) failed." );

		    /*** actually put the classid in the vla  ***/
		    me->eligible_classids[locate_class_thing->w_count - 1]
					= class_id ;
		  }

	      }
	  } /* end while () */

	/***  assign the real vla to the real pointer  ***/
	if ( selector == _locate_rtree )
	  {
	    locate_class_thing->p_classes = me->rtree_classids;
	    p_CEO_LOCATE->locate_rtree = locate_class_thing;
	  }
	else
	  {
	    locate_class_thing->p_classes = me->eligible_classids;
	    p_CEO_LOCATE->locate_eligible = locate_class_thing;
	  }

	break;

      case _locate_props:
	p_CEO_LOCATE->attributes.properties = (unsigned long) int_or_str_ptr;
	break;
      case _locate_owner:
	p_CEO_LOCATE->attributes.owner_action = (unsigned long) int_or_str_ptr;
	break;
      case _locate_display:
	p_CEO_LOCATE->display_flag = int_or_str_ptr;
	break;
      case _locate_type:
	p_CEO_LOCATE->type = int_or_str_ptr;
	break;

      case _highlight_mode:		/*** JAJ:04-20-88 ***/
	p_CEO_LOCATE->HilightMode = (enum GRdpmode) int_or_str_ptr;
	break;

      case _unhighlight_mode:		/*** JAJ:04-20-88 ***/
	p_CEO_LOCATE->UnhilightMode = (enum GRdpmode) int_or_str_ptr;
	break;

      case _display_mode:		/*** JAJ:04-20-88 ***/
	p_CEO_LOCATE->DisplayMode = (enum GRdpmode) int_or_str_ptr;
	break;

      case _hilite_located:	/**** = GRbdhd; --JAJ:06-02-88 ****/
	if ( int_or_str_ptr ) p_CEO_LOCATE->DisplayMode = GRhd;
	else p_CEO_LOCATE->DisplayMode = GRhe; 	/** = GRbdhe; --JAJ:06-02-88 **/
	_send ( my_id, CEO_LOCATE.display_located ( (long *)sts ));
#ifdef DEBUG
	_cob_check2 ( status, *sts, \
	  "CEO_LOCATE.action:  CEO_LOCATE.display_located() failed." );
#endif
	break;

      case _discon_located:
	/*** changed to lc$wild_disconnect()	JAJ:09-09-87***********/
	status = lc$wild_disconnect ( p_chanselect =
						&p_CEO_LOCATE->located_chansel );
#ifdef DEBUG
	_cob_check ( status, \
	  "CEO_LOCATE.action:  lc$wild_disconnect() failed." );
#endif
	break;

      case _event_mask:
	status = om$send ( targetid = my_id,
	    msg = message CEO_LOCATE.action ( _event_mask1, int_or_str_ptr, sts ),
	    mode = OM_e_wrt_message );
#ifdef DEBUG
	_cob_check ( status, \
	  "CEO_LOCATE.action:  CEO_LOCATE.action ( _event_mask1 ) failed." );
#endif
	p_CEO_LOCATE->event_mask2 = p_CEO_LOCATE->event_mask1; 
	_bugprint(bflag=CEO_LOCATE_debug, str = "LOCATE me->event_mask2 = %d\n",
		var = p_CEO_LOCATE->event_mask2 )
	break;

      case _event_mask2:
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = '_event_mask2' = %d\n", var = selector)
	p_CEO_LOCATE->event_mask2 = int_or_str_ptr; 
	if ( p_CEO_LOCATE->event_mask2 & GRm_ANGLE )
	  {
	    p_CEO_LOCATE->event_mask2 ^= GRm_ANGLE;
	    p_CEO_LOCATE->event_mask2 |= GRm_VALUE;
	    p_CEO_LOCATE->value_type = GRIO_ANGLE;
	  }
	if ( p_CEO_LOCATE->event_mask2 & GRm_DIST )
	  {
	    p_CEO_LOCATE->event_mask2 ^= GRm_DIST;
	    p_CEO_LOCATE->event_mask2 |= GRm_VALUE;
	    p_CEO_LOCATE->value_type = GRIO_DISTANCE;
	  }
	if ( p_CEO_LOCATE->event_mask2 & GRm_SCALAR )
	  {
	    p_CEO_LOCATE->event_mask2 ^= GRm_SCALAR;
	    p_CEO_LOCATE->event_mask2 |= GRm_VALUE;
	    p_CEO_LOCATE->value_type = GRIO_SCALAR;
	  }
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"me->event_mask2 = %d; me->value_type = %d\n",
		var = `p_CEO_LOCATE->event_mask2, p_CEO_LOCATE->value_type` )
	break;

      case _loc_regex:		/*** JAJ:08-19-87 ***/
	p_CEO_LOCATE->regex = int_or_str_ptr;
	break;

      case _loc_stack_size:	/*** JAJ:08-19-87 ***/
	p_CEO_LOCATE->stack_size = int_or_str_ptr;
	break;

	/*** this next case occurs also in CEO.action, but without ***/
	/***   the reference to me->event_mask1			   ***/
      case _filter_mode:	/*** JAJ:08-25-87 ***/
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = _filter_mode = %d\n", var = selector )
	p_CEO->filter_mode = int_or_str_ptr;

	if ( p_CEO->filter_mode == EX_ALL_CHAR_MODE )
	  {
	    p_CEO_LOCATE->event_mask1 |= GRm_CHAR;
	  }

	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "me->filter_mode = int_or_str_ptr = %d\n", var = p_CEO->filter_mode )
	break;

      case _convert_resp_to_mask:     /* 	-- JAJ:10-21-87	      */
	_bugprint(bflag=read_debug, str =
	  "selector = _convert_resp_to_mask = %d\n", var = selector )
	/*** this converts the transition's response type into a      */
	/***   filter mask setting;  this was transferred from	      */
	/***   trans.set during the COB IGE/COB DRAFT split	      */

	/**** KLUDGE NOTE:  in this case statement, the 'sts' variable*/
	/****	is to be filled in with the mask value and returned   */
	/****	to trans.set via 'sts'				      */

	* sts = 0;	/*** forget the OM_S_SUCCESS stuff ***/

	switch ( int_or_str_ptr )
	  {
	    case EX_CMD_KEY:	/*** JAJ:09-18-87 ***/
		  * sts = GRm_COMMAND;
		  break;
	    case EX_DATA:
		  * sts = GRm_DATA | GRm_PT_OUT_MOD;
		  break;
	    case EX_BACK_UP:	/*** JAJ:09-18-87 ***/
		  * sts = GRm_BACK_UP;
		  break;
	    case EX_RJT_MOVEON:
		  * sts = GRm_RJT_MOVEON;
		  break;
	    case EX_STRING:
	    case _ceo_null_string:
		  * sts = GRm_STRING;
		  break;
	    case _ceo_text_value:
	    case _ceo_null_text_value:
		  * sts = GRm_TEXT_VALUE;
		  break;
	    case EX_CHAR:
		  * sts = GRm_CHAR;
		  break;
	    case EX_VALUE:
		  * sts = GRm_VALUE;
		  break;
	    case _ceo_angle:
		  * sts = GRm_ANGLE;
		  break;
	    case _ceo_distance:
		  * sts = GRm_DIST;
		  break;
	    case _ceo_scalar:
		  * sts = GRm_SCALAR;
		  break;
	    case EX_OBJID:
		  * sts = GRm_OBJID;
		  break;
	    case EX_RESTART:	/*** JAJ:09-18-87 ***/
		  * sts = GRm_RESTART;
		  break;
	    case EX_FORM_FINISHED:	/*** JAJ:03-22-88 ***/
		  * sts = GRm_FORM_FINISHED;
		  break;
	    default:
		  break;
	  }
	break;

      case _scale_flag:		/*** JAJ:05-22-89 ***/
	_bugprint(bflag=CEO_LOCATE_debug, str =
		"selector = '_scale_flag' = %d\n", var = selector)

	p_CEO_LOCATE->scale_flag = int_or_str_ptr;

	_bugprint(bflag=CEO_LOCATE_debug, str = "me->scale_flag = %d\n",
		var = `p_CEO_LOCATE->scale_flag` )
	break;

      default:
	_bugprint(bflag=CEO_LOCATE_debug, str =
	    "Burping unknown action selector = %d back to CEO.action\n",
	    var = selector)
	status = om$send ( targetid = my_id,
	    msg = message CEO.action ( selector, int_or_str_ptr, sts ),
	    mode = OM_e_wrt_message );
#ifdef DEBUG
	_cob_check ( status, \
	  "CEO_LOCATE.action:  CEO.action() failed." );
#endif
	break;
    }
quit:
  _bugprint(bflag=TFLAG, str = "-CEO_LOCATE.action:  selector = %d, *sts = %d\n",
		var = `selector, *sts` )
  return OM_S_SUCCESS;
}
end implementation CEO_LOCATE;
