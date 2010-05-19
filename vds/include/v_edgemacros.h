/*
	I/VDS	Copy
*/
#ifndef v_edgemacros_include
#	define v_edgemacros_include

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
#ifndef v_include
#	include "v_.h"
#endif
#ifndef vd_ve_include
#	include "vd_ve.h"
#endif

/*+M
Macro vd_$get_surface_edges

Abstract
	Returns the edges of a surface.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRid		*sfId		Id. of surface.
	IN	struct GRmd_env 	*sfEnv		Env. of surface.
	IN	int			edgeType	Edges wanted.
							( See v_edgedef.h for
							  more details ).
	OUT	int			*edCount	Count of edges.
	OUT	struct GRid		*edList[]	List of edges.
Note
	`*edList' is allocated and hence must be freed by the caller
	with `free( *edList )'.
-M*/
#omdef vd_$get_surface_edges( msg,
			     sfId,
			     sfEnv,
			     edgeType = VD_K_ALL_EDGES,
			     edCount,
			     edList )

       VD_getSurfaceEdges( (msg), (sfId), (sfEnv), (edgeType), (edCount),
			  (edList) )
#endomdef
extern long
VD_getSurfaceEdges		__((	long			*msg,
					struct GRid		*sfId,
					struct GRmd_env 	*sfEnv,
					int			edgeType,
					int			*edCount,
					struct GRid		**edList )) ;

/*+M
Macro vd_$get_graphic_edge

Abstract
	Returns the graphic object or the copy of the graphic object associated
	to an edge.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRid		*edId		Id. of edge.
	IN	struct GRmd_env 	*edEnv		Env. of edge.
	IN	int			copy		TRUE/FALSE.
	IN	struct GRmd_env 	*copyEnv	Env. of the copy.
	OUT	struct GRid		*grEdge 	Graphic object of edge.
Note
	If `copy' is TRUE, the macro returns a copy of the graphic object using
	the env. given by `copyEnv'. Otherwise the macro returns the graphic
	object itself (`copyEnv' may be NULL ).
-M*/
extern long
VD_getGraphicEdge		__((	long			*msg,
					struct GRid		*edId,
					struct GRmd_env 	*edEnv,
					int			copy,
					struct GRmd_env 	*copyEnv,
					struct GRid		*grEdge )) ;

#omdef vd_$get_graphic_edge( msg,
			    edId,
			    edEnv,
			    copy = FALSE,
			    copyEnv = NULL,
			    grEdge )

       VD_getGraphicEdge( (msg), (edId), (edEnv), (copy), (copyEnv), (grEdge) )
#endomdef


/*+M
Macro vd_$select_obj_comps

Abstract
	Returns the graphic components of an object.
Arguments
	OUT	long			*msg		Completion code.
	IN	int			option		Graphic Type.
	IN	int			count		Counts of graphcis.
	IN	struct GRid		grIds[]		Id. of graphics.
-OR-	IN	struct GRobj_env	objenvs[]	GRobj_envs of graphics.
	IN	struct GRmd_env 	*theEnv		Env. of graphics.
	OUT	struct VDve_elem_buf	*elmList 	Graphic components
Note
	'theEnv' must be specified for the 'grIds'. The 'elmList' can be
	a new list or an already used list of output of previous calls. New
	found components will be added to be existing list.
-M*/
extern long
VD_SelectCompsObj		__((	long			*msg,
					int			option,
					int			count,
					struct GRid		*grIds,
					struct GRobj_env	*objEnvs,
					struct GRmd_env 	*theEnv,
					struct VDve_elem_buf	*elmList )) ;

#omdef vd_$select_obj_comps(	msg,
				option	= VD_K_gm_ALL,
				count	= 1,
				grIds	= NULL,
				objEnvs	= NULL,
				theEnv	= NULL,
				elmList )

       VD_SelectCompsObj( (msg), (option), (count),
				(grIds), (objEnvs), (theEnv), (elmList) )
#endomdef

#endif
