/*
	I/VDS	Copy
*/
#ifndef v_string_include
#	define v_string_include

struct VD_s_Str2Index {
	char	*string ;
	int	index ;
} ;
typedef struct VD_s_Str2Index VD_str2index ;

struct VD_s_StrLink {
	VD_str2index		*entry ;
	struct VD_s_StrLink	*next ;
} ;

typedef struct VD_s_StrLink VD_strLink ;

#endif
