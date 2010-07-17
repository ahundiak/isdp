/*
	I/STRUCT
*/
#ifndef vsdata_include
#	define vsdata_include

enum VS_e_DataType { VSnullType = -1, VSdouble = 0, VSint = 1, VSstring = 2 } ;
typedef enum VS_e_DataType VSdataType ;

struct VS_s_DataLoc {
	unsigned short	type: 2,
			addr:14 ;
} ;
typedef struct VS_s_DataLoc VSdataLoc ;

union VS_u_DataPtr {
	double	*d ;
	int	*i ;
	char	*s ;
} ;
typedef union VS_u_DataPtr VSdataPtr ;

struct VS_s_DataDesc {
	VSdataType	type ;
	int		index;
	union {
		double	d ;
		char	*s;
		int	i ;
	} value ;
} ;

typedef struct VS_s_DataDesc VSdataDesc ;

#endif
