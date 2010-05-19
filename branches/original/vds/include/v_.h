/*
 	I/VDS	Copy.
*/
#ifndef v_include
#	define v_include

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef	gr_include
#	include "gr.h"
#endif
#ifndef growner_include
#	include "growner.h"
#endif


/*
 * Type of display representation.
 */
typedef unsigned char VD_dspRep ;

/*
 * Trial flags for joint search between surfaces.
 */
#define VD_K_NO_OVERLAP         0
#define VD_K_COMMON_PORTION     1
#define VD_K_0_COVERS_1         2
#define VD_K_1_COVERS_0         3
#define VD_K_TOTAL_MATCH        4


/*
 * t0start	: parameters of start points on curve 0.
 * t0end	: parameters of end   points on curve 0.
 * t1start	: parameters of start points on curve 1.
 * t1end	: parameters of end   points on curve 1.
 * count	: count of overlaps.
 * code		: type of overlap :
 *			VD_K_NO_OVERLAP
 *			VD_K_COMMON_PORTION
 *			VD_K_0_COVERS_1
 *			VD_K_1_COVERS_0
 *			VD_K_TOTAL_MATCH
 *			( #define in v_jointdef.h. If `code' VD_K_NO_OVERLAP,
 *			  then `endPoints', `t0', `t1' are not relevant. )
 * NOTE : the memory for `t0start', `t0end', `t1start', `t1end' is malloc'ed,
 * but ONLY `t0start' must be freed, the others point to memory contained in
 * that pointed to by `t0start'.
 */
struct VD_s_overlapInfo {
	double		*t0start,
			*t0end,
			*t1start,
			*t1end ;
	int		count,
			code ;
} ;
typedef struct VD_s_overlapInfo VD_overlapInfo ;

/*
 * List of (partially or totally) matching edges.
 * edge0	: id of matching edge of surface 0.
 * edge1	: id of matching edge of surface 1.
 * edgeGeom0	: geometry of matching edge of surface 0.
 * edgeGeom1	: geometry of matching edge of surface 1.
 * matchInfo	: detail of matching.
 * next		: next entry (this structure used for linked list).
 */
struct VD_s_matchingEdges {
	VD_overlapInfo			matchInfo ;
	struct GRid			edgeId0,
					edgeId1 ;
	struct IGRbsp_curve		*edgeGeom0,
					*edgeGeom1 ;
	struct VD_s_matchingEdges	*next ;
} ;
typedef struct VD_s_matchingEdges VD_matchingEdges ;

/*
 * Symmetry codes
 */
enum VD_symmetry {
                        VD_e_No_Symm    = 0,
                        VD_e_X_Symm     = 1,
                        VD_e_Y_Symm     = 2,
                        VD_e_XY_Symm    = 3
} ;


#endif
