/*
	I/STRUCT
*/
#ifndef vsbtchctsdef_include
#define vsbtchctsdef_include

#define VS_K_MAX_OPNDS	30
#define VS_K_MAX_OPTRS	30

#define VS_K_opndKyWord	"~~operand"
#define VS_K_optrKyWord	"~~operator"

#define VS_K_MAP_SEP	'~'
#define VS_K_END_OF_MAP	(-1)
#define VS_K_MAP_ALL	(-2)

struct VS_s_oprtrOprndMap {
	char	oprndIndices[VS_K_MAX_OPNDS],
		oprtrName[30] ;
} ;
typedef struct VS_s_oprtrOprndMap VSoprtrOprndMap ;

#endif
