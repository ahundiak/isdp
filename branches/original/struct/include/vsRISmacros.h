/*
	I/STRUCT
*/
#ifndef vsRISmacros_include
#	define vsRISmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

extern int
VdsRisSelect		__((	char            *select,
				char            *table,
				char            *where,
				char            *order,
				char            *group,
				char            *having,
				int             nbatt,
				int             *p_count,
				char            **p_list[] )) ;

#omdef vs$RISquery(	table,
			select,
			where	= NULL,
			nbAttrs	= 1,
			p_count,
			p_list )

	VdsRisSelect(	(select),
			(table),
			(where),
			(NULL),
			(NULL),
			(NULL),
			(nbAttrs),
			(p_count),
		   	(p_list) )
#endomdef

extern int
VdsRisExtractValue	__((	int     count,
				int     nbAttrs,
				char    **list,
				int     whichVal,
				int     whichAttr,
				char    *value )) ;

#omdef vs$RISextractVal(	count,
				list,
				nbAttrs		= 1,
				whichAttr	= 0,
				whichVal,
				value )

	VdsRisExtractValue(	(count),
				(nbAttrs),
				(list),
				(whichVal),
				(whichAttr),
				(value) )
#endomdef

#endif
