
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

/*		Apogee compliant		*/

#include <stdlib.h>
#include <stdio.h>

#include "igrtypedef.h"
#include "igr.h"

#include "hsmath.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"

#include "HSpr_display.h"

#define DEBUG	0


/*---HSdraw_trapezoid------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSdraw_trapezoid( struct trapezoid *trap )
#else
	void	HSdraw_trapezoid( trap )

	struct trapezoid	*trap;
#endif

	{
#if DEBUG
	{
	fprintf( stderr, "\nHSdraw_trapezoid --- %1d %x\n", ++c1, trap->id );
	fprintf( stderr, "p0 -- %5d %5d %12d %2d\n",
		ROUND16( trap->x0 ), trap->ya, trap->z0, trap->shade0 );
	fprintf( stderr, "p1 -- %5d %5d %12d %2d\n",
		ROUND16( trap->x1 ), trap->ya, trap->z1, trap->shade1 );
	fprintf( stderr, "p2 -- %5d %5d %12d %2d\n",
		ROUND16( trap->x2 ), trap->yb, trap->z2, trap->shade2 );
	fprintf( stderr, "p3 -- %5d %5d %12d %2d\n",
		ROUND16( trap->x3 ), trap->yb, trap->z3, trap->shade3 );
	}
#endif

	(*active_window->rasterizer[active_window->active_zbuffer])( trap );
	}
