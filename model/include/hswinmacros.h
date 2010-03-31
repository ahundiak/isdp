
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hswinmacros_include
#define hswinmacros_include

/***
	This file contains the macros used to access HSURF information
	from windows and to perform other useful tasks relating to
	shading windows.
***/


/*--- hs$get_window_instance_data -------------------------------------------*/

/*
	This macro gets the HS instance data for a window.  There are 4 cases:

	   1) (win_id,win_os) is a HSgragad -> its instance data is returned

	   2) (win_id,win_os) is a sublcass of IGEgragad and has a HSinstance
	      object attached -> the HSinstance object's instance data is
	      returned

	   3) (win_id,win_os) is a subclass of IGEgragad and doesn't have a
	      HSinstance object attached -> default instance data is returned

	   4) (win_id,win_os) is not a subclass of IGEgragad => error and
	      *msg is set to MSFAIL
	   
	The defines and structure definitions that are necessary to use this
	macro are in: ve.h, ve_inst.h and vedef.h.

	Parameters:
	   
	   *msg - IGRlong

	      MSSUCC is successful, MSFAIL if a failure occured

	   win_id - OM_S_OBJID

	      The object id of the window whose HS instance data is to
	      be inquired.

	   win_os - OMuword

	      The object space number of the window whose HS instance
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

	Return Values

	   0 - If successful
	   1 - otherwise
*/

#omdef hs$get_window_instance_data( msg,
	                            win_id,
	                            win_os = OM_Gw_current_OS,
	                            which_error,
	                            var_list );
					
	HSget_window_instance_data( msg, win_id, win_os, which_error, var_list )
	
#endomdef


/*--- hs$set_window_instance_data --------------------------------------------*/

/*
	This macro changes the HS instance data for a window.  There are 4 cases:

	   1) (win_id,win_os) is a HSgragad -> its instance data is changed

	   2) (win_id,win_os) is a sublcass of IGEgragad and has a HSinstance
	      object attached -> the HSinstance object's instance data is
	      changed

	   3) (win_id,win_os) is a subclass of IGEgragad and doesn't have a
	      HSinstance object attached -> a HSinstance object is constructed
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

	      The object id of the window whose HS instance data is to
	      be set.

	   win_os - OMuword

	      The object space number of the window whose HS instance
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

	Return Values

	   0 - If successful
	   1 - otherwise
*/

#omdef hs$set_window_instance_data( msg,
	                            win_id,
	                            win_os = OM_Gw_current_OS,
	                            which_error,
	                            var_list );
					
	HSset_window_instance_data( msg, win_id, win_os, which_error, var_list )
	
#endomdef



/*--- hs$get_saved_instance_id -----------------------------------------------*/

/*
	This macro gets the object id of the HSinstance object associated with
	a window.  If a HSinstance object is not assocatiated with the window,
	*instance_id is set to NULL_OBJID.  If (win_id,win_os) is not a subclass
	of IGEgragad, *msg is set to MSFAIL.
	   
	Parameters:
	   
	   *msg         - IGRlong

	      MSSUCC if successful, MSFAIL if a failure occurred

	   win_id       - OM_S_OBJID

	      The object id of the window whose HSinstance is to
	      be returned.

	   win_os       - OMuword

	      The object space number of the window whose HSinstance is to
	      be returned.

	   *instance_id - OM_S_OBJID

	      The object id of the HSinstance object associated with the
	      window (win_id, win_os).

	Return Values

	   0 - If successful
	   1 - otherwise
*/

#omdef hs$get_saved_instance_id( msg,
	                         win_id,
	                         win_os = OM_Gw_current_OS,
	                         instance_id );
					
	HSget_saved_instance_id( msg, win_id, win_os, instance_id )
	
#endomdef


/*--- hs$convert_shading_window_to_wireframe -----------------------------------------*/

/*
	This macro converts a shading window to a wireframe window and saves the
	shading instance data in an HSinstance object.
	   
	Parameters:
	   
	   *msg         - IGRlong

	      MSSUCC if successful, MSFAIL if a failure occurred

	   win_id       - OM_S_OBJID

	      The object id of the window to be converted to wireframe

	   win_os       - OMuword

	      The object space number of the window to be converted to wireframe

	   update - IGRint

	      Set to TRUE if you want the window updated after the conversion

	   display_message - IGRint

	      Set to TRUE if you want the message "Shading -> Wireframe" displayed in
	      the keyin field.

	Return Values

	   0 - If successful
	   1 - otherwise
*/

#omdef hs$convert_shading_window_to_wireframe( msg,
	                                       win_id,
	                                       win_os = OM_Gw_current_OS,
	                                       update = TRUE,
	                                       display_message = TRUE );
					
	HSconvert_shading_window_to_wireframe( msg, win_id, win_os, update, display_message );
	
#endomdef


/*--- hs$convert_wireframe_window_to_shading -----------------------------------------*/

/*
	This macro converts a wireframe window to a shading window.
	   
	Parameters:
	   
	   *msg         - IGRlong

	      MSSUCC if successful, MSFAIL if a failure occurred

	   win_id       - OM_S_OBJID

	      The object id of the window to be converted to shading.

	   win_os       - OMuword

	      The object space number of the window to be converted to shading.

	   update - IGRint

	      Set to TRUE if you want the window updated after the conversion

	   display_message - IGRint

	      Set to TRUE if you want the message "Wireframe -> Shading" displayed in
	      the keyin field.

	   shading_style - IGRuchar

	      Use defines in hsmacdef.h
	      
	   x_dits, y_dits - IGRint 

	Return Values

	   0 - If successful
	   1 - otherwise
*/

#omdef hs$convert_wireframe_window_to_shading( msg,
	                                       win_id,
	                                       win_os = OM_Gw_current_OS,
	                                       update = TRUE,
	                                       display_message = TRUE,
	                                       shading_style = HS_STYLE_SMOOTH, 
	                                       x_dits=-1,
	                                       y_dits=-1);
					
	HSconvert_wireframe_window_to_shading( msg, win_id, win_os, update, 
		display_message, shading_style, x_dits, y_dits );
	
#endomdef

#endif
