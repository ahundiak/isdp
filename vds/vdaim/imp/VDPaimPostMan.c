/***************************************************************************
 * I/AIM
 *
 * File:        sir/VDPaimPostMan.c
 *
 * Description: New interfaces to the postman library
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimPostMan.c,v $
 *      Revision 1.2.2.1  2003/05/30 19:08:54  ahundiak
 *      ah
 *
 *      Revision 1.2  2003/05/27 13:35:15  ahundiak
 *      ah
 *
 *      Revision 1.1  2003/05/16 14:39:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/17/03  ah      Creation
 ***************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>

#include <sys/types.h>
#include <sys/varargs.h>
#include <sys/socket.h>

#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>

#include "VDPaimPostMan.h"

#define CLIX_CONNECT	  -1
#define CLIX_DISCONNECT -2

/* ----------------------------------------------
 * Information from last request 
 */
static char s_errorMsg[256];
static int  s_error1;
static int  s_error2;

char *VDPaimPostManGetErrorMsg() { return s_errorMsg; }
int   VDPaimPostManGetError1()   { return s_error1; }
int   VDPaimPostManGetError2()   { return s_error2; }

/* ----------------------------------------------
 * New interface for connecting to AIM
 */
int VDPaimPostManConnect(char *serverHostName)
{
  int sts;

  char *errmsg = NULL;

  struct hostent *hp;

  /* Init */
 *s_errorMsg = 0;
  s_error1 = 0;
  s_error2 = 0;

  /* Arg check */
  assert(serverHostName && *serverHostName);

  /* Get the host info */
  hp = gethostbyname(serverHostName);
  if (hp == NULL)
  {
    sprintf(s_errorMsg,"Could Not Find AIM Server %s",serverHostName);
    s_error1 = 1;
    return 1;
  }

  /* Do It */
  sts = POSTMAN_REQUEST_ON_CLIX(CLIX_CONNECT,
          (char *)inet_ntoa(*((struct in_addr *)hp->h_addr)),
          NULL,NULL,NULL,&errmsg);

  if (sts == 0) return 0;

  s_error1 = sts;
  if (errmsg) strcpy(s_errorMsg,errmsg);
  
  /* Override the sometime obscure error message */      
  sprintf(s_errorMsg,"Failed to connect to AIM Server %s",serverHostName);

  return sts;
}

/* ----------------------------------------------
 * New interface for disconnecting from AIM
 */
int VDPaimPostManDisConnect()
{
  int sts;

  char *errmsg = NULL;

 *s_errorMsg = 0;
  s_error1 = 0;
  s_error2 = 0;

  sts = POSTMAN_REQUEST_ON_CLIX(CLIX_DISCONNECT,
    NULL,NULL,NULL,NULL,&errmsg);

  s_error1 = sts;
  if (errmsg) strcpy(s_errorMsg,errmsg);
  else        strcpy(s_errorMsg,"Problem disconnecting from AIM Server");
  return sts;
}

/* ----------------------------------------------
 * Unpack the next item from the format string
 * Return 0 when not more args
 */
static int getArgInfo(char *fmtx, char **px, char *cx, int *lenx)
{
  int   retFlag = 0;

  char *fmt = fmtx;
  char *p   = *px;
  char  c   = 0;
  int   len = 0;

  /* Check if done */
  if (fmt == NULL) goto wrapup;
  if ((p  == NULL) || (*p == 0)) goto wrapup;

  while(*p)
  {
    switch(*p)
    {
      case 'd': case 's': case 'f':
        c = *p++;
        retFlag = 1;
      goto wrapup;

      case '%':

        /* Pull out any number */
        if (isdigit(*(p+1)))
        {
          p++;
          len = atoi(p);
          while(isdigit(*p)) p++;
          p--;
        }
      break;
    }
    p++;
  }

wrapup:
  *px = p;
  *cx = c;
  *lenx = len;
  return retFlag;
}

/* ----------------------------------------------
 * First Generation Query 
 */
