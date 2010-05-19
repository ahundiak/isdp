/* $Id: VDtypedef.h,v 1.2 2002/05/10 13:42:48 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDtypedef.h
 *
 * Description: Got tired of typing struct
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDtypedef.h,v $
 *      Revision 1.2  2002/05/10 13:42:48  ahundiak
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  1999/04/08  20:51:02  pinnacle
 * ah
 *
 * Revision 1.2  1998/10/08  17:10:26  pinnacle
 * ah
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.6  1998/04/08  21:35:52  pinnacle
 * ah
 *
 * Revision 1.5  1998/03/15  15:19:16  pinnacle
 * AssyTree
 *
 * Revision 1.4  1997/12/17  18:48:52  pinnacle
 * AssyTree
 *
 * Revision 1.3  1997/10/29  14:53:52  pinnacle
 * Added Headers
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/28/97  ah      Added header
 * 12/17/97  ah      Deleted VDmaster.h, was not working
 * 03/15/98  ah      Added includes to make it standalone, subset of VDmaster.h
 * 08/01/98  ah      Add bserr.h, nddef.h
 * 04/08/99  ah      Add some minor typedefs
 * 05/09/02  ah      Add a couple of NULL defines
 ***************************************************************************/

#ifndef VDtypedef_include
#define VDtypedef_include

#ifndef   _STDIO_H
#include "stdio.h"
#endif

#ifndef  _STANDARDS_H_
#include "standards.h"
#endif

// CLIX ppl does not like this one
#ifndef  _STDLIB_H
#ifndef   VD_PPL
#include "stdlib.h"
#endif
#endif

#ifndef  _STRING_H
#include "string.h"
#endif

// SOLARIS ppl does not like this one
#ifndef  _MATH_H
#ifndef   VD_PPL
#include "math.h"
#endif
#endif

#ifndef	  OM_D_PRIMITIVES
#include "OMprimitives.h"  /* Gets OMminimum,OMlimits,OMtypes */
#endif

#ifndef	  OM_D_ERRORDEF
#include "OMerrordef.h"
#endif

#ifndef	  OM_D_MACROS
#include "OMmacros.h"
#endif

#include "msdef.h"

#ifndef   igetypedef_include
#include "igetypedef.h"
#endif

#ifndef   igrtypedef_include
#include "igrtypedef.h"
#endif

#ifndef   igr_include
#include "igr.h"
#endif

#ifndef   igrdp_include
#include "igrdp.h"
#endif

#ifndef   grerr_include
#include "grerr.h"
#endif

#ifndef   gr_include
#include "gr.h"
#endif

#ifndef   growner_include
#include "growner.h"
#endif

#ifndef   madef_include
#include "madef.h"
#endif

#ifndef   godef_include
#include "godef.h"
#endif

#ifndef   go_include
#include "go.h"
#endif

#ifndef   exdef_include
#include "exdef.h"
#endif

#ifndef   ex_include
#include "ex.h"
#endif

#ifndef   exmacros_include
#include "exmacros.h"
#endif

#ifndef   griodef_include
#include "griodef.h"
#endif

#ifndef   grio_include
#include "grio.h"
#endif

#ifndef   grdpb_include
#include "grdpb.h"  /* Includes grdpbdef.h */
#endif

#ifndef   grdpbmacros_include
#include "grdpbmacros.h"
#endif

#ifndef   grmacros_include
#include "grmacros.h"
#endif

#ifndef   parametric_def
#include "parametric.h"
#endif

#ifndef   acrg_collect_include
#include "ACrg_collect.h"
#include "ACattrib.h"
#endif

#ifndef   msmacros_include
#include "msmacros.h"      /* Includes msdef.h */
#endif

#ifndef   bserr_include
#include "bserr.h"         /* Includes bstypes.h */
#endif

#ifndef   nddef_include
#include "nddef.h"
#endif

/* -----------------------------------------------
 * Start of the actual typedefs
 */
typedef struct GRid           TGRid;
typedef struct GRas           TGRas;
typedef struct GRmd_env       TGRmd_env;
typedef struct GRparms        TGRparms;
typedef struct GRlc_info      TGRlc_info;
typedef struct GRobj_env      TGRobj_env;
typedef struct GRsymbology    TGRsymbology;
typedef struct GRmdenv_info   TGRmdenv_info;
typedef struct GRvg_construct TGRvg_construct;

typedef struct IGRplane       TGRplane;
typedef struct IGRdisplay     TGRdisplay;
typedef struct IGRpolyline    TGRpolyline;
typedef struct IGRbsp_curve   TGRbsp_curve;
typedef struct IGRbsp_surface TGRbsp_surface;

typedef struct ret_struct     Tret_struct;

typedef struct ACrg_coll      TACrg_coll;

typedef IGRlong IGRstat;
typedef IGRlong IGRstar;

typedef OMuword    VDclassid;
typedef OMuword    VDosnum;
typedef OM_S_OBJID VDobjid;

typedef OMuword    TVDclassid;
typedef OMuword    TVDosnum;
typedef OM_S_OBJID TVDobjid;

#define VDtraOS OM_Gw_TransOSnum_0
#define VDcurOS OM_Gw_current_OS

#define NULL_OSNUM   ((OMuword) -1)
#define NULL_CLASSID ((OMuword) -1)

/* Warning Warning Warning
 * This will really mess with some people's mind!
 */
typedef struct { IGRdouble x,y,z; } TGRpoint;

// Of Include Block
#endif





