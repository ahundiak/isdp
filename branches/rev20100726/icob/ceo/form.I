/* ceo/form.I */

/**********************************************************/
/*** I/Forms methods  -- JAJ:12-07-88			***/
/**********************************************************/

class implementation CEO;

#include <OMmacros.h>	/*** need this for om$vla_set_dimension() ***/
#include <stdio.h>
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

#ifndef Form
#ifndef NT
#define Form char *
#endif
#endif


/*********************************************************************/
/*  CEO.get_form_ptr [ PUBLIC & PRIVATE ] -			     */
/*   Given a form label, return I/Forms  form pointer		     */
/*********************************************************************/
method get_form_ptr (
  int	  	   label;
  char 		** form_ptr;	/*** really a Form *	***/
  int		 * index;
  int		 * sts )
{
  int	  ii;

  _bugprint(bflag=TFLAG, str =
	"+CEO.get_form_ptr:  label=%d, *form_ptr=0x%x, *index=%d, *sts=%d\n",
	var = `label, *form_ptr, *index, *sts` )

  * index = -1;
  * sts = COB_E_FORM_NOT_FOUND;
  * form_ptr = NULL;

  /** see if the label is for a regular form **/
  for ( ii=0; ii < me->number_of_forms; ii++)
    {
       if ( me->forms[ii].label == label )
	 {
	    * form_ptr = me->forms[ii].form_ptr;
	    * index = ii;
	    * sts = OM_S_SUCCESS;
	    goto quit;
	 }
    }

  /** see if the label is for the status display form-- JAJ:01-02-88 **/
  if ( label == STATUS_FORM )
    {
      * form_ptr = me->status_display_form_ptr;
      * sts = OM_S_SUCCESS;
      /*** goto quit;  ***/
    }

quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO.get_form_ptr:  label=%d, *form_ptr=0x%x, *index=%d, *sts=%d\n",
	var = `label, *form_ptr, *index, *sts` )
  return OM_S_SUCCESS;
}




/*********************************************************************/
/*  CEO.display_form_by_label [ PUBLIC & PRIVATE ] -		     */
/*    Given a form label, display I/Forms form 			     */
/*********************************************************************/
method display_form_by_label (
  int	  form_label;
  int	* sts )
{
  char	* form_ptr = NULL;
  int	  index;
  int	  status;


  _bugprint(bflag=TFLAG, str =
	"+CEO.display_form_by_label:  form_label=%d, *sts=%d\n",
	var = `form_label, *sts` )

  * sts = OM_S_SUCCESS;

  _bugprint(bflag=CEO_debug, str =
	    "Sending myself CEO.get_form_ptr(label = %d)\n",
	    var = form_label )

	/*** get the ptr to the form ***/
  status = om$send ( targetid = my_id,
			msg = message CEO.get_form_ptr
			( form_label, &form_ptr, &index, sts ) );

  _bugprint(bflag=CEO_debug, str =
     "Back from CEO.get_form_ptr(form_ptr=0x%x, index=%d, *sts=%d)\n",
	var = `form_ptr, index, *sts` )

  if ( form_ptr && form_label != STATUS_FORM )
    {			/*** it's a regular form ***/
      _bugprint(bflag=CEO_debug, str =
	      "Calling FIf_display (me->forms[%d].form_ptr = 0x%x )\n",
	      var = `index, me->forms[index].form_ptr` )

      status = FIf_display ( me->forms[index].form_ptr );
      if ( (status != FI_SUCCESS)  &&  (status != FI_QUIET_MODE_ON)  )
        {
          fprintf ( stderr,
		  "CEO.display_form_label:  Display of form '%s' failed;  error status = %d.\n",
		  me->forms[index].name, status );
        }

	  /*** remember that the form is displayed ***/
      me->forms[index].displayed = 1;
    }
  else if ( form_ptr )	/*** it's the STATUS FORM ***/
    {
      _bugprint(bflag=CEO_debug, str =
        "Calling FIf_display (me->status_display_form_ptr = 0x%x )\n",
	      var = `me->status_display_form_ptr` )

      status = FIf_display ( me->status_display_form_ptr );
      if ( (status != FI_SUCCESS)  &&  (status != FI_QUIET_MODE_ON)  )
        {
          fprintf ( stderr,
		  "CEO.display_form_label:  Display of STATUS DISPLAY form '%s' failed;  error status = %d.\n",
		  me->active_form_name, status );
        }

	  /*** remember that the form is displayed ***/
      me->form_requested = 1;
    }
  else	/* the form_label supplied wasn't for a valid form */
    {
      *sts = COB_E_FORM_NOT_FOUND;
    }


/*quit:*/
  _bugprint(bflag=TFLAG, str =
    "-CEO.display_form_by_label:  outgoing *sts = %d\n", var = `sts` )
  return OM_S_SUCCESS;
}



