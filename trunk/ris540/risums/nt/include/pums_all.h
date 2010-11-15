#include <stdarg.h>
#include "UMS.h"
#include "UMSpriv.h"
#include "UMSfile.h"

/* umsfile.c */
extern int UMS_int_convert(int *value);
extern int UMS_long_convert(long *value);
extern int UMS_short_convert(short *value);
extern int _UMSOpenFile(UMSHeader *msgHdr);
extern int _UMSCloseFile(UMSHeader *msgHdr);
extern int _UMSReadFilePos(char dataBuf[], unsigned numBytes, long filePos);
extern int _UMSFilePos(long filePos);
extern int _UMSReadFile(char dataBuf[], unsigned numBytes);

/* umsgbkey.c */
extern int UMSGetByKey(char msgBuf[], char *msgKey, char *msgFmt, ...);
extern int UMSGetByKeyVar(char msgBuf[], char *msgKey, char *msgFmt, va_list vars);

/* umsgbnum.c */
extern int UMSGetByNum(char msgBuf[], long msgNum, char *msgFmt, ...);
extern int UMSGetByNumVar(char msgBuf[], long msgNum, char *msgFmt, va_list vars);

/* umsinitm.c */
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
extern int UMSSetExpandBackslashMode (int mode);

/* umskeyby.c */
extern int UMSGetKeyByNum(char *msgKey, char *msgKey2, long msgNum);

/* umsmsgco.c */
extern int UMSMsgCode(char codeBuf[], long msgNum, int supFlag, char *newComp, char *newType, char *newExt);

/* umsmsgfm.c */
extern int _UMSPrepFormat(char *newMsgFmt, int *numArg, char *msgFmt);
extern int _UMSSubstitute(char *msgBuf, char *textBuf, char *varBuf, int numArg);

/* umsnumby.c */
extern int UMSGetNumByKey(long *msgNum, char *msgKey);

/* umsrbkey.c */
extern int UMSRetPtrByKey(char **msgPtr, int *msgLen, char *msgKey);
extern int _UMSReturnByKey(char *textBuf, char *msgKey);
extern int _UMSInterpretKey(UMSHeader **msgHdr, int *idx, char *msgKey);
extern int _UMSFindFileKidx(int *idx, UMSHeader *msgHdr, char *msgExt);
extern int _UMSFindMemKidx(int *idx, UMSHeader *msgHdr, char *msgExt);
extern int _UMSFindFileKey2(UMSHeader **msgHdr, int *idx, char *msgKey2);
extern int _UMSFindMemKey2(UMSHeader **msgHdr, int *idx, char *msgKey2);
extern int _UMSSearchFileBlock(int *idx, char *key, long filePos, long blockSize);

/* umsrbnum.c */
extern int UMSRetPtrByNum(char **msgPtr, int *msgLen, long msgNum);
extern int _UMSReturnByNum(char *textBuf, long msgNum);
extern int _UMSInterpretNum(UMSHeader **msgHdr, int *msgCount, long msgNum);
extern int _UMSRetrieveByNum(char *textBuf, UMSHeader *msgHdr, long msgNum, int idx);
extern int _UMSGetFileIdx(long fileIdx[], int idx);
extern int _UMSGetFileText(char textBuf[], long textPtr);
extern int _UMSGetFileExt(char *extBuf, UMSHeader *msgHdr, long extPtr);
extern int _UMSGetMemText(char textBuf[], UMSHeader *msgHdr, int idx);
extern int _UMSGetMemTextPtr(char **textPtr, int *textLen, UMSHeader *msgHdr, int idx);

/* UMSgetopt.c */
extern int UMSgetopt (int argc, char **argv, char *optstring);

/* COMPcall.c */
extern void UMSExpandBackslash(char *instring, char *outstring);
