/* 
 * File:   UMSx.h
 * Author: impd
 *
 * Created on December 11, 2010, 4:12 PM
 */

#ifndef UMSX_H
#define	UMSX_H

#define	UMS_COMP_LEN 10

#ifdef	__cplusplus
extern "C" {
#endif

typedef struct
{
  long msgNum;
  long txtPtr;
  long keyPtr;
} UMSIndex;

typedef	struct
{
  short     msgBase;
  char      comp[UMS_COMP_LEN];
  long      msgCount;
  UMSIndex *indexes;
  char     *txtBuf;
  char     *priKeyBuf;
  char     *secKeyBuf;
  char      msgFileName[1];
} UMSInfo;


#ifdef	__cplusplus
}
#endif

#endif	/* UMSX_H */

