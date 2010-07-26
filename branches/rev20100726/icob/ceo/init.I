/* ceo/init.I */
/*
  initialize a new instance of this command class.
  init me data to default values.
*/
class implementation CEO;

#include <stdio.h>
#include <msdef.h>	/** need this for MS_ON			   **/
#include <OMmacros.h>	/** need this for OM_SET_DIMENSION	   **/

#include <COB_pf_nod.h> /** need this for pf_nod stuff --JAJ:08-10-88**/
#include <FI.h>

#ifdef ENV5
%safe
#include <FIproto_pub.h>
%endsafe
#endif

#ifdef X11
%safe
#include <XFIproto_pub.h>
%endsafe
#endif

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


#ifdef NT
#include <shampub.h>
#endif


/*** This is a global variable to replace the loss of OMNamObjDir ***/
/***   MOVED TO exnucglobal.c -- JAJ:11-17-88 			  ***/
extern struct COB_pf_nod	* COB_persistent_forms;

method init (
  int	  type;
  char	* str_ptr )
{
  int			  status, sts, ii;
  FILE			* fp = 0;
  char			  err_report[256];
  char			  tfilename[_max_file_name];
  char			  found_pf;
  struct COB_pf_nod	* temp_pf_entry = NULL;
  char			* TERMINATING_CMD = "CEO.init:  Terminating command.\n\n";
#ifdef DEBUG
  char			  temptfilename[_max_file_name];
  char			* ch;
  extern char		* strrchr ();
#endif
  extern void		  COB_FI_initial_form_notification();
  extern void		  COB_FI_form_notification();
  extern char * 	  find_file();

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct super_cmd_instance	* p_super_cmd = ME.super_cmd;
  struct CEO_instance		* p_CEO = ME.CEO;
  int				  num_states;
  

  _bugprint(bflag=TFLAG, str = 
      "+CEO.init:  type  = %d, str_ptr = '%s', me->cmd_name = '%s'\n", 
      var = `type, str_ptr, p_super_cmd->cmd_name` )


  sts = OM_S_SUCCESS;

  /*** see if we've done CEO.init before; if so, leave ***/
  if ( p_CEO->ceo_version )
    {
      goto quit;
    }

  p_super_cmd->mytype = type;
  p_CEO->prompt [0] = NULL;
  p_CEO->msg [0] = NULL;
  p_CEO->status [0] = NULL;
  p_CEO->filter_mode = EX_LINE_MODE;		/*** JAJ:08-25-87 ***/
  p_CEO->ret = OM_S_SUCCESS;
  p_CEO->number_of_forms = 0;
  p_CEO->const_class[0] = NULL;  /* moved from CEO-- JAJ:10-19-87 */

  /*** status_display form ***/
  p_super_cmd->form_requested = _false;
  p_CEO->status_display_form_ptr = NULL;	/*** JAJ:12-21-88 ***/

  p_CEO->prev_msg_state = MS_ON;		/** JAJ:08-09-88 **/

  p_CEO->at_init	= NULL;			/** JAJ:08-18-88 **/
  p_CEO->at_wakeup	= NULL;
  p_CEO->at_sleep	= NULL;
  p_CEO->at_delete	= NULL;
  p_CEO->states_ptr	= NULL;

    /*** initialize the memory management arrays & their indices ***/
  p_CEO->ceo_free_state_ptr		= NULL;	/*** JAJ:11-22-88 ***/
  p_CEO->ceo_free_action_ptr		= NULL;
  p_CEO->ceo_free_action_args_ptr	= NULL;
  p_CEO->ceo_free_trans_ptr		= NULL;
  p_CEO->ceo_free_trans_pods_ptr	= NULL;
  p_CEO->ceo_free_state_index		= 0;
  p_CEO->ceo_free_action_index		= 0;
  p_CEO->ceo_free_action_args_index	= 0;
  p_CEO->ceo_free_trans_index		= 0;
  p_CEO->ceo_free_trans_pods_index	= 0;
  p_CEO->ceo_free_strs_ptr		= NULL;
  p_CEO->ceo_free_strs_indices		= NULL;
  p_CEO->ceo_free_strs_index		= 0;
  p_CEO->ceo_free_strs_size		= 0;

  _bugprint(bflag=CEO_debug, str =
    "Making chan_selects(me->const_chansel) = CEO.constructed_graphics\n" )
  status = om$make_chanselect (
      channame = "CEO.constructed_graphics",
      p_chanselect = & p_CEO->const_chansel );
#ifdef DEBUG
  _cob_check ( status, "CEO.init:  om$make_chanselect(CEO.constructed_graphics) failed");
#endif

  p_super_cmd->state=0;
  p_CEO->next_state=0;

  strcpy ( p_super_cmd->path, str_ptr );
  _bugprint(bflag=CEO_debug, str =
    "Filename: me->path(mystrptr) = '%s'\n", var = p_super_cmd->path )

	/**********************************************************/
	/***	 	start reading in the ".T" file		***/
	/**********************************************************/

	/*** set the filename ***/
#ifndef NT
  strcpy ( tfilename, find_file ( p_super_cmd->cmd_key,
				"config/commands/", &status ) );
#else
  strcpy ( tfilename, find_file ( p_super_cmd->cmd_key,
				"config\\commands\\", &status ) );
#endif
  _bugprint(bflag=CEO_debug, str =
	  "Reading in cmd def for '%s'\n\tfrom file '%s'\n",
	  var = `p_super_cmd->cmd_name, tfilename` )

	/***  read in the command's definition ***/
	/***    ( this sets ME.CEO->ceo_version )  ***/
  _send ( my_id,
	  CEO.read_t_file ( 0, tfilename, 0, (char *) fp, & sts ));
  _bugprint(bflag=CEO_debug, str =
	"Sent CEO.read_t_file:  status=%d, sts=%d\n", 
	var = `status, sts` )

	/*** dump the cmd out to /tmp if DEBUG was set ***/
#ifdef DEBUG
  if ( dump_debug )
    {
#ifndef NT
	strcpy ( temptfilename, "/tmp" );
	ch = strrchr ( tfilename, '/' );
#else
	strcpy ( temptfilename, "c:\temp" );
	ch = strrchr ( tfilename, '\\' );
#endif
	strcat ( temptfilename, ch );
	_bugprint(bflag=CEO_debug, str =
			"fopen()-ing temptfilename = '%s'\n",
			var = temptfilename )

	if ( NULL != ( fp = (FILE *) fopen ( temptfilename, "w" ) ) )
	  {
		/***============= begin dump ==============***/
	    fprintf ( fp, "CDO(%d)\n{\n", p_CEO->ceo_version );

	    if ( p_super_cmd->active_form_name[0] )
	      {
		fprintf ( fp,"  status_display(\"%s\",%d,%d,%d)\n",
				p_super_cmd->active_form_name,
				p_CEO->origin_x, p_CEO->origin_y, p_CEO->status_display_form_ptr );
	      }

		  /*** dump the non-status_disp forms ***/
	    for ( ii = 0; ii < p_CEO->number_of_forms ; ii++ )
	      {
		fprintf ( fp,"form(\"%s\",%d,%d,%d,%d)\n",
			me->forms[ii].name, me->forms[ii].label,
			me->forms[ii].display_type,
			me->forms[ii].x, me->forms[ii].y,
			me->forms[ii].form_ptr );
	      }

			/****	"at init do"   ****/
	    if ( p_CEO->at_init )
	      {
		fprintf ( fp, "init()\n{\n" );
		_COB_for_list(action_ptr, list, \
			p_CEO->at_init, struct COBact_trans )

		  _bugprint(bflag=CEO_debug, str =
		     "Calling COBactions_dump( action = (0x)%x )\n",
				var = `& action_ptr->at.action` )
		  COBactions_dump ( &action_ptr->at.action, _true, fp );
		_COB_end_for_list
		fprintf ( fp, "    }\n" );
	      }

			/****	"at wakeup do"   ****/
	    if ( p_CEO->at_wakeup )
	      {
		fprintf ( fp, "wakeup()\n{\n" );
		_COB_for_list(action_ptr, list, \
			p_CEO->at_wakeup, struct COBact_trans )

		  _bugprint(bflag=CEO_debug, str =
		    "Calling COBactions_dump( action = (0x)%x )\n",
				var = `& action_ptr->at.action` )
		  COBactions_dump ( &action_ptr->at.action, _true, fp );
		_COB_end_for_list
		fprintf ( fp, "    }\n" );
	      }

			/****	"at sleep do"   ****/
	    if ( p_CEO->at_sleep )
	      {
		fprintf ( fp, "sleep()\n{\n" );
		_COB_for_list(action_ptr, list, \
				p_CEO->at_sleep, struct COBact_trans )

		_bugprint(bflag=CEO_debug, str =
			"Calling COBactions_dump( action = (0x)%x )\n",
				var = `& action_ptr->at.action` )
		COBactions_dump ( &action_ptr->at.action, _true, fp );

		_COB_end_for_list
		fprintf ( fp, "    }\n" );
	      }

		/****	"at delete do" ****/
	    if ( p_CEO->at_delete )
	      {
		fprintf ( fp, "delete()\n{\n" );
		_COB_for_list(action_ptr, list, \
			p_CEO->at_delete, struct COBact_trans )

		_bugprint(bflag=CEO_debug, str =
			 "Calling COBactions_dump( action = (0x)%x )\n",
			var = `& action_ptr->at.action` )
		COBactions_dump ( &action_ptr->at.action, _true, fp );

		_COB_end_for_list
		fprintf ( fp, "    }\n" );
	      }

			/*** dump the states ***/
	    _COB_for_list(state_ptr, list, p_CEO->states_ptr, \
						struct COBstate )

	      _bugprint(bflag=CEO_debug, str =
			"Calling COBstate_dump( action = (0x)%x )\n",
			var = state_ptr )
	      COBstate_dump ( state_ptr, fp );

	    _COB_end_for_list

	    fprintf ( fp, "}\n" );
		/***============= end of dump ==============***/
           if(fp != NULL)
          {

	    if ( fclose ( fp ) )
	      {
		printf("\n\t *** ERROR in closing dump file '%s'\n",
		    temptfilename );
	      }
            }
	  }
	else
	  {
	   printf("\n\t *** ERROR in opening dump file '%s'\n",
			temptfilename );
	  }
    }
#endif	/* DEBUG */

  if ( ! ( 1 & status & sts ) )
    {
	/**** error in reading cmd definition, so terminate. ****/
	  _bugprint(bflag=CEO_debug, str =
	    "Command object '%s' not constructed.\n",
	    var = p_super_cmd->cmd_name );

	    /*** fix to not overwrite me->status -- JAJ:01-11-90 ***/
	  sprintf ( err_report, "ERROR in '%s' command file.",
						p_super_cmd->cmd_key );
	  _send ( my_id, CEO.status ( err_report ) );

	  fprintf ( stderr, "\nCEO.init: ERROR in '%s' command file.\n",
						p_super_cmd->cmd_name );
	  fprintf ( stderr,
	      "CEO.init:  Couldn't read command definition file '%s'\n",
		tfilename);
	  fprintf ( stderr, "%s", TERMINATING_CMD );

	  p_super_cmd->state = _terminate;
	  goto quit;
    }
	/**********************************************************/
	/***	 	end of reading in the ".T" file		***/
	/**********************************************************/


  /*** status_display form ***/
  if ( p_super_cmd->active_form_name[0] )
    {
      _bugprint(bflag=CEO_debug, str =
		"Constructing status_display form '%s', label = %d\n",
		 var = `p_super_cmd->active_form_name, STATUS_FORM` )
      status = FIf_new ( STATUS_FORM, p_super_cmd->active_form_name,
				  (int (*)())COB_FI_form_notification,
				& p_CEO->status_display_form_ptr );
      _bugprint(bflag=CEO_debug, str =
	  "FIf_new() status = %d; me->status_display_form_ptr = 0x%x\n",
	  var = `status, p_CEO->status_display_form_ptr` ) 
      if ( status != FI_SUCCESS )
	{
	  fprintf ( stderr,
	      "\nCEO.init:  Construct of status_display form '%s' failed;\n  error status = %d.\n",
	      p_super_cmd->active_form_name, status );
	  fprintf ( stderr, "%s", TERMINATING_CMD );

		/*** This must be done to prevent it from	***/
		/*** being accessed.		-- JAJ:01-13-89 ***/
	  p_CEO->status_display_form_ptr = NULL;

	  p_super_cmd->state = _terminate;
	  goto quit;
	}
      else
	{
#ifndef NT
		/*** tell the form which cmd it's talking to ***/
	  status = FIf_set_cmd_oid_os ( p_CEO->status_display_form_ptr,
					my_id, OM_Gw_current_OS );
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
		"\nCEO.init:  Unable to set cmd oid,os of status_display form '%s';\n  error status = %d.\n",
		p_super_cmd->active_form_name, status );
	      fprintf ( stderr, "%s", TERMINATING_CMD );

	      p_super_cmd->state = _terminate;
	      goto quit;
	    }
#endif

					/***	   JAJ:01-28-89 ***/
		/*** tell the form what function to call for	***/
		/***   any initially notified gadgets  		***/
	  status = FIf_set_initial_notification_routine (
				p_CEO->status_display_form_ptr,
				(int (*)())COB_FI_initial_form_notification );
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
		"\nCEO.init:  Unable to set initial notification function\n  of status_display form '%s';\n  error status = %d.\n",
		p_super_cmd->active_form_name, status );
	      fprintf ( stderr, "%s", TERMINATING_CMD );

	      p_super_cmd->state = _terminate;
	      goto quit;
	    }

					/***	   JAJ:05-22-89 ***/
		/*** tell the form where to display		***/
	  if ( p_CEO->origin_x != -1  ||  p_CEO->origin_y != -1 )
	    {
	      status = FIf_set_location (
				p_CEO->status_display_form_ptr,
				p_CEO->origin_x, p_CEO->origin_y );
#ifdef DEBUG
	      if ( status != FI_SUCCESS )
		{
		    fprintf ( stderr,
			  "\nCEO.init:  Unable to set location\n  of status_display form '%s';\n  error status = %d.\n",
			  p_super_cmd->active_form_name, status );

		}
#endif
	    }
	}
    }	/* construct & init status display form */


  /*** construct and init the regular forms ***/
  for ( ii = 0; ii < p_CEO->number_of_forms; ++ ii )
    {
      if ( me->forms[ii].display_type == _persistent_form )
	{
		/*** see if there are any "Persistent Forms"; ***/
		/***   if not, make one ***/

	  found_pf = 0;

	  if ( COB_persistent_forms )
	    {
		/*** look for the form's name in the linked list ***/
	      _bugprint(bflag=CEO_debug, str =
		"Looking for pers. form name '%s' in COB_pf list\n",
		var = me->forms[ii].name )

	      _COB_for_list( pf_ptr, list, COB_persistent_forms,\
						 struct COB_pf_nod )
		if ( ! strcmp ( pf_ptr->name, me->forms[ii].name ) )
		  {
		    found_pf = 1;
		    me->forms[ii].form_ptr = pf_ptr->form_ptr;
		    me->forms[ii].prev_pf_cmd_oid = pf_ptr->cmd_oid;
		    pf_ptr->cmd_oid = my_id;
		    break;
		  }
	      _COB_end_for_list    
	    }
#ifdef DEBUG
	  else
	    {
	      _bugprint(bflag=CEO_debug, str = "COB_pf list is NULL\n" )
	    }
#endif

	  _bugprint(bflag=CEO_debug, str =
		"%s persistent form '%s' in COB_pf list\n",
		var = `found_pf ? "Found" : "Didn't find", me->forms[ii].name` )

	  if ( ! found_pf )
	    {
		/***  if the persistent form wasn't found,	***/
		/***  construct it and put its (name,oid)	***/
		/***  entry in the linked list pointed to	***/
		/***  by COB_persistent_forms 			***/

		  _bugprint(bflag=CEO_debug, str =
			"Constructing PERSISTENT me->form[%d] '%s'\n",
			 var = `ii, me->forms[ii].name` )
		  status = FIf_new ( me->forms[ii].label,
				  me->forms[ii].name,
				  (int (*)())COB_FI_form_notification,
				& me->forms[ii].form_ptr );
		  if ( status != FI_SUCCESS )
		    {
		      fprintf ( stderr,
			"\nCEO.init:  Construct of persistent form '%s' failed;\n  error status = %d.\n",
			me->forms[ii].name, status );
		      fprintf ( stderr, "%s", TERMINATING_CMD );

			/*** This must be done to prevent it from ***/
			/*** being accessed.	  -- JAJ:01-13-89 ***/
		      me->forms[ii].form_ptr = NULL;

		      p_super_cmd->state = _terminate;
		      goto quit;
		    }

	      temp_pf_entry = (struct COB_pf_nod *) calloc ( 1,
					sizeof ( struct COB_pf_nod ));
	      if ( ! temp_pf_entry )
		{
		  fprintf ( stderr, 
			 "\nCEO.init:  calloc ( pf_entry ) failed.\n" );
		  fprintf ( stderr, "%s", TERMINATING_CMD );
		  p_super_cmd->state = _terminate;
		  goto quit;
		}

	      strcpy ( temp_pf_entry->name, me->forms[ii].name );
	      temp_pf_entry->form_ptr = me->forms[ii].form_ptr;
	      temp_pf_entry->cmd_oid = my_id;

	      temp_pf_entry->list.next = temp_pf_entry;
	      temp_pf_entry->list.prev = temp_pf_entry;

	      _COB_append_to_list ( temp_pf_entry, list, COB_persistent_forms );
		_bugprint(bflag=CEO_debug, str =
			"Appended name( form name = '%s', form ptr = 0x%x) to COB_pf list\n",
			var=`temp_pf_entry->name, temp_pf_entry->form_ptr` );
	    }  /*** if ( ! found_pf ) ***/
	}   /* if ( me->forms[ii].display_type == _persistent_form ) */
      else	/*** NON-persistent form ***/
	{
	      _bugprint(bflag=CEO_debug, str =
			"Constructing me->form[%d] '%s'\n",
			 var = `ii, me->forms[ii].name` )
	      status = FIf_new (  me->forms[ii].label,
				  me->forms[ii].name,
				  (int (*)())COB_FI_form_notification,
				& me->forms[ii].form_ptr );
	      if ( status != FI_SUCCESS )
		{
		  fprintf ( stderr,
			"\nCEO.init:  Construct of form '%s' failed;\n  error status = %d.\n",
			me->forms[ii].name, status );
		  fprintf ( stderr, "%s", TERMINATING_CMD );

		    /*** This must be done to prevent it from	***/
		    /*** being accessed.	-- JAJ:01-13-89 ***/
		  me->forms[ii].form_ptr = NULL;

		  p_super_cmd->state = _terminate;
		  goto quit;
		}
	}

#ifndef NT
		/*** tell the form which cmd it's talking to ***/
	  status = FIf_set_cmd_oid_os ( me->forms[ii].form_ptr,
					      my_id, OM_Gw_current_OS );
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
		    "\nCEO.init:   Unable to set cmd oid,os of form '%s';\n  error status = %d.\n",
			  me->forms[ii].name, status );
	      fprintf ( stderr, "%s", TERMINATING_CMD );

	      p_super_cmd->state = _terminate;
	      goto quit;
	    }