/*********************************************************************/
/*  CEO.erase_form_by_label [ PUBLIC & PRIVATE ] -		     */
/*    Given a form label, erase I/Form form 			     */
/*********************************************************************/
method erase_form_by_label (
  int	  form_label;
  int	  reset_flag;	/* 1 = Reset form after erase */
  int	* sts )
{
  char  * form_ptr;
  int	  status;
  int	  index;


  _bugprint(bflag=TFLAG, str =
	"+CEO.erase_form_by_label:  form_label=%d, *sts=%d\n",
	var = `form_label, *sts` )

  * sts = OM_S_SUCCESS;

  _bugprint(bflag=CEO_debug, str =
	    "Sending myself CEO.get_form_ptr(label = %d)\n",
	    var = form_label )

	/*** get the ptr to the form ***/
  status = om$send ( targetid = my_id,
			msg = message CEO.get_form_ptr
			( form_label, &form_ptr, &index, sts ) );

  _bugprint(bflag=CEO_debug, str =
     "Back from CEO.get_form_ptr(form_ptr=0x%x, index=%d, *sts=%d)\n",
	var = `form_ptr, index, *sts` )

  if ( form_ptr && form_label != STATUS_FORM )
    {				/*** it's a regular form ***/
      _bugprint(bflag=CEO_debug, str =
	      "Calling FIf_erase (me->forms[%d].form_ptr = 0x%x )\n",
	      var = `index, me->forms[index].form_ptr` )

      status = FIf_erase ( me->forms[index].form_ptr );
      if ( status != FI_SUCCESS )
        {
          fprintf ( stderr,
		  "CEO.erase_form_by_label:  Erase of form '%s' failed;  error status = %d.\n",
		  me->forms[index].name, status );
	  goto quit;
        }

	  /*** remember that the form is erased ***/
      me->forms[index].displayed = 0;

      if ( reset_flag )
	{
	  _bugprint(bflag=CEO_debug, str =
	      "Calling FIf_reset (me->forms[%d].form_ptr = 0x%x )\n",
	      var = `index, me->forms[index].form_ptr` )

	  status = FIf_reset ( me->forms[index].form_ptr );
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
		"CEO.erase_form_by_label:  Reset of form '%s' failed;  error status = %d.\n",
		me->forms[index].name, status );
	    }
	}
    }
  else if ( form_ptr )	/*** it's the STATUS FORM ***/
    {
      _bugprint(bflag=CEO_debug, str =
	    "Calling FIf_erase (me->status_display_form_ptr = 0x%x )\n",
	      var = `me->status_display_form_ptr` )

      status = FIf_erase ( me->status_display_form_ptr );
      if ( status != FI_SUCCESS )
        {
          fprintf ( stderr,
		  "CEO.erase_form_by_label:  Erase of STATUS DISPLAY form '%s' failed;  error status = %d.\n",
		  me->active_form_name, status );
	  goto quit;
        }

	  /*** remember that the form is erased ***/
      me->form_requested = 0;

      if ( reset_flag )
	{
	  _bugprint(bflag=CEO_debug, str =
	      "Calling FIf_reset (me->status_display_form_ptr = 0x%x )\n",
	      var = `me->status_display_form_ptr` )

	  status = FIf_reset ( me->status_display_form_ptr );
	  if ( status != FI_SUCCESS )
	    {
	      fprintf ( stderr,
		"CEO.erase_form_by_label:  Reset of form STATUS DISPLAY'%s' failed;  error status = %d.\n",
		me->active_form_name, status );
	    }
	}
    }
  else	/* the form_label supplied wasn't for a valid form */
    {
      *sts = COB_E_FORM_NOT_FOUND;
    }


