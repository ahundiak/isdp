

int setup_t_attrs ( class_name, val, n_val )
  int		  class_name;	/* which class to setup for */
/*  output */
  _attr_type	  val [];	/* output array of attrs for class */
  int		* n_val;	/* how many attrs there are */
{
    /****    * n_val = 0;  JAJ:11-09-87 ****/

    switch ( class_name )
      {
	case _ceo:
	/*** request the version #, and amounts of memory to calloc ***/
	  _attr_setup ( val [ 0 ], _ceo, _ceo_version,		_int );
	  _attr_setup ( val [ 1 ], _ceo, _ceo_num_states,	_int );
	  _attr_setup ( val [ 2 ], _ceo, _ceo_num_actions,	_int );
	  _attr_setup ( val [ 3 ], _ceo, _ceo_num_action_args,	_int );
	  _attr_setup ( val [ 4 ], _ceo, _ceo_num_trans,	_int );
	  _attr_setup ( val [ 5 ], _ceo, _ceo_num_trans_pods,	_int );
	  * n_val = 6;
	  break;

	case _ceo_form:
	  _attr_setup ( val [ 0 ], _ceo_form, _ceo_form_name, _ascii );
	  _attr_setup ( val [ 1 ], _ceo_form, _ceo_form_label, _int );
	  _attr_setup ( val [ 2 ], _ceo_form, _ceo_form_display, _int );
	  _attr_setup ( val [ 3 ], _ceo_form, _ceo_form_x, _int );
	  _attr_setup ( val [ 4 ], _ceo_form, _ceo_form_y, _int );
	  * n_val = 5;
	  break;

	case _ceo_status_form:
	  _attr_setup ( val [ 0 ], _ceo_status_form, _ceo_status_form, _ascii );
	  _attr_setup ( val [ 1 ], _ceo_status_form, _ceo_form_x, _int );
	  _attr_setup ( val [ 2 ], _ceo_status_form, _ceo_form_y, _int );
	  * n_val = 3;
	  break;

	case _ceo_init:
	case _ceo_wakeup:
	case _ceo_sleep:
	case _ceo_delete:
	  _attr_setup ( val [ 0 ], _ceo_init, _ceo_string, _ascii );
	  * n_val = 1;
	  break;

	case _actions_class_name:	/*** JAJ:01-19-88 ***/
	  _attr_setup ( val [ 0 ], _actions, _actions_class, _ascii );
	  _attr_setup ( val [ 1 ], _actions, _actions_name, _ascii );
	  * n_val = 2;
	  break;

	case _actions:			/*** JAJ:01-19-88 ***/
	  _attr_setup ( val [ *n_val ], _actions, _actions_data, _ascii );
	  (*n_val)++;
	  break;

	case _state:
	  _attr_setup ( val [ 0 ], _state, _state_num, _int );
	  * n_val = 1;
	  break;

	case _trans_next:    /*** get the next state --JAJ:11-09-87 ***/
	  _attr_setup ( val [ 0 ], _trans, _trans_next, _int );
	  * n_val = 1 ;
	  break;

	case _trans: /** get the pred, op, data triple--JAJ:11-09-87 **/
	  _attr_setup ( val [ *n_val ], _trans, _trans_pred, _int );
	  (*n_val)++;
	  _attr_setup ( val [ *n_val ], _trans, _trans_op, _int );
	  (*n_val)++;
	  _attr_setup ( val [ *n_val ], _trans, _trans_data, _ascii );
	  (*n_val)++;
	  break;

	default :
          _debug(fprintf(stderr,"unknown class %d\n",class_name);)
	  return 2;

      } /* switch on class */

    return 1;

} /* setup_class_attrs */
