/* $Id: VDnb.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDnb.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDnb.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/12/17  23:16:38  pinnacle
 * VDnb
 *
 *
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      12/17/97  ah      Created
 ***************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

IGRstat VDnbGetTextFromID __((
  TGRid   *nbID, 
  IGRint   textSize, 
  IGRchar *text
));

IGRstat VDnbGetTextFromPath __((
  IGRchar *path, 
  IGRint   textSize, 
  IGRchar *text
));

#if defined(__cplusplus)
}
#endif

