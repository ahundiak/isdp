/*
 * I/STRUCT
 */

#ifndef vspart_include
#	define vspart_include

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
#endif

/*
 * Type of conversion of the index of a part (sub-) component.
 */
enum VS_e_cmpixtype {
			VS_e_real_to_virtual,
			VS_e_virtual_to_real
} ;
typedef enum VS_e_cmpixtype VScmpixtype ;

#define	VS_K_INV_POS_NUMBER	(-1.)
#define VS_K_INV_COORDINATE	(GRDGNLIMITS_MAX_D + 1.)
/*
 * Integral properties of part: volume, area, centroid, inertia, etc.
 * area, volume, dims[0] = VS_K_INV_POS_NUMBER if not set.
 * Iuv (u,v = x,y,z) and centroid[0] = VS_K_INV_COORDINATE if not set
 */
struct VS_S_integral {
	double	area,
		volume,
		mass ;
		union {
			struct {
				double	Ixx,
					Iyy,
					Izz,
					Ixy,
					Iyz,
					Izx ;
			} element ;
			double array[6] ;
		} MofI ;
	double	dims[3] ;
	IGRpoint
		centroid ;
} ;		
typedef struct VS_S_integral VSintegral ;	

/*
 * Orientation definition (no/natural/reverse)
 */
#define VS_K_NoOrient	0
#define VS_K_NatOrient	1
#define VS_K_RevOrient	2

/*
 * Maximum depth allowed for ownership graph.
 */
#define	VS_K_MAXOWNDEPTH	10

/*
 * Index path of a (sub-)component of a part.
 */
struct VS_s_ixPath {
	int	ls[VS_K_MAXOWNDEPTH],
		sz ;
} ;
typedef struct VS_s_ixPath VSixPath ;

/*
 * Index + id of a (sub-)component of a part.
 */
struct VS_s_IPATHandID {
	struct GRid	id ;
	VSixPath	ip ;
} ;

typedef struct VS_s_IPATHandID VSipathANDid ;

#endif /* vspart_include */

