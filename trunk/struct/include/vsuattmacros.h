/*
	I/STRUCT
*/
#ifndef vsuattmacros_include
#	define vsuattmacros_include

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

/*+M
Macro vs$getActiveUsrAttr

Abstract
	Returns the active collection of user attributes.
Arguments
	OUT	long		*msg		Completion code.
	IN	GRname		basename	Base name (without path) of the
						active collection.
	OUT	struct GRid	*p_activeUA	Id of collection.
Note
	If there is no active collection, the macro returns with success but
	`p_activeUA->objid' is set to NULL_OBJID.
-M*/
extern long
VSgetActiveUsrAttr		__((	long		*msg,
					GRname		basename,
					struct GRid	*p_activeUA )) ;

#omdef vs$getActiveUsrAttr( msg, basename, p_activeUA )
	VSgetActiveUsrAttr( (msg), (basename), (p_activeUA) )
#endomdef

/*+M
Macro vs$makeActiveUsrAttr

Abstract
	Create a collection of user attributes and makes it the active one,
	replacing the previous active one if any.
Abstract
	OUT	long		*msg		Completion code.
	IN	GRname		basename	Base name (without path) of the
						collection to be created.
	IN	int		nbEntries	Count of entries in collection.
	IN	char		*names[]	Array of entry names.
	IN	char		*syntaxes[]	Array of entry syntaxes.
	OUT	struct GRid	*p_activeUA	Id of newly created collection
						become the active one.
Note
	If one of the entries has a bad name or syntax, the collection is not
	created and the active collection is still the previous one.
	One will be able to retrieve this collection with the macro
	`vs$getActiveUsrAttr' with the base name which was used for creation.
	All collections of user attributes are created in the active design.
-M*/
extern long
VSmakeActiveUsrAttr		__((	long		*msg,
					GRname		basename,
					int		nbEntries,
					char		*names[],
					char		*syntaxes[],
					struct GRid	*p_activeUA )) ;

#omdef vs$makeActiveUsrAttr(	msg,
				basename,
				nbEntries,
				names,
				syntaxes,
				p_activeUA )
	VSmakeActiveUsrAttr(	(msg),
				(basename),
				(nbEntries),
				(names),
				(syntaxes),
				(p_activeUA) )
#endomdef

/*+M
Macro vs$getUsrAttrContent

Abstract
	Gets the content (names and syntaxes) of a collection of user
	attributes.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*UAid		Id of collection.
	OUT	int		*p_size		Count of entries in collection.
	OUT	char		***p_names	Array of entry names.
	OUT	char		***p_syntaxes	Array of entry syntaxes.
Note
	The memory allocated must be freed with:
		VSfreeList( size, *p_names ) ;
	and	VSfreeList( size, *p_syntaxes ) ;
-M*/
extern long
VSgetUsrAttrContent		__((	long		*msg,
					struct GRid	*UAid,
					int		*p_size,
					char		***p_names,
					char		***p_syntaxes )) ;

#omdef vs$getUsrAttrContent( msg, UAid, p_size, p_names, p_syntaxes )
	VSgetUsrAttrContent( (msg), (UAid), (p_size), (p_names), (p_syntaxes) )
#endomdef

#endif
