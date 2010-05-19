/* $Id: VDexp.h,v 1.3 2001/02/13 15:18:15 jayadev Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDexp.h
 *
 * Description:	Expression Processing
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDexp.h,v $
 * Revision 1.3  2001/02/13 15:18:15  jayadev
 * vd$exp_evaluate args changed
 *
 * Revision 1.2  2001/02/09 23:00:06  jayadev
 * expression evaluation macro vd$exp_evaluate()
 *
 * Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 * Initial import to CVS
 *
 * Revision 1.2  2000/03/09  21:41:42  pinnacle
 * ah
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
 * 03/08/00  ah      Add create routine
 * 05/02/01  Jayadev Add vd$exp_evaluate routine
 ***************************************************************************/

#ifndef VDexp_include
#define VDexp_include

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
 * Create routine
 */
extern IGRstat VDevaluateEXP __((IGRboolean        *flag,
                     	         IGRchar           *expName,
                                 struct GRobj_env  *object,
				 struct ACrg_coll  *rgColl));

#omdef vd$exp_evaluate(flag,    // OUTPUT
		       expName, // INPUT
		       object,  // INPUT
		       rgColl)  // OUTPUT

VDevaluateEXP((flag),(expName),(object),(rgColl))
#endomdef

/* ------------------------------------------------------------------------
 * Create routine
 */
extern IGRstat VDexpCreateTextExp __((VDosnum osnum, 
				      IGRchar *name, 
				      IGRchar *text, 
				      TGRid *objID));
  
#omdef vdexp$CreateTextExp(osnum = OM_K_NOT_AN_OS,
			   name,
			   text,
			   objID = NULL)

VDexpCreateTextExp((osnum),(name),(text),(objID))
#endomdef

/* ------------------------------------------------------------------------
 * Modify routine
 */
extern IGRstat VDexpModifyTextExp __((TGRid *objID, IGRchar *text));
  
#omdef vdexp$ModifyTextExp(objID,text)

VDexpModifyTextExp((objID),(text))
#endomdef


/* ------------------------------------------------------------------------
 * Get routine
 */
extern IGRstar VDexpGet
__((TGRobj_env *a_objOE,
    TGRid      *a_objID,
    
    IGRchar    *a_txt,
    IGRdouble  *a_dbl,
    IGRint     *a_int

));

#omdef vdexp$Get(objOE = NULL,
		 objID = NULL,
		 txt   = NULL,
		 dbl   = NULL,
		 jnt   = NULL
		)

VDexpGet((objOE),(objID),(txt),(dbl),(jnt))
#endomdef

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
