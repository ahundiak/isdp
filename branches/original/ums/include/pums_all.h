#if defined(__STDC__) || defined(__cplusplus)
# define UMS_PROTO(s) s
#else
# define UMS_PROTO(s) ()
#endif


/* COMPcall.c */
extern int UMScompile UMS_PROTO((char *text_file, char *message_file, char *c_include, char *for_include));
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
extern int UMS_int_convert UMS_PROTO((int *value));
extern int UMS_long_convert UMS_PROTO((long *value));
extern int UMS_short_convert UMS_PROTO((short *value));
extern int _UMSOpenFile UMS_PROTO((UMSHeader *msgHdr));
extern int _UMSCloseFile UMS_PROTO((UMSHeader *msgHdr));
extern int _UMSReadFilePos UMS_PROTO((char dataBuf[], unsigned numBytes, long filePos));
extern int _UMSFilePos UMS_PROTO((long filePos));
extern int _UMSReadFile UMS_PROTO((char dataBuf[], unsigned numBytes));

/* UMSgbkey.c */
extern int UMSGetByKey UMS_PROTO((char msgBuf[], char *msgKey, char *msgFmt, ...));
extern int UMSGetByKeyVar UMS_PROTO((char msgBuf[], char *msgKey, char *msgFmt, va_list vars));

/* UMSgbnum.c */
extern int UMSGetByNum UMS_PROTO((char msgBuf[], long msgNum, char *msgFmt, ...));
extern int UMSGetByNumVar UMS_PROTO((char msgBuf[], long msgNum, char *msgFmt, va_list vars));

/* UMSinitm.c */
extern int UMSInitMsg UMS_PROTO((char *msgFile, int optFlag));
extern int _UMSInitMsgHdr UMS_PROTO((UMSHeader **newHdr, char *msgFile));
extern int _UMSInitNumIdx UMS_PROTO((UMSHeader *newHdr));
extern int _UMSInitBothIdx UMS_PROTO((UMSHeader *newHdr));
extern int _UMSInitTextBuf UMS_PROTO((UMSHeader *newHdr));
extern int _UMSInitKeyExt UMS_PROTO((UMSHeader *newHdr));
extern int _UMSInitKeyLst UMS_PROTO((UMSHeader *newHdr));
extern int UMSClearMsg UMS_PROTO((char *msgFile));
extern UMSHeader *_UMSHdrByFile UMS_PROTO((char *msgFile));
extern int _UMSFreeMem UMS_PROTO((UMSHeader *msgHdr));

/* UMSkeyby.c */
extern int UMSGetKeyByNum UMS_PROTO((char *msgKey, char *msgKey2, long msgNum));

/* UMSmsgco.c */
extern int UMSMsgCode UMS_PROTO((char codeBuf[], long msgNum, int supFlag, char *newComp, char *newType, char *newExt));

/* UMSmsgfm.c */
extern int _UMSPrepFormat UMS_PROTO((char *newMsgFmt, int *numArg, char *msgFmt));
extern int _UMSSubstitute UMS_PROTO((char *msgBuf, char *textBuf, char *varBuf, int numArg));

/* UMSnumby.c */
extern int UMSGetNumByKey UMS_PROTO((long *msgNum, char *msgKey));

/* UMSrbkey.c */
extern int UMSRetPtrByKey UMS_PROTO((char **msgPtr, int *msgLen, char *msgKey));
extern int _UMSReturnByKey UMS_PROTO((char *textBuf, char *msgKey));
extern int _UMSInterpretKey UMS_PROTO((UMSHeader **msgHdr, int *idx, char *msgKey));
extern int _UMSFindFileKidx UMS_PROTO((int *idx, UMSHeader *msgHdr, char *msgExt));
extern int _UMSFindMemKidx UMS_PROTO((int *idx, UMSHeader *msgHdr, char *msgExt));
extern int _UMSFindFileKey2 UMS_PROTO((UMSHeader **msgHdr, int *idx, char *msgKey2));
extern int _UMSFindMemKey2 UMS_PROTO((UMSHeader **msgHdr, int *idx, char *msgKey2));
extern int _UMSSearchFileBlock UMS_PROTO((int *idx, char *key, long filePos, long blockSize));

/* UMSrbnum.c */
extern int UMSRetPtrByNum UMS_PROTO((char **msgPtr, int *msgLen, long msgNum));
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
