/* $Id: vdtr_ppl.h,v 1.2 2001/03/16 14:59:03 paul_noel Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDrev_ppl_progs.h
 *
 * Description:	Sets up access definitions for "Review PPL Programs" command
 *
 * Dependencies:
 *
 * Revision History:
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/01  pn      Creation
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
 * Access Routing
 */
extern IGRstat VDtrReviewPPLPrograms __(());

#omdef vdtr$ReviewPPLPrograms() 

VDtrReviewPPLPrograms(())
#endomdef




/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
