/* ceo/read_t_file.I */
class implementation CEO;

#include <stdio.h>
#include <OMmacros.h>	/*** need this for om$vla_set_dimension() ***/
#include <COBint.h>	/*** need this for AVG- & FREE- #defines  ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#endif

#ifdef DMALLOC
#  define DEBUG_CHECK	 debug_check();
#else
#  define DEBUG_CHECK
#endif

#define  INVALID_CHAN		-1
#define  STATE_ACT_TRANS_CHAN	0
#define  TRANS_ACT_CHAN		1

#define  INIT_ACT_CHAN		2
#define  WAKEUP_ACT_CHAN	3
#define  SLEEP_ACT_CHAN		4
#define  DELETE_ACT_CHAN	5



method read_t_file (
  char		which_chan;	/* # indicates chan to put action on */
  char	      * file_name;
  char	      * owner_ptr;	/* back ptr to COBstate struct or    */
				/*   COB_act_trans struct to connect */
				/*   action or trans to		     */
  char	      * char_fp;	/* really a FILE *, but we don't want */
				/*   CEO.S to have to include stdio.h */
  int	      * sts )
{
  int		ii, jj;
  int		status;
  int		attr_num = -1; 
  char		buff [ _max_data_union_str ]; 
  char		attr_name [ _max_data_union_str ]; 
  char		tok;
  char		do_more = _true;
  char		which_parent = 0;
  char	  	check [ 5 ];
  char	  	found_start;
  _attr_type	val [ 100 ]; /*worst case allocation*/
  char	      * temp_state_act_trans = NULL;
				/* back ptr to COBstate struct or    */
				/*   COB_act_trans struct to connect */
				/*   action or trans to		     */
  struct COBstate	* temp_state_ptr = 0;
  struct COBact_trans	* temp_act_trans_ptr;
  struct COBstate	* temp_state_owner_ptr;
  struct COBact_trans	* temp_act_trans_owner_ptr;
  FILE			* fp = ( FILE * ) char_fp;
  extern char		* COB_shove_str ( );
  extern char		* calloc( );

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct super_cmd_instance	* p_super_cmd = ME.super_cmd;
  struct CEO_instance		* p_CEO = ME.CEO;


  _bugprint(bflag = read_debug, str = 
      "+CEO.read_t_file:  which_chan=%d, owner_ptr=(0x)%x, file='%s'\n",
      var = `which_chan, owner_ptr, file_name` )
  DEBUG_CHECK;

  * sts = OM_S_SUCCESS;

  if ( file_name ) 
   {
     fp = ( FILE * ) fopen ( file_name, "r" );
     found_start = _false;
   }
  else found_start = _true;
  if ( !fp  )
   {
     fprintf ( stderr, "CEO.read_t_file: Failed to open command definition file '%s'.\n", file_name);
     *sts = 4;
     goto quit;
   }
/*-----------------------------------*/
  do
    {
      status = COB_read_t_next ( fp, &tok, buff, &attr_num, attr_name );
      _cob_check ( status, "CEO.read_t_file:  COB_read_t_next() failed")
      if ( !found_start )
	{
	  strncpy ( check, buff, 4 );
	     /*** strncpy sometimes doesn't NULL-terminate ***/
	  check [ 4 ] = 0;

	  if ( !strcmp ( check, "CDO(" ) )
	    {
		 found_start = _true;
	    }
	  else if ( tok == EOF && found_start == _false )
	    {
		break;
	    }
	  else
	    {
		continue;
	    }
	}
     _verbose(fprintf(stderr,"CEO_read_tfile:  tok=%d, buff='%s'\n",tok,buff);)
     switch ( tok )
	{
	  case _tok_class :
	    if ( !strcmp ( buff, "CDO(" ) )
	      {
		which_parent = INVALID_CHAN;
		status = read_t_attrs ( fp, _ceo, val, & jj );
		_cob_check ( status, \
			 "CEO.read_t_file:  read_t_attrs(CDO) failed");

		/**** do something with the version # ****/
		/****		      -- JAJ:08-31-87 ****/
		_bugprint(bflag=CEO_debug || read_debug,
			str = "CDO version = %d (%d.%d.%d)\n",
		    var = `val[0].val.i, (val[0].val.i & 0xF000) >> 12, 
		    (val[0].val.i & 0x0F00)>>8, val[0].val.i & 0x00FF`) 

		p_CEO->ceo_version = val[0].val.i;

				/** returns embedded COB version # **/
		jj = give_cob_version( );

		if ( p_CEO->ceo_version != jj )
		  {
		    fprintf(stderr,
			"\nCEO.read_t_file:  Version Mismatch:  COB is version %d.%d.%d,\n\tCommand ascii file was made by COB version %d.%d.%d\n\n",
		        (jj & 0xF000) >> 12,
			(jj & 0x0F00) >> 8,
			jj & 0x00FF,
		      ( p_CEO->ceo_version & 0xF000) >> 12,
		      ( p_CEO->ceo_version & 0x0F00) >>  8,
			p_CEO->ceo_version & 0x00FF );

		    * sts = COB_E_VERS_MISMATCH ;
		    return OM_S_SUCCESS ;
		  }

						/*** JAJ:11-22-88 ***/
		/*** calloc ALL the needed memory for the cmd obj ***/

		/*** get memory for the states ***/
		p_CEO->ceo_free_state_ptr = (struct COBstate *)
					calloc ( val[1].val.i,
					sizeof ( struct COBstate ) );

		_bugprint(bflag = read_debug, str =
		  "CEO:  Calloc'ed %d states; me->ceo_free_state_ptr = 0x%x\n",
		   var = `val[1].val.i, p_CEO->ceo_free_state_ptr` );
		DEBUG_CHECK;

		/*** get memory for the actions ***/
		p_CEO->ceo_free_action_ptr = (struct COBact_trans *)
					calloc ( val[2].val.i,
					sizeof ( struct COBact_trans ));
		_bugprint(bflag = read_debug, str =
		  "CEO:  Calloc'ed %d actions; me->ceo_free_action_ptr = 0x%x\n",
		  var = `val[2].val.i, p_CEO->ceo_free_action_ptr` );
		DEBUG_CHECK;

		/*** get some memory for the actions' arguments ***/
		/***   ( See COBaction struct in "COBstructs.h" ) ***/
		p_CEO->ceo_free_action_args_ptr = calloc (
				val[3].val.i * 
			      (    sizeof(char *)	/* args       */
				 + sizeof(short)	/* args_index */
				 + sizeof(double)	/* values     */
				 + sizeof(short)	/* is_const   */
			      ),
				sizeof ( char ));
		_bugprint(bflag = read_debug, str =
		  "CEO:  Calloc'ed %d action args; me->ceo_free_action_args_ptr = 0x%x\n",
		  var = `val[3].val.i, p_CEO->ceo_free_action_args_ptr` );
		DEBUG_CHECK;

		/*** get memory for the transitions ***/
		p_CEO->ceo_free_trans_ptr = (struct COBact_trans *)
					calloc ( val[4].val.i,
					sizeof ( struct COBact_trans ));
		_bugprint(bflag = read_debug, str =
		  "CEO:  Calloc'ed %d trans; me->ceo_free_trans_ptr = 0x%x\n",
		  var = `val[4].val.i, p_CEO->ceo_free_trans_ptr` );
		DEBUG_CHECK;

		/*** get some memory for the trans' <pred,op,data>'s **/
		/***   ( See COBtrans struct in "COBstructs.h" )   ***/
		p_CEO->ceo_free_trans_pods_ptr = calloc (
				val[5].val.i * 
			      (    sizeof(int)		/* predicate  */
				 + sizeof(int)		/* operator   */
				 + sizeof(data_val)	/* data       */
			      ),
				sizeof ( char ));
		_bugprint(bflag = read_debug, str =
		  "CEO:  Calloc'ed %d trans pods; me->ceo_free_trans_pods_ptr = 0x%x\n",
		  var = `val[5].val.i, p_CEO->ceo_free_trans_pods_ptr` );
		DEBUG_CHECK;

		/*** check to make sure all the ptrs calloc'ed so ***/
		/***   far are not NULL				  ***/
  		if ( ! p_CEO->ceo_free_state_ptr		||
		     ! p_CEO->ceo_free_action_ptr		||
		     ! p_CEO->ceo_free_action_args_ptr	||
		     ! p_CEO->ceo_free_trans_ptr		||
		     ! p_CEO->ceo_free_trans_pods_ptr 		)
		  {
		     fprintf ( stderr,
		       "\nCEO.read_t_file:  calloc[1] ( ) failed\n\n" );
		     *sts = OM_E_NODYNMEM;
		     goto quit;
		  }

		/*** get some memory for various strings used by ***/
		/***   the cmd obj				 ***/

			/*** Calculate the # of data lines needed ***/
		jj = ( ( AVG_MSG_NAME_LENGTH   * val[2].val.i ) +
		       ( AVG_ARG_LENGTH        * val[3].val.i ) +
		       ( AVG_TRANS_DATA_LENGTH * val[5].val.i )  )
				/ FREE_STR_LINE_LENGTH  + 1;

		p_CEO->ceo_free_strs_ptr = (char **)
					calloc ( jj, sizeof(char *) ); 

		_bugprint(bflag = read_debug, str =
		  "CEO:  Calloc'ed %d free_strs; me->ceo_free_strs_ptr = 0x%x\n",
		  var = `jj, p_CEO->ceo_free_strs_ptr` );
		DEBUG_CHECK;

		p_CEO->ceo_free_strs_indices = (int *)
					    calloc ( jj, sizeof(int) );
		_bugprint(bflag = read_debug, str =
		  "CEO:  Calloc'ed %d free_strs_indices; me->ceo_free_indices = 0x%x\n",
		  var = `jj, p_CEO->ceo_free_strs_indices` );
		DEBUG_CHECK;

		if ( p_CEO->ceo_free_strs_ptr && p_CEO->ceo_free_strs_indices)
		  {
		    for ( ii = 0; ii < jj ; ii++ )
		      {
			p_CEO->ceo_free_strs_ptr[ii] = calloc ( 1,
						FREE_STR_LINE_LENGTH ); 
			_bugprint(bflag = read_debug, str =
			  "CEO:  Calloc'ed me->ceo_free_strs_ptr[%d] = 0x%x\n",
			  var = `ii, p_CEO->ceo_free_strs_ptr[ii]` );
			p_CEO->ceo_free_strs_indices[ii] = 0;
		DEBUG_CHECK;

			if ( ! p_CEO->ceo_free_strs_ptr[ii] )
			  {
			    fprintf ( stderr,
		              "\nCEO.read_t_file:  calloc[2] ( ) failed\n\n" );
			    *sts = OM_E_NODYNMEM;
			    goto quit;
			  }
		      }
		    p_CEO->ceo_free_strs_size = jj;
		  }
		else
		  {
		     fprintf ( stderr,
		       "\nCEO.read_t_file:  calloc[3] ( ) failed\n\n" );
		     *sts = OM_E_NODYNMEM;
		     goto quit;
		  }
	      }
	    else if ( !strcmp ( buff, "init(" ) )
	      {
		_bugprint(bflag = read_debug, str = "  init(\n" )
		which_parent = INIT_ACT_CHAN;
		status = read_t_attrs ( fp, _ceo_init, val, & jj );
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(init) failed");
	      }
	    else if ( !strcmp ( buff, "wakeup(" ) )
	      {
		_bugprint(bflag = read_debug, str = "  wakeup(\n" )
		which_parent = WAKEUP_ACT_CHAN;
		status = read_t_attrs ( fp, _ceo_wakeup, val, & jj );
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(wakeup) failed");
	      }
	    else if ( !strcmp ( buff, "sleep(" ) )
	      {
		_bugprint(bflag = read_debug, str = "  sleep(\n" )
		which_parent = SLEEP_ACT_CHAN;
		status = read_t_attrs ( fp, _ceo_sleep, val, & jj );
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(sleep) failed");
	      }
	    else if ( !strcmp ( buff, "delete(" ) )
	      {
		_bugprint(bflag = read_debug, str = "  delete(\n" )
		which_parent = DELETE_ACT_CHAN;
		status = read_t_attrs ( fp, _ceo_delete, val, & jj );
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(delete) failed");
	      }
	    else if ( !strcmp ( buff, "status_display(" ) )
	      {
		_bugprint(bflag = read_debug, str = "  status_display(\n" )
		status = read_t_attrs ( fp, _ceo_status_form, val, &jj );
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(status_display) failed");

		strncpy ( p_super_cmd->active_form_name, val[0].val.str,
			sizeof ( p_super_cmd->active_form_name )  );

		  /*** strncpy sometimes doesn't NULL-terminate ***/
		p_super_cmd->active_form_name [
		    sizeof ( p_super_cmd->active_form_name ) - 1 ] = '\0';

		p_CEO->origin_x = val[1].val.i;
		p_CEO->origin_y = val[2].val.i;
		p_CEO->status_display_form_ptr = 0;

		_bugprint(bflag = CEO_debug || read_debug, str =
		   "Setting me->active_form_name(status_disp) = '%s'\n",
			var = p_super_cmd->active_form_name )
		_bugprint(bflag = CEO_debug || read_debug, str =
		   "Setting me->origin_x,y (status_disp) = (%d,%d)\n",
			var = `p_CEO->origin_x, p_CEO->origin_y` )
	      }
	    else if ( !strcmp ( buff, "form(" ) )
	      {
		_bugprint(bflag = read_debug, str = "  form(\n" )
		status = read_t_attrs ( fp, _ceo_form, val, & jj );
		_bugprint(bflag = read_debug, str =
		   "After read_t_attrs(val):  jj = %d, status = %d\n",
			var = `jj, status` )
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(form) failed");

		p_CEO->number_of_forms ++ ;

		status = om$vla_set_dimension
		  ( varray = ME.CEO->forms, size = p_CEO->number_of_forms);
		_bugprint(bflag = CEO_debug || read_debug, str =
		   "After om$vla_set_dim(me->forms,dim=%d): status = %d\n",
			var = `p_CEO->number_of_forms, status` )
		_cob_check ( status, "CEO.read_t_file:  om$vla_set_dim(me->forms) failed");

		/*** get some memory for the form name ***/
		jj = p_CEO->number_of_forms - 1;
		me->forms[jj].name = COB_shove_str ( val[0].val.str,
					& p_CEO->ceo_free_strs_ptr,
					& p_CEO->ceo_free_strs_indices,
					& p_CEO->ceo_free_strs_index,
					& p_CEO->ceo_free_strs_size  );
		if ( ! me->forms[jj].name )
		  {
		     fprintf ( stderr,
		       "\nCEO.read_t_file:  calloc[4] ( ) failed\n\n" );
		     *sts = OM_E_NODYNMEM;
		     goto quit;
		  }

#ifdef DMALLOC
		printf("  FORM debug_check:\n" );
		DEBUG_CHECK;
#endif

		me->forms[jj].label = val[1].val.i;
		me->forms[jj].display_type = val[2].val.i;

		/*** if no (x,y) positions were given, 		***/
		/***	default to (-1,-1)	-- JAJ:09-27-88 ***/
		if ( ! val[3].val.i )
		  {
		    me->forms[jj].x = -1;
		  }
		else
		  {
		    me->forms[jj].x = val[3].val.i;
		  }

		if ( ! val[4].val.i )
		  {
		    me->forms[jj].y = -1;
		  }
		else
		  {
		    me->forms[jj].y = val[4].val.i;
		  }

		me->forms[jj].form_ptr = 0;
		me->forms[jj].displayed = 0;
		me->forms[jj].prev_pf_cmd_oid = NULL_OBJID;

		_bugprint(bflag = CEO_debug || read_debug, str =
		    "  me->forms[%d].name = val[0].val.str = '%s'\n",
		    var = `jj, me->forms[jj].name` )
		_bugprint(bflag = CEO_debug || read_debug, str =
		    "  me->forms[%d].label = val[1].val.i = %d\n",
		    var = `jj, me->forms[jj].label` )
		_bugprint(bflag = CEO_debug || read_debug, str =
		 "  me->forms[%d].display_type = val[2].val.i = %d\n",
		    var = `jj, me->forms[jj].display_type` )
		_bugprint(bflag = CEO_debug || read_debug, str =
		    "  me->forms[%d].(x,y) = (%d,%d)\n",
		    var = `jj, me->forms[jj].x, me->forms[jj].y` )
	      }
	    else if ( !strcmp ( buff, "s(" ))	/** "state(" **/
	      {
		_bugprint(bflag = read_debug, str = "  state(\n" )
		which_parent = STATE_ACT_TRANS_CHAN;
		status = read_t_attrs ( fp, _state, val, & jj );
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(state) failed");

		_bugprint(bflag = read_debug, str =
		  "CEO:  Assigning  state[ me->ceo_free_state_index = %d ]\n",
		  var = `p_CEO->ceo_free_state_index` );

			/*** construct a state structure ***/
		temp_state_act_trans = (char *)
		      &	p_CEO->ceo_free_state_ptr [ p_CEO->ceo_free_state_index++ ] ;

			/*** fill in the state structure ***/
		temp_state_ptr = (struct COBstate *) temp_state_act_trans ;
		temp_state_ptr->state_id  = val[0].val.i;
		temp_state_ptr->act_trans = NULL;
		temp_state_ptr->list.next = temp_state_ptr;
		temp_state_ptr->list.prev = temp_state_ptr;

		    /*** connect the state structure to the   ***/
		    /***   cmd object's linked list of states ***/
		_COB_append_to_list ( temp_state_ptr, list, \
						 p_CEO->states_ptr );
		_bugprint(bflag = read_debug, str =
		 "Appended state_ptr (0x)%x to me->states_ptr (0x)%x\n",
		 var = `temp_state_ptr, p_CEO->states_ptr` )
	      }
	    else if ( !strcmp ( buff, "a(" ))	/** "action(" **/
	      {
		_bugprint(bflag = read_debug, str = "  action(\n" )
		which_parent = INVALID_CHAN;
		status = read_t_attrs ( fp, _actions, val, & jj );
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(action) failed");

		    /*** if the class name wasn't explicitly  ***/
		    /***   specified, use the name of the cmd ***/
		    /***   object's class in all method calls ***/
		if ( val[0].val.str[0] == '\0' )
		  {
		    status = om$get_classname ( objid = my_id,
					classname = val[0].val.str );
		    _cob_check ( status, "CEO.read_t_file:  get_classname failed");
		  }

		    /*** if the method name wasn't explicitly   ***/
		    /***   specified, then it's method "action" ***/
		if ( val[1].val.str[0] == '\0' )
		  {
		    strcpy ( val[1].val.str, "action" );
		  }

		_bugprint(bflag = read_debug, str =
		  "CEO:  Assigning  action[ me->ceo_free_action_index = %d ]\n",
		  var = `p_CEO->ceo_free_action_index` );

			/*** construct an action structure ***/
		temp_state_act_trans = (char *)
		      &	p_CEO->ceo_free_action_ptr [ p_CEO->ceo_free_action_index++ ] ;

			/*** fill in the action structure ***/
		temp_act_trans_ptr = (struct COBact_trans *) temp_state_act_trans ;
		temp_act_trans_ptr->is_trans = 0;
		temp_act_trans_ptr->list.next = temp_act_trans_ptr;
		temp_act_trans_ptr->list.prev = temp_act_trans_ptr;

		_bugprint(bflag = read_debug, str =
		   "Calling COBactions_set ( act_ptr=(0x)%x, #=%d )\n",
		   var = `& temp_act_trans_ptr->at.action, jj`  )
		COBactions_set ( & temp_act_trans_ptr->at.action,
				   val, jj,
				   p_CEO->ceo_free_action_args_ptr,
				 & p_CEO->ceo_free_action_args_index,
				 & p_CEO->ceo_free_strs_ptr,
				 & p_CEO->ceo_free_strs_indices,
				 & p_CEO->ceo_free_strs_index,
				 & p_CEO->ceo_free_strs_size,
				   sts );
		DEBUG_CHECK;
		_cob_check ( *sts, \
		     "CEO.read_t_file:  Error in construction action" );


		    /*** connect the action to the appropriate list ***/
		switch  ( which_chan )
		  {
		   case TRANS_ACT_CHAN:
		    temp_act_trans_owner_ptr =
				( struct COBact_trans * ) owner_ptr;
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
			temp_act_trans_owner_ptr->at.trans.act_trans );
		    _bugprint(bflag = read_debug, str =
		      "Appended action_ptr to TRANS owner_ptr->act_trans (0x)%x\n",
		      var=temp_act_trans_owner_ptr->at.trans.act_trans )
		    break;

		   case STATE_ACT_TRANS_CHAN:
		    temp_state_owner_ptr =
				( struct COBstate * ) owner_ptr;
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
				temp_state_owner_ptr->act_trans );
		    _bugprint(bflag = read_debug, str =
		      "Appended action_ptr to STATE owner_ptr->act_trans (0x)%x\n",
			var = temp_state_owner_ptr->act_trans )
		    break;

		   case INIT_ACT_CHAN:
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
							 p_CEO->at_init );
		    _bugprint(bflag = read_debug, str =
			"Appended action_ptr to ME->at_init (0x)%x\n",
			var = p_CEO->at_init )
		    break;

		   case WAKEUP_ACT_CHAN:
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
							p_CEO->at_wakeup );
		    _bugprint(bflag = read_debug, str =
			"Appended action_ptr to ME->at_wakeup (0x)%x\n",
			var = p_CEO->at_wakeup )
		    break;

		   case SLEEP_ACT_CHAN:
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
							p_CEO->at_sleep );
		    _bugprint(bflag = read_debug, str =
			"Appended action_ptr to ME->at_sleep (0x)%x\n",
			var = p_CEO->at_sleep )
		    break;

		   case DELETE_ACT_CHAN:
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
							p_CEO->at_delete );
		    _bugprint(bflag = read_debug, str =
			"Appended action_ptr to ME->at_delete (0x)%x\n",
			var = p_CEO->at_delete )
		    break;

		   default:
#ifdef DEBUG
		    fprintf(stderr,
			"Error in CEO.read_t_file:  Bad channel flag %d\n",
			which_chan );
#endif
		    break;
		  }
	      }
	    else if ( !strcmp ( buff, "t(" ))	/** "trans(" **/
	      {
		_bugprint(bflag = read_debug, str = "  trans(\n" )
		which_parent = TRANS_ACT_CHAN;
		status = read_t_attrs ( fp, _trans, val, & jj );
		_cob_check ( status, "CEO.read_t_file:  read_t_attrs(trans) failed");

		_bugprint(bflag = read_debug, str =
		  "CEO:  Assigning  trans[ me->ceo_free_trans_index = %d ]\n",
		  var = `p_CEO->ceo_free_trans_index` );

			/*** construct an trans structure ***/
		temp_state_act_trans = (char *)
		      &	p_CEO->ceo_free_trans_ptr [ p_CEO->ceo_free_trans_index++ ] ;
			/*** fill in the trans structure ***/
		temp_act_trans_ptr = (struct COBact_trans *) temp_state_act_trans ;
		temp_act_trans_ptr->is_trans = 1;
		temp_act_trans_ptr->at.trans.act_trans = NULL;
		temp_act_trans_ptr->list.next = temp_act_trans_ptr;
		temp_act_trans_ptr->list.prev = temp_act_trans_ptr;

		/*** connect the trans node to the right linked list***/
		switch ( which_chan )
		  {
		  case TRANS_ACT_CHAN:
		    temp_act_trans_owner_ptr =
				( struct COBact_trans * ) owner_ptr;
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
			temp_act_trans_owner_ptr->at.trans.act_trans );
		    _bugprint(bflag = read_debug, str =
		      "Appended trans_ptr to TRANS owner_ptr->act_trans (0x)%x\n",
		      var=temp_act_trans_owner_ptr->at.trans.act_trans )
		    temp_state_ptr = NULL ;
		    break;

		  case STATE_ACT_TRANS_CHAN:
		    temp_state_owner_ptr =
				( struct COBstate * ) owner_ptr;
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
				temp_state_owner_ptr->act_trans );
		    _bugprint(bflag = read_debug, str =
		      "Appended trans_ptr to STATE owner_ptr->act_trans (0x)%x\n",
			var = temp_state_owner_ptr->act_trans )
		    /*** do this so COBstate_set will be called to ***/
		    /***   BIT-OR in this tran's mask into state's ***/
		    /***   filter				   ***/
		    temp_state_ptr = ( struct COBstate * ) owner_ptr ;
		    break;

	  /****** Can't have transitions for at's ***** JAJ:08-22-88 ***
		   case INIT_ACT_CHAN:
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
							p_CEO->at_init );
		    break;
		   case WAKEUP_ACT_CHAN:
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
							p_CEO->at_wakeup );
		    break;
		   case SLEEP_ACT_CHAN:
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
							p_CEO->at_sleep );
		    break;
		   case DELETE_ACT_CHAN:
		    _COB_append_to_list ( temp_act_trans_ptr, list, \
							p_CEO->at_delete );
		    break;
	  *********** can't have transitions for at's ***************/

		   default:
