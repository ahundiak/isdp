/* ceo/delete.I */
/*
	Created:  8-05-87  
	Purpose:  To delete the CEO class object, along with its
		  associated CDO object (and all the objects hanging
		  off the CDO).
	Modified: 12-21-87 -- JAJ
		  Moved CDO.delete_cmd stuff here, as well as CDO.dump
		  08-25-88 -- JAJ
		  Changed it from using state objects to structures
*/
class implementation CEO;

#include <stdio.h>
#include <OMmacros.h>	/*** need this for IF_NULL_OBJID	***/
#include <COB_pf_nod.h> /** need this for pf_nod stuff --JAJ:08-10-88**/

#include <FI.h>
#include <FIdyn.h>

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
#include "shampub.h"
#endif

method delete ( int f_defer_flag )  /* f_defer_flag is no longer used */
{
  int	 		     status,ii;
  struct COB_pf_nod	   * temp_pf_entry = NULL;
  extern struct COB_pf_nod * COB_persistent_forms;
  char			     found_pf;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_instance		* p_CEO = ME.CEO;


  _bugprint(bflag=TFLAG, str = "+CEO.delete:\n" )

	  /*** "at delete do" stuff - JAJ:09-28-87 ***/
  _bugprint(bflag=CEO_debug, str =
	"************  Doing AT DELETE's  ************\n" )

  p_CEO->ret = OM_S_SUCCESS;	/*** this must be done before ***/
				/*** calling COBactions/trans _do_it **/

  _COB_for_list ( act_ptr, list, p_CEO->at_delete, struct COBact_trans)
    _bugprint(bflag=CEO_debug, str =
	  "Calling COBactions_do_it ( action_ptr=(0x)%x,...)\n",
	    var = `& act_ptr->at.action` )
    status = COBactions_do_it ( & act_ptr->at.action, my_id, &p_CEO->ret );

    _bugprint(bflag=CEO_debug, str =
       "Called COBactions_do_it():  status = %d, ME.CEO->ret = %d\n",
	    var = `status, p_CEO->ret` )

    if ( status == OM_I_STOP_SENDING || !( 1 & status ) || 
			    	 p_CEO->ret == COB_E_ARG_NOT_FOUND )
      {
	break;
      }

  _COB_end_for_list
  _bugprint(bflag=CEO_debug, str =
	"************  Did AT DELETE's  ************\n" )


  /*** delete the status display form ***/
  if ( p_CEO->status_display_form_ptr ) 
    {
      /*  make sure form is valid before deleting  */

      if (!(FIf_is_valid (p_CEO->status_display_form_ptr)))
      {
         _bugprint(bflag=CEO_debug, str =
		"Calling FIf_delete status disp form_ptr = 0x%x )\n",
		var = `p_CEO->status_display_form_ptr` )

         status = FIf_delete ( p_CEO->status_display_form_ptr );
      }
#ifdef DEBUG
      if ( status != FI_SUCCESS )
        {
	   fprintf ( stderr,
		"CEO.delete:  Delete of status_display form '%s' failed;\n  error status = %d.\n",
		p_super_cmd->active_form_name, status );
        }
#endif
    }


  /*** delete all the forms ***/
  for ( ii = 0; ii < p_CEO->number_of_forms ; ii ++ )
    {
	/*** don't do this anymore -- it's freed as a whole later ***/
      /*********************************************  JAJ:11-23-88
      if ( me->forms[ii].name )
	{
	  free ( me->forms[ii].name );
	}
      ***************************************************************/

      if (  me->forms[ii].display_type == _persistent_form )
	{
	    /*** see if the COB_persistent_forms ptr is there; ***/
	    /***   if not, it's an error	***/
	    if ( ! COB_persistent_forms )
	      {
#ifdef DEBUG
		fprintf ( stderr,
		  "CEO.delete:  Error: COB_persistent_forms ptr is NULL\n" );
#endif
		continue;
	      }

	    /*** don't delete persistent form objects, unless this   **/
	    /***   is the cmd that first brought it up--JAJ:12-08-87 **/
	    if ( me->forms[ii].prev_pf_cmd_oid != NULL_OBJID )
	      {
		/*** remove my_id as the current CO controlling the ***/
		/***   persistent form 				    ***/
		
		temp_pf_entry = NULL;
		/*** look for the oid in the linked list ***/
		_COB_for_list( pf_ptr, list, COB_persistent_forms,\
						 struct COB_pf_nod )
		  if ( ! strcmp ( pf_ptr->name, me->forms[ii].name))
		    {
		      temp_pf_entry = pf_ptr;
		      break;
		    }
		_COB_end_for_list    

		if ( ! temp_pf_entry )
		  {
#ifdef DEBUG
		    fprintf ( stderr,
		      "CEO.delete:  Couldn't find persistent form oid entry '%s' in linked list\n",
		      me->forms[ii].name );
#endif
		    continue;
		  }

		/*** store the previous cmd as the current cmd oid ***/
		/***   using this persistent form ***/
		temp_pf_entry->cmd_oid = me->forms[ii].prev_pf_cmd_oid;

#ifndef NT
		/*** tell the form which cmd it's talking to ***/
		status = FIf_set_cmd_oid_os (
					me->forms[ii].form_ptr,
		    	       		me->forms[ii].prev_pf_cmd_oid,
					OM_Gw_current_OS );
#ifdef DEBUG
		if ( status != FI_SUCCESS )
		  {
		    fprintf ( stderr,
		      "CEO.delete:   Unable to set cmd oid,os of persistent form '%s';\n  error status = %d.\n",
		      me->forms[ii].name, status );
		  }
#endif
#endif
		continue;	/* don't delete the form structure */
	      }
	    else  /*** this cmd "is responsible for" deleting the ***/
	      {   /*** persistent form 	***/

		/*** Remove the form_ptr of the persistent form;  ***/
		/***   if it's not there, it's an error.  	  ***/

		/*** look for the form name in the linked list ***/
		found_pf = 0;
		_COB_for_list( pf_ptr, list, COB_persistent_forms,\
						 struct COB_pf_nod )
		  if ( ! strcmp ( pf_ptr->name, me->forms[ii].name))
		    {
		      found_pf = 1;

		      _bugprint(bflag=CEO_debug, str =
			"Removing name( form name='%s', ptr=0x%x, cmd_oid=%d) from COB_pf list\n",
			var=`pf_ptr->name, pf_ptr->form_ptr, pf_ptr->cmd_oid` );
		      _COB_remove_from_list ( pf_ptr, list, \
						COB_persistent_forms );

		      free ( pf_ptr );

		      break;
		    }

		_COB_end_for_list    

		if ( ! found_pf )
		  {
#ifdef DEBUG
		    fprintf ( stderr,
		      "CEO.delete:  Couldn't find any persistent form's '%s' reference in linked list NAME field\n",
		      me->forms[ii].name );
#endif
		    continue;
		  }
	      }
	} /*** end of if _persistent_form ***/

	/**** Actually delete the form structure ***/
      if ( me->forms[ii].form_ptr  )
	{
	  _bugprint(bflag=CEO_debug, str =
		  "Calling FIf_delete (me->forms[%d].form_ptr = 0x%x )\n",
		  var = `ii, me->forms[ii].form_ptr` )

	  status = FIf_delete ( me->forms[ii].form_ptr );
#ifdef DEBUG
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
		    "CEO.delete:  Delete of form '%s' failed;  error status = %d.\n",
		    me->forms[ii].name, status );
	      continue;
	    }
#endif
	}
    }	 /*** end of for loop ***/


	/*** delete all the state structures	 ***/
  if ( p_CEO->ceo_free_state_ptr )
    {
      _bugprint(bflag = CEO_debug, str = "freeing state_ptr = 0x%x\n",
		var = p_CEO->ceo_free_state_ptr )
      free ( p_CEO->ceo_free_state_ptr );
    }

	/*** delete all the action structures	 ***/
  if ( p_CEO->ceo_free_action_ptr )
    {
      _bugprint(bflag = CEO_debug, str = "freeing action_ptr = 0x%x\n",
		var = p_CEO->ceo_free_action_ptr )
      free ( p_CEO->ceo_free_action_ptr );
    }

	/*** delete all the action args characters ***/
  if ( p_CEO->ceo_free_action_args_ptr )
    {
      _bugprint(bflag = CEO_debug, str = "freeing action_args_ptr = 0x%x\n",
		var = p_CEO->ceo_free_action_args_ptr )
      free ( p_CEO->ceo_free_action_args_ptr );
    }

	/*** delete all the trans structures	 ***/
  if ( p_CEO->ceo_free_trans_ptr )
    {
      _bugprint(bflag = CEO_debug, str = "freeing trans_ptr = 0x%x\n",
		var = p_CEO->ceo_free_trans_ptr )
      free ( p_CEO->ceo_free_trans_ptr );
    }

	/*** delete all the trans_pods characters  ***/
  if ( p_CEO->ceo_free_trans_pods_ptr )
    {
      _bugprint(bflag = CEO_debug, str="freeing trans_pods_ptr = 0x%x\n",
		var = p_CEO->ceo_free_trans_pods_ptr )
      free ( p_CEO->ceo_free_trans_pods_ptr );
    }

	/*** delete all the miscellaneous character strings  ***/
  for ( ii = 0; ii < p_CEO->ceo_free_strs_size ; ii++ )
    {
      if ( p_CEO->ceo_free_strs_ptr[ii] )
	{
	  _bugprint(bflag = CEO_debug, str="freeing free_strs_ptr[%d] = 0x%x\n",
		var = `ii, p_CEO->ceo_free_strs_ptr[ii]` )
	  free ( p_CEO->ceo_free_strs_ptr[ii] );
	}
    }
  if ( p_CEO->ceo_free_strs_ptr )
    {
      _bugprint(bflag = CEO_debug, str="freeing free_strs_ptr = 0x%x\n",
		var = p_CEO->ceo_free_strs_ptr )
      free ( p_CEO->ceo_free_strs_ptr );
    }
  if ( p_CEO->ceo_free_strs_indices )
    {
      _bugprint(bflag = CEO_debug, str="freeing free_strs_indices = 0x%x\n",
		var = p_CEO->ceo_free_strs_indices )
      free ( p_CEO->ceo_free_strs_indices );
    }


  /**** delete the CEO-class object itself ****/
  _bugprint(bflag=CEO_debug, str =
	"Sending my_id Root.delete( 0 )\n" )
  status = om$send ( targetid = my_id,
		     mode = OM_e_wrt_message,
		     msg = message Root.delete ( 0 ));
#ifdef DEBUG
  _cob_check ( status, "CEO.delete:  Root.delete(my_id) failed");
#endif


/*quit:*/
  _bugprint(bflag=TFLAG, str = "-CEO.delete: status[local] = %d\n",
	var = status)
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}  /*** end CEO.delete () ***/

end implementation CEO;
