/*
	I/STRUCT
*/

#ifndef vsRDBproto_include
#	define vsRDBproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif

extern long
VSmkPartCachePathName		__((	long		*msg,
					char		*topdir,
					char		*material,
					char		*family,
					char		*part,
					char		*cacheName )) ;


extern long
VSgetMatsInDir			__((	long		*msg,
					OMuword		osnum,
					int		*p_count,
					char		***p_materials )) ;

extern long
VSgetCmpPrflFamsFromDir		__((	long		*msg,
					OMuword		osnum,
					char		*material,
					int		*p_count,
					char		***p_families )) ;

extern long
VSgetCmpPrflPrtsFromDir		__((	long		*msg,
					OMuword		osnum,
					char		*material,
					char		*family,
					int		*p_count,
					char		***p_parts )) ;

extern int
VSisLoggedIntoRDB		__((	void )) ;

extern void
VSgetMacDefFullName		__((	char		*macLib,
					char		*macDefBaseName,
					char		*macDefFullName )) ;

extern long
VSgetMacroNameFromPmacro	__((	char		*family,
					char		*material,
					char		*part,
					char		*macro_name	)) ;

#endif /* vsRDBproto_include */

