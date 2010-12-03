/***************************************************************************
 * I/AIM
 *
 * File:        include/VDPaimPostMan.h
 *
 * Description: New interfaces to the postman library
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDPaimPostMan.h,v $
 *      Revision 1.1.2.1  2003/05/16 14:28:50  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/17/03  ah      Creation
 ***************************************************************************/
#ifndef VDPaimPostMan_H
#define VDPaimPostMan_H

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------
 * Just a generic data buffer to make the code
 * a bit more readable
 */
typedef struct
{
  int   len;
  int   max;
  int   inc;
  int   iter;
  char *data;
} TVDPaimBuf;

/* ----------------------------------------------
 * The standard postman interface
 */
extern int 
POSTMAN_REQUEST_ON_CLIX __((int    inBufLen,
                            char  *inBuf, 
                            int   *outBufLen, 
                            char **outBuf, 
                            int   *mfail, 
                            char **errmsg));

/* ----------------------------------------------
 * Public Prototypes aim1.c
 */
extern int 
VDPaimPostManRequest __((int *bufLen,char **bufData,char *fmt,...));

extern int 
VDPaimPostManExtract __((int  bufLen,char  *bufData,int *bufIter,char *fmt,...));

extern int VDPaimPostManDisConnect __(());
extern int VDPaimPostManConnect    __((char *serverHostName));

extern char *VDPaimPostManGetErrorMsg __(());
extern int   VDPaimPostManGetError1   __(());
extern int   VDPaimPostManGetError2   __(());

/* ----------------------------------------------
 * Some utility stuff
 */
void VDPPutAimInfo(char *user, char *server, char *env);
void VDPGetAimInfo(char *user, char *server, char *env);

int VDPaimGetServerInfo(char *user, char *server, char *env);

/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif
#endif
