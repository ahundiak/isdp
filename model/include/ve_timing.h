
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef ve_timing_include
#define ve_timing_include 1

/*
DESCRIPTION
	Define TIMING as 1 and re-compile VE if you want execution
	time and time spent in individual functions

HISTORY
	S.P. Rogers  09/19/88  Creation Date
*/

#define TIMING 0

#if TIMING
#include "sys/types.h"
#include "sys/times.h"
#endif

#endif
