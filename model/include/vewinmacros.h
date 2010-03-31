
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef vewinmacros_include
#define vewinmacros_include 1

/***
	This file contains the macros used to access VE information
	from windows and to perform other useful tasks relating to
	visible Edges.
***/


/*--- ve$get_window_instance_data -------------------------------------------*/

/*
	This macro gets the VE instance data for a window.  There are 4 cases:

	   1) (win_id,win_os) is a VEgragad -> its instance data is returned

	   2) (win_id,win_os) is a sublcass of IGEgragad and has a VEinstance
	      object attached -> the VEinstance object's instance data is
	      returned

	   3) (win_id,win_os) is a subclass of IGEgragad and doesn't have a
	      VEinstance object attached -> default instance data is returned

	   4) (win_id,win_os) is not a subclass of IGEgragad => error and
	      *msg is set to MSFAIL
	   
	The defines and structure definitions that are necessary to use this
	macro are in: ve.h, ve_inst.h and vedef.h.

	Parameters:
	   
	   *msg - IGRlong

	      MSSUCC is successful, MSFAIL if a failure occured

	   win_id - OM_S_OBJID

	      The object id of the window whose VE instance data is to
	      be inquired.

	   win_os - OMuword

	      The object space number of the window whose VE instance
	      data is to be inquired.

	   *var_list - struct var_list

	      Array of structures that tells what instance data to
	      inquire and where to put it.  Each structure has the
	      following fields:

	         var --- A constant defined in vedef.h that identifies
	                 which attribute is to be inquired.

	         var_ptr --- The address of a variable in the callers
	                     data space that will receive the inquired data.

	         num_bytes --- The number of bytes in the space provided by the
	                       caller.

	         bytes_returned --- The number of bytes copied into the space
	                            provided by the caller.

	      The last structure in the array must have 'var' set to END_PARAM.

	   *which_error - IGRlong

	      If one of the instance data requests fails, this variable
	      will be set to the 'var' field of the one that failed.

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$get_window_instance_data( msg,
	                            win_id,
	                            win_os = OM_Gw_current_OS,
	                            which_error,
	                            var_list );
					
	VEget_window_instance_data( msg, win_id, win_os, which_error, var_list )
	
#endomdef


/*--- ve$set_window_instance_data --------------------------------------------*/

/*
	This macro changes the VE instance data for a window.  There are 4 cases:

	   1) (win_id,win_os) is a VEgragad -> its instance data is changed

	   2) (win_id,win_os) is a sublcass of IGEgragad and has a VEinstance
	      object attached -> the VEinstance object's instance data is
	      changed

	   3) (win_id,win_os) is a subclass of IGEgragad and doesn't have a
	      VEinstance object attached -> a VEinstance object is constructed
	      and attached to (win_id,win_os) and its instnace data is
	      changed

	   4) (win_id,win_os) is not a subclass of IGEgragad => error and
	      *msg is set to MSFAIL
	   
	The defines and structure definitions that are necessary to use this
	macro are in: ve.h, ve_inst.h and vedef.h.
	   
	Parameters:
	   
	   *msg - IGRlong

	      MSSUCC is successful, MSFAIL if a failure occured

	   win_id - OM_S_OBJID

	      The object id of the window whose VE instance data is to
	      be set.

	   win_os - OMuword

	      The object space number of the window whose VE instance
	      data is to be set.

	   *var_list - struct var_list

	      Array of structures that tells what instance data to
	      set and where to get it from.  Each structure has the
	      following fields:

	         var - A constant defined in vedef.h that identifies
	               which attribute is to be set.

	         var_ptr - The address of a variable in the callers
	                   data space that will contains the data to
	                   put in the instance data.

	         num_bytes - The number of bytes in the space provided by the
	                     caller.

	         bytes_returned - The number of bytes copied into the instance
	                          data of the window.

	      The last structure in the array must have 'var' set to END_PARAM.

	   *which_error - IGRlong

	      If one of the instance data requests fails, this variable
	      will be set to the 'var' field of the one that failed.

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$set_window_instance_data( msg,
	                            win_id,
	                            win_os = OM_Gw_current_OS,
	                            which_error,
	                            var_list );
					
	VEset_window_instance_data( msg, win_id, win_os, which_error, var_list )
	
#endomdef


/*--- ve$get_saved_instance_id -----------------------------------------------*/

/*
	This macro gets the object id of the VEinstance object associated with
	a window.  If a VEinstance object is not assocatiated with the window,
	*instance_id is set to NULL_OBJID.  If (win_id,win_os) is not a subclass
	of IGEgragad, *msg is set to MSFAIL.
	   
	Parameters:
	   
	   *msg         - IGRlong

	      MSSUCC if successful, MSFAIL if a failure occurred

	   win_id       - OM_S_OBJID

	      The object id of the window whose VEinstance is to
	      be returned.

	   win_os       - OMuword

	      The object space number of the window whose VEinstance is to
	      be returned.

	   *instance_id - OM_S_OBJID

	      The object id of the VEinstance object associated with the
	      window (win_id, win_os).

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$get_saved_instance_id( msg,
	                         win_id,
	                         win_os = OM_Gw_current_OS,
	                         instance_id );
					
	VEget_saved_instance_id( msg, win_id, win_os, instance_id )
	
#endomdef


/*--- ve$make_win_ve -----------------------------------------------*/

/*
	This macro makes a window a VEgragad.  It changes the class of the
	window and saves shading instance data as an HSinstance object if
	necessary.  If the window has a VEinstance object attached, its
	instance data is loaded into the resulting VEgragad.  Otherwise,
	default instance data is loaded into the VEgragad.
	   
	Parameters:
	   
	   *msg            - IGRlong

	      MSSUCC is successful, MSFAIL if a failure occured.

	   win_id          - OM_S_OBJID

	      The object id of the window to convert to a VEgragad.

	   win_os          - OMuword

	      The object space number of the window to convert to a
	      VEgragad.

	   display_message - IGRint

	      If TRUE, then a message is displayed in the keyin field
	      if the window that was converted was a shading window
	      (i.e., Shading -> Wireframe).

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$make_win_ve( msg,
	               win_id,
	               win_os = OM_Gw_current_OS,
	               display_message = TRUE );
					
	VEmake_win_ve( msg, win_id, win_os, display_message );
	
#endomdef


/*--- ve$convert_ve_win_to_wireframe -----------------------------------------------*/

/*
	This macro converts a VEgragad to an IGEgragad.  It changes the class
	of the window to an IGEgragad, and saves the Visible Edges instance data as
	a VEinstance object connected to the IGEgragad.
	   
	Parameters:
	   
	   *msg            - IGRlong

	      MSSUCC if successful, MSFAIL if a failure occurred.

	   win_id          - OM_S_OBJID

	      The object id of the VE window to convert to an IGEgragad.

	   win_os          - OMuword

	      The object space number of the VE window to convert to an
	      IGEgragad.

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$convert_ve_win_to_wireframe( msg,
	                               win_id,
	                               win_os = OM_Gw_current_OS );
					
	VEconvert_ve_win_to_wireframe( msg, win_id, win_os )
	
#endomdef

#endif