#ifdef DEBUG
		    fprintf(stderr,
		     "Error in CEO.read_t_file:  Bad trans channel flag %d\n",
			which_chan );
#endif
		    break;
		  }

		/*** fill in more trans data--must be done after ***/
		/***   above switch is done			 ***/
		_bugprint(bflag = read_debug, str =
		   "Calling COBtrans_set ( trans_ptr=(0x)%x, #=%d )\n",
		   var = `& temp_act_trans_ptr->at.trans, jj`  )
		COBtrans_set ( & temp_act_trans_ptr->at.trans,
				temp_state_ptr, my_id, val, jj,
				   p_CEO->ceo_free_trans_pods_ptr,
				 & p_CEO->ceo_free_trans_pods_index,
				 & p_CEO->ceo_free_strs_ptr,
				 & p_CEO->ceo_free_strs_indices,
				 & p_CEO->ceo_free_strs_index,
				 & p_CEO->ceo_free_strs_size,
				   sts );
		DEBUG_CHECK;
		_cob_check ( *sts, "CEO.read_t_file:  COBtrans_set failed");
	      }
	    break;

	  case _tok_attr :
	    fprintf ( stderr,
		"CEO_read_tfile:  file format error: read _tok_attr '%s'\n",
		buff );
	    status = 2;
	    goto quit;
	    /*break;*/

	  case _tok_start :
	    _send ( my_id, CEO.read_t_file (
				which_parent, 0, temp_state_act_trans,
				(char *) fp, sts ) );
	    _cob_check2 ( status, *sts, \
			"CEO_read_tfile:  CEO.read_tfile failed" )
	    break;

	  case _tok_stop :
	  case EOF :
	    do_more = _false;
	    break;

	  default :
	    fprintf ( stderr,
		"\nCEO_read_t_file:  default file format error, read _tok=%d buff='%s'\n\n",
		tok, buff );
	    status = 2;
	    goto quit;
	    /*break;*/
	}
    }
  while ( do_more );

  * sts = OM_S_SUCCESS;

quit :	/* and also normal exit */
  if ( file_name && fp ) fclose ( fp );

  _bugprint(bflag = read_debug, str = 
      "-CEO.read_t_file:  which_chan=%d, file_name='%s'\n",
      var = `which_chan, file_name` )
  DEBUG_CHECK;

  return OM_S_SUCCESS;
} /* read_t_file */


end implementation CEO;
