
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsncdef_include
#define hsncdef_include 1

/*
 * hsncdef.h contains HSURF-NC Verification definitions.
 */


/*
 * Display mode flags.
 */

#define HSNC_SWVOL		1
#define HSNC_SWVOL_TOOL		2
#define HSNC_SIMULATION		3


/*
 * Simulation speed values.
 */

#define HSNC_MIN_SIM_SPEED 	1
#define HSNC_MAX_SIM_SPEED 	16
#define HSNC_DEFAULT_SIM_SPEED 	4


/*
 * Shading style flags.
 */

#define HSNC_SMOOTH_SHADED 	1
#define HSNC_CONSTANT_SHADED 	2


/*
 * Display list values.
 */

#define HSNC_DISP_LIST_SIZE	512
#define	HSNC_USE_GLOBAL_SPEED	-1
#define	HSNC_USE_TOOL_COLOR	-1
#define HSNC_USE_TOOL_TRANS	-1

/*
 * Macro return codes.
 */

#define HSNC_SUCCESS		0
#define HSNC_FAILURE		1

#endif
