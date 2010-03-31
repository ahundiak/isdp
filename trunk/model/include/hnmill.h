
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

/*
 * NC_mill.h contains structures and definitions needed by the NC Verification
 * command object interface.
 */

/*
 * NC toolpath typedefs. 	07/15/88 	KMJ	created
 */

typedef	char		int8;
typedef unsigned char	uint8;
typedef short		int16;
typedef	unsigned short	uint16;
typedef	int		int32;
typedef unsigned int	uint32;
typedef float		real32;
typedef double		real64;


/* 
 * NC toolpath command defs. 	07/23/88 	CMJ	created	
 *				09/06/88	KMJ	added toolholder
 */

#define NC_TOOLPATH_COMMAND	(uint8)64
#define NC_SET_TOOL		(uint8)0
#define NC_SET_TOOL_ORIENTATION	(uint8)1
#define NC_SET_3AX_SUB_TOOLPATH	(uint8)2
#define NC_SET_ARC_SUB_TOOLPATH	(uint8)3
#define NC_SET_TOOLHOLDER	(uint8)4
#define NC_END_TOOLPATH		(uint8)5
#define NC_SET_5AX_SUB_TOOLPATH	(uint8)6


/*
 * ShadedNC condition flags.	07/23/88	CMJ	created
 */
 
#define SNC_INIT		0 	/* Command to initialize the NCmilling structures */
#define SNC_CHGMODE		1	/* Command to change only those flags which
					      are allowed to change during execution */
#define SNC_EXECUTE		2	/* Command to (continue to) execute the toolpath */
#define SNC_CLEANUP		3	/* Command to cleanup all memory */
#define SNC_CHGMODES		4	/* Same as SNC_CHGMODE, with the addition of speed */

#define SNC_OK			10	/* Status: finished current step (no error) */
#define SNC_FINISHED		11	/* Status: finished execution */

#define SNC_ERROR		12	/* Status: error encountered during execution */
#define SNC_DLERR		13	/* Status: error in display list */
#define SNC_BIGENV		14	/* Status: out of memory: env obj set too large */
#define SNC_BIGTOOL		15	/* Status: out of memory: tool too large */
#define SNC_NOMEM		16	/* Status: out of memory */


/*
 * NURB curve/surface flags	07/23/88	KMJ	created
 */

#define CV_PERIODIC_M		0x0001
#define CV_NON_UNIFORM_M	0x0002
#define CV_RATIONAL_M		0x0004
#define CV_PLANAR_M		0x0008
#define CV_PHY_CLOSED_M		0x0010

#define SF_U_PERIODIC_M		0x0001
#define SF_V_PERIODIC_M		0x0002
#define SF_U_NON_UNIFORM_M	0x0004
#define SF_V_NON_UNIFORM_M	0x0008
#define SF_RATIONAL_M		0x0010
#define SF_PLANAR_M		0x0020
#define SF_U_CLOSED_M		0x0040
#define SF_V_CLOSED_M		0x0080
#define SF_ORIENTATION_M	0x0100
#define SF_SOLID_HOLE_M		0x0200


/*
 * Local NC Verification modes structure.
 */

struct HSNC_mode_parms
	{
	IGRboolean		single_step;		/* toolpath execution mode	*/
	IGRint			display_mode;		/* toolpath display mode	*/
	IGRint			simulation_speed;	/* simulation mode step size	*/
	IGRint			shading_style;		/* dexel shading style		*/
	};


/*
 * Local NC Verification return structure.
 */

struct HSNC_return_parms
	{
	struct IGRbsp_curve	*tool;			/* tool curve definition	*/
	IGRdouble		rotation[3][3];		/* tool rotation matrix		*/
	IGRpoint		location;		/* current tool location	*/
	};