#endif

					/***	   JAJ:01-28-89 ***/
		/*** tell the form what function to call for	***/
		/***   any initially notified gadgets  		***/
	  status = FIf_set_initial_notification_routine (
	  			me->forms[ii].form_ptr,
				(int (*)())COB_FI_initial_form_notification );
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
			"\nCEO.init:  Unable to set initial notification function\n  of form '%s';\n  error status = %d.\n",
			me->forms[ii].name, status );
	      fprintf ( stderr, "%s", TERMINATING_CMD );

	      p_super_cmd->state = _terminate;
	      goto quit;
	    }

					/***	   JAJ:05-22-89 ***/
	    /*** tell the form where to display		***/
	  if ( me->forms[ii].x != -1  ||  me->forms[ii].y != -1 )
	    {
	      status = FIf_set_location ( me->forms[ii].form_ptr,
					  me->forms[ii].x,
					  me->forms[ii].y );
#ifdef DEBUG
	      if ( status != FI_SUCCESS )
	        {
	          fprintf ( stderr,
		    "\nCEO.init:  Unable to set location\n  of form '%s';\n  error status = %d.\n",
		    me->forms[ii].name, status );
		}
#endif
	    }
    }   /*** for loop  ***/

	/**************************************************/
	/*** initialize the CEO->prev_state[] vla	***/
	/***************************** JAJ:08/02/91 *******/

  num_states = 0;

  _COB_for_list ( state_ptr, list, p_CEO->states_ptr, struct COBstate )

    num_states ++;

  _COB_end_for_list

  ii = om$dimension_of ( varray = ME.CEO->prev_state );
  if ( ii < num_states )
    {
      _bugprint ( bflag=CEO_debug, str =
		"me->prev_state size = %d, num_states = %d\n",
		var = `ii, num_states` )

      status = om$vla_set_dimension
		( varray = ME.CEO->prev_state, size = num_states );
      _cob_check ( status, "CEO.init:  om$vla_set_dimension failed" );
    }

  for ( ii = 0; ii < num_states ; ii++ )
    {
      ME.CEO->prev_state[ii] = 0;
    }


		/**********************************/
		/***	"at init do" stuff	***/
		/**********************************/

  _bugprint(bflag=CEO_debug, str =
	"************  Doing AT INIT's  ************\n" )

  p_CEO->ret = OM_S_SUCCESS;	/*** this must be done before ***/
				/*** calling COBactions/trans _do_it **/

  _COB_for_list ( act_ptr, list, p_CEO->at_init, struct COBact_trans )
    _bugprint(bflag=CEO_debug, str =
	  "Calling COBactions_do_it ( action_ptr=(0x)%x,...)\n",
	    var = `& act_ptr->at.action` )
    status = COBactions_do_it ( & act_ptr->at.action, my_id, &p_CEO->ret );

    _bugprint(bflag=CEO_debug, str =
       "Called COBactions_do_it():  status = %d, p_CEO->ret = %d\n",
	    var = `status, p_CEO->ret` )

    if ( status == OM_I_STOP_SENDING || !( 1 & status ) )
      {
	break;
      }

    if ( p_CEO->ret == COB_E_ARG_NOT_FOUND )	/*** JAJ:02-01-88 ***/
      {
	p_super_cmd->state = _terminate;
	goto quit;
      }

  _COB_end_for_list
  _bugprint(bflag=CEO_debug, str =
	"************  Did AT INIT's  ************\n" )

quit:
  _bugprint(bflag=TFLAG, str = "-CEO.init:\n" )

  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}  /*** end of CEO.init () ***/

end implementation CEO;
