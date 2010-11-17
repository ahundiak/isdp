#ifndef LOG_H
#define LOG_H

/* log.c */
extern void logBuf(int type, int stdOutFlag, char *buf);
extern void logMsg(int type, int stdOutFlag, char *fmt, ...);

extern void closeLogFiles();
extern void openTraceLogFile(char *fileName);
extern void openErrorLogFile(char *fileName);
extern void openSpecialLogFile(char *fileName);

#endif
