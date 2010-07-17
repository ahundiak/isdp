/*
	I/STRUCT
*/ 
class implementation VSimgFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method NDdrawing_copy_geom(	struct GRid	*selected_elements ;
				int		nb_elements ;
				struct GRid	**drawing_elements ;
				int		*nb_drawing_elem ;
				double		*vector,
						*point ;
				int		*levelMask ;
				struct IGRlbsys *lbsys ;
				struct GRmd_env *from_env,
						*to_env ) {

	long		sts ;
	long		msg ;
	struct GRid	model ;

	sts = om$send(	msg	= message ACheader.ACfind_model( &msg, &model ),
			targetid= my_id ) ;
	__CheckRC( sts, msg, "ACheader.ACfind_model", wrapup ) ;

	sts = om$send(	msg	= message NDnode.NDdrawing_copy_geom(
							selected_elements,
							nb_elements,
							drawing_elements,
							nb_drawing_elem,
							vector,
							point,
							levelMask,
							lbsys,
							from_env,
							to_env ),
			targetid= model.objid,
			targetos= model.osnum ) ;

	wrapup :
		return sts ;

} /* method NDdrawing_copy_geom */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;

