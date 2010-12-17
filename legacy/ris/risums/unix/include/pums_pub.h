/****************************************************************/
/* pums_pub.h -                                                 */
/*   This is the ANSI-C function prototype header file for the  */
/*   functions in the UMS Product ( UMS SN01256 )               */
/****************************************************************/
/*  Copyright 1992 Intergraph Corporation                       */
/*  All Rights Reserved, Including this Release Note, the       */
/*  Product it Describes, its File Formats, and Visual Displays */
/****************************************************************/


#ifndef PUMS_H_INCLUDED
#define PUMS_H_INCLUDED 1

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define UMS_PROTO(s) s
#else
#define UMS_PROTO(s) ()
#endif

#include <stdarg.h>
#include <ums.h>

                    /*********************/
                    /*** UMS Functions ***/
                    /*********************/

extern int UMScompile UMS_PROTO((char *text_file, char *message_file, char *c_include, char *for_include));
extern int UMS_int_convert UMS_PROTO((int *value));
extern int UMS_long_convert UMS_PROTO((long *value));
extern int UMS_short_convert UMS_PROTO((short *value));
extern int UMSGetByKey UMS_PROTO((char msgBuf[], char *msgKey, char *msgFmt, ...));
extern int UMSGetByKeyVar UMS_PROTO((char msgBuf[], char *msgKey, char *msgFmt, va_list vars));
extern int UMSGetByNum UMS_PROTO((char msgBuf[], long msgNum, char *msgFmt, ...));
extern int UMSGetByNumVar UMS_PROTO((char msgBuf[], long msgNum, char *msgFmt, va_list vars));
extern int UMSInitMsg UMS_PROTO((char *msgFile, int optFlag));
extern int UMSClearMsg UMS_PROTO((char *msgFile));
extern int UMSGetKeyByNum UMS_PROTO((char *msgKey, char *msgKey2, long msgNum));
extern int UMSMsgCode UMS_PROTO((char codeBuf[], long msgNum, int supFlag, char *newComp, char *newType, char *newExt));
extern int UMSGetNumByKey UMS_PROTO((long *msgNum, char *msgKey));
extern int UMSRetPtrByKey UMS_PROTO((char **msgPtr, int *msgLen, char *msgKey));
extern int UMSRetPtrByNum UMS_PROTO((char **msgPtr, int *msgLen, long msgNum));

#undef UMS_PROTO

#if defined(__cplusplus)
}
#endif

#endif  /* #ifndef PUMS_H */
