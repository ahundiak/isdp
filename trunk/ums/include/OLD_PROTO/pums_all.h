/****************************************************************
   pums_all.h -
    This is the ANSI-C function prototype header file for all 
    functions in the UMS Product ( UMS SN01256 )
    Not for public release.
*****************************************************************
   Copyright 1992 Intergraph Corporation
   All Rights Reserved, Including this Release Note, the
   Product it Describes, its File Formats, and Visual Displays
*****************************************************************/


#ifndef PUMS_ALL_H_INCLUDED
#define PUMS_ALL_H_INCLUDED 1

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(__STDC__) || defined(__cplusplus)


#include <stdio.h>
#include <stdarg.h>
#include "UMS.h"
#include "UMSfile.h"
#include "UMSpriv.h"
#include "COMP.h"
#include "UMCcomp.h"


                 /**************************/
                 /*** all UMS Functions  ***/
                 /**************************/


/* COMPcall.c */
extern int UMScompile(char *text_file, char *message_file, char *c_include, char *for_include);
extern int UMCCmdLine(int argc, char *argv[], int *progFlag, char *textFile, char *msgFile, char *progFile);
extern int UMCDefNames(int progFlag, char *textFile, char *msgFile, char *progFile);

/* COMPmsg.c */
extern int UMCInitCOMP(char *compName);
extern int UMCErrorMsg(long msgNum, char *msgFmt, ...);

/* COMPread.c */
extern int UMCReadTxt(char *textFile, UMCFileData *fileData);
extern int UMCFileHdr(char line[], int lineNum, UMCFileData *fileData);
extern int UMCKeyLine(char line[], int lineNum, UMCFileData *fileData);
extern int UMCMsgLine(char line[], int lineNum, UMCFileData *fileData);
extern int UMCGetLine(FILE *fp, char line[], int *lineNum);
extern int UMCCheckMem(int msgLen, int extLen, int key2Len, UMCFileData *fileData);

/* COMPwrit.c */
extern int UMCWriteMsg(char *msgFile, UMCFileData *fileData);
extern int UMCWriteH(char *progFile, UMCFileData *fileData);
extern int UMCWriteInc(char *progFile, UMCFileData *fileData);

/* UMSfile.c */
extern int UMS_int_convert(int *value);
extern int UMS_long_convert(long *value);
extern int UMS_short_convert(short *value);
extern int _UMSOpenFile(UMSHeader *msgHdr);
extern int _UMSCloseFile(UMSHeader *msgHdr);
extern int _UMSReadFilePos(char dataBuf[], unsigned numBytes, long filePos);
extern int _UMSFilePos(long filePos);
extern int _UMSReadFile(char dataBuf[], unsigned numBytes);

/* UMSgbkey.c */
extern int UMSGetByKey(char msgBuf[], char *msgKey, char *msgFmt, ...);
extern int UMSGetByKeyVar(char msgBuf[], char *msgKey, char *msgFmt, va_list vars);

/* UMSgbnum.c */
extern int UMSGetByNum(char msgBuf[], long msgNum, char *msgFmt, ...);
extern int UMSGetByNumVar(char msgBuf[], long msgNum, char *msgFmt, va_list vars);

/* UMSinitm.c */
extern int UMSInitMsg(char *msgFile, int optFlag);
extern int _UMSInitMsgHdr(UMSHeader **newHdr, char *msgFile);
extern int _UMSInitNumIdx(UMSHeader *newHdr);
extern int _UMSInitBothIdx(UMSHeader *newHdr);
extern int _UMSInitTextBuf(UMSHeader *newHdr);
extern int _UMSInitKeyExt(UMSHeader *newHdr);
extern int _UMSInitKeyLst(UMSHeader *newHdr);
extern int UMSClearMsg(char *msgFile);
extern UMSHeader *_UMSHdrByFile(char *msgFile);
extern int _UMSFreeMem(UMSHeader *msgHdr);

/* UMSkeyby.c */
extern int UMSGetKeyByNum(char *msgKey, char *msgKey2, long msgNum);

/* UMSmsgco.c */
extern int UMSMsgCode(char codeBuf[], long msgNum, int supFlag, char *newComp, char *newType, char *newExt);

/* UMSmsgfm.c */
extern int _UMSPrepFormat(char *newMsgFmt, int *numArg, char *msgFmt);
extern int _UMSSubstitute(char *msgBuf, char *textBuf, char *varBuf, int numArg);

/* UMSnumby.c */
extern int UMSGetNumByKey(long *msgNum, char *msgKey);

/* UMSrbkey.c */
extern int UMSRetPtrByKey(char **msgPtr, int *msgLen, char *msgKey);
extern int _UMSReturnByKey(char *textBuf, char *msgKey);
extern int _UMSInterpretKey(UMSHeader **msgHdr, int *idx, char *msgKey);
extern int _UMSFindFileKidx(int *idx, UMSHeader *msgHdr, char *msgExt);
extern int _UMSFindMemKidx(int *idx, UMSHeader *msgHdr, char *msgExt);
extern int _UMSFindFileKey2(UMSHeader **msgHdr, int *idx, char *msgKey2);
extern int _UMSFindMemKey2(UMSHeader **msgHdr, int *idx, char *msgKey2);
extern int _UMSSearchFileBlock(int *idx, char *key, long filePos, long blockSize);

/* UMSrbnum.c */
extern int UMSRetPtrByNum(char **msgPtr, int *msgLen, long msgNum);
extern int _UMSReturnByNum(char *textBuf, long msgNum);
extern int _UMSInterpretNum(UMSHeader **msgHdr, int *msgCount, long msgNum);
extern int _UMSRetrieveByNum(char *textBuf, UMSHeader *msgHdr, long msgNum, int idx);
extern int _UMSGetFileIdx(long fileIdx[], int idx);
extern int _UMSGetFileText(char textBuf[], long textPtr);
extern int _UMSGetFileExt(char *extBuf, UMSHeader *msgHdr, long extPtr);
extern int _UMSGetMemText(char textBuf[], UMSHeader *msgHdr, int idx);
extern int _UMSGetMemTextPtr(char **textPtr, int *textLen, UMSHeader *msgHdr, int idx);

/* getopt.c */
extern int UMSgetopt(int argc, char **argv, char *optstring);


#endif  /* #if defined(__STDC__) || defined(__cplusplus) */

#if defined(__cplusplus)
}
#endif

#endif  /* #ifndef PUMS_ALL_H */
