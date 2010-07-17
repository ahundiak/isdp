/*
	I/STRUCT
	File dependency : vssectiondef.h
*/
#ifndef vsprofmacros_include
#	define vsprofmacros_include

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
Macro vs$getComponentDescr

Abstract
	Returns an array of message keys of ASCII messages describing the
	available meaning for the component curves of a graphic cross-section
	(profile) curve. This description will also be those of the faces of
	the beam generated with this profile.
Arguments
	OUT	long	*msg		Completion code.
	OUT	long	descrKeys[VS_K_sc_MAXFACES]
					Array of message keys describing the
					components (abbreviated).
	OUT	long	ldescrKeys[VS_K_sc_MAXFACES]
					Array of message keys describing the
					components (full description).
					Optional: may be set to NULL.
Notes
	Indices for `descrKeys' are defined in "vssectiondef.h", E.g. the
	description of the left web will be `descrKeys[VS_K_sc_WebL]'.
-M*/
extern long
VSgetCmpDescr			__((	long	*msg,
					long	descrKeys[],
					long	ldescrKeys[] )) ;

#omdef vs$getComponentDescr( msg, descrKeys, ldescrKeys = NULL )
	VSgetCmpDescr( (msg), (descrKeys), (ldescrKeys) )
#endomdef

/*+M
Macro vs$moveGRccToXSection

Abstract
	Given an EMS composite curve (GRcompcurve) and an array to assign user
	indices to the components, transforms the EMS composite curve into
	a cross-section curve.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*GRccId		Id of EMS composite curve.
	IN	int		usrIndex[]	Array of user indices.
Note
	See message VSinitMap of class VScompcurve for more details on
	`usrIndex'.
	Upon successful completion the object `GRccId' has changed classes.
-M*/
extern long
VSmoveGRccToVSxs		__((	long		*msg,
					struct GRid	*GRccId,
					int		usrIndex[] )) ;

#omdef vs$moveGRccToXSection( msg, GRccId, usrIndex )
	VSmoveGRccToVSxs( (msg), (GRccId), (usrIndex) )
#endomdef

/*+M
Macro vs$moveAGccToXSection

Abstract
	Given an Associative Geometry composite curve (AScompcurve) and an
	array to assign user indices to the components, transforms the
	Associative Geometry composite curve into a cross-section curve.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*AGccId		Id of A.G. composite curve.
	IN	int		usrIndex[]	Array of user indices.
Note
	See message VSinitMap of class VScompcurve for more details on
	`usrIndex'.
	Upon successful completion the object `AGccId' has changed classes.
-M*/
extern long
VSmoveAGccToVSxs		__((	long		*msg,
					struct GRid	*AGccId,
					int		usrIndex[] )) ;

#omdef vs$moveAGccToXSection( msg, AGccId, usrIndex )
	VSmoveAGccToVSxs( (msg), (AGccId), (usrIndex) )
#endomdef

#endif
