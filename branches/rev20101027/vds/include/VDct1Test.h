/* $Id: VDct1Test.h,v 1.1 2001/01/09 22:17:57 art Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:  include/VDct1Test.h
 *
 * Description: Low level generic test routines
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDct1Test.h,v $
 *	Revision 1.1  2001/01/09 22:17:57  art
 *	ah
 *	
 * Revision 1.1  2000/08/15  17:51:58  pinnacle
 * ah
 *
 *
 *
 * History:
 * 08/14/00 ah  Created
 *
 * -------------------------------------------------------------------*/
#ifndef VDct1Test_include
#define VDct1Test_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDct1_include
#include "VDct1.h"
#endif

/* -------------------------------------------------------------------
 * Usual BS
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------------
 * The real generic routines are defined in VDct1Test.C
 */
extern IGRstat VDct1TestManager        __(());
extern IGRstat VDct1TestCreateSet      __((IGRchar  *setType, 
					   IGRchar  *setName, 
					   TVDct1JD *setJD));
  
extern IGRstat VDct1TestFindSet        __((IGRchar  *setType, 
					   IGRchar  *setName, 
					   TVDct1JD *setJD));
  
extern IGRstat VDct1TestIsSetNameValid __((IGRchar *setType, 
					   IGRchar *setName));

extern IGRstat VDct1TestGetTreeForSet  __((TVDct1JD *setJD,
					   TVDct1JD *treeJD));

extern IGRstat VDct1TestFindNode       __((TVDct1JD *searchJD, 
					   IGRchar  *nodeType, 
					   IGRchar  *nodeName,
					   TVDct1JD *foundJD));
  
extern IGRstat VDct1TestCreateNode     __((TVDct1JD *parentJD, 
				           IGRchar  *nodeType, 
				           IGRchar  *nodeName, 
					   TVDct1JD *createdJD));

extern IGRstat VDct1TestSetAttr        __((TVDct1JD *nodeJD,
					   IGRchar  *name,
					   IGRchar  *value));
  
/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif
#endif




