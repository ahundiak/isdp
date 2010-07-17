/* $Id: vsjoint.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/include/vsjoint.h 
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsjoint.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1997/12/18  13:35:20  pinnacle
 * Replaced: include/vsjoint.h for:  by svkadamb for struct
 *
 * Revision 1.2  1997/11/14  12:38:08  pinnacle
 * Replaced: include/vsjoint.h for:  by svkadamb for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT

	File dependency	:	vs.h
				vsjointdef.h
				vsweld.h
*/
#ifndef vsjoint_include
#	define vsjoint_include

#ifndef vs_include
#	include "vs.h"
#endif
#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif
#ifndef vsjointdef_include
#	include "vsjointdef.h"
#endif
#ifndef vsweld_include
#	include "vsweld.h"
#endif

/*
 * Used by GRgetattr and GRputattr.
 */
struct VS_s_JointAttr {
	double		allowance,
			grooveAngle,
			pitch,
			incrLength,
			size,
			shrinkage ;
	VSweldAttr	weldAttr ;
	VSaddWldAttr	addWldAttr ;
	char		usrSymbol[VS_K_MAXUSRSYMSZ] ;
} ;
typedef struct VS_s_JointAttr VSjointAttr ;

/*
 * Joining information.
 * action	: join results of division together, joint each result with
 *		  operator of division.
 * cst		: construction lists for first joint, and second joint
 *		  (if relevant).
 * rep		: display representations for first joint, and second joint
 *		  (if relevant).
 * dir		: directory where joints will name themselves (may be NULL:
 *		  joints will no have names).
 */
struct VS_s_joinInfo {
	int			action ;
	struct GRvg_construct	cst[2] ;
	VSdspRep		rep[2] ;
	char			*dir ;
} ;
typedef struct VS_s_joinInfo VSjoinInfo ;

/*
 * Sub-joint construction information.
 * divFeature	: divided feature upon one of the sub-feature of which a
 *		  sub-joint between the latter and the other feature must be
 *		  placed.
 * otherFeature	: that mentioned above.
 * dir		: directory where sub-joints will name themselves (may be NULL:
 *		  sub-joints will no have names).
 */
struct VS_s_subJointInfo {
	struct GRobj_env	divFeature,
				otherFeature ;
	char			*dir ;
} ;
typedef struct VS_s_subJointInfo VSsubJointInfo ;

/*
 * t0start	: parameters of start points on curve 0.
 * t0end	: parameters of end   points on curve 0.
 * t1start	: parameters of start points on curve 1.
 * t1end	: parameters of end   points on curve 1.
 * count	: count of overlaps.
 * code		: type of overlap :
 *			VS_K_NO_OVERLAP
 *			VS_K_COMMON_PORTION
 *			VS_K_0_COVERS_1
 *			VS_K_1_COVERS_0
 *			VS_K_TOTAL_MATCH
 *			( #define in vsjointdef.h. If `code' VS_K_NO_OVERLAP,
 *			  then `endPoints', `t0', `t1' are not relevant. )
 * NOTE : the memory for `t0start', `t0end', `t1start', `t1end' is malloc'ed,
 * but ONLY `t0start' must be freed, the others point to memory contained in
 * that pointed to by `t0start'.
 */
struct VS_s_overlapInfo {
	double		*t0start,
			*t0end,
			*t1start,
			*t1end ;
	int		count,
			code ;
} ;
typedef struct VS_s_overlapInfo VSoverlapInfo ;

/*
 * List of (partially or totally) matching edges.
 * edge0	: id of matching edge of surface 0.
 * edge1	: id of matching edge of surface 1.
 * edgeGeom0	: geometry of matching edge of surface 0.
 * edgeGeom1	: geometry of matching edge of surface 1.
 * matchInfo	: detail of matching.
 * next		: next entry (this structure used for linked list).
 */
struct VS_s_matchingEdges {
	VSoverlapInfo			matchInfo ;
	struct GRid			edgeId0,
					edgeId1 ;
	struct IGRbsp_curve		*edgeGeom0,
					*edgeGeom1 ;
	struct VS_s_matchingEdges	*next ;
} ;
typedef struct VS_s_matchingEdges VSmatchingEdges ;

#endif
