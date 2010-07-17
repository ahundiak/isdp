/*
	I/STRUCT

	File dependency : vsridef.h
*/
#ifndef vsri_include
#	define vsri_include

struct PARDEF {
	double	value ;
	char	name[MAX_PAR_LEN+1] ;
} ;

enum READRC {	nothingToRead,
		readError,
		missingItem,
		badFormat,
		readOK
} ;

#endif
