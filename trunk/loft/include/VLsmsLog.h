/* $Id: VLsmsLog.h,v 1.1 2001/09/14 13:41:52 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        include/VLsms.h
 *
 * Description:	Struct Manufacturing Solutions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLsmsLog.h,v $
 *      Revision 1.1  2001/09/14 13:41:52  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/16 18:11:58  ramarao
 *      *** empty log message ***
 *
 * Revision 1.3  2000/11/27  20:22:12  pinnacle
 * ah
 *
 * Revision 1.2  2000/05/26  17:51:16  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/25  16:26:24  pinnacle
 * ah
 *
 * Revision 1.1  2000/02/25  17:34:00  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/10/99  ah      Creation
 ***************************************************************************/
#ifndef VLsmsLog_include
#define VLsmsLog_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------------
 * VLsmsLog.I 
 */
extern IGRstat VLsmsLog1 __((IGRint type, IGRint stdOut, IGRchar *fmt, ...));
extern IGRstat VLsmsLog2 __((IGRint type, IGRint stdOut, IGRchar *pre, 
			     TGRobj_env *objOE, TGRid *objID));

extern IGRstat VLsmsCloseLogFiles __(());
extern IGRstat VLsmsInitLogFiles  __(());
extern IGRstat VLsmsSetLogFile    __((IGRint nth, FILE *file));
extern FILE   *VLsmsGetLogFile    __((IGRint nth));

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif








