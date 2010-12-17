#ifndef UMSfile_include
#define UMSfile_include


/*****************/
/** File Macros **/
/*****************/

#define	UMS_FILE_VERSION	2

#define	UMS_FILE_COMP_LEN	10
#define	UMS_FILE_EXT_LEN	33
#define	UMS_FILE_KEY2_LEN	33

#define	UMS_FILEIDX_LEN		3
#define	UMS_FILEIDX_MSGNUM	0
#define	UMS_FILEIDX_TEXTPTR	1
#define	UMS_FILEIDX_EXTPTR	2


/*****************************/
/** Message File Structures **/
/*****************************/

typedef	struct
{
	char	ums[3];
	char	version;
	short	baseNo;
	char	comp[UMS_FILE_COMP_LEN];
	long	numMsg;
/**
	long	textBufLen;
	long	extBufLen;
	long	key2BufLen;
**/
	int	textBufLen;
	int	extBufLen;
	int	key2BufLen;
} UMSFileHdr;

typedef	long	UMSFileIndex[UMS_FILEIDX_LEN];


#endif
