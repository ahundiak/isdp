/*
	I/STRUCT
*/
class specification VSdataMgr(0:0) of global_class ;

#ifndef _LIMITS_H
#	include <limits.h>
#endif
#include "vsdatadef.h"
#include "vsdata.h"

/*+c
	Objects of this class manage data shared by several objects residing
	in the same Object Space. There is one such object per Object Space.
	The shared data managed by this objects are data collections of class
	VSsharedData.

	`vs$getDataMgr' #define'd in "vsdatamacros.h" must be used to
	construct or retrieve the data manager associated with an Object Space.
-c*/
instance VSdataMgr {
	channel	{
			(	one_to_many,
				rel_ordered,
				initial		= 1,
				increment	= 1 ) VSsharedData.toDataMgr ;
	} toSharedData ;
} ;

override
	debug ;

/*+d
Message VSgetCollection

Abstract
	Given a list of data, returns a collection of shared data, being either
	new and formatted or already existing and containing the same data
	as those input.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		count		Of data for collection.
	IN	VSdataDesc	data[]		List of data for collection.
	OUT	OM_S_OBJID	*collection	The created/found collection.
Note
	The returned collection lives in the same Object Space as the object
	target of this message.
	The returned collection should never be deleted. The system handles
	the destruction of no longer needed collections, ie. collections
	which have no children any longer.
-d*/
message VSgetCollection(	long		*msg ;
				int		count;
				VSdataDesc	data[] ;
				OM_S_OBJID	*collection ; ) ;

/*+d
Message VSfindCollection

Abstract
	Given a list of data, looks for an existing collection of shared data
	containing the same data as those input.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		count		Of data to compare.
	IN	VSdataDesc	data[]		List of data to compare.
	OUT	OM_S_OBJID	*collection	The found collection (NULL_OBJID
						if not found).
	OUT	int		*index		Index of collection if found
						or index where a new collection
						must be inserted if not found.
-d*/
message VSfindCollection(	long		*msg ;
				int		count;
				VSdataDesc	data[] ;
				OM_S_OBJID	*collection ;
				int		*index ) ;

/*+d
Message VSfindCollection

Abstract
	Inserts a collection on the channel (private message).
Arguments
	OUT	long		*msg		Completion code.
	IN	OM_S_OBJID	collection	Collection to insert.
	IN	int		index		Index of insertion.
-d*/
message VSinsertCollection(	long		*msg ;
				OM_S_OBJID	collection ;
				int		index ) ;

end specification VSdataMgr ;

