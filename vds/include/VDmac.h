/* $Id: VDmac.h,v 1.2 2001/03/06 16:23:48 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDmac.h
 *
 * Description:	Macro Processing
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDmac.h,v $
 * Revision 1.2  2001/03/06 16:23:48  ramarao
 * Created a new structure VDdgnMcInfo.
 *
 * Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 * Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1998/04/23  23:10:22  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/23/98  ah      Creation
 ***************************************************************************/

#ifndef VDmac_include
#define VDmac_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------------------------------------------------
 * Get routine
 */
extern IGRstar VDmacGet
__((TGRobj_env *a_objOE,
    TGRid      *a_objID,
    
    IGRchar    *a_footName,

    IGRchar    *a_defName,
    TGRid      *a_defID,

    TGRid      *a_footID
));

#omdef vdmac$Get(objOE    = NULL,
		 objID    = NULL,
		 footName = NULL,
		 defName  = NULL,
		 defID    = NULL,
		 footID   = NULL
		)

VDmacGet((objOE),(objID),(footName),(defName),(defID),(footID))
#endomdef

/*
 * Info related to a macro in a design file.
 */
typedef struct {

   IGRchar		macro_name[DI_PATH_MAX];
   IGRchar		library_name[DI_PATH_MAX];
   IGRint		occurrence_count;
   IGRboolean		is_symbol;

} VDdgnMcInfo ;

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
