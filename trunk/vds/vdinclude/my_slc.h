/* $Id: my_slc.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS        Copy
 *
 * File:        vds/vdinclude / my_slc.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: my_slc.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/10/13  21:20:00  pinnacle
 * Created: vdinclude/my_slc.h by mdong for vds
 *
 *
 * History:
 * -------------------------------------------------------------------*/

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



struct VD_s_execOut {
	struct GRid		*OUTPUT ;
	int			size,
				count ;
} ;
typedef struct VD_s_execOut  VD_execOUT ;

#endif
