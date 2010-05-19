/* $Id: v_slc.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include / v_slc.h
 *
 * Description:
 *	Parser structures - used by Visual and attribute expression interpreters
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_slc.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
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
 * Revision 1.2  1995/07/27  23:19:34  pinnacle
 * Replaced: include/v_slc.h for:  by tlbriggs for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	07/25/95   tlb		Added VD_drwArgLst from v_drw.h
 *
 *************************************************************************/

#ifndef v_slrc_include
#	define v_slrc_include

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
#ifndef v_slcdef_include
#	include "v_slcdef.h"
#endif

typedef char	VD_tktxt[VD_K_tokMAX_SIZE] ;

struct VD_s_parseErr {
	long	msg ;
	int	lineno,
		charno ;
	VD_tktxt	string ;
} ;
typedef struct VD_s_parseErr VD_parseErr ;

struct VD_s_array {
	unsigned short		size ;
	struct VD_s_execRes	*element ;
} ;
typedef struct VD_s_array VDarray ;

union VD_u_allTypes {
		double			dval ;
		int			ival ;
		VD_tktxt		sval ;
		struct GRobj_env	oval ;
		VDarray			aval ;
} ;
typedef union VD_u_allTypes VD_allTypes ;

struct VD_s_token {
	int		type ;
	VD_allTypes	v ;
} ;
typedef struct VD_s_token VD_TOKEN ;

struct VD_s_node {
	int			type ;
	VD_allTypes		v ;
	struct VD_s_node	*a1,
				*a2,
				*a3 ;
} ;
#define _dval v.dval
#define _ival v.ival
#define _sval v.sval
#define _oval v.oval
#define _aval v.aval

typedef struct VD_s_node VD_NODE ;

struct VD_s_execRes {
	int		type ;
	VD_allTypes	v ;
} ;
typedef struct VD_s_execRes VD_execRes ;

typedef VD_tktxt VD_aliasTable[VD_K_MAX_INPUT] ;

struct VD_s_execIn {
	struct GRvg_construct	*cst ;
	struct GRid		*INPUT ;
	int			count ;
	VD_aliasTable		aliases ;
} ;
typedef struct VD_s_execIn VD_execIN ;

struct VD_s_execOut {
	struct GRid		*OUTPUT ;
	int			size,
				count ;
} ;
typedef struct VD_s_execOut  VD_execOUT ;

/*
 * List of arguments of a function.
 */
struct VD_s_drwArgLst {
	VD_execRes		arg ;
	struct VD_s_drwArgLst	*next ;
} ;
typedef struct VD_s_drwArgLst VD_drwArgLst ;

#endif
