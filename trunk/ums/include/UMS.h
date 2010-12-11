#ifndef UMS_include
#define	UMS_include


#define	UMS_MAX_BUFLEN	512	

/*********************************/
/** File Initialization Options **/
/*********************************/

#define	UMS_INDEX	0x1	/* Save index based on message numbers	*/
#define	UMS_KEY		0x3	/* Save the primary message keys	*/
#define	UMS_KEY2	0x8	/* Save the secondary message keys	*/
#define	UMS_MESSAGE	0x5	/* Save the message text		*/


/************************/
/** UMSMsgCode Options **/
/************************/

#define	UMS_SUPPRESS_COMP	0x1	/* Do not interpret component	*/
#define	UMS_SUPPRESS_TYPE	0x2	/* Do not interpret type	*/
#define	UMS_SUPPRESS_EXT	0x4	/* Do not interpret extension	*/


/**********************/
/** UMS Return Codes **/
/**********************/

#define	UMS_S_SUCCESS	1

#define	UMS_I_DUPINIT	0xb		/* File already initialized	*/

#define	UMS_E_NOFILE	0x12		/* File not found or accessible	*/
#define	UMS_E_INVFMT	0x1a		/* Not indexed message file	*/
#define	UMS_E_INVVER	0x22		/* Invalid file version		*/
#define	UMS_E_TOOMANY	0x2a		/* Too many files open		*/
#define	UMS_E_OPEN	0x32		/* Other (obscure) open error	*/

#define	UMS_E_SEEK	0x3a		/* Error setting file position	*/
#define	UMS_E_READ	0x42		/* Error reading message file	*/
#define	UMS_E_EOF	0x4a		/* Read past the end-of-file	*/

#define	UMS_E_NOTFND	0x52		/* Message number/key not found	*/

#define	UMS_E_NOTINIT	0x5a		/* File not initialized		*/

#define	UMS_E_INSVMEM	0x62		/* Insufficient virtual memory	*/

#define	UMS_E_INVOPT	0x6a		/* Invalid initialization opt	*/

#define	UMS_W_NOTINMEM	0x70		/* Message text not in memory	*/

#define UMS_E_COMPILE	0x80		/* input file in wrong format */

/* ==================================================================== */
#if defined(__cplusplus)
extern "C" {
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define UMS_PROTO(s) s
#else
#define UMS_PROTO(s) ()
#endif

extern int UMSGetByKey UMS_PROTO((char msgBuf[], char *msgKey, char *msgFmt, ...));
extern int UMSGetByNum UMS_PROTO((char msgBuf[], long  msgNum, char *msgFmt, ...));

extern int UMSInitMsg     UMS_PROTO((char *msgFile, int optFlag));
extern int UMSClearMsg    UMS_PROTO((char *msgFile));
extern int UMSGetKeyByNum UMS_PROTO((char *msgKey, char *msgKey2, long msgNum));
extern int UMSMsgCode     UMS_PROTO((char codeBuf[], long msgNum, int supFlag, char *newComp, char *newType, char *newExt));
extern int UMSGetNumByKey UMS_PROTO((long *msgNum, char *msgKey));
extern int UMSRetPtrByKey UMS_PROTO((char **msgPtr, int *msgLen, char *msgKey));
extern int UMSRetPtrByNum UMS_PROTO((char **msgPtr, int *msgLen, long msgNum));

#undef UMS_PROTO

#if defined(__cplusplus)
}
#endif

#endif
