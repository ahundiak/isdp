class specification CEO (1:0) of super_cmd;

#include <igetypedef.h>
#include <exmacros.h>
#include <ODE.h>
#include <COBstructs.h>

%undef sleep

instance CEO
{
    /******************************************************************/
    /**			"PRIVATE" instance data			     **/
    /**  This instance data is for INTERNAL COB USE ONLY, and        **/
    /**  should *NOT* be referenced by COB users.	  	     **/
    /******************************************************************/

  struct COBact_trans	* at_init;	  /* at "init"   do           */
  struct COBact_trans	* at_wakeup;	  /* at "wakeup" do           */
  struct COBact_trans	* at_sleep;	  /* at "sleep"  do           */
  struct COBact_trans	* at_delete;	  /* at "delete" do           */
  struct COBstate	* states_ptr;	  /* ptr to cmd obj's states  */

  int			  ceo_version;	  /* version # of ".T" file   */

  struct COBstate	* ceo_free_state_ptr;
  struct COBact_trans	* ceo_free_action_ptr;
  char			* ceo_free_action_args_ptr;
  struct COBact_trans	* ceo_free_trans_ptr;
  char			* ceo_free_trans_pods_ptr;

  int			  ceo_free_state_index;
  int			  ceo_free_action_index;
  int			  ceo_free_action_args_index;
  int			  ceo_free_trans_index;
  int			  ceo_free_trans_pods_index;

  char		       ** ceo_free_strs_ptr;
  int			* ceo_free_strs_indices;
  int			  ceo_free_strs_index;
  int			  ceo_free_strs_size;

  variable int		  prev_state [4]; /* previous state stack     */
  short			  prev_counter;	  /* previous state stack ptr */
  IGRshort		  prev_msg_state; /* either MS_ON or MS_OFF   */


	/**************************************************************/
	/**		  "SEMI-PRIVATE" instance data		     **/
	/**  This instance data is set up and referenced by COB.     **/
	/**  Users may reference these variables directly when	     **/
	/**  necessary, although users should not change these       **/
	/**  variables except in cases outlined in the               **/
	/**  COB Users Guide and/or release notes.		     **/
	/**************************************************************/

  channel {(initial=1, increment=1)}	constructed_graphics;
  OM_S_CHANSELECT	  const_chansel;	/* constructed chan select */
  char			  const_class [ _max_class_name ];

  int			  next_state;		/* next state num */
  char			* status_display_form_ptr; /* status disp ptr */
  int			  origin_x;		/* status_disp form origin */
  int			  origin_y;		/* '' */
 variable struct CEO_form forms[0];		/* form(s) for this cmd */
  int			  number_of_forms;	/* number of forms this cmd */
  int			* response;		/* wfi input type */
  char			* response_data;	/* wfi input data */
  int			  nbytes1;		/* # bytes returned by wfi */
  long			  ret;			/* return code */
  char			  prompt [_max_key];	/* current prompt chars */
  char			  msg [_max_key];	/* current message chars */
  char			  status [_max_key];	/* current status chars */
  variable char		  error_box [ 0 ];	/* current error box chars */
  long			  filter_mode;		/* mode used to get kbd input */
};

	/*****************************************************************/
	/**			"PRIVATE" messages			**/
	/**  These messages are for INTERNAL COB USE ONLY, and		**/
	/**  should *NOT* BE SENT or OVERRIDDEN by COB users.		**/
	/*****************************************************************/

message predicate (	/* test predicate to see if it "is_true" */
  int		  predicate_selector;	/* the thing to check */
  int		  predicate_operator;	/* how to check it */
  char		* data;			/* data required by predicate */
					/*   really data_val *, but we don't */
					/*   want to include COBint.h	     */
  int		* is_true );		/* result */


message read_t_file (	/* read in the ".T" command file at run-time */
  char		  which_chan;
  char		* file_name;
  char		* owner_ptr;	/* really a COBstate/COBact_trans ptr */
  char		* fp;		/* really a FILE *, but we don't want */
				/*   CEO.S to have to include stdio.h */
  int		* sts );	/* the usual return code */

message real_execute (	/* called by execute method */
  int	* response;
  char	* response_data;
  int	  pos;
  int  ** ceo_response; );


	/*****************************************************************/
	/**		     "SEMI-PRIVATE" messages			**/
	/**  These messages are used internally by COB, but they may 	**/
	/**  be sent and/or overridden by COB users as directed in the  **/
	/**  COB Users Guide and release notes.  In general, if any of	**/
	/**  these methods are overridden by the COB user, then the	**/
	/**  user's method should include a send with respect to	**/
	/**  message of the CEO method that was overridden.		**/
	/*****************************************************************/

override delete; /* int f_defer_flag (not used) */
	/* delete the CEO class object and all its malloc-ed memory */

override execute; /* int * response; char * response_data; int pos */

override init; /* int type; char * str_ptr  */
	/* initialize a new instance of this command class		*/
	/* read in command definition from ascii file,			*/
	/* set instance data to defaults, e.g. prompt, msg, status, etc.*/
	/* make chan selectors ;  construct & init forms               */

