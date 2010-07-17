/*
	I/STRUCT
*/
#ifndef vsedgemacros_include
#	define vsedgemacros_include

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

/*+M
Macro vs$get_surface_edges

Abstract
	Returns the edges of a surface.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRid		*sfId		Id. of surface.
	IN	struct GRmd_env 	*sfEnv		Env. of surface.
	IN	int			edgeType	Edges wanted.
							( See vsedgedef.h for
							  more details ).
	OUT	int			*edCount	Count of edges.
	OUT	struct GRid		*edList[]	List of edges.
Note
	`*edList' is allocated and hence must be freed by the caller
	with `free( *edList )'.
-M*/
#omdef vs$get_surface_edges( msg,
			     sfId,
			     sfEnv,
			     edgeType = VS_K_ALL_EDGES,
			     edCount,
			     edList )

       VSgetSurfaceEdges( (msg), (sfId), (sfEnv), (edgeType), (edCount),
			  (edList) )
#endomdef
extern long
VSgetSurfaceEdges		__((	long			*msg,
					struct GRid		*sfId,
					struct GRmd_env 	*sfEnv,
					int			edgeType,
					int			*edCount,
					struct GRid		**edList )) ;

/*+M
Macro vs$get_graphic_edge

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
VSgetGraphicEdge		__((	long			*msg,
					struct GRid		*edId,
					struct GRmd_env 	*edEnv,
					int			copy,
					struct GRmd_env 	*copyEnv,
					struct GRid		*grEdge )) ;

#omdef vs$get_graphic_edge( msg,
			    edId,
			    edEnv,
			    copy = FALSE,
			    copyEnv = NULL,
			    grEdge )

       VSgetGraphicEdge( (msg), (edId), (edEnv), (copy), (copyEnv), (grEdge) )
#endomdef

#endif
