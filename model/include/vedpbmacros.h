
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef vedpbmacros_include
#define vedpbmacros_include 1

/***
	This file contains the macros used to access VEdpb information.
***/

/*--- ve$copy_dpb_data_to_other_os -------------------------------*/

/*
	This macros copies VEdpb data from the current module to
	a VEdpb in another object space.

	Parameters:

	   osnum - OMuword

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$copy_dpb_data_to_other_os( osnum )

	VEdpb_copy_data_to_other_os( osnum );

#endomdef


/*--- ve$get_dpb_flags -------------------------------------------*/

/*
	This macro gets the VEdpb flags word.

	Parameters:
	   
	   *flags - IGRuint

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$get_dpb_flags( flags )
					
	VEdpb_get_flags( flags );
	
#endomdef


/*--- ve$set_dpb_flags -------------------------------------------*/

/*
	This macro sets the VEdpb flags word.

	Parameters:
	   
	   flags - IGRuint

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$set_dpb_flags( flags )
					
	VEdpb_set_flags( flags );
	
#endomdef


/*--- ve$get_gapping_distance -------------------------------------------*/

/*
	This macro gets the gapping distance.

	Parameters:
	   
	   *gapping_distance - IGRdouble

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$get_gapping_distance( gapping_distance )
					
	VEdpb_get_gapping_distance( gapping_distance );
	
#endomdef


/*--- ve$set_gapping_distance -------------------------------------------*/

/*
	This macro sets the gapping distance.

	Parameters:
	   
	   gapping_distance - IGRdouble

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$set_gapping_distance( gapping_distance )
					
	VEdpb_set_gapping_distance( gapping_distance );
	
#endomdef


/*--- ve$get_trace_tol -------------------------------------------*/

/*
	This macro gets the tracing tolerance.

	Parameters:
	   
	   *trace_tol - IGRdouble

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$get_trace_tol( trace_tol )
					
	VEdpb_get_trace_tol( trace_tol );
	
#endomdef


/*--- ve$set_trace_tol -------------------------------------------*/

/*
	This macro sets the tracing tolerance.

	Parameters:
	   
	   trace_tol - IGRdouble

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$set_trace_tol( trace_tol )
					
	VEdpb_set_trace_tol( trace_tol );
	
#endomdef


/*--- ve$get_reduction_thresholds -------------------------------------------*/

/*
	This macro gets the gapping distance.

	Parameters:
	   
	   *surf_threshold - IGRshort
	   *curve_threshold - IGRshort

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$get_reduction_thresholds( surf_threshold, curve_threshold )
					
	VEdpb_get_reduction_thresholds( surf_threshold, curve_threshold );
	
#endomdef


/*--- ve$set_reduction_thresholds -------------------------------------------*/

/*
	This macro sets the VEdpb flags word.

	Parameters:
	   
	   surf_threshold - IGRshort
	   curve_threshold - IGRshort

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$set_reduction_thresholds( surf_threshold, curve_threshold )
					
	VEdpb_set_reduction_thresholds( surf_threshold, curve_threshold );
	
#endomdef


/*--- ve$get_last_bg_info -------------------------------------------*/

/*
	This macro gets the last background job information

	Parameters:
	   
	   *last_server       - IGRchar
	   *last_user_name    - IGRchar
	   *last_password     - IGRchar
	   *last_results_file - IGRchar
	   *last_start_time   - IGRchar

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$get_last_bg_info( last_server, last_user_name, last_password, last_results_file, last_start_time )
					
	VEdpb_get_last_bg_info( last_server, last_user_name, last_password, last_results_file, last_start_time );
	
#endomdef


/*--- ve$set_last_bg_info -------------------------------------------*/

/*
	This macro sets the last background job information

	Parameters:
	   
	   *last_server       - IGRchar
	   *last_user_name    - IGRchar
	   *last_password     - IGRchar
	   *last_results_file - IGRchar
	   *last_start_time   - IGRchar

	Return Values:

	   0 - if successful
	   1 - otherwise
*/

#omdef ve$set_last_bg_info( last_server, last_user_name, last_password, last_results_file, last_start_time )
					
	VEdpb_set_last_bg_info( last_server, last_user_name, last_password, last_results_file, last_start_time );
	
#endomdef

#endif