quit:
  _bugprint(bflag=TFLAG, str =
    "-CEO.erase_form_by_label:  outgoing *sts = %d\n", var = `sts` )
  return OM_S_SUCCESS;
}



/****************************************************************/
/* COB_FI_form_notification [ PRIVATE only ] -			*/
/*   This is the function called by default by every I/Forms	*/
/*   form defined via COB.  It basically calls the		*/
/*   FIf_get_cmd_oid_os() function				*/ 
/*   and gets out the command's objid and osnum for the command */
/*   object controlling the form.  It then sends this object	*/
/*   a message, passing on the arguments sent in to		*/
/*   COB_FI_form_notification().  Sending this MESSAGE		*/
/*   ( as opposed to a FUNCTION ) allows the command to access	*/
/*   its instance data when handling input from the form.	*/
/*								*/
/*   The default form input method is CEO.form_notification().	*/
/****************************************************************/
void COB_FI_form_notification ( form_label, gadget_label,
				value, form_ptr )
  int		form_label;
  int		gadget_label;
  double	value;
  Form		form_ptr;
{
  unsigned int		cmd_oid;
  unsigned short	cmd_os;
  int			status;
  extern int		FIf_get_cmd_oid_os();

  _bugprint(bflag=TFLAG, str =
	"+COB_FI_form_notification: form_label=%d, gadget_label=%d\n",
	var = `form_label, gadget_label` )
  _bugprint(bflag=TFLAG, str = "	value=%lf, form_ptr=0x%x\n",
	var = `value, form_ptr` )

  FIf_get_cmd_oid_os ( form_ptr, &cmd_oid, &cmd_os );

  _bugprint(bflag=CEO_debug, str =
	"After FIf_get_cmd_oid_os:  oid = %d, os = %hd\n",
	var = `cmd_oid, cmd_os` )

  status = om$send (	senderid = cmd_oid,
			targetid = cmd_oid,
   			targetos = cmd_os,
		msg = message CEO.form_notification ( form_label,
				gadget_label, value, form_ptr ) );

/*quit:*/
	;	/*** Need this ; so that if bugprint is not	  ***/
		/***   included in .c file, quit: has a statement ***/
		/***   to be a label for.			  ***/

#ifdef X11
  /*
  *  This is to accomodate Xforms.  For save_restore forms, the process event
  *  loop will not be exited unless FIf_erase is called.
  */
  if (FI_ACCEPT == gadget_label || FI_CANCEL == gadget_label)
  {
     long attr = 0;

     FIf_get_attr(form_ptr, &attr);
     if (attr & FI_SAVE_RESTORE)
       FIf_erase(form_ptr);
  }
#endif
  _bugprint(bflag=TFLAG, str = "-COB_FI_form_notification:\n" )
}



