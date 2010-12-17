/* umsfile.c */
extern int _UMSOpenFile(UMSHeader *msgHdr);
extern int _UMSCloseFile(UMSHeader *msgHdr);
extern int _UMSReadFilePos(char dataBuf[], unsigned numBytes, long filePos);
extern int _UMSFilePos(long filePos);
extern int _UMSReadFile(char dataBuf[], unsigned numBytes);
/* umsgbkey.c */
/* umsgbnum.c */
/* umsinitm.c */
extern int _UMSInitMsgHdr(UMSHeader **newHdr, char *msgFile);
extern int _UMSInitNumIdx(UMSHeader *newHdr);
extern int _UMSInitBothIdx(UMSHeader *newHdr);
extern int _UMSInitTextBuf(UMSHeader *newHdr);
extern int _UMSInitKeyExt(UMSHeader *newHdr);
extern int _UMSInitKeyLst(UMSHeader *newHdr);
extern UMSHeader *_UMSHdrByFile(char *msgFile);
extern int _UMSFreeMem(UMSHeader *msgHdr);
/* umskeyby.c */
/* umsmsgco.c */
/* umsmsgfm.c */
extern int _UMSPrepFormat(char *newMsgFmt, int *numArg, char *msgFmt);
extern int _UMSSubstitute(char *msgBuf, char *textBuf, char *varBuf, int numArg);
/* umsnumby.c */
/* umsrbkey.c */
extern int _UMSReturnByKey(char *textBuf, char *msgKey);
extern int _UMSInterpretKey(UMSHeader **msgHdr, int *idx, char *msgKey);
extern int _UMSFindFileKidx(int *idx, UMSHeader *msgHdr, char *msgExt);
extern int _UMSFindMemKidx(int *idx, UMSHeader *msgHdr, char *msgExt);
extern int _UMSFindFileKey2(UMSHeader **msgHdr, int *idx, char *msgKey2);
extern int _UMSFindMemKey2(UMSHeader **msgHdr, int *idx, char *msgKey2);
extern int _UMSSearchFileBlock(int *idx, char *key, long filePos, long blockSize);
/* umsrbnum.c */
extern int _UMSReturnByNum(char *textBuf, long msgNum);
extern int _UMSInterpretNum(UMSHeader **msgHdr, int *msgCount, long msgNum);
extern int _UMSRetrieveByNum(char *textBuf, UMSHeader *msgHdr, long msgNum, int idx);
extern int _UMSGetFileIdx(long fileIdx[], int idx);
extern int _UMSGetFileText(char textBuf[], long textPtr);
extern int _UMSGetFileExt(char *extBuf, UMSHeader *msgHdr, long extPtr);
extern int _UMSGetMemText(char textBuf[], UMSHeader *msgHdr, int idx);
extern int _UMSGetMemTextPtr(char **textPtr, int *textLen, UMSHeader *msgHdr, int idx);