int VDPaimPostManRequest(int *retBufLen, char **retBuf, char *fmt, ...)
{
  int sts = 0;

  char *qryBuf;
  char  qryBufx[256];
  int   qryBufLen;

  va_list ap;

  char   *p;
  char    c;
  int     cLen;

  int     argD;
  double  argF;
  char   *argS;

  int   mfail;
  char *errmsg = NULL;

  /* Init */
  *retBufLen = 0;
  *retBuf    = NULL;

 *s_errorMsg = 0;
  s_error1 = 0;
  s_error2 = 0;

  /* Must have a format */
  assert(fmt && *fmt);

  /* Cycle once to get required buf len */
  qryBufLen = 0;
  p = fmt;
  va_start(ap,fmt);
  while(getArgInfo(fmt,&p,&c,&cLen))
  {
    switch(c)
    {
      case 'd':
        argD = va_arg(ap, int);
        qryBufLen += sizeof(int);
      break;

      case 'f':
        argF = va_arg(ap, double);
        qryBufLen += sizeof(double);
      break;

      case 's':
        argS = va_arg(ap, char*);
        if (argS) qryBufLen += strlen(argS) + 1;
        else      qryBufLen++;
      break;
    
      default: assert(0);
    }
  }
  va_end(ap);
  assert(qryBufLen);

  /* See if a new buffer is needed */
  if (qryBufLen <= 256) qryBuf = qryBufx;
  else
  {
    qryBuf = malloc(qryBufLen);
    assert(qryBuf);
  }

  /* Fill in the buffer */
  qryBufLen = 0;
  p = fmt;
  va_start(ap,fmt);
  while(getArgInfo(fmt,&p,&c,&cLen))
  {
    switch(c)
    {
      case 'd':
        argD = va_arg(ap, int);
        memcpy(&qryBuf[qryBufLen],&argD,sizeof(int));
        qryBufLen += sizeof(int);
      break;

      case 'f':
        argF = va_arg(ap, double);
        memcpy(&qryBuf[qryBufLen],&argF,sizeof(double));
        qryBufLen += sizeof(double);
      break;

      case 's':
        argS = va_arg(ap, char*);
        if (argS) 
        {
          strcpy(&qryBuf[qryBufLen],argS);
          qryBufLen += strlen(argS) + 1;
        }
        else qryBuf[qryBufLen++] = 0;
      break;
    
      default: assert(0);
    }
  }
  va_end(ap);

  /* Execute it */
  sts = POSTMAN_REQUEST_ON_CLIX(qryBufLen,qryBuf, 
                                retBufLen,retBuf, 
                                &mfail,&errmsg);
  /* Free query buffer */
  if (qryBuf != qryBufx) free(qryBuf);

  /* Save error stuff */
  s_error1 = sts;
  s_error2 = mfail;

  if (errmsg) strcpy(s_errorMsg,errmsg);

  /* Return mfail if sts is okay */
  if (sts == 0) sts = mfail;

  /* Override the reset message */
  if (sts == 12345) 
  {
    strcpy(s_errorMsg,"AIM connection was reset by server.");
  }

  /* Make sure have some sort of error message */
  if (sts && (*s_errorMsg == 0))
  {
    sprintf(s_errorMsg,"VDPaimPostManRequest Error Code %d",sts);
  }

  /* Done */
  return sts;
}
/* ----------------------------------------------
 * Use this to pull data out of a buffer returned
 * by the postman request routine.
 * Controlled with a format string
 */
int VDPaimPostManExtract(int bufLen, char *buf, int *bufIter, char *fmt, ...)
{
  int retFlag = 0;

  va_list ap;

  char *p;
  char  c;
  int   cLen;

  int    *argD;
  double *argF;
  char   *argS;

  int     len;
  int     iter;

  /* Arg check */
  assert(buf);
  assert(bufIter);
  assert(fmt);

  /* Cycle through the arguments */
  iter = *bufIter;
  p = fmt;
  va_start(ap,fmt);
  while(getArgInfo(fmt,&p,&c,&cLen))
  {
    switch(c)
    {
      case 'd':
        argD = va_arg(ap, int*);
        if (argD) *argD = 0;
        len = sizeof(int);
        if ((iter + len) <= bufLen) 
        {
          if (argD) memcpy(argD,&buf[iter],len);
        }
        iter += len;
      break;

      case 'f':
        argF = va_arg(ap, double*);
        if (argF) *argF = 0.0;
        len = sizeof(double);
        if ((iter + len) <= bufLen) 
        {
          if (argF) memcpy(argF,&buf[iter],len);
        }
        iter += len;
      break;

      case 's':
        argS = va_arg(ap, char*);
        if (argS) *argS = 0;
        len = strlen(&buf[iter]);
        if ((iter + len) < bufLen) 
        {
          if (argS) 
          {
            if (cLen == 0) cLen = len + 1;
            if (cLen >= (len+1)) strcpy(argS,&buf[iter]);
            else
            {
              memcpy(argS,&buf[iter],cLen);
              argS[cLen-1] = 0;
              retFlag = 2;
            }
          }
        } 
        iter += len + 1;
      break;
    
      default: assert(0);
    }
  }
  va_end(ap);

wrapup:
  *bufIter = iter;
  return retFlag;
}

