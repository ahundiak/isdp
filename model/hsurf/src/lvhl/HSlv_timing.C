
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:39 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/times.h>
#include <FI.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "growner.h"
#include "godef.h"
#include "dpstruct.h"
#include "msdef.h"
#include "msmacros.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdisplay.h"

#include "vemsg.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HSd_fixedpt.h"
#include "HSe2_mesher.h"

#include "HSplot.h"
#include "HSpr_lvhl.h"


static long	beg_time;
static long	cur_time;
static long	last_time;

static int	timing_active;

/*---HSlvhl_display_timing-----------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_display_timing( long this_time )
#else
	void	HSlvhl_display_timing( this_time )

	long	this_time;
#endif

	{
	long	min, sec;
	
	min = (this_time - beg_time) / 60;
	sec = (this_time - beg_time) % 60;
	
	ex$message( field = KEYIN_FIELD,
		  msgnumb = VE_I_ElapsedTime,
		     type = "%d%d",
		      var = `min,sec`,
	    justification = CENTER_JUS );
	}

/*---HSlvhl_init_timing--------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_init_timing(void)
#else
	void	HSlvhl_init_timing()
#endif

	{
	char	*expr, *getenv();
	
	timing_active = 0;
	expr = getenv( "HSlvhl_TIMER" );
	if ( expr )
		sscanf( expr, "%d", &timing_active );

	if( !timing_active ) return;
		
	last_time = beg_time = time(0);
	HSlvhl_display_timing( (long)time(0) );
	}

/*---HSlvhl_update_timing------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_update_timing(void)
#else
	void	HSlvhl_update_timing()
#endif

	{
	if( !timing_active ) return;
	
	cur_time = time(0);
	
	if( (cur_time - last_time) >= 5 )
		{
		HSlvhl_display_timing( cur_time );
		last_time = cur_time;
		}
	}

/*---HSlvhl_fini_timing--------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HSlvhl_fini_timing(void)
#else
	void	HSlvhl_fini_timing()
#endif

	{
	if( !timing_active ) return;
	
	HSlvhl_display_timing( (long)time(0) );
	}

