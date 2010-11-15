#include "UMSfile.h"
#include "UMCcomp.h"
#include "COMP.h"
#include "UMSpriv.h"


extern int main(int argc, char *argv[]);
extern int UMCCmdLine(int argc, char *argv[], int *progFlag, char *textFile, char *msgFile, char *progFile);
extern int UMCDefNames(int progFlag, char *textFile, char *msgFile, char *progFile);
extern int UMCInitCOMP(char *compName);
extern int UMCErrorMsg(long msgNum, char *msgFmt, ...);
extern int UMCReadTxt(char *textFile, UMCFileData *fileData);
extern int UMCFileHdr(char line[], int lineNum, UMCFileData *fileData);
extern int UMCKeyLine(char line[], int lineNum, UMCFileData *fileData);
extern int UMCMsgLine(char line[], int lineNum, UMCFileData *fileData);
extern int UMCGetLine(FILE *fp, char line[], int *lineNum);
extern int UMCCheckMem(int msgLen, int extLen, int key2Len, UMCFileData *fileData);
extern int UMCWriteMsg(char *msgFile, UMCFileData *fileData);
extern int UMCWriteH(char *progFile, UMCFileData *fileData);
extern int UMCWriteInc(char *progFile, UMCFileData *fileData);
extern char *IIwhence(char *name, char *workdir);
