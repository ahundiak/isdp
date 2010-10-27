/*
	I/VDS	Copy.
*/

#ifndef v_visedgproto_include
#	define v_visedgproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

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
#ifndef growner_include
#	include "growner.h"
#endif
#ifndef igr_include
#	include "igr.h"
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

extern long
VD_veRangeRangeRelationShip	__((	long		*msg,
					const GRrange 	range0,
					const GRrange	range1,
					const IGRvector	viewVector,
					int		*relationship )) ;

extern long
VD_veFindHiddenPartsOfCurveWithSolSurfs
				__((	long			*msg,
					const struct GRid	*cvId,
					const struct GRmd_env 	*cvEnv,
					int			nbSolSurf,
					const struct GRobj_env	*solSurfObj,
					const IGRvector		viewVector,
					int			*nb_part,
					double			**part_pt_s,
					double			**part_pt_e,
					double			**part_pm_s,
					double			**part_pm_e )) ;

#endif
