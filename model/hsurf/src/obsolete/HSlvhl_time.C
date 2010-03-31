#include "hsurf_import.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>

#include "igrtypedef.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"

#include "vemsg.h"

static long	beg_time;
static long	cur_time;
static long	last_time;


/*---HSdisplay_lvhl_timing-----------------------------------*/

void	HSdisplay_lvhl_timing( this_time )

long	this_time;

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

/*---HSinit_lvhl_timing--------------------------------------*/

void	HSinit_lvhl_timing()

	{
	last_time = beg_time = time(0);
	HSdisplay_lvhl_timing( (long)time(0) );
	}

/*---HSupdate_lvhl_timing------------------------------------*/

void	HSupdate_lvhl_timing()

	{
	cur_time = time(0);
	
	if( (cur_time - last_time) >= 5 )
		{
		HSdisplay_lvhl_timing( cur_time );
		last_time = cur_time;
		}
	}

/*---HSfini_lvhl_timing--------------------------------*/

void	HSfini_lvhl_timing()

	{
	HSdisplay_lvhl_timing( (long)time(0) );
	}

