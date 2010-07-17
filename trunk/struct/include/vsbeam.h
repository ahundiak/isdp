/*
 *	I/STRUCT
 */

#ifndef vsbeam_include
#	define vsbeam_include

#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

/*
 * Used by GRgetattr and GRputattr.
 */
struct VS_s_BeamAttr {
	double	xoff,		/* x-offset				*/
		yoff,		/* y-offset				*/
		rotat ;		/* About beam axis			*/
	enum VScardinal_point	card ;
	enum VSsymmetry		sym ;
} ;
typedef struct VS_s_BeamAttr VSbeamAttr ;

#endif /* vsbeam_include */

