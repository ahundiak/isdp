/* 
 * File:   UMS.h
 * Author: impd
 *
 * Created on December 11, 2010, 4:10 PM
 */

#ifndef UMS_H
#define	UMS_H

#define	UMS_S_SUCCESS 1
#define	UMS_E_FAIL    0

#ifdef	__cplusplus
extern "C" {
#endif

extern int UMSInitMsg (char *msgFile, int options);
extern int UMSGetByNum(char msgBuf[], long  msgNum, char *msgFmt, ...);

#ifdef	__cplusplus
}
#endif

#endif	/* UMS_H */

