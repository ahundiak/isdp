/* Do not alter this SPC information: $Revision: 1.4.9.1 $ */
/*
**	NAME:							ristypes.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**		add RIS_types_matrix by Jin Jing 8/93
*/

#ifndef RIS_TYPES_H
#define RIS_TYPES_H

#ifndef COM_EXTERN
# ifdef COM_GLOBAL_DEFINE
#  define COM_EXTERN
# else
#  define COM_EXTERN extern
# endif
#endif

#ifndef COM_INITIAL
# ifdef COM_GLOBAL_DEFINE
#  define COM_INITIAL(value) = value
# else
#  define COM_INITIAL(value)
# endif
#endif

/*
**	INCLUDES
*/
#include "ris.h"

/*
**	DEFINES
*/

#define RIS_ALIGN(type,ptr) \
	(ptr = (ptr + (RIS_types[type].sqllen-1) - (((int)(ptr)-1) & (RIS_types[type].sqllen-1))))

/*
**	TYPES
*/

/*
**	VARIABLES
*/
COM_EXTERN  short RIS_types_matrix[RIS_MAX_TYPES][RIS_MAX_TYPES]

#ifdef COM_GLOBAL_DEFINE
= {
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,
0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,
0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,
0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
}
#endif /* COM_GLOBAL_DEFINE */
;

COM_EXTERN  struct {
	short	sqllen;
	char	*string;
	char	*ifx_string;
	char	*ora_string;
	char	*igs_string;
	char	*db2_string;
	char	*rdb_string;
    char    *syb_string;
	char	*os400_string;
	char    *mssql_string;

} RIS_types[RIS_MAX_TYPES]

#ifdef COM_GLOBAL_DEFINE
= {
1,              "unknown", "unknown",   "unknown",     "unknown", "unknown",
"unknown","unknown","unknown","unknown",
1,              "char",    "char",      "varchar2",    	"varchar", "varchar",
"varchar","char","varchar","varchar",
1,              "unknown", "unknown",   "unknown",     "unknown", "unknown",
"unknown","unknown","unknown","unknown",
sizeof(double), "decimal", "decimal",   "number",      "float8",  "decimal",
"decimal","decimal","decimal","float",
sizeof(int),    "int",     "integer",   "number(10,0)","integer4","integer",
"integer","int","integer","int",
sizeof(short),  "smallint","smallint",  "number(5,0)", "integer2","smallint",
"smallint","smallint","smallint","smallint",
1,              "unknown", "unknown",   "unknown",     "unknown", "unknown",
"unknown","unknown","unknown","unknown",
sizeof(float),  "real",    "smallfloat","float(21)",   "float4",  "real",
"real","real","real","real",
sizeof(double), "double",  "float",     "number",       "float8",  "double precision",
"double precision","double precision","double precision","float",
1,              "timestamp","datetime",  "date",        "date",    "timestamp",
"date","datetime","timestamp", "datetime",
1,              "unknown", "unknown",   "unknown",     "unknown", "unknown",
"unknown","unknown","unknown","unknown",
1,              "unknown", "unknown",   "unknown",     "unknown", "unknown",
"unknown","unknown","unknown","unknown",
1,              "unknown", "unknown",   "unknown",     "unknown", "unknown",
"unknown","unknown","unknown","unknown",
1,              "unknown", "unknown",   "unknown",     "unknown", "unknown",
"unknown","unknown","unknown","unknown",
0,              "unsupported", "unsupported", "unsupported", "unsupported", "unsupported", "unsupported","unsupported","unsupported","unsupported",
1, 	"ris_blob", "byte", "long raw", "varchar", "unsupported", "varchar","unsupported","unsupported","unsupported",
1, 	"ris_text", "text", "long", "varchar", "unsupported", "varchar","unsupported","unsupported","unsupported"
}
#endif /* COM_GLOBAL_DEFINE */
;

#endif
