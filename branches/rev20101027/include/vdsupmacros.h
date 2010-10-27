/* $Id: vdsupmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* I/VDS
 *
 * File:        $VDS/include/vdsupmacros.h
 *
 * Description:
 *	This file contains general support macros.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdsupmacros.h,v $
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	08/21/94	A. Zuurhout	Creation Date
 */

/* ---------------------------------------
 * include support files.
 */


/* ----------------------------------------
 * Prototypes
 */

#ifndef vd_supmacros_include
#       define vd_supmacros_include


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern	IGRchar VDgettime __(( ));

#if defined(__cplusplus)
}
#endif

/*+Me
  External Macro vd$get_time

  Abstract
      This macro returns current time and date in string format.

  Arguments

  Status/Return Code
      OM_S_SUCCESS    : if success

-Me*/
  
#omdef vd$get_time()
        VDgettime ()
#endomdef

#endif /* vd_supmacros_include */
