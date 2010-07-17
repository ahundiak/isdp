/*
	I/STRUCT
*/
#ifndef vsslrc_include
#	define vsslrc_include

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
#endif
#ifndef growner_include
#	include "growner.h"
#endif
#ifndef igr_include
#	include "igr.h"
#endif
#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef godef_include
#	include "godef.h"
#endif
#ifndef go_include
#	include "go.h"
#endif
#ifndef vsslcdef_include
#	include "vsslcdef.h"
#endif

typedef char	VStktxt[VS_K_tokMAX_SIZE] ;

struct VS_s_parseErr {
	long	msg ;
	int	lineno,
		charno ;
	VStktxt	string ;
} ;
typedef struct VS_s_parseErr VSparseErr ;

struct VS_s_array {
	unsigned short		size ;
	struct VS_s_execRes	*element ;
} ;
typedef struct VS_s_array VSarray ;

union VS_u_allTypes {
		double			dval ;
		int			ival ;
		VStktxt			sval ;
		struct GRobj_env	oval ;
		VSarray			aval ;
} ;
typedef union VS_u_allTypes VSallTypes ;

struct VS_s_token {
	int		type ;
	VSallTypes	v ;
} ;
typedef struct VS_s_token VS_TOKEN ;

struct VS_s_node {
	int			type ;
	VSallTypes		v ;
	struct VS_s_node	*a1,
				*a2,
				*a3 ;
} ;
#define _dval v.dval
#define _ival v.ival
#define _sval v.sval
#define _oval v.oval
#define _aval v.aval

typedef struct VS_s_node VS_NODE ;

struct VS_s_execRes {
	int		type ;
	VSallTypes	v ;
} ;
typedef struct VS_s_execRes VSexecRes ;

typedef VStktxt VSaliasTable[VS_K_MAX_INPUT] ;

struct VS_s_execIn {
	struct GRvg_construct	*cst ;
	struct GRid		*INPUT ;
	int			count ;
	VSaliasTable		aliases ;
} ;
typedef struct VS_s_execIn VSexecIN ;

struct VS_s_execOut {
	struct GRid		*OUTPUT ;
	int			size,
				count ;
} ;
typedef struct VS_s_execOut  VSexecOUT ;

#endif
