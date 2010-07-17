/*
	I/STRUCT
*/
#ifndef vsnamemacros_include
#	define vsnamemacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

/*+M
Macro vs$isDirUsable

Abstract
	Checks that a directory is valid for object naming after creation, ie.
	that the directory is in the active design file and is writable.
Arguments
	IN	char	*dirname	Name of directory.
	OUT	int	*isHere		Does directory exist ? (TRUE/FALSE)
	OUT	int	*inModel	Is in active design file ? (TRUE/FALSE)
	OUT	int	*writable	Is writable ? (TRUE/FALSE)
-M*/
extern long
VSisDirUsable			__((	char	*dirname,
					int	*isHere,
					int	*inModel,
					int	*writable )) ;

#omdef vs$isDirUsable(	dirname,
			isHere 	= NULL,
			inModel	= NULL,
			writable= NULL )
	 VSisDirUsable( (dirname), (isHere), (inModel), (writable) )
#endomdef

#endif
