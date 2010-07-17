/*
	I/STRUCT
*/

#ifndef vsshdatproto_include
#	define vsshdatproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef vsdata_include
#	include "vsdata.h"
#endif

extern void
VSdumpSharedData		__((	int		count,
					VSdataDesc	list[] )) ;

extern void
VSfreeData			__((	int		count,
					VSdataDesc	list[] )) ;

extern long
VSpackData			__((	long		*msg,
					int		count,
					VSdataDesc	data[],
					char		**packet,
					VSdataLoc	**locationsInPacket,
					unsigned	*sizeOfPacket )) ;

extern long
VSgetDataMgr			__((	OMuword		dataMgrOs,
					OM_S_OBJID	*dataMgrId )) ;

extern long
VSgetSharedData			__((	long		*msg,
					OMuword		shDataOs,
					int		count,
					VSdataDesc	data[],
					OM_S_OBJID	*shDataId )) ;

#endif /* vsshdatproto_include */

