
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsncmacros_include
#define hsncmacros_include 1

/***
	This file contains the macros used to get/put HSURF-NC Verification
	global data.
	
	Dependencies:

	    hsncdef.h
***/


/*--- hsnc$get_verification_parameters -----------------------------------------------*/

/*
	This macro returns the requested NC Verification parameter values.
	   
	Parameters:
	   
	   *display_mode	- IGRint - defined in hsncdef.h
	   *simulation_speed	- IGRint - defined in hsncdef.h
	   *shading_style	- IGRint - defined in hsncdef.h
*/

#omdef  hsnc$get_verification_parameters(	display_mode		= NULL,
						simulation_speed	= NULL,
						shading_style		= NULL )

	HSNCget_verification_parms(	display_mode,
					simulation_speed,
					shading_style )
	
#endomdef


/*--- hsnc$put_verification_parameters -----------------------------------------------*/

/*
	This macro changes the given NC Verification parameter values.
	   
	Parameters:
	   
	   display_mode		- IGRint - defined in hsncdef.h
	   simulation_speed	- IGRint - defined in hsncdef.h
	   shading_style	- IGRint - defined in hsncdef.h

	Return Values:

	   0 - SUCCESS
	   1 - FAILURE (illegal parameter value)
*/

#omdef  hsnc$put_verification_parameters(	display_mode		= NULL,
						simulation_speed	= NULL,
						shading_style		= NULL )

	HSNCput_verification_parms(	display_mode,
					simulation_speed,
					shading_style )
	
#endomdef

#endif
