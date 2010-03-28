#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "dpdef.h"

static IGRint DPpixel_tolerance = 2;

int DPinq_display_tolerance(
   int *pixel_tol )

/*
NAME
	DPinq_display_tolerance

DESCRIPTION
	This function inquires the global display
	tolerance.  The tolerance is in pixels.

SYNOPSIS
	int DPinq_display_tolerance(
	   int *pixel_tol )

PARAMETERS
	pixel_tol (OUT) - the pixel tolerance

GLOBALS USED
	DPpixel_tolerance (static)

RETURN VALUES
	0
		Success
	1
		Failure

HISTORY
	07/26/93 S.P. Rogers
		Creation
*/
	
{
   *pixel_tol = DPpixel_tolerance;
   return( 0 );
} /* DPinq_display_tolerance */

int DPset_display_tolerance(
   int pixel_tol )

/*
NAME
	DPset_display_tolerance

DESCRIPTION
	This function sets the global display
	tolerance.  The tolerance is in pixels.

SYNOPSIS
	int DPset_display_tolerance(
	   int pixel_tol )

PARAMETERS
	pixel_tol (IN) - the new pixel tolerance

GLOBALS USED
	DPpixel_tolerance (static)

RETURN VALUES
	0
		Success
	1
		Failure

HISTORY
	07/26/93 S.P. Rogers
		Creation
*/

{
   DPpixel_tolerance = pixel_tol;
   return( 0 );
} /* DPset_display_tolerance */

