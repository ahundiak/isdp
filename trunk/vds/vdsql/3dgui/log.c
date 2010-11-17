/* ----------------------------------------------
 * Simple logging routines
 */
#include "stdio.h"
#include "stdlib.h"
#include "stdarg.h"
#include "log.h"

static FILE *s_errorFile   = NULL;
static FILE *s_traceFile   = NULL;
static FILE *s_specialFile = NULL;

void openErrorLogFile(char *fileName)
{
  if (s_errorFile) return;
  s_errorFile = fopen(fileName,"wt");
  return;
}
void openTraceLogFile(char *fileName)
{
  if (s_traceFile) return;
  s_traceFile = fopen(fileName,"wt");
  return;
}
void openSpecialLogFile(char *fileName)
{
  if (s_specialFile) return;
  s_specialFile = fopen(fileName,"wt");
  return;
}

void closeLogFiles()
{
  if (s_errorFile)
  {
    fclose(s_errorFile);
    s_errorFile = NULL;
  }
  if (s_traceFile)
  {
    fclose(s_traceFile);
    s_traceFile = NULL;
  }  
  if (s_specialFile)
  {
    fclose(s_specialFile);
    s_specialFile = NULL;
  }

  return;
}

void logBuf(int type, int stdOutFlag, char *buf)
{
  if (stdOutFlag) 
  {
    fputs(buf,stdout);
    fflush(stdout);
  }

  if ((s_traceFile) && (type != 2)) 
  {
    fputs(buf,s_traceFile);
    fflush(s_traceFile);
  }

  if ((s_errorFile) && (type == 1)) 
  {
    fputs(buf,s_errorFile);
    fflush(s_errorFile);
  }
  if ((s_specialFile) && (type == 2)) 
  {
    fputs(buf,s_specialFile);
    fflush(s_errorFile);
  }

  return;
}
void logMsg(int type, int stdOutFlag, char *fmt, ...)
{
  char buf[4096];
  va_list ap;
  
  // Buf the message
  va_start(ap,fmt);
  vsnprintf(buf,sizeof(buf),fmt,ap);  
  va_end(ap);

  logBuf(type,stdOutFlag,buf);
}



