/****************************************************************
   pums_pri.h -
    This is the ANSI-C function prototype header file for private
    functions in the UMS Product ( UMS SN01256 )
    Not for public release.
*****************************************************************
   Copyright 1992 Intergraph Corporation
   All Rights Reserved, Including this Release Note, the
   Product it Describes, its File Formats, and Visual Displays
*****************************************************************/


#ifndef PUMS_PRI_H_INCLUDED
#define PUMS_PRI_H_INCLUDED 1

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define UMS_PROTO(s) s
#else
#define UMS_PROTO(s) ()
#endif

#include <stdio.h>
#include <stdarg.h>
#include <ums.h>
#include <umsfile.h>
#include <umspriv.h>
#include <comp.h>
#include <umccomp.h>


                 /**************************/
                 /*** all UMS Functions  ***/
                 /**************************/

/* COMPcall.c */
extern int UMCCmdLine UMS_PROTO((int argc, char *argv[], int *progFlag, char *textFile, char *msgFile, char *progFile));
extern int UMCDefNames UMS_PROTO((int progFlag, char *textFile, char *msgFile, char *progFile));
/* COMPmsg.c */
extern int UMCInitCOMP UMS_PROTO((char *compName));
extern int UMCErrorMsg UMS_PROTO((long msgNum, char *msgFmt, ...));
/* COMPread.c */
extern int UMCReadTxt UMS_PROTO((char *textFile, UMCFileData *fileData));
extern int UMCFileHdr UMS_PROTO((char line[], int lineNum, UMCFileData *fileData));
extern int UMCKeyLine UMS_PROTO((char line[], int lineNum, UMCFileData *fileData));
extern int UMCMsgLine UMS_PROTO((char line[], int lineNum, UMCFileData *fileData));
extern int UMCGetLine UMS_PROTO((FILE *fp, char line[], int *lineNum));
extern int UMCCheckMem UMS_PROTO((int msgLen, int extLen, int key2Len, UMCFileData *fileData));
/* COMPwrit.c */
extern int UMCWriteMsg UMS_PROTO((char *msgFile, UMCFileData *fileData));
extern int UMCWriteH UMS_PROTO((char *progFile, UMCFileData *fileData));
extern int UMCWriteInc UMS_PROTO((char *progFile, UMCFileData *fileData));
/* UMSfile.c */
extern int _UMSOpenFile UMS_PROTO((UMSHeader *msgHdr));
extern int _UMSCloseFile UMS_PROTO((UMSHeader *msgHdr));
extern int _UMSReadFilePos UMS_PROTO((char dataBuf[], unsigned numBytes, long filePos));
extern int _UMSFilePos UMS_PROTO((long filePos));
extern int _UMSReadFile UMS_PROTO((char dataBuf[], unsigned numBytes));
/* UMSgbkey.c */
/* UMSgbnum.c */
/* UMSinitm.c */
extern int _UMSInitMsgHdr UMS_PROTO((UMSHeader **newHdr, char *msgFile));
extern int _UMSInitNumIdx UMS_PROTO((UMSHeader *newHdr));
extern int _UMSInitBothIdx UMS_PROTO((UMSHeader *newHdr));
extern int _UMSInitTextBuf UMS_PROTO((UMSHeader *newHdr));
extern int _UMSInitKeyExt UMS_PROTO((UMSHeader *newHdr));
extern int _UMSInitKeyLst UMS_PROTO((UMSHeader *newHdr));
extern UMSHeader *_UMSHdrByFile UMS_PROTO((char *msgFile));
extern int _UMSFreeMem UMS_PROTO((UMSHeader *msgHdr));
/* UMSkeyby.c */
/* UMSmsgco.c */
/* UMSmsgfm.c */
extern int _UMSPrepFormat UMS_PROTO((char *newMsgFmt, int *numArg, char *msgFmt));
extern int _UMSSubstitute UMS_PROTO((char *msgBuf, char *textBuf, char *varBuf, int numArg));
/* UMSnumby.c */
/* UMSrbkey.c */
extern int _UMSReturnByKey UMS_PROTO((char *textBuf, char *msgKey));
extern int _UMSInterpretKey UMS_PROTO((UMSHeader **msgHdr, int *idx, char *msgKey));
extern int _UMSFindFileKidx UMS_PROTO((int *idx, UMSHeader *msgHdr, char *msgExt));
extern int _UMSFindMemKidx UMS_PROTO((int *idx, UMSHeader *msgHdr, char *msgExt));
extern int _UMSFindFileKey2 UMS_PROTO((UMSHeader **msgHdr, int *idx, char *msgKey2));
extern int _UMSFindMemKey2 UMS_PROTO((UMSHeader **msgHdr, int *idx, char *msgKey2));
extern int _UMSSearchFileBlock UMS_PROTO((int *idx, char *key, long filePos, long blockSize));
/* UMSrbnum.c */
extern int _UMSReturnByNum UMS_PROTO((char *textBuf, long msgNum));
extern int _UMSInterpretNum UMS_PROTO((UMSHeader **msgHdr, int *msgCount, long msgNum));
extern int _UMSRetrieveByNum UMS_PROTO((char *textBuf, UMSHeader *msgHdr, long msgNum, int idx));
extern int _UMSGetFileIdx UMS_PROTO((long fileIdx[], int idx));
extern int _UMSGetFileText UMS_PROTO((char textBuf[], long textPtr));
extern int _UMSGetFileExt UMS_PROTO((char *extBuf, UMSHeader *msgHdr, long extPtr));
extern int _UMSGetMemText UMS_PROTO((char textBuf[], UMSHeader *msgHdr, int idx));
extern int _UMSGetMemTextPtr UMS_PROTO((char **textPtr, int *textLen, UMSHeader *msgHdr, int idx));
/* getopt.c */
extern int UMSgetopt UMS_PROTO((int argc, char **argv, char *optstring));

#undef UMS_PROTO

#if defined(__cplusplus)
}
#endif

#endif  /* #ifndef PUMS_PRI_H_INCLUDED */
