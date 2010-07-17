/* $Id: vsbeamproto.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        include/prototypes/vsbeamproto.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsbeamproto.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1997/09/29  13:12:14  pinnacle
 * TR179700969
 *
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 ***************************************************************************/

#ifndef vsbeamproto_include
#	define vsbeamproto_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

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
#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

extern long
VSbeamBox			__((	long		*msg,
					struct GRid	*bmId,
					struct GRmd_env	*bmEnv,
					GRrange		box )) ;

extern long
VScardpoint_to_vector		__((	long			*msg,
					struct GRmd_env		*profileEnv,
					struct GRid		*profileCurve,
					IGRboolean		*profOpt,
					enum VScardinal_point	cardPt,
					IGRvector		vector )) ;

extern long
VScardpt_to_vector		__((	struct GRmd_env		*profileEnv,
					struct GRid		profileDef,
					IGRboolean		*profOpt,
					enum VScardinal_point	cardPt,
					IGRvector		vector )) ;

// TR179700969 Added profOpt
extern long
VScardpoint_to_point		__((	long			*msg,
					struct GRmd_env		*profileEnv,
					struct GRid		*profileCurve,
					IGRboolean		*profOpt,
					enum VScardinal_point	cardPt,
					IGRpoint		point )) ;

// TR179700969 Added profOpt
extern long
VScardpt_to_point		__((	struct GRmd_env		*profileEnv,
					struct GRid		profileDef,
					IGRboolean		*profOpt,
					enum VScardinal_point	cardPt,
					IGRpoint		point )) ;

#endif /* vsbeamproto_include */

