/* $Id: VDrisFunc.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDrisFunc.h
 *
 * Description: Special functions for converting ris data to strings
 *              Intended to be included to existing source code and
 *              replace local implementations of these functions with
 *              standard global functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrisFunc.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1999/04/30  21:56:00  pinnacle
 * ris conversion prototypes
 *
 * Revision 1.1  1998/10/11  13:48:26  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/30/99  ah      Creation
 ***************************************************************************/
#ifndef VDrisFunc_include
#define VDrisFunc_include

#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------------
 * The functions, implemented in vdris/imp/VdsFun.C
 */
extern int VdsRisSqlDblToStr      __((double val, char *buf));
extern int VdsRisSqlIntToStr      __((int    val, char *buf));
extern int VdsRisSqlStrToStr      __((char  *val, int len, char *buf));
extern int VdsRisSqlDateTimeToStr __((char  *val, int len, char *buf));
  

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
