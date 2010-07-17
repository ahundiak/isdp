/*
	I/STRUCT
*/
class specification VSsharedData(0:0) of NDnodein ;

#ifndef _LIMITS_H
#	include <limits.h>
#endif
#ifndef vsdatadef_include
#	include "vsdatadef.h"
#endif
#ifndef vsdata_include
#	include "vsdata.h"
#endif

/*+c
	Objects of this class work hand in hand with objects of class
	"VSdataMgr". They store data (integers, doubles and strings) packed
	in a VLA. Since the way data are written to disk is machine-dependent
	(the bytes may be reversed on some machines), to convert from one
	machine to another, the VLA must be unpacked in one machine format
	an repacked in the other machine's format.
-c*/

instance VSsharedData {
	variable char		data[0] ;
	variable VSdataLoc	loc [0] ;
	channel	{
			( many_to_one ) VSdataMgr.toSharedData ;

	} toDataMgr ;
} ;

override
	debug,

/*+o
Message NDcopy_to_root

Abstract
	Sends message NDcopy of NDnode to self.
Arguments
	See message NDcopy_to_root of class NDnode.
-o*/
	NDcopy_to_root,

/*+o
Message NDgive_structure

Abstract
	Only returns the type of the object.
Arguments
	See message NDgive_structure of class NDnode.
-o*/
	NDgive_structure,

/*+o
Message ASreturn_go

Abstract
	Just returns this object.
Arguments
	See message ASreturn_go of class NDnode.
-o*/
	ASreturn_go  ;

/*+d
Message VSputData

Abstract
	Feeds data into the object. The list of data is specified in `list'
	and their number in `count'.
	Each element of list specifies the data type, data value and data
	index. When all data are set the index in `list[i]' is `i'.
	Indices must start from 0 by step of 1.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		count		Of data to set.
	IN	VSdataDesc	list[]		Of data.
Notes
	Formatting the object the first time:

	VSdataDesc list[2] ;

	list[0].type	= VSdouble ;
	list[0].index	= 0 ;
	list[0].value.d	= 3.14 ;
	list[1].type	= VSstring ;
	list[1].index	= 1 ;
	list[1].value.d	= "abc" ;

-d*/
message	VSputData(	long		*msg ;
			int		count;
			VSdataDesc	list[] ) ;

/*+d
Message VSgetData

Abstract
	Gets data from the object. The list of wanted data is specified in
	`list' and their number in `count'.
	Each element of list specifies the data type, data value and data
	index. When all data are to be gotten the index in `list[i]' is `i'.
	It is different when only some of the data are wanted.
	Indices must start from 0 by step of 1.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		count		Of data to get.
	OUT	VSdataDesc	list[]		Of data.
Notes
	Getting all data form the object (say there is two):

	VSdataDesc list[2] ;

	list[0].index	= 0 ;
	list[1].index	= 1 ;

	Then to get item #1 only:

	list[0].index	= 1 ;

	The memory needed to store the items must be freed as follows

		extern void VSfreeData() ;

		VSfreeData( count, list ) ;
-d*/
message	VSgetData(	long		*msg ;
			int		count;
			VSdataDesc	list[] ) ;

/*+d
Message VSgetMemoryContent

Abstract
	Returns the memory containing the data of the object (those which
	have been stored with a `VSputData' message). The pads between data
	are filled with 0s so that memory area may be compared.
Arguments
	OUT	long		*msg		Completion code.
	OUT	int		*size		Size in bytes of memory.
	OUT	char		**content	Content of memory.
Notes
	if `*size' is 0, then `*content' is NULL, else `*contents' must be freed
	by the caller with :

				_FREE( *content ) ;
-d*/
message VSgetMemoryContent(	long	*msg ;
				int	*size ;
				char	**content ) ;

end specification VSsharedData ;
