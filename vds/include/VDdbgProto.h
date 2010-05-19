/* $Id: VDdbgProto.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDdbgProto.h
 *
 * Description: Debug Flag Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdbgProto.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1998/03/10  20:08:16  pinnacle
 * TraceFORM
 *
 * Revision 1.1  1998/03/06  00:26:36  pinnacle
 * Debug Flags
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/05/98  ah      Creation
 * 03/10/98  ah      Added TraceFORM
 ***************************************************************************/
#ifndef VDdbgProto_include
#define VDdbgProto_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDdbgGetTraceOM   __(());
extern int VDdbgGetTracePPL  __(());
extern int VDdbgGetTraceFORM __(());

extern int VDdbgGetTraceDev1 __(());
extern int VDdbgGetTraceDev2 __(());
extern int VDdbgGetTraceDev3 __(());
extern int VDdbgGetTraceDev4 __(());

extern int VDdbgSetTraceOM   __((int flag));
extern int VDdbgSetTracePPL  __((int flag));
extern int VDdbgSetTraceFORM __((int flag));

extern int VDdbgSetTraceDev1 __((int flag));
extern int VDdbgSetTraceDev2 __((int flag));
extern int VDdbgSetTraceDev3 __((int flag));
extern int VDdbgSetTraceDev4 __((int flag));

#if defined(__cplusplus)
}
#endif

#endif


