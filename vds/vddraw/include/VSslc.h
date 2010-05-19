/* $Id: VSslc.h,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/include/VSslc.h
 *
 * Description:
 *		Support I/STRUCT functionalities in I/VDS.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSslc.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/08/16  14:49:40  pinnacle
 * Created: vddraw/include/VSslc.h by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/13/95	adz		creation date
 *
 ***************************************************************************/

#ifndef VSslrc_include
#	define VSslrc_include

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
#ifndef VSslcdef_include
#	include "VSslcdef.h"
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
