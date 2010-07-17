/*
	I/STRUCT
*/
#ifndef vsipthmacros_include
#	define vsipthmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vspart_include
#	include "vspart.h"
#endif

/*+M
Macro vs$getCmpIndexPath

Abstract
	Given an owner and one of its (sub-)components, finds the index path
	(ie. an array of indices on the to-components channel) from the owner
	to the (sub-)component.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*owner		Owner of (sub-)component.
	IN	struct GRid	*component	(Sub-)component.
	OUT	int		*p_size		Size of array of indices.
	OUT	int		ipath[SIZE]	Array of indices.
Note
	`SIZE' must be >= VS_K_MAXOWNDEPTH.
-M*/
extern long
VSgetCmpIndexPath		__((	long		*msg,
					struct GRid	*owner,
					struct GRid	*component,
					int		*p_size,
					int		ipath[] )) ;

#omdef vs$getCmpIndexPath( msg, owner, component, p_size, ipath )
	VSgetCmpIndexPath( (msg), (owner), (component), (p_size), (ipath) )
#endomdef

/*+M
Macro vs$getCmpIdFromIpath

Abstract
	Given an owner and an index path, gets the id of the sub-component.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*owner		Owner of (sub-)component.
	IN	int		size		Size of array of indices.
	IN	int		ipath[SIZE]	Array of indices.
	OUT	struct GRid	*component	(Sub-)component.
Note
	`SIZE' must be >= VS_K_MAXOWNDEPTH.
-M*/
extern long
VSgetCmpIdFromIpath		__((	long		*msg,
					struct GRid	*owner,
					int		size,
					int		ipath[],
					struct GRid	*component )) ;

#omdef vs$getCmpIdFromIpath( msg, owner, size, ipath, component )
	VSgetCmpIdFromIpath( (msg), (owner), (size), (ipath), (component) ) 
#endomdef

/*+M
Macro vs$getSubCmpCount

Abstract
	Returns the count of components and sub-components in an ownership
	tree.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*owner		Owner of (sub-)components.
	OUT	int		*count		Count of sub-components.
-M*/
extern long
VSgetSubCmpCount		__((	long		*msg,
					struct GRid	*owner,
					int		*count )) ;

#omdef vs$getSubCmpCount( msg, owner, count )
	VSgetSubCmpCount( (msg), (owner), (count) )
#endomdef

/*+M
Macro vs$getSubComponents

Abstract
	Returns the list of components and sub-components in an ownership
	tree.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*owner		Owner of (sub-)components.
	OUT	struct GRid	list[]		List of sub-components.
Note
	Use `vs$getSubCmpCount' to allocate the memory for `list'.
-M*/
extern long
VSgetSubComponents		__((	long		*msg,
					struct GRid	*owner,
					struct GRid	list[]	)) ;

#omdef vs$getSubComponents( msg, owner, list )
	VSgetSubComponents( (msg), (owner), (list) )
#endomdef

/*+M
Macro vs$getIPATHsandIDs

Abstract
	Returns the count of elements of an ownership graph as well as their
	ids and IPATHs.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*owner		Top of ownership graph.
	IN	int		ownerIndex	Index of owner if itself a
						component.
	OUT	int		*count		Count of (sub-)components.
	OUT	VSipathANDid	**p_list	List of IPATHs and ids of
						(sub-)components.
Note
	If `ownerIndex' is specified, it will be added in front of every IPATH
	in the list; this is to handle the case when `owner' is itself a
	component and one wishes the path to be from owner's owner downwards.
	`*p_list' is malloc'ed: it is up to the caller to free it.
-M*/
extern long
VSgetIPATHsandIDs		__((	long		*msg,
					struct GRid	*owner,
					int		ownerIndex,
					int		*count,
					VSipathANDid	**p_list ))  ;

#omdef vs$getIPATHsandIDs(	msg,
				owner,
				ownerIndex = VS_K_NULL_INDEX,
				count,
				p_list )
	VSgetIPATHsandIDs( (msg), (owner), (ownerIndex), (count), (p_list) )
#endomdef

#endif
