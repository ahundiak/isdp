/********************************************************************
* Copyright (c) 1993, 1994
* Intergraph Corporation; All Rights Reserved
* Including Application Programs, File Formats, and Visual Displays
*
* File Name:          pums_pub.h,  $Revision: 1.1.38.1 $
* Description:        public function prototypes for UMS for Windows
*
* Change History:
*
*  When        Who   What
*  ---------   ---   ---------------------------------------------
*  02-AUG-94   JAJ   Added this header, and C++ wrappers, and removed
*                    "extern"'s from function prototypes.
********************************************************************/


#ifndef PUMS_PUB_H
#define PUMS_PUB_H 1


#ifdef __cplusplus
extern "C" {
#endif


#include "stdarg.h"

int  UMS_int_convert   ( int *value   );
int  UMS_long_convert  ( long *value  );
int  UMS_short_convert ( short *value );
int  UMSGetByKey    ( char msgBuf[], char *msgKey, char *msgFmt, ... );
int  UMSGetByKeyVar ( char msgBuf[], char *msgKey, char *msgFmt, va_list vars );
int  UMSGetByNum    ( char msgBuf[], long msgNum, char *msgFmt, ... );
int  UMSGetByNumVar ( char msgBuf[], long msgNum, char *msgFmt, va_list vars );
int  UMSInitMsg     ( char *msgFile, int optFlag );
int  UMSClearMsg    ( char *msgFile );
int  UMSGetKeyByNum ( char *msgKey, char *msgKey2, long msgNum );
int  UMSMsgCode     ( char codeBuf[], long msgNum, int supFlag,
                      char *newComp, char *newType, char *newExt );
int  UMSGetNumByKey ( long *msgNum, char *msgKey );
int  UMSRetPtrByKey ( char **msgPtr, int *msgLen, char *msgKey );
int  UMSRetPtrByNum ( char **msgPtr, int *msgLen, long msgNum );
void UMSExpandBackslash ( char *instring, char *outstring );
int  UMSSetExpandBackslashMode ( int mode );


#ifdef __cplusplus
}
#endif

#endif