override sleep; /* int pos */

override status_disp;	/* status display form */

override wakeup; /* int pos */
	/* set runtime info,						*/
	/* restore message field					*/
	/* if command uses a form, do form initialization 		*/

/*----------------------------------------------------------------------*/

message action ( /* perform indicated action */
  int	  action_selector;	/* the action to perform */
  int	  int_or_str_ptr;	/* ptr to data required by action */
  int	* sts );		/* returned status code */

/*----------------------------------------------------------------------*/

message arg_name_to_value ( /* translate a string from the state table into */
			    /*   its variable name value */
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
  char		* is_const );	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */

/*----------------------------------------------------------------------*/

/******************************************************************************/
/*** Given a form label, CEO.display_form_by_label will display the	    ***/
/***    I/Forms form, and notify COB that it is displayed.		    ***/
/***    The purpose of this method is to have the same functionality as the ***/
/***    "display_form" keyword in the state table, so programmers may call  ***/
/***    it from within a method.					    ***/
/***  NOTE: It returns OM_S_SUCCESS through "sts" if the form was	    ***/
/***	    displayed successfully, or COB_E_FORM_NOT_FOUND if the label    ***/
/***	    is not valid.						    ***/
/******************************************************************************/
message display_form_by_label (
  int	  form_label;
  int	* sts );

/*----------------------------------------------------------------------*/

message dynamics (	/*** perform dynamics - dummy method ***/
  int	  dynamics;
  int	* sts );

/*----------------------------------------------------------------------*/

/******************************************************************************/
/*** Given a form label, CEO.erase_form_by_label will erase the  	    ***/
/***    I/Forms form, and notify COB that it is erased.			    ***/
/***    The purpose of this method is to have the same functionality as the ***/
/***    "erase_form" keyword in the state table, so programmers may call    ***/
/***    it from within a method.					    ***/
/***  NOTE: It returns OM_S_SUCCESS through "sts" if the form was	    ***/
/***	    erased successfully, or COB_E_FORM_NOT_FOUND if the label  	    ***/
/***	    is not valid.						    ***/
/******************************************************************************/
message erase_form_by_label (
  int	  form_label;
  int	  reset_flag;	/* 1 = Reset form after erase; 0 = Don't reset form. */
  int	* sts );

/*----------------------------------------------------------------------*/

message error_box ( char * error_string ); /* write string in Exnuc error box */

/*----------------------------------------------------------------------*/

message filter (	/*** input using current filter	***/
  int	  filter;
  int   * response;
  char	* response_data );

/*----------------------------------------------------------------------*/

/******************************************************************************/
/* CEO.form_notification is called whenever a I/Forms form is given input     */
/* by the user.  It is analogous to super_cmd.form_input(); however, no input */
/* is present in the "value" argument if the gadget type is a field.  See the */
/* I/Forms Forms documentation about querying a form's gadgets to get their   */
/* values.								      */
/******************************************************************************/
message form_notification (
  int	 form_label;		/* label of form which received user  input */
  int	 gadget_label;		/* gadget label  which received user  input */
  double value;			/* value of gadget ( or field row # )	    */
  char * form_ptr );		/* ptr to I/Forms form which received input */

/*----------------------------------------------------------------------*/

/******************************************************************************/
/*** Given a form label, CEO.get_form_ptr will return a pointer to the form ***/
/***	with that label (along with the index into ME.CEO->forms[]) if the  ***/
/***	form is present; otherwise, *sts returns COB_E_FORM_NOT_FOUND	    ***/
/*** Note:  If ( label == STATUS_FORM ), then the form_ptr returned is      ***/
/***    me->status_display_form_ptr and the index = -1.			    ***/
/******************************************************************************/
message get_form_ptr (
  int	  	   label;
  char 		** form_ptr;
  int		 * index;
  int		 * sts );

/*----------------------------------------------------------------------*/

/******************************************************************************/
/* CEO.initial_form_notification is called whenever a I/Forms form is         */
/* initially given input by the user.  The difference between		      */
/* CEO.initial_form_notification and CEO.form_notification is that the former */
/* method is invoked immediately upon the user's poking of a gadget on the    */
/* form, and the latter message is sent when the user finally stops updating  */
/* the gadget.  CEO.initial_form_notification is only called for gadgets      */
/* on a form which have the initial notification mode set to on.  See the     */
/* I/Forms Forms documentation about querying a form's gadgets to get their   */
/* values.								      */
/******************************************************************************/
message initial_form_notification (
  int	 form_label;		/* label of form which received user  input */
  int	 gadget_label;		/* gadget label  which received user  input */
  double value;			/* value of gadget ( or field row # )	    */
  char * form_ptr );		/* ptr to I/Forms form which received input */

/*----------------------------------------------------------------------*/

message msg ( char * message_string ); /* write string in message field */

/*----------------------------------------------------------------------*/

message prompt ( char * prompt_string ); /* write string in prompt field */

/*----------------------------------------------------------------------*/

message status ( char * status_string ); /* write string in status field */

/*----------------------------------------------------------------------*/


end specification CEO;
