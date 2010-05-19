/* $Id: VDhttp.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDhttp.h
 *
 * Description: Public interface http routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDhttp.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/03/07  14:40:08  pinnacle
 * initial revision
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/07/00  ah      Creation
 *
 ***************************************************************************/

#ifndef VDhttp_include
#define VDhttp_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

// Usual stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

// -----------------------------------------------------------
// C++ Stuff
#if defined(__cplusplus)
extern "C" {
#endif

/* ------------------------------------------------
 * Executes a HTTP GET Operation
 */
extern IGRstat VDhttpDoGet __((IGRchar *hostName, // I - Host name 
			       IGRint   port,     // I - Default to 80
			       IGRchar *getStr,   // I - Sent to host
			       IGRint   bufLen,   // I - Length of buffer
			       IGRchar *buf));    // O - NULL Terminated string
  

#omdef vdhttp$DoGet(hostName,port=80,getStr,bufLen,buf)

VDhttpDoGet((hostName),(port),(getStr),(bufLen),(buf))

#endomdef

// ---------------------------------------------
#if defined(__cplusplus)
}
#endif

#endif
