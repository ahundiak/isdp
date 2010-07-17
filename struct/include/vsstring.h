/*
	I/STRUCT
*/
#ifndef vsstring_include
#	define vsstring_include

struct VS_s_Str2Index {
	char	*string ;
	int	index ;
} ;
typedef struct VS_s_Str2Index VSstr2index ;

struct VS_s_StrLink {
	VSstr2index		*entry ;
	struct VS_s_StrLink	*next ;
} ;

typedef struct VS_s_StrLink VSstrLink ;

#endif