/****************************************************************/
/* COB_FI_initial_form_notification [ PRIVATE only ] -		*/
/*   This is the function called by default by every I/Forms	*/
/*   form defined via COB, for forms which have gadgets which   */
/*   have the INITIAL NOTIFY MODE set.  It basically 		*/
/*   gets the command's objid and osnum for the command 	*/
/*   object controlling the form.  It then sends this object	*/
/*   a CEO.initial_form_notification message, passing on the	*/
/*   arguments sent in to					*/
/*   COB_FI_initial_form_notification().  Sending this MESSAGE	*/
/*   ( as opposed to a FUNCTION ) allows the command to access	*/
/*   its instance data when handling input from the form.	*/
/****************************************************************/
void COB_FI_initial_form_notification ( form_label, gadget_label,
					value, form_ptr )
  int		form_label;
  int		gadget_label;
  double	value;
  Form		form_ptr;
{
  unsigned int		cmd_oid;
  unsigned short	cmd_os;
  int			status;
  extern int		FIf_get_cmd_oid_os();

  _bugprint(bflag=TFLAG, str =
	"+COB_FI_initial_form_notification: form_label=%d, gadget_label=%d\n",
	var = `form_label, gadget_label` )
  _bugprint(bflag=TFLAG, str = "	value=%lf, form_ptr=0x%x\n",
	var = `value, form_ptr` )
#ifndef NT
  FIf_get_cmd_oid_os ( form_ptr, &cmd_oid, &cmd_os );

  _bugprint(bflag=CEO_debug, str =
	"After FIf_get_cmd_oid_os:  oid = %d, os = %hd\n",
	var = `cmd_oid, cmd_os` )
#else
cmd_os = 0;
#endif

  status = om$send (	senderid = cmd_oid,
			targetid = cmd_oid,
   			targetos = cmd_os,
		msg = message CEO.initial_form_notification
			( form_label, gadget_label, value, form_ptr ) );

/*quit:*/
	;	/*** Need this ; so that if bugprint is not	  ***/
		/***   included in .c file, quit: has a statement ***/
		/***   to be a label for.			  ***/
  _bugprint(bflag=TFLAG, str = "-COB_FI_initial_form_notification:\n" )
}



/****************************************************************/
/* CEO.form_notification [ PUBLIC & PRIVATE ] -			*/
/*   This is the method which is invoked whenever I/Forms	*/
/*   forms return input to the command object.  It is analogous */
/*   to super_cmd.form_input().  Whenever an I/Forms form	*/
/*   gets input, the form calls the COB_FI_form_notification	*/
/*   function which sends the CEO.form_notification message to  */
/*   the command object.					*/
/*								*/
/*   This is a dummy method, and should be overridden by all	*/
/*   CEO- subclassed command objects which use I/Forms forms.	*/
/****************************************************************/
method form_notification (
  int		form_label;
  int		gadget_label;
  double	value;
  Form		form_ptr )
{
  _bugprint(bflag=TFLAG, str =
  "+CEO.form_notification: form_label=%d, gadget_label=%d, value=%lf, ptr = 0x%x\n",
    var = `form_label, gadget_label, value, form_ptr` )

  _bugprint(bflag=TFLAG, str = "-CEO.form_notification:\n" )

  return OM_S_SUCCESS;
}



/****************************************************************/
/* CEO.intial_form_notification [ PUBLIC & PRIVATE ] -		*/
/*   This is the method which is invoked whenever I/Forms	*/
/*   forms return input to the command object, for forms which  */
/*   have gadgets whose INITIAL NOTIFY mode is on.		*/
/*   Whenever an I/Forms form having such gadgets gets input,	*/
/*   the form calls the COB_FI_initial_form_notification	*/
/*   function which sends the CEO.initial_form_notification	*/
/*   message to the command object.				*/
/*								*/
/*   This is a dummy method, and should be overridden by all	*/
/*   CEO- subclassed command objects which use I/Forms forms    */
/*   which have initial notify gadgets.				*/
/****************************************************************/
method initial_form_notification (
  int		form_label;
  int		gadget_label;
  double	value;
  Form		form_ptr )
{
  _bugprint(bflag=TFLAG, str =
  "+CEO.initial_form_notification: form_label=%d, gadget_label=%d, value=%lf, ptr = 0x%x\n",
    var = `form_label, gadget_label, value, form_ptr` )

  _bugprint(bflag=TFLAG, str = "-CEO.initial_form_notification:\n" )

  return OM_S_SUCCESS;
}


end implementation CEO;
