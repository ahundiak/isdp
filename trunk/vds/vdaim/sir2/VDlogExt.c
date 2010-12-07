/* ----------------------------------------------
 * Just a few wrapper routines for the logger
 * Be nice if you could pass on ... args with a macro
 */

#include "VDtypedefc.h"
#include "VDlog.h"

#include "stdarg.h"

/* -----------------------------------------------
 * Error Logger
 */
IGRstat VDlogPrintE(IGRint stdOutFlag, IGRchar *fmt, ...)
{
  IGRstat retFlag = 0;

  IGRint  type = VDLOG_ERROR;

  IGRchar buf[256];

  va_list ap;
  
  // Buf the message
  va_start(ap,fmt);
  vsnprintf(buf,sizeof(buf),fmt,ap);  
  va_end(ap);

  // Print it
  VDlogPrintBuf(type,stdOutFlag,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Warning Logger
 */
IGRstat VDlogPrintW(IGRint stdOutFlag, IGRchar *fmt, ...)
{
  IGRstat retFlag = 0;

  IGRint  type = VDLOG_WARN;

  IGRchar buf[256];
  
  va_list ap;
  
  // Buf the message
  va_start(ap,fmt);
  vsnprintf(buf,sizeof(buf),fmt,ap);  
  va_end(ap);

  // Print it
  VDlogPrintBuf(type,stdOutFlag,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Info Logger
 */
IGRstat VDlogPrintI(IGRint stdOutFlag, IGRchar *fmt, ...)
{
  IGRstat retFlag = 0;

  IGRint  type = VDLOG_INFO;

  IGRchar buf[256];
  
  va_list ap;
  
  // Buf the message
  va_start(ap,fmt);
  vsnprintf(buf,sizeof(buf),fmt,ap);  
  va_end(ap);

  // Print it
  VDlogPrintBuf(type,stdOutFlag,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Debug Logger
 */
IGRstat VDlogPrintD(IGRint stdOutFlag, IGRchar *fmt, ...)
{
  IGRstat retFlag = 0;

  IGRint  type = VDLOG_DEBUG;

  IGRchar buf[256];
  
  va_list ap;
  
  // Buf the message
  va_start(ap,fmt);
  vsnprintf(buf,sizeof(buf),fmt,ap);  
  va_end(ap);

  // Print it
  VDlogPrintBuf(type,stdOutFlag,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Stat Logger
 */
IGRstat VDlogPrintS(IGRint stdOutFlag, IGRchar *fmt, ...)
{
  IGRstat retFlag = 0;

  IGRint  type = VDLOG_STAT;

  IGRchar buf[256];
  
  va_list ap;
  
  // Buf the message
  va_start(ap,fmt);
  vsnprintf(buf,sizeof(buf),fmt,ap);  
  va_end(ap);

  // Print it
  VDlogPrintBuf(type,stdOutFlag,buf);
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

